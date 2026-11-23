/***************************************************************************************************
* @Name ICS_QualityBuilderBulkPollScheduler 
* @Description Schedules a single one-time check of a Bulk API 2.0 job a few minutes in the future.
*              Each firing enqueues ICS_QualityBuilderBulkPoller to do the actual callout.
* @version 1.0
* @Created Date 13/09/2026
* @Modified Date 08/09/2026
***************************************************************************************************/
public class IPS_QualityBuilderBulkPollScheduler implements Schedulable{
    
    private static final Integer DEFAULT_DELAY_MINUTES = 2;
    private String jobName;
    private String bulkJobId;
    private Integer attemptCount;

    public IPS_QualityBuilderBulkPollScheduler(String jobName, String bulkJobId, Integer attemptCount) {
        this.jobName = jobName;
        this.bulkJobId = bulkJobId;
        this.attemptCount = attemptCount;
    }

    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new IPS_QualityBuilderBulkPoller(jobName, bulkJobId, attemptCount));
    }

    public static void scheduleNextPoll(String jobName, String bulkJobId, Integer attemptCount) {
        scheduleNextPoll(jobName, bulkJobId, attemptCount, DEFAULT_DELAY_MINUTES);
    }

    public static void scheduleNextPoll(String jobName, String bulkJobId, Integer attemptCount, Integer delayMinutes) {
        try {
            Datetime fireTime = Datetime.now().addMinutes(delayMinutes);
            String cronExpression = buildOneTimeCron(fireTime);

            // CronTrigger job names must be unique and <= 80 chars; truncate jobName defensively.
            String safeJobName = jobName.length() > 40 ? jobName.substring(0, 40) : jobName;
            String scheduleName = 'ICS QB Poll ' + safeJobName + ' ' + String.valueOf(fireTime.getTime()) + attemptCount;

            System.debug('BULK API: Job created');
            System.schedule(scheduleName, cronExpression, new IPS_QualityBuilderBulkPollScheduler(jobName, bulkJobId, attemptCount));

        } catch (Exception exc) {
            //Core_Log_Entry.logEntryWithException(jobName, 'QualityBuilder', 'ISVC', 'Critical',jobName + ' Poll Scheduling Failed','Unhandled exception occurred while scheduling the next bulk job poll', exc);
            System.debug('Poll Scheduling Failed. Unhandled exception occurred while scheduling the next bulk job poll: '+exc);
        }
    }

    private static String buildOneTimeCron(Datetime fireTime) {
        return fireTime.second() + ' ' + fireTime.minute() + ' ' + fireTime.hour() + ' '
            + fireTime.day() + ' ' + fireTime.month() + ' ? ' + fireTime.year();
    }
}