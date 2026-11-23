public class Core_IPS_BES_Invoke_HeapSize_Batch {
    /* @InvocableMethod
public static void invokeBatch(List<Id> recordIdList) {
besUpdateClass_optimised con = new besUpdateClass_optimised(recordIdList);
database.ExecuteBatch(con,1);

} */
    @InvocableMethod
    public static void invokeBatch(List<Id> recordIdList) {
        List<Id> OutbondMessageRecordIdList = new List<Id>();
        System.debug('invocalbale called');
        if(recordIdList.size() == 0 || recordIdList == null || recordIdList.isEmpty() ){
            return ;   
        }
        List<Core_IPS_BES_Error_Log__c> errorLogList =  [SELECT Id, Core_IPS_Schedule_Time__c,Core_IPS_Outbound_Message_Id__r.Id FROM Core_IPS_BES_Error_Log__c Where Id =:recordIdList[0]]; 
        if (errorLogList[0].Core_IPS_Schedule_Time__c == null) {
            return; // No time to schedule from
        }
        OutbondMessageRecordIdList.add(errorLogList[0].Core_IPS_Outbound_Message_Id__r.Id);
        
        // Add 1 hour to the schedule time
        Datetime scheduledTime = errorLogList[0].Core_IPS_Schedule_Time__c.addHours(1);
        
        // Build the cron expression
        String cronExp = buildCronExpression(scheduledTime);
        
        // Schedule the batch
        String jobName = 'RetryBatch_' + DateTime.now().getTime();
        RetryBatchScheduleClass obj = new RetryBatchScheduleClass(OutbondMessageRecordIdList);
        System.debug('jobName'+jobName);
        System.debug('cronExp'+cronExp);
        //System.debug('jobName'+jobName);
        System.schedule( jobName,cronExp,obj);
        System.debug('schedule Callled');
    }
    
    public static String buildCronExpression(Datetime dt) {
        return String.format('{0} {1} {2} {3} {4} ? {5}', new List<String>{
            String.valueOf(dt.second()),
                String.valueOf(dt.minute()),
                String.valueOf(dt.hour()),
                String.valueOf(dt.day()),
                String.valueOf(dt.month()),
                String.valueOf(dt.year())
                });
    }
    
    
    
}