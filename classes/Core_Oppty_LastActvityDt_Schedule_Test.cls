/********************************************************************************************************************************************************************
Apex Class Name:  Core_Oppty_LastActvityDt_Schedule_Test
Version     : 1.0 
Created Date: 21/09/2022  
Function    : Test class for Core_Oppty_LastActvityDt_Schedule

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth               21/09/2022               Original Version developed
*******************************************************************************************************************************************************************/
@isTest
public class Core_Oppty_LastActvityDt_Schedule_Test {
    
    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        
        
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Core_Oppty_LastActvityDt_Schedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
    }
    

}