/****************************************************************************************************************************************
* Class Name  : Pricing_QuoteAgentic_Utility_Test 
* Version     : 1.0   
* Created Date: 04-21-2026
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         Sinduja - 04-21-2026              Created Test Class for Pricing_QuoteAgentic_Utility   
*****************************************************************************************************************************************/
@isTest
public class Pricing_QuoteAgentic_Utility_Test {
    
    /***********************************************************************************************************
    Method Name:        testSendCDBPayload
    Description:        Test method for sendCDBPayload method - both success and exception scenarios
    @Added By:          Sinduja - 04-21-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @isTest
    public static void testSendCDBPayload() {
        // Test data setup
        String testPayload = '{"test": "data"}';
        String namedCredential = 'TestCredential';
        
        // Mock HTTP Response for success scenario
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        
        // Test successful callout
        HttpResponse response = Pricing_QuoteAgentic_Utility.sendCDBPayload(testPayload, namedCredential);
        
        Test.stopTest();
        
        // Assertions for success scenario
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        
        // Test exception scenario by passing null payload
        HttpResponse errorResponse = Pricing_QuoteAgentic_Utility.sendCDBPayload(null, namedCredential);
        System.assertEquals(503, errorResponse.getStatusCode(), 'Error response status code should be 503');
        System.assertEquals('APEX_EXCEPTION', errorResponse.getStatus(), 'Error response status should be APEX_EXCEPTION');
    }
    
    /***********************************************************************************************************
    Method Name:        testCreateCDBLogInstance
    Description:        Test method for createCDBLogInstance method
    @Added By:          Sinduja - 04-21-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @isTest
    public static void testCreateCDBLogInstance() {
        // Test data setup
        String integrationType = 'Test Integration';
        String recordId = 'TestRecord123';
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        Boolean isSuccess = true;
        Integer retryCounter = 1;
        
        Test.startTest();
        
        // Test successful log creation
        Core_CDB_Integration_Log__c logRecord = Pricing_QuoteAgentic_Utility.createCDBLogInstance(
            integrationType, recordId, mockResponse, isSuccess, retryCounter
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, logRecord, 'Log record should not be null');
        System.assertEquals('200', logRecord.Core_Status_Code__c, 'Status code should be 200');
        
        // Test failed log creation
        Core_CDB_Integration_Log__c failedLogRecord = Pricing_QuoteAgentic_Utility.createCDBLogInstance( integrationType, recordId, mockResponse, false, retryCounter );
        System.assertEquals('Failed', failedLogRecord.Core_Log_Status_Nm__c, 'Status should be Failed for unsuccessful operation');
    }
    
    /***********************************************************************************************************
    Method Name:        testCreateLogEntries
    Description:        Test method for createLogEntries method
    @Added By:          Sinduja - 04-21-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @isTest
    public static void testCreateLogEntries() {
        // Test data setup
        List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
        
        Map<String, String> logMap1 = new Map<String, String>();
        logMap1.put('Core_Origin__c', 'Test Origin');
        logMap1.put('Core_Severity__c', 'Critical');
        logMap1.put('Core_sObjectType__c', 'Test_Object__c');
        logMap1.put('Core_Project__c', 'Test Project');
        logMap1.put('Core_Message__c', 'Test Message');
        logMap1.put('Core_Details__c', 'Test Details');
        
        Map<String, String> logMap2 = new Map<String, String>();
        logMap2.put('Core_Origin__c', 'Test Origin 2');
        logMap2.put('Core_Severity__c', 'Warning');
        logMap2.put('Core_sObjectType__c', 'Test_Object2__c');
        logMap2.put('Core_Project__c', 'Test Project 2');
        logMap2.put('Core_Message__c', 'Test Message 2');
        
        coreLogMaps.add(logMap1);
        coreLogMaps.add(logMap2);
        
        Test.startTest();
        
        // Test log entries creation
        Pricing_QuoteAgentic_Utility.createLogEntries(coreLogMaps);
        
        Test.stopTest();
        
        // Query and verify log entries were created
        List<Core_Log_Entry__c> createdLogs = [SELECT Id, Core_Origin__c, Core_Severity__c, Core_sObjectType__c 
                                              FROM Core_Log_Entry__c 
                                              WHERE Core_Origin__c IN ('Test Origin', 'Test Origin 2')];
        
        System.assertEquals(2, createdLogs.size(), 'Two log entries should be created');
        
        // Test with empty list
        Pricing_QuoteAgentic_Utility.createLogEntries(new List<Map<String, String>>());
        
        // Test with null list
        Pricing_QuoteAgentic_Utility.createLogEntries(null);
        
        // No exceptions should be thrown for empty or null lists
        System.assert(true, 'Method should handle empty and null lists gracefully');
    }  
    /***********************************************************************************************************
    Method Name:        testUpdateRecordsList
    Description:        Test method for updateRecordsList with Quote failures
    @Added By:          Sinduja - 04-21-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @isTest
    public static void testUpdateRecordsList() {
        // Setup test data using similar pattern from reference
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        List<SBQQ__Quote__c> quotes;
        
        if (!adminUser.isEmpty()) {
            System.runAs(adminUser[0]) {
                Pricing_Test_Utility.createPriceBook();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
                Pricing_Test_Utility.createTemplate(adminUser[0].Id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
                insert accTeam;
                
                // Create quotes using utility method
                quotes = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2, salesRepUserList[0].Email, accountExecutiveUserList[0].Email);
            }
        }
        
        // Get the created quotes
        List<SBQQ__Quote__c> testQuotes = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 2];
        
        // Modify quotes to cause update error
        for (SBQQ__Quote__c quote : testQuotes) {
            quote.SBQQ__Account__c = '001000000000000'; // Invalid Id
        }
        
        Test.startTest();
        
        // Test updateRecordsList - will generate error and call collectAndLogDbErrors
        Pricing_QuoteAgentic_Utility.updateRecordsList( testQuotes, 'Id', 'Quote update failed for record: ', 'SBQQ__Quote__c');
        
        Test.stopTest();
        
        // Verify error log created
        List<Core_Log_Entry__c> logs = [SELECT Id FROM Core_Log_Entry__c WHERE Core_sObjectType__c = 'SBQQ__Quote__c'];
        System.assert(logs.size() > 0, 'Error log should be created for failed quote update');
    }
    
    /***********************************************************************************************************
    Method Name:        testUpsertCDBIntegrationLogList
    Description:        Test method for upsertCDBIntegrationLogList with failures
    @Added By:          Sinduja - 04-21-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @isTest
    public static void testUpsertCDBIntegrationLogList() {
        // Create CDB log with invalid data to force error
        Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
        logRec.Core_Record_Id__c = 'TestRecord001';
        logRec.Core_Status_Code__c = 'Very long status code that exceeds field length limit to cause upsert failure';
        
        Test.startTest();
        
        // This will trigger error handling in upsertCDBIntegrationLogList
        Pricing_QuoteAgentic_Utility.upsertCDBIntegrationLogList(new List<Core_CDB_Integration_Log__c>{logRec});
        
        Test.stopTest();
        
        // Verify error log created for failed upsert
        List<Core_Log_Entry__c> logs = [SELECT Id FROM Core_Log_Entry__c WHERE Core_sObjectType__c = 'Core_CDB_Integration_Log__c'];
        System.assert(logs.size() > 0, 'Error log should be created for failed CDB log upsert');
    }
    
    /***********************************************************************************************************
    Inner Class:        MockHttpResponseGenerator
    Description:        Mock class for HTTP callout testing
    ************************************************************************************************************/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}