@isTest
private class Core_Batch_AccountTeamAuditKO_Test {
    static List<Account>			lstAccount;
    static List<User>              	lstUser;
    static List<AccountTeamMember> 	lstAccountTeamMember;
    static Core_Batch_Header__c    	batchHeader;
    static List<Account>			lstAccountResults;
    static Date 					dueDate;    
    
    static List<Core_Account_Team__c> lstCustomAccountTeamMember;
    
    static void setupTestData()
    {        
        lstAccount = Core_Test_Utility.createAccount(10);
        insert lstAccount;
        
        lstUser = Core_Test_Utility.Core_User(10);
        insert lstUser;
        
        lstAccountTeamMember = new List<AccountTeamMember>();
        
        List<AccountTeamMember> lstATM;
        Integer count = 0;
        for (Account acct : lstAccount) {
            if(count < 5) {
                lstATM = Core_Test_Utility.Core_AccountTeamMember(lstUser);
                for (AccountTeamMember atm : lstATM) {
                    atm.AccountId = acct.Id;
                }
                lstAccountTeamMember.addAll(lstATM);                
                count++;
            }                     	          
        }
        insert lstAccountTeamMember;
        
        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Core_Batch_AccountTeamAuditKickoff';
        batchHeader.Name           = 'Core_Batch_AccountTeamAuditKickoff';        
        insert batchHeader;
        
        Core_Account_Team_Audit_Settings__c setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'AuditDurationDays';
        setting.Core_Value__c = '30';
        insert setting;
        Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'AccountTeamAuditKickoff';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c = 'AccountTeamAuditKickoff';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');      
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');  
    }
    
    @isTest static void testWithoutDueDateScheduled() {
        setupTestData();
        
        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditKickoff(false, false, null, false), 1000);
        
        Test.stopTest();   
        
        //System.assert(findOpenAuditAccounts() == 5);
    }
    
    @isTest static void testWithDueDateScheduled() {
        setupTestData();
        dueDate = Date.today().addDays(25);
        
        Core_Account_Team_Audit_Schedule__c sched = new Core_Account_Team_Audit_Schedule__c();
        sched.Name = '1-5 Due Date';
        sched.Core_Execution_Month_Day__c = dueDate;
        insert sched;
        
        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditKickoff(false, false, null, false), 1000);
        
        Test.stopTest();   
        
        //System.assert(findOpenAuditAccounts() == 5);
    }
    
    static Integer findOpenAuditAccounts() {
        lstAccountResults = [select ID, Core_Account_Team_Audit_Complete__c from Account where Core_Account_Team_Audit_Complete__c = false and Core_Account_Team_Audit_Due_Date__c != null];
        return lstAccountResults.size();
    }	 
}