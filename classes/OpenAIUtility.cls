//can you check below code is correct
public class OpenAIUtility {
    @InvocableMethod(label='Prompt using Azure Open AI' description='Display the prompt result')
    public static List<String> PromptOpenAI(List<String> seachQueryEscaped) {
        // Perform a SOQL query to get the accounts
        List<String> responseLst = new List<String>();
        try{
            system.debug('reqBody:test'+seachQueryEscaped[0]);
            //String reqBody = seachQueryEscaped[0];
            String reqBody = '{"messages": [{"role": "system","content":"The below text is an extracted invoice data. Read it and generate invoice number, invoice amount,  invoice date, tax in the following format invoice amount : 11111. Do not miss any extracted information from the invoice information mentioned inside three backticks.```'+seachQueryEscaped[0]+'```"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            system.debug('reqBody:'+reqBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GenAI_POC'+'/gpt4-smgtest?api-version=2023-05-15');
            //req.setEndpoint('callout:GenAI_POC'+'/gpt-35-turbo?api-version=2024-02-15-preview');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(reqBody);
            HttpResponse response = new Http().send(req);
            // Parse the JSON response
            system.debug('testing response--');
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
               // responseLst.add(response.getBody());
                //return responseLst;
            }
            system.debug('after testing response--');
            
            // Deserialize the JSON string
            Map<String, Object> parsedJson = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            // Access the 'content' value
            String content = '';
            system.debug('after testing response-parsedJson-'+  parsedJson);
            if (parsedJson.containsKey('choices')) {
                List<Object> choices = (List<Object>)parsedJson.get('choices');
                
                if (!choices.isEmpty()) {
                    Map<String, Object> choice = (Map<String, Object>)choices[0];
                    
                    if (choice.containsKey('message')) {
                        Map<String, Object> message = (Map<String, Object>)choice.get('message');
                        
                        if (message.containsKey('content')) {
                            content = (String)message.get('content');
                            responseLst.add(content);
                        }
                    }
                }
            }
            
            return responseLst;
        }
        catch(exception ex)
        {
            // Log the exception
            System.debug('error---'+ex);
            responseLst.add(ex.getMessage());
            // Return an empty list or a list with a specific error message
            return responseLst;
        }
    }
}