/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityDt_Schedule_Test
Version     : 1.0 
Created Date: 15/04/2020
Function    : Test class for Core_Opp_LastActvityDt_Schedule

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               15/04/2020               Original Version developed
*******************************************************************************************************************************************************************/
@isTest
public class Core_Opp_LastActvityDt_Schedule_Test {
    
    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        
        
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Core_Opp_LastActvityDt_Schedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
    }
    

}