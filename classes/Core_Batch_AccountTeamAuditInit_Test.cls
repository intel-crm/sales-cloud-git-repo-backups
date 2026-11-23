@isTest
private class Core_Batch_AccountTeamAuditInit_Test {
	static List<Account>	lstAccount;
	static List<User>              lstUser;
    static List<AccountTeamMember> lstAccountTeamMember;
    static Core_Batch_Header__c    batchHeader;

    static List<Core_Account_Team__c> lstCustomAccountTeamMember;

	static void setupTestData()
    {        
        lstAccount = Core_Test_Utility.createAccount(10);
        insert lstAccount;

        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Core_Batch_AccountTeamAuditInitialize';
        batchHeader.Name           = 'Core_Batch_AccountTeamAuditInitialize';        
        insert batchHeader;
    }
	
	static testMethod void CompleteAndDueDate() {
		setupTestData();
		Integer count = 0;
        for (Account acct : lstAccount) {
            System.debug('Account: ' + acct);
            if(count < 5) {
	            acct.Core_Account_Team_Audit_Complete__c = false;
	            acct.Core_Account_Team_Audit_Due_Date__c = Date.today();
            	count++;
        	}                     	          
        }
        update lstAccount;
		
		System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
		System.assert(countIncompleteAuditEntries() == 5);

        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditInitialize(), 1000);
        
        Test.stopTest();   

        System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
        System.assert(countIncompleteAuditEntries() == 0);
	}

	static testMethod void CompleteOnly() {
		setupTestData();
		Integer count = 0;
        for (Account acct : lstAccount) {
            System.debug('Account: ' + acct);
            if(count < 5) {
	            acct.Core_Account_Team_Audit_Complete__c = false;
            	count++;
        	}                     	          
        }
        update lstAccount;
		
		System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
		System.assert(countIncompleteAuditEntries() == 5);

        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditInitialize(), 1000);
        
        Test.stopTest();   

        System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
        System.assert(countIncompleteAuditEntries() == 0); 
	}

		static testMethod void DueDateOnly() {
		setupTestData();
		Integer count = 0;
        for (Account acct : lstAccount) {
            System.debug('Account: ' + acct);
            if(count < 5) {
	            acct.Core_Account_Team_Audit_Due_Date__c = Date.today();
            	count++;
        	}                     	          
        }
        update lstAccount;
		
		System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
		System.assert(countIncompleteAuditEntries() == 5);

        Test.startTest();        
        
        Database.executeBatch(new Core_Batch_AccountTeamAuditInitialize(), 1000);
        
        Test.stopTest();   

        System.debug('IncompleteAuditEntries: ' + String.valueOf(countIncompleteAuditEntries()));
        System.assert(countIncompleteAuditEntries() == 0);
	}

	static Integer countIncompleteAuditEntries() {
		List<Account> accts = [select ID, Core_Account_Team_Audit_Complete__c from Account where Core_Account_Team_Audit_Complete__c = false or Core_Account_Team_Audit_Due_Date__c != null];
		return accts.size();
	}
	
}