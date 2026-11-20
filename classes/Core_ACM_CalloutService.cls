public without sharing class Core_ACM_CalloutService {

    public class RequestConfig {
        public String endpoint;
        public String method;
        public Integer timeoutMs;
        public String contentType;

        public RequestConfig(String endpoint, String method, Integer timeoutMs, String contentType) {
            this.endpoint = endpoint;
            this.method = method;
            this.timeoutMs = timeoutMs;
            this.contentType = contentType;
        }
    }

    public static String executeAPICall(Core_ACM_Integration_Queue__c queueRecord, String integrationName) {
        return executeAPICall(queueRecord, getRequestConfig(integrationName));
    }

    public static String executeAPICall(Core_ACM_Integration_Queue__c queueRecord, RequestConfig requestConfig) {
        String responseBody;
        try {
            RequestConfig validatedRequestConfig = validateRequestConfig(requestConfig);
            String requestBody = prepareRequestBody(queueRecord);
            Map<String, String> requestHeaders = buildRequestHeaders(validatedRequestConfig);
            System.debug('Request Endpoint: ' + validatedRequestConfig.endpoint);
            System.debug('Request Method: ' + validatedRequestConfig.method);
            System.debug('Request Body: ' + requestBody);
            Core_RestClient restClient = new Core_RestClient(
                validatedRequestConfig.endpoint,
                validatedRequestConfig.method,
                requestHeaders,
                requestBody,
                validatedRequestConfig.timeoutMs == null ? Core_ACM_Constants.API_TIMEOUT : validatedRequestConfig.timeoutMs
            );
            HttpResponse httpResponse = restClient.invokeAPI();
            responseBody = httpResponse.getBody();
            System.debug('@@Response Body: ' + responseBody);
        }catch (Exception e) {
            UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'executeAPICall',
                'Callout error for queue record ' + queueRecord.Id + ': ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), queueRecord.Id);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return responseBody;
    }

    public static RequestConfig getRequestConfig(String integrationName) {
        if (String.isBlank(integrationName)) {
            throw new CalloutException('Integration name is required.');
        }
        String normalizedIntegrationName = integrationName.trim().toUpperCase();
        Core_ACM_Integration_Callout_Config__mdt configRecord = getIntegrationConfigRecord(normalizedIntegrationName);
        if (configRecord != null) {
            return new RequestConfig(
                configRecord.Endpoint__c,
                configRecord.Http_Method__c,
                configRecord.Timeout_Ms__c == null ? 30000 : configRecord.Timeout_Ms__c.intValue(),
                String.isBlank(configRecord.Content_Type__c) ? 'application/json' : configRecord.Content_Type__c
            );
        }
        throw new CalloutException('No callout configuration found for integration: ' + integrationName);
    }

    private static Core_ACM_Integration_Callout_Config__mdt getIntegrationConfigRecord(String integrationName) {
        List<Core_ACM_Integration_Callout_Config__mdt> configRecords = [
            SELECT DeveloperName, Endpoint__c, Http_Method__c, Timeout_Ms__c, Content_Type__c
            FROM Core_ACM_Integration_Callout_Config__mdt
            WHERE DeveloperName = :integrationName
            AND Is_Active__c = true
            LIMIT 1
        ];
        return configRecords.isEmpty() ? null : configRecords[0];
    }

    private static RequestConfig validateRequestConfig(RequestConfig requestConfig) {
        if (requestConfig == null) {
            throw new CalloutException('Request configuration is required.');
        }
        if (String.isBlank(requestConfig.endpoint)) {
            throw new CalloutException('Request endpoint is required.');
        }
        if (String.isBlank(requestConfig.method)) {
            throw new CalloutException('Request method is required.');
        }
        return requestConfig;
    }

    private static Map<String, String> buildRequestHeaders(RequestConfig requestConfig) {
        return new Map<String, String>{
            'Content-Type' => String.isBlank(requestConfig.contentType)
                ? Core_ACM_Constants.API_CONTENT_TYPE
                : requestConfig.contentType
        };
    }

    private static String prepareRequestBody(Core_ACM_Integration_Queue__c queueRecord) {
        String requestBody;
        try {
            requestBody = queueRecord.Core_Payload__c;
        } catch (Exception e) {
            UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'prepareRequestBody',
                'Invalid JSON payload for queue record ' + queueRecord.Id + ': ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), queueRecord.Id);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return requestBody;
    }
}