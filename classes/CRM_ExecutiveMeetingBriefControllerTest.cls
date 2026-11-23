@isTest
public class CRM_ExecutiveMeetingBriefControllerTest {
    
    @testSetup
    static void setupTestData() { 
        List<Account> accountList;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        accountList[0].core_2023_Sales_Group__c = 'Americas US Sales Group';
        accountList[0].recordtypeID = accountRecordTypeIntel;
        insert accountList;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        LstAcc[0].core_2023_Sales_Group__c = 'Americas US Sales Group';
        lstAcc[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();  
        LstAcc[1].core_2023_Sales_Group__c = 'Americas US Sales Group';      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        Id profId = [select Id from Profile where Name='IT Admin' limit 1][0].Id;
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User 2', Email='test.user2@intel.com',
        Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User 3', Email='test.user3@intel.com',
        Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User 4', Email='test.user4@intel.com',
        Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user5.testOppApproverByManager@intel.com.crm', LastName='User 5', Email='test.user5@intel.com',
        Alias='tclass5', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user6.testOppApproverByManager@intel.com.crm', LastName='User 6', Email='test.user6@intel.com',
        Alias='tclass6', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user7.testOppApproverByManager@intel.com.crm', LastName='User 7', Email='test.user7@intel.com',
        Alias='tclass7', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        insert users;
        /* Create test data for User
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create test data for Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;*/
        
            
            Contact contactInstance = new Contact();
            contactInstance.FirstName = 'test';
            contactInstance.LastName = 'Contact xyz';
            contactInstance.email = 'test@test1.com';
            contactInstance.AccountId = accountList[0].id;
            contactInstance.MailingCountry = 'India';
            insert contactInstance;
		account acc = [select id,Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
        // Create test data for Executive_Meeting_Brief__c
        Executive_Meeting_Brief__c testMeetingBrief = new Executive_Meeting_Brief__c(
            CRM_Event_Engagement_Name__c = 'Test Event',
            //CRM_Scheduled_Start_Time__c = Date.today(),
            //CRM_Scheduled_End_Time__c = Date.today().addDays(1),
            Account__c = acc.id
        );
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert testMeetingBrief;}
    }

    @isTest
    static void testSaveMeetingBrief() {
        
        Map<String, Object> meetingBriefData = new Map<String, Object>{
            'CRM_Event_Engagement_Name__c' => 'Test Event',
            'CRM_Scheduled_Start_Time__c' => String.valueOf(Date.today()),
            'CRM_Scheduled_End_Time__c' => String.valueOf(Date.today().addDays(1))
        };

        Id meetingBriefId = CRM_ExecutiveMeetingBriefController.saveMeetingBrief(meetingBriefData, false, null);
        System.assertNotEquals(null, meetingBriefId, 'Meeting Brief should be saved successfully');
    }

    @isTest
    static void testGetUsers() {
        List<User> users = CRM_ExecutiveMeetingBriefController.getUsers();
        System.assert(users.size() > 0, 'Users should be returned');
    }

    @isTest
    static void testSearchContacts() {
        List<Contact> contacts = CRM_ExecutiveMeetingBriefController.searchContacts('Test');
        System.assert(contacts.size() > 0, 'Contacts should be returned');
    }

    @isTest
    static void testSearchUsers() {
        List<User> users = CRM_ExecutiveMeetingBriefController.searchUsers('Test');
        System.assert(users.size() > 0, 'Users should be returned');
    }

    @isTest
    static void testSearchAttendees() {
        List<User> users = CRM_ExecutiveMeetingBriefController.searchAttendees('CRM_Intel_Attendees__c', 'Test');
        //System.assert(users.size() > 0, 'Attendees should be returned');
    }

    @isTest
    static void testGetExecutiveMeetingBriefData() {
        Executive_Meeting_Brief__c meetingBrief = [SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1];
        Executive_Meeting_Brief__c result = CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData(meetingBrief.Id);
        System.assertNotEquals(null, result, 'Executive Meeting Brief should be returned');
    }

    @isTest
    static void testGetBaseUrl() {
        String baseUrl = CRM_ExecutiveMeetingBriefController.getBaseUrl();
        System.assertNotEquals(null, baseUrl, 'Base URL should be returned');
    }

    @isTest
    static void testUpdateMeetingBriefData() {
        Executive_Meeting_Brief__c meetingBrief = [SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1];
        Map<String, Object> meetingBriefData = new Map<String, Object>{
            'CRM_IntelAttendees__c' => 'Test Intel Attendees',
            'CRM_ExternalAttendees__c' => 'Test External Attendees'
        };
        CRM_ExecutiveMeetingBriefController.updateMeetingBriefData(meetingBriefData, meetingBrief.Id, 'Attendees');
        Executive_Meeting_Brief__c updatedMeetingBrief = [SELECT CRM_IntelAttendees__c, CRM_ExternalAttendees__c FROM Executive_Meeting_Brief__c WHERE Id = :meetingBrief.Id];
        System.assertEquals('Test Intel Attendees', updatedMeetingBrief.CRM_IntelAttendees__c, 'Intel Attendees should be updated');
        System.assertEquals('Test External Attendees', updatedMeetingBrief.CRM_ExternalAttendees__c, 'External Attendees should be updated');
    }
}