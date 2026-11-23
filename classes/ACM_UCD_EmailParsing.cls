/******************************************************************************************************
* Class Name  : ACM_UCD_EmailParsing 
* Version     : 1.0 
* Created Date: 01-07-2024
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
	Aditya 			  01-07-2024         Class for Chat GPT callout to return json data as per prompt
*******************************************************************************************************/

public class ACM_UCD_EmailParsing {
    /****************************************************************************************************** 
    Method Name:        getQueryData
    @return  :          contentWrap (json data as per prompt)
    @parameters:        String rawData (content data as string)
    Description:        This method is used to send document data to GPT and get the proposed values
    Added By:           Aditya - 01-07-2024
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static HttpResponse getQueryData(String rawData){
        try{
            contentWrap contentWrapper = new contentWrap();
            contentWrapper.rawContent = rawData;
            rawData = rawData.escapeJava();
            String prompt = '{"messages": [{"role": "system","content":"Extract Contact information from the below Email to be inserted as a record in Salesforce, response should exactly match the output format and no deviations can be allowed. output format: Contact{Firstname:<Text>, LastName:<Text>, email:<Emailaddress>, AccountID: <SalesForceAccountID>, ShippingCountry:<Text>}       Email begins here -  \'\'\'{{{rawData}}}\'\'\' "}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            prompt = prompt.replace('{{{rawData}}}',rawData);
            
            
            HttpRequest req = new HttpRequest();
            String endpoint = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzyGenAIEndpoint');
            req.setEndpoint('callout:Core_MDF_CCP_GenAI'+ endpoint);
            //req.setEndpoint('callout:Core_MDF1_CCP_GenAI'+'/gpt-35-turbo?api-version=2024-02-15-preview');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(prompt);
            HttpResponse response = new Http().send(req);
            System.debug(((MAP<String, String>) JSON.deserializeUntyped(response.getBody())).get('message'));
            return response;
        }catch(Exception ex){
           // Core_MDF_CCP_UtilityClass.logError(ex); 
           return null;
        }
        
    }
    
    public class contentWrap{
        public string contentFromChatGPT;
        public string rawContent;
    }
}