public class CalloutClass {
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