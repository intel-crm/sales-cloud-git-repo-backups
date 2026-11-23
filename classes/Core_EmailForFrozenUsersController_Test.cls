/*******************************************************************************************************************************
Apex Class Name:  Core_EmailForFrozenUsersController_Test
Version     : 1.0 
Created Date: 20 JUNE 2022
Function    : methods to fetch user data and send as an excel attachment to required users.
Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------------------------- 
* Sankarshana                 06/20/2022               Test class for Core_EmailForFrozenUsersController.
*********************************************************************************************************************************/
@isTest
public class Core_EmailForFrozenUsersController_Test {
  
public static testMethod void forTest(){
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String CRON_EXP = '0 6 * * * ?';
    test.startTest();    
    String jobId = System.schedule('SendEmail',  CRON_EXP, new Core_EmailForFrozenUsersController());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
    
    test.stopTest();
  }
	 
}