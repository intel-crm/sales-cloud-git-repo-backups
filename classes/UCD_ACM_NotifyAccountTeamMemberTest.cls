@isTest
private with sharing class UCD_ACM_NotifyAccountTeamMemberTest {
    @testSetup
    static void dataSetUp() {
        Core_Account_Bypass_Validation_Rule__c bypass= new Core_Account_Bypass_Validation_Rule__c();
        bypass.ByPass__c = true;
        bypass.SetupOwnerId = UserInfo.getOrganizationId();
        INSERT bypass;

        User user1 = New User();
        user1.Alias = 'tu1';
        user1.Email='testUser1@intel.com';
        user1.EmailEncodingKey='UTF-8';
        user1.LastName='Test User';
        user1.LocaleSidKey='en_US';
        user1.ProfileId = [Select Id from Profile Where Name = 'It Admin'].Id;
        user1.TimeZoneSidKey='America/Los_Angeles';
        user1.UserName='testUser1@testorg.com.intel';
        user1.LanguageLocaleKey = 'en_US'; 
        user1.IsActive = false;
        
        
        User user2 = New User();
        user2.Alias = 'tu2';
        user2.Email='testUser2@intel.com';
        user2.EmailEncodingKey='UTF-8';
        user2.LastName='Test User';
        user2.LocaleSidKey='en_US';
        user2.ProfileId = [Select Id from Profile Where Name = 'It Admin'].Id;
        user2.TimeZoneSidKey='America/Los_Angeles';
        user2.UserName='testUser2@testorg.com.intel';
        user2.LanguageLocaleKey = 'en_US';   
        INSERT new List<User>{user1, user2};
            
        Account acc1 = new Account();
        acc1.Name = 'Test account 1';
        acc1.OwnerId = user1.Id;
        acc1.billingCountry = 'India';
        acc1.BillingCity = 'Bangalore';
        
        Account acc2 = new Account();
        acc2.Name = 'Test account 2';
        acc2.OwnerId = user1.Id;
        acc2.BillingCountry = 'India';
        acc2.BillingCity = 'Bangalore';
        
        INSERT new List<Account>{acc1, acc2};
            
        AccountTeamMember atm1 = New AccountTeamMember();
        atm1.accountId = acc1.Id;
        atm1.TeamMemberRole = 'Team Member';
        atm1.userId = user2.Id;
        
        AccountTeamMember atm2 = New AccountTeamMember();
        atm2.accountId = acc2.Id;
        atm2.TeamMemberRole = 'Team Member';
        atm2.userId = user2.Id;
        
        INSERT new List<AccountTeamMember>{atm1, atm2};

    }
    
    @isTest
    private static void accountOwnerChangeTest() {
        Id userId = [Select Id from User Where Email = 'testUser1@intel.com'].Id;
        UCD_ACM_NotifyAccountTeamMember.getAccountTeamMembers(new List<Id>{userId});
    }
}