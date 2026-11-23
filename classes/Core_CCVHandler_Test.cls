/****************************************************************************************************
Apex Class Name : Core_CCVHandler_Test
Version         : 1.0 
Created Date    : 2/9/15
Function        : Test class for CCV Trigger functions
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              2/9/15             Original Version
*****************************************************************************************************/
@
isTest
private class Core_CCVHandler_Test {

    static final integer ACCOUNT_COUNT   = 5;
    static final integer VALUE_MAP_COUNT = 3;
    
    static List<Account> accountList;

    static void setupTest()
    {
        List<User> ccvUserList = Core_Test_Utility.Core_User(1);
        User ccvUser = ccvUserList[0];
        insert ccvUser;
        
        accountList = Core_Test_Utility.createAccount(ACCOUNT_COUNT);
        
        for (Account account : accountList)
        { 
            insert account;    
            
            AccountTeamMember atm = new AccountTeamMember(AccountId=account.Id, UserId=ccvUser.Id, TeamMemberRole='TeamMember');
            insert atm;
        }
    }


    static testMethod void Core_CCVHandler_Test_1() 
    {    
        setupTest();
        Test.startTest();
        
        for (Account account : accountList)
        {             
            Core_CCV__c ccv = new Core_CCV__c(Core_Account__c=account.Id);
            insert ccv;            
        }
     
        Test.stopTest();
        
        List<Core_Value_Map__c> listValueMap = [SELECT Id FROM Core_Value_Map__c];
        //System.assertEquals(listValueMap.size(), ACCOUNT_COUNT * VALUE_MAP_COUNT);
        
        List<Core_CCV__Share> listCCVShare = [SELECT Id, ParentId, UserOrGroupId FROM Core_CCV__Share];
        for (Core_CCV__Share ccvShare : listCCVShare)
            System.debug('Sharing Id: ' + ccvShare.Id + '  ParentId: ' + ccvShare.ParentId + '  UserOrGroupId: ' + ccvShare.UserOrGroupId); 
              
        // One share for the owner, one for the team member.      
      //  System.assertEquals(listCCVShare.size(), ACCOUNT_COUNT * 2);
               
    }
    
    
    static testMethod void Core_CCVHandler_Test_2() 
    {    
        setupTest();
        Test.startTest();
        
        for (Account account : accountList)
        {             
            Core_CCV__c ccv = new Core_CCV__c(Core_Account__c=account.Id);
            insert ccv;   
                      
            Core_Value_Map__c vm = new Core_Value_Map__c(Core_CCV__c=ccv.Id, Core_Customer_Value__c='1 - High');  
            update ccv;       
        }
        
        Test.stopTest();
        
        List<Core_Value_Map__c> listValueMap = [SELECT Id FROM Core_Value_Map__c];
       // System.assertEquals(listValueMap.size(), ACCOUNT_COUNT * VALUE_MAP_COUNT);
        
        List<Core_CCV__Share> listCCVShare = [SELECT Id, ParentId, UserOrGroupId FROM Core_CCV__Share];
        for (Core_CCV__Share ccvShare : listCCVShare)
            System.debug('Sharing Id: ' + ccvShare.Id + '  ParentId: ' + ccvShare.ParentId + '  UserOrGroupId: ' + ccvShare.UserOrGroupId); 
              
        // One share for the owner, one for the team member.      
      //  System.assertEquals(listCCVShare.size(), ACCOUNT_COUNT * 2);
               
    }
    
    
    static testMethod void Core_CCVHandler_Test_3() 
    {    
        setupTest();
        Test.startTest();
        
        Core_CCVHandler.valueMapBypass = true;
        
        for (Account account : accountList)
        {             
            Core_CCV__c ccv = new Core_CCV__c(Core_Account__c=account.Id);
            insert ccv;                         
        }
        
        Test.stopTest();
        
        List<Core_Value_Map__c> listValueMap = [SELECT Id FROM Core_Value_Map__c];
       // System.assertEquals(listValueMap.size(), 0);
        
        List<Core_CCV__Share> listCCVShare = [SELECT Id, ParentId, UserOrGroupId FROM Core_CCV__Share];
        for (Core_CCV__Share ccvShare : listCCVShare)
            System.debug('Sharing Id: ' + ccvShare.Id + '  ParentId: ' + ccvShare.ParentId + '  UserOrGroupId: ' + ccvShare.UserOrGroupId); 
              
        // One share for the owner, one for the team member.      
        //System.assertEquals(listCCVShare.size(), ACCOUNT_COUNT * 2);
               
    }
}