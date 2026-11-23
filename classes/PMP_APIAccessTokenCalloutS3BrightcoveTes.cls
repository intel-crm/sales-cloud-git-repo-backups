@isTest
public class PMP_APIAccessTokenCalloutS3BrightcoveTes {
    @isTest static void getAccessTokenTest() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new PMP_APIMultipleCalloutS3BrightcoveTest());
        Http http = new Http(); 
        HttpRequest request1 = new HttpRequest(); 
        request1.setEndpoint('http://test.com/access_token'); 
        request1.setMethod('POST'); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    HttpResponse response = PMP_APICalloutS3Brightcove.getAccessToken();
    // Verify that the response received contains fake values
    String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{"name":"testreca","Access_Token":"Ajkcs"}';
    System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, response.getStatusCode());
    }

}