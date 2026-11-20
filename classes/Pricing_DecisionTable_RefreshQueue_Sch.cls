public class Pricing_DecisionTable_RefreshQueue_Sch  implements Schedulable{
    private List<String> tableNames;
    private Integer startIndex;
    
    public Pricing_DecisionTable_RefreshQueue_Sch(List<String> tableNames, Integer startIndex) {
        this.tableNames = tableNames;
        this.startIndex = startIndex;
    }
    
    public void execute(SchedulableContext sc) {
        // Abort this specific scheduled job instance so it doesn't clutter scheduled jobs
        System.abortJob(sc.getTriggerId());
        
        // Fire your Queueable batch to process the remaining tables
        if (!Test.isRunningTest()) {
            System.enqueueJob(new Pricing_DecisionTableRefresh_Queue(tableNames, startIndex));
        }
    }
    
    // Helper method to dynamically schedule the retry 1 hour from now
    public static void scheduleRetry(List<String> tableNames, Integer startIndex) {
        Datetime retryTime = System.now().addMinutes(60);
        String cronExpression = '' + retryTime.second() + ' ' + 
            retryTime.minute() + ' ' + 
            retryTime.hour() + ' ' + 
            retryTime.day() + ' ' + 
            retryTime.month() + ' ? ' + 
            retryTime.year();
        
        // Unique job name to prevent collision
        String jobName = 'Decision Table Retry - ' + System.currentTimeMillis();
        System.schedule(jobName, cronExpression, new Pricing_DecisionTable_RefreshQueue_Sch(tableNames, startIndex));
    }
}