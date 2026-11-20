@isTest
public class SWS_DynamicMethodCallerTest {

    @isTest
    static void testCallMethodWithValidClassName() {
        // Arrange
        String className = 'SWS_UnrivalService';
        List<Object> methodParams = new List<Object>{'12345', 'https://example.com/service/accountID', 'testKey', 'testSecret'};

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Act
        Object result = SWS_DynamicMethodCaller.callMethod(className, methodParams);
     
        // Assert
        System.assertNotEquals(null, result, 'The result should not be null');
       // System.assertEquals('https://embed.example.com/preview?uid=0051J000006hoU6QAI', result, 'The EmbedURL should match the expected value');
    }

    @isTest
    static void testCallMethodWithInvalidClassName() {
        
        // Arrange
        String className = 'InvalidClassName';
        List<Object> methodParams = new List<Object>{'12345', 'https://example.com/service/accountID', 'testKey', 'testSecret'};

        // Act & Assert
        try {
             Object result = SWS_DynamicMethodCaller.callMethod(className, methodParams);
             
              System.assertEquals(null, result, 'The result should be null');           
        } catch (IllegalArgumentException e) {
           
            System.assertEquals('Class not found: ' + className, e.getMessage(), 'The exception message should match the expected value');
        }
        catch (Exception ex) {
           
            System.assertEquals('Class not found: ' + className, ex.getMessage(), 'The exception message should match the expected value');
        }
    }

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"KS_Embed_Preview": "https://embed.example.com/preview"}');
            return res;
        }
    }
}