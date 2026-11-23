public class ChatGPT {
    //private static String CHAT_GPT_KEY = 'e1e1e6a9df3f493faea39aabcb578b46'; //Custom Setting
    //private static final String ENDPOINT ='https://oai-opnai1-gpt-dev-frte.openai.azure.com/v1/completions';
    private static String CHAT_GPT_KEY = 'Fl5+St5DPd50xFBTR/cydusadUDZtbBBlqjGVzzMQnc=';
    private static final String ENDPOINT = 'https://m2rkpieventhub.servicebus.windows.net/v1/completions';
    //@method   : getQueryData
    //@param    : searchString
    //@description  : Below method is used in Salesforce+Chat GPT integration LWC as Controller to make callout
    //                to Chat GPT and return response/error from this method
    @AuraEnabled
    public static String getQueryData(String seachQueryEscaped){
        try{
            String reqBody = '{"messages": [{"role": "user","content":"The below text is an extracted invoice data. Read it and generate invoice number, invoice amount,  invoice date, tax in the following format invoice amount : 11111. Do not miss any extracted information from the invoice information mentioned inside three backticks.```'+seachQueryEscaped+'```"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            //String reqBody = '{"messages": [{"role": "system","content":"The below text is an extracted invoice data. Read it and generate invoice number, invoice amount,  invoice date, tax in the following format invoice amount : 11111. Do not miss any extracted information from the invoice information mentioned inside three backticks.```'+seachQueryEscaped+'```"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            system.debug('reqBody:'+reqBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GenAI_POC'+'/gpt4-smgtest?api-version=2023-05-15');
            //req.setEndpoint('callout:GenAI_POC'+'/gpt-35-turbo?api-version=2024-02-15-preview');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(reqBody);
            HttpResponse response = new Http().send(req);
            // Parse the JSON response
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
                return response.getBody();
            }
          

// Deserialize the JSON string
Map<String, Object> parsedJson = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

// Access the 'content' value
String content = '';

if (parsedJson.containsKey('choices')) {
    List<Object> choices = (List<Object>)parsedJson.get('choices');
    
    if (!choices.isEmpty()) {
        Map<String, Object> choice = (Map<String, Object>)choices[0];
        
        if (choice.containsKey('message')) {
            Map<String, Object> message = (Map<String, Object>)choice.get('message');
            
            if (message.containsKey('content')) {
                content = (String)message.get('content');
            }
        }
    }
}

// Now, 'content' contains the value inside "content" from the JSON response
System.debug('Content: ' + content);
            content = content.replaceAll('\n', '&');
            return content;
        }catch(Exception ex){
            System.debug('Exception in Catch of Server-Side Controller '+ex);
            return null;
        }
    }

}