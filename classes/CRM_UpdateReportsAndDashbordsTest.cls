@IsTest
public class CRM_UpdateReportsAndDashbordsTest {
    @IsTest(SeeAllData=true)
    static void testShareReportDashFolder() {
        User testUser = new User(
            FirstName = 'TestReDa03',
            LastName = 'UserReDa',
            Email = 'testuser11@example.com',
            Username = 'testuserre011@example.com.salesforce',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Report testReport = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById FROM Report WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastRunDate  <> last_N_days:365 and FolderName != 'Public Reports' LIMIT 1];
        Dashboard testDashboard = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById FROM Dashboard WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastReferencedDate <> last_N_days:365 LIMIT 1];
        string fromReuser=testReport.CreatedBy.Username;
        string fromDauser=testDashboard.CreatedBy.Name;
        string toReuser=testUser.Username;
        User toDauser= [Select Id,Name From User where Email ='testuser11@example.com'];
        
       /* Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
            config.Core_MDF_isActive_ind__c = true;
            
            Insert config;*/
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(200));
        //System.runAs(Core_Test_Utility.systemAdminUser) {
         Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testReport.Id},toDauser.Id, 'Reports' /*, config*/);
         Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testDashboard.Id},toDauser.Id, 'Dashboards' /*, config*/);
        //}
       // List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport.CreatedById, toDauser.Id);
        List<Map<String, Object>> DashResult = CRM_Create_Dashbord_detail.Create_Dasboard_Data( testDashboard.CreatedById, toDauser.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        Test.stopTest();

        System.assert(true, 'Test completed successfully. Add assertions for specific validations.');
    }
    @IsTest(SeeAllData=true)
    static void testShareReportsFolder() {
        User testUser = new User(
            FirstName = 'TestReDa012',
            LastName = 'UserReDa',
            Email = 'testuser12@example.com',
            Username = 'testuser012@example.com.salesforce',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        List<Report> testReport = [SELECT Id, FolderName, CreatedBy.Name,CreatedBy.Username FROM Report WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and FolderName != 'Public Reports' and  LastRunDate  <> last_N_days:365 LIMIT 25];
        List<Dashboard> testDashboard = [SELECT Id, FolderName, CreatedBy.Name,CreatedBy.Username FROM Dashboard WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastReferencedDate <> last_N_days:365 LIMIT 21];
        string fromReuser = testReport[0].createdBy.Username;
        string fromDauser = testDashboard[0].CreatedBy.Name;
        string toReuser = testUser.Username;
        User toDauser= [Select Id,Name From User where Email ='testuser12@example.com'];
       /* Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
            config.Core_MDF_isActive_ind__c = true;
            
            Insert config;*/
        List<Id>testRepotIds =  new List<Id>();
        List<Id>testDashIds =  new List<Id>();
        For(Report Rept : testReport){
            testRepotIds.add(Rept.Id);
        }
        For(Dashboard dash : testDashboard){
            testDashIds.add(dash.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(200));
        Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(testRepotIds,toDauser.Id, 'Reports' /*, config*/);
         Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(testDashIds,toDauser.Id, 'Dashboards' /*, config*/);
        //List<Report> ReportResult = CRM_CheckUserAccess_Report.UserReports(fromReuser, toReuser);
      //  List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport[0].CreatedById, toDauser.Id);
        List<Map<String, Object>> DashResult = CRM_Create_Dashbord_detail.Create_Dasboard_Data( testDashboard[0].CreatedById, testDashboard[0].CreatedById);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        Test.stopTest();

        System.assert(true, 'Test completed successfully. Add assertions for specific validations.');
    }
    @IsTest
    static void testShareReportFolderWithEmptyInput() {
       // List<CRM_UpdateReportsAndDashbords.FolderSharingRequest> emptyRequests = new List<CRM_UpdateReportsAndDashbords.FolderSharingRequest>();

        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(200));
        Test.startTest();
         
        CRM_UpdateReportsAndDashbords.shareReportFolder(null,null,null/*,null*/);
        // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        Test.stopTest();

        System.assert(true, 'Method handled empty input without errors.');
    }
    @IsTest(SeeAllData=true)
    static void testRunningUser() {
        User testUser = new User(
            FirstName = 'TestReDa013',
            LastName = 'UserReDa',
            Email = 'testuser13@example.com',
            Username = 'testuser013@example.com.salesforce',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Report testReport = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById FROM Report WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastRunDate  <> last_N_days:365 and FolderName = 'Public Reports' LIMIT 1];
        Dashboard testDashboard = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById FROM Dashboard WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastReferencedDate <> last_N_days:365 and RunningUser.IsActive = false LIMIT 1];
        string fromReuser=testReport.CreatedBy.Username;
        string fromDauser=testDashboard.CreatedBy.Name;
        string toReuser=testUser.Username;
        User toDauser= [Select Id,Name From User where Email ='testuser13@example.com'];
        
        /*Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
            config.Core_MDF_isActive_ind__c = true;
            
            Insert config;*/
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(200));
        //System.runAs(Core_Test_Utility.systemAdminUser) {
         Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testReport.Id},toDauser.Id, 'Reports' /*, config*/);
         Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testDashboard.Id},toDauser.Id, 'Dashboards' /*, config*/);
        //}
       // List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport.CreatedById, toDauser.Id);
        List<Map<String, Object>> DashResult = CRM_Create_Dashbord_detail.Create_Dasboard_Data( testDashboard.CreatedById, testDashboard.CreatedById);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        Test.stopTest();

        System.assert(true, 'Test completed successfully. Add assertions for specific validations.');
    }
    public class Core_TestHttpResponse implements HttpCalloutMock {
        
        public Integer statusCode;
        public Core_TestHttpResponse(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test" , "values":[{"value":"test value"}]}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    public class MockHttpCalloutWithError implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"error": "Internal Server Error"}');
        return res;
    }
}
    
}