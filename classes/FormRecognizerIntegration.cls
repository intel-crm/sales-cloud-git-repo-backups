public class FormRecognizerIntegration{

    @AuraEnabled
    // Method to call Form Recognizer API and read the contents of a document
    public static String readDocumentContents(String fileContent) {
        //String documentUrl = 'https://github.com/Azure-Samples/cognitive-services-REST-api-samples/raw/master/curl/form-recognizer/rest-api/invoice.pdf';
        String formRecognizerEndpoint = 'callout:Azure_Document_Intelligence'+'/analyses/prebuilt-layout:analyze?api-version=2023-07-31';

        
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
        HttpResponse response = http.send(request);

        // Process the response
        if (response.getStatusCode() == 200 || response.getStatusCode() == 202) {
            String operationLocation = response.getHeader('Operation-Location');
            System.debug('Operation-Location Header Value: ' + operationLocation);
            String extractedValue = extractValueFromOperationLocation(operationLocation);
            System.debug('Extracted Value: ' + extractedValue);
            
            //System.enqueueJob(new MicrosoftApiCaller('prebuilt-layout', extractedValue,new FormRecognizerIntegration()));
            return extractedValue;
        } else {
            // Handle error scenarios
            system.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus() + ' - ' + response.getBody());
       return null;
        }
    }
    
     private static String extractValueFromOperationLocation(String operationLocation) {
        // Find the index of "analyzeResults/" and "?"
        Integer startIndex = operationLocation.indexOf('analyzeResults/') + 'analyzeResults/'.length();
        Integer endIndex = operationLocation.indexOf('?', startIndex);

        // Extract the substring
        if (startIndex > 0 && endIndex > 0) {
            return operationLocation.substring(startIndex, endIndex);
        } else {
            return null; // Handle the case where the pattern is not found
        }
    }
    
    @AuraEnabled
    public static String makeCallout(String modelId, String resultId) {
        String ENDPOINT_URL = 'callout:Azure_Document_Intelligence'+'/{modelId}/analysis-results/{resultId}?api-version=2023-07-31';
    String status = '';
        String content;
        HttpRequest subsequentRequest = new HttpRequest();
            subsequentRequest.setEndpoint(ENDPOINT_URL.replace('{modelId}', modelId).replace('{resultId}', resultId));
            subsequentRequest.setMethod('GET');
        HttpResponse subsequentResponse;
        Map<String, Object> jsonResponse ;
        // Loop until the status is "completed"
        while (!status.equals('succeeded')) {
            // Perform subsequent HTTP requests to check status
            

            subsequentResponse = new Http().send(subsequentRequest);

            // Retrieve the status from the subsequent response
            jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(subsequentResponse.getBody());
            status = (String) jsonResponse.get('status');
            // Sleep for a short duration before checking again
            if (!status.equals('succeeded')) {
                // Adjust the sleep duration based on your specific scenario
                // For example, sleep for 5 seconds
                subsequentResponse = new Http().send(subsequentRequest);
            }
        }
        jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(subsequentResponse.getBody());
         // Extract the "content" value from "analyzeResult"
            Map<String, Object> analyzeResult = (Map<String, Object>) jsonResponse.get('analyzeResult');
            if (analyzeResult.containsKey('content')) {
                content = (String) analyzeResult.get('content');
                content = content.replaceAll('\n', '');
            }
        String contentFromChatGPT = ChatGPT.getQueryData(content);
        return contentFromChatGPT;
    }
}