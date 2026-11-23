/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentProcessRetailMdfIPA 
* Version     : 1.0   
* Created Date: 28-09-2020 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Amal Thomas     28/09/2020                    Class contains all the methods supporting the Retail MDF Payment process
*****************************************************************************************************************************************/

public without sharing class Core_MDF_PaymentProcessRetailMdfIPA_POC {
    
    // Map of unique key and payment wrapper for creating payment record
    public static Map<String,Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String,Core_MDF_PaymentWrapper>();
  
    // Map of key and RMF Payment file Wrapper for generating payment file
    public static Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
    
    public static Map<Id, String> claimIdToUniquekeyForExchangeRate = new Map<Id, String>();
    public static Map<string,Decimal> uniqueKeyToExchangeRate = new Map<string,Decimal>();
    public static Map<String, Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> mapOfConvertedCurrencies = new Map<String, Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();

    /************************************************************************************************************* 
    Method Name:        groupClaimsforPaymentFileRetailMDFIPA
    @return  :          Map of Unique Key and Payment file Wrapper
    @parameters:        List of Payment Due claims
    Description:        This method is used to group claims for Payment File using unique key 
    Added By:           Accenture - Pranav - 28/09/2020
    Modified By:        Date:       Changes: 
    *************************************************************************************************************/ 
  
    public static Map<String,Core_MDF_PaymentFileWrapper> groupClaimsforPaymentFileRetailMDFIPA(List<PartnerFundClaim> paymentDueClaimsTobeProcessed, Core_MDF_Payment_Run__c pRun){
        
        // For Retail MDF Budget type, Convert Claim's Amount into Bank's Local Currency
        if(pRun.Core_MDF_Budget_Type_Txt__c == Label.Core_MDF_RetailMDF_BudgetType){
            getCovertedAmountOfClaims(paymentDueClaimsTobeProcessed);
        }
        
        for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed) 
        {
            //Unique key for group claims for Retail MDF payment File generation
            String fileWrapperKey;           
            // Create Unique key for payment file
            fileWrapperKey = createFileWrapperKey(claim) ;
            // Assigning Converted Amount fields,Vat Fields on Claim
            if(pRun.Core_MDF_Budget_Type_Txt__c == Label.Core_MDF_RetailMDF_BudgetType){
                updatePaymentConversionFieldOnClaim(claim);
            }
            // Create Wrapper for Payment file 
            createPaymentFileWrapper(claim, fileWrapperKey);            
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
            
            if(paymentWrapperMap.containsKey(paymentWrapperKey)){
                // sum of all claim amount for the key
                paymentWrapperMap.get(paymentWrapperKey).sumOfClaimsAmount += fileWrapper.sumOfClaimsAmount;
                // Add Claims records in payment Wrapper
                paymentWrapperMap.get(paymentWrapperKey).claimsToBeProcessed.addAll(fileWrapper.claimsToBeProcessed);
                if(prunInstance.Core_MDF_Budget_Type_Txt__c == Label.Core_MDF_RetailMDF_BudgetType){
                    // Get Converted Amount Sum in the Wrapper
                    paymentWrapperMap.get(paymentWrapperKey).sumOfConvertedAmount += fileWrapper.sumOfConvertedAmount;            
                }
            }
            else{
                Core_MDF_PaymentWrapper wrapperObject = new Core_MDF_PaymentWrapper();
                wrapperObject.claimsToBeProcessed.addAll(fileWrapper.claimsToBeProcessed);
                wrapperObject.sumOfClaimsAmount = fileWrapper.sumOfClaimsAmount;
                if(prunInstance.Core_MDF_Budget_Type_Txt__c == Label.Core_MDF_RetailMDF_BudgetType){
                    wrapperObject.sumOfConvertedAmount = fileWrapper.sumOfConvertedAmount;
                }
                wrapperObject.currencyExchangeRate = fileWrapper.currencyExchangeRate;        
                paymentWrapperMap.put(paymentWrapperKey, wrapperObject);
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
    public static Map<String, Core_MDF_PaymentWrapper> createPaymentRecordRetailMDF(Core_MDF_Payment_Run__c pRunInstance,Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
  
        //Map of unique key and payment record
        Map<String,Core_MDF_Payment__c> paymentRecordsToBeProcessedMap = new Map<String,Core_MDF_Payment__c>();
        // Describe call to fetch all the Payment Record Types
        Map<String,Schema.RecordTypeInfo> paymentRecordTypeMap = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName(); 
        
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
                    if(pRunInstance.Core_MDF_Budget_Type_Txt__c == Label.Core_MDF_RetailMDF_BudgetType){
                        // get Converted Amount in payment Wrapper and Payment record
                        payment.Core_MDF_Converted_Amt_Nbr__c = paymentWrapperMap.get(uniqueKey).sumOfConvertedAmount;                
                        // get Currency Conversion rate
                        payment.Core_MDF_Conversion_Rate_Nbr__c = paymentWrapperMap.get(uniqueKey).currencyExchangeRate;
                    }
                    // Paid Amount
                    payment.Core_MDF_Paid_Amt__c = paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount;
                    // Actual payment amount
                    payment.Core_MDF_RMF_Actual_Payment_Amt__c = paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount;                
                    if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed != NULL && paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.size() > 0){
                        // Account Company 
                        payment.Core_MDF_Account_Id__c = paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                        // Currency Code of the bank
                        payment.Core_MDF_Currency_Cd_txt__c = paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;                
                    }
                    paymentRecordsToBeProcessedMap.put(uniqueKey,payment);
                }            
                if(paymentRecordsToBeProcessedMap!=NULL && paymentRecordsToBeProcessedMap.size() > 0){
                    //insert payment records
                    Database.insert(paymentRecordsToBeProcessedMap.values());
                    
                    // Query the inserted Payment Records
                    Map<Id,Core_MDF_Payment__c> paymentMap = new Map<Id,Core_MDF_Payment__c>([Select Core_MDF_Payment_Run_Id__c, Core_MDF_Paid_Amt__c, Name, Core_MDF_Payment_No_Txt__c,Id 
                                                                                              From Core_MDF_Payment__c where ID IN :paymentRecordsToBeProcessedMap.values()]);
                    
                    // add Payment record in each payment file wrapper and payment Wrapper attribute paymentForClaims
                    for(Core_MDF_PaymentFileWrapper paymentFileWrapper : paymentFileWrapperMap.values())
                    {
                        
                        paymentFileWrapper.paymentForClaims = paymentMap.get(paymentRecordsToBeProcessedMap.get(paymentFileWrapper.paymentWrapperUniqueKey).Id);
                        paymentWrapperMap.get(paymentFileWrapper.paymentWrapperUniqueKey).paymentForClaims = paymentMap.get(paymentRecordsToBeProcessedMap.get(paymentFileWrapper.paymentWrapperUniqueKey).Id);
                        
                    }
                }
            }
        System.debug('Payment Wrapper Map Values' +paymentWrapperMap);
        return paymentWrapperMap;
    }
    
    /************************************************************************************************************* 
    Method Name:        createFileWrapperKey
    @return  :          Unique key for Payment File lines
    @parameters:        Claim
    Description:        This method creates a key from claim fields ; The key will be used for generating Payment File
    Added By:           Accenture - Pranav - 16/10/2020
    Modified By:        Date:       Changes: 
    *************************************************************************************************************/ 

    public static String createFileWrapperKey(PartnerFundClaim claim)
    {
        String fileWrapperKey='';
        // Key for Payment File - RMF Claims & IPA Claims
        //In case of non vat claims, for IPA Program we have included Budget Type field to existing grouping logic
        fileWrapperKey = claim.Core_MDF_VAT_Eligibility_Ind__c?
                         String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                         (claim.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name) ?
                         claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_' + claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Request.Core_MDF_Product_Category_txt__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c :
                         claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_' + claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Request.Core_MDF_Product_Category_txt__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c+'_' +claim.Core_MDF_Budget_Type_Options_Nm__c;
        
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

    public static void createPaymentFileWrapper(PartnerFundClaim claim, String fileWrapperKey)
    {
        Decimal tempDecimal = 0;  
        Decimal conversionRate = 0;
        // Unique Key for Payment record of RMF & IPA Claims
        //For VAT eligible Claims of RMF & IPA Programs, individual claim id
        //Added an extra check if program is RMF for Non Vat eligible claims.For IPA Non vat claims,included Budget Type field in exsiting grouping logic.
         String paymentUniqueKey= claim.Core_MDF_VAT_Eligibility_Ind__c ? 
                               String.valueOf(claim.Id)+'_'+claim.Core_MDF_C_Type_Ind__c:
                               (claim.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name) ?
                                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c:
                                claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_txt__c+'_'+claim.Core_MDF_C_Type_Ind__c;
       
 
        if(paymentFileWrapperMap.containsKey(fileWrapperKey)){ tempDecimal = claim.Amount;            
            // Sum of All claims Amount in file Wrapper
            paymentFileWrapperMap.get(fileWrapperKey).sumOfClaimsAmount += tempDecimal.setScale(2,System.RoundingMode.HALF_UP);

            paymentFileWrapperMap.get(fileWrapperKey).sumOfConvertedAmount += claim.Core_MDF_Payment_lcl_Amount__c ;
            // Add the claims in Wrapper
            paymentFileWrapperMap.get(fileWrapperKey).claimsToBeProcessed.add(claim);
        }
        else{
            Core_MDF_PaymentFileWrapper fileWrapperObject = new Core_MDF_PaymentFileWrapper();
            fileWrapperObject.claimsToBeProcessed.add(claim);
            tempDecimal = claim.Amount;
            fileWrapperObject.sumOfClaimsAmount = tempDecimal.setScale(2,System.RoundingMode.HALF_UP);            
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
            fileWrapperObject.isVatEligible = claim.Core_MDF_VAT_Eligibility_Ind__c ? 
                                true :false;
            fileWrapperObject.totalVatAmt = (claim.Core_MDF_VAT_Eligibility_Ind__c) ? 
                              claim.Core_MDF_VAT_Amt__c : 0;
            System.debug('conversionRate'+conversionRate);
            fileWrapperObject.sumOfConvertedAmount = claim.Core_MDF_Payment_lcl_Amount__c;
            fileWrapperObject.currencyExchangeRate = claim.Core_MDF_Payment_Exchange_Rate_Nbr__c;
            fileWrapperObject.totalConvertedVatAmt = (claim.Core_MDF_Vat_Eligibility_Ind__c) ?claim.Core_MDF_Vat_Payment_lcl_Amount__c : NULL;
            fileWrapperObject.isCtypeInd = claim.Core_MDF_C_Type_Ind__c ? 
                                           true : false;
            paymentFileWrapperMap.put(fileWrapperKey,fileWrapperObject);
        }    
    }
    
    /* Updating Payment Currency and Payment Amount on Claim By Converting Claim's Amount into Bank's Local Currency */
    public static List<PartnerFundClaim> getCovertedAmountOfClaims(List<PartnerFundClaim> paymentDueClaimsTobeProcessed){
        
        list<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listofPayments = new list<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed) 
        {
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            input.inputAmount = claim.Amount;
            input.inputCurrency = 'USD';
            input.outputCurrency = claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;
            input.inputDate =  date.newinstance(claim.createdDate.year(), claim.createdDate.month(), claim.createdDate.day());
            listofPayments.add(input);
            if(claim.Core_MDF_VAT_Eligibility_Ind__c){
                Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount vatinput = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                vatinput.inputAmount = claim.Core_MDF_VAT_Amt__c;
                vatinput.inputCurrency = 'USD';
                vatinput.outputCurrency = claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;
                vatinput.inputDate =  date.newinstance(claim.createdDate.year(), claim.createdDate.month(), claim.createdDate.day());
                listofPayments.add(vatinput);
            }
        }
        if(listofPayments!= NULL && listofPayments.size() > 0)
        {
            // Converting payment amount stored in USD into its local currency and storing it in map
            mapOfConvertedCurrencies = Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency(listofPayments);          
        }
        return paymentDueClaimsTobeProcessed;
    }
    
    /* Updating Payment Currency Fields on Claim */
    public static void updatePaymentConversionFieldOnClaim(PartnerFundClaim claim){
        
        String currConvKey = String.valueOf(claim.Amount) +  '\t' + 'USD' +  '\t' + String.valueOf(date.newinstance(claim.createdDate.year(), claim.createdDate.month(), claim.createdDate.day())) + '\t' +
            String.valueOf(claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c);
        String currConvKeyForVat = String.valueOf(claim.Core_MDF_VAT_Amt__c) +  '\t' + 'USD' +  '\t' + String.valueOf(date.newinstance(claim.createdDate.year(), claim.createdDate.month(), claim.createdDate.day())) + '\t' +
            String.valueOf(claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c);
        if(mapOfConvertedCurrencies!= NULL && mapOfConvertedCurrencies.containsKey(currConvKey))
        {
            // Get Exchange rate from the Map
            Decimal convRate = mapOfConvertedCurrencies.get(currConvKey).conversionRate ;
            // Update Exchange Record in Payment Wrapper record
            claim.Core_MDF_Payment_Exchange_Rate_Nbr__c = convRate;
            // Get local Currency
            claim.Core_MDF_Payment_Currency_Txt__c = mapOfConvertedCurrencies.get(currConvKey).outputCurrency;
            // Get Amount after conversion into local Currency
            Decimal convertedAmountinlocalCurr = mapOfConvertedCurrencies.get(currConvKey).convertedAmount;
            // Updating sumOfConvertedAmount attribute for each payment wrapper 
            claim.Core_MDF_Payment_lcl_Amount__c = convertedAmountinlocalCurr;
            if(claim.Core_MDF_VAT_Eligibility_Ind__c && mapOfConvertedCurrencies.containsKey(currConvKeyForVat)){
                claim.Core_MDF_Vat_Payment_lcl_Amount__c = (claim.Core_MDF_VAT_Amt__c * convRate).setScale(2,System.RoundingMode.HALF_UP);
            }
        }
    }
    
    /*public static void getConvertedAmtForClaim(List<PartnerFundClaim> paymentDueClaimsTobeProcessed){
        
        for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed){
            String uniqueKey = '';
            uniqueKey = claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c + Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(claim.CreatedDate);
            claimIdToUniquekeyForExchangeRate.put(claim.Id,uniqueKey);
        }
        System.debug('@@claimIdToUniquekeyForExchangeRate'+claimIdToUniquekeyForExchangeRate);
        if(claimIdToUniquekeyForExchangeRate.values().size()>0){
            List<Core_MDF_Currency_Exchange_Rates__c> exchangeRates = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c 
                                                                           FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                           where Core_MDF_Unique_Key__c in :claimIdToUniquekeyForExchangeRate.values()];
           
            System.debug('@@exchangeRates'+exchangeRates);
            //Create a map with the Excahnge rates
            for(Core_MDF_Currency_Exchange_Rates__c exchangeRecord:exchangeRates){
                uniqueKeyToExchangeRate.put(exchangeRecord.Core_MDF_Unique_Key__c,exchangeRecord.Core_MDF_Exchange_Rate__c);                      
            }
            System.debug('@@uniqueKeyToExchangeRate'+uniqueKeyToExchangeRate);
        }
    }
    
    public static void updatePaymentFieldsOnClaim(PartnerFundClaim claim){
        Decimal tempDecimal = 0;       
        Decimal conversionRate = 0;
        if(claimIdToUniquekeyForExchangeRate != NULL && claimIdToUniquekeyForExchangeRate.size()>0 && claimIdToUniquekeyForExchangeRate.containsKey(claim.Id)){
            String uniqueKey = claimIdToUniquekeyForExchangeRate.get(claim.Id);
            if(uniqueKeyToExchangeRate != NULL && uniqueKeyToExchangeRate.size()>0 && uniqueKeyToExchangeRate.containsKey(uniqueKey)){
                conversionRate = 1/(uniqueKeyToExchangeRate.get(claimIdToUniquekeyForExchangeRate.get(claim.Id)));
            }
        }
        tempDecimal = claim.Amount;
        if(tempDecimal != 0 && conversionRate != 0){
            claim.Core_MDF_Payment_Amount__c = (tempDecimal*conversionRate).setScale(2,System.RoundingMode.HALF_UP);
            claim.Core_MDF_Payment_Conversion_Rate_Nbr__c = conversionRate;
            if(claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_VAT_Amt__c != 0){
                claim.Core_MDF_Vat_Payment_Amount__c = (claim.Core_MDF_VAT_Amt__c*conversionRate).setScale(2,System.RoundingMode.HALF_UP);
            }
            claim.Core_MDF_Payment_Currency_Txt__c = claim.Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c;
        }
    }*/
}