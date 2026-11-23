/****************************************************************************************************************************************
    * Class Name  : Core_MDF_PaymentProcessRetailMdfIPA 
    * Version     : 1.0   
    * Created Date: 28-09-2020 
    * Modification Log :
    * Developer                     Date                          Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Intel - Amal Thomas     28/09/2020                    Class contains all the methods supporting the Retail MDF Payment process
    *****************************************************************************************************************************************/
    
    public without sharing class Core_MDF_PaymentProcessRetailMdfIPA {
        
        //custom exception to throw if we don't have currency exchange rate for the input currency
        public class CustomException extends Exception{}
        // Map of unique key and payment wrapper for creating payment record
        public static Map<String,Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String,Core_MDF_PaymentWrapper>();
        
        // Map of key and RMF Payment file Wrapper for generating payment file
        public static Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
        
        // List of Claims related BU Split records to be created    
        public static List<Core_MDF_Claim_BU_Split__c> claimsBUSplitList = new List<Core_MDF_Claim_BU_Split__c>();
        
        private static String IPAProgram=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
        private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');

        //Claim to Cost Center Map 
        private static Map<Id,String> claimToCostCenterMap  = new Map<Id,String>();
        /************************************************************************************************************* 
    Method Name:        groupClaimsforPaymentFileRetailMDFIPA
    @return  :          Map of Unique Key and Payment file Wrapper
    @parameters:        List of Payment Due claims
    Description:        This method is used to group claims for Payment File using unique key 
    Added By:           Accenture - Pranav - 28/09/2020
    Modified By:        Pranav    Date:08-07-2021       Changes: Added BU Split changes
    *************************************************************************************************************/ 
        
        public static Map<String,Core_MDF_PaymentFileWrapper> groupClaimsforPaymentFileRetailMDFIPA(List<PartnerFundClaim> paymentDueClaimsTobeProcessed, Core_MDF_Payment_Run__c pRun,  Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmfMap, Map<Id, Core_MDF_Account_Node_Attributes__c> accountNodeAttributesMap){
            paymentFileWrapperMap.clear();
            paymentWrapperMap.clear();
            // Map to store Busines Unit and the correspong split percent field to refer in activity
            Map<String, String> buActivityFieldsMapping = new Map<String, String>();
            // Map to store Busines Unit/Product Category and the corresponding Profit center, material code - program check at both places
            Map<String, Core_MDF_Product_Category__mdt> profitCenterMMIdMapping = new Map<String, Core_MDF_Product_Category__mdt>();
            //Map to store the Product category metadata's budget Type as the key and record as the value
            Map<String, Core_MDF_Product_Category__mdt> productCategoryMap = new Map<String, Core_MDF_Product_Category__mdt>();
            //Map of List to store the eligible Budget Types as key and List of the valid records of those budget types
            Map<String, List<Core_MDF_BudgetType_ProdCategory_Split__mdt>> budgetTypeProdCategorySplitMap = new Map<String, List<Core_MDF_BudgetType_ProdCategory_Split__mdt>>(); //budgetTypeProdCategorySplitMap

            for(Core_MDF_CCP_Custom_Metadata_Utility__c buSplits : [Select Core_MDF_Field_5_txt__c, Core_MDF_Field_6_txt__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c =: pRun.Core_MDF_Program_Id__r.Name AND Core_MDF_Category__c = 'BU Splits']){
                if(!buActivityFieldsMapping.containsKey(buSplits.Core_MDF_Field_5_txt__c)){ 
                    //Core_MDF_Field_5_txt__c = Core_MDF_BU_Name__c, Core_MDF_Field_6_txt__c = Core_MDF_Field_Name__c
                    buActivityFieldsMapping.put(buSplits.Core_MDF_Field_5_txt__c, buSplits.Core_MDF_Field_6_txt__c);                    
                }            
            }
            
            for(Core_MDF_Product_Category__mdt buproductcategory : [Select MasterLabel,DeveloperName, Core_MDF_Budget_Type_Txt__c,Core_MDF_Profit_Center_Txt__c,Core_MDF_Material_Code_Txt__c,Core_MDF_Product_Category_Txt__c FROM Core_MDF_Product_Category__mdt WHERE Core_MDF_Program_Txt__c =: pRun.Core_MDF_Program_Id__r.Name]){
                profitCenterMMIdMapping.put(buproductcategory.MasterLabel, buproductcategory);               
                productCategoryMap.put(buproductcategory.DeveloperName,buproductcategory);
            }
            
            //Looping over all the Budget Type Split metadata records which are active and putting the values in the Map of List
            for(Core_MDF_BudgetType_ProdCategory_Split__mdt budgetTypeSplit : [Select MasterLabel, DeveloperName, Core_MDF_Active_Ind__c,Core_MDF_Budget_Type_Txt__c,Core_MDF_Product_Category_Txt__c,Core_MDF_Product_Category_Code__c,Core_MDF_Split_Percent_Nbr__c FROM Core_MDF_BudgetType_ProdCategory_Split__mdt WHERE Core_MDF_Active_Ind__c = true]){
                if(budgetTypeProdCategorySplitMap.containsKey(budgetTypeSplit.Core_MDF_Budget_Type_Txt__c)){
                    budgetTypeProdCategorySplitMap.get(budgetTypeSplit.Core_MDF_Budget_Type_Txt__c).add(budgetTypeSplit);                    
                }
                else{
                    budgetTypeProdCategorySplitMap.put(budgetTypeSplit.Core_MDF_Budget_Type_Txt__c, new List<Core_MDF_BudgetType_ProdCategory_Split__mdt>{budgetTypeSplit}); 
                }
            }
       
            // Get the list of programs for which Business unit split is applicable
            List<String> programsforBuSplit = String.valueOf(Core_MDF_Configuration__c.getValues('PROGRAMS_FOR_BU_SPLIT').Core_MDF_Value__c).split(';');//Intel Partner Alliance, Channel MDF
            
           Core_MDF_PaymentUtility.paymentSubCategoryWrapper pmtWrapper = Core_MDF_PaymentUtility.getPaymentSubCategoryMap(pRun.Core_MDF_Program_Id__r.Name,'');
           Map<String,Core_MDF_CCP_Custom_Metadata_Utility__c> leCodeClaimCountryToCostCenterMap = pmtWrapper.costCenterKeyValueMap;
           Core_MDF_CCP_Payment_File_Particulars__mdt defaultFileParticulars = [SELECT Core_MDF_GL_Account__c, Core_MDF_GL_Account_CSAR__c, Core_MDF_GL_Account_Customer_NonPO__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt WHERE Core_MDF_Program__c =: pRun.Core_MDF_Program_Txt__c LIMIT 1];
	    

            for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed) 
            {           
                //Unique key for group claims for Retail MDF/IPA payment File generation
                String fileWrapperKey;
                List<String> claimsBuList = new List<String>();
                Core_MDF_Comarketing_CMF_Map__c cmfRec = new Core_MDF_Comarketing_CMF_Map__c();
                Boolean hasCMFRecords = false;
                if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCreditMemo || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerPassThrough || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerCreditMemo)
                {
                  if(cmfMap.containsKey(claim.ChannelPartnerId) && cmfMap.get(claim.ChannelPartnerId) !=null){
                      cmfRec = cmfMap.get(claim.ChannelPartnerId);
                      hasCMFRecords = true;
                  }
                  
                  //Ignore the claims, if we don't have any Comarketing CMF Map active record for the Node account
                  if(!hasCMFRecords){
                      continue;
                  }
                }

            // WW42 deriving cost center based on claim Country, Region and Bank LE
            String costCenter = '';
            if((claim.Core_MDF_Program__c == IPAProgram || claim.Core_MDF_Program__c == CoGTMProgram) && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer){
                String claimCountry = (claim.Core_MDF_Program__c == CoGTMProgram) ? 'WW' : claim.Core_MDF_Country_Location_nm__c;
                String claimGeo = (claim.Core_MDF_Program__c == CoGTMProgram) ? 'WW' : claim.Core_MDF_Region_Cd__c;
                if(!leCodeClaimCountryToCostCenterMap.isEmpty() && leCodeClaimCountryToCostCenterMap != null)
                {
                    costCenter = leCodeClaimCountryToCostCenterMap.ContainsKey(claimCountry) ?  leCodeClaimCountryToCostCenterMap.get(claimCountry).Core_MDF_Value__c : leCodeClaimCountryToCostCenterMap.containsKey(claimGeo) ? leCodeClaimCountryToCostCenterMap.get(claimGeo).Core_MDF_Value__c : '';
                } 
                claimToCostCenterMap.put(claim.Id,costCenter);
            }
            // Get corresponding node attributes record and stamp glAccount
            String glAccount = '';
        
            if (claim.Core_MDF_Program__c == IPAProgram) {
                Core_MDF_Account_Node_Attributes__c nodeAttr = (claim.ChannelPartnerId != null) ? accountNodeAttributesMap.get(claim.ChannelPartnerId) : null;
                if (nodeAttr != null && 
                ((claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer && nodeAttr.Core_MDF_Final_NonPO_GL_Account_nbr__c != null)
                || (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO && nodeAttr.Core_MDF_Final_Cust_NonPO_GL_Acc_nbr__c != null)
                || ((claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCash) && nodeAttr.Core_MDF_Final_CSAR_GL_Account_nbr__c != null))) {
                    if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) {
                        glAccount = String.valueOf(nodeAttr.Core_MDF_Final_NonPO_GL_Account_nbr__c);
                    } else if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO) {
                        glAccount = String.valueOf(nodeAttr.Core_MDF_Final_Cust_NonPO_GL_Acc_nbr__c);
                    } else if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCash) {
                        glAccount = String.valueOf(nodeAttr.Core_MDF_Final_CSAR_GL_Account_nbr__c);
                    }
                } else {
                    if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) {
                        glAccount = defaultFileParticulars.Core_MDF_GL_Account__c;
                    } else if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO) {
                        glAccount = defaultFileParticulars.Core_MDF_GL_Account_Customer_NonPO__c;
                    } else if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCash) {
                        glAccount = defaultFileParticulars.Core_MDF_GL_Account_CSAR__c;
                    }
                }
            } else {
                glAccount = (claim.Core_MDF_Program__c == CoGTMProgram && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) ? defaultFileParticulars.Core_MDF_GL_Account__c : defaultFileParticulars.Core_MDF_GL_Account_CSAR__c;
            }
                // Get all the claim's Activity's Bu in a list - check with anish for the field
                if(claim.Request.Core_MDF_BU_Split__c != NULL && claim.Request.Core_MDF_BU_Split__c != ''){claimsBuList = claim.Request.Core_MDF_BU_Split__c.split(';'); }                      
                // If the List of BUs are not empty and program is applicable for BU split of claims 
                if(programsforBuSplit.contains(pRun.Core_MDF_Program_Id__r.Name) && claimsBuList != NULL && claimsBuList.size()>0){             
                    for(String businessUnit : claimsBuList){
                        
                        
                        // Get the corresponding BU's split percent                          
                        Integer buSplitPercent = Integer.valueOf(claim.Request.get(buActivityFieldsMapping.get(businessUnit)));                        
                        if(buSplitPercent > 0){  
                            // Get the Business unit/product category metadata record for the business unit
                            Core_MDF_Product_Category__mdt businessUnitPCMMID = profitCenterMMIdMapping.get(businessUnit);                         
                            // For each business unit, add instance of Bu split for claim in a list
                            //createBuSplitClaimChildRecords(claim, businessUnit, buSplitPercent);
                            // Check if the incoming claim's budget type matches with the budget types eligible for split
                            if(budgetTypeProdCategorySplitMap.containsKey(claim.Core_MDF_Budget_Type_Options_Nm__c) && (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCash)){
                                //Looping over the List of Budget Type Split metadata records which are related to the eligible Budget Types for Splitting
                                for(Core_MDF_BudgetType_ProdCategory_Split__mdt budgetTypeSplitRecord : ((List<Core_MDF_BudgetType_ProdCategory_Split__mdt>)budgetTypeProdCategorySplitMap.get(claim.Core_MDF_Budget_Type_Options_Nm__c))){ 
                                    //Getting the instance of Product Category metadata records which matches the key of the Budget Type Split metadata records
                                    Core_MDF_Product_Category__mdt productCategoryRecord = productCategoryMap.get(budgetTypeSplitRecord.Core_MDF_Product_Category_Code__c);
                                    //Creating File Wrapping and sending claim record, business unit, and the Budget Type Split metadata record                               
                                    fileWrapperKey = createFileWrapperKey(claim, businessUnit, budgetTypeSplitRecord,NULL,NULL);                                           
                                    // Creating Payment Line Items and putting in a map                                 
                                    createPaymentFileWrapper(claim, fileWrapperKey, businessUnit, buSplitPercent, productCategoryRecord, budgetTypeSplitRecord,cmfRec,NULL, NULL);
                                }                            
                            }
                            //for Non customer payment type 
                            else if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO){
                                fileWrapperKey = createFileWrapperKey(claim, businessUnit, NULL,costCenter,glAccount);  
                                createPaymentFileWrapper(claim, fileWrapperKey, businessUnit, buSplitPercent, businessUnitPCMMID, NULL,cmfRec,costCenter,glAccount); 
                            }
                            else {                     
                                fileWrapperKey = createFileWrapperKey(claim, businessUnit, NULL,NULL,glAccount);
                                createPaymentFileWrapper(claim, fileWrapperKey, businessUnit, buSplitPercent, businessUnitPCMMID, NULL,cmfRec,NULL,glAccount);                            
                            }
                        }
                    }
                }
                // For program where BUs is not applicable or no BUs are found on activity 
                else{
                    // Get the Business unit/product category metadata record for the activity's product category                
                    Core_MDF_Product_Category__mdt productCategory = profitCenterMMIdMapping.get(claim.Request.Core_MDF_Product_Category_txt__c);                  
                    fileWrapperKey = createFileWrapperKey(claim, NULL, NULL, costCenter, glAccount) ;
                    // Creating Payment Line Items and putting in a map - Business unit related params are null
                    if(claim.Core_MDF_Program__c == CoGTMProgram){
                        createPaymentFileWrapper(claim, fileWrapperKey, NULL, NULL, productCategory, NULL, cmfRec, costCenter, glAccount);
                    } else{
                        createPaymentFileWrapper(claim, fileWrapperKey, NULL, NULL, productCategory, NULL, NULL, NULL, glAccount);
                    }
                }
            }
            // Amount Conversion Required Only for Retail MDF
            if(pRun.Core_MDF_Budget_Type_nm__c!=null && (pRun.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType))
               && paymentFileWrapperMap != NULL && paymentFileWrapperMap.size()>0){
                   // Convert USD Amount of Claim into bank's local currency for file
                   paymentFileWrapperMap = getConvertedAmount(paymentFileWrapperMap);               
               }
            return paymentFileWrapperMap;          
        }

        /****************************************************************************************************** 
    Method Name:        createPaymentWrapperMap
    @return  :          Payment Wrapper Map
    @parameters:        Payment File Wrapper
    Description:        This method is used to create Map of Unique Key and Payment Wrapper
    Added By:           Accenture - Pranav - 28/09/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/  
        
        public static Map<String,Core_MDF_PaymentWrapper> createPaymentWrapperMap(Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap, Core_MDF_Payment_Run__c prunInstance)
        {
            //Unique key for group claims for Creating Payment Record
            String paymentWrapperKey;
            Decimal tempDecimal = 0;
            
            for(Core_MDF_PaymentFileWrapper fileWrapper : paymentFileWrapperMap.values())
            {            
                // key - ultimate Account, Bank, Supplier No, Quarter and Year
                paymentWrapperKey = fileWrapper.paymentWrapperUniqueKey;
                if(!fileWrapper.isRecoveryIncluded){ //Ignore Recovery Keys from File Wrapper
                    if(paymentWrapperMap.containsKey(paymentWrapperKey)){
                        // sum of all claim amount for the key - If business unit is non empty then sum the buAmount else sum the claims amount
                        paymentWrapperMap.get(paymentWrapperKey).sumOfClaimsAmount += fileWrapper.sumOfClaimsAmount;

                        if(fileWrapper.includeOnlyClaimAmountForPayment){
                            paymentWrapperMap.get(paymentWrapperKey).sumOfClaimsAmountExcludesRecovery += fileWrapper.sumOfClaimsAmountExcludesRecovery;
                        }
                        // Add Claims records in payment Wrapper
                        paymentWrapperMap.get(paymentWrapperKey).claimsToBeProcessed.addAll(fileWrapper.claimsToBeProcessed);
                        if(prunInstance.Core_MDF_Budget_Type_nm__c!=null && prunInstance.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType)){
                            // Get Converted Amount Sum in the Wrapper
                            paymentWrapperMap.get(paymentWrapperKey).sumOfConvertedAmount += fileWrapper.sumOfConvertedAmount; 

                            if(fileWrapper.includeOnlyClaimAmountForPayment) 
                                paymentWrapperMap.get(paymentWrapperKey).sumOfConvertedAmountExcludesRecovery += fileWrapper.sumOfConvertedAmountExcludesRecovery;         
                        }
                    }
                    else{
                        Core_MDF_PaymentWrapper wrapperObject = new Core_MDF_PaymentWrapper();
                        wrapperObject.claimsToBeProcessed.addAll(fileWrapper.claimsToBeProcessed);
                        //If business unit is non empty get sum the buAmount else get the claims amount
                        wrapperObject.sumOfClaimsAmount = fileWrapper.sumOfClaimsAmount;
                        
                        if(fileWrapper.includeOnlyClaimAmountForPayment){
                            wrapperObject.includeOnlyClaimAmountForPayment = true;
                            wrapperObject.sumOfClaimsAmountExcludesRecovery = fileWrapper.sumOfClaimsAmountExcludesRecovery;
                        }

                        if(prunInstance.Core_MDF_Budget_Type_nm__c!=null && prunInstance.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType)){
                            wrapperObject.sumOfConvertedAmount = fileWrapper.sumOfConvertedAmount;

                            if(fileWrapper.includeOnlyClaimAmountForPayment) 
                                wrapperObject.sumOfConvertedAmountExcludesRecovery = fileWrapper.sumOfConvertedAmountExcludesRecovery;
                        }
                        wrapperObject.currencyExchangeRate = fileWrapper.currencyExchangeRate;        
                        paymentWrapperMap.put(paymentWrapperKey, wrapperObject);
                    }
                }
            } 
            return paymentWrapperMap ;   
        }
        
        /****************************************************************************************************** 
    Method Name:        createPaymentRecordRetailMDF
    @return  :          Map of unique key and payment wrapper
    @parameters:        payment run instance and map of payment wrapper
    Description:        This method is used to create payment records
    Added By:           Accenture - Pranav - 28/09/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/    
        public static Map<String, Core_MDF_PaymentWrapper> createPaymentRecordRetailMDF(Core_MDF_Payment_Run__c pRunInstance,Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap, String paymentFileFormatName){
            
            //Map of unique key and payment record
            Map<String,Core_MDF_Payment__c> paymentRecordsToBeProcessedMap = new Map<String,Core_MDF_Payment__c>();
            // Describe call to fetch all the Payment Record Types
            Map<String,Schema.RecordTypeInfo> paymentRecordTypeMap = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName(); 
            
            Map<Id,Core_MDF_Payment__c> paymentMap = new Map<Id,Core_MDF_Payment__c>();
            //This method fetch payment record type and assign
            String paymentRecTypeDevName = Core_MDF_PaymentProcess.fetchPaymentRecordType(pRunInstance);
            
            if(paymentWrapperMap != NULL && paymentWrapperMap.size() > 0)
            {
                for (String uniqueKey : paymentWrapperMap.keyset())
                {
                    //New payment instance
                    Core_MDF_Payment__c payment = new Core_MDF_Payment__c();        
                    payment.Core_MDF_Payment_Run_Id__c = pRunInstance.Id;        
                    // Payment Record Type
                    if(paymentRecordTypeMap!=null && paymentRecordTypeMap.containsKey(paymentRecTypeDevName)){
                        payment.RecordTypeId =  paymentRecordTypeMap.get(paymentRecTypeDevName).getRecordTypeId();
                    }
                    if(pRunInstance.Core_MDF_Budget_Type_nm__c!=null && pRunInstance.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType)){
                        // get Converted Amount in payment Wrapper and Payment record
                        payment.Core_MDF_Converted_Amt_Nbr__c = paymentWrapperMap.get(uniqueKey).includeOnlyClaimAmountForPayment ? paymentWrapperMap.get(uniqueKey).sumOfConvertedAmountExcludesRecovery : paymentWrapperMap.get(uniqueKey).sumOfConvertedAmount;                
                        // get Currency Conversion rate
                        payment.Core_MDF_Conversion_Rate_Nbr__c = paymentWrapperMap.get(uniqueKey).currencyExchangeRate;
                    }
                    // Paid Amount
                    payment.Core_MDF_Paid_Amt__c = paymentWrapperMap.get(uniqueKey).includeOnlyClaimAmountForPayment ? paymentWrapperMap.get(uniqueKey).sumOfClaimsAmountExcludesRecovery.setScale(2,System.RoundingMode.DOWN) : paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN);
                    // Actual payment amount
                    payment.Core_MDF_RMF_Actual_Payment_Amt__c = paymentWrapperMap.get(uniqueKey).includeOnlyClaimAmountForPayment ? paymentWrapperMap.get(uniqueKey).sumOfClaimsAmountExcludesRecovery.setScale(2,System.RoundingMode.DOWN) : paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN);                
                    if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed != NULL && paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.size() > 0){
                        // Account Company 
                        payment.Core_MDF_Account_Id__c = paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                        // Currency Code of the bank
                        payment.Core_MDF_Currency_Cd_txt__c = paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;                
                        if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Budget_Type_Options_Nm__c!=null){ //Added Budget type US - US1017409
                        	payment.Core_MDF_Budget_Type_Nm__c =paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Budget_Type_Options_Nm__c;
                        } 
                    }
                    payment.Core_MDF_Payment_Type_txt__c = paymentFileFormatName;
                        paymentRecordsToBeProcessedMap.put(uniqueKey,payment);
                    //paymentRecordsToBeProcessedMap.put(uniqueKey,payment);
                }     

                if(paymentRecordsToBeProcessedMap!=NULL && paymentRecordsToBeProcessedMap.size() > 0){

                        Database.insert(paymentRecordsToBeProcessedMap.values());
                    
                    // Query the inserted Payment Records
                    paymentMap = new Map<Id,Core_MDF_Payment__c>([Select Core_MDF_Payment_Run_Id__c, Core_MDF_Paid_Amt__c, Name, Core_MDF_Payment_No_Txt__c,Id 
                                                                                              From Core_MDF_Payment__c where ID IN :paymentRecordsToBeProcessedMap.values()]);
                    
                    // add Payment record in each payment file wrapper and payment Wrapper attribute paymentForClaims
                    for(Core_MDF_PaymentFileWrapper paymentFileWrapper : paymentFileWrapperMap.values())
                    {
                        String uniqueKey = paymentFileWrapper.paymentWrapperUniqueKey.removeEnd('Recovery');
                        paymentFileWrapper.paymentForClaims = paymentMap.get(paymentRecordsToBeProcessedMap.get(uniqueKey).Id);
                        paymentWrapperMap.get(uniqueKey).paymentForClaims = paymentMap.get(paymentRecordsToBeProcessedMap.get(uniqueKey).Id);
                    }
                }
            }
                return paymentWrapperMap;

        }
        
        
        /****************************************************************************************************** 
    Method Name:        getConvertedAmount
    @return  :          Map of Payment File Wrapper
    @parameters:        Payment File Wrapper Map
    Description:        This method is used to get the Converted Amount into local Currency for each Payment file Wrapper
    Added By:           Accenture - Pranav - 01/08/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
        
        public static Map<String,Core_MDF_PaymentFileWrapper> getConvertedAmount(Map<String, Core_MDF_PaymentFileWrapper> paymentFileWrapper){
            
            list<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listofPayments = new list<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            Map<String, Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> mapOfConvertedCurrencies = new Map<String, Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            //Decimal convertedAmountinlocalCurr;
            
            for(Core_MDF_PaymentFileWrapper paymentFileWrapperRecord:  paymentFileWrapper.values())
            {
                // For all payment wrapper records ,create respective records for the currency conversion method
                Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                input.inputAmount = paymentFileWrapperRecord.sumOfClaimsAmount;
                input.inputCurrency = 'USD';
                input.outputCurrency = paymentFileWrapperRecord.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;
                input.inputDate = System.today();
                listofPayments.add(input);

                if(paymentFileWrapperRecord.includeOnlyClaimAmountForPayment){
                    Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount inputValue = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                    inputValue.inputAmount = paymentFileWrapperRecord.sumOfClaimsAmountExcludesRecovery;
                    inputValue.inputCurrency = 'USD';
                    inputValue.outputCurrency = paymentFileWrapperRecord.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;
                    inputValue.inputDate = System.today();
                    listofPayments.add(inputValue);
                }
                
            }
            if(listofPayments!= NULL && listofPayments.size() > 0)
            {
                // Converting payment amount stored in USD into its local currency and storing it in map
                mapOfConvertedCurrencies = Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency(listofPayments);          
            }
           
            for(Core_MDF_PaymentFileWrapper paymentFileWrapperRecord:  paymentFileWrapper.values())
            {
                // Creating a Key for each Payment Wrapper same as that of mapOfConvertedCurrencies's key  
                String currConvKey = String.valueOf(paymentFileWrapperRecord.sumOfClaimsAmount) +  '\t' + 'USD' +  '\t' + String.valueOf(System.today()) + '\t' +
                    String.valueOf(paymentFileWrapperRecord.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c);
                

                String currConvKeyForClaim = '';
                if(paymentFileWrapperRecord.includeOnlyClaimAmountForPayment){
                    currConvKeyForClaim = String.valueOf(paymentFileWrapperRecord.sumOfClaimsAmountExcludesRecovery) +  '\t' + 'USD' +  '\t' + String.valueOf(System.today()) + '\t' +
                    String.valueOf(paymentFileWrapperRecord.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c);
                }
                
                //Includes Claim + Recovery
                if(mapOfConvertedCurrencies!= NULL && mapOfConvertedCurrencies.containsKey(currConvKey))
                {

                    if(mapOfConvertedCurrencies.get(currConvKey).conversionRate > 0){
                        // Get Exchange rate from the Map
                        Decimal convRate = mapOfConvertedCurrencies.get(currConvKey).conversionRate ;
                        // Update Exchange Record in Payment Wrapper record
                        paymentFileWrapperRecord.currencyExchangeRate = convRate;  
                        // Converting Total Vat Amount into bank's Local Currency
                    	if(paymentFileWrapperRecord.isVatEligible){ paymentFileWrapperRecord.totalConvertedVatAmt = (paymentFileWrapperRecord.totalVatAmt * convRate).setScale(2);
                                                              }
                    }else{
                        throw new CustomException('Conversion rate cannot be Zero');
                    }            
                    // Get local Currency
                    String localCurrency = mapOfConvertedCurrencies.get(currConvKey).outputCurrency;
                    
                    // Get Amount after conversion into local Currency
                    Decimal convertedAmountinlocalCurr = mapOfConvertedCurrencies.get(currConvKey).convertedAmount;
                    // Updating sumOfConvertedAmount attribute for each payment wrapper 
                    paymentFileWrapperRecord.sumOfConvertedAmount = convertedAmountinlocalCurr;
                    
                }else{
                    throw new CustomException('Invalid currency exchange rate');
                }

                //Includes Only Claim
                if(String.isNotBlank(currConvKeyForClaim)){
                    if(mapOfConvertedCurrencies != null && mapOfConvertedCurrencies.containsKey(currConvKeyForClaim))
                    {   
                        // Get Amount after conversion into local Currency
                        Decimal convertedAmountinlocalCurr = mapOfConvertedCurrencies.get(currConvKeyForClaim).convertedAmount;
                        // Updating sumOfConvertedAmount attribute for each payment wrapper 
                        paymentFileWrapperRecord.sumOfConvertedAmountExcludesRecovery = convertedAmountinlocalCurr;
                        
                    }else{
                        throw new CustomException('Invalid currency exchange rate');
                    }
                }
            }
            
            return paymentFileWrapper;
        }
        
        /************************************************************************************************************* 
    Method Name:        createFileWrapperKey
    @return  :          Unique key for Payment File lines
    @parameters:        Claim
    Description:        This method creates a key from claim fields ; The key will be used for generating Payment File
    Added By:           Accenture - Pranav - 16/10/2020
    Modified By:        Date:       Changes: 
    *************************************************************************************************************/ 
        
        public static String createFileWrapperKey(PartnerFundClaim claim, String businessUnit, Core_MDF_BudgetType_ProdCategory_Split__mdt budgetTypeSplit, String costCenter, String glAccount)
        {
            String fileWrapperKey='';
            // Key for Payment File - RMF Claims & IPA Claims
            //In case of non vat claims, for IPA Program we have included Budget Type field to existing grouping logic
            if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCreditMemo || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerPassThrough || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerCreditMemo) 
            {
            fileWrapperKey =  String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c;    
            }
            else
            {
            fileWrapperKey = claim.Core_MDF_VAT_Eligibility_Ind__c? String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c+'_'+businessUnit+'_'+budgetTypeSplit?.Core_MDF_Product_Category_Code__c:
            claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_' + claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Request.Core_MDF_Product_Category_txt__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_' +claim.Core_MDF_Budget_Type_Options_Nm__c+'_'+businessUnit+'_'+budgetTypeSplit?.Core_MDF_Product_Category_Code__c;
     
            if(costCenter != null && costCenter != '' && claim.Core_MDF_Payment_Type_nm__c != Core_MDF_PaymentUtility.customerNonPO) {
                fileWrapperKey =  fileWrapperKey + '_' + costCenter ;
            }

            if((claim.Core_MDF_Program__c == IPAProgram || claim.Core_MDF_Program__c == CoGTMProgram) && glAccount != null) {
                fileWrapperKey = fileWrapperKey + '_' + glAccount;
            }
            if(claim.Core_MDF_Program__c == CoGTMProgram && !claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer && claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c != null) {
                fileWrapperKey = fileWrapperKey + '_' + claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c;
            }
            

               if (claim.Core_MDF_Program__c == CoGTMProgram && !claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer && claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c != null) {
                    fileWrapperKey = fileWrapperKey + '_' + claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c;
                }

            }
            
            return fileWrapperKey;       
        }
        /************************************************************************************************************* 
    Method Name:        createPaymentFileWrapper
    @return  :          void
    @parameters:        Claim , Key for File
    Description:        This method is used to group claims for Payment File using unique key 
    Added By:           Accenture - Pranav - 16/10/2020
    Modified By:        Date:       Changes: 
    *************************************************************************************************************/ 
        
        public static void createPaymentFileWrapper(PartnerFundClaim claim, String fileWrapperKey, String businessUnit, Integer buSplitPercent, Core_MDF_Product_Category__mdt productCategoryMdt, Core_MDF_BudgetType_ProdCategory_Split__mdt budgetTypeSplit,Core_MDF_Comarketing_CMF_Map__c cmfRec , String costCenter, String glAccount)
        {
            Decimal tempDecimal = 0;  
            String paymentUniqueKey ='';
            Boolean addRecoveryAmountInRow = true;
            // Unique Key for Payment record of RMF & IPA Claims
            //For VAT eligible Claims of RMF & IPA Programs, individual claim id
            //Added an extra check if program is RMF for Non Vat eligible claims.For IPA Non vat claims,included Budget Type field in exsiting grouping logic.
            if((claim.Core_MDF_Program__c == IPAProgram && (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCreditMemo || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerPassThrough))
             || (claim.Core_MDF_Program__c == CoGTMProgram && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerCreditMemo))
            {
                paymentUniqueKey =  String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c;  
                addRecoveryAmountInRow = false;  
            }
            else if((claim.Core_MDF_Program__c == IPAProgram || claim.Core_MDF_Program__c == CoGTMProgram) && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer)
            {
                paymentUniqueKey= claim.Core_MDF_VAT_Eligibility_Ind__c ? String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_'+claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c + '_' + businessUnit+ '_'+costCenter;
                if (glAccount != null) {
                    paymentUniqueKey += '_' + glAccount;
                }
            }
            else if(claim.Core_MDF_Program__c == CoGTMProgram && !claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer)
            {
                paymentUniqueKey= claim.Core_MDF_VAT_Eligibility_Ind__c ? String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_'+claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c;
                if (glAccount != null) {
                    paymentUniqueKey += '_' + glAccount;
                }
                if(claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c != null)
                {
                    paymentUniqueKey = paymentUniqueKey + '_' + claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c;
                }
                if(claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c != null)
                 {
                    paymentUniqueKey = paymentUniqueKey + '_' + claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c;
                }

            }

            else if(claim.Core_MDF_Program__c == IPAProgram && (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO))
            {
                paymentUniqueKey= claim.Core_MDF_VAT_Eligibility_Ind__c ? String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_'+claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c + '_' + businessUnit;
                
                if (glAccount != null) {
                    paymentUniqueKey += '_' + glAccount;
                }
            }
            else
            {
                paymentUniqueKey= claim.Core_MDF_VAT_Eligibility_Ind__c ? String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                (claim.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name) ?
                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c:
                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c;
                if ((claim.Core_MDF_Program__c == IPAProgram || claim.Core_MDF_Program__c == CoGTMProgram) && glAccount != null) {
                    paymentUniqueKey += '_' + glAccount;
                }
            }

            if(!claim.Core_MDF_VAT_Eligibility_Ind__c || claim.Core_MDF_Total_Claim_Recovery_Amount__c <= 0){
                addRecoveryAmountInRow = false;
            }

            if(paymentFileWrapperMap.containsKey(fileWrapperKey)){ 
                tempDecimal = claim.Amount;
                // Sum of All claims BU Amount in file line item
                if(buSplitPercent != NULL && buSplitPercent > 0){
                    //check if product category split percent is required
                    if(budgetTypeSplit != NULL && budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c > 0){                    
                        Double amtAfterSplitCalculate  = (tempDecimal * budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c)/100;
                        paymentFileWrapperMap.get(fileWrapperKey).sumOfClaimsAmount += ((amtAfterSplitCalculate * buSplitPercent)/100);                    
                    }
                    else {                  
                        paymentFileWrapperMap.get(fileWrapperKey).sumOfClaimsAmount += ((tempDecimal * buSplitPercent)/100);                        
                    }                    
                }
                // Sum of all the claims amount for the file line item
                else{
                    paymentFileWrapperMap.get(fileWrapperKey).sumOfClaimsAmount += tempDecimal;             
                }
                // Add the claims in Wrapper
                paymentFileWrapperMap.get(fileWrapperKey).claimsToBeProcessed.add(claim);

            }
            else{
                prepareFileWrapperObject(claim, paymentUniqueKey, fileWrapperKey, businessUnit, buSplitPercent, productCategoryMdt, budgetTypeSplit, cmfRec, addRecoveryAmountInRow, false,costCenter, glAccount);
                if(addRecoveryAmountInRow && claim.Core_MDF_Total_Claim_Recovery_Amount__c > 0){
                    prepareFileWrapperObject(claim, paymentUniqueKey, fileWrapperKey, businessUnit, buSplitPercent, productCategoryMdt, budgetTypeSplit, cmfRec, addRecoveryAmountInRow, true,costCenter, glAccount);
                }
            }    
        }


        public static void prepareFileWrapperObject(PartnerfundClaim claim, String paymentUniqueKey, String fileWrapperKey, String businessUnit, Integer buSplitPercent, Core_MDF_Product_Category__mdt productCategoryMdt, Core_MDF_BudgetType_ProdCategory_Split__mdt budgetTypeSplit,Core_MDF_Comarketing_CMF_Map__c cmfRec, Boolean addRecoveryAmountInRow, Boolean isRecoveryRow,String costCenter, String glAccount){
            Decimal tempDecimal = 0;
            Decimal claimsAmount = 0;
            Decimal totalVatAmount = 0;
            Core_MDF_PaymentFileWrapper fileWrapperObject = new Core_MDF_PaymentFileWrapper();

            fileWrapperObject.claimsToBeProcessed.add(claim);

            if(!isRecoveryRow){
                if(addRecoveryAmountInRow && claim.Core_MDF_Total_Claim_Recovery_Amount__c > 0){
                    tempDecimal = claim.Amount + claim.Core_MDF_Total_Claim_Recovery_Amount__c;
                    tempDecimal = tempDecimal.setScale(2, System.RoundingMode.HALF_UP); 
                    totalVatAmount = claim.Core_MDF_VAT_Amt__c + ((claim.Core_MDF_Total_Claim_Recovery_Amount__c * (String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) && claim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == '650' ? Decimal.valueOf(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) : String.isNotBlank(claim.Core_MDF_Bank__r.Core_MDF_VAT_pct__c) ? Decimal.valueOf(claim.Core_MDF_Bank__r.Core_MDF_VAT_pct__c) : 0 ))/100);
                    totalVatAmount = totalVatAmount.setScale(2, System.RoundingMode.HALF_UP);

                    //Set includeOnlyClaimAmountForPayment attribute only to VAT Claims
                if(claim.Core_MDF_VAT_Eligibility_Ind__c){
                    claimsAmount = claim.Amount;
                }
                }else{
                    tempDecimal = claim.Amount;
                    totalVatAmount = claim.Core_MDF_VAT_Amt__c;
                }

                
                
            }else{
                tempDecimal = claim.Core_MDF_Total_Claim_Recovery_Amount__c;
                totalVatAmount = ((claim.Core_MDF_Total_Claim_Recovery_Amount__c * (String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) && claim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == '650' ? Decimal.valueOf(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) : String.isNotBlank(claim.Core_MDF_Bank__r.Core_MDF_VAT_pct__c) ? Decimal.valueOf(claim.Core_MDF_Bank__r.Core_MDF_VAT_pct__c) : 0 ))/100);
                totalVatAmount = totalVatAmount.setScale(2, System.RoundingMode.HALF_UP);
            }

            // If Split percent is present then get Claim Amount as well as the Vat amount and multiply with split % for that BU - 
            if(buSplitPercent != NULL && buSplitPercent > 0){ 
                //check if product category split percent is required
                if(budgetTypeSplit != NULL && budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c > 0){              
                    Double amtAfterSplitCalculate  = (tempDecimal * budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c)/100;                    
                    fileWrapperObject.sumOfClaimsAmount = ((amtAfterSplitCalculate * buSplitPercent)/100) ;
                    Double vatAmt = claim.Core_MDF_VAT_Eligibility_Ind__c ?(totalVatAmount * budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c)/100: 0;
                    fileWrapperObject.totalVatAmt = (vatAmt * buSplitPercent)/100;                    
                    fileWrapperObject.businessUnit = businessUnit ;

                    if(claimsAmount > 0){
                        Double claimAmtAfterSplitCalculate  = (claimsAmount * budgetTypeSplit.Core_MDF_Split_Percent_Nbr__c)/100;                    
                        fileWrapperObject.sumOfClaimsAmountExcludesRecovery = ((claimAmtAfterSplitCalculate * buSplitPercent)/100);
                        fileWrapperObject.includeOnlyClaimAmountForPayment = true;   
                    }
                }                   
                else{                        
                    fileWrapperObject.sumOfClaimsAmount = ((tempDecimal * buSplitPercent)/100) ;
                    fileWrapperObject.totalVatAmt = claim.Core_MDF_VAT_Eligibility_Ind__c ?(totalVatAmount * buSplitPercent)/100 : 0;                        
                    fileWrapperObject.businessUnit = businessUnit ;

                    if(claimsAmount > 0){                  
                        fileWrapperObject.sumOfClaimsAmountExcludesRecovery = ((claimsAmount * buSplitPercent)/100) ;
                        fileWrapperObject.includeOnlyClaimAmountForPayment = true;  
                    }
                }
            }
            // If BU Split % is null then just add the claim's amount and vat amount directly
            else{
                fileWrapperObject.sumOfClaimsAmount = tempDecimal;
                fileWrapperObject.totalVatAmt = (claim.Core_MDF_VAT_Eligibility_Ind__c) ? totalVatAmount : 0;

                if(claimsAmount > 0){
                    fileWrapperObject.sumOfClaimsAmountExcludesRecovery = claimsAmount;
                    fileWrapperObject.includeOnlyClaimAmountForPayment = true;
                }
            }
            // update geo and subgeo with claim's geo , sub geo
            fileWrapperObject.geoLocation = claim.Core_MDF_Region_Cd__c;
            fileWrapperObject.subGeoLocation = claim.Core_MDF_Sub_Region_Cd__c; 
            
            // Payment Wrapper's product category
            fileWrapperObject.productCategory = claim.Request.Core_MDF_Product_Category_txt__c;
            
            // Quarter Number of grouped claims in this Payment Wrapper
            fileWrapperObject.quarterNum = claim.Core_MDF_Quarter_Year_txt__c.left(2);
            // Fiscal year of grouped claims in this Payment Wrapper 
            fileWrapperObject.fiscalYear = claim.Core_MDF_Quarter_Year_txt__c.right(4);
            // Claim's quarter year field
            fileWrapperObject.fyQuarterAndYear = claim.Core_MDF_Quarter_Year_txt__c;
            // To identify Payment Record add the attribute paymentWrapperUniqueKey in payment file wrapper
            fileWrapperObject.paymentWrapperUniqueKey = paymentUniqueKey;
           
            fileWrapperObject.isVatEligible = claim.Core_MDF_VAT_Eligibility_Ind__c ? true :false;
            fileWrapperObject.isCtypeInd = claim.Core_MDF_C_Type_Ind__c ? true : false;
            
            // Store the profit center and material code coming from productcategory metadata
            if(claim.Core_MDF_Program__c != CoGTMProgram && productCategoryMdt != NULL){
                fileWrapperObject.profitcenter = productCategoryMdt.Core_MDF_Profit_Center_Txt__c; 
                fileWrapperObject.materialCode = productCategoryMdt.Core_MDF_Material_Code_Txt__c;
            }
            if(claim.Core_MDF_Program__c == CoGTMProgram){
                fileWrapperObject.profitcenter = claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c != null ? claim.Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c : '';
                fileWrapperObject.materialCode = claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c != null ? claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c : '';
            }
            if(cmfRec !=null){
                fileWrapperObject.shipToNumber = cmfRec.Core_MDF_Ship_To_Number_Id__c;
                fileWrapperObject.soldToNumber = cmfRec.Core_MDF_Sold_To_Number_Id__c;
                fileWrapperObject.salesOrg = cmfRec.Core_MDF_Sales_Org_cd__c;
                fileWrapperObject.distributionChannel  = cmfRec.Core_MDF_Distribution_Channel_cd__c;
            }

            if(isRecoveryRow){
                fileWrapperObject.paymentWrapperUniqueKey += 'Recovery';
                fileWrapperKey += 'Recovery';
                fileWrapperObject.isRecoveryIncluded = true;
            }
            
            if(costCenter != null) {
              fileWrapperObject.costCenter = costCenter;
            }
            if(glAccount != null) {
                fileWrapperObject.glAccount = glAccount;
            }
            
            paymentFileWrapperMap.put(fileWrapperKey,fileWrapperObject);
        }

        public static Map<Id,String> getClaimToCostCenterMap() {
           return claimToCostCenterMap;

        }
        /****************************************************************************************************** 
    Method Name:        createBuSplitClaimChildRecords
    @return  :          
    @parameters:        Claim, Business Unit, Split %
    Description:        This method adds the claim's related BU split records in a list that will be inserted finally
    Added By:           Accenture - Pranav - 08/07/2021
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
        
        /*public static void createBuSplitClaimChildRecords(PartnerfundClaim ipaClaim, String businessUnit, Integer buSplitPercent){        
            // New instance for the Business Unit split record
            Core_MDF_Claim_BU_Split__c claimBuSplit = new Core_MDF_Claim_BU_Split__c();
            // the BU split record will be child of that claim
            claimBuSplit.Core_MDF_Claim__c = ipaClaim.Id;
            // update the Split %, Business Unit and BU Amount after multiplying the claim's Amount with split %
            claimBuSplit.Core_MDF_BU_Split_Percent__c = buSplitPercent;
            claimBuSplit.Core_MDF_BU_Txt__c = businessUnit;
            claimBuSplit.Core_MDF_BU_Amount_Nbr__c = ((ipaClaim.Amount*buSplitPercent)/100).setScale(2,System.RoundingMode.DOWN);
            // Add the instance in the list
            claimsBUSplitList.add(claimBuSplit);
        }*/
    }