/***************************************************************************************************************************
 * Test Class: PIMApiServiceTest
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Test class for PIMApiService and mock implementations for dependency injection
 ****************************************************************************************************************************/
@isTest
public class PIMApiServiceTest {

    @isTest
    static void testGetHierarchyCategories() {
        Test.setMock(HttpCalloutMock.class, new PIMHierarchyCategoriesMock());
        Test.startTest();
        PIMApiService service = new PIMApiService();
        HttpResponse response = service.getHierarchyCategories(1, 5000);
        Test.stopTest();
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void testGetHierarchyLevelsVPH() {
        Test.setMock(HttpCalloutMock.class, new PIMHierarchyLevelsMock());
        Test.startTest();
        PIMApiService service = new PIMApiService();
        HttpResponse response = service.getHierarchyLevels('1001', 50000, 1, 'VPH');
        Test.stopTest();
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void testGetHierarchyLevelsVPLCH() {
        Test.setMock(HttpCalloutMock.class, new PIMHierarchyLevelsMock());
        Test.startTest();
        PIMApiService service = new PIMApiService();
        HttpResponse response = service.getHierarchyLevels(null, 50000, 1, 'VPLCH');
        Test.stopTest();
        System.assertEquals(200, response.getStatusCode());
    }

    // Mock for hierarchy categories endpoint
    public class PIMHierarchyCategoriesMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"_metadata":{"count":2,"limit":5000,"offset":1},"categories":[{"parentId":"root","sourceId":"1001","Name":"Product A"},{"parentId":"root","sourceId":"1002","Name":"Product B"}]}');
            return res;
        }
    }

    // Mock for hierarchy levels endpoint
    public class PIMHierarchyLevelsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"count":"10 records","hierarchy":[{"l1":"1001","l1Name":"L1 Name","l2":"2001","l2Name":"L2 Name","l3":"3001","l3Name":"L3 Name","l4":"4001","l4Name":"L4 Name","l5":"5001","l5Name":"L5 Name","l5_is_active":1,"dataSource":"pim","L4RestrictionLevel":null,"attributes":{},"mm_details":null}]}');
            return res;
        }
    }
}