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
     * @description Test response property assignment
     */
    @isTest
    static void testResponsePropertyAssignment() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        
        response.isSuccess = false;
        response.code = 'SUCCESS';
        response.message = 'Test message';
        response.errorcode = 'ERR-9000';
        response.totalRecords = 5;
        
        Assert.isFalse(response.isSuccess);
        Assert.areEqual('SUCCESS', response.code);
        Assert.areEqual('Test message', response.message);
        Assert.areEqual('ERR-9000', response.errorcode);
        Assert.areEqual(5, response.totalRecords);
    }

    /**
     * @description Test FileUploadResult initialization
     */
    @isTest
    static void testFileUploadResultInitialization() {
        Core_MDF_PFR_RestAPI_Response.FileUploadResult result = 
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('test.pdf', 'Success');
        
        Assert.isNotNull(result);
        Assert.areEqual('test.pdf', result.fileName);
        Assert.areEqual('Success', result.status);
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
        Assert.areEqual('Failed', failure.status);
        Assert.areEqual('Pending', pending.status);
    }

    /**
     * @description Test ErrorContent initialization
     */
    @isTest
    static void testErrorContentInitialization() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
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
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
        error.pfrId = '001xx000000001';
        error.pfrName = 'Test Activity';
        error.errors.add('Error 1');
        error.errors.add('Error 2');
        
        Assert.areEqual('001xx000000001', error.pfrId);
        Assert.areEqual('Test Activity', error.pfrName);
        Assert.areEqual(2, error.errors.size());
    }

    /**
     * @description Test ErrorDetail initialization
     */
    @isTest
    static void testErrorDetailInitialization() {
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = new Core_MDF_PFR_RestAPI_Response.ErrorDetail();
        
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
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = new Core_MDF_PFR_RestAPI_Response.ErrorDetail();
        
        detail.code = 'ERR-9030';
        detail.message = 'Invalid Activity Category';
        detail.field = 'Activity Category';
        detail.allowedValues = new List<String>{'Event', 'Retail', 'Digital'};
        
        Assert.areEqual('ERR-9030', detail.code);
        Assert.areEqual('Invalid Activity Category', detail.message);
        Assert.areEqual('Activity Category', detail.field);
        Assert.areEqual(3, detail.allowedValues.size());
    }

    /**
     * @description Test toErrorDetail with simple error code and message
     */
    @isTest
    static void testToErrorDetailSimple() {
        String rawError = 'ERR-9020: Campaign ID is required.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.isNotNull(detail);
        Assert.areEqual('ERR-9020', detail.code);
        Assert.areEqual('Campaign ID is required.', detail.message);
    }

    /**
     * @description Test toErrorDetail extracts correct field from code
     */
    @isTest
    static void testToErrorDetailFieldMapping() {
        String rawError = 'ERR-9030: Activity Category "Invalid" is not valid. Allowed values:\n1. Event\n2. Retail';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9030', detail.code);
        Assert.areEqual('Activity Category', detail.field);
    }

    /**
     * @description Test toErrorDetail with ERR-9031 (Activity Type)
     */
    @isTest
    static void testToErrorDetailActivityType() {
        String rawError = 'ERR-9031: Activity Type "Invalid" is not valid.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9031', detail.code);
        Assert.areEqual('Activity Type', detail.field);
    }

    /**
     * @description Test toErrorDetail with ERR-9040 (Priority)
     */
    @isTest
    static void testToErrorDetailPriority() {
        String rawError = 'ERR-9040: Priority value is invalid.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9040', detail.code);
        Assert.areEqual('Priority', detail.field);
    }

    /**
     * @description Test toErrorDetail with ERR-9042 (Country)
     */
    @isTest
    static void testToErrorDetailCountry() {
        String rawError = 'ERR-9042: Country value is not available.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9042', detail.code);
        Assert.areEqual('Country', detail.field);
    }

    /**
     * @description Test toErrorDetail with ERR-9050 (Member Acceptor)
     */
    @isTest
    static void testToErrorDetailMemberAcceptor() {
        String rawError = 'ERR-9050: Member Acceptor user is not active.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9050', detail.code);
        Assert.areEqual('Member Acceptor', detail.field);
    }

    /**
     * @description Test toErrorDetail with unknown error code (no field mapping)
     */
    @isTest
    static void testToErrorDetailUnknownCode() {
        String rawError = 'ERR-9999: Some unknown error.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9999', detail.code);
        Assert.isNull(detail.field);
        Assert.areEqual('Some unknown error.', detail.message);
    }

    /**
     * @description Test toErrorDetail with allowed values
     */
    @isTest
    static void testToErrorDetailWithAllowedValues() {
        String rawError = 'ERR-9030: Activity Category "Invalid" is not valid. Allowed values:\n1. Event\n2. Retail\n3. Digital';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9030', detail.code);
        Assert.isTrue(detail.message.containsIgnoreCase('Activity Category'));
        Assert.isNotNull(detail.allowedValues);
        Assert.areEqual(3, detail.allowedValues.size());
        Assert.areEqual('Event', detail.allowedValues[0]);
        Assert.areEqual('Retail', detail.allowedValues[1]);
        Assert.areEqual('Digital', detail.allowedValues[2]);
    }

    /**
     * @description Test toErrorDetail with multiple allowed values
     */
    @isTest
    static void testToErrorDetailMultipleAllowedValues() {
        String rawError = 'ERR-9040: Priority value "High" is not available. Allowed values:\n1. Critical\n2. Medium\n3. Low\n4. Planning';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9040', detail.code);
        Assert.areEqual(4, detail.allowedValues.size());
        Assert.areEqual('Critical', detail.allowedValues[0]);
        Assert.areEqual('Planning', detail.allowedValues[3]);
    }

    /**
     * @description Test toErrorDetail without error code prefix
     */
    @isTest
    static void testToErrorDetailNoCodePrefix() {
        String rawError = 'This is an error message without code prefix.';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.isNull(detail.code);
        Assert.areEqual('This is an error message without code prefix.', detail.message);
        Assert.isNull(detail.field);
    }

    /**
     * @description Test toErrorDetail with whitespace in code
     */
    @isTest
    static void testToErrorDetailWhitespaceHandling() {
        String rawError = '  ERR-9020  :  Campaign ID is required.  ';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9020', detail.code);
        Assert.areEqual('Campaign ID is required.', detail.message);
    }

    /**
     * @description Test toErrorDetail with empty string
     */
    @isTest
    static void testToErrorDetailEmptyString() {
        String rawError = '';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.isNotNull(detail);
        Assert.isNull(detail.code);
        Assert.areEqual('', detail.message);
    }

    /**
     * @description Test toErrorDetail with only code
     */
    @isTest
    static void testToErrorDetailCodeOnly() {
        String rawError = 'ERR-9050:';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9050', detail.code);
        Assert.areEqual('', detail.message.trim());
    }

    /**
     * @description Test toErrorDetail with special characters in message
     */
    @isTest
    static void testToErrorDetailSpecialCharacters() {
        String rawError = 'ERR-9014: Invalid value "Test & Value with <special> characters".';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.areEqual('ERR-9014', detail.code);
        Assert.isTrue(detail.message.contains('&'));
        Assert.isTrue(detail.message.contains('<'));
    }



    /**
     * @description Test ErrorContent errorDetails property (computed)
     */
    @isTest
    static void testErrorContentErrorDetailsProperty() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        error.errors.add('ERR-9020: Campaign ID is required.');
        error.errors.add('ERR-9030: Activity Category "Invalid" is not valid. Allowed values:\n1. Event\n2. Retail');
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        Assert.isNotNull(details);
        Assert.areEqual(2, details.size());
        Assert.areEqual('ERR-9020', details[0].code);
        Assert.areEqual('ERR-9030', details[1].code);
    }

    /**
     * @description Test ErrorContent errorDetails with empty errors
     */
    @isTest
    static void testErrorContentErrorDetailsEmpty() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        Assert.isNotNull(details);
        Assert.areEqual(0, details.size());
    }

    /**
     * @description Test ErrorContent errorDetails with blank error strings
     */
    @isTest
    static void testErrorContentErrorDetailsBlankStrings() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        error.errors.add('ERR-9020: Campaign ID is required.');
        error.errors.add('');
        error.errors.add('   ');
        error.errors.add('ERR-9030: Activity Category invalid.');
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        // Blank strings should be filtered out
        Assert.areEqual(2, details.size());
    }

    /**
     * @description Test allowed values parsed in error detail from numbered list
     */
    @isTest
    static void testAllowedValuesInErrorDetail() {
        String rawError = 'ERR-9030: Invalid Activity Category. Allowed values:\n1. Event\n2. Retail\n3. Digital\n4. Sponsorship';
        
        Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
        
        Assert.isNotNull(detail.allowedValues);
        Assert.areEqual(4, detail.allowedValues.size());
        Assert.areEqual('Event', detail.allowedValues[0]);
        Assert.areEqual('Retail', detail.allowedValues[1]);
        Assert.areEqual('Digital', detail.allowedValues[2]);
        Assert.areEqual('Sponsorship', detail.allowedValues[3]);
    }

    /**
     * @description Test full response with failure content
     */
    @isTest
    static void testResponseWithFailureContent() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.isSuccess = false;
        response.code = 'VALIDATION_FAILED';
        response.totalRecords = 1;
        
        Core_MDF_PFR_RestAPI_Response.ErrorContent failure = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        failure.pfrName = 'Test Activity';
        failure.errors.add('ERR-9020: Campaign ID is required.');
        response.failureContent.add(failure);
        
        Assert.isFalse(response.isSuccess);
        Assert.areEqual('VALIDATION_FAILED', response.code);
        Assert.areEqual(1, response.failureContent.size());
        Assert.areEqual('Test Activity', response.failureContent[0].pfrName);
    }

    /**
     * @description Test response with file upload content
     */
    @isTest
    static void testResponseWithFileUploadContent() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.fileUploadContent = new List<Core_MDF_PFR_RestAPI_Response.FileUploadResult>();
        
        response.fileUploadContent.add(
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('document1.pdf', 'Success')
        );
        response.fileUploadContent.add(
            new Core_MDF_PFR_RestAPI_Response.FileUploadResult('document2.pdf', 'Failed')
        );
        
        Assert.areEqual(2, response.fileUploadContent.size());
        Assert.areEqual('document1.pdf', response.fileUploadContent[0].fileName);
        Assert.areEqual('Success', response.fileUploadContent[0].status);
    }

    /**
     * @description Test multiple errors in single ErrorContent
     */
    @isTest
    static void testErrorContentMultipleErrors() {
        Core_MDF_PFR_RestAPI_Response.ErrorContent error = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        error.pfrName = 'Activity 123';
        error.errors.add('ERR-9020: Campaign ID is required.');
        error.errors.add('ERR-9030: Activity Category invalid.');
        error.errors.add('ERR-9040: Priority mismatch.');
        
        List<Core_MDF_PFR_RestAPI_Response.ErrorDetail> details = error.errorDetails;
        
        Assert.areEqual(3, details.size());
        Assert.areEqual('Campaign ID is required.', details[0].message.substring(0, 24));
    }

    /**
     * @description Test toErrorDetail with all mapped error codes
     */
    @isTest
    static void testToErrorDetailAllMappedCodes() {
        List<String> errorCodes = new List<String>{
            'ERR-9030', 'ERR-9031', 'ERR-9032', 'ERR-9033', 'ERR-9034',
            'ERR-9040', 'ERR-9041', 'ERR-9042', 'ERR-9043', 'ERR-9050'
        };
        
        for (String errorCode : errorCodes) {
            String rawError = errorCode + ': Test error message.';
            Core_MDF_PFR_RestAPI_Response.ErrorDetail detail = Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError);
            
            Assert.areEqual(errorCode, detail.code);
            Assert.isNotNull(detail.field, 'Field should be mapped for ' + errorCode);
        }
    }

    /**
     * @description Test response JSON serialization
     */
    @isTest
    static void testResponseSerialization() {
        Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
        response.isSuccess = true;
        response.code = 'SUCCESS';
        response.message = 'Records created successfully';
        response.totalRecords = 1;
        
        String json = JSON.serialize(response);
        
        Assert.isNotNull(json);
        Assert.isTrue(json.containsIgnoreCase('isSuccess'));
        Assert.isTrue(json.containsIgnoreCase('SUCCESS'));
    }
}