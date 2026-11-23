//can you check below code is correct
public class OpenAIUtility {
    @InvocableMethod(label='Prompt using Azure Open AI' description='Display the prompt result')
    public static List<String> PromptOpenAI(List<String> seachQueryEscaped) {
        // Perform a SOQL query to get the accounts
        List<String> responseLst = new List<String>();
        try{
            system.debug('reqBody:test'+seachQueryEscaped[0]);
            //String reqBody = seachQueryEscaped[0];
            string prompt = 'Evaluate the Quality and Relevance of the Questionnaire in Tender Quote Requests '+
'As the Tender Quote Request approver, you are tasked with reviewing the questionnaires provided with each tender request. '+
'Your evaluation should be based on the following criteria to ensure that the questionnaire is suitable for the tender evaluation process '+
'Ensure:'+
'Relevant details are filled in, including relevant comments and competitor information.'+
'The information submitted is relevant to question. Comments like “please approve” or “as requested” should not be accepted. Classify the Quote Requests either as Good Quality or Bad Quality, provide brief explanation for the classification choosen.Make sure the ouput adheres to below conditions: '+
'Do not output the evaluation for example sets provided.'+
'Do not provide any other commentary other than classification and brief example.';
            
            String reqBody = '{"messages": [{"role": "system","content":"'+prompt+'```'+seachQueryEscaped[0]+'```"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 2000,"stop": null}';
            system.debug('reqBody:'+reqBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GenAI_POC'+'/gpt4-smgtest?api-version=2023-05-15');
            //req.setEndpoint('callout:GenAI_POC'+'/gpt-35-turbo?api-version=2024-02-15-preview');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(reqBody);
             req.setTimeout(12000);
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