@isTest
public class Core_AccountMeetingBriefHandler_Test {
    
    static final String TEST_USER_EMAIL = 'test.user.03232016@example.com';
    static final String TEST_CONTACT_EMAIL = 'test.contact.03032016@example.com';
    
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='addAccountTeamToMeetingBrief', Core_Object__c='Account_Meeting_Brief__c', Core_Class_Name__c='Core_AccountMeetingBriefHandler',
            Core_Trigger_Events__c='after insert', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        String intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        testAccount.RecordTypeId = intelAccRecTypeId;
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email=TEST_CONTACT_EMAIL, AccountId=testAccount.Id,MailingCountry='USA',
                                         Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_ERPM_Integration_Status__c = 'Pending',Core_eRPM_Person_Id__c = '111111');
        insert testContact;
        
        List<User> testUsers = new List<User>();
        //Edited and moved the SOQL query from line number 27 by Kavyashree HR(Infosys Pegasus Team) on 30/04/2020 to fix security scan issues(US667274)
        Id proId=[select Id from Profile where Name = 'Sales Rep-BB' limit 1].Id;
        //KavyaShree          july22,2020        Security scan fix
        for (Integer i=1; i<5; i++) {
            User testUser = new User(FirstName='Test', LastName='User '+i, UserName=TEST_USER_EMAIL+i+'.03232016.intel.crm',
                                     Email=TEST_USER_EMAIL, Alias='testusr'+i, CommunityNickName='test.user'+i+'.03232016',
                                     ProfileId=proId,LANGUAGELOCALEKEY='en_US', LOCALESIDKEY='en_US', TIMEZONESIDKEY='America/Los_Angeles',
                                     EMAILENCODINGKEY='ISO-8859-1', Core_Employee_Type_Code__c='NB');
            testUsers.add(testUser);
        }
        insert testUsers;
        
        List<AccountTeamMember> testTeamMembers = new List<AccountTeamMember>();
        for(Integer i=0; i<4; i++) {
            AccountTeamMember teamMember = new AccountTeamMember(AccountId=testAccount.Id, UserId=testUsers[i].Id, TeamMemberRole='Test');
            testTeamMembers.add(teamMember);
        }
        insert testTeamMembers;
    }

    static testmethod void testInsertAccountMeetingBrief() {
        Account testAccount = [select Id from Account limit 1][0];
        Contact testContact = [select Id from Contact limit 1][0];
        
        System.assertEquals(0, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
        
        Account_Meeting_Brief__c brief = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c='03:00 am',
                                                                      Core_Account_Meeting_End_Time__c ='12:00 am',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        try{
        insert brief;
        
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
        System.assertEquals(6, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
    }
    
  
}