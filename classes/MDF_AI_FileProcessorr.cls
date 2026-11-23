public with sharing class MDF_AI_FileProcessorr {

    @AuraEnabled
    public static String processFileWithAI(Id contentDocumentId) {
        try {
            // Step 1: Get latest file version
            ContentVersion cv = [
                SELECT Id, VersionData, Title
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            // Step 2: Convert Blob → String (CSV)
            String fileData = cv.VersionData.toString();

            // Step 3: Parse CSV
            Map<String, String> fieldMap = parseCSV(fileData);

            // Step 4: Build Prompt
            String prompt = buildPrompt(fieldMap);

            // Step 5: Call GPT API
            String response = callGPT(prompt);

            return response;

        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    // ============================
    // CSV PARSER
    // ============================
    private static Map<String, String> parseCSV(String data) {
        Map<String, String> fieldMap = new Map<String, String>();

        List<String> lines = data.split('\n');

        for (String line : lines) {
            List<String> cols = line.split(',');

            if (cols.size() >= 2) {
                String key = cols[0].trim();
                String value = cols[1].trim();

                fieldMap.put(key, value);
            }
        }

        return fieldMap;
    }

    // ============================
    // PROMPT BUILDER
    // ============================
    private static String buildPrompt(Map<String, String> data) {

        List<String> fields = new List<String>{
            'Name','Account','Start Date','End Date','Focus Area','Description',
            'Budget Type','Available Budget','Total Investment ( Intel + Partner )',
            'Maximum Intel Investment','Priority','Priority #2','Region','Country',
            'Target Audience','Ecosystem Partner','Initiative','Brand','Technology',
            'Product Type','Outcome Metric',
            'Other Brands /Technologies included in this Campaign?','Tactics'
        };

        Map<String, Object> finalMap = new Map<String, Object>();

        for (String field : fields) {
            if (data.containsKey(field)) {
                finalMap.put(field, data.get(field));
            }
        }

        return 'Extracted campaign data:\n' + JSON.serializePretty(finalMap);
    }

    // ============================
    // GPT CALLOUT
    // ============================
    private static String callGPT(String prompt) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:Core_MDF_CCP_GenAI/gpt-4o?api-version=2024-12-01-preview');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, Object>{
                    'role' => 'user',
                    'content' => 'Convert below data into structured JSON:\n' + prompt
                }
            },
            'temperature' => 0.2
        };

        req.setBody(JSON.serialize(body));

        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            throw new AuraHandledException('API Error: ' + res.getBody());
        }
    }
}