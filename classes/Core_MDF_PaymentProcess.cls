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
        system.debug('claimsTobeProcessed--'+paymentDueClaimsTobeProcessed);

        // Map of Payment Wrapper 
        Map<String,Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String,Core_MDF_PaymentWrapper>();
        Decimal tempDecimal = 0;
        for(PartnerFundClaim claim : paymentDueClaimsTobeProcessed) 
        {
            //uniqueKey = company+bank+suppliernumber;  
            String uniqueKey = claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+claim.Core_MDF_Bank__c+'_'+claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c;
            
            if(paymentWrapperMap.containsKey(uniqueKey)){
                tempDecimal = claim.Amount;
                paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount += tempDecimal.setScale(2,System.RoundingMode.HALF_UP);
                paymentWrapperMap.get(uniqueKey).claimsToBeProcessed.add(claim);
            }
            else{
                System.debug('uniqueKey ::::'+uniqueKey);
                Core_MDF_PaymentWrapper wrapperObject = new Core_MDF_PaymentWrapper();
                wrapperObject.claimsToBeProcessed.add(claim);
                tempDecimal = claim.Amount;
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
        String paymentRecTypeDevName ;
        
        // To fetch the map to store the Payment record Types
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfPaymentRecTypeMetadata = Core_MDF_PaymentUtility.fetchMetaDataRecord();
        
        // Describe call to fetch all the Payment Record Types
        Map<String,Schema.RecordTypeInfo> paymentRecordTypeMap = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName(); 
        
        if(pRunInstance.Core_MDF_Program_Id__c!=null && mapOfPaymentRecTypeMetadata !=null && mapOfPaymentRecTypeMetadata.containsKey(pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c)){
            paymentRecTypeDevName = mapOfPaymentRecTypeMetadata.get(pRunInstance.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c).Core_MDF_Payment_RecordType_txt__c;
        }
        
        if(paymentWrapperMap != NULL && paymentWrapperMap.size() > 0)
        {
            for (String uniqueKey : paymentWrapperMap.keyset())
            {
                //New payment instance
                Core_MDF_Payment__c payment = new Core_MDF_Payment__c();
                payment.Core_MDF_Payment_Run_Id__c = pRunInstance.Id;
                if(paymentRecordTypeMap.containsKey(paymentRecTypeDevName)){
                    payment.RecordTypeId =  paymentRecordTypeMap.get(paymentRecTypeDevName).getRecordTypeId();
                }
                payment.Core_MDF_Paid_Amt__c = paymentWrapperMap.get(uniqueKey).sumOfClaimsAmount;
                paymentRecordsToBeProcessedMap.put(uniqueKey,payment);
            }

            //insert payment records
            if(paymentRecordsToBeProcessedMap!=NULL && paymentRecordsToBeProcessedMap.size() > 0){
                Database.insert(paymentRecordsToBeProcessedMap.values());

                Map<Id,Core_MDF_Payment__c> paymentMap = new Map<Id,Core_MDF_Payment__c>([Select Core_MDF_Payment_Run_Id__c, Core_MDF_Paid_Amt__c, Core_MDF_Payment_No_Txt__c, Id 
                                                        From Core_MDF_Payment__c where ID IN :paymentRecordsToBeProcessedMap.values()]);
                

                if(paymentMap != NULL && paymentMap.size() > 0){
                    for (String uniqueKey : paymentRecordsToBeProcessedMap.keyset())
                    {
                        for(Core_MDF_Payment__c payment : paymentMap.values()){
                            if(payment.Id == paymentRecordsToBeProcessedMap.get(uniqueKey).Id){
                                paymentRecordsMap.put(uniqueKey, payment);
                            }
                        }
                    
                    }
                }
                
                for(String uniqueKey : paymentRecordsMap.keyset()){
                    paymentWrapperMap.get(uniqueKey).paymentForClaims = paymentRecordsMap.get(uniqueKey);
                }
            }
            return paymentWrapperMap;
        }else{return null;}
        
    }
    
    
    /****************************************************************************************************** 
    Method Name:        updatePaymentRunStatus 
    @return  :          void
    @parameters:        payment run instance and status
    Description:        This method is used to update payment run status
    Added By:           Accenture - AD - 01/28/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void updatePaymentRunStatus(List<Core_MDF_Payment_Run__c> prunList,string status){
       
       List<Core_MDF_Payment_Run__c> pRunListToBeUpdated = new List<Core_MDF_Payment_Run__c>();
       for(Core_MDF_Payment_Run__c prunInstance : prunList)
        {
            //created new payment run instance
            Core_MDF_Payment_Run__c pRun = new Core_MDF_Payment_Run__c(Id=prunInstance.Id);      
            pRun.Core_MDF_Status_Txt__c = status;
            pRunListToBeUpdated.add(pRun);
        }
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
    Method Name:        updateClaimStatus
    @return  :          void
    @parameters:        Map of unique key and payment wrapper
    Description:        This method is used to update claim status to Pending Payment
    Added By:           Accenture - AD - 01/28/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void updateClaimStatus(Map<String,Core_MDF_PaymentWrapper> resultantWrapperMap){
        //List of claims to be updated
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        for(Core_MDF_PaymentWrapper wrapperObject : resultantWrapperMap.values())
        {
            for(PartnerFundClaim claim : wrapperObject.claimsToBeProcessed){
                claim.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Payment;
                claim.Core_MDF_Payment_Id__c = wrapperObject.paymentForClaims.Id;
               // claim.LastModifiedById = Label.Core_MDF_Dummy_Account_Owner_Id;
                claimsToBeUpdated.add(claim);
            }
        }
        //Update claims
        if(claimsToBeUpdated!=NULL && claimsToBeUpdated.size() > 0){
            Database.update(claimsToBeUpdated);
        }
    }
}