public class Core_MDF_IUPGMBatchHelper {
    public static void generateBatchChaining() {
        //CRON expression - hold schedule time to run batch
        String nextRunCron;
        String iupgmBatchJobName;
        //Adding X minutes to current time to calculate next run time
        Integer minuteValue = Integer.ValueOf(Core_MDF_Configuration__c.getValues('BULK_IUPGM_JOB_MINUTES').Core_MDF_Value__c);
        
        DateTime nextRunTime = system.now().addMinutes(minuteValue);
        
        nextRunCron = 0+' '+nextRunTime.minute()+' '+nextRunTime.hour()+' '+nextRunTime.day()+'-'+nextRunTime.day()+' '+nextRunTime.month()+'  ? '+nextRunTime.year();
        // provide unique name to job
        Double randomNum = math.random();
        iupgmBatchJobName = 'CCP_MDF_BulkIUPGMJob_'+nextRunTime+'_'+randomNum ;
        string jobId = System.schedule(iupgmBatchJobName, nextRunCron, new Core_MDF_InactivateIUPGMScheduler());
        
        
    }
}