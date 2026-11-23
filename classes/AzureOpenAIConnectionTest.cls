public class AzureOpenAIConnectionTest {
    
    /**
     * Simple test method to check Azure OpenAI connection
     * Run this in Anonymous Apex to test your connection
     */
    public static void testConnection() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Set endpoint using Named Credential
            request.setEndpoint('callout:Azure_OpenAI_API/openai/deployments/gpt-4o/chat/completions?api-version=2023-03-15-preview');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('api-key', '95ec8b6ceb774ee3aaf968603c4c36b4'); // Manual API key header
            request.setTimeout(120000);
            
            // Simple test message
            Map<String, Object> requestBody = new Map<String, Object>{
                'messages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'role' => 'user',
                        'content' => 'Say hello'
                    }
                },
                'max_tokens' => 50,
                'temperature' => 0.1
            };
            
            request.setBody(JSON.serialize(requestBody));
            
            System.debug('=== AZURE OPENAI CONNECTION TEST ===');
            System.debug('Request URL: ' + request.getEndpoint());
            System.debug('Request Body: ' + request.getBody());
            
            // Make the call
            HttpResponse response = http.send(request);
            
            System.debug('Response Status Code: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
            
            if (response.getStatusCode() == 200) {
                System.debug('✅ SUCCESS: Azure OpenAI connection working!');
                
                // Parse the response to get the AI message
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> choices = (List<Object>) responseMap.get('choices');
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                    String content = (String) message.get('content');
                    System.debug('AI Response: ' + content);
                }
                
            } else {
                System.debug('❌ FAILED: HTTP ' + response.getStatusCode());
                System.debug('Error Details: ' + response.getBody());
                
                // Common error analysis
                if (response.getStatusCode() == 401) {
                    System.debug('💡 SOLUTION: Check your API key in Named Credential');
                } else if (response.getStatusCode() == 404) {
                    System.debug('💡 SOLUTION: Check your endpoint URL and deployment name');
                } else if (response.getStatusCode() == 429) {
                    System.debug('💡 SOLUTION: Rate limit exceeded, try again later');
                }
            }
            
        } catch (Exception e) {
            System.debug('❌ EXCEPTION: ' + e.getMessage());
            System.debug('💡 SOLUTION: Check Named Credential configuration and Remote Site Settings');
        }
        
        System.debug('=== TEST COMPLETE ===');
    }
    
    /**
     * Test just the Named Credential setup without making API call
     */
    public static void testNamedCredential() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Test if Named Credential resolves correctly
            request.setEndpoint('callout:Azure_OpenAI_API/test');
            request.setMethod('GET');
            request.setTimeout(5000);
            
            System.debug('=== NAMED CREDENTIAL TEST ===');
            System.debug('Testing Named Credential: Azure_OpenAI_API');
            
            HttpResponse response = http.send(request);
            
            System.debug('Status Code: ' + response.getStatusCode());
            
            if (response.getStatusCode() == 404) {
                System.debug('✅ Named Credential is working (404 expected for /test endpoint)');
            } else if (response.getStatusCode() == 401) {
                System.debug('❌ Authentication failed - check API key in Named Credential');
            } else {
                System.debug('Status: ' + response.getStatusCode() + ' - ' + response.getBody());
            }
            
        } catch (Exception e) {
            System.debug('❌ Named Credential Error: ' + e.getMessage());
            if (e.getMessage().contains('No Named Credential')) {
                System.debug('💡 SOLUTION: Create Named Credential with API Name: Azure_OpenAI_API');
            }
        }
        
        System.debug('=== NAMED CREDENTIAL TEST COMPLETE ===');
    }
}