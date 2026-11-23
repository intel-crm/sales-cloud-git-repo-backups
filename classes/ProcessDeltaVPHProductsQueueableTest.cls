/***************************************************************************************************************************
* Apex Class Name  : ProcessDeltaVPHProductsQueueableTest
* Author And Date  : Rohit Podder, 23 MAR 2026
* Function         : Test class for ProcessDeltaVPHProductsQueueable
****************************************************************************************************************************/
@isTest
private class ProcessDeltaVPHProductsQueueableTest {
 
    private class MockHttpCallout implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
 
        MockHttpCallout(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
 
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
 
    private static String buildHierarchyResponse() {
        return '{"count":"1 records","hierarchy":[{' +
            '"l1":"1201","l1Name":"Processors",' +
            '"l2":"1202","l2Name":"Desktop",' +
            '"l3":"1203","l3Name":"i7",' +
            '"l4":"1204","l4Name":"12th Gen",' +
            '"l5":"1205","l5Name":"i7-12700K",' +
            '"l5_is_active":0,' +
            '"dataSource":"pim",' +
            '"L4RestrictionLevel":null,' +
            '"attributes":{},' +
            '"mm_details":null' +
            '}]}';
    }
 
    private static String buildEmptyHierarchyResponse() {
        return '{"count":"0 records","hierarchy":[]}';
    }
 
    @isTest
    static void testHierarchyProduct_Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, buildHierarchyResponse()));
 
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201','1234'}));
        Test.stopTest();
 
        List<Product_Inbound_Staging__c> records = [SELECT Id,Core_IsActive__c FROM Product_Inbound_Staging__c];
        Assert.areEqual(1, records.size(), 'Should create 1 staging record');
        Assert.areEqual(false, records[0].Core_IsActive__c, 'Inactive product should have Core_IsActive__c = false');
    }
 
    @isTest
    static void testHierarchyProduct_NonSuccessResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(500, 'Error'));
 
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
 
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'No staging records on API failure');
    }
 
    @isTest
    static void testHierarchyProduct_EmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, buildEmptyHierarchyResponse()));
 
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
 
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'No staging records for empty response');
    }
 
    @isTest
    static void testHierarchyProduct_MmOnlyDataSourceExcluded() {
        String response = '{"count":"1 records","hierarchy":[{' +
            '"l1":"1201","l1Name":"Processors",' +
            '"l2":"1202","l2Name":"Desktop",' +
            '"l3":"1203","l3Name":"i7",' +
            '"l4":"1204","l4Name":"12th Gen",' +
            '"l5":"1205","l5Name":"i7-12700K",' +
            '"l5_is_active":1,' +
            '"dataSource":"mm_only",' +
            '"L4RestrictionLevel":null,' +
            '"attributes":{},' +
            '"mm_details":null' +
            '}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, response));
 
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
 
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'mm_only records should be excluded');
    }
  
    @isTest
    static void testContinuationConstructor() {
        ProcessDeltaVPHProductsQueueable q = new ProcessDeltaVPHProductsQueueable(
            0,
            new Set<String>{'1201'},
            '12345',
            new List<Product_Inbound_Staging__c>()
        );
        Assert.isNotNull(q, 'Continuation constructor should work');
    }
 
    @isTest
    static void testCustomException() {
        try {
            throw new ProcessDeltaVPHProductsQueueable.CustomException('Test error');
        } catch (ProcessDeltaVPHProductsQueueable.CustomException e) {
            Assert.areEqual('Test error', e.getMessage(), 'Custom exception message should match');
        }
    }
}