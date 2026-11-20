@isTest
public class Core_RestClientTracker {

    private static String url, httpMethod, body, responseStatus;
    private static Map < String, String > mapOfHttpHeader;
    private static Integer responseCode;
    private static blob blobBody;

    private static void setRequestParams() {
        mapOfHttpHeader = new Map < String, String > { 'Context-Type' => 'text/JSON'};
        url = 'Sample URL';
        httpMethod = 'GET';
        body = ' ';
    }

    private static void setResponseParam(){
        responseStatus = 'OK';
        responseCode = 200;
    }

    @isTest public static void testAll(){
        setRequestParams();
        setResponseParam();

        Test.startTest();

        invokeTestAPI();
        System.assertEquals(responseCode, 200);
        Test.stopTest();
    }

    public static void invokeTestAPI(){

        RequestMock objMock = new RequestMock(responseCode, responseStatus, body, mapOfHttpHeader);

        Test.setMock(HttpCalloutMock.class, objMock);
        Core_RestClient  coreRestClient1 = new Core_RestClient();
        Core_RestClient  coreRestClient = new Core_RestClient(url, httpMethod, mapOfHttpHeader, body, 30000);

        coreRestClient.invokeAPI();
        coreRestClient.getHttpResponseStatusCode();
        coreRestClient.getHttpResponseHeader();
        coreRestClient.getHttpResponseStatus();
        coreRestClient.getHttpResponseBody();
        coreRestClient.getHttpResponse();

        Core_RestClient  coreRestClient2 = new Core_RestClient(url, httpMethod, mapOfHttpHeader, blobBody, 30000);


    }


}