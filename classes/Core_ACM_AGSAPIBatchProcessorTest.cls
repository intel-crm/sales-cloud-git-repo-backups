@isTest
public class Core_ACM_AGSAPIBatchProcessorTest {
    
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
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
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
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "payload' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        insert queueRecords;
    }
    
    @isTest
    static void testConstructors() {
        Test.startTest();
        
        // Test default constructor
        Core_ACM_AGSAPIBatchProcessor batch1 = new Core_ACM_AGSAPIBatchProcessor();
        System.assertEquals(0, batch1.retryCount, 'Default constructor should set retry count to 0');
        
        // Test constructor with process type
        Core_ACM_AGSAPIBatchProcessor batch2 = new Core_ACM_AGSAPIBatchProcessor('LIVE');
        System.assertEquals('LIVE', batch2.processType, 'Process type should be set correctly');
        System.assertEquals(0, batch2.retryCount, 'Retry count should be 0');
        System.assertEquals('Role 2.0', batch2.source, 'Source should be set to Role 2.0');
        
        // Test constructor with failed records
        Set<Id> failedIds = new Set<Id>();
        List<Core_ACM_Integration_Queue__c> queueRecords = [SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2];
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            failedIds.add(record.Id);
        }
        
        Core_ACM_AGSAPIBatchProcessor batch3 = new Core_ACM_AGSAPIBatchProcessor(failedIds, 1);
        System.assertEquals(2, batch3.retryCount, 'Retry count should be incremented');
        System.assertEquals(2, batch3.failedRecordsToRetry.size(), 'Failed records should be set');
        
        Test.stopTest();
    }
    
    @isTest
    static void testStartMethodLiveProcess() {
        Test.startTest();
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
        Database.BatchableContext context = new TestBatchableContext();
        
        Database.QueryLocator ql = batch.start(context);
        System.assertNotEquals(null, ql, 'Query locator should not be null');
        System.assert(batch.query.contains('LIVE'), 'Query should contain LIVE process type');
        
        Test.stopTest();
    }
    
    @isTest
    static void testStartMethodBulkProcess() {
        Test.startTest();
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('BULK');
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
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor(failedIds, 0);
        batch.processType = 'LIVE'; // Set process type for retry scenario
        Database.BatchableContext context = new TestBatchableContext();
        
        Database.QueryLocator ql = batch.start(context);
        System.assertNotEquals(null, ql, 'Query locator should not be null');
        System.assert(batch.query.contains('failedRecordsToRetry'), 'Query should contain failed records filter');
        
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
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
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
        }
        
        // Verify inbound messages were created
        List<Core_Integration_Inbound_Message__c> inboundMessages = [
            SELECT Id FROM Core_Integration_Inbound_Message__c
        ];
        System.assertEquals(2, inboundMessages.size(), 'Should create inbound messages for successful calls');
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethodFailure() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, 
                   Core_Message_Type__c, Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Process_Type__c = 'BULK' 
            LIMIT 2
        ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FailureCalloutMock());
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('BULK');
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.execute(context, queueRecords);
        
        // Verify records were marked as failed
        List<Core_ACM_Integration_Queue__c> updatedRecords = [
            SELECT Core_Status__c, Core_Retry_Count__c 
            FROM Core_ACM_Integration_Queue__c 
            WHERE Id IN :queueRecords
        ];
        
        for (Core_ACM_Integration_Queue__c record : updatedRecords) {
            System.assertEquals(Core_ACM_Constants.STATUS_FAILED, record.Core_Status__c, 
                'Record should be marked as failed');
        }
        
        System.assertEquals(2, batch.failedRecords.size(), 'Should track failed records');
        
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
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
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
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
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
    static void testFinishMethodWithRetry() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2
        ];
        
        Test.startTest();
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
        batch.retryCount = 1; // Less than max retry
        
        // Add failed records
        for (Core_ACM_Integration_Queue__c record : queueRecords) {
            batch.failedRecords.put(record.Id, record);
        }
        
        Database.BatchableContext context = new TestBatchableContext();
        
        batch.finish(context);
        
        // Verify that retry batch would be executed
        System.assertEquals(2, batch.failedRecords.size(), 'Should have failed records for retry');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFinishMethodMaxRetriesExceeded() {
        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2
        ];
        
        Test.startTest();
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
        batch.retryCount = 10; // Assuming this exceeds max retry
        
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
        
        Core_ACM_AGSAPIBatchProcessor batch = new Core_ACM_AGSAPIBatchProcessor('LIVE');
        batch.retryCount = 1;
        // No failed records
        
        Database.BatchableContext context = new TestBatchableContext();
        batch.finish(context);
        
        // Should not attempt retry
        System.assertEquals(0, batch.failedRecords.size(), 'Should have no failed records');
        
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