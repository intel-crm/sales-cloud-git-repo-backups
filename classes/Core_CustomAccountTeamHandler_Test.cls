@isTest
public class Core_CustomAccountTeamHandler_Test {
    
    static final String TEST_USER_EMAIL = 'test.user.03232016@example.com';
    static final String TEST_CONTACT_EMAIL = 'test.contact.03032016@example.com';
    
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='shareAccountMeetingBrief', Core_Object__c='Core_Account_Team__c', Core_Class_Name__c='Core_CustomAccountTeamHandler',
            Core_Trigger_Events__c='after insert, after delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        List<Account> lst = new List<Account>();
        lst.add(testAccount);
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email=TEST_CONTACT_EMAIL, AccountId=testAccount.Id);
        insert testContact;
        
        Account_Meeting_Brief__c brief = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Meeting_End_Time__c = '12:00 AM', Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c='3:00 am',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        insert brief;
        Core_CustomAccountTeamHandler.Insert_logexception(lst,'Exception Test');
        List<User> testUsers = new List<User>();
        //Below line added by Ankita Roy for US667275 - DEVELOPMENT ONLY : Security Scan Fixes - 3 for Avoid Calling SOQL and DML Inside Loops.
        Profile P =[select Id from Profile where Name = 'Sales Rep-BB' ];
        for (Integer i=1; i<5; i++) {
            //Commneted Below Line by Ankita Roy for US667275 - DEVELOPMENT ONLY : Security Scan Fixes - 3  for Avoiding Calling SOQL and DML Inside Loops.
            /*User testUser = new User(FirstName='Test', LastName='User '+i, UserName=TEST_USER_EMAIL+i+'.03232016.intel.crm',
                                     Email=TEST_USER_EMAIL, Alias='testusr'+i, CommunityNickName='test.user'+i+'.03232016',
                                     Profile P =[select Id from Profile where Name = 'Sales Rep-BB' ] ,
                                     LANGUAGELOCALEKEY='en_US', LOCALESIDKEY='en_US', TIMEZONESIDKEY='America/Los_Angeles',
                                     EMAILENCODINGKEY='ISO-8859-1', Core_Employee_Type_Code__c='NB');*/
            User testUser = new User(FirstName='Test', LastName='User '+i, UserName=TEST_USER_EMAIL+i+'.03232016.intel.crm',
                                     Email=TEST_USER_EMAIL, Alias='testusr'+i, CommunityNickName='test.user'+i+'.03232016',
                                     ProfileId = P.id ,
                                     LANGUAGELOCALEKEY='en_US', LOCALESIDKEY='en_US', TIMEZONESIDKEY='America/Los_Angeles',
                                     EMAILENCODINGKEY='ISO-8859-1', Core_Employee_Type_Code__c='NB');
            testUsers.add(testUser);
        }
        insert testUsers;
        
        Core_Account_Team__c testTeamMember1 = new Core_Account_Team__c(Core_Account__c = testAccount.Id, Core_Team_Member__c = testUsers[0].Id);
        Core_Account_Team__c testTeamMember4 = new Core_Account_Team__c(Core_Account__c = testAccount.Id, Core_Team_Member__c = testUsers[3].Id);
        insert testTeamMember1;
        insert testTeamMember4;
    }
    
    static testmethod void testAddingAccountTeamMembers() {
        Account testAccount = [select Id from Account limit 1][0];
        
        System.assertEquals(4, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
        
        User testUser2 = [select Id from User where FirstName = 'Test' and LastName = 'User 2' limit 1];
        User testUser3 = [select Id from User where FirstName = 'Test' and LastName = 'User 3' limit 1];
        List<Core_Account_Team__c> testTeamMembers = new List<Core_Account_Team__c>{
            new Core_Account_Team__c(Core_Account__c = testAccount.Id, Core_Team_Member__c = testUser2.Id),
            new Core_Account_Team__c(Core_Account__c = testAccount.Id, Core_Team_Member__c = testUser3.Id) };
        insert testTeamMembers;
        
        // Ensure Account Meeting Brief sharing records were added
        System.assertEquals(6, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
    }
    
    static testmethod void testRemovingAccountTeamMembers() {
        Account testAccount = [select Id from Account limit 1][0];
        
        System.assertEquals(4, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
        
        User testUser1 = [select Id from User where FirstName = 'Test' and LastName = 'User 1' limit 1];
        User testUser4 = [select Id from User where FirstName = 'Test' and LastName = 'User 4' limit 1];
        
        List<Core_Account_Team__c> testTeamMembers =[select Id from Core_Account_Team__c where Core_Account__c = :testAccount.Id
                                                     and (Core_Team_Member__c = :testUser1.Id or Core_Team_Member__c = :testUser4.Id)];
        delete testTeamMembers;
        
        // Ensure Account Meeting Brief sharing record was removed
       // System.assertEquals(2, [select count() from Account_Meeting_Brief__Share where Parent.Account__c = :testAccount.Id]);
    }
   
  
    
}