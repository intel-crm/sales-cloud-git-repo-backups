public with sharing class DocAiDirectService {
    public class ExtractResult {
        public String text;
        public List<Object> entities;
        public List<Map<String, Object>> keyValuePairs;
        public Integer statusCode;
        public String rawResponse;
    }

    public static ExtractResult processBase64(
        String projectId,
        String location,
        String processorId,
        String mimeType,
        String base64Content,
        Boolean skipHumanReview,
        String accessToken
    ) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(120000);

        String endpoint =
            'callout:DocExtractor/v1/projects/535487920781/locations/us/processors/16ee4328fa2aa8ef:process';
        system.debug('endpoint-> '+endpoint);
        req.setEndpoint(endpoint);

        Map<String, Object> payload = new Map<String, Object>{
            'skipHumanReview' => (skipHumanReview == null ? true : skipHumanReview),
            'rawDocument' => new Map<String, Object>{
                'content' => base64Content,
                'mimeType' => mimeType
            }
        };
        req.setBody(JSON.serialize(payload));
        system.debug('payload-> '+payload);

        Http http = new Http();
        HttpResponse res = http.send(req);

        ExtractResult out = new ExtractResult();
        out.statusCode = res.getStatusCode();
        out.rawResponse = res.getBody();
        out.keyValuePairs = new List<Map<String, Object>>();
        out.entities = new List<Object>();

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            return out;
        }

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> document = (Map<String, Object>) root.get('document');
        if (document == null) return out;

        out.text = (String) document.get('text');

        Object entitiesObj = document.get('entities');
        if (entitiesObj != null) {
            out.entities = (List<Object>) entitiesObj;
        }

        List<Object> pages = (List<Object>) document.get('pages');
        if (pages != null) {
            for (Object pageObj : pages) {
                Map<String, Object> page = (Map<String, Object>) pageObj;
                Decimal pageNumber = (Decimal) page.get('pageNumber');

                List<Object> formFields = (List<Object>) page.get('formFields');
                if (formFields == null) continue;

                for (Object ffObj : formFields) {
                    Map<String, Object> ff = (Map<String, Object>) ffObj;

                    Map<String, Object> fieldName = (Map<String, Object>) ff.get('fieldName');
                    Map<String, Object> fieldValue = (Map<String, Object>) ff.get('fieldValue');

                    String keyText = layoutText(fieldName, out.text);
                    String valueText = layoutText(fieldValue, out.text);

                    Decimal keyConf = fieldName == null ? null : (Decimal) fieldName.get('confidence');
                    Decimal valueConf = fieldValue == null ? null : (Decimal) fieldValue.get('confidence');

                    if (!String.isBlank(keyText) || !String.isBlank(valueText)) {
                        out.keyValuePairs.add(new Map<String, Object>{
                            'key' => keyText,
                            'value' => valueText,
                            'keyConfidence' => keyConf,
                            'valueConfidence' => valueConf,
                            'pageNumber' => pageNumber
                        });
                    }
                }
            }
        }

        return out;
    }

    private static String layoutText(Map<String, Object> layout, String fullText) {
        if (layout == null || String.isBlank(fullText)) return '';

        Map<String, Object> textAnchor = (Map<String, Object>) layout.get('textAnchor');
        if (textAnchor == null) return '';

        List<Object> segments = (List<Object>) textAnchor.get('textSegments');
        if (segments == null || segments.isEmpty()) return '';

        String result = '';
        for (Object segObj : segments) {
            Map<String, Object> seg = (Map<String, Object>) segObj;
            Integer startIdx = seg.containsKey('startIndex')
                ? Integer.valueOf(String.valueOf(seg.get('startIndex')))
                : 0;
            Integer endIdx = Integer.valueOf(String.valueOf(seg.get('endIndex')));

            if (startIdx < 0) startIdx = 0;
            if (endIdx > fullText.length()) endIdx = fullText.length();
            if (startIdx < endIdx) {
                result += fullText.substring(startIdx, endIdx);
            }
        }
        return result.trim();
    }
}