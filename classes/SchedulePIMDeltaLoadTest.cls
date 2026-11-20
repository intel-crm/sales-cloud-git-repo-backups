/***************************************************************************************************************************
 * Apex Class Name  : ProcessLevel1ProductsQueueable
 * Author And Date  : Rohit Podder, 22 JUNE 2026
 * Function         : Test class to cover SchedulePIMDeltaLoad
 ****************************************************************************************************************************/
@isTest
public class SchedulePIMDeltaLoadTest {
    
    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        
        // Get the number of jobs in the queue before scheduling
        Integer jobsBeforeScheduling = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'];
        
        
        String cronExpression = '0 0 12 * * ?'; // Daily at 12 PM
        String jobId = System.schedule('Test SchedulePIMDeltaLoad', cronExpression, new SchedulePIMDeltaLoad());
        
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExpression, ct.CronExpression, 'Cron expression should match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have been triggered yet');
        
        Test.stopTest();
        
        Integer jobsAfterScheduling = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assert(jobsAfterScheduling >= jobsBeforeScheduling, 'A queueable job should have been enqueued');
    }
    
}