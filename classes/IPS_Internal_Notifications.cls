public class IPS_Internal_Notifications {
    @InvocableMethod
    public static void invokeBatch(List<Id> recordIdList) {
        System.debug('invocalbale called');
        if(recordIdList.size() == 0 || recordIdList == null || recordIdList.isEmpty() ){
            return ;   
        }
        List<Case> caseList =  [SELECT Id, Core_IPS_Date_Time_Close_Pending__c FROM Case Where Id =:recordIdList[0]]; 
        if (caseList[0].Core_IPS_Date_Time_Close_Pending__c == null) {
            return; // No time to schedule from
        }
        
        // Add 10 days hour to the schedule time
        Datetime scheduledTime = caseList[0].Core_IPS_Date_Time_Close_Pending__c.adddays(10);
        
        // Build the cron expression
        String cronExp =Core_IPS_BES_Invoke_HeapSize_Batch.buildCronExpression(scheduledTime);
        
        // Schedule the batch
        String jobName = 'Internal_Notification Job' + DateTime.now().getTime();
        RetryBatchScheduleClass obj = new RetryBatchScheduleClass(recordIdList);
        
    }
    
    public static void updateEmailTextAndSendEmail(List<Id> caseId){
        List<Case> caseList = [Select Id,Core_IPS_email_text__c from Case where ID =:caseId[0] LIMIT 1];
        System.debug('caseList'+caseList);
        if(caseList.size()>0){
            Case caseToUpdate = caseList[0];
            caseToUpdate.Core_IPS_email_text__c='IPS has Close-Pending Reminder on Case';
            Update  caseToUpdate; 
			      

        }
    }
}