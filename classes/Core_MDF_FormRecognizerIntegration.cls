/******************************************************************************************************
* Class Name  : Core_MDF_FormRecognizerIntegration 
* Version     : 1.0 
* Created Date: 01-07-2024
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
	Aditya 			  01-07-2024         Class for Azure OCR callouts to read file contents as a string
*******************************************************************************************************/
public class Core_MDF_FormRecognizerIntegration {
    
    /****************************************************************************************************** 
    Method Name:        readDocumentContents
    @return  :          String (request Id)
    @parameters:        String fileContent (base64 encoded string of file content)
    Description:        This method is used to send document data to OCR(Azure) and get the request Id
    Added By:           Aditya - 01-07-2024
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static String readDocumentContents(String fileContent) {
        HttpResponse response;
        if(fileContent != null && fileContent.length() < 5900000){
            try{
                String endpoint = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzyOCREndpoint1');
                String formRecognizerEndpoint = 'callout:Core_MDF_CCP_Azure_Document_Intelligence'+ endpoint;//prebuilt-layout;prebuilt-read
                //String formRecognizerEndpoint = 'https://apis.intel.com/m2r/ccp-generative-ai/v1/analyses/prebuilt-read:analyze?api-version=2023-07-31';
                // Request payload
                String requestBody = '{"base64Source":"' + fileContent + '"}';

                // Make the HTTP request
                HttpRequest request = new HttpRequest();
                request.setEndpoint(formRecognizerEndpoint);
                request.setMethod('POST');
                request.setHeader('Content-Type' , 'application/json'); 
                request.setBody(requestBody);
                // Make the HTTP callout
                Http http = new Http();
                response = http.send(request);

            }catch(Exception ex){
                Core_MDF_CCP_UtilityClass.logError(ex); throw ex;
            }
            
            // Process the response
            if (response.getStatusCode() == 200 || response.getStatusCode() == 202) {
                String extractedValue = response.getHeader('apim-request-id');
                return extractedValue;
            } else {
                // Handle error scenarios
                Core_MDF_CCP_UtilityClass.logErrorAsNormal(response.getStatusCode() + ' - ' + response.getStatus() + ' - ' + response.getBody(), 'Core_MDF_AI_Tracking__c'); return null;
            }
        }else{
            Core_MDF_CCP_UtilityClass.logErrorAsNormal(System.Label.Core_MDF_Claim_ezy_MaxStringLimitError, 'Core_MDF_AI_Tracking__c');
            String error = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,' + System.Label.Core_MDF_Claim_ezy_MaxStringLimitError + ':'; throw new StringException(error);
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        getDocumentAsString
    @return  :          String documentAsString
    @parameters:        String (request Id)
    Description:        This method is used to send Ocr Request ID and get document content as string
    Added By:           Aditya - 01-07-2024
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static string getDocumentAsString(String modelId, String resultId) {
        String endpoint = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzyOCREndpoint2');
        String ENDPOINT_URL = 'callout:Core_MDF_CCP_Azure_Document_Intelligence'+ endpoint;
        String status = '';
        String content;

        HttpRequest subsequentRequest = new HttpRequest();
        subsequentRequest.setEndpoint(ENDPOINT_URL.replace('{modelId}', modelId).replace('{resultId}', resultId));
        subsequentRequest.setMethod('GET');
        HttpResponse subsequentResponse;
        Map<String, Object> jsonResponse ;
        // Loop until the status is "completed"
        Integer counter = 0;
        try{
            while (!status.equals('succeeded')) {
                if( counter < 10 && Limits.getCpuTime() < 7000 ){
                    // Perform subsequent HTTP requests to check status
                    subsequentResponse = new Http().send(subsequentRequest);
                    // Retrieve the status from the subsequent response
                    jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(subsequentResponse.getBody());
                    if(jsonResponse.containsKey('status')){
                        status = (String) jsonResponse.get('status');
                    }
                    
                    counter += 1;
                }else{
                    Core_MDF_CCP_UtilityClass.logErrorAsNormal('Maximum Azure OCR 2 callout reached', 'Core_MDF_AI_Tracking__c');
                    break;
                }
            }
        } catch (exception ex){    Core_MDF_CCP_UtilityClass.logError(ex);
        }
        //ATHR - Deeply Nested if 16209
        if(subsequentResponse.getBody() == null) {
            Core_MDF_CCP_UtilityClass.logErrorAsNormal('Azure OCR2 response body is blank', 'Core_MDF_AI_Tracking__c');
            return content;
        }
        //if(subsequentResponse.getBody() != null){
            jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(subsequentResponse.getBody());
            // Extract the "content" value from "analyzeResult"
            //ATHR - Deeply Nested if 16209
            if(jsonResponse.get('analyzeResult') == null || !jsonResponse.containsKey('analyzeResult')) {
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('Azure OCR2 response body not having proper attributes', 'Core_MDF_AI_Tracking__c');
                return content;
            }
            //if(jsonResponse.containsKey('analyzeResult')){
                Map<String, Object> analyzeResult = (Map<String, Object>) jsonResponse.get('analyzeResult');
                if (analyzeResult.containsKey('content')) {
                    content = (String) analyzeResult.get('content');
                    content = content.replaceAll('\n', ' ');
                }else{
                    Core_MDF_CCP_UtilityClass.logErrorAsNormal('Azure OCR2 response body not having proper attributes', 'Core_MDF_AI_Tracking__c');
                }
            /*}else{
                Core_MDF_CCP_UtilityClass.logErrorAsNormal('Azure OCR2 response body not having proper attributes', 'Core_MDF_AI_Tracking__c');
            }
        }else{
            Core_MDF_CCP_UtilityClass.logErrorAsNormal('Azure OCR2 response body is blank', 'Core_MDF_AI_Tracking__c');
        }*/
        return content;
    }
}