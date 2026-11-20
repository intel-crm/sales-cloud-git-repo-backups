@isTest
public class CRM_GeneratePDF_EMBController_Test {
     @TestSetup
    static void setupTestData() {
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
            CRM_Start_Time_txt__c =  '01/01/2026 6:00',
            CRM_End_Time_txt__c = '01/01/2026 6:40',
            CRM_Meeting_Agenda_Items__c = 'Opening Remarks'
        );
        insert agenda1;
        
        CRM_Meeting_Brief_Agenda__c agenda2 = new CRM_Meeting_Brief_Agenda__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Start_Time_txt__c = '01/01/2026 5:00',
            CRM_End_Time_txt__c = '01/01/2026 6:50',
            CRM_Presenters_Conversation_Lead__c = testUser1.Id,
            CRM_Meeting_Agenda_Items__c = 'Main Discussion'
        );
        insert agenda2;
        
        // Create Background Talking Points
        CRM_MeetingBriefBackground_TalkingPoints__c bgTalkingPoint1 = new CRM_MeetingBriefBackground_TalkingPoints__c(
            CRM_Executive_Meeting_Brief__c = testEMB.Id,
            CRM_Agenda_Topic__c = 'Topic 1',
            CRM_Background__c = 'Background information <img src="bg.jpg">',
            CRM_Proactive_Talking_Points__c = 'Proactive points',
            CRM_Reactive_Talking_Points__c = 'Reactive points'
        );
        insert bgTalkingPoint1;
        
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
    }
    
    @isTest
    static void testPDFGenerationAndFileAttachment() {
        Executive_Meeting_Brief__c testEMB = [SELECT Id, Core_Executive_Meeting_Brief_Name__c FROM Executive_Meeting_Brief__c WHERE Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief' LIMIT 1];
        
        Test.startTest();
        
        // Set up page parameters
        PageReference pageRef = Page.CRM_GeneratePDF_EMB;
        pageRef.getParameters().put('id', testEMB.Id);
        Test.setCurrentPage(pageRef);
        
        // Create controller instance
        CRM_GeneratePDF_EMBController controller = new CRM_GeneratePDF_EMBController();
        
        Test.stopTest();
        
        String sampleBase64 = CRM_GeneratePDF_EMBController.getPdfBase64(testEMB.Id);
        
        CRM_GeneratePDF_EMBController.attachFiletoExecutiveMeetingBrief(testEMB.Id, sampleBase64);
        String reduceSize = '<table><tbody><tr><td><p style="margin: 0in; font-size: 11.0pt; color: black;"><span style="font-weight: bold;">Fiel</span></p></td><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 4.8625in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;"><span style="font-weight: bold;">Description</span></p></td></tr><tr><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 1.7354in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;">EventEngagement Name</p></td><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 4.9125in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;">Theofficial title of the meeting. A short, descriptive phrase that isrecognizable. </p></td></tr></tbody></table>';
        
        CRM_GenerateWord_EMBController.reduceSizeForWordForWord(reduceSize);
        }
        @isTest
    static void testWordGenerationAndFileAttachment() {
        Executive_Meeting_Brief__c testEMB = [SELECT Id, Core_Executive_Meeting_Brief_Name__c FROM Executive_Meeting_Brief__c WHERE Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief' LIMIT 1];
        
        Test.startTest();
        
        // Set up page parameters
        PageReference pageRef = Page.CRM_GenerateWord_EMB;
        pageRef.getParameters().put('id', testEMB.Id);
        Test.setCurrentPage(pageRef);
        
        // Create controller instance
        CRM_GenerateWord_EMBController controller = new CRM_GenerateWord_EMBController();
        
        
        
        Id ContentID = CRM_GenerateWord_EMBController.generateWordAndCreateFile(testEMB.Id);
       
        String originalUrl =
            'https://intel--crmdevsls3.sandbox.file.force.com/servlet/rtaImage?' +
            'eid=' + testEMB.Id +
            '&refid=0EMWA000000wNM1';

        Test.setMock(HttpCalloutMock.class, new CRM_FetchImageCalloutMockTest());
        STring frmtSTring1 = CRM_GenerateWord_EMBController.convertImageToDataURI(originalUrl,'CRM_Attendee_Bio_s__c','Executive_Meeting_Brief__c');
        STring frmtSTring = CRM_GenerateWord_EMBController.fetchImageAsBase64(originalUrl,'CRM_Attendee_Bio_s__c','Executive_Meeting_Brief__c');

        String reduceSize = '<table class="ql-table-blob" border="1" style="border-style: solid; border-color: rgb(163, 163, 163); border-width: 1pt;margin-left: 0.3333in;"><tbody><tr><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width:1.7159in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;"><span style="font-weight: bold;">Field </span></p></td><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 4.8625in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;"><span style="font-weight: bold;">Description</span></p></td></tr><tr><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 1.7354in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;">EventEngagement Name</p></td><td colspan="1" rowspan="1" style="border-style: solid; border-color: #A3A3A3; border-width: 1pt; width: 4.9125in; padding: 4pt 4pt 4pt 4pt;"><p style="margin: 0in; font-size: 11.0pt; color: black;">Theofficial title of the meeting. A short, descriptive phrase that isrecognizable. </p></td></tr></tbody></table><p><br></p>';

        CRM_GenerateWord_EMBController.reduceSizeForWord(reduceSize);
        Test.stopTest();
        }
        @isTest
    static void testWordForTalkingObj() {
        Executive_Meeting_Brief__c testEMB = [SELECT Id, Core_Executive_Meeting_Brief_Name__c FROM Executive_Meeting_Brief__c WHERE Core_Executive_Meeting_Brief_Name__c = 'Test Executive Meeting Brief' LIMIT 1];
        
        Test.startTest();
        
        // Set up page parameters
        PageReference pageRef = Page.CRM_GeneratePDF_EMB;
        pageRef.getParameters().put('id', testEMB.Id);
        Test.setCurrentPage(pageRef);
        
        // Create controller instance
        CRM_GeneratePDF_EMBController controller = new CRM_GeneratePDF_EMBController();
       
        String originalUrl =
            'https://intel--crmdevsls3.sandbox.file.force.com/servlet/rtaImage?' +
            'eid=' + testEMB.Id +
            '&refid=0EMWA000000wNM1';

        //Test.setMock(HttpCalloutMock.class, new CRM_FetchImageCalloutMockTest());
        Test.setMock(HttpCalloutMock.class, new CRM_FetchImageCalloutMockTest());
        //String str= CRM_GeneratePDF_EMBController.getFormattedSchedule();
        //STring frmtSTring = CRM_GeneratePDF_EMBController.fetchImageAsBase64(originalUrl,'CRM_Attendee_Bio_s__c','CRM_MeetingBriefBackground_TalkingPoints__c');
        Test.stopTest();
        }
        public class CRM_FetchImageCalloutMockTest implements HttpCalloutMock {

            public HTTPResponse respond(HTTPRequest req) {
        
                HttpResponse res = new HttpResponse();
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'image/png');
        
                // Fake image blob
                Blob fakeImage = Blob.valueOf('FAKE_IMAGE_DATA');
                res.setBodyAsBlob(fakeImage);
        
                return res;
            }
       }

}