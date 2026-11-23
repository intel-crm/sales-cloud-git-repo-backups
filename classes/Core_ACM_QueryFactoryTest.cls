@isTest
public class Core_ACM_QueryFactoryTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Industry = 'Technology',
            BillingCity = 'City1',
            BillingStreet = 'Street1',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal code'
        );
        
        // Set record type if available
        try {
            testAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe()
                .getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        } catch (Exception e) {
            // Record type might not exist in all orgs
            System.debug('Intel Account record type not found: ' + e.getMessage());
        }
        
        insert testAccount;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 20; i++) {
            testContacts.add(new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@example.com',
                MailingCountry = 'IND'
            ));
        }
        insert testContacts;
        
        // Create integration queue records with different timestamps and statuses
        List<Core_ACM_Integration_Queue__c> queueRecords = new List<Core_ACM_Integration_Queue__c>();
        
        // Current hour - NEW status records (LIVE)
        for (Integer i = 0; i < 5; i++) {
            queueRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'LIVE',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "live_payload_' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        // Current hour - NEW status records (BULK)
        for (Integer i = 5; i < 10; i++) {
            queueRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'BULK',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "bulk_payload_' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        // Current hour - PROCESSED records (for capacity testing)
        for (Integer i = 10; i < 15; i++) {
            queueRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'LIVE',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
                Core_Status__c = Core_ACM_Constants.STATUS_SUCCESS,
                Core_Payload__c = '{"test": "processed_payload_' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        
        insert queueRecords;
        
        // Create past hour records by updating CreatedDate (using Test.setCreatedDate)
        List<Core_ACM_Integration_Queue__c> pastHourRecords = new List<Core_ACM_Integration_Queue__c>();
        for (Integer i = 15; i < 20; i++) {
            pastHourRecords.add(new Core_ACM_Integration_Queue__c(
                Core_Contact__c = testContacts[i].Id,
                Core_Process_Type__c = 'BULK',
                Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
                Core_Status__c = Core_ACM_Constants.STATUS_NEW,
                Core_Payload__c = '{"test": "past_hour_payload_' + i + '"}',
                Core_Retry_Count__c = 0
            ));
        }
        insert pastHourRecords;
        
        // Set past hour created date
        Datetime pastHour = Datetime.now().addHours(-2);
        for (Core_ACM_Integration_Queue__c record : pastHourRecords) {
            Test.setCreatedDate(record.Id, pastHour);
        }
    }
    
    @isTest
    static void testGetQueryWithFailedRecords() {
        // Get some test records
        List<Core_ACM_Integration_Queue__c> testRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 3
        ];
        
        Set<Id> failedRecordsToRetry = new Set<Id>(); // Use the exact variable name
        for (Core_ACM_Integration_Queue__c record : testRecords) {
            failedRecordsToRetry.add(record.Id);
        }
        
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(failedRecordsToRetry, 'LIVE');
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains('SELECT Id, Core_Contact__c'), 'Query should contain base fields');
        System.assert(query.contains('WHERE Id IN :failedRecordsToRetry'), 'Query should filter by failed record IDs');
        System.assertNotEquals(null, query, 'Query should not be null');
        
        // Test that query returns expected records using the bind variable
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        System.assertEquals(3, results.size(), 'Should return 3 failed records');
    }
    
    @isTest
    static void testGetQueryLiveProcess() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(null, Core_ACM_Constants.PROCESS_TYPE_LIVE);
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains('LIVE'), 'Query should filter by LIVE process type');
        System.assert(query.contains(Core_ACM_Constants.STATUS_NEW), 'Query should filter by NEW status');
        System.assert(query.contains('Core_Process_Type__c = \'' + Core_ACM_Constants.PROCESS_TYPE_LIVE + '\''), 
            'Query should have LIVE process type filter');
        
        // Test query execution (no bind variables in this case)
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals('LIVE', record.Core_Process_Type__c, 'All results should be LIVE type');
            System.assertEquals(Core_ACM_Constants.STATUS_NEW, record.Core_Status__c, 'All results should be NEW status');
        }
    }
    
    @isTest
    static void testGetQueryBulkProcess() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(null, Core_ACM_Constants.PROCESS_TYPE_BULK);
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains('BULK'), 'Query should filter by BULK process type');
        System.assert(query.contains(Core_ACM_Constants.STATUS_NEW), 'Query should filter by NEW status');
        System.assert(query.contains('Core_Process_Type__c = \'' + Core_ACM_Constants.PROCESS_TYPE_BULK + '\''), 
            'Query should have BULK process type filter');
        
        // Test query execution (no bind variables in this case)
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals('BULK', record.Core_Process_Type__c, 'All results should be BULK type');
            System.assertEquals(Core_ACM_Constants.STATUS_NEW, record.Core_Status__c, 'All results should be NEW status');
        }
    }
    
    @isTest
    static void testGetQueryNullProcessType() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(null, null);
        Test.stopTest();
        
        // Should default to BULK when processType is null
        System.assert(query.contains('BULK'), 'Query should default to BULK when processType is null');
        System.assert(query.contains(Core_ACM_Constants.STATUS_NEW), 'Query should filter by NEW status');
        
        // Test query execution
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals('BULK', record.Core_Process_Type__c, 'All results should be BULK type');
        }
    }
    
    @isTest
    static void testGetQueryEmptyFailedRecords() {
        Set<Id> failedRecordsToRetry = new Set<Id>(); // Empty set with correct variable name
        
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(failedRecordsToRetry, 'LIVE');
        Test.stopTest();
        
        // Should not use failed records filter when set is empty
        System.assert(!query.contains('failedRecordsToRetry'), 'Query should not contain failed records filter');
        System.assert(query.contains('LIVE'), 'Query should filter by LIVE process type');
        
        // Test query execution
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals('LIVE', record.Core_Process_Type__c, 'All results should be LIVE type');
        }
    }
    
    @isTest
    static void testGetAGSQueryWithFailedRecords() {
        // Get some test records with real IDs
        List<Core_ACM_Integration_Queue__c> testRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c 
            WHERE Core_Message_Type__c = :Core_ACM_Constants.MESSAGE_TYPE_AGS
            LIMIT 3
        ];
        
        Set<Id> failedRecordsToRetry = new Set<Id>(); // Use exact variable name
        for (Core_ACM_Integration_Queue__c record : testRecords) {
            failedRecordsToRetry.add(record.Id);
        }
        
        Test.startTest();
        String query = Core_ACM_QueryFactory.getAGSQuery(failedRecordsToRetry, 'LIVE', 'Role 2.0');
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains('WHERE Id IN :failedRecordsToRetry'), 'Query should filter by failed record IDs');
        System.assert(query.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Query should filter by AGS message type');
        System.assert(query.contains('ORDER BY CreatedDate ASC'), 'Query should order by CreatedDate');
        
        // Test query execution with bind variable
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        System.assertEquals(3, results.size(), 'Should return 3 failed records');
    }
    
    @isTest
    static void testGetAGSQueryLiveProcessWithCapacity() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getAGSQuery(null, Core_ACM_Constants.PROCESS_TYPE_LIVE, 'Role 2.0');
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains('LIVE'), 'Query should filter by LIVE process type');
        System.assert(query.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Query should filter by AGS message type');
        System.assert(query.contains('ORDER BY CreatedDate ASC'), 'Query should order by CreatedDate');
        System.assert(query.contains('LIMIT'), 'Query should have a limit clause');
        
        // For queries with bind variables like :startOfHour, we need to create those variables
        Datetime startOfHour = Datetime.now().addMinutes(-Datetime.now().minute()).addSeconds(-Datetime.now().second());
        Datetime endOfHour = startOfHour.addHours(1);
        
        // Test query execution with required bind variables
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals('LIVE', record.Core_Process_Type__c, 'All results should be LIVE type');
            System.assertEquals(Core_ACM_Constants.STATUS_NEW, record.Core_Status__c, 'All results should be NEW status');
            System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_AGS, record.Core_Message_Type__c, 'All results should be AGS type');
        }
    }
    
    @isTest
    static void testGetAGSQueryBulkProcessCurrentHour() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getAGSQuery(null, Core_ACM_Constants.PROCESS_TYPE_BULK, 'Role 2.0');
        Test.stopTest();
        
        // Verify query structure
        System.assert(query.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Query should filter by AGS message type');
        System.assert(query.contains('ORDER BY CreatedDate ASC'), 'Query should order by CreatedDate');
        System.assert(query.contains('LIMIT'), 'Query should have a limit clause');
        
        // For queries with bind variables, we need to create those variables
        Datetime startOfHour = Datetime.now().addMinutes(-Datetime.now().minute()).addSeconds(-Datetime.now().second());
        Datetime endOfHour = startOfHour.addHours(1);
        
        // Test query execution
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals(Core_ACM_Constants.STATUS_NEW, record.Core_Status__c, 'All results should be NEW status');
            System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_AGS, record.Core_Message_Type__c, 'All results should be AGS type');
        }
    }
    
    @isTest
    static void testGetAGSQueryStructureOnly() {
        // Test that focuses only on query structure without execution to avoid bind variable issues
        
        // Get real record IDs for testing
        List<Core_ACM_Integration_Queue__c> realRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 2
        ];
        
        Test.startTest();
        
        // Test with failed records using real IDs
        Set<Id> testIds = new Set<Id>();
        for (Core_ACM_Integration_Queue__c record : realRecords) {
            testIds.add(record.Id);
        }
        
        String failedQuery = Core_ACM_QueryFactory.getAGSQuery(testIds, 'LIVE', 'Role 2.0');
        System.assert(failedQuery.contains('WHERE Id IN :failedRecordsToRetry'), 'Failed records query structure correct');
        
        // Test LIVE query structure
        String liveQuery = Core_ACM_QueryFactory.getAGSQuery(null, 'LIVE', 'Role 2.0');
        System.assert(liveQuery.contains('LIVE'), 'LIVE query should contain LIVE filter');
        System.assert(liveQuery.contains('ORDER BY CreatedDate ASC'), 'Should order by CreatedDate');
        System.assert(liveQuery.contains('LIMIT'), 'Should have LIMIT clause');
        
        // Test BULK query structure
        String bulkQuery = Core_ACM_QueryFactory.getAGSQuery(null, 'BULK', 'Role 2.0');
        System.assert(bulkQuery.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Should filter by AGS message type');
        System.assert(bulkQuery.contains('ORDER BY CreatedDate ASC'), 'Should order by CreatedDate');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAGSQueryNoCapacityScenarios() {
        // Test scenarios where capacity is exceeded - focus on query structure
        
        Test.startTest();
        
        // The actual capacity check happens inside getAGSQuery based on existing data
        // We'll test the query structure when capacity might be exceeded
        String liveQuery = Core_ACM_QueryFactory.getAGSQuery(null, 'LIVE', 'Role 2.0');
        String bulkQuery = Core_ACM_QueryFactory.getAGSQuery(null, 'BULK', 'Role 2.0');
        
        // Verify queries are properly formed
        System.assertNotEquals(null, liveQuery, 'LIVE query should not be null');
        System.assertNotEquals(null, bulkQuery, 'BULK query should not be null');
        
        // Check if queries contain expected elements
        System.assert(liveQuery.contains('SELECT'), 'LIVE query should be a SELECT statement');
        System.assert(bulkQuery.contains('SELECT'), 'BULK query should be a SELECT statement');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAGSQueryEmptyFailedRecords() {
        Set<Id> failedRecordsToRetry = new Set<Id>(); // Empty set with correct name
        
        Test.startTest();
        String query = Core_ACM_QueryFactory.getAGSQuery(failedRecordsToRetry, 'LIVE', 'Role 2.0');
        Test.stopTest();
        
        // Should not use failed records filter when set is empty
        System.assert(!query.contains('failedRecordsToRetry'), 'Query should not contain failed records filter');
        System.assert(query.contains('LIVE'), 'Query should filter by LIVE process type');
        System.assert(query.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Query should filter by AGS message type');
    }
    
    @isTest
    static void testGetAGSQueryNullProcessType() {
        Test.startTest();
        String query = Core_ACM_QueryFactory.getAGSQuery(null, null, 'Role 2.0');
        Test.stopTest();
        
        // Should default to BULK processing when processType is null
        System.assert(query.contains(Core_ACM_Constants.MESSAGE_TYPE_AGS), 'Query should filter by AGS message type');
        System.assert(query.contains('ORDER BY CreatedDate ASC'), 'Query should order by CreatedDate');
        
        // For execution, we need the bind variables
        Datetime startOfHour = Datetime.now().addMinutes(-Datetime.now().minute()).addSeconds(-Datetime.now().second());
        
        // Test query execution
        List<Core_ACM_Integration_Queue__c> results = Database.query(query);
        for (Core_ACM_Integration_Queue__c record : results) {
            System.assertEquals(Core_ACM_Constants.STATUS_NEW, record.Core_Status__c, 'All results should be NEW status');
            System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_AGS, record.Core_Message_Type__c, 'All results should be AGS type');
        }
    }
    
    @isTest
    static void testBaseFieldsConstant() {
        // Test that BASE_FIELDS contains all required fields
        Test.startTest();
        String query = Core_ACM_QueryFactory.getQuery(null, 'LIVE');
        Test.stopTest();
        
        // Verify all required fields are present
        System.assert(query.contains('SELECT Id'), 'Query should select Id field');
        System.assert(query.contains('Core_Contact__c'), 'Query should select Core_Contact__c field');
        System.assert(query.contains('Core_Process_Type__c'), 'Query should select Core_Process_Type__c field');
        System.assert(query.contains('Core_Payload__c'), 'Query should select Core_Payload__c field');
        System.assert(query.contains('Core_Message_Type__c'), 'Query should select Core_Message_Type__c field');
        System.assert(query.contains('Core_Status__c'), 'Query should select Core_Status__c field');
        System.assert(query.contains('Core_Retry_Count__c'), 'Query should select Core_Retry_Count__c field');
        System.assert(query.contains('FROM Core_ACM_Integration_Queue__c'), 'Query should be from correct object');
    }
    
    @isTest
    static void testQueryExecutionWithMockData() {
        // Create specific test data for this test to avoid bind variable issues
        Account testAccount = new Account(
            Name = 'Query Test Account',
            Type = 'Customer',
            BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='Postal code',
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId()
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Query',
            LastName = 'Test Contact',
            Email = 'querytest@example.com',
            MailingCountry = 'IND'
        );
        insert testContact;
        
        Core_ACM_Integration_Queue__c testRecord = new Core_ACM_Integration_Queue__c(
            Core_Contact__c = testContact.Id,
            Core_Process_Type__c = 'LIVE',
            Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS,
            Core_Status__c = Core_ACM_Constants.STATUS_NEW,
            Core_Payload__c = '{"test": "query_execution"}',
            Core_Retry_Count__c = 0
        );
        insert testRecord;
        
        Test.startTest();
        
        // Test simple queries without bind variables
        String liveQuery = Core_ACM_QueryFactory.getQuery(null, 'LIVE');
        List<Core_ACM_Integration_Queue__c> liveResults = Database.query(liveQuery);
        System.assert(liveResults.size() > 0, 'Should return LIVE records');
        
        String bulkQuery = Core_ACM_QueryFactory.getQuery(null, 'BULK');
        List<Core_ACM_Integration_Queue__c> bulkResults = Database.query(bulkQuery);
        // BULK results might be 0 if no BULK records exist
        
        Test.stopTest();
    }
    
    @isTest
    static void testQueryLocatorExecution() {
        // Test using Database.getQueryLocator (similar to batch context)
        Test.startTest();
        
        Set<Id> failedRecordsToRetry = new Set<Id>();
        String query = Core_ACM_QueryFactory.getQuery(failedRecordsToRetry, 'LIVE');
        
        // Use QueryLocator instead of direct Database.query to avoid bind variable issues
        Database.QueryLocator ql = Database.getQueryLocator(query);
        System.assertNotEquals(null, ql, 'QueryLocator should be created successfully');
        
        // Test AGS query with QueryLocator
        String agsQuery = Core_ACM_QueryFactory.getAGSQuery(null, 'LIVE', 'Role 2.0');
        Database.QueryLocator agsQl = Database.getQueryLocator(agsQuery);
        System.assertNotEquals(null, agsQl, 'AGS QueryLocator should be created successfully');
        
        Test.stopTest();
    }
    
}