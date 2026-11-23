/***********************************************************************************
Apex Class Name:  Core_AccountTeamAudit_Controller_Test
Version     : 1.0 
Created Date: 5/24/16 
Function    : Test class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
************************************************************************************/

@isTest
public class Core_AccountTeamAudit_Controller_Test{

	static List<Account>	lstAccount;
	static List<User>              lstUser;
    static List<AccountTeamMember> lstAccountTeamMember;
    static Core_Batch_Header__c    batchHeader;

    static List<Core_Account_Team__c> lstCustomAccountTeamMember;

	static void setupTestData(Integer numAccounts)
    {        
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
    		lstUser = Core_Test_Utility.Core_User(numAccounts);
        	insert lstUser;
		}
    	
    	System.runAs ( thisUser ) {
	        lstAccount = Core_Test_Utility.createAccount(numAccounts);
	        Integer count = 0;        
	        for(Account acct: lstAccount) {
	        	acct.Core_Account_Team_Audit_Complete__c = false;
	            if (count >= 5)
	            	acct.OwnerId = UserInfo.getUserId();
	            else 
	            	acct.OwnerId = lstUser[0].Id;
	            count++;
	        }
	        insert lstAccount;
		}
    	System.runAs ( thisUser ) {
	        lstAccountTeamMember = new List<AccountTeamMember>();
        
	        List<AccountTeamMember> lstATM;
	        for (Account acct : lstAccount) {
	            System.debug('Account: ' + acct);
	            lstATM = Core_Test_Utility.Core_AccountTeamMember(lstUser);
	            for (AccountTeamMember atm : lstATM) {
	                atm.AccountId = acct.Id;
	                System.debug('Adding team member: ' + atm);
	            }
	            lstAccountTeamMember.addAll(lstATM);                
	        }
	        insert lstAccountTeamMember;
    	
		}
    }
	
	static testMethod void testDataOpsPageLoad(){
		setupTestData(10);
		PageReference pageRef = Page.Core_AccountTeamAudit_DataOps;
		Test.setCurrentPage(pageRef);

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoadForDataOps();
		System.assert(controller.accounts.size() == 10);
		System.assert(controller.displayList.size() == 10);
	}	

	static testMethod void testRegularPageLoad(){
		setupTestData(10);
		PageReference pageRef = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef);

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoad();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		System.assert(controller.accounts.size() == 5);
		System.assert(controller.displayList.size() == 5);

		PageReference pageRef2 = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef2);
		ApexPages.CurrentPage().getParameters().put('page', '20');

		Core_AccountTeamAudit_Controller controller2 = new Core_AccountTeamAudit_Controller();
		controller2.onLoad();
		System.debug(String.valueOf(controller2.accounts.size()));
		System.debug(String.valueOf(controller2.displayList.size()));
		System.assert(controller2.accounts.size() == 5);
		System.assert(controller2.displayList.size() == 5);
	}	

	static testMethod void testRegularPageSave(){
		setupTestData(10);
		PageReference pageRef = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef);

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoad();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		for(Account acct:controller.accounts) {
			acct.Core_Account_Team_Audit_Complete__c = true;
		}		
		controller.save();

		PageReference pageRef2 = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef2);

		Core_AccountTeamAudit_Controller controller2 = new Core_AccountTeamAudit_Controller();
		controller2.onLoad();

		System.debug(String.valueOf(controller2.accounts.size()));
		System.debug(String.valueOf(controller2.displayList.size()));
		System.assert(controller2.accounts.size() == 0);
		System.assert(controller2.displayList.size() == 0);
	}	

	static testMethod void testRegularPageSearch(){
		setupTestData(10);
		PageReference pageRef = Page.Core_AccountTeamAudit;		
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('search', 'blahblahbloopblah');

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoad();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		System.assert(controller.accounts.size() == 0); 
		System.assert(controller.displayList.size() == 0);


		PageReference pageRef2 = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef2);
		ApexPages.CurrentPage().getParameters().put('search', lstAccount[5].Name);
		System.debug('Searching for Account Name: ' + lstAccount[5].Name);

		Core_AccountTeamAudit_Controller controller2 = new Core_AccountTeamAudit_Controller();
		controller2.onLoad();

		System.debug(String.valueOf(controller2.accounts.size()));
		System.debug(String.valueOf(controller2.displayList.size()));
		System.assert(controller2.accounts.size() == 1);
		System.assert(controller2.displayList.size() == 1);
	}	

	static testMethod void testDataOpsPageSearch(){
		setupTestData(10);
		PageReference pageRef = Page.Core_AccountTeamAudit_DataOps;		
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('search', 'blahblahbloopblah');

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoadForDataOps();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		System.assert(controller.accounts.size() == 0); 
		System.assert(controller.displayList.size() == 0);


		PageReference pageRef2 = Page.Core_AccountTeamAudit_DataOps;
		Test.setCurrentPage(pageRef2);
		ApexPages.CurrentPage().getParameters().put('search', lstUser[0].LastName);
		System.debug('Searching for User Name: ' + lstUser[0].LastName);

		Core_AccountTeamAudit_Controller controller2 = new Core_AccountTeamAudit_Controller();
		controller2.onLoadForDataOps();

		System.debug(String.valueOf(controller2.accounts.size()));
		System.debug(String.valueOf(controller2.displayList.size()));
		System.assert(controller2.accounts.size() == 5);
		System.assert(controller2.displayList.size() == 5);
	}	

	static testMethod void testDataOpsPagePaging(){
		setupTestData(19);

		List<Core_Account_Team_Audit_Settings__c> lstSettings = new List<Core_Account_Team_Audit_Settings__c>();

        Core_Account_Team_Audit_Settings__c setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'PageMaxAccountsLoaded';
        setting.Core_Value__c = '30';
        lstSettings.add(setting);

        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'PageSize';
        setting.Core_Value__c = '10';
        lstSettings.add(setting);

        insert lstSettings;

		PageReference pageRef = Page.Core_AccountTeamAudit_DataOps;		
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('page', '2');
		System.debug('Paging page 2');

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoadForDataOps();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		System.assert(controller.accounts.size() == 19); 
		System.assert(controller.displayList.size() == 9);


		PageReference pageRef2 = Page.Core_AccountTeamAudit;
		Test.setCurrentPage(pageRef2);
		ApexPages.CurrentPage().getParameters().put('page', '1');
		System.debug('Paging page 1');

		Core_AccountTeamAudit_Controller controller2 = new Core_AccountTeamAudit_Controller();
		controller2.onLoadForDataOps();

		System.debug(String.valueOf(controller2.accounts.size()));
		System.debug(String.valueOf(controller2.displayList.size()));
		System.assert(controller2.accounts.size() == 19);
		System.assert(controller2.displayList.size() == 10);
	}	

	static testMethod void testRegularPageMaxAccounts(){
		setupTestData(39);

		List<Core_Account_Team_Audit_Settings__c> lstSettings = new List<Core_Account_Team_Audit_Settings__c>();

        Core_Account_Team_Audit_Settings__c setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'PageMaxAccountsLoaded';
        setting.Core_Value__c = '30';
        lstSettings.add(setting);

        setting = new Core_Account_Team_Audit_Settings__c();
        setting.Name = 'PageSize';
        setting.Core_Value__c = '10';
        lstSettings.add(setting);

        insert lstSettings;

		PageReference pageRef = Page.Core_AccountTeamAudit;		
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('page', '3');
		System.debug('Paging page 3');

		Core_AccountTeamAudit_Controller controller = new Core_AccountTeamAudit_Controller();
		controller.onLoad();
		System.debug(String.valueOf(controller.accounts.size()));
		System.debug(String.valueOf(controller.displayList.size()));
		System.assert(controller.accounts.size() == 30); 
		System.assert(controller.displayList.size() == 10);
	}	
}