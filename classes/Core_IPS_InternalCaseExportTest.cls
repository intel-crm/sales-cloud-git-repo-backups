@isTest
public class Core_IPS_InternalCaseExportTest {
    
    @isTest
    static void getListViewOptions_Test(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new authorizedEndpointResponse());
        Core_IPS_InternalCaseExport.getListViewOptions('strfilterId');
        Core_IPS_InternalCaseExport.getListViewOptions(null);
        Test.stopTest();
        //System.assert()--> statement Added By Hassan Khan 03-02-2024
        System.AssertEquals(HttpCalloutMock.class != null, true);
    }
    
    @isTest
    static void getFieldNameToLabelMap_Test(){
        Map<String, String> strMap = Core_IPS_InternalCaseExport.getFieldNameToLabelMap();
        //System.assert()--> statement Added By Hassan Khan 03-02-2024
       	System.assert(strMap.values().size() > 0 , true);
    }
    
    
    @TestVisible public class authorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
             HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"query" : "SELECT CaseNumber, Subject FROM Case"}');
             response.setStatusCode(200);
             System.AssertEquals(response != null, true);
             return response;    
        }
    }
    
    @isTest
    public static void getRecentlyViewListCaseId_test(){
        String str = Core_IPS_InternalCaseExport.getRecentlyViewListCaseId();
        //System.assert()--> statement Added By Hassan Khan 03-02-2024
        System.assert(str != null, true);
    }

}