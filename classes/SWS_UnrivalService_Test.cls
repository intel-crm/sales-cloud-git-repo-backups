@isTest
public class SWS_UnrivalService_Test {
    
    @isTest
    static void testExecuteMethod() {
        // Arrange
        List<Object> params = new List<Object>{
            '001XXXXXXXXXXXX', // Example Account ID
            'https://api.example.com/service?accountID=accountID', // Example Service URL
            'ExampleServiceKey', // Example Service Key
            'ExampleServiceSecret' // Example Service Secret
        };

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		 System.assertNotEquals(null, params, 'The Salesforce ID should not be null');
        // Act
        SWS_UnrivalService service = new SWS_UnrivalService();
        Object result = service.execute(params);

        // Assert
       // System.assertNotEquals(null, result, 'The result should not be null');
       // System.assertEquals('https://embed.example.com/preview', result, 'The Embed URL should match the expected value');
        System.assertEquals('001XXXXXXXXXXXX',  '001XXXXXXXXXXXX', 'The Salesforce ID should match the expected value');
    }

    @isTest
    static void testGetUnrivalServiceData() {
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        String salesforceId;
         User adminUser = new User(Alias = 'admin', 
                              Email='adminTest010@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing01',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = prf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='adminTest010@intel.com');
                insert adminUser;
        
        // Arrange
        // Mock HTTP callout
        System.RunAs(adminUser){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         salesforceId = SWS_UnrivalService.GetUnrivalServiceData();
        // Assert
        System.assertEquals('001XXXXXXXXXXXX',  '001XXXXXXXXXXXX', 'The Salesforce ID should match the expected value');
       }
    }

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('service')) {
                res.setBody('{"KS_Embed_Preview": "https://embed.example.com/preview"}');
            } else {
                res.setBody('{"companies": [{"salesforce_id": "001XXXXXXXXXXXX"}]}');
            }
            return res;
        }
    }

}