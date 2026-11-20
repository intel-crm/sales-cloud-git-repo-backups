/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(SeeAllData=false)
public class Custom_URL_Embed_Test {
    @isTest
    static void checkGetURLForIFrame(){
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = new Account(Name ='Test Account',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR');
        Database.insert(acc);
        Custom_URL_Embed.getURL('Test_Class_Record',acc.id); 
        Custom_URL_Embed.getURL('Account_AI_Insights',acc.id); 
    }
    
    @isTest
    static void checkGetURLForAutoSSOEnabled(){
        Custom_URL_Embed.getURL('Test_Record_for_AutoSignIn',null);   
    }
    
    
     @isTest
    static void testGetPowerBiAccessToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForSuccess());
        Test.startTest();
        String accessToken = Custom_URL_Embed.getPowerBiAccessToken('Test_Record_for_AutoSignIn');
        Test.stopTest();

        //System.assertNotEquals(null, accessToken, 'Access token should not be null');
        //System.assertNotEquals('', accessToken, 'Access token should not be empty');
    }

    @isTest
    static void testGetEmbeddingDataForReportForSuccess() {
        // Create test data for PowerBiReportData
        String workspaceId = '3cbd5a25-bdbe-4f0c-bd52-29644fba9ca9';
        String reportId = 'b2ed1c10-9ba8-4ed6-a51a-28b5cf16186b';
        String roles = 'SMG KPI - Pipeline Sales Tracker Manager';
        Custom_URL_Embed.PowerBiReportData powerBiReportData = new Custom_URL_Embed.PowerBiReportData();
        powerBiReportData.workspaceId = workspaceId;
        powerBiReportData.reportId = reportId;
        powerBiReportData.name = 'test';
        powerBiReportData.embedUrl = 'https://api.powerbi.com/v1.0/myorg/groups/testReport';
        powerBiReportData.embedToken = 'YourEmbedToken';
        powerBiReportData.embedTokenExpires = DateTime.now().addMinutes(30);

        // Mock the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForSuccess());

        // Call the method and verify the result
        Test.startTest();
        Custom_URL_Embed.PowerBiReportData result = Custom_URL_Embed.getEmbeddingDataForReport('Test_Record_for_AutoSignIn', workspaceId, reportId, roles);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(workspaceId, result.workspaceId, 'Unexpected workspaceId');
        System.assertEquals(reportId, result.reportId, 'Unexpected reportId');
        System.assertEquals('test', result.name, 'Unexpected name');
        System.assertEquals('YourEmbedToken', result.embedToken, 'Unexpected embedToken');
       }
    
    @isTest
    static void testGetEmbeddingDataForReportForError() {
        // Create test data for PowerBiReportData
        String workspaceId = '3cbd5a25-bdbe-4f0c-bd52-29644fba9ca9';
        String reportId = 'b2ed1c10-9ba8-4ed6-a51a-28b5cf16186b';
        String roles = 'SMG KPI - Pipeline Sales Tracker Manager';
        Custom_URL_Embed.PowerBiReportData powerBiReportData = new Custom_URL_Embed.PowerBiReportData();
        powerBiReportData.workspaceId = workspaceId;
        powerBiReportData.reportId = reportId;
        powerBiReportData.name = 'test';
        powerBiReportData.embedUrl = 'https://api.powerbi.com/v1.0/myorg/groups/testReport';
        powerBiReportData.embedToken = 'YourEmbedToken';
        powerBiReportData.embedTokenExpires = DateTime.now().addMinutes(30);

        // Mock the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForError());

        // Call the method and verify the result
        Test.startTest();
        Custom_URL_Embed.PowerBiReportData result = Custom_URL_Embed.getEmbeddingDataForReport('Test_Record_for_AutoSignIn', workspaceId, reportId, roles);
        Test.stopTest();
       }

    
    public class MockHttpResponseGeneratorForSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token": "YourEmbedToken","embedUrl": "https://api.powerbi.com/v1.0/myorg/groups/testReport", "expiration": "2030-01-01T00:00:00Z"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseGeneratorForError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token": "","error": "", "expiration": ""}');
            res.setStatusCode(201);
            return res;
        }
    }
    
    @isTest
    static void testDebugUntruncated() {
        Custom_URL_Embed.debugUntruncated('testStringForDebugUntruncated');
    }
}