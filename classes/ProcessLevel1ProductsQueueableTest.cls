/***************************************************************************************************************************
* Apex Class Name  : ProcessLevel1ProductsQueueableTest
* Author And Date  : Rohit Podder, 23 MAR 2026
* Function         : Test class for ProcessLevel1ProductsQueueable
****************************************************************************************************************************/

@isTest
private class ProcessLevel1ProductsQueueableTest {
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
    
    private static String buildLevel1Response(Integer count, Integer limitVal) {
        return '{"categories":[' +
            '{"parentId":"root","sourceId":"873","Name":"Processors"},' +
            '{"parentId":"root","sourceId":"920","Name":"Chipsets"},' +
            '{"parentId":"873","sourceId":"999","Name":"ChildCategory"}' +
            '],"_metadata":{"count":' + count + ',"limit":' + limitVal + ',"offset":1}}';
    }
    
    @isTest
    static void testLevel1Products_Success() {
        String responseBody = buildLevel1Response(2, 5000);
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, responseBody));
        Test.startTest();
        System.enqueueJob(new ProcessLevel1ProductsQueueable());
        Test.stopTest();
        Assert.areEqual(2, Core_Level1_Products__c.getAll().values().size(),'All level 1 prodcuts has not been retrieved successfully');
    }
    
    @isTest
    
    static void testLevel1Products_WithExistingSetting() {
        Core_Level1_Products__c existing = new Core_Level1_Products__c();
        existing.Name = 'Processors';
        existing.Level_1_Id__c = '873';
        existing.Is_Active__c = true;
        insert existing;
        String responseBody = buildLevel1Response(2, 5000);
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, responseBody));
        Test.startTest();
        System.enqueueJob(new ProcessLevel1ProductsQueueable());
        Test.stopTest();
        Assert.areEqual(2, Core_Level1_Products__c.getAll().values().size(),'Should have 2 custom settings (1 existing + 1 new)');
    }
    
    @isTest
    static void testLevel1Products_DeactivatesOldSettings() {
        Core_Level1_Products__c old = new Core_Level1_Products__c();
        old.Name = 'OldProduct';
        old.Level_1_Id__c = '111';
        old.Is_Active__c = true;
        insert old;
        String responseBody = buildLevel1Response(2, 5000);
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, responseBody));
        Test.startTest();
        System.enqueueJob(new ProcessLevel1ProductsQueueable());
        Test.stopTest();
        Core_Level1_Products__c deactivated = [SELECT Is_Active__c FROM Core_Level1_Products__c WHERE Name = 'OldProduct'];
        
        Assert.areEqual(false, deactivated.Is_Active__c, 'Old product should be deactivated');
    }
    
    @isTest
    static void testLevel1Products_NonSuccessResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(500, 'Server Error'));
        Test.startTest();
        System.enqueueJob(new ProcessLevel1ProductsQueueable());
        Test.stopTest();
        Assert.areEqual(0, Core_Level1_Products__c.getAll().values().size(),'No custom settings should be created on API failure');
    }
    
    @isTest
    static void testLevel1Products_PaginatedResponse() {
        // Response with count > limit triggers pagination
        String responseBody = buildLevel1Response(10000, 5000);
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, responseBody));
        Test.startTest();
        System.enqueueJob(new ProcessLevel1ProductsQueueable());
        Test.stopTest();
        
        Assert.isTrue(Core_Level1_Products__c.getAll().values().size() > 0,'Should process paginated responses');
    }
    
    /*@isTest
    static void testConstructorWithDependencyInjection() {
        PIMApiService apiService = new PIMApiService();
        Level1ProductSettingService settingService = new Level1ProductSettingService();
        ProcessLevel1ProductsQueueable q = new ProcessLevel1ProductsQueueable(apiService, settingService);
        Assert.isNotNull(q, 'Should instantiate with injected dependencies');
    }**/
}