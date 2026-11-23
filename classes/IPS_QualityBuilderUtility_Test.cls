/***************************************************************************************************************
* @Name IPS_QualityBuilderUtility_Test 
* @Description Test class to test all positive and negative scenarios of quality builder functionality
* @Author Saikrishna popcornapps

* @version 1.0
* @Created Date 29/11/2021
****************************************************************************************************************/
@isTest
private class IPS_QualityBuilderUtility_Test {
    // To setup the test data.
    
    
    @testSetup static void setup() {
        // Create common custom setting record
        IPS_QualityBuilder_Generic_Pipe_Setting__c jobSetting = new IPS_QualityBuilder_Generic_Pipe_Setting__c();
        jobSetting.Name = 'Daily IPS survey file for OnR';
        jobSetting.Cron_Expression__c = '20 30 8 10 8 ?';
        jobSetting.File_Name_Date_Format__c = 'MMddyyy';
        jobSetting.File_Name_Prefix__c = 'QB';
        jobSetting.Is_Active__c = true;
        jobSetting.Report_Id__c = System.Label.IPS_QB_REPORTID;
        Test.startTest();
        insert jobSetting;   
        Test.stopTest(); 
        
    }
    // To test positive response.
    @isTest static void testPositive() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        // To test padding cond for "=="
        IPS_QualityBuilderUtility.testString = 'any carnal pleasure.';
        IPS_QualityBuilderReportscheduler.schedule();
        Blob reportContent = Blob.valueOf('YourDummyDataHere');         
        String fileName = IPS_QualityBuilderUtility.generateFileName('Test Job', 'MMddyyy');
        String boundryString = IPS_QualityBuilderUtility.generateBoundryString();
        Blob blobBody = IPS_QualityBuilderUtility.generateBlobBody(reportContent, boundryString, fileName);
        String res = IPS_QualityBuilderUtility.doReportSendCalloutWithRetry(reportContent, boundryString, '',10);
        
        Test.stopTest();
    }
    // To test positive response to test padding cond for "="
    @isTest static void testPaddingPositive() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        // To test padding cond for "="
        IPS_QualityBuilderUtility.testString = 'any carnal pleasure';
        IPS_QualityBuilderReportscheduler.schedule();
        Test.stopTest();
    }
    
    // To test positive response to test padding cond for NOT "=" & NOT "=="
    @isTest static void testPaddingBlankPositive() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        // To test padding cond for "="
        IPS_QualityBuilderUtility.testString = 'any carnal pleasur';
        IPS_QualityBuilderReportscheduler.schedule();
        Test.stopTest();
    }
    
    // To test negative response
    @isTest static void testNegative() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(400);
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        IPS_QualityBuilderUtility.testString = 'any carnal pleasure';
        IPS_QualityBuilderReportscheduler.schedule();
        Test.stopTest();
    }
    // START- Shipra
    // To test negative response
    @isTest static void testIncorectReportNegative() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        IPS_QualityBuilderUtility.testString = null;
        IPS_QualityBuilderReportscheduler.schedule();
        Test.stopTest();
    }
    @isTest static void testTokenGenerationFailure() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(500); 
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        
        try {
            IPS_QualityBuilderUtility.generateTokenWithRetry('https://apis-stage.intel.com/v1/auth/token', 'client_id', 'client_secret');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Failed to generate token'), 'Expected failure message');
        }
        
        Test.stopTest();
    }
    
    
    @isTest static void testReportUploadFailure() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token','IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files','IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(500); 
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        
        try {
            Blob reportContent = Blob.valueOf('dummy content');
            String boundryString = 'dummyBoundary';
            IPS_QualityBuilderUtility.doReportSendCalloutWithRetry(reportContent, boundryString, 'token', 10);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('File Upload Failed'), 'Expected failure message');
        }
        
        Test.stopTest();
    }
    @isTest
    static void testNegativegenerateFileName() {
        Test.startTest();
        
        String fileNameNullDateFormat = IPS_QualityBuilderUtility.generateFileName('test', null);
        System.assert(fileNameNullDateFormat.startsWith('test'), 'File name should start with the prefix');
        System.assert(fileNameNullDateFormat.endsWith('.csv'), 'File name should end with .csv');
        
        String invalidDateFormat = 'invalid-format';
        String fileNameInvalidDateFormat = IPS_QualityBuilderUtility.generateFileName('test', invalidDateFormat);
        System.assert(fileNameInvalidDateFormat.startsWith('test'), 'File name should start with the prefix');
        System.assert(fileNameInvalidDateFormat.endsWith('.csv'), 'File name should end with .csv');
        
        Test.stopTest();    
    }
 
    
    @isTest
    static void testReportUploadFailureNeg() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis-stage.intel.com/v1/auth/token', 'IPS_QualityBuilder_TokenCallout_MockResponse');
        multimock.setStaticResource('https://apis-stage.intel.com/m2r/isvc-services/v1/files', 'IPS_QualityBuilder_SendFileCallout_MockResponse');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(500);  // Simulate an HTTP failure response
        
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest(); 
        Blob reportContent = Blob.valueOf('dummy content');
        String boundaryString = 'dummyBoundary';
        String token = 'token';
        Decimal totalRecords = 10;  
      
        String result = IPS_QualityBuilderUtility.doReportSendCalloutWithRetry(reportContent, boundaryString, token, totalRecords);
        System.assertEquals(totalRecords, 10);
		Test.stopTest();
    }
   // START- END
    
}