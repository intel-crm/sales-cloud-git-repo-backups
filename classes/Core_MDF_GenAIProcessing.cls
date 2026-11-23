/******************************************************************************************************
* Class Name  : Core_MDF_GenAIProcessing 
* Version     : 1.0 
* Created Date: 01-07-2024
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
	Aditya 			  01-07-2024         Class for Chat GPT callout to return json data as per prompt
*******************************************************************************************************/

public class Core_MDF_GenAIProcessing {
    /****************************************************************************************************** 
    Method Name:        getQueryData
    @return  :          contentWrap (json data as per prompt)
    @parameters:        String rawData (content data as string)
    Description:        This method is used to send document data to GPT and get the proposed values
    Added By:           Aditya - 01-07-2024
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static contentWrap getQueryData(String rawData){
        try{
            contentWrap contentWrapper = new contentWrap();
            contentWrapper.rawContent = rawData;
            rawData = rawData.escapeJava();
            //String reqBody = '{"messages": [{"role": "user","content":"The below text is an extracted invoice data. Read it and generate invoice number, invoice amount,  invoice date, tax and currency code as XXX in the following format invoice amount : 11111. Do not miss any extracted information from the invoice information mentioned inside three backticks.```'+seachQueryEscaped+'```"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            //String reqBody = '{"messages": [{"role": "system","content":"Please extract the following information from the provided invoice details. Ensure that the output format for each piece of information is as specified.Invoice Information:'+rawData+'.Output Format:Invoice Number: XXX (Replace XXX with the generated code)Invoice Amount: $11111 (Replace 11111 with the generated amount)Invoice Date: DD/MM/YYYY (Replace DD with date,MM with month and YYYY with year)Tax: $XXX (Replace XXX with the generated code)Currency Code: XXX (Replace XXX with the generated code)"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            //String reqBody = '{"messages": [{"role": "system","content":"Please extract the following information from the provided invoice details. Ensure that the output format for each piece of information is as specified and return Not Provided if value not found.Invoice Information:'+rawData+'.Output Format:Invoice Number: XXX (Replace XXX with the generated code)Invoice Amount: $11111 (Replace 11111 with the generated amount)Invoice Date: DD/MM/YYYY (Replace DD with date,MM with month and YYYY with year)Tax: $XXX (Replace XXX with the generated code)Currency Code: XXX (Replace XXX with the generated code)"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            
            //String prompt = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzy_Prompt');
            String prompt = Label.Core_MDF_ClaimEzy_Prompt1 + Label.Core_MDF_ClaimEzy_Prompt2;
            //String prompt = '{"messages": [{"role": "system","content":"Please extract the following information from the provided invoice details. Ensure that the output format for each piece of information is as specified. Invoice information is provided in three backticks and if information not found return Not Provided for that attribute.If the currency code is not explicitly mentioned look for currency symbol before amount and get currency code accordingly. Invoice Amount should include tax amount also if tax is present. Invoice number may also have been mentioned as Activity Number or Bill No in invoice information. Consider Tax attribute if tax is explicitly mentioned only. Invoice Information:\'\'\'{{{rawData}}}\'\'\'.Output Format:Invoice Number: XXX (Replace XXX with the generated code)Invoice Amount: $11111 (Replace 11111 with the generated amount)Invoice Date: DD/MM/YYYY (Replace DD with date,MM with month and YYYY with year)Tax: $XXX (Replace XXX with the generated code)Currency Code: XXX(Replace XXX with the generated code)"}],"temperature": 0.7,"top_p": 0.95,"frequency_penalty": 0,"presence_penalty": 0,"max_tokens": 800,"stop": null}';
            prompt = prompt.replace('{{{rawData}}}',rawData);
            
            HttpRequest req = new HttpRequest();
            String endpoint = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzyGenAIEndpoint');
            req.setEndpoint('callout:Core_MDF_CCP_GenAI'+ endpoint);
            //req.setEndpoint('callout:Core_MDF_CCP_GenAI'+'/gpt-35-turbo?api-version=2024-02-15-preview');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(prompt);
            HttpResponse response = new Http().send(req);

            // Parse the JSON response
            if(response.getStatusCode() != 200) {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI endpoint is not giving proper result', 'Core_MDF_AI_Tracking__c');
                contentWrapper.contentFromChatGPT = '';
                return contentWrapper;
            }else{
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
                                content = String.isNotBlank(content) ? content.replaceAll('\n', '&') : '';
                            }else{
                                Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI endpoint is not giving proper result', 'Core_MDF_AI_Tracking__c');
                            }
                        }else{
                            Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI endpoint is not giving proper result', 'Core_MDF_AI_Tracking__c');
                        }
                    }
                }else{
                    Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI endpoint is not giving proper result', 'Core_MDF_AI_Tracking__c');
                }

                contentWrapper.contentFromChatGPT = content;
            }
            return contentWrapper;
	    
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex); return null;
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        getAIApprovalData
    @return  :          contentWrap (json data as per prompt)
    @parameters:        String promptData (complete prompt ready to send to GPT)
    Description:        This method is used to send approval prompt to GPT and get approval recommendations
    Added By:           Gayathri - AI Approval Feature
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static contentWrap getAIApprovalData(String promptData){
        try {
            contentWrap contentWrapper = new contentWrap();
            contentWrapper.rawContent = promptData;
            
            String endpoint = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzyGenAIEndpoint');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Core_MDF_CCP_GenAI' + endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');            
            req.setBody(promptData);
            
            HttpResponse response = new Http().send(req);
            
            // Parse the JSON response
            if(response.getStatusCode() != 200) {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI endpoint error for approval analysis. Status: ' + response.getStatusCode(), 'Core_MDF_AI_Tracking__c'); 
                contentWrapper.contentFromChatGPT = ''; 
                return contentWrapper;
            }
            
            // Deserialize the JSON string
            Map<String, Object> parsedJson;
            try {
                parsedJson = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            } catch (Exception jsonEx) {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI response JSON parsing failed: ' + jsonEx.getMessage(), 'Core_MDF_AI_Tracking__c');
                contentWrapper.contentFromChatGPT = '';
                return contentWrapper;
            }
            
            String content = '';

            if (parsedJson.containsKey('choices')) {
                List<Object> choices = (List<Object>)parsedJson.get('choices');
                
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> choice = (Map<String, Object>)choices[0];
                    
                    if (choice.containsKey('message')) {
                        Map<String, Object> message = (Map<String, Object>)choice.get('message');
                        
                        if (message.containsKey('content')) {
                            content = (String)message.get('content');
                            if (String.isNotBlank(content)) {
                                content = content.replaceAll('\n', '&');
                            }
                        } else {
                            Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI response missing content key in message', 'Core_MDF_AI_Tracking__c');
                        }
                    } else {
                        Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI response missing message key in choice', 'Core_MDF_AI_Tracking__c');
                    }
                } else {
                    Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI response has empty choices array', 'Core_MDF_AI_Tracking__c');
                }
            } else {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('GEN AI response missing choices key', 'Core_MDF_AI_Tracking__c');
            }

            contentWrapper.contentFromChatGPT = content;
            return contentWrapper;
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }
    
    public class contentWrap{
        public string contentFromChatGPT;
        public string rawContent;
    }
}