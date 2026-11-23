/****************************************************************************************************************************************
* Class Name        : Core_MDF_SubmitLogForRetry
* Created Date      : 03/09/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       03/09/2020         Controller class for Core_MDF_BatchRetryErrors component
*****************************************************************************************************************************************/
public class Core_MDF_SubmitLogForRetry {
    
    /***************************************************************************************************** 
    Method Name   :        submitRetry
    @return       :        void
    @parameters   :        Record Id of the Core_MDF_Batch_Apex_Error_Log__c
    Description   :        Calls the GenericRetryBatchClass to submit for retry by passing Log record
    Added By      :        Accenture - VK - 07/29/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/  
    @AuraEnabled
    public static void submitRetry(Id logRecordId){
        
        List<Core_MDF_Batch_Apex_Error_Log__c> logRecord = [SELECT Id,Core_MDF_Status_nm__c,Core_MDF_Scope_txt__c,Core_MDF_Counter_nbr__c,Core_MDF_Job_Id__c,
                                                            Core_MDF_Type_of_exception_txt__c, Core_MDF_Apex_Class_txt__c,Core_MDF_Exception_Message_txt__c,
                                                            Core_MDF_Details_txt__c
                                                      		FROM Core_MDF_Batch_Apex_Error_Log__c 
                                                      		WHERE Id =:logRecordId];
        
        Database.executeBatch(new GenericRetryBatchClass(logRecord), 1);
                
    }
}