@isTest
public class Core_MDF_InactivateIUPGMScheduler_Test {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    //public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static String CRON_EXP = '0 0 0 * * ? 2022';
    static testmethod void testScheduledJob() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new Core_MDF_InactivateIUPGMScheduler());
        Test.stopTest();
        System.assert(jobId != NULL);
    }
}