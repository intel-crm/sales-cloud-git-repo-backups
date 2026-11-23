/**
 * Apex Controller for Azure AI Integration
 * Handles communication with Azure OpenAI API for Account Plan Generation
 */
public with sharing class AccountPlanAzureAIController {
    
    // Azure OpenAI Configuration (Store these in Custom Settings or Environment Variables)
    private static final String AZURE_API_ENDPOINT = 'https://uam-azure-open-ai-east.openai.azure.com';
    private static final String AZURE_API_KEY = '95ec8b6ceb774ee3aaf968603c4c36b4';
    private static final String AZURE_DEPLOYMENT_ID = 'gpt-4o';
    private static final String AZURE_API_VERSION = '2023-03-15-preview';

    /**
     * Calls Azure OpenAI API to generate account plan based on user prompt
     * @param prompt The user prompt for generating account plan
     * @return Generated account plan text
     */
    @AuraEnabled
    public static String callAzureAI(String prompt) {
        try {
            if (String.isBlank(prompt)) {
                throw new IllegalArgumentException('Prompt cannot be empty');
            }

            // Construct Azure OpenAI API request
            String endpoint = AZURE_API_ENDPOINT + '/openai/deployments/' + AZURE_DEPLOYMENT_ID + 
                            '/chat/completions?api-version=' + AZURE_API_VERSION;
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('api-key', AZURE_API_KEY);
            
            // Create request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'messages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'role' => 'system',
                        'content' => 'You are an expert business strategist specializing in creating comprehensive account plans. Provide detailed, actionable account plans based on the user\'s requirements.'
                    },
                    new Map<String, Object>{
                        'role' => 'user',
                        'content' => prompt
                    }
                },
                'temperature' => 0.7,
                'max_tokens' => 2000,
                'top_p' => 0.95,
                'frequency_penalty' => 0,
                'presence_penalty' => 0
            };
            
            request.setBody(JSON.serialize(requestBody));
            request.setTimeout(120000); // 2 minutes timeout
            
            // Make API call
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            // Handle response
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> choices = (List<Object>) responseBody.get('choices');
                
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> choice = (Map<String, Object>) choices.get(0);
                    Map<String, Object> message = (Map<String, Object>) choice.get('message');
                    String content = (String) message.get('content');
                    return content;
                }
            } else {
                String errorMessage = 'Azure AI API Error: ' + response.getStatusCode() + ' - ' + response.getBody();
                System.debug(LoggingLevel.ERROR, errorMessage);
                throw new AuraHandledException(errorMessage);
            }
            
            return null;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error calling Azure AI: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    /**
     * Helper method to validate Azure credentials are configured
     * @return true if credentials are properly configured
     */
    private static Boolean validateAzureCredentials() {
        return !String.isBlank(AZURE_API_ENDPOINT) && 
               !String.isBlank(AZURE_API_KEY) && 
               !String.isBlank(AZURE_DEPLOYMENT_ID) &&
               !AZURE_API_ENDPOINT.contains('YOUR_');
    }
}