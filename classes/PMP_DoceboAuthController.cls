public with sharing class PMP_DoceboAuthController {

    private static final String CLIENT_ID = '56048a48-2079-4134-b4e6-7f246e6c6667';
    private static final String CLIENT_SECRET = 'rqJ8Q~KGPhlPm6WjuZ4C25~44rML4-~u0BPzub_5';

    private static final String INTEL_TOKEN_ENDPOINT = 'https://apis-sandbox.intel.com/v1/auth/token';
    private static final String DOCEBO_AUTH_ENDPOINT = 'https://apis-sandbox.intel.com/m2r/docebo/auth';
    private static final String LEARNING_MANAGEMENT_ENDPOINT = 'https://intelexternalsandbox.docebosaas.com/learn/v1/channels/97/assets?page_size=200&page=1';
        //'https://apis-sandbox.intel.com/m2r/learning-management/external';
    //https://intelexternalsandbox.docebosaas.com/learn/v1/channels/97/assets?page_size=200&page=1

    private static final String TEST_USERNAME = 'test.endpoints@test.test';


    @AuraEnabled
    public static String getDoceboAccessToken() {

        try {

            String username = TEST_USERNAME;

            // For logged-in Salesforce user:
            // String username = UserInfo.getUserEmail();

            String credentials = CLIENT_ID + ':' + CLIENT_SECRET;
            String basicAuth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(credentials));

            HttpRequest tokenReq = new HttpRequest();

            tokenReq.setEndpoint(INTEL_TOKEN_ENDPOINT);
            tokenReq.setMethod('POST');
            tokenReq.setHeader('Authorization', basicAuth);
            tokenReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            tokenReq.setHeader('Accept', 'application/json');
            tokenReq.setBody('grant_type=client_credentials');
            tokenReq.setTimeout(30000);

            Http http = new Http();

            HttpResponse tokenRes = http.send(tokenReq);

            System.debug('STEP 1 STATUS: ' + tokenRes.getStatusCode());
            System.debug('STEP 1 RESPONSE: ' + tokenRes.getBody());

            if (tokenRes.getStatusCode() < 200 || tokenRes.getStatusCode() >= 300) {
                throw new AuraHandledException('Intel authentication failed: ' + tokenRes.getBody());
            }

            Map<String, Object> tokenData = (Map<String, Object>) JSON.deserializeUntyped(tokenRes.getBody());

            String intelAccessToken = String.valueOf(tokenData.get('access_token'));

            if (String.isBlank(intelAccessToken)) {
                throw new AuraHandledException('Intel access token not returned');
            }

            System.debug('Intel token length: ' + intelAccessToken.length());


            // Step 2 - Get Docebo token

            HttpRequest doceboReq = new HttpRequest();

            doceboReq.setEndpoint(DOCEBO_AUTH_ENDPOINT);
            doceboReq.setMethod('POST');
            doceboReq.setHeader('Authorization', 'Bearer ' + intelAccessToken);
            doceboReq.setHeader('Content-Type', 'application/json');
            doceboReq.setHeader('Accept', 'application/json');
            doceboReq.setBody(JSON.serialize(new Map<String, String>{'username' => username}));
            doceboReq.setTimeout(30000);

            HttpResponse doceboRes = http.send(doceboReq);

            System.debug('STEP 2 STATUS: ' + doceboRes.getStatusCode());
            System.debug('STEP 2 RESPONSE: ' + doceboRes.getBody());

            if (doceboRes.getStatusCode() < 200 || doceboRes.getStatusCode() >= 300) {
                throw new AuraHandledException('Docebo authentication failed: ' + doceboRes.getBody());
            }

            Map<String, Object> doceboData = (Map<String, Object>) JSON.deserializeUntyped(doceboRes.getBody());

            String doceboAccessToken = String.valueOf(doceboData.get('access_token'));

            if (String.isBlank(doceboAccessToken)) {
                throw new AuraHandledException('Docebo access token not returned');
            }

            System.debug('Docebo token length: ' + doceboAccessToken.length());

            // This is the token returned to the LWC.
            return doceboAccessToken;

        } catch (AuraHandledException e) {

            throw e;

        } catch (Exception e) {

            System.debug('ERROR: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static LearningResponse getLearningData() {

        LearningResponse result = new LearningResponse();

        try {

            String username = TEST_USERNAME;

            result.username = username;

            String credentials = CLIENT_ID + ':' + CLIENT_SECRET;
            String basicAuth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(credentials));

            HttpRequest tokenReq = new HttpRequest();

            tokenReq.setEndpoint(INTEL_TOKEN_ENDPOINT);
            tokenReq.setMethod('POST');
            tokenReq.setHeader('Authorization', basicAuth);
            tokenReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            tokenReq.setHeader('Accept', 'application/json');
            tokenReq.setBody('grant_type=client_credentials');
            tokenReq.setTimeout(30000);

            Http http = new Http();

            HttpResponse tokenRes = http.send(tokenReq);

            System.debug('STEP 1 STATUS: ' + tokenRes.getStatusCode());
            System.debug('STEP 1 RESPONSE: ' + tokenRes.getBody());

            if (tokenRes.getStatusCode() < 200 || tokenRes.getStatusCode() >= 300) {
                result.success = false;
                result.statusCode = tokenRes.getStatusCode();
                result.responseBody = tokenRes.getBody();
                result.errorMessage = 'STEP 1 failed';
                return result;
            }

            Map<String, Object> tokenData = (Map<String, Object>) JSON.deserializeUntyped(tokenRes.getBody());

            String intelAccessToken = String.valueOf(tokenData.get('access_token'));

            if (String.isBlank(intelAccessToken)) {
                result.success = false;
                result.errorMessage = 'Intel access token not returned';
                return result;
            }

            result.intelTokenLength = intelAccessToken.length();


            // Step 2 - Get Docebo token

            HttpRequest doceboReq = new HttpRequest();

            doceboReq.setEndpoint(DOCEBO_AUTH_ENDPOINT);
            doceboReq.setMethod('POST');
            doceboReq.setHeader('Authorization', 'Bearer ' + intelAccessToken);
            doceboReq.setHeader('Content-Type', 'application/json');
            doceboReq.setHeader('Accept', 'application/json');
            doceboReq.setBody(JSON.serialize(new Map<String, String>{'username' => username}));
            doceboReq.setTimeout(30000);

            HttpResponse doceboRes = http.send(doceboReq);

            System.debug('STEP 2 STATUS: ' + doceboRes.getStatusCode());
            System.debug('STEP 2 RESPONSE: ' + doceboRes.getBody());

            if (doceboRes.getStatusCode() < 200 || doceboRes.getStatusCode() >= 300) {
                result.success = false;
                result.statusCode = doceboRes.getStatusCode();
                result.responseBody = doceboRes.getBody();
                result.errorMessage = 'STEP 2 failed';
                return result;
            }

            Map<String, Object> doceboData = (Map<String, Object>) JSON.deserializeUntyped(doceboRes.getBody());

            String doceboAccessToken = String.valueOf(doceboData.get('access_token'));

            if (String.isBlank(doceboAccessToken)) {
                result.success = false;
                result.errorMessage = 'Docebo access token not returned';
                return result;
            }

            result.doceboTokenLength = doceboAccessToken.length();


            // Step 3 - Learning Management API

            HttpRequest learningReq = new HttpRequest();

            learningReq.setEndpoint(LEARNING_MANAGEMENT_ENDPOINT);
            learningReq.setMethod('GET');
            learningReq.setHeader('Authorization', 'Bearer ' + doceboAccessToken);
            learningReq.setHeader('Accept', 'application/json');
            learningReq.setTimeout(30000);

            HttpResponse learningRes = http.send(learningReq);

            System.debug('STEP 3 STATUS: ' + learningRes.getStatusCode());
            System.debug('STEP 3 RESPONSE: ' + learningRes.getBody());

            result.statusCode = learningRes.getStatusCode();
            result.responseBody = learningRes.getBody();

            if (learningRes.getStatusCode() >= 200 && learningRes.getStatusCode() < 300) {
                result.success = true;
            } else {
                result.success = false;
                result.errorMessage = 'STEP 3 failed';
            }

            return result;

        } catch (Exception e) {

            System.debug('ERROR: ' + e.getMessage());

            result.success = false;
            result.errorMessage = e.getMessage();

            return result;
        }
    }


    public class LearningResponse {

        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public Integer statusCode;

        @AuraEnabled
        public String responseBody;

        @AuraEnabled
        public String errorMessage;

        @AuraEnabled
        public String username;

        @AuraEnabled
        public Integer intelTokenLength;

        @AuraEnabled
        public Integer doceboTokenLength;
    }
}