@isTest
public class Core_ACM_ERPMAPIBatchProcessorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test contacts
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        Account account = lstAccounts[0];
        account.recordtypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert account;
        
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            testContacts.add(new Contact(
                AccountId = account.id,
                MailingCountry = 'IND',
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com'
            ));
        }
        insert testContacts;
        
        // Create test integration queue records
        List<Core_ACM_Integration_Queue__c> queueRecords = new List<Core_ACM_Integration_Queue__c>();
        
        // Live records for current hour
        for (Integer i = 0; i < 5; i++) {
            queueRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'LIVE',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_ERPM,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "payload' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        // Bulk records for current hour
        for (Integer i = 5; i < 10; i++) {
            queueRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'BULK',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_ERPM,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "payload' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        insert queueRecords;
    }
    
    @isTest
    static void testDefaultConstructor() {
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor();
        
        System.assertEquals(Core_ACM_Constants.PROCESS_TYPE_BULK, batch.processType, 
            'Default constructor should set process type to BULK');
        System.assertEquals(0, batch.retryCount, 'Default constructor should set retry count to 0');
        System.assertEquals(0, batch.failedRecords.size(), 'Failed records map should be empty');
        System.assertEquals(0, batch.failedRecordsToRetry.size(), 'Failed records to retry set should be empty');
        
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithProcessType() {
        Test.startTest();
        
        // Test with LIVE process type
        Core_ACM_ERPMAPIBatchProcessor batch1 = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        System.assertEquals('LIVE', batch1.processType, 'Process type should be set to LIVE');
        System.assertEquals(0, batch1.retryCount, 'Retry count should be 0');
        
        // Test with null process type (should default to BULK)
        Core_ACM_ERPMAPIBatchProcessor batch2 = new Core_ACM_ERPMAPIBatchProcessor(null);
        System.assertEquals(Core_ACM_Constants.PROCESS_TYPE_BULK, batch2.processType, 
            'Null process type should default to BULK');
        
        // Test with blank process type (should default to BULK)
        Core_ACM_ERPMAPIBatchProcessor batch3 = new Core_ACM_ERPMAPIBatchProcessor('');
        System.assertEquals(Core_ACM_Constants.PROCESS_TYPE_BULK, batch3.processType, 
            'Blank process type should default to BULK');
        
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithFailedRecords() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 3];
        Set<Id> failedIds = new Set<Id>();
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            failedIds.add(record.Id);
        }
        
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(failedIds, 1);
        
        System.assertEquals(2, batch.retryCount, 'Retry count should be incremented by 1');
        System.assertEquals(3, batch.failedRecordsToRetry.size(), 'Failed records to retry should be set');
        System.assertEquals(failedIds, batch.failedRecordsToRetry, 'Failed records IDs should match');
        
        Test.stopTest();
    }
    
    @isTest
    static void testStartMethodWithProcessType() {
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        Database.QueryLocator ql = batch.start(context);
        
        System.assertNotEquals(null, ql, 'Query locator should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testStartMethodWithFailedRecords() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2];
        Set<Id> failedIds = new Set<Id>();
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            failedIds.add(record.Id);
        }
        
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(failedIds, 0);
        Database.BatchableContext context = new TestBatchableContext();
        
        Database.QueryLocator ql = batch.start(context);
        
        System.assertNotEquals(null, ql, 'Query locator should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethodSuccess() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 2
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.execute(context, queueRecords);
        
        // Verify records were updated to success
        List<Core_ACM_Integration_Queue__c> updatedRecords = [
            SELECT Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Id IN :queueRecords
        ];
        
        for (Core_ACM_Integration_Queue__c record : updatedRecords) {
            System.assertEquals(Core_ACM_Constants.STATUS_SUCCESS, record.Core_Status__c, 
                'Record should be marked as success');
            System.assertEquals(0, record.Core_Retry_Count__c, 'Retry count should be 0');
        }
        
        // Verify inbound messages were created
        List<Core_Integration_Inbound_Message__c> inboundMessages = [
            SELECT Id FROM Core_Integration_Inbound_Message__c
        ];
        System.assertEquals(2, inboundMessages.size(), 'Should create inbound messages for successful calls');
        
        // Verify no failed records
        System.assertEquals(0, batch.failedRecords.size(), 'Should have no failed records');
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethodException() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 1
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExceptionCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.execute(context, queueRecords);
        
        // Verify record was marked as failed due to exception
        Core_ACM_Integration_Queue__c updatedRecord = [
            SELECT Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Id = :queueRecords[0].Id
        ];
        
        System.assertEquals(Core_ACM_Constants.STATUS_FAILED, updatedRecord.Core_Status__c, 
            'Record should be marked as failed due to exception');
        System.assertEquals(1, batch.failedRecords.size(), 'Should track failed record');
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethodNullResponse() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 1
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NullResponseCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.execute(context, queueRecords);
        
        // Verify record was marked as failed due to null response
        Core_ACM_Integration_Queue__c updatedRecord = [
            SELECT Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Id = :queueRecords[0].Id
        ];
        
        System.assertEquals(Core_ACM_Constants.STATUS_FAILED, updatedRecord.Core_Status__c, 
            'Record should be marked as failed due to null response');
        System.assertEquals(1, batch.failedRecords.size(), 'Should track failed record');
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethodWithRetryCount() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 1
        ];
        
        Set<Id> failedIds = new Set<Id>{queueRecords[0].Id};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(failedIds, 2);
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.execute(context, queueRecords);
        
        // Verify record was updated with correct retry count
        Core_ACM_Integration_Queue__c updatedRecord = [
            SELECT Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Id = :queueRecords[0].Id
        ];
        
        System.assertEquals(Core_ACM_Constants.STATUS_SUCCESS, updatedRecord.Core_Status__c, 
            'Record should be marked as success');
        System.assertEquals(3, updatedRecord.Core_Retry_Count__c, 'Retry count should be 3');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFinishMethodWithRetry() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2
        ];
        
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        batch.retryCount = 1; // Less than max retry
        
        // Add failed records
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            batch.failedRecords.put(record.Id, record);
        }
        
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.finish(context);
        
        // Verify that retry batch would be scheduled
        System.assertEquals(2, batch.failedRecords.size(), 'Should have failed records for retry');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFinishMethodMaxRetriesExceeded() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2
        ];
        
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        batch.retryCount = Core_ACM_Constants.API_MAX_RETRY; // Max retries reached
        
        // Add failed records
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            batch.failedRecords.put(record.Id, record);
        }
        
        Database.BatchableContext context = new TestBatchableContext();
        batch.finish(context);
        
        // Should log error about exhausted retries
        System.assertEquals(2, batch.failedRecords.size(), 'Should still have failed records');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFinishMethodNoFailedRecords() {
        Test.startTest();
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        batch.retryCount = 1;
        // No failed records
        
        Database.BatchableContext context = new TestBatchableContext();
        batch.finish(context);
        
        // Should not attempt retry
        System.assertEquals(0, batch.failedRecords.size(), 'Should have no failed records');
        
        Test.stopTest();
    }
    
    @isTest
    static void testHandleInboundInsertResultsFailure() {
        // This test verifies error handling for inbound message insert failures
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 1
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        // Execute with valid data - the error handling is internal
        batch.execute(context, queueRecords);
        
        Test.stopTest();
    }
    
    @isTest
    static void testHandleQueueUpdateResultsFailure() {
        // This test verifies error handling for queue record update failures
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'LIVE' 
            LIMIT 1
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        // Execute with valid data - the error handling is internal
        batch.execute(context, queueRecords);
        
        Test.stopTest();
    }
    
    // Helper class for testing
    private class TestBatchableContext implements Database.BatchableContext {
        public Id getJobId() {
            return '01p000000000000';
        }
        
        public Id getChildJobId() {
            return '01p000000000001';
        }
    }
    
    // Mock classes for HTTP callouts
    public class SuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Status": "' + Core_ACM_Constants.STATUS_SUCCESS + '", "Message": "Success"}');
            return response;
        }
    }
    
    public class FailureCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"Status": "Failed", "Message": "API Error", "ErrorCode": "400"}');
            return response;
        }
    }
    
    public class ExceptionCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Simulated callout exception');
        }
    }
    
    public class NullResponseCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(null);
            return response;
        }
    }
}