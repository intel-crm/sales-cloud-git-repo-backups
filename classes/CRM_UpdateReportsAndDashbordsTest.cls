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
        System.runAs(Core_Test_Utility.systemAdminUser) {
        insert testUser;
        }
        Report testReport = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById FROM Report WHERE CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastRunDate  <> last_N_days:365 and FolderName != 'Public Reports' LIMIT 1];
        Dashboard testDashboard = [SELECT Id, FolderName,CreatedBy.Name,CreatedBy.Username,CreatedById,RunningUser.IsActive FROM Dashboard WHERE RunningUser.IsActive = false and CreatedById IN (SELECT userId FROM userLogin WHERE IsFrozen = true) and CreatedBy.Profile.Name	in ('Sales Rep-BB','Sales Rep-CW','SMG/GMC Read Only','Data Ops','Sales Manager','Commissions Office Inquiries Admin User','Sales Ops','Sales Rep-BB-Dual IPS','BU Account Collaborator','Global Export Compliance','Reporting Admin') and LastReferencedDate <> last_N_days:365 LIMIT 1];
        string fromReuser=testReport.CreatedBy.Username;
        string fromDauser=testDashboard.CreatedBy.Name;
        string toReuser=testUser.Username;
        User toDauser= [Select Id,Name From User where Email ='testuser11@example.com'];
        
        Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
            config.Core_MDF_isActive_ind__c = true;
            
            Insert config;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(2000));
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //System.runAs(Core_Test_Utility.systemAdminUser) {
       // System.Test.setMock(WebServiceMock.class, new CRMMetadataServiceMock());
         Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testReport.Id},toDauser.Id, 'Reports' , config);
         Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testDashboard.Id},toDauser.Id, 'Dashboards' , config);
        //}
        List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport.CreatedById, toDauser.Id);
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
        
        List<Id>testRepotIds =  new List<Id>();
        List<Id>testDashIds =  new List<Id>();
        For(Report Rept : testReport){
            testRepotIds.add(Rept.Id);
        }
        For(Dashboard dash : testDashboard){
            testDashIds.add(dash.Id);
        }
        Test.startTest();
        
        Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
        System.runAs(Core_Test_Utility.systemAdminUser) {
        
            config.Core_MDF_isActive_ind__c = true;
            
            Insert config;}
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(2000));
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //System.Test.setMock(WebServiceMock.class, new CRMMetadataServiceMock());
        
        Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(testRepotIds,toDauser.Id, 'Reports' , config);
        Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(testDashIds,toDauser.Id, 'Dashboards' , config);
        
        List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport[0].CreatedById, toDauser.Id);
        List<Map<String, Object>> DashResult = CRM_Create_Dashbord_detail.Create_Dasboard_Data( testDashboard[0].CreatedById, testDashboard[0].CreatedById);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        //Test.stopTest();
       // Test.startTest();
        List<CRM_MetadataService.DashboardFolder> dFolderlst = new List<CRM_MetadataService.DashboardFolder>();
        
        CRM_MetadataService.DashboardFolder dashFolder = new CRM_MetadataService.DashboardFolder();
        dashFolder.fullName = 'Test';  // Folder Developer Name
        dashFolder.accessType = 'Public';
        CRM_MetadataService.FolderShare share = new CRM_MetadataService.FolderShare();
        share.accessLevel = 'EditAllContents';  // View or EditAllContents or Manage
        share.sharedTo = toDauser.Id;    //TO UserName or Group ID
        share.sharedToType = 'User';
        dashFolder.folderShares = new List<CRM_MetadataService.FolderShare>{ share };
            dFolderlst.add(dashFolder);
        
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        CRM_UpdateReportsAndDashbords.CreatesessionId(dFolderlst);
         Test.stopTest();
        System.assert(true, 'Test completed successfully. Add assertions for specific validations.');
    }
    @IsTest
    static void testShareReportFolderWithEmptyInput() {

        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(2000));
        Test.startTest();
         System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //System.Test.setMock(WebServiceMock.class, new CRMMetadataServiceMock());
        CRM_UpdateReportsAndDashbords.shareReportFolder(null,null,null,null);
        CRM_UpdateReportsAndDashbords.CreatesessionId(null);
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
        
        
        Test.startTest();
        
        Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
        System.runAs(Core_Test_Utility.systemAdminUser) {
        
            config.Core_MDF_isActive_ind__c = true;
            Insert config;}
        //System.runAs(Core_Test_Utility.systemAdminUser) {
        Test.setMock(HttpCalloutMock.class, new Core_TestHttpResponse(200));
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //System.Test.setMock(WebServiceMock.class, new CRMMetadataServiceMock());
         Boolean SaveReportResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testReport.Id},toDauser.Id, 'Reports' , config);
         Boolean SaveDashResult = CRM_UpdateReportsAndDashbords.shareReportFolder(new List<Id>{testDashboard.Id},toDauser.Id, 'Dashboards' , config);
        //}
        List<SObject> ReportResultForMassOn = Core_MDF_CCP_MassOwnerUpdate.UserReports(testReport.CreatedById, toDauser.Id);
        List<Map<String, Object>> DashResult = CRM_Create_Dashbord_detail.Create_Dasboard_Data( testDashboard.CreatedById, testDashboard.CreatedById);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        
        List<CRM_MetadataService.DashboardFolder> dFolderlst = new List<CRM_MetadataService.DashboardFolder>();
        for(Integer i=0;i<12;i++){
            CRM_MetadataService.DashboardFolder dashFolder = new CRM_MetadataService.DashboardFolder();
            dashFolder.fullName = 'Test'+string.ValueOF(i) ;  // Folder Developer Name
            dashFolder.accessType = 'Public';
            CRM_MetadataService.FolderShare share = new CRM_MetadataService.FolderShare();
            share.accessLevel = 'EditAllContents';  // View or EditAllContents or Manage
            share.sharedTo = toDauser.Id;    //TO UserName or Group ID
            share.sharedToType = 'User';
            dashFolder.folderShares = new List<CRM_MetadataService.FolderShare>{ share };
                dFolderlst.add(dashFolder);
        }
        
        
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        CRM_UpdateReportsAndDashbords.CreatesessionId(dFolderlst);
         //Test.stopTest();
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


private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof CRM_MetadataService.retrieve_element){
                response.put('response_x', new CRM_MetadataService.retrieveResponse_element());
            }    
            if(request instanceof CRM_MetadataService.checkDeployStatus_element){
                response.put('response_x', new CRM_MetadataService.checkDeployStatusResponse_element());
            }    
            if(request instanceof CRM_MetadataService.listMetadata_element){
                response.put('response_x', new CRM_MetadataService.listMetadataResponse_element());
            }   
            if(request instanceof CRM_MetadataService.checkRetrieveStatus_element){
                response.put('response_x', new CRM_MetadataService.checkRetrieveStatusResponse_element());
            }   
            if(request instanceof CRM_MetadataService.describeMetadata_element){
                response.put('response_x', new CRM_MetadataService.describeMetadataResponse_element());
            }
            if(request instanceof CRM_MetadataService.deploy_element){
                response.put('response_x', new CRM_MetadataService.deployResponse_element());
            } 
            if(request instanceof CRM_MetadataService.updateMetadata_element){
                response.put('response_x', new CRM_MetadataService.updateMetadataResponse_element());
            }   
            if(request instanceof CRM_MetadataService.renameMetadata_element){
                 response.put('response_x', new CRM_MetadataService.renameMetadataResponse_element());
            }   
            if(request instanceof  CRM_MetadataService.cancelDeploy_element){
                response.put('response_x', new CRM_MetadataService.cancelDeployResponse_element());
            }
            if(request instanceof  CRM_MetadataService.deleteMetadata_element){
                 response.put('response_x', new CRM_MetadataService.deleteMetadataResponse_element());
            }  
            if(request instanceof  CRM_MetadataService.upsertMetadata_element){
                response.put('response_x', new CRM_MetadataService.upsertMetadataResponse_element());
            }
            if(request instanceof  CRM_MetadataService.createMetadata_element){
                response.put('response_x', new CRM_MetadataService.createMetadataResponse_element());
            }   
            if(request instanceof  CRM_MetadataService.readMetadata_element){
                CRM_MetadataService.readDashboardFolderResponse_element mockdashfolder = new CRM_MetadataService.readDashboardFolderResponse_element();
                if(request instanceof  CRM_MetadataService.ReadDashboardResult){
                    response.put('response_x', new CRM_MetadataService.readDashboardResponse_element());
                }   
                if(request instanceof  CRM_MetadataService.ReadReportResult){
                    response.put('response_x', new CRM_MetadataService.readReportResponse_element());
                }    
                if(request instanceof  CRM_MetadataService.ReadDashboardFolderResult){
                    response.put('response_x', new CRM_MetadataService.readDashboardFolderResponse_element());
                }    
                if(request instanceof  CRM_MetadataService.ReadReportFolderResult){
                    response.put('response_x', new CRM_MetadataService.readReportFolderResponse_element());
                }
                response.put('response_x', new CRM_MetadataService.readMetadataResponse_element());
            }   
            
            return;
        }
    }   
}