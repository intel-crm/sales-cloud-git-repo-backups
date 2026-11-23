@isTest
public class PMP_PublishFutureUpdateScheduler_Test {
 //IPA2.0 - As part of TWC729-7977 commented the entire class
 /*
    @isTest 
    static void executeTest(){
        Test.StartTest();
        String cronExp = '0 46 * * * ?';
        String jobID = System.schedule('Schedule', cronExp , new PMP_PublishFutureUpdateScheduler());

        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	    System.assertEquals(cronExp, ct.CronExpression);
    } */
}