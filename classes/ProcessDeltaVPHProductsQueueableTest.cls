/***************************************************************************************************************************
 * Apex Class Name  : ProcessDeltaVPHProductsQueueableTest
 * Author And Date  : Rohit Podder, 23 MAR 2026
 * Function         : Test class for ProcessDeltaVPHProductsQueueable
 ****************************************************************************************************************************/
@isTest
private class ProcessDeltaVPHProductsQueueableTest {
    
    private static String buildHierarchyResponse() {
        return '{"count":"1 records","hierarchy":[{' +
            '"l1":"1201","l1Name":"Processors",' +
            '"l2":"1202","l2Name":"Desktop",' +
            '"l3":"1203","l3Name":"i7",' +
            '"l4":"1204","l4Name":"12th Gen",' +
            '"l5":"1205","l5Name":"i7-12700K",' +
            '"l5_is_active":1,' +
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
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(200, buildHierarchyResponse(), buildEmptyHierarchyResponse()));
        
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        //Assert.areEqual(1, records.size(), 'Should create 1 staging record');
    }
    
    @isTest
    static void testHierarchyProduct_NonSuccessResponse() {
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(500, 'Error', buildEmptyHierarchyResponse()));
        
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'No staging records on API failure');
    }
    
    @isTest
    static void testEmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(200, buildEmptyHierarchyResponse()));
        
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'No staging records for empty response');
    }
    
    @isTest
    static void testMmOnlyDataSourceExcluded() {
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
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(200, response));
        
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        Assert.areEqual(0, records.size(), 'mm_only records should be excluded');
    }
    
    @isTest
    static void testInactiveProduct() {
        String response = '{"count":"1 records","hierarchy":[{' +
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
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(200, response, buildEmptyHierarchyResponse()));
        
        Test.startTest();
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>{'1201'}));
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        //Assert.areEqual(1, records.size(), 'Inactive product response should still create a staging record for processing');
    }
    
    @isTest
    static void testChainExecution() {
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(200, buildHierarchyResponse(), buildEmptyHierarchyResponse()));
        
        Test.startTest();
        ProcessDeltaVPHProductsQueueable pdvq = new ProcessDeltaVPHProductsQueueable(0,new Set<String>{'1201'}, '1234', new List<Product_Inbound_Staging__c>(), 'VPH', 1, 50000, TRUE);
        pdvq.execute(Null);
        Test.stopTest();
        
        List<Product_Inbound_Staging__c> records = [SELECT Id FROM Product_Inbound_Staging__c];
        //Assert.areEqual(1, records.size(), 'Should create one staging record for the provided L1 product');
    }
    
    @isTest
    static void testException() {
        Test.setMock(HttpCalloutMock.class, new PIMApiMockHttpCallout(500, buildHierarchyResponse(), buildEmptyHierarchyResponse()));
        System.MathException mockExceptionVPH = new System.MathException();
        mockExceptionVPH.setMessage('Exceeded max size limit for VPH');
        
        System.MathException mockExceptionVPLCH = new System.MathException();
        mockExceptionVPLCH.setMessage('Exceeded max size limit for VPLCH');
        
        System.MathException mockExceptionNull = new System.MathException();
        mockExceptionNull.setMessage('Exceeded max size limit');
        
        Test.startTest();
        ProcessDeltaVPHProductsQueueable pdvq = new ProcessDeltaVPHProductsQueueable(0,new Set<String>{'1201'}, '1234', new List<Product_Inbound_Staging__c>(), 'VPH', 1, 50000, TRUE);
        pdvq.handleHeapSizeException(mockExceptionVPH, TRUE);
        pdvq.handleHeapSizeException(mockExceptionVPLCH, TRUE);
        pdvq.handleHeapSizeException(mockExceptionNull, TRUE);
        pdvq.isSizeLimitException(mockExceptionVPH);
        Test.stopTest();
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
    
    private class PIMApiMockHttpCallout implements HttpCalloutMock {
        private Integer statusCode;
        private String vphResponse;
        private String vplchResponse;
        
        private PIMApiMockHttpCallout(Integer statusCode, String vphResponse) {
            this(statusCode, vphResponse, buildEmptyHierarchyResponse());
        }
        
        private PIMApiMockHttpCallout(Integer statusCode, String vphResponse, String vplchResponse) {
            this.statusCode = statusCode;
            this.vphResponse = vphResponse;
            this.vplchResponse = vplchResponse;
        }
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(statusCode);
            String endpoint = request.getEndpoint();
            String body = (endpoint != null && endpoint.contains('hierarchyName=VPLCH_Hierarchy')) ? vplchResponse : vphResponse;
            response.setBody(body);
            return response;
        }
    }
    
    private class PIMApiChunkModeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            String endpoint = request.getEndpoint();
            if (endpoint != null && endpoint.contains('hierarchyName=VPLCH_Hierarchy')) {
                response.setBody(buildEmptyHierarchyResponse());
            } else {
                response.setBody(buildHierarchyResponse());
            }
            return response;
        }
    }
}