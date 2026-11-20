//use this class as schedular
//* @Description Scheduler class to schedule daily csv file report upload job to Quality Builder shared forlder 

/***************************************************************************************************************
* @Name IPS_QualityBuilderReportscheduler
* @Description Scheduler class to schedule daily csv file report upload job to Quality Builder shared forlder
* @Author Sai krishna popcornapps
* @version 1.0
* @Created Date 26/11/2021
****************************************************************************************************************/
public class IPS_QualityBuilderReportscheduler implements Schedulable {
    public void execute(SchedulableContext sContext){
        //-- Logic to fetch the job settings and pass to utility method & abort job if inactive.
        String jobName = IPS_QualityBuilderUtility.getJobName(sContext);
        Map<String,IPS_QualityBuilder_Generic_Pipe_Setting__c> jobSettingMap = IPS_QualityBuilder_Generic_Pipe_Setting__c.getAll();
        if(String.isNotBlank(jobName) && jobSettingMap.containsKey(jobName) && jobSettingMap.get(jobName).Is_Active__c) {
            IPS_QualityBuilderUtility.sendQualityBuilderReport(jobName);
        }
        if((String.isNotBlank(jobName) && !jobSettingMap.containsKey(jobName)) || (String.isNotBlank(jobName) && jobSettingMap.containsKey(jobName) && !jobSettingMap.get(jobName).Is_Active__c)) {
            System.abortJob(sContext.getTriggerId());
        }
        // End Logic to fetch the job settings and pass to utility method & abort job if inactive.
    }
    // Method can be used to schedule this job by providing the CRON Expression
    public static void schedule() { 
        // Start Logic to schedule all active jobs.
        // fetch all the jobs from generic pipe setting
        Map<String,IPS_QualityBuilder_Generic_Pipe_Setting__c> jobSettingMap = IPS_QualityBuilder_Generic_Pipe_Setting__c.getAll();
        if(jobSettingMap != null && !jobSettingMap.isEmpty()) {
            // abort all the jobs
            IPS_QualityBuilderUtility.abortAllJobs(jobSettingMap.keySet());
            // scedule all the active Jobs based on setting
            IPS_QualityBuilderUtility.scheduleActiveJobs(jobSettingMap);
        }
        // End Logic to schedule all active jobs.
    }
}