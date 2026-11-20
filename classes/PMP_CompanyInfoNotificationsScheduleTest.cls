/****************************************************************************************************************************************
* Class Name        : PMP_CompanyInfoNotificationsScheduleTest
* Created Date      : 15-06-2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Abhishek         15-06-2020         test class for PMP_CompanyInfoNotificationsScheduler .
*****************************************************************************************************************************************/
@isTest
public class PMP_CompanyInfoNotificationsScheduleTest {
  
    static testMethod void PMP_CompanyInfoNotificationsScheduleTest(){
        Test.StartTest();
        String cronExp = '0 46 * * * ?';
        String jobID = System.schedule('Schedule', cronExp , new PMP_CompanyInfoNotificationsScheduler());

        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	    System.assertEquals(cronExp, ct.CronExpression);
    }
}