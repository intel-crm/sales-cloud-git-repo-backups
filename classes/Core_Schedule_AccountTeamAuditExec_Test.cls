/***********************************************************************************
Apex Class Name:  Core_Schedule_AccountTeamAuditExec_Test
Version     : 1.0 
Created Date: 5/24/16 
Function    : Test class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
************************************************************************************/

@isTest
private class Core_Schedule_AccountTeamAuditExec_Test {

	// CRON expression
   	// Because this is a test, job executes
   	// immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	static List<Account>								lstAccount;
	static Core_Batch_Header__c    						batchHeader;

	static void setupTestData()  {        
        lstAccount = Core_Test_Utility.createAccount(10);
        insert lstAccount;

        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Core_Batch_AccountTeamAuditInitialize';
        batchHeader.Name           = 'Core_Batch_AccountTeamAuditInitialize';        
        insert batchHeader;
    }
	
	@isTest static void auditResetTest() {
		setupTestData();
	    Core_Account_Team_Audit_Schedule__c setting = new Core_Account_Team_Audit_Schedule__c();
        setting.Core_Escalation_Level__c = 2;
        setting.Core_Execution_Month_Day__c = Date.today();
        setting.Name = 'Audit Reset';
    
        insert setting;

		Test.startTest();
		// Schedule the test job 
      	String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new Core_Schedule_AccountTeamAuditExecution());
		Test.stopTest();
	}

	@isTest static void basicTest() {
		setupTestData();
	    Core_Account_Team_Audit_Schedule__c setting = new Core_Account_Team_Audit_Schedule__c();
        setting.Core_Escalation_Level__c = 2;
        setting.Core_Execution_Month_Day__c = Date.today();
        setting.Name = 'Fake Name';
    
        insert setting;

		Test.startTest();
		// Schedule the test job
      	String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new Core_Schedule_AccountTeamAuditExecution());
		Test.stopTest();
	}
}