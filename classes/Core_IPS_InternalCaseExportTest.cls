@isTest
public class Core_IPS_InternalCaseExportTest {
    
    @isTest
    static void getListViewOptions_Test(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new authorizedEndpointResponse());
        Core_IPS_InternalCaseExport.getListViewOptions('strfilterId');
        Core_IPS_InternalCaseExport.getListViewOptions(null);
        Test.stopTest();
    }
    
    @isTest
    static void getFieldNameToLabelMap_Test(){
       Core_IPS_InternalCaseExport.getFieldNameToLabelMap();
    }
    
    
    @TestVisible public class authorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
             HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"query" : "SELECT CaseNumber, Subject FROM Case"}');
             response.setStatusCode(200);
             return response;    
        }
    }
    
    @isTest
    public static void getRecentlyViewListCaseId_test(){
        Core_IPS_InternalCaseExport.getRecentlyViewListCaseId();
    }

}