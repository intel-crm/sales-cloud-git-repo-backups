@isTest
public class CRM_ExecutiveMeetingBriefUtility_Test {
	@isTest
    public static void checkMandatoryFields() {
        
        // Create the custom setting record
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.Name = 'CRM_EMB_Sharing';
        triggerSetting.Core_Active__c = true;
        triggerSetting.Core_Class_Name__c = 'CRM_ExecutiveMeetingBriefUtility';
        triggerSetting.Core_Description__c = 'Test';
        triggerSetting.Core_Object__c = 'Executive_Meeting_Brief__c';
        triggerSetting.Core_Trigger_Events__c = 'After Update';
        insert triggerSetting;
         
        // Create test Account
 		Account testAccount = new Account();
        testAccount.name = 'TestAccount';
        testAccount.BillingCountryCode = 'USA';
        testAccount.BIllingStateCode = 'AL';
        testAccount.BillingCity = 'Alabama';
        testAccount.BillingStreet = 'test';   //'Americas ELAR Sales Group'; 
        testAccount.Industry = 'Agriculture';
        testAccount.Core_Sub_Industry__c = 'Forestry';
        testAccount.BillingPostalCode ='12345';
        insert testAccount;
        
        // Create test Users for relationships
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@deloitte.com',
            Username = 'testuser_1test@test.com.test',
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-BB' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;
      
       User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@deloitte.com',
            Username = 'testuser_21test@test.com.test',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;
        User testUser3 = new User(
            FirstName = 'Test',
            LastName = 'User31',
            Email = 'testembuser31@example.com',
            Username = 'testembuser_31test@example.com',
            Alias = 'tuser3',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser3;
        
        User testUser4 = new User(
            FirstName = 'Test',
            LastName = 'User411',
            Email = 'testuser411@example.com',
            Username = 'testuser_411test@example.com',
            Alias = 'tuser4',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser4;
        
        // Create Executive Meeting Brief record
        Executive_Meeting_Brief__c testEMB = new Executive_Meeting_Brief__c(
            Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief',
            Account__c = testAccount.Id,
            CRM_Intels_Meeting_Objectives__c = 'Test Intel Objectives <img src="test.jpg"> with image',
            CRM_Most_Critical_Messages_to_Get_Across__c = 'Critical Messages; Second Message; Third Message',
            CRM_Other_Partys_Meeting_Objectives__c = 'Other Party Objectives',
            Industry_Insights_Political_Climate__c = 'Political Climate Info',
            How_They_Buy_Sell__c = 'Buy/Sell Information',
            CRM_Investor_Scouting_Report__c = 'Investor Report',
            CRM_Additional_Legal_Guidance__c = 'Legal Guidance',
            CRM_Attendee_Bio_s__c = 'Attendee Bios',
            CRM_Dress_Code__c = 'Business Casual',
            CRM_Scheduled_Start_Time_txt__c = '01/01/2026 6:00',
            CRM_Scheduled_End_Time_txt__c = '01/01/2026 7:00'         
        );
        insert testEMB;

		Executive_Meeting_Brief__c embRec = [SELECT Id, CRM_Technical_Assistant__c, CRM_Brief_Reviewer__c FROM Executive_Meeting_Brief__c WHERE Id =: testEMB.Id];
        
        testEMB.CRM_Technical_Assistant__c = testUser1.Id;
        testEMB.CRM_Brief_Reviewer__c = testUser3.Id;
        update testEMB;
        
        testEMB.CRM_Technical_Assistant__c = testUser1.Id;
        testEMB.CRM_Brief_Reviewer__c = testUser4.Id;
        update testEMB;
        
        // The query will work if the CMT record exists in your org
        Test.startTest();
        
        CRM_EMB_Required_Fields__mdt metadata = [SELECT Required_Fields__c FROM CRM_EMB_Required_Fields__mdt WHERE DeveloperName = 'CRM_EMB_Mandatory_Fields' LIMIT 1];
        
        
         CRM_ExecutiveMeetingBrief_Utility.checkMandatoryFields(testEMB.Id);
        
         Test.stopTest();
        
    }
    @isTest
    public static void testSendEmailFromTemplate(){
        User sysUser = new User(
            FirstName = 'Test',
            LastName = 'Sys User 1',
            Email = 'testsysuser1@example.com',
            Username = 'testsysuser123@example.com',
            Alias = 'tusersys',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert sysUser;
        
      // Create test email template
        EmailTemplate testTemplate = new EmailTemplate(
            Name = 'Test Template',
            DeveloperName = 'Test_Template',
            TemplateType = 'Text',
            FolderId = UserInfo.getOrganizationId(),
            Subject = 'Test Subject',
            Body = 'Test Body Content'
        );
      System.runAs(sysUser){
      
        insert testTemplate;
      }
        
        // Create test Account
 		Account testAccount = new Account();
        testAccount.name = 'TestAccount';
        testAccount.BillingCountryCode = 'USA';
        testAccount.BIllingStateCode = 'AL';
        testAccount.BillingCity = 'Alabama';
        testAccount.BillingStreet = 'test';   //'Americas ELAR Sales Group'; 
        testAccount.Industry = 'Agriculture';
        testAccount.Core_Sub_Industry__c = 'Forestry';
        testAccount.BillingPostalCode ='12345';
        insert testAccount;
        
        // Create Executive Meeting Brief record
        Executive_Meeting_Brief__c testEMBRec = new Executive_Meeting_Brief__c(
            Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief',
            Account__c = testAccount.Id,
            CRM_Intels_Meeting_Objectives__c = 'Test Intel Objectives <img src="test.jpg"> with image',
            CRM_Most_Critical_Messages_to_Get_Across__c = 'Critical Messages; Second Message; Third Message',
            CRM_Other_Partys_Meeting_Objectives__c = 'Other Party Objectives',
            Industry_Insights_Political_Climate__c = 'Political Climate Info',
            How_They_Buy_Sell__c = 'Buy/Sell Information',
            CRM_Investor_Scouting_Report__c = 'Investor Report',
            CRM_Additional_Legal_Guidance__c = 'Legal Guidance',
            CRM_Attendee_Bio_s__c = 'Attendee Bios',
            CRM_Dress_Code__c = 'Business Casual',
            CRM_Scheduled_Start_Time_txt__c = '01/01/2026 6:00',
            CRM_Scheduled_End_Time_txt__c = '01/01/2026 7:00'           
        );
        insert testEMBRec;
        
        // Get test EMB record
        Executive_Meeting_Brief__c testEMB = [SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1];
        
        // Create test content for attachment
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Briefing for Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        
         // Test Case 1: Success with attachment
        CRM_ExecutiveMeetingBrief_Utility.EmailRequest emailRequest1 = new CRM_ExecutiveMeetingBrief_Utility.EmailRequest();
        emailRequest1.emailAddress = 'test1@example.com';
        emailRequest1.emailTemplateId = testTemplate.Id;
        emailRequest1.whatId = testEMB.Id;
        
        
         List<CRM_ExecutiveMeetingBrief_Utility.EmailRequest> requests = new List<CRM_ExecutiveMeetingBrief_Utility.EmailRequest>{emailRequest1};
            
         Test.startTest();
    
        // Call the method
        List<CRM_ExecutiveMeetingBrief_Utility.EmailResult> results = CRM_ExecutiveMeetingBrief_Utility.sendEmailFromTemplate(requests);
        
        Test.stopTest();

    }
}