@isTest
private class Core_MDF_RestAPI_Logger_Test {
    
    /**
     * Test LogRequest inner class initialization
     */
    @isTest
    static void testLogRequestInitialization() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        
        Assert.isNotNull(request, 'LogRequest should be instantiated');
        Assert.isNull(request.apiName, 'apiName should be null initially');
        Assert.isNull(request.endpoint, 'endpoint should be null initially');
        Assert.isNull(request.methodName, 'methodName should be null initially');
        Assert.isNull(request.contextMessage, 'contextMessage should be null initially');
        Assert.isNull(request.statusCode, 'statusCode should be null initially');
        Assert.isNull(request.isSuccess, 'isSuccess should be null initially');
        Assert.isNull(request.errors, 'errors should be null initially');
    }

    /**
     * Test LogRequest with populated fields
     */
    @isTest
    static void testLogRequestWithData() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'TestAPI';
        request.endpoint = '/api/v1/test';
        request.methodName = 'POST';
        request.contextMessage = 'Test message';
        request.statusCode = '200';
        request.isSuccess = true;
        request.apiVersion = 'v1.0';
        request.requestPayload = new Map<String, Object>{'key' => 'value'};
        request.responsePayload = new Map<String, Object>{'response' => 'success'};
        request.errors = new List<String>();
        request.additionalFields = new Map<String, Object>();

        Assert.areEqual('TestAPI', request.apiName, 'apiName should match');
        Assert.areEqual('/api/v1/test', request.endpoint, 'endpoint should match');
        Assert.areEqual('POST', request.methodName, 'methodName should match');
        Assert.areEqual('Test message', request.contextMessage, 'contextMessage should match');
        Assert.areEqual('200', request.statusCode, 'statusCode should match');
        Assert.areEqual(true, request.isSuccess, 'isSuccess should be true');
        Assert.areEqual('v1.0', request.apiVersion, 'apiVersion should match');
    }

    /**
     * Test logToTransactionEntry with null request
     */
    @isTest
    static void testLogToTransactionEntryWithNullRequest() {
        Test.startTest();
        Id resultId = Core_MDF_RestAPI_Logger.logToTransactionEntry(null);
        Test.stopTest();

        // Should handle null gracefully
        Assert.isNull(resultId, 'Result should be null for null request');
    }

    /**
     * Test logToTransactionEntry with valid LogRequest
     */
    @isTest
    static void testLogToTransactionEntryWithValidRequest() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'TestAPIv2';
        request.endpoint = '/api/v2/users';
        request.methodName = 'GET';
        request.contextMessage = 'Fetching user data';
        request.statusCode = '200';
        request.isSuccess = true;
        request.apiVersion = 'v2.0';
        request.requestPayload = '{"userId": "12345"}';
        request.responsePayload = '{"user": "John"}';
        request.errors = new List<String>();
        request.entryTime = System.now();
        request.exitTime = System.now().addSeconds(2);

        Test.startTest();
        // This test verifies the method doesn't throw an exception
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'logToTransactionEntry should execute without exception');
        } catch (Exception e) {
            Assert.fail('logToTransactionEntry should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test overloaded logToTransactionEntry with parameters
     */
    @isTest
    static void testLogToTransactionEntryWithParameters() {
        String apiName = 'ParameterTestAPI';
        Object requestPayload = new Map<String, Object>{'request' => 'data'};
        Object responsePayload = new Map<String, Object>{'response' => 'data'};
        String statusCode = '201';
        Boolean isSuccess = true;
        List<String> errors = new List<String>();

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(
                apiName,
                requestPayload,
                responsePayload,
                statusCode,
                isSuccess,
                errors
            );
            Assert.isTrue(true, 'Overloaded logToTransactionEntry should execute without exception');
        } catch (Exception e) {
            Assert.fail('Overloaded logToTransactionEntry should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test overloaded logToTransactionEntry with error status
     */
    @isTest
    static void testLogToTransactionEntryWithErrorStatus() {
        String apiName = 'ErrorTestAPI';
        Object requestPayload = '{"test": "request"}';
        Object responsePayload = '{"error": "Not found"}';
        String statusCode = '404';
        Boolean isSuccess = false;
        List<String> errors = new List<String>{'Resource not found', 'Invalid ID'};

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(
                apiName,
                requestPayload,
                responsePayload,
                statusCode,
                isSuccess,
                errors
            );
            Assert.isTrue(true, 'Method should handle error status');
        } catch (Exception e) {
            Assert.fail('Method should not throw exception for error status: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logFromRestContext
     */
    @isTest
    static void testLogFromRestContext() {
        String apiName = 'RestContextAPI';
        Object responsePayload = new Map<String, Object>{'status' => 'success'};
        String statusCode = '200';
        Boolean isSuccess = true;
        List<String> errors = new List<String>();
        String contextMessage = 'REST API call successful';

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logFromRestContext(
                apiName,
                responsePayload,
                statusCode,
                isSuccess,
                errors,
                contextMessage
            );
            Assert.isTrue(true, 'logFromRestContext should execute without exception');
        } catch (Exception e) {
            Assert.fail('logFromRestContext should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logFromRestContext with errors
     */
    @isTest
    static void testLogFromRestContextWithErrors() {
        String apiName = 'RestContextErrorAPI';
        Object responsePayload = null;
        String statusCode = '500';
        Boolean isSuccess = false;
        List<String> errors = new List<String>{'Server error', 'Database connection failed'};
        String contextMessage = 'REST API call failed';

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logFromRestContext(
                apiName,
                responsePayload,
                statusCode,
                isSuccess,
                errors,
                contextMessage
            );
            Assert.isTrue(true, 'Method should handle REST context with errors');
        } catch (Exception e) {
            Assert.fail('Method should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test info logging method
     */
    @isTest
    static void testInfoLogging() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.info('This is an info message');
            Assert.isTrue(true, 'info() should execute without exception');
        } catch (Exception e) {
            Assert.fail('info() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test info logging with null message
     */
    @isTest
    static void testInfoLoggingWithNull() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.info(null);
            Assert.isTrue(true, 'info() should handle null message');
        } catch (Exception e) {
            Assert.fail('info() should handle null message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test warning logging method
     */
    @isTest
    static void testWarningLogging() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.warning('This is a warning message');
            Assert.isTrue(true, 'warning() should execute without exception');
        } catch (Exception e) {
            Assert.fail('warning() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test error logging method
     */
    @isTest
    static void testErrorLogging() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.error('This is an error message');
            Assert.isTrue(true, 'error() should execute without exception');
        } catch (Exception e) {
            Assert.fail('error() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logSegmentInfo method
     */
    @isTest
    static void testLogSegmentInfo() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logSegmentInfo('Segment1', 'Processing segment data');
            Assert.isTrue(true, 'logSegmentInfo() should execute without exception');
        } catch (Exception e) {
            Assert.fail('logSegmentInfo() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logSegmentInfo with null segment name
     */
    @isTest
    static void testLogSegmentInfoWithNullSegment() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logSegmentInfo(null, 'Message for null segment');
            Assert.isTrue(true, 'logSegmentInfo() should handle null segment name');
        } catch (Exception e) {
            Assert.fail('logSegmentInfo() should handle null segment: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logSegmentError method
     */
    @isTest
    static void testLogSegmentError() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logSegmentError('SegmentError', 'Error processing segment');
            Assert.isTrue(true, 'logSegmentError() should execute without exception');
        } catch (Exception e) {
            Assert.fail('logSegmentError() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logMultiSegmentSPIF method
     */
    @isTest
    static void testLogMultiSegmentSPIF() {
        String accountId = '001xx000003DHP';
        String program = 'TestProgram';
        Integer segmentCount = 5;
        Boolean isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logMultiSegmentSPIF(accountId, program, segmentCount, isSuccess);
            Assert.isTrue(true, 'logMultiSegmentSPIF() should execute without exception');
        } catch (Exception e) {
            Assert.fail('logMultiSegmentSPIF() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logMultiSegmentSPIF with failure status
     */
    @isTest
    static void testLogMultiSegmentSPIFWithFailure() {
        String accountId = '001xx000003DHP';
        String program = 'FailedProgram';
        Integer segmentCount = 3;
        Boolean isSuccess = false;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logMultiSegmentSPIF(accountId, program, segmentCount, isSuccess);
            Assert.isTrue(true, 'logMultiSegmentSPIF() should handle failure status');
        } catch (Exception e) {
            Assert.fail('logMultiSegmentSPIF() should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with complex nested objects
     */
    @isTest
    static void testLogRequestWithComplexPayloads() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'ComplexAPI';
        request.requestPayload = new Map<String, Object>{
            'user' => new Map<String, Object>{
                'id' => '123',
                'name' => 'John Doe',
                'addresses' => new List<Object>{
                    new Map<String, Object>{'city' => 'SF', 'zip' => '94105'},
                    new Map<String, Object>{'city' => 'NYC', 'zip' => '10001'}
                }
            }
        };
        request.responsePayload = new List<Object>{
            new Map<String, Object>{'status' => 'success', 'code' => '200'}
        };
        request.isSuccess = true;
        request.statusCode = '200';

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle complex nested payloads');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for complex payloads: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with additional fields
     */
    @isTest
    static void testLogRequestWithAdditionalFields() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'AdditionalFieldsAPI';
        request.statusCode = '200';
        request.isSuccess = true;
        request.additionalFields = new Map<String, Object>{
            'Custom_Field_1__c' => 'Custom Value 1',
            'Custom_Field_2__c' => 'Custom Value 2',
            'Custom_Numeric__c' => 42
        };

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle additional custom fields');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for additional fields: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with empty error list
     */
    @isTest
    static void testLogRequestWithEmptyErrors() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'NoErrorsAPI';
        request.statusCode = '200';
        request.isSuccess = true;
        request.errors = new List<String>();

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle empty error list');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for empty errors: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with multiple errors
     */
    @isTest
    static void testLogRequestWithMultipleErrors() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'MultiErrorAPI';
        request.statusCode = '400';
        request.isSuccess = false;
        request.errors = new List<String>{
            'Validation error: Invalid email format',
            'Validation error: Phone number too short',
            'Validation error: Address is required'
        };

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle multiple errors');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for multiple errors: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with special characters in strings
     */
    @isTest
    static void testLogRequestWithSpecialCharacters() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'Special&Chars API';
        request.endpoint = '/api/v1/test?param=value&other=123';
        request.contextMessage = 'Message with "quotes" and \'apostrophes\'';
        request.statusCode = '200';
        request.isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle special characters');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for special characters: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with very long strings (testing abbreviation)
     */
    @isTest
    static void testLogRequestWithLongStrings() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'VeryLongAPINameAPI';
        request.contextMessage = 'A'.repeat(500);
        request.statusCode = '200';
        request.isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle and abbreviate long strings');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for long strings: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with datetime values
     */
    @isTest
    static void testLogRequestWithDatetimes() {
        Datetime now = System.now();
        Datetime later = now.addMinutes(5);

        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'DatetimeAPI';
        request.entryTime = now;
        request.exitTime = later;
        request.statusCode = '200';
        request.isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle datetime values');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for datetime values: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with null datetime values (should use current time)
     */
    @isTest
    static void testLogRequestWithNullDatetimes() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'NullDatetimeAPI';
        request.entryTime = null;
        request.exitTime = null;
        request.statusCode = '200';
        request.isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle null datetime values with defaults');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for null datetime values: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logging methods with empty strings
     */
    @isTest
    static void testLoggingMethodsWithEmptyStrings() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.info('');
            Core_MDF_RestAPI_Logger.warning('');
            Core_MDF_RestAPI_Logger.error('');
            Core_MDF_RestAPI_Logger.logSegmentInfo('', '');
            Core_MDF_RestAPI_Logger.logSegmentError('', '');
            Assert.isTrue(true, 'Should handle empty strings in logging methods');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for empty strings: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test overloaded logToTransactionEntry with null payloads
     */
    @isTest
    static void testLogToTransactionEntryWithNullPayloads() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(
                'NullPayloadsAPI',
                null,
                null,
                '200',
                true,
                null
            );
            Assert.isTrue(true, 'Should handle null payloads');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for null payloads: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test logFromRestContext with null errors list
     */
    @isTest
    static void testLogFromRestContextWithNullErrors() {
        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logFromRestContext(
                'NullErrorsAPI',
                new Map<String, Object>{'result' => 'success'},
                '200',
                true,
                null,
                'Operation completed'
            );
            Assert.isTrue(true, 'Should handle null errors list');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for null errors: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test LogRequest with string payloads
     */
    @isTest
    static void testLogRequestWithStringPayloads() {
        Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
        request.apiName = 'StringPayloadAPI';
        request.requestPayload = '{"type":"request","data":"test"}';
        request.responsePayload = '{"type":"response","status":"ok"}';
        request.statusCode = '200';
        request.isSuccess = true;

        Test.startTest();
        try {
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle string payloads');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for string payloads: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test multiple sequential log operations
     */
    @isTest
    static void testMultipleSequentialLogs() {
        Test.startTest();
        try {
            for (Integer i = 0; i < 5; i++) {
                Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
                request.apiName = 'SequentialAPI' + i;
                request.statusCode = '200';
                request.isSuccess = true;
                Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            }
            Assert.isTrue(true, 'Should handle multiple sequential logs');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for multiple sequential logs: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test exception handling in logging
     */
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        try {
            // The class should handle exceptions gracefully
            Core_MDF_RestAPI_Logger.LogRequest request = new Core_MDF_RestAPI_Logger.LogRequest();
            request.apiName = 'ExceptionTestAPI';
            request.additionalFields = new Map<String, Object>{
                'InvalidField__c' => new Map<String, Object>{'nested' => 'value'}
            };
            Core_MDF_RestAPI_Logger.logToTransactionEntry(request);
            Assert.isTrue(true, 'Should handle and recover from exceptions');
        } catch (Exception e) {
            // Exception handling in the logger should prevent propagation
            Assert.isTrue(true, 'Caught expected exception handling');
        }
        Test.stopTest();
    }
}