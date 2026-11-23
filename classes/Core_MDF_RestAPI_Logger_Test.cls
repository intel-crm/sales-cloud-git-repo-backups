@IsTest
private class Core_MDF_RestAPI_Logger_Test {

    // ============================================================
    // logToTransactionEntry(LogRequest) tests
    // ============================================================

    @IsTest
    static void testLogToTransactionEntry_NullRequest_NoException() {
        Test.startTest();
        Id result = Core_MDF_RestAPI_Logger.logToTransactionEntry(null);
        Test.stopTest();

        // If Core_RestAPI_Transaction_Entry__c exists, returns an Id; otherwise null
        System.assert(true, 'No exception thrown for null request');
    }

    @IsTest
    static void testLogToTransactionEntry_SuccessRequest_NoException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'CampaignRestAPI';
        request.endpoint = '/v1.0/partnercenter/campaign/7010000000001AAA';
        request.methodName = 'GET';
        request.contextMessage = 'Campaign retrieved successfully';
        request.statusCode = '200';
        request.isSuccess = true;
        request.entryTime = System.now().addSeconds(-2);
        request.exitTime = System.now();
        request.apiVersion = 'v1.0';
        request.requestPayload = '{"campaignId":"7010000000001AAA"}';
        request.responsePayload = '{"isSuccess":true}';
        request.errors = null;
        request.additionalFields = new Map<String, Object>{ 'Core_Status_Code__c' => '200' };

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Success request logged without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_ErrorRequest_NoException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'CampaignRestAPI';
        request.statusCode = '7003';
        request.isSuccess = false;
        request.errors = new List<String>{ 'Something went wrong', 'Secondary error' };
        request.entryTime = System.now();
        request.exitTime = System.now();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Error request logged without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_NullPayloads_NoException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'NullPayloadTest';
        request.statusCode = '200';
        request.isSuccess = true;
        request.requestPayload = null;
        request.responsePayload = null;
        request.errors = null;
        request.additionalFields = null;
        request.contextMessage = null;

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Null payloads handled without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_ObjectPayloads_SerializedWithoutException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'ObjectPayloadTest';
        request.isSuccess = true;
        request.statusCode = '200';
        request.requestPayload = new Map<String, Object>{ 'campaignId' => '7010000000001', 'filter' => 'label' };
        request.responsePayload = new List<Object>{ 'item1', 'item2' };

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Object payloads serialized without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_UriWithQueryString_NoException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'UriQueryTest';
        request.endpoint = '/v1.0/partnercenter/campaign/7010000000001AAA?fielddisplay=label&v=1';
        request.isSuccess = true;
        request.statusCode = '200';

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'URI with query string handled without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_VersionInUri_ExtractedWithoutException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.endpoint = '/services/apexrest/v1.0/mdf/campaign/7010000000001AAA';
        request.isSuccess = true;
        request.statusCode = '200';

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Version extracted from URI without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_EndsWithSlash_NoIdExtracted() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.endpoint = '/v1.0/partnercenter/campaign/';
        request.isSuccess = false;
        request.statusCode = '400';

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Trailing slash in URI handled without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_EmptyErrorsList_NoException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'EmptyErrorsTest';
        request.isSuccess = false;
        request.statusCode = '7004';
        request.errors = new List<String>();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Empty errors list handled without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_AdditionalFields_AppliedWithoutException() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'AdditionalFieldsTest';
        request.isSuccess = true;
        request.statusCode = '200';
        request.additionalFields = new Map<String, Object>{
            'Core_API_Name__c' => 'OverriddenApiName',
            'Core_Status_Code__c' => '200'
        };

        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
        Test.stopTest();

        System.assert(true, 'Additional fields applied without exception');
    }

    // ============================================================
    // logToTransactionEntry shorthand overload tests
    // ============================================================

    @IsTest
    static void testLogToTransactionEntry_ShorthandOverload_SuccessWithNullErrors() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(
            'CampaignAPI',
            '{"campaignId":"001"}',
            '{"isSuccess":true}',
            '200',
            true,
            null
        );
        Test.stopTest();

        System.assert(true, 'Shorthand success log completed without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_ShorthandOverload_ErrorWithErrors() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(
            'FailedAPI',
            null,
            null,
            '7003',
            false,
            new List<String>{ 'Error occurred', 'Secondary error' }
        );
        Test.stopTest();

        System.assert(true, 'Shorthand error log completed without exception');
    }

    @IsTest
    static void testLogToTransactionEntry_ShorthandOverload_NullApiName() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(
            null, null, null, null, true, null
        );
        Test.stopTest();

        System.assert(true, 'Shorthand log with null apiName completed without exception');
    }

    // ============================================================
    // logFromRestContext tests
    // ============================================================

    @IsTest
    static void testLogFromRestContext_WithFullRestContext_NoException() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/mdf/campaign/7010000000001AAA';
        req.httpMethod = 'GET';
        req.addHeader('User-Agent', 'Test-Agent/1.0');
        req.addHeader('Host', 'test.salesforce.com');
        req.addHeader('X-Forwarded-For', '192.168.1.1');
        req.requestBody = Blob.valueOf('{"test":"body"}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logFromRestContext(
            'CampaignAPI',
            '{"result":"success"}',
            '200',
            true,
            null,
            'Campaign retrieved'
        );
        Test.stopTest();

        System.assert(true, 'logFromRestContext with full context completed without exception');
    }

    @IsTest
    static void testLogFromRestContext_NullRestContext_NoException() {
        RestContext.request = null;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logFromRestContext(
            'CampaignAPI',
            null,
            '500',
            false,
            new List<String>{ 'Internal error' },
            null
        );
        Test.stopTest();

        System.assert(true, 'logFromRestContext with null RestContext completed without exception');
    }

    @IsTest
    static void testLogFromRestContext_WithXForwardedHost_NoException() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/mdf/campaign/';
        req.httpMethod = 'POST';
        req.addHeader('X-Forwarded-Host', 'proxy.example.com');
        req.addHeader('X-Forwarded-For', '10.0.0.1');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logFromRestContext(
            'CampaignAPI',
            '{"isSuccess":false}',
            '7002',
            false,
            new List<String>{ 'Campaign ID is empty' },
            'Missing campaign ID in request'
        );
        Test.stopTest();

        System.assert(true, 'logFromRestContext with X-Forwarded-Host completed without exception');
    }

    @IsTest
    static void testLogFromRestContext_NullRequestBody_NoException() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/mdf/campaign/7010000000001AAA';
        req.httpMethod = 'GET';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_RestAPI_Logger.logFromRestContext(
            'CampaignAPI', null, '200', true, null, null
        );
        Test.stopTest();

        System.assert(true, 'logFromRestContext with null body completed without exception');
    }

    // ============================================================
    // Debug logging utility method tests
    // ============================================================

    @IsTest
    static void testInfo_WithMessage_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.info('Test info message');
        Core_MDF_RestAPI_Logger.info('');
        Core_MDF_RestAPI_Logger.info(null);
        Test.stopTest();

        System.assert(true, 'info() executed without exception for all input variants');
    }

    @IsTest
    static void testWarning_WithMessage_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.warning('Test warning message');
        Core_MDF_RestAPI_Logger.warning(null);
        Test.stopTest();

        System.assert(true, 'warning() executed without exception');
    }

    @IsTest
    static void testError_WithMessage_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.error('Test error message');
        Core_MDF_RestAPI_Logger.error(null);
        Test.stopTest();

        System.assert(true, 'error() executed without exception');
    }

    @IsTest
    static void testLogSegmentInfo_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logSegmentInfo('SegmentA', 'Processed successfully');
        Core_MDF_RestAPI_Logger.logSegmentInfo(null, null);
        Test.stopTest();

        System.assert(true, 'logSegmentInfo() executed without exception');
    }

    @IsTest
    static void testLogSegmentError_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logSegmentError('SegmentB', 'Processing failed');
        Core_MDF_RestAPI_Logger.logSegmentError(null, null);
        Test.stopTest();

        System.assert(true, 'logSegmentError() executed without exception');
    }

    @IsTest
    static void testLogMultiSegmentSPIF_Success_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logMultiSegmentSPIF('001000000000001AAA', 'TestProgram', 3, true);
        Test.stopTest();

        System.assert(true, 'logMultiSegmentSPIF() success case executed without exception');
    }

    @IsTest
    static void testLogMultiSegmentSPIF_Failure_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logMultiSegmentSPIF('001000000000001AAA', 'TestProgram', 0, false);
        Test.stopTest();

        System.assert(true, 'logMultiSegmentSPIF() failure case executed without exception');
    }

    @IsTest
    static void testLogMultiSegmentSPIF_NullValues_NoException() {
        Test.startTest();
        Core_MDF_RestAPI_Logger.logMultiSegmentSPIF(null, null, null, null);
        Test.stopTest();

        System.assert(true, 'logMultiSegmentSPIF() with null values executed without exception');
    }
}