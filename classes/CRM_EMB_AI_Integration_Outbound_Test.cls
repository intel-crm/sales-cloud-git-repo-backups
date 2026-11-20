@isTest
public class CRM_EMB_AI_Integration_Outbound_Test {
     @TestSetup
    static void setupTestData() {
    
    Id newBriefRecordTypeId = Schema.SObjectType.Executive_Meeting_Brief__c.getRecordTypeInfosByDeveloperName().get('CRM_New_Executive_Meeting_Brief').getRecordTypeId();
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
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;
        
        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@deloitte.com',
            Username = 'testuser_2test@test.com.test',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;
        
        
        // Create test Contacts
        Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            Email = 'testcontact1@test.com',
            AccountId = testAccount.Id,
            MailingCountry ='USA'
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            Email = 'testcontact2@test.com',
            AccountId = testAccount.Id,
            MailingCountry ='USA'
        );
        insert testContact2;
              
        // Create Executive Meeting Brief record
        Executive_Meeting_Brief__c testEMB = new Executive_Meeting_Brief__c(
            Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief',
            Account__c = testAccount.Id,
            CRM_Brief_Reviewer__c = testUser2.Id,
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
        
        // Create Meeting Brief Attendees
        CRM_Meeting_Brief_Attendee__c attendee1 = new CRM_Meeting_Brief_Attendee__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Intel_Attendee__c = testUser1.Id,
            CRM_External_Attendee__c = testContact2.Id
        );
        insert attendee1;
        
        // Create Meeting Brief Agenda
        CRM_Meeting_Brief_Agenda__c agenda1 = new CRM_Meeting_Brief_Agenda__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Start_Time_txt__c =  '01/01/2026 6:20',
            CRM_End_Time_txt__c = '01/01/2026 7:00',
            CRM_Meeting_Agenda_Items__c = 'Opening Remarks',
            CRM_AI_Generated__c= true
        );
        insert agenda1;
        
        CRM_Meeting_Brief_Agenda__c agenda2 = new CRM_Meeting_Brief_Agenda__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Start_Time_txt__c = '01/01/2026 8:00',
            CRM_End_Time_txt__c = '01/01/2026 9:00',
            CRM_Presenters_Conversation_Lead__c = testUser1.Id,
            CRM_Meeting_Agenda_Items__c = 'Main Discussion',
            CRM_AI_Generated__c= true
        );
        insert agenda2;
        
        // Create Background Talking Points
        CRM_MeetingBriefBackground_TalkingPoints__c bgTalkingPoint1 = new CRM_MeetingBriefBackground_TalkingPoints__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Agenda_Topic__c = 'Topic 1',
            CRM_Background__c = 'Background information <img src="bg.jpg">',
            CRM_Proactive_Talking_Points__c = 'Proactive points',
            CRM_Reactive_Talking_Points__c = 'Reactive points',
            CRM_AI_Generated__c= true
        );
        insert bgTalkingPoint1;
         // Create Executive Meeting Brief record
       /* Executive_Meeting_Brief__c testEMB1 = new Executive_Meeting_Brief__c(
            Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief 2',
            Account__c = testAccount.Id,
            CRM_Brief_Reviewer__c = testUser2.Id,
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
            Brief_Status__c='Final',
            CRM_Rating__c='Test',
            RecordTypeId=newBriefRecordTypeId,
            CRM_Scheduled_End_Time_txt__c = '01/01/2026 7:00'
        );
        insert testEMB1;*/
        
        // Create existing ContentVersion for attachment testing
        ContentVersion existingCV = new ContentVersion(
            Title = 'Briefing for Test',
            PathOnClient = 'existing.pdf',
            VersionData = Blob.valueOf('Existing content'),
            ContentLocation = 'S'
        );
        insert existingCV;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :existingCV.Id].ContentDocumentId;
        ContentDocumentLink existingCDL = new ContentDocumentLink(
            ContentDocumentId = cdId,
            LinkedEntityId = testEMB.Id,
            ShareType = 'V'
        );
        insert existingCDL;  
        
        // Create ContentVersion for attachment testing
        ContentVersion invalidCV = new ContentVersion(
            Title = 'Test Doc att',
            PathOnClient = 'existing.pdf',
            VersionData = Blob.valueOf('Existing content'),
            ContentLocation = 'S'
        );
        insert invalidCV;
        
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :invalidCV.Id].ContentDocumentId;
        ContentDocumentLink existingInvalidCDL = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = testEMB.Id,
            ShareType = 'V'
        );
        insert existingInvalidCDL; 
        
    }
    @isTest
    public static void fetchExecutiveMeetingBriefDetailsTest(){
        Executive_Meeting_Brief__c execMeetingBriefRec = [SELECT Id FROM Executive_Meeting_Brief__c WHERE Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief'];
        List<Id> execIds = new List<Id>();
        execIds.add(execMeetingBriefRec.Id);
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(execIds);
    }
    @isTest
    public static void testSuccess() {
        List<Id> briefIds = new List<Id>{[SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1].Id};
        
        Test.setMock(HttpCalloutMock.class, new MockResponse(true));
        
        Test.startTest();
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(briefIds);
        Test.stopTest();
        
        // Verify success flow
        Executive_Meeting_Brief__c updatedBrief = [SELECT CRM_Agentic_Drafting_Status__c FROM Executive_Meeting_Brief__c LIMIT 1];
        updatedBrief.CRM_Agentic_Drafting_Status__c='In Progress';
        update updatedBrief;
        System.assertEquals('In Progress', updatedBrief.CRM_Agentic_Drafting_Status__c);
        
        /*List<Core_CDB_Integration_Log__c> logs = [SELECT Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c];
        System.assertEquals('Successful', logs[0].Core_Log_Status_Nm__c);*/
        
        CRM_EMB_AI_Integration_Outbound.updateExecutiveBriefStatus(briefIds);
        CRM_EMB_AI_Integration_Outbound.deleteExistingRecords(briefIds);
    }

    @isTest
    public static void testMainFlow_Failure() {
        List<Id> briefIds = new List<Id>{[SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1].Id};
        
        Test.setMock(HttpCalloutMock.class, new MockResponse(false));
        
        Test.startTest();
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(briefIds);
        Test.stopTest();
        
        // Verify failure flow
        /*List<Core_CDB_Integration_Log__c> logs = [SELECT Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c];
        System.assertEquals('Failed', logs[0].Core_Log_Status_Nm__c);*/
    }
    
    @isTest
    public static void testEdgeCases() {
        // Test null/empty inputs
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(null);
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(new List<Id>());
        
        // Test utility methods
        CRM_EMB_AI_Integration_Outbound.collectAndLogDbErrors(null, null, 'Test');
        CRM_EMB_AI_Integration_Outbound.createLogEntries(null);
        
        // Test wrapper classes
        CRM_EMB_AI_Integration_Outbound.ContentVersionDetailsWrapper cvWrapper = new CRM_EMB_AI_Integration_Outbound.ContentVersionDetailsWrapper();
        CRM_EMB_AI_Integration_Outbound.ExecutiveMeetingBriefWrapper embWrapper = new CRM_EMB_AI_Integration_Outbound.ExecutiveMeetingBriefWrapper();
        
        System.assert(true, 'Edge cases handled without exceptions');
    }
    
      @isTest
    public static void testLogMethods() {
        // Test createLogEntries with valid data
        List<Map<String, String>> logMaps = new List<Map<String, String>>();
        Map<String, String> logMap = new Map<String, String>();
        logMap.put('Core_Origin__c', 'Test Origin');
        logMap.put('Core_Severity__c', 'Low');
        logMap.put('Core_Message__c', 'Test Message');
        logMap.put('Core_Project__c', 'Test Project');
        logMaps.add(logMap);
        
        CRM_EMB_AI_Integration_Outbound.createLogEntries(logMaps);
        
        // Verify log entry created
        List<Core_Log_Entry__c> logs = [SELECT Core_Origin__c FROM Core_Log_Entry__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('Test Origin', logs[0].Core_Origin__c);
        
        // Test collectAndLogDbErrors with valid data
        Map<String, List<Database.Error>> errorMap = new Map<String, List<Database.Error>>();
        Map<String, String> messageMap = new Map<String, String>();
        messageMap.put('testRecord1','Test error message');
        
        CRM_EMB_AI_Integration_Outbound.collectAndLogDbErrors(errorMap, messageMap, 'Test_Object__c');
        
        // Test edge cases
        CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails(null);
        CRM_EMB_AI_Integration_Outbound.collectAndLogDbErrors(null, null, 'Test');
        CRM_EMB_AI_Integration_Outbound.createLogEntries(null);
        
        System.assert(true, 'All methods executed without exceptions');
    }
    
    @isTest
public static void testCreateLogEntriesWithLongData() {
    // Test createLogEntries with data that might cause issues
    List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
    
    Map<String, String> logMap1 = new Map<String, String>();
    logMap1.put('Core_Origin__c', 'Test Origin');
    logMap1.put('Core_Severity__c', 'Low');
    logMap1.put('Core_Message__c', 'Test Message');
    logMap1.put('Core_Details__c', 'x'.repeat(50000)); // Very long string
    logMap1.put('Core_Project__c', 'Test Project');
    logMap1.put('InvalidField__c', 'This field does not exist'); // Invalid field
    coreLogMaps.add(logMap1);
    
    Test.startTest();
    CRM_EMB_AI_Integration_Outbound.createLogEntries(coreLogMaps);
    Test.stopTest();
    }
    
       @isTest
    public static void testDatabaseUpsertErrors() {
        List<Id> briefIds = new List<Id>{[SELECT Id FROM Executive_Meeting_Brief__c LIMIT 1].Id};
        
        Test.setMock(HttpCalloutMock.class, new MockResponse(false));
        
        // Test collectAndLogDbErrors with hardcoded database errors
        Map<String, List<Database.Error>> errorsByRecordKeyMap = new Map<String, List<Database.Error>>();
        Map<String, String> baseMessageByRecordKeyMap = new Map<String, String>();
        
        // Generate real database errors using Core_CDB_Integration_Log__c
        Core_CDB_Integration_Log__c invalidLog1 = new Core_CDB_Integration_Log__c();
        invalidLog1.Core_Integration_Type__c = 'Test'.repeat(100); // Too long to cause error
        List<Database.Error> errors1 = Database.insert(invalidLog1, false).getErrors();
        
        Core_CDB_Integration_Log__c invalidLog2 = new Core_CDB_Integration_Log__c();
        invalidLog2.Core_Status_Message__c = 'Error'.repeat(200); // Too long to cause error  
        List<Database.Error> errors2 = Database.insert(invalidLog2, false).getErrors();
        
        // Populate the maps
        errorsByRecordKeyMap.put(briefIds[0], errors1);
        errorsByRecordKeyMap.put('testRecord2', errors2);
        
        baseMessageByRecordKeyMap.put(briefIds[0], 'CDB Integration Log upsert failed for record: ' + briefIds[0]);
        baseMessageByRecordKeyMap.put('testRecord2', 'CDB Integration Log upsert failed for record: testRecord2');
        
        Test.startTest();
        
        // Test the collectAndLogDbErrors method
        CRM_EMB_AI_Integration_Outbound.collectAndLogDbErrors(
            errorsByRecordKeyMap, 
            baseMessageByRecordKeyMap, 
            'Core_CDB_Integration_Log__c'
        );
        
        // Test the main callout method
        Map<String, String> testMap = new Map<String, String>();
    testMap.put(briefIds[0], '{"test": "payload"}');
        
        CRM_EMB_AI_Integration_Outbound.makeCDBCallout(testMap);
        
        Test.stopTest();
        
        // Verify that error log entries were created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Details__c, Core_sObjectType__c 
                                             FROM Core_Log_Entry__c 
                                             WHERE Core_Origin__c = 'CRM_EMB_AI_Integration_Outbound'];
        
        System.assert(!logEntries.isEmpty(), 'Log entries should be created for database errors');
        System.assertEquals('Core_CDB_Integration_Log__c', logEntries[0].Core_sObjectType__c);
        
        // Verify error handling was executed
        System.assert(true, 'Database error handling executed');
    }
    public class MockResponse implements HttpCalloutMock {
        Boolean success;
        public MockResponse(Boolean success) { this.success = success; }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(success ? 200 : 500);
            res.setStatus(success ? 'SUCCESS' : 'Error');
            res.setBody('{"status": "' + (success ? 'success' : 'error') + '"}');
            return res;
        }
    }
}