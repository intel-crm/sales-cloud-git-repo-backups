/****************************************************************************************************
Apex Class Name:  Core_ChangeRequestHandler_Test
Version     : 1.0
Created Date: 06 OCT 2014
Function    : Test class for "Core_ChangeRequest" Trigger and "Core_Change_Request_Handler" Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Harshith M L             06/10/2014              Original Version
*****************************************************************************************************/
@isTest
private class Core_ChangeRequestHandler_Test {

    // List of Accounts to be inserted
    Static List <Account> lstAccount;

    // List of Change Request records to be inserted
    Static List<Core_Change_Request__c> lstChangeRequest;

    // To store the instance of System Admin User
    Static user systemAdminUser;

    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data ( Accounts )
     * Return Type  : None
     * Parameter    : None
     */

    static void setupTestData() {
    
        // Custom Setting to be inserted inorder to run the "Account Team Member Creation" functionality
        List <Core_Trigger_Executions__c> lstTriggerExecution = new List <Core_Trigger_Executions__c>();

        Core_Trigger_Executions__c accountTeamMemberCreation = new Core_Trigger_Executions__c();
        accountTeamMemberCreation.name = 'accountTeamMemberCreation';
        accountTeamMemberCreation.Core_Object__c = 'Change_Request__c';
        accountTeamMemberCreation.Core_Active__c = TRUE;
        accountTeamMemberCreation.Core_Trigger_Events__c = 'After Insert';
        accountTeamMemberCreation.Core_Description__c = 'This is a test';
        accountTeamMemberCreation.Core_Class_Name__c = 'Test class';

        lstTriggerExecution.add(accountTeamMemberCreation);

        // Custom Setting to be inserted inorder to run the "Change Request Owner Population" functionality
        Core_Trigger_Executions__c changeRequestOwnerPopulation = new Core_Trigger_Executions__c();
        changeRequestOwnerPopulation.name = 'changeRequestOwnerPopulation';
        changeRequestOwnerPopulation.Core_Object__c = 'Change_Request__c';
        changeRequestOwnerPopulation.Core_Active__c = TRUE;
        changeRequestOwnerPopulation.Core_Trigger_Events__c = 'After Insert';
        changeRequestOwnerPopulation.Core_Description__c = 'This is a test';
        changeRequestOwnerPopulation.Core_Class_Name__c = 'Test class';

        lstTriggerExecution.add(changeRequestOwnerPopulation);

        // inserting custom setting
        insert lstTriggerExecution;


        List <User> usersList = new List <User>();

        // Fetching a different System admin
        usersList = [SELECT Id, Name FROM User where isActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 5];
        for (User sysAdminUser: usersList) {
            if (sysAdminUser.Id != UserInfo.getUserId())
                systemAdminUser = sysAdminUser;
        }
        
        // Inserting list of accounts
        lstAccount = new List <Account>();
        lstAccount = Core_Test_Utility.createAccount(200);

        for (Account sobjAcc: lstAccount) {
            sobjAcc.billingCity = 'Bangalore';
            sobjAcc.billingStreet = 'Yemlur';
        }
        
        insert lstAccount;

    }

    /*
     * Method name  : setupChangeRequest
     * Description  : Method to setup test data ( Change Request)
     * Return Type  : None
     * Parameter    : None
     */

    static void setupChangeRequest() {
    
        // Fetching "Account Team Request" record type Id
        List <RecordType> lstRecordType = [SELECT Id, Name, DeveloperName From RecordType where sObjectType = 'Core_Change_Request__c'
                                             AND DeveloperName = 'Account_Team_Request'];
                                             
        lstChangeRequest = new List<Core_Change_Request__c>();
        lstChangeRequest = Core_Test_Utility.createChangeRequest(lstAccount);

        // Updating the record type details for change request and inserting it
        Boolean testCustomerAERole = true;
        
        for (Core_Change_Request__c changeRequestInstance: lstChangeRequest) {
            changeRequestInstance.RecordTypeId = lstRecordType.get(0).Id;
            if(testCustomerAERole) {
                //changeRequestInstance.Core_Account_Team_Role__c = 'Customer Access and Entitlement';
                testCustomerAERole = false;
            }
        }
        insert lstChangeRequest;
        
    }


    /*
     * Method name  : changeRequestCreate
     * Description  : Testmethod method for testing "Core_ChangeRequest" Trigger and "Core_Change_Request_Handler" Class 
                      for Change Request Owner population
     * Return Type  : None
     * Parameter    : None
     */

    static testMethod void changeRequestOwnerPopulation() {
        
        setupTestData();

        Test.startTest();

            // Creating change Request records as a different system admin user
            System.runAs(systemAdminUser) {
                setupChangeRequest();
                // Asserting whether owner of Change Request and Account records are same
                for (Core_Change_Request__c changeRequestInstance : lstChangeRequest)
                    System.assertEquals(changeRequestInstance.OwnerId, changeRequestInstance.Core_Account__r.OwnerId);
            }

        Test.stopTest();
    }
    
    
    static TestMethod void accountTeamAutomation()
    {
        // Set to store Account Ids related to change request record
        Set <Id> sAccountIds = new Set <Id>();
        
        // List to store inserted Accounts details
        List <Account> lstInsertedAccounts = new List <Account>();
        
        // Setting up test Environment
        setupTestData();

        Test.startTest();
        
            System.runAs(systemAdminUser) {
                setupChangeRequest();
            }        
            
            // Updating the boolean flag to simulate that its a different transaction for upcoming DML
            Core_ChangeRequestHandler.bChangeRequestOwnerPopulation = true;
            
            // Changing the status of Change request record to approved
            for (Core_Change_Request__c changeRequestInstance: lstChangeRequest) {
                changeRequestInstance.Core_Status__c = 'stalled';
                sAccountIds.add(changeRequestInstance.Core_Account__c);
            }
    
            update lstChangeRequest;
            
            System.debug(systemAdminUser);
            
            for(Core_Change_Request__c changeRequestInstance : [SELECT Id,OwnerId FROM Core_Change_Request__c])
            {
                System.assertEquals(changeRequestInstance.OwnerId,UserInfo.getUserId());
            }
        
            // Fetching the Account, Account Teammembers and AccountShare records related to changeRequest
            lstInsertedAccounts = [SELECT Id, Name, (SELECT UserId, AccountId, TeamMemberRole FROM AccountTeamMembers),
                        (SELECT ID, UserOrGroupId, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM Shares) FROM ACCOUNT];
    
            Map < Id, Account > mapAccountIdAccount = new Map < Id, Account > (lstInsertedAccounts);
    
            for (Core_Change_Request__c changeRequestInstance: lstChangeRequest) {
                System.assertEquals(mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).AccountTeamMembers.size(), 0);
                System.assertEquals(mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).Shares.size(), 1);
            }
            
            // Updating the boolean flag to simulate that its a different transaction for upcoming DML
            Core_ChangeRequestHandler.bChangeRequestOwnerPopulation = true;
            
            // Updating the boolean flag to simulate that its a different transaction for upcoming DML
            Core_ChangeRequestHandler.baccountTeamMemberCreation = true;
            
            // Changing the status of Change request record to approved
            for (Core_Change_Request__c changeRequestInstance: lstChangeRequest) {
                changeRequestInstance.Core_Status__c = 'Approved';
                sAccountIds.add(changeRequestInstance.Core_Account__c);
            }
    
            update lstChangeRequest;
    
            // Fetching the Account, Account Teammembers and AccountShare records related to changeRequest
            lstInsertedAccounts = [SELECT Id, Name, (SELECT UserId, AccountId, TeamMemberRole FROM AccountTeamMembers),
                        (SELECT ID, UserOrGroupId, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM Shares) FROM ACCOUNT];
                        
            mapAccountIdAccount.clear();
    
            mapAccountIdAccount = new Map < Id, Account > (lstInsertedAccounts);
    
            for (Core_Change_Request__c changeRequestInstance: lstChangeRequest) {
                System.assertEquals(mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).AccountTeamMembers.size(), 1);
                System.assertEquals((mapAccountIdAccount.get(changeRequestInstance.Core_Account__c)).AccountTeamMembers.get(0).UserId, systemAdminUser.Id);
                System.assertEquals((mapAccountIdAccount.get(changeRequestInstance.Core_Account__c)).AccountTeamMembers.get(0).TeamMemberRole,
                    changeRequestInstance.Core_Account_Team_Role__c);
                //System.assertEquals(mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).Shares.size(), 2);
            }
            
        Test.stopTest();
    }
}