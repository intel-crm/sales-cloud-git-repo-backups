@isTest
public class Core_CampaignMemberInfoLookup_Test {
    
    static final String TEST_CAMPAIGN_NAME = 'Test Campaign';
    static final String TEST_CONTACT_EMAIL = 'test.contact.03032016@example.com';
    static final String TEST_USER_EMAIL = 'test.user.03032016@example.com';
    
    @testSetup
    static void setupTestData() {        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='assignToUserLookup', Core_Object__c='CampaignMember', Core_Class_Name__c='Core_CampaignMemberHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        Campaign testCampaign = new Campaign(Name=TEST_CAMPAIGN_NAME, Description='Test', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1));
        insert testCampaign;
        
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email=TEST_CONTACT_EMAIL, AccountId=testAccount.Id);
        insert testContact;
        
        User testUser = new User(FirstName='Test', LastName='User', UserName=TEST_USER_EMAIL+'.03032016.intel.crm',
                                 Email=TEST_USER_EMAIL, Alias='testuser', CommunityNickName='test.user.03032016',
                                 ProfileId=[select Id from Profile where Name = 'Vendor Sales Center - Agent' limit 1].Id,
                                 LANGUAGELOCALEKEY='en_US', LOCALESIDKEY='en_US', TIMEZONESIDKEY='America/Los_Angeles',
                                 EMAILENCODINGKEY='ISO-8859-1', Core_Employee_Type_Code__c='NB');
        insert testUser;
    }
    
    testMethod static void testInsertLookup() {
        Contact testContact = [select Id from Contact where Email = :TEST_CONTACT_EMAIL];
        Campaign testCampaign = [select Id from Campaign where Name = :TEST_CAMPAIGN_NAME];
        User testUser = [select Id, Email from User where Email = :TEST_USER_EMAIL];
        
        CampaignMember campMemberBasicTest = new CampaignMember(CampaignId=testCampaign.Id, ContactId=testContact.Id,
                                                                Core_Assigned_To_User_Email__c=testUser.Email, Core_Assigned_To_User_ID__c='');
        insert campMemberBasicTest;
        
        campMemberBasicTest = [select Id, Core_Assigned_To_User_ID__c from CampaignMember
                               where CampaignId = :testCampaign.Id and ContactId = :testContact.Id];
        System.assertEquals(testUser.Id, campMemberBasicTest.Core_Assigned_To_User_ID__c);
    } 

}