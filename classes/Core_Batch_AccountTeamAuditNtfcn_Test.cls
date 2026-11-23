/***********************************************************************************
Apex Class Name:  Core_Batch_AccountTeamAuditNtfcn_Test
Version     : 1.0 
Created Date: 5/24/16 
Function    : Test class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
************************************************************************************/

@isTest
private class Core_Batch_AccountTeamAuditNtfcn_Test {
    
    static List<Account>			lstAccount;
    static List<User>              	lstUser;
    static List<AccountTeamMember> 	lstAccountTeamMember;
    static Core_Batch_Header__c    	batchHeader;
    static List<Account>			lstAccountResults;
    static Date 					dueDate;    
    static List<Core_Account_Team__c> lstCustomAccountTeamMember;
    static String 					taskSubject;
    static Integer					numAccounts;
    
    static void setupTestData()
    {        
        lstAccount = Core_Test_Utility.createAccount(numAccounts);
        
        lstUser = Core_Test_Utility.Core_User(numAccounts+10);        
        lstUser[5].Alias = 'uncoverd';
        insert lstUser;
        
        Integer count = 0;
        for(Account acct:lstAccount) {
            acct.Core_Account_Team_Audit_Complete__c = false;
            acct.Core_Account_Team_Audit_Due_Date__c = Date.today().addDays(30);
            acct.OwnerId = lstUser[count].ID;
            count++;
        }
        insert lstAccount;
        
        Task taskInstance = new Task();
        taskInstance.ActivityDate = System.Today().addDays(1);
        taskInstance.Priority = 'Medium';
        taskInstance.status = 'Pending';
        taskInstance.Subject = 'Perform Account Team Audit (Test Class)';
        insert taskInstance;
        
        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Core_Batch_AccountTeamAuditNotification';
        batchHeader.Name           = 'Core_Batch_AccountTeamAuditNotification';        
        insert batchHeader;
        
        List<Core_Account_Team_Audit_Settings__c> lstSettings = new List<Core_Account_Team_Audit_Settings__c>();
        
        Core_Account_Team_Audit_Settings__c setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'AuditDurationDays';
        setting.Core_Value__c = '30';
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'AuditPageURL';
        setting.Core_Value__c = 'apex/Core_AccountTeamAudit';
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'DefaultTaskPriority';
        setting.Core_Value__c = 'High';
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'DefaultTaskStatus';
        setting.Core_Value__c = 'Not Started';
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'DefaultTaskSubject';
        taskSubject = 'Perform Account Team Audit (Test Class)';
        setting.Core_Value__c = taskSubject;
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'UncoveredAccountsUser';
        setting.Core_Value__c = lstUser[numAccounts+1].ID;
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'UncoveredAccountsEmailTemplateName';
        setting.Core_Value__c = 'Account Team Audit - Uncovered Accounts';
        lstSettings.add(setting);
        
        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'OrgWideEmailDisplayName';
        setting.Core_Value__c = 'Intel Covered Accounts';
        lstSettings.add(setting);
        
        insert lstSettings;
         
    }
    
    @isTest static void testWithoutEmailOrTasks() {
        numAccounts = 10;
        setupTestData();
        Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'Account_TeamAuditNotification';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c ='Account_TeamAuditNotification';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');     
        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditNotification(3, false, 'Account Team Audit - Initial Notification', false), 1000);
        
        Test.stopTest();   
        
        //Assert that appropriate audit_log entries were generated
        List<Core_Audit_Log__c> logs = [select Id, Core_Account__r.Name from Core_Audit_Log__c];
        //System.assert(logs.size() == numAccounts);
    }
    
    @isTest static void testWithEmailAndTasks() {
        numAccounts = 10;
        setupTestData();
        Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'Account_TeamAuditNotification';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c ='Account_TeamAuditNotification';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');     
        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditNotification(3, true, 'Account Team Audit - Initial Notification', true), 1000);
        
        Test.stopTest();   
        
        List<Task> tasks = [select Id, Task.Owner.Name from Task where Task.Subject = :taskSubject];
        //System.assert(tasks.size() == numAccounts);
    }
    
    @isTest static void testWithEmailAndTasksAtScale() {
        numAccounts = 200;
        setupTestData();
         Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'Account_TeamAuditNotification';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c ='Account_TeamAuditNotification';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');  
        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditNotification(3, true, 'Account Team Audit - Initial Notification', true), 1000);
        
        Test.stopTest();   
        
        List<Task> tasks = [select Id, Task.Owner.Name from Task where Task.Subject = :taskSubject];
        //System.assert(tasks.size() == numAccounts);
    } 
}