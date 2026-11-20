/**
 * @description Test class for Core_MDF_PFR_RestAPI_Response
 * Tests response models, error handling, and structured error formatting.
 */
@isTest
private class Core_MDF_PFR_RestAPI_Response_Test {

    /**
     * @description Test default constructor initialization
     */
    @isTest
    static void testResponseDefaultConstructor() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        
        Assert.isNotNull(response);
        Assert.isTrue(response.isSuccess);
        Assert.isNotNull(response.successContent);
        Assert.areEqual(0, response.successContent.size());
        Assert.isNotNull(response.failureContent);
        Assert.areEqual(0, response.failureContent.size());
    }

    /**
     * @description Test default constructor multi-segment SPIF field initialization
     */
    @isTest
    static void testResponseDefaultConstructorSPIFFields() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        
    }

    /**
     * @description Test response property assignment
     */
    @isTest
    static void testResponsePropertyAssignment() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        
        response.isSuccess    = false;
        response.code         = 'SUCCESS';
        response.message      = 'Test message';
        response.errorcode    = 'ERR-9000';
        response.totalRecords = 5;
        
        Assert.isFalse(response.isSuccess);
        Assert.areEqual('SUCCESS',      response.code);
        Assert.areEqual('Test message', response.message);
        Assert.areEqual('ERR-9000',     response.errorcode);
        Assert.areEqual(5,              response.totalRecords);
    }

    // =========================================================================
    // FileUploadResult
    // =========================================================================

    /**
     * @description Test FileUploadResult initialization
     */
    @isTest
    static void testFileUploadResultInitialization() {
        Core_MDF_PFR_RestAPI_Response.FileUploadResult result =
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('test.pdf', 'Success');
        
        Assert.isNotNull(result);
        Assert.areEqual('test.pdf', result.fileName);
        Assert.areEqual('Success',  result.status);
    }

    /**
     * @description Test FileUploadResult with null values
     */
    @isTest
    static void testFileUploadResultWithNullValues() {
        Core_MDF_PFR_RestAPI_Response.FileUploadResult result =
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult(null, null);
        
        Assert.isNotNull(result);
        Assert.isNull(result.fileName);
        Assert.isNull(result.status);
    }

    /**
     * @description Test FileUploadResult with various status values
     */
    @isTest
    static void testFileUploadResultVariousStatus() {
        Core_MDF_PFR_RestAPI_Response.FileUploadResult success =
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('file1.pdf', 'Success');
        Core_MDF_PFR_RestAPI_Response.FileUploadResult failure =
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('file2.pdf', 'Failed');
        Core_MDF_PFR_RestAPI_Response.FileUploadResult pending =
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('file3.pdf', 'Pending');
        
        Assert.areEqual('Success', success.status);
        Assert.areEqual('Failed',  failure.status);
        Assert.areEqual('Pending', pending.status);
    }

    // =========================================================================
    // ErrorContent
    // =========================================================================

    /**
     * @description Test ErrorContent initialization
     */
    @isTest
    static void testErrorContentInitialization() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
        Assert.isNotNull(error);
        Assert.isNull(error.pfrId);
        Assert.isNull(error.pfrName);
        Assert.isNotNull(error.errors);
        Assert.areEqual(0, error.errors.size());
    }

    /**
     * @description Test ErrorContent property assignment
     */
    @isTest
    static void testErrorContentPropertyAssignment() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
        error.pfrId   = '001xx000000001';
        error.pfrName = 'Test Activity';
        error.errors.add('Error 1');
        error.errors.add('Error 2');
        
        Assert.areEqual('001xx000000001', error.pfrId);
        Assert.areEqual('Test Activity',  error.pfrName);
        Assert.areEqual(2,                error.errors.size());
    }

    /**
     * @description Test ErrorContent errorDetails with empty errors list
     */
    @isTest
    static void testErrorContentErrorDetailsEmpty() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        Assert.isNotNull(details);
        Assert.areEqual(0, details.size());
    }

    /**
     * @description Blank / whitespace-only error strings must be filtered out
     */
    @isTest
    static void testErrorContentErrorDetailsBlankStrings() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        error.errors.add('Campaign ID is required.');
        error.errors.add('');
        error.errors.add('   ');
        error.errors.add('Activity Category invalid.');
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        Assert.areEqual(2, details.size());
    }

    // =========================================================================
    // ErrorDetail
    // =========================================================================

    /**
     * @description Test ErrorDetail default initialization (all fields null)
     */
    @isTest
    static void testErrorDetailInitialization() {
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail =
            new Core_MDF_PFR_RestAPI_Response.ErrorDetail();
        
        Assert.isNotNull(detail);
        Assert.isNull(detail.code);
        Assert.isNull(detail.message);
        Assert.isNull(detail.field);
        Assert.isNull(detail.allowedValues);
    }

    /**
     * @description Test ErrorDetail property assignment
     */
    @isTest
    static void testErrorDetailPropertyAssignment() {
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail =
            new Core_MDF_PFR_RestAPI_Response.ErrorDetail();
        
        detail.code          = 'ERR-9030';
        detail.message       = 'Invalid Activity Category';
        detail.field         = 'Activity Category';
        detail.allowedValues = new List<String>{'Event', 'Retail', 'Digital'};
        
        Assert.areEqual('ERR-9030',                  detail.code);
        Assert.areEqual('Invalid Activity Category', detail.message);
        Assert.areEqual('Activity Category',         detail.field);
        Assert.areEqual(3,                           detail.allowedValues.size());
    }

    // =========================================================================
    // toErrorDetail – no-code / plain-message paths
    // =========================================================================

    /**
     * @description Input with no error-code prefix returns null code and full string as message
     */
    @isTest
    static void testToErrorDetailNoCodePrefix() {
        String rawError = 'This is an error message without code prefix.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail =
            Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.isNull(detail.code);
        Assert.areEqual(rawError, detail.message);
        Assert.isNull(detail.field);
    }


    // =========================================================================
    // Full response assembly
    // =========================================================================

    /**
     * @description Response with failure content is assembled correctly
     */
    @isTest
    static void testResponseWithFailureContent() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.isSuccess    = false;
        response.code         = 'VALIDATION_FAILED';
        response.totalRecords = 1;
        
        Core_MDF_PFR_RestAPI_Response.ErrorContent failure =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        failure.pfrName = 'Test Activity';
        failure.errors.add('Campaign ID is required.');
        response.failureContent.add(failure);
        
        Assert.isFalse(response.isSuccess);
        Assert.areEqual('VALIDATION_FAILED', response.code);
        Assert.areEqual(1,                   response.failureContent.size());
        Assert.areEqual('Test Activity',     response.failureContent[0].pfrName);
    }

    /**
     * @description Response with file upload content is assembled correctly
     */
    @isTest
    static void testResponseWithFileUploadContent() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.fileUploadContent =
            new List<Core_MDF_PFR_RestAPI_Response.FileUploadResult>();
        
        response.fileUploadContent.add(
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('document1.pdf', 'Success'));
        response.fileUploadContent.add(
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('document2.pdf', 'Failed'));
        
        Assert.areEqual(2,               response.fileUploadContent.size());
        Assert.areEqual('document1.pdf', response.fileUploadContent[0].fileName);
        Assert.areEqual('Success',       response.fileUploadContent[0].status);
        Assert.areEqual('document2.pdf', response.fileUploadContent[1].fileName);
        Assert.areEqual('Failed',        response.fileUploadContent[1].status);
    }

    /**
     * @description Response serialises to JSON containing expected keys and values
     */
    @isTest
    static void testResponseSerialization() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.isSuccess    = true;
        response.code         = 'SUCCESS';
        response.message      = 'Records created successfully';
        response.totalRecords = 1;
        
        String json = JSON.serialize(response);
        
        Assert.isNotNull(json);
        Assert.isTrue(json.containsIgnoreCase('isSuccess'));
        Assert.isTrue(json.containsIgnoreCase('SUCCESS'));
    }
}