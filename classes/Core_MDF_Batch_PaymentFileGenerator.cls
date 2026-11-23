/******************************************************************************************************
* Class Name  : Core_MDF_Batch_PaymentFileGenerator  
* Version     : 1.0    
* Created Date: 01-22-2019
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - JV      01/22/2019          Batchable class to generate .xls/.tsv file and 
link generated content with payment run record.                                   
*******************************************************************************************************/

public class Core_MDF_Batch_PaymentFileGenerator implements Database.Batchable<sObject>, Database.Stateful {
    //To hold Payment Run record instance
    public Core_MDF_Payment_Run__c prunInstance;
    //To hold program name
    public String paymentRunProgram;
    //Map of unique key and payment wrapper
    public Map<String,Core_MDF_PaymentWrapper> resultantWrapperMap;

    //Exception Flag
    public boolean errorFlag = true;
    public Exception exceptionObject;
    
    
    // Constructor -  To assign pay run instance, pass the geo and pgm to constructor
    public Core_MDF_Batch_PaymentFileGenerator(Core_MDF_Payment_Run__c prunInstance){
        this.prunInstance = prunInstance;    
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
       
        // From list of pruns ==> for one prun - based on its geo and program find All claims store it 
        Core_MDF_Payment_Run__c paymentRunInstance = [SELECT Id, Name, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program_Id__r.Name, Core_MDF_Geo_Txt__c, Core_MDF_PaymentJob_Id__c, Core_MDF_ErrorDetails_Txt__c, Core_MDF_Status_Txt__c, Core_MDF_ScheduleRun_Dtm__c 
                                                      FROM Core_MDF_Payment_Run__c WHERE Id =:prunInstance.Id LIMIT 1];
        
        String prunInstanceId = paymentRunInstance.Id;
        prunInstance = paymentRunInstance;
        paymentRunProgram = paymentRunInstance.Core_MDF_Program_Id__r.Name;
        String query = 'SELECT Id, Name, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program_Id__r.Name, Core_MDF_Geo_Txt__c, Core_MDF_PaymentJob_Id__c, Core_MDF_ErrorDetails_Txt__c, Core_MDF_Status_Txt__c, Core_MDF_ScheduleRun_Dtm__c'+ 
                        ' FROM Core_MDF_Payment_Run__c WHERE Id =:prunInstanceId LIMIT 1';
        return Database.getQueryLocator(query); 
    }
    
    // process each batch of records
    public void execute(Database.BatchableContext bc, List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed) {
        Savepoint sp = Database.setSavepoint();
        try{
            //To hold payment due claims
            List<PartnerFundClaim> paymentDueClaimsToBeProcessedForPayment;
        //chekcing adjustment process is active or not on custom setting
        Core_Trigger_Executions__c adjustmentClaimOffsetCustomSetting = Core_Trigger_Executions__c.getValues(Label.Core_MDF_AdjustmentClaimOffsetProcess);
        if(adjustmentClaimOffsetCustomSetting.Core_Active__c){
            //PD claims after offset Process
      paymentDueClaimsToBeProcessedForPayment = Core_MDF_AdjustmentClaimOffsetProcess.performClaimAdjustmentProcess(paymentRunRecordsTobeProcessed);            
            }else{
            //filter payment due claims for payment process, if adjustments is inactive
            paymentDueClaimsToBeProcessedForPayment = Core_MDF_PaymentUtility.queryPaymentDueClaimsForPayment(paymentRunRecordsTobeProcessed);
            }
            system.debug('inside payment - '+paymentDueClaimsToBeProcessedForPayment);
            // This method updates the Payment Run Status before claim grouping and Payment Record Creation
            Core_MDF_PaymentProcess.updatePaymentRunStatus(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Inprogress);
           
            if(paymentDueClaimsToBeProcessedForPayment!=NULL && paymentDueClaimsToBeProcessedForPayment.size() > 0){
                // This method groups claim depending on Company, Bank and Supplier Number
                resultantWrapperMap = Core_MDF_PaymentProcess.groupClaimsforPayment(paymentDueClaimsToBeProcessedForPayment);
            
                // This method creates the Payment Records according to the grouping done
                resultantWrapperMap = Core_MDF_PaymentProcess.createPaymentRecord(prunInstance,resultantWrapperMap);
                
                // This method generates the file according to the grouping done
                Core_MDF_Payment_FileHelper.fileGenerator(resultantWrapperMap,prunInstance,paymentRunProgram);           
            }
            if(resultantWrapperMap != NULL && resultantWrapperMap.size() > 0)
            {   
                // This method updates the corresponding claim status to Pending payment

                Core_MDF_PaymentProcess.updateClaimStatus(resultantWrapperMap); 
                
                // This method shares the payment records with external users
                Core_MDF_Payment_Sharing.sharePaymentRecordsToPartner(resultantWrapperMap);
                
                // This method shares the payment records with Internal Account Manager
                //Core_MDF_Payment_Sharing.sharePaymentRecordsToInternal(resultantWrapperMap);
                
                // This method shares the payment records with Internal User
                Core_MDF_Payment_Sharing.sharePaymentRecordsToInternalUsers(resultantWrapperMap);


            }
            
        errorFlag = false;
        }catch(Exception e){

            errorFlag = true;
            exceptionObject = e;
            Database.rollback(sp);
        }  
    }   
    
    public void finish(Database.BatchableContext bc) {
 
        try{
            if(errorFlag == false){
                Core_MDF_PaymentProcess.updatePaymentRunStatus(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Completed); 
            }else{
                // This method updates the Payment record with Status and Error field in case of errors/exceptions
                Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,exceptionObject.getMessage()); 
                Core_MDF_CCP_UtilityClass.logError(exceptionObject);
            }
        }catch(Exception e){
            // This method updates the Payment record with Status and Error field in case of errors/exceptions
            Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,e.getMessage()); 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
            
    }
    
}