/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentProcess 
* Version     : 1.0   
* Created Date: 30-01-2019 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Amal Thomas     8/21/2018                    Class contains all the methods supporting the CCP Payment process
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PaymentProcess {
    
    
    /****************************************************************************************************** 
    Method Name:        groupClaimsforPayment
    @return  :          Map of unique key and payment wrapper
    @parameters:        List of claims
    Description:        This method is used to filter/group claims based on geo and program
    Added By:           Accenture - JV - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static Map<String,Core_MDF_PaymentWrapper> groupClaimsforPayment(List<PartnerFundClaim> paymentDueClaimsTobeProcessed){
        
        
        // Map of Payment Wrapper 
        Map<String,Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String,Core_MDF_PaymentWrapper>();
        Decimal tempDecimal = 0;
        
        for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed) 
        {
            //Unique key for group claims for payment
            String uniqueKey;
            List<String> mdfBudgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_BANK_HIDE').Core_MDF_Value__c.split(',');
            List<String> ccfdcfprograms = Core_MDF_Configuration__c.getValues('Programs_For_MDF_PaymentRun').Core_MDF_Value__c.split(',');
            
            //If budget type is RSA MD , then uniqueKey would be company
            if(claim.Core_MDF_Budget_Type_Options_Nm__c != null && claim.Core_MDF_Budget_Type_Options_Nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type){
                uniqueKey = claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
              }
           //Unique Key for MDF Budget types of CCF & DCF programs
            else if(((mdfBudgetTypes.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)) && ccfdcfprograms.contains(claim.Core_MDF_Program__c)) || (claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Co_GTM') && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCreditMemo)){
                uniqueKey = claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_'+claim.Core_MDF_Type_Txt__c;   
            }
            else if(claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Co_GTM') && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCash){
                uniqueKey = claim.Core_MDF_Budget_Type_Options_Nm__c != null ? claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c
                                                                         : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c;  
            }
            // Unique key for CCP Programs except for MDF budget types
            else if(!(mdfBudgetTypes.contains(claim.Core_MDF_Budget_Type_Options_Nm__c))){
            //else{
                //uniqueKey = company+bank+suppliernumber+BudgetType; - Added Budget type as part of CMP Payment US-US1017409
                uniqueKey = claim.Core_MDF_Budget_Type_Options_Nm__c!= null ? claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c
                                                                          : claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c;
            }
            
            if(paymentWrapperMap.containsKey(uniqueKey)){
                tempDecimal = claim.Amount;
                paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount += tempDecimal.setScale(2,System.RoundingMode.HALF_UP);
                paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.add(claim);
            }
            else{

                Core_MDF_PaymentWrapper wrapperObject = new Core_MDF_PaymentWrapper();
                wrapperObject.claimsToBeProcessed.add(claim);
                tempDecimal = claim.Amount;
                wrapperObject.budgetType=claim.Core_MDF_Budget_Type_Options_Nm__c; //Added Budget Type as part of US-US1017409
                wrapperObject.sumOfClaimsAmount = tempDecimal.setScale(2,System.RoundingMode.HALF_UP);
                paymentWrapperMap.put(uniqueKey,wrapperObject);
            }
        }
        
        return paymentWrapperMap;
    }
    
     
    /****************************************************************************************************** 
    Method Name:        createPaymentRecord
    @return  :          Map of unique key and payment wrapper
    @parameters:        payment run instance and map of payment wrapper
    Description:        This method is used to create payment records
    Added By:           Accenture - AD - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/    
    public static Map<String, Core_MDF_PaymentWrapper> createPaymentRecord(Core_MDF_Payment_Run__c pRunInstance,Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        //Map of unique key and payment record
        Map<String,Core_MDF_Payment__c> paymentRecordsToBeProcessedMap = new Map<String,Core_MDF_Payment__c>();
        Map<String,Core_MDF_Payment__c> paymentRecordsMap = new Map<String,Core_MDF_Payment__c>();
        String coGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
      
        

        // Describe call to fetch all the Payment Record Types
        Map<String,Schema.RecordTypeInfo> paymentRecordTypeMap = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName(); 
        
        //This method fetch payment record type and assign
        String paymentRecTypeDevName = fetchPaymentRecordType(pRunInstance);
        //ATHR - Deeply Nested if 16209
        if(paymentWrapperMap == null || paymentWrapperMap.isEmpty()){
            return paymentWrapperMap;
        }
        //if(paymentWrapperMap != NULL && paymentWrapperMap.size() > 0)
        //{
            for (String uniqueKey : paymentWrapperMap.keyset())
            {
                //New payment instance
                Core_MDF_Payment__c payment = new Core_MDF_Payment__c();
                payment.Core_MDF_Payment_Run_Id__c = pRunInstance.Id;
                if(paymentRecordTypeMap!=null && paymentRecordTypeMap.containsKey(paymentRecTypeDevName)){
                    payment.RecordTypeId =  paymentRecordTypeMap.get(paymentRecTypeDevName).getRecordTypeId();
                }
                payment.Core_MDF_Paid_Amt__c = paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount;
                //Actual payment amount
                if(pRunInstance.Core_MDF_Program_Id__r.Name != coGTMProgram){
                    payment.Core_MDF_RMF_Actual_Payment_Amt__c = paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount;
                }
                //ATHR - Deeply Nested if 16209
                if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed == NULL || paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.isEmpty()) {
                    paymentRecordsToBeProcessedMap.put(uniqueKey, payment);
                    continue;
                }
                //if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed != NULL && paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.size() > 0){
                    // Account Company
                    payment.Core_MDF_Account_Id__c = paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                    //Populating Budget type field on Payment record as part of US-US1017409
                    if(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Budget_Type_Options_Nm__c!=null){
                        //payment.Core_MDF_Budget_Type_Nm__c =paymentWrapperMap.get(uniqueKey).claimsToBeProcessed[0].Core_MDF_Budget_Type_Options_Nm__c;
                   		payment.Core_MDF_Budget_Type_Nm__c = Core_MDF_PaymentUtility.fetchDistinctBudgetTypes(paymentWrapperMap.get(uniqueKey).claimsToBeProcessed);
                    }
                //}    
                paymentRecordsToBeProcessedMap.put(uniqueKey,payment);
            }
           
            //insert payment records
            //ATHR - Deeply Nested if 16209
            if(paymentRecordsToBeProcessedMap==NULL || paymentRecordsToBeProcessedMap.isEmpty()) return paymentWrapperMap;
            //if(paymentRecordsToBeProcessedMap!=NULL && paymentRecordsToBeProcessedMap.size() > 0){
                Database.insert(paymentRecordsToBeProcessedMap.values());

                Map<Id,Core_MDF_Payment__c> paymentMap = new Map<Id,Core_MDF_Payment__c>([Select Core_MDF_Payment_Run_Id__c, Core_MDF_Paid_Amt__c, Name, Core_MDF_Payment_No_Txt__c,Id 
                                                        From Core_MDF_Payment__c where ID IN :paymentRecordsToBeProcessedMap.values()]);
                //ATHR - Deeply Nested if 16209
                if(paymentMap == NULL && paymentMap.isEmpty()) return paymentWrapperMap;
                //if(paymentMap != NULL && paymentMap.size() > 0){
                    for(String uniqueKey : paymentWrapperMap.keyset()){
                        paymentWrapperMap.get(uniqueKey).paymentForClaims = paymentMap.get(paymentRecordsToBeProcessedMap.get(uniqueKey).Id);
                    }
                //}
            //}
        //}
        return paymentWrapperMap;
    }
    
    
    /****************************************************************************************************** 
    Method Name:        updatePaymentRunStatus 
    @return  :          void
    @parameters:        payment run instance and status
    Description:        This method is used to update payment run status
    Added By:           Accenture - AD - 01/28/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void updatePaymentRunRecord(List<Core_MDF_Payment_Run__c> prunList,string status){
       
       List<Core_MDF_Payment_Run__c> pRunListToBeUpdated = new List<Core_MDF_Payment_Run__c>();
       for(Core_MDF_Payment_Run__c prunInstance : prunList)
        {
            //created new payment run instance
            Core_MDF_Payment_Run__c pRun = new Core_MDF_Payment_Run__c(Id=prunInstance.Id);      
            pRun.Core_MDF_Status_Txt__c = status;
            pRunListToBeUpdated.add(pRun);
        }
        // To populate File Names in Payment Run field
        pRunListToBeUpdated = updateFilesNameFieldOnPrun(pRunListToBeUpdated);
        if(pRunListToBeUpdated!=NULL && pRunListToBeUpdated.size() > 0){
            Database.update(pRunListToBeUpdated);
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        updatePaymentRunStatusAndErrorDetails
    @return  :          void
    @parameters:        payment run instance and status
    Description:        This method is used to update payment run status
    Added By:           Accenture - AD - 01/28/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void updatePaymentRunStatusAndErrorDetails(List<Core_MDF_Payment_Run__c> prunList,String status,String exceptionMessage){
        
        List<Core_MDF_Payment_Run__c> pRunListToBeUpdated = new List<Core_MDF_Payment_Run__c>();
        for(Core_MDF_Payment_Run__c prunInstance : prunList)
        {
            //created new payment run instance
            Core_MDF_Payment_Run__c pRun = new Core_MDF_Payment_Run__c(Id=prunInstance.Id);      
            pRun.Core_MDF_Status_Txt__c = status;
            pRun.Core_MDF_ErrorDetails_Txt__c = exceptionMessage;
            pRunListToBeUpdated.add(pRun);
        }
        if(pRunListToBeUpdated!=NULL && pRunListToBeUpdated.size() > 0){
            Database.update(pRunListToBeUpdated);
        }
    }
   
    /****************************************************************************************************** 
    Method Name:        fetchPaymentRecordType
    @return  :          payment record type
    @parameters:        payment run instance
    Description:        This method is used to assign payment record type
    Added By:           Accenture - AD - 05/12/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static String fetchPaymentRecordType(Core_MDF_Payment_Run__c pRunInstance){
        //To hold payment record type
        String payRecTypeDevName;
        // fetch and store budget type and its corresponding record type
        Map<String,String> mapOfBudgetTypeAndRecType = Core_MDF_PaymentUtility.fetchBudgetTypeAndRecTypeMetaData();
        //If selected program is Retail type and CCF MDF & DCF MDF
        if(pRunInstance.Core_MDF_Budget_Type_nm__c!=null && pRunInstance.Core_MDF_Budget_Type_nm__c.split(';').size() > 0){
            List<String> budgetTypeSplit = pRunInstance.Core_MDF_Budget_Type_nm__c.split(';');
            String programBudgetType = pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c+budgetTypeSplit[0];
            if(mapOfBudgetTypeAndRecType !=null && mapOfBudgetTypeAndRecType.size()>0 && mapOfBudgetTypeAndRecType.containsKey(programBudgetType)){
                //to hold retail record type based on budget type
                payRecTypeDevName = mapOfBudgetTypeAndRecType.get(pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c+budgetTypeSplit[0]);
            }
        }else{
            //If selected program is CCP
            if(mapOfBudgetTypeAndRecType !=null && mapOfBudgetTypeAndRecType.size()>0 && mapOfBudgetTypeAndRecType.containsKey(pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c)){  
                //to hold CCP record type
                payRecTypeDevName= mapOfBudgetTypeAndRecType.get(pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c);
            }
        }
        return payRecTypeDevName;
    }
    
    /****************************************************************************************************** 
    Method Name:        updateFilesNameFieldOnPrun
    @return  :          List of Payment run records
    @parameters:        List of Payment run records
    Description:        This method is used to populate files name field on payment run
    Added By:           Accenture - Pranav - 30/11/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public static List<Core_MDF_Payment_Run__c> updateFilesNameFieldOnPrun(List<Core_MDF_Payment_Run__c> pRunList){
        
        // List to store Payment run Ids 
        List<Id> paymentRunIdsList = new List<Id>();
        
        // Get List of payment run Ids from incoming list 
        for(Core_MDF_Payment_Run__c pRun : pRunList){
            if(pRun.Core_MDF_Status_Txt__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PayRunStatus_Completed')){
                paymentRunIdsList.add(pRun.Id);
            }
        }        
        //ATHR - Deeply Nested if 16209
        if(paymentRunIdsList == null || paymentRunIdsList.isEmpty()) return pRunList;
        //if(paymentRunIdsList != NULL && paymentRunIdsList.size()>0){
            
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();            
            Map<Id, String> pRunToNamesOfFilesMap = new Map<Id, String>();
            
            // Query Content Document Link for the Payment Run record
            cdlList = [Select Id, contentDocument.Title, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : paymentRunIdsList order By contentDocument.Id];
            
            // Get inside this condition only when there are files attached
            //ATHR - Deeply Nested if 16209
            if(cdlList == NULL || cdlList.isEmpty()) return pRunList;
            //if(cdlList != NULL && cdlList.size()>0){
                // Create a Map of Payment Run Id and Corresponding Payment files titles 
                for(ContentDocumentLink cdLink : cdlList){                    
                    if(pRunToNamesOfFilesMap.containsKey(cdLink.LinkedEntityId)){
                        // Concatenate String with line breaks between file names
                        String nameOfFiles = pRunToNamesOfFilesMap.get(cdLink.LinkedEntityId) + '\n'+ 
                                             String.valueOf(cdLink.contentDocument.Title);
                        pRunToNamesOfFilesMap.put(cdLink.LinkedEntityId, nameOfFiles);
                    }
                    else{
                        pRunToNamesOfFilesMap.put(cdLink.LinkedEntityId,String.valueOf(cdLink.contentDocument.Title));
                    }
                }
                // Updating file Name field 
                for(Core_MDF_Payment_Run__c payRun : pRunList){
                    if(pRunToNamesOfFilesMap.containsKey(payRun.Id)){
                        // Assign payment run record field Core_MDF_Files_Name_Txt__c
                        payRun.Core_MDF_Files_Name_Txt__c = pRunToNamesOfFilesMap.get(payRun.Id);  
                    }
                }
            //}
        //}
        return pRunList;
    }


}