public class DeepSeekCalloutService {
    
    private static final String AZURE_GPT4O_MODEL = 'gpt-4o';
    private static final String AZURE_GPT4O_CODER_MODEL = 'gpt-4o';
    
    public class DeepSeekResponse {
        public String content;
        public Integer totalTokens;
        public String model;
        public Boolean success;
        public String errorMessage;
    }
    
    /**
     * Call Azure OpenAI API for general analysis
     */
    public static DeepSeekResponse callDeepSeek(String prompt) {
        return callDeepSeekWithModel(prompt, AZURE_GPT4O_MODEL);
    }
    
    /**
     * Call Azure OpenAI API specifically for code analysis
     */
    public static DeepSeekResponse callDeepSeekCoder(String prompt) {
        return callDeepSeekWithModel(prompt, AZURE_GPT4O_CODER_MODEL);
    }
    
    /**
     * Core API call method
     */
    public static DeepSeekResponse callDeepSeekWithModel(String prompt, String model) {
        DeepSeekResponse response = new DeepSeekResponse();
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Set endpoint using Named Credential for Azure OpenAI
            request.setEndpoint('callout:Azure_OpenAI_API/openai/deployments/gpt-4o/chat/completions?api-version=2023-03-15-preview');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('api-key', '95ec8b6ceb774ee3aaf968603c4c36b4'); // Manual API key header
            request.setTimeout(120000); // 2 minutes
            
            // Build request body - Azure OpenAI doesn't need model in body since it's in the URL
            Map<String, Object> requestBody = new Map<String, Object>{
                'messages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'role' => 'system',
                        'content' => 'You are an expert Salesforce architect and metadata analyst using GPT-4o. Provide detailed, actionable insights for Salesforce org cleanup and optimization.'
                    },
                    new Map<String, Object>{
                        'role' => 'user',
                        'content' => prompt
                    }
                },
                'max_tokens' => 4000,
                'temperature' => 0.1, // Low temperature for consistent, factual responses
                'stream' => false
            };
            
            request.setBody(JSON.serialize(requestBody));
            
            // Make the API call
            HttpResponse httpResponse = http.send(request);
            
            if (httpResponse.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                
                // Parse response
                List<Object> choices = (List<Object>) responseMap.get('choices');
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                    
                    response.content = (String) message.get('content');
                    response.model = model;
                    response.success = true;
                    
                    // Get usage info
                    Map<String, Object> usage = (Map<String, Object>) responseMap.get('usage');
                    if (usage != null) {
                        response.totalTokens = (Integer) usage.get('total_tokens');
                    }
                } else {
                    response.success = false;
                    response.errorMessage = 'No choices in API response';
                }
                
            } else {
                response.success = false;
                response.errorMessage = 'HTTP ' + httpResponse.getStatusCode() + ': ' + httpResponse.getBody();
            }
            
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = 'Exception: ' + e.getMessage();
            System.debug('Azure OpenAI API Error: ' + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * Test method to verify Azure OpenAI API connectivity
     */
    @AuraEnabled(cacheable=false)
    public static Boolean testConnection() {
        try {
            DeepSeekResponse response = callDeepSeek('Hello, can you help analyze Salesforce metadata?');
            return response.success;
        } catch (Exception e) {
            System.debug('Azure OpenAI connection test failed: ' + e.getMessage());
            return false;
        }
    }
}