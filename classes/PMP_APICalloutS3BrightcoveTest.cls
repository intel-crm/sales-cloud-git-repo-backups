@isTest
public class PMP_APICalloutS3BrightcoveTest{
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

    
    @isTest static void CreateVideoResponseTest() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new PMP_APIMultipleCalloutS3BrightcoveTest());
        Http http = new Http(); 
        HttpRequest request1 = new HttpRequest(); 
        request1.setEndpoint('http://test.com/videos'); 
        request1.setMethod('POST'); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    HttpResponse response = PMP_APICalloutS3Brightcove.CreateVideoResponse('123');
    // Verify that the response received contains fake values
    String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{"names", "my videos"}';
    System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, response.getStatusCode());
        
}
    @isTest static  void getUploadUrlTest() {
    // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PMP_APIMultipleCalloutS3BrightcoveTest());
        Http http = new Http(); 
        HttpRequest request1 = new HttpRequest(); 
        request1.setEndpoint('http://test.com/upload-urls');
        request1.setMethod('GET'); 
        // Call method to test
        HttpResponse result = PMP_APICalloutS3Brightcove.getUploadUrl('1234','54643','LET');
        // Verify mock response is not null
        System.assertNotEquals(null,result, 'The callout returned a null response.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        // Verify content type   
        System.assertEquals('application/json',result.getHeader('Content-Type'),'The content type value is not expected.');  
        // Verify the array contains 7 items     
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(result.getBody());
        System.assertEquals(7, results.size(), 'The array should only contain 7 items.');          
    }   
    
    @isTest static void submitDynamicIngestTest() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new PMP_APIMultipleCalloutS3BrightcoveTest());
        Http http = new Http(); 
        HttpRequest request1 = new HttpRequest(); 
        request1.setEndpoint('http://test.com/ingest-requests'); 
        request1.setMethod('POST'); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    HttpResponse response = PMP_APICalloutS3Brightcove.submitDynamicIngest('12332526','674556564');
    // Verify that the response received contains fake values
    String contentType = response.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue = '{"namessfd", "my videos upload"}';
    System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, response.getStatusCode());
  }

   

}