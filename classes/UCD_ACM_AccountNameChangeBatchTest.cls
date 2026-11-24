/***************************************************************************************************************************
 * Apex Class Name  : UCD_ACM_AccountNameChangeBatchTest
 * Author And Date  : Rohit Podder, 23 NOV 2026
 * Function         : Test class for UCD_ACM_AccountNameChangeBatch
 ****************************************************************************************************************************/
@isTest
private class UCD_ACM_AccountNameChangeBatchTest {

    private static final String MOCK_SUCCESS_BODY = '{"status":"Case Created"}';
    private static final String MOCK_FAILURE_BODY = '{"status":"Internal Server Error"}';

    // Configurable mock for the PEGA callout
    private class PegaCalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        PegaCalloutMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(statusCode);
            response.setBody(body);
            return response;
        }
    }

    private static Core_ACM_Account_Staging__c createStagingRecord(String actionReference) {
        Core_ACM_Account_Staging__c staging = new Core_ACM_Account_Staging__c();
        staging.AccountId__c = '001000000000001';
        staging.Account_Action_Refrence__c = actionReference;
        staging.Core_Action__c = 'NAME_UPDATE';
        staging.Core_Status__c = 'NEW';
        insert staging;
        return staging;
    }

    @isTest
    static void testBatchSuccess() {
        Core_ACM_Account_Staging__c staging = createStagingRecord('UCID-12345; New Account Name');
        Test.setMock(HttpCalloutMock.class, new PegaCalloutMock(200, MOCK_SUCCESS_BODY));

        Test.startTest();
        Id batchJobId = Database.executeBatch(new UCD_ACM_AccountNameChangeBatch(), 50);
        Test.stopTest();

        System.assertNotEquals(null, batchJobId, 'Batch job should be enqueued.');
        Core_ACM_Account_Staging__c result = [SELECT Core_Status__c, Status_Details__c FROM Core_ACM_Account_Staging__c WHERE Id = :staging.Id];
        System.assertEquals('COMPLETED', result.Core_Status__c, 'Record should be marked COMPLETED on a 200 response.');
        System.assertEquals(MOCK_SUCCESS_BODY, result.Status_Details__c, 'Response body should be stored in Status_Details__c.');
    }

    @isTest
    static void testBatchFailureTriggersRetry() {
        Core_ACM_Account_Staging__c staging = createStagingRecord('UCID-12345; New Account Name');
        Test.setMock(HttpCalloutMock.class, new PegaCalloutMock(500, MOCK_FAILURE_BODY));

        Test.startTest();
        Id batchJobId = Database.executeBatch(new UCD_ACM_AccountNameChangeBatch(), 50);
        Test.stopTest();

        System.assertNotEquals(null, batchJobId, 'Batch job should be enqueued.');
        Core_ACM_Account_Staging__c result = [SELECT Core_Status__c, Status_Details__c, Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE Id = :staging.Id];
        System.assertEquals('FAILED', result.Core_Status__c, 'Record should be marked FAILED on a non-200 response.');
        System.assertEquals(MOCK_FAILURE_BODY, result.Status_Details__c, 'Response body should be stored in Status_Details__c.');
        // The retry batches chained from finish() also execute in test context, exhausting all retries
        System.assertEquals(3, result.Core_Retry_Counter__c, 'Retry counter should reach 3 after the retry chain is exhausted.');
    }

    @isTest
    static void testRetryConstructorMaxRetriesReached() {
        Core_ACM_Account_Staging__c staging = createStagingRecord('UCID-12345; New Account Name');
        Test.setMock(HttpCalloutMock.class, new PegaCalloutMock(500, MOCK_FAILURE_BODY));

        Test.startTest();
        // retryCounter 2 -> internal retryCount becomes 3, so no further batch is chained
        Id batchJobId = Database.executeBatch(new UCD_ACM_AccountNameChangeBatch(new Set<Id>{ staging.Id }, 2), 50);
        Test.stopTest();

        System.assertNotEquals(null, batchJobId, 'Retry batch job should be enqueued.');
        Core_ACM_Account_Staging__c result = [SELECT Core_Status__c, Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE Id = :staging.Id];
        System.assertEquals('FAILED', result.Core_Status__c, 'Record should remain FAILED after the final retry.');
        System.assertEquals(3, result.Core_Retry_Counter__c, 'Retry counter should be incremented to 3 on the final retry.');
    }

    @isTest
    static void testExecuteExceptionHandling() {
        // No semicolon in the reference -> split()[1] throws and the catch block logs the error
        Core_ACM_Account_Staging__c staging = createStagingRecord('UCID-12345-NoSemicolon');
        Test.setMock(HttpCalloutMock.class, new PegaCalloutMock(200, MOCK_SUCCESS_BODY));

        Test.startTest();
        Id batchJobId = Database.executeBatch(new UCD_ACM_AccountNameChangeBatch(), 50);
        Test.stopTest();

        System.assertNotEquals(null, batchJobId, 'Batch job should be enqueued.');
        Core_ACM_Account_Staging__c result = [SELECT Core_Status__c FROM Core_ACM_Account_Staging__c WHERE Id = :staging.Id];
        System.assertEquals('NEW', result.Core_Status__c, 'Record should stay NEW when execute hits an exception.');
    }

    @isTest
    static void testMakeHttpRequestToPega() {
        Test.setMock(HttpCalloutMock.class, new PegaCalloutMock(200, MOCK_SUCCESS_BODY));

        Test.startTest();
        HttpResponse response = UCD_ACM_AccountNameChangeBatch.makeHttpRequestToPega('UCID-12345', 'New Account Name', 'test.user@intel.com');
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Mocked status code should be returned.');
        System.assertEquals(MOCK_SUCCESS_BODY, response.getBody(), 'Mocked body should be returned.');
    }
}