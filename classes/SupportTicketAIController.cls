public with sharing class SupportTicketAIController {

    @AuraEnabled
    public static Id createTicket(String userInput, String base64File) {

        try {
            // 🔹 Step 1: Read file (if any)
            String fileText = '';

            if(base64File != null){
                Blob fileBlob = EncodingUtil.base64Decode(base64File);
                fileText = fileBlob.toString();
            }

            String finalInput = userInput + '\n' + fileText;

            // 🔹 Step 2: Call GPT API
            Map<String, Object> gptResponse = callGPT(finalInput);

            System.debug('PARSED RESPONSE: ' + JSON.serializePretty(gptResponse));

            // 🔹 Step 3: Extract content safely
            String jsonText = extractContent(gptResponse);

            System.debug('CLEAN JSON: ' + jsonText);

            if(String.isBlank(jsonText)){
                throw new AuraHandledException('JSON is empty after cleaning');
            }

            // 🔹 Step 4: Parse JSON
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(jsonText);

            Map<String, Object> fields;

            // ✅ Handle BOTH formats
            if(parsed.containsKey('fields')) {
                fields = (Map<String, Object>) parsed.get('fields');
            } else {
                fields = parsed;
            }

            if(fields == null){
                throw new AuraHandledException('Fields missing in GPT response');
            }

            // 🔹 Step 5: Create record
            Support_Ticket__c ticket = new Support_Ticket__c();

            if(fields.containsKey('Subject__c'))
                ticket.Subject__c = (String) fields.get('Subject__c');

            if(fields.containsKey('Priority__c'))
                ticket.Priority__c = (String) fields.get('Priority__c');

            if(fields.containsKey('Description__c'))
                ticket.Description__c = (String) fields.get('Description__c');

            // 🔹 Step 6: Default + Validation
            if(String.isBlank(ticket.Subject__c)){
                ticket.Subject__c = 'Default Subject';
            }

            // Priority validation
            Set<String> validPriority = new Set<String>{'High','Medium','Low'};
            if(!validPriority.contains(ticket.Priority__c)){
                ticket.Priority__c = 'Low';
            }

            insert ticket;

            return ticket.Id;

        } catch(Exception e){
            System.debug('ERROR: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 🔹 GPT API Call using Named Credential
    private static Map<String, Object> callGPT(String inputText) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:Core_MDF_CCP_GenAI/gpt-4o?api-version=2024-12-01-preview');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String prompt = 'Extract fields for Support_Ticket__c. ' +
                        'Return ONLY JSON. ' +
                        'Fields: Subject__c, Priority__c (High/Medium/Low), Description__c. ' +
                        'Map urgency words like urgent → High.';

        String body = JSON.serialize(new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, Object>{
                    'role' => 'system',
                    'content' => prompt
                },
                new Map<String, Object>{
                    'role' => 'user',
                    'content' => inputText
                }
            }
        });

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        // 🔥 Debug (VERY IMPORTANT)
        System.debug('RAW RESPONSE STRING: ' + res.getBody());
        System.debug('STATUS CODE: ' + res.getStatusCode());

        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }

    // 🔹 Extract GPT content safely (handles multiple formats)
    private static String extractContent(Map<String, Object> response) {

        if(response == null){
            throw new AuraHandledException('Response is null');
        }

        String content;

        // ✅ Case 1: OpenAI format
        if(response.containsKey('choices')) {

            List<Object> choices = (List<Object>) response.get('choices');

            if(choices != null && !choices.isEmpty()) {
                Map<String, Object> choice = (Map<String, Object>) choices[0];

                // Some APIs use "message", some use "text"
                if(choice.containsKey('message')) {
                    Map<String, Object> message =
                        (Map<String, Object>) choice.get('message');

                    if(message != null && message.containsKey('content')) {
                        content = (String) message.get('content');
                    }
                }

                // fallback: direct text
                if(content == null && choice.containsKey('text')) {
                    content = (String) choice.get('text');
                }
            }
        }

        // ✅ Case 2: result
        if(content == null && response.containsKey('result')) {
            content = (String) response.get('result');
        }

        // ✅ Case 3: output.text
        if(content == null && response.containsKey('output')) {
            Map<String, Object> output =
                (Map<String, Object>) response.get('output');

            if(output != null && output.containsKey('text')) {
                content = (String) output.get('text');
            }
        }

        if(String.isBlank(content)) {
            throw new AuraHandledException(
                'Unable to extract content. Response: ' +
                JSON.serializePretty(response)
            );
        }

        return cleanJson(content);
    }

    // 🔹 Clean markdown and extract JSON
    private static String cleanJson(String content) {

        if(String.isBlank(content)) {
            return content;
        }

        content = content.replace('```json', '');
        content = content.replace('```', '');
        content = content.trim();

        Integer start = content.indexOf('{');
        Integer end1 = content.lastIndexOf('}');

        if(start != -1 && end1 != -1 && end1 > start){
            content = content.substring(start, end1 + 1);
        }

        return content;
    }
}