/****************************************************************************************************
Apex Class Name : Core_Account_330_URL_Test
Version         : 1.0 
Created Date    : 01/16/15
Function        : Test class for Account 330 VForce Page controller
                  current owner.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              01/16/2015             Original Version
*****************************************************************************************************/
@
isTest(SeeAllData=true)
private class Core_Account_330_URL_Test {

    static Account account;
    static ApexPages.StandardController accountController;
    static Core_Account_330_URL newController;

    static void setupTest(String cpmId, Id acctOwnerId)
    {    
        List<Account> acctList = Core_Test_Utility.createAccount(1);            
        account                = acctList[0];
        account.Core_CPM_ID__c = cpmId; 
        account.OwnerId        = acctOwnerId;
        insert account;
        
        System.debug('#27 acctOwnerId: '     + acctOwnerId);
        System.debug('#28 account.OwnerId: ' + account.OwnerId);

        accountController = new ApexPages.StandardController(account);
        newController     = new Core_Account_330_URL(accountController);
    }


    // Single CPM ID
    static testMethod void account330URLTest() 
    {    
        setupTest('90009999', UserInfo.getUserId());
        
        // Start testing the functionality
        Test.startTest();
        
        newController.loadSalesUnits();
        newController.loadSalesRevenue(); 
        newController.loadProductUnits();
        newController.loadProductRevenue();  
        newController.loadBrandedUnits(); 
        newController.loadBrandedRevenue(); 
        newController.loadMembership();
                        
        Test.stopTest();

    }
    
    // Blank CPM ID
    static testMethod void account330URLBlankCPMID() 
    {    
        setupTest('', UserInfo.getUserId());
        newController.iframeSource = '';
    }    
    
    // Multiple CPM ID
    static testMethod void account330URLTestMulti() 
    {    
        setupTest('90009999,10003171,10003172', UserInfo.getUserId());
    }    
    
    static testMethod void account330URLAccessCheck_02() 
    {   
        List<User> newUserList = Core_Test_Utility.Core_User(1); 
        User newUser           = newUserList[0];
        insert newUser;
    
        Id currentUserId = UserInfo.getUserId();
    
        System.runAs(newUser)
        {        
            setupTest('90009999,10003171,10003172', currentUserId);                 
            
            AccountTeamMember atm = new AccountTeamMember(AccountId=account.Id, UserId=newUser.Id);  
            insert atm;
                      
            newController = new Core_Account_330_URL(accountController);
        }
    }    

}