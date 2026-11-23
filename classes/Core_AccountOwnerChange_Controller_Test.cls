/****************************************************************************************************
Apex Class Name : Core_AccountOwnerChange_Controller_Test
Version         : 1.0 
Created Date    : 01/16/15
Function        : Test class for User actuated process to request ownership of an account from the 
                  current owner.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              01/16/2015             Original Version
* Dave Hood                   03/20/2015             Updated for "Uncovered Account"
* Dave Hood                   01/17/2017             Updated to test for block of users with A&E profile but not A&E Super User permission set
*****************************************************************************************************/
@isTest
private class Core_AccountOwnerChange_Controller_Test {

    static Account account;
    static ApexPages.StandardController accountController;
    static Core_AccountOwnerChange_Controller changeRequestController;
    static User inactiveUser;
    static User newUser;

    static List<Account> accountList;
    static List<User> userList;

    static void setupTest(Integer testCase)
    {
        // List size  0 - account not found.
        if (testCase == 0)
        {
            account                 = new Account();    
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }

        // CurrentUser == Account Owner
        if (testCase == 1)
        {
            accountList     = Core_Test_Utility.createAccount(1);
            account         = accountList[0];
            account.OwnerId = UserInfo.getUserId();
            insert account;
                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }
        
        
        // CurrentUser == Integration User
        if (testCase == 2)
        {
            accountList     = Core_Test_Utility.createAccount(2);
            account         = accountList[1];
            account.OwnerId = Label.Core_CRM_Integration_User_ID;
            insert account;
                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }


        // Account Owner Inactive        
        if (testCase == 3)
        {
            // User must be Active for the account insert to work.
            userList              = Core_Test_Utility.Core_User(1);
            inactiveUser          = userList[0];
            inactiveUser.isActive = true;
            insert inactiveUser;
        
            accountList     = Core_Test_Utility.createAccount(3);
            account         = accountList[2];
            account.ownerId = inactiveUser.Id;
            insert account;

            userList = [SELECT Name, Email, IsActive 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

            System.runAs(userList[0]) 
            {    
                // Change User to inactive
                inactiveUser.isActive = false;
                update inactiveUser;
            }
                                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }

        // Make request!
        if (testCase == 4)
        {
            userList = Core_Test_Utility.Core_User(2);
            newUser  = userList[1];
            insert newUser;
        
            accountList     = Core_Test_Utility.createAccount(4);
            account         = accountList[3];
            account.ownerId = newUser.Id;
            insert account;

            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }        
        
        // CurrentUser == Uncovered Account
        if (testCase == 5)
        {
            accountList     = Core_Test_Utility.createAccount(5);
            account         = accountList[4];
            account.OwnerId = Label.Core_Uncovered_Account_ID;
            insert account;
                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }
        
        // Current user is A&E User but not A&E Super User
        if (testCase == 6)
        {
            accountList     = Core_Test_Utility.createAccount(1);
            account         = accountList[0];
            account.OwnerId = Label.Core_Uncovered_Account_ID;
            insert account;
                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }
        
        // Current user is Sales Rep
        if (testCase == 7)
        {
            accountList     = Core_Test_Utility.createAccount(1);
            account         = accountList[0];
            account.OwnerId = Label.Core_Uncovered_Account_ID;
            insert account;
                        
            accountController       = new ApexPages.StandardController(account);
            changeRequestController = new Core_AccountOwnerChange_Controller(accountController);
            return;
        }
        
    }

    static testMethod void accountChangeRequestTest0(){    
        // Start testing the functionality
        Test.startTest();      
          setupTest(0);
          changeRequestController.changeOwnerRequest();
        Test.stopTest();
         
         }         
     static testMethod void accountChangeRequestTest1(){ 
       Test.startTest();        
          setupTest(1);
          changeRequestController.changeOwnerRequest();
        Test.stopTest();
        }
        
       static testMethod void accountChangeRequestTest2(){ 
        Test.startTest();        
          setupTest(2);
          changeRequestController.changeOwnerRequest();
        Test.stopTest();
        }
        
         static testMethod void accountChangeRequestTest3(){ 
          Test.startTest();     
          setupTest(3);
          changeRequestController.changeOwnerRequest();
         Test.stopTest();
        }
         static testMethod void accountChangeRequestTest4(){ 
          Test.startTest(); 
           setupTest(4);
           changeRequestController.changeOwnerRequest();
         Test.stopTest();
        }
         static testMethod void accountChangeRequestTest5(){ 
          Test.startTest(); 
           setupTest(5);
           changeRequestController.changeOwnerRequest();
           changeRequestController.returnToAccount();
         Test.stopTest();
         }
    // Test A&E User/non-Super User blocking
    static testMethod void testBlockOfAEUser() 
    {
        setupTest(6);
        
        Id aeProfileId = [select Id from Profile where Name = 'A&E User'][0].Id;
        Id aeSuperUserPermSetId = [select Id from PermissionSet where Name = 'A_E_Super_Users'][0].Id;
        
        List<User> testUsers = Core_Test_Utility.Core_User(2);
        testUsers[0].ProfileId = aeProfileId;
        testUsers[1].ProfileId = aeProfileId;
        insert testUsers;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = testUsers[1].Id, PermissionSetId = aeSuperUserPermSetId);
            insert psa;
        }
        
        // A&E User
        System.runAs(testUsers[0]) {
            changeRequestController.changeOwnerRequest();
        }
        System.assertNotEquals(testUsers[0].Id, [select OwnerId from Account][0].OwnerId);
        
        // A&E Super User
        System.runAs(testUsers[1]) {
            changeRequestController.changeOwnerRequest();
        }
        System.assertEquals(testUsers[1].Id, [select OwnerId from Account][0].OwnerId);
        
        changeRequestController.returnToAccount();
    }

    // Make sure a standard Sales Rep-BB change ownership still works
    static testMethod void testSalesRepBB() 
    {
        setupTest(7);
        
        User testUser = Core_Test_Utility.Core_User(1)[0];
        testUser.ProfileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        insert testUser;
        
        System.runAs(testUser) {
            changeRequestController.changeOwnerRequest();
        }
        System.assertEquals(testUser.Id, [select OwnerId from Account][0].OwnerId);
        
        changeRequestController.returnToAccount();
    }

}