public without sharing class Core_MDF_RestAPI_Logger {
    private static final String TRANSACTION_ENTRY_OBJECT = 'Core_RestAPI_Transaction_Entry__c';
    private static final Integer MAX_SHORT_TEXT_LENGTH = 255;
    private static final Integer MAX_LONG_TEXT_LENGTH = 131072;
    private static UserContext cachedUserContext;
    private static final Map<String, Map<String, ErrorConfig>> cachedErrorConfigsByCategory =
        new Map<String, Map<String, ErrorConfig>>();

    public class LogRequest {
        public String apiName;
        public String endpoint;
        public String methodName;
        public String contextMessage;
        public String statusCode;
        public Boolean isSuccess;
        public Datetime entryTime;
        public Datetime exitTime;
        public String apiVersion;
        public Object requestPayload;
        public Object responsePayload;
        public List<String> errors;
        public Map<String, Object> additionalFields;
    }

    private class UserContext {
        public Id userId;
        public String profileName;
        public Id contactId;
        public Id accountId;
    }

    public static Id logToTransactionEntry(LogRequest request) {
        try {
            if (request == null) {
                request = new LogRequest();
            }

            SObject logRecord = (SObject)Type.forName(TRANSACTION_ENTRY_OBJECT).newInstance();
            if (logRecord == null) {
                return null;
            }

            Datetime whenValue = request.entryTime == null ? System.now() : request.entryTime;
            RestRequest restRequest = RestContext.request;
            String resolvedEndpoint = firstNonBlank(
                request.endpoint,
                restRequest != null ? restRequest.requestURI : null,
                request.apiName
            );
            String resolvedMethod = firstNonBlank(
                request.methodName,
                restRequest != null ? restRequest.httpMethod : null,
                'POST'
            );
            String requestPayload = serializeSafely(request.requestPayload);
            String responsePayload = serializeSafely(request.responsePayload);
            String errorPayload = (request.errors == null || request.errors.isEmpty())
                ? null
                : String.join(request.errors, '\n');
            String details = buildDetails(request.contextMessage, requestPayload, responsePayload, errorPayload);

            Datetime exitTimeValue = request.exitTime != null ? request.exitTime : System.now();
            Long durationMs = exitTimeValue.getTime() - whenValue.getTime();
            Decimal durationValue = Decimal.valueOf(String.valueOf(durationMs));
            UserContext userContext = getUserContext();
            String userAgent = (restRequest != null && restRequest.headers != null) ? restRequest.headers.get('User-Agent') : null;
            String host = null;
            String remoteAddress = null;
            if (restRequest != null && restRequest.headers != null) {
                host = restRequest.headers.get('Host');
                if (String.isBlank(host)) host = restRequest.headers.get('X-Forwarded-Host');
                remoteAddress = restRequest.headers.get('X-Forwarded-For');
            }
            String resolvedApiVersion = firstNonBlank(request.apiVersion, extractVersionFromUri(resolvedEndpoint), null);
            String requestIdParam = extractIdFromUri(resolvedEndpoint);

            // Map API names to values using try-catch for safe assignment
            putSafeValue(logRecord, 'Core_API_Name__c', abbreviate(request.apiName, 200));
            putSafeValue(logRecord, 'Core_API__c', abbreviate(resolvedEndpoint, 100));
            putSafeValue(logRecord, 'Core_Origin__c', abbreviate(request.apiName, 255));
            putSafeValue(logRecord, 'Core_Message__c', abbreviate(firstNonBlank(request.contextMessage, resolvedEndpoint, request.apiName), 255));
            putSafeValue(logRecord, 'Core_Severity__c', Boolean.valueOf(request.isSuccess) ? 'Info' : 'Error');
            putSafeValue(logRecord, 'Core_Http_Method__c', resolvedMethod);
            putSafeValue(logRecord, 'Core_Status_Code__c', request.statusCode);
            putSafeValue(logRecord, 'Core_Host__c', host);
            putSafeValue(logRecord, 'Core_Remote_address__c', abbreviate(remoteAddress, 255));
            putSafeValue(logRecord, 'Core_User__c', userContext.userId);
            putSafeValue(logRecord, 'Core_Contact__c', userContext.contactId);
            putSafeValue(logRecord, 'Core_Account__c', userContext.accountId);
            putSafeValue(logRecord, 'Core_User_Agent__c', abbreviate(userAgent, 255));
            putSafeValue(logRecord, 'Core_Entry_Time__c', whenValue);
            putSafeValue(logRecord, 'Core_Exit_Time__c', exitTimeValue);
            putSafeValue(logRecord, 'Core_Duration__c', durationValue);
            putSafeValue(logRecord, 'Core_Request_Body__c', abbreviate(requestPayload, 255));
            putSafeValue(logRecord, 'Core_Params__c', abbreviate(requestIdParam, MAX_LONG_TEXT_LENGTH));
            putSafeValue(logRecord, 'Core_Details__c', abbreviate(details, 131072));
            putSafeValue(logRecord, 'Core_API_Version__c', abbreviate(resolvedApiVersion, 20));

            if (Boolean.valueOf(request.isSuccess) == false) {
                putSafeValue(logRecord, 'Core_Error_Id__c', abbreviate(request.statusCode, 30));
            }

            if (request.additionalFields != null) {
                for (String fieldApiName : request.additionalFields.keySet()) {
                    putSafeValue(logRecord, fieldApiName, request.additionalFields.get(fieldApiName));
                }
            }

            Database.insert(logRecord, AccessLevel.SYSTEM_MODE);
            return (Id) logRecord.get('Id');
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            System.debug(LoggingLevel.ERROR, 'Failed to write transaction entry: ' + e.getMessage());
            return null;
        }
    }

    public static Id logToTransactionEntry(
        String apiName,
        Object requestPayload,
        Object responsePayload,
        String statusCode,
        Boolean isSuccess,
        List<String> errors
    ) {
        LogRequest request = new LogRequest();
        request.apiName = apiName;
        request.requestPayload = requestPayload;
        request.responsePayload = responsePayload;
        request.statusCode = statusCode;
        request.isSuccess = isSuccess;
        request.errors = errors;
        request.entryTime = System.now();
        return logToTransactionEntry(request);
    }

    public static Id logFromRestContext(
        String apiName,
        Object responsePayload,
        String statusCode,
        Boolean isSuccess,
        List<String> errors,
        String contextMessage
    ) {
        LogRequest request = new LogRequest();
        RestRequest restRequest = RestContext.request;

        request.apiName = apiName;
        request.endpoint = restRequest != null ? restRequest.requestURI : null;
        request.methodName = restRequest != null ? restRequest.httpMethod : null;
        request.requestPayload = restRequest != null && restRequest.requestBody != null ? restRequest.requestBody.toString() : null;
        request.responsePayload = responsePayload;
        request.statusCode = statusCode;
        request.isSuccess = isSuccess;
        request.errors = errors;
        request.contextMessage = contextMessage;
        request.entryTime = System.now();

        return logToTransactionEntry(request);
    }

    private static String buildDetails(String contextMessage, String requestPayload, String responsePayload, String errorsPayload) {
        List<String> parts = new List<String>();

        if (String.isNotBlank(contextMessage)) {
            parts.add(contextMessage);
        }
        if (String.isNotBlank(errorsPayload)) {
            parts.add('Errors:\n' + errorsPayload);
        }
        if (String.isNotBlank(requestPayload)) {
            parts.add('Request Body:\n' + requestPayload);
        }
        if (String.isNotBlank(responsePayload)) {
            parts.add('Response Payload:\n' + responsePayload);
        }

        return parts.isEmpty() ? null : String.join(parts, '\n\n');
    }

    private static String buildSectionDetails(String sectionOneLabel, String sectionOneBody, String sectionTwoLabel, String sectionTwoBody) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(sectionOneBody)) {
            parts.add(sectionOneLabel + ':\n' + sectionOneBody);
        }
        if (String.isNotBlank(sectionTwoBody)) {
            parts.add(sectionTwoLabel + ':\n' + sectionTwoBody);
        }
        return parts.isEmpty() ? null : String.join(parts, '\n\n');
    }

    private static UserContext getUserContext() {
        if (cachedUserContext != null) {
            return cachedUserContext;
        }

        cachedUserContext = new UserContext();
        cachedUserContext.userId = UserInfo.getUserId();

        try {
            User currentUser = [
                SELECT Id, ContactId
                FROM User
                WHERE Id = :cachedUserContext.userId
                LIMIT 1
            ];

            cachedUserContext.contactId = currentUser.ContactId;
            cachedUserContext.accountId = getAccountIdFromContact(currentUser.ContactId);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            // Leave optional fields null when user-contact relationship is not accessible.
        }

        return cachedUserContext;
    }

    private static Id getAccountIdFromContact(Id contactId) {
        if (contactId == null) {
            return null;
        }

        try {
            Contact contactRecord = [
                SELECT AccountId
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
            return contactRecord != null ? contactRecord.AccountId : null;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    private static String extractIdFromUri(String uri) {
        if (String.isBlank(uri)) {
            return null;
        }

        String normalized = uri;
        Integer queryIndex = normalized.indexOf('?');
        if (queryIndex >= 0) {
            normalized = normalized.substring(0, queryIndex);
        }

        Integer lastSlashIndex = normalized.lastIndexOf('/');
        if (lastSlashIndex < 0 || lastSlashIndex == normalized.length() - 1) {
            return null;
        }

        String candidate = normalized.substring(lastSlashIndex + 1).trim();
        return String.isBlank(candidate) ? null : candidate;
    }

    private static void putSafeValue(SObject record, String fieldName, Object value) {
        try {
            if (record != null && String.isNotBlank(fieldName)) {
                record.put(fieldName, value);
            }
        } catch (Exception ex) {
            // Silently ignore field assignment errors
        }
    }

    private static String extractVersionFromUri(String uri) {
        if (String.isBlank(uri)) {
            return null;
        }
        Pattern versionPattern = Pattern.compile('/(v\\d+\\.\\d+)/');
        Matcher versionMatcher = versionPattern.matcher(uri);
        return versionMatcher.find() ? versionMatcher.group(1) : null;
    }

    private static String firstNonBlank(String one, String two, String three) {
        if (String.isNotBlank(one)) {
            return one;
        }
        if (String.isNotBlank(two)) {
            return two;
        }
        return three;
    }

    private static String serializeSafely(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            return (String) value;
        }
        try {
            return JSON.serializePretty(value);
        } catch (Exception ex) {
            try {
                return String.valueOf(value);
            } catch (Exception ignoredEx) {
                return 'Unable to serialize value.';
            }
        }
    }

    private static String abbreviate(String inputValue, Integer maxLength) {
        if (String.isBlank(inputValue) || maxLength == null || maxLength <= 0) {
            return inputValue;
        }
        if (inputValue.length() <= maxLength) {
            return inputValue;
        }
        return inputValue.substring(0, maxLength);
    }

    public static void info(String message) {
        writeDebug(LoggingLevel.INFO, message);
    }

    public static void warning(String message) {
        writeDebug(LoggingLevel.WARN, message);
    }

    public static void error(String message) {
        writeDebug(LoggingLevel.ERROR, message);
    }

    public static void logSegmentInfo(String segmentName, String message) {
        info(formatSegmentMessage(segmentName, message));
    }

    public static void logSegmentError(String segmentName, String message) {
        error(formatSegmentMessage(segmentName, message));
    }

    public static void logMultiSegmentSPIF(String accountId, String program, Integer segmentCount, Boolean isSuccess) {
        info('Multi-Segment SPIF account=' + accountId + ', program=' + program + ', segmentCount=' + segmentCount + ', success=' + isSuccess);
    }

    private static String formatSegmentMessage(String segmentName, String message) {
        return 'SPIF segment=' + segmentName + ': ' + message;
    }

    private static void writeDebug(LoggingLevel level, String message) {
        System.debug(level, String.isBlank(message) ? '' : message);
    }
    
    /****************************************************************
    * Inner Class: ErrorConfig
    * Description: Wrapper for error configuration from custom setting.
    *****************************************************************/
    public class ErrorConfig {
        public String code;
        public String message;
        public Integer httpStatusCode;
    }
    /****************************************************************
    * Method Name: getErrorConfigDetails
    * Parameters: String errorCode, String category
    * Description: Retrieves error configuration from Core_RestAPI_Response_Codes__c custom setting filtered by error code and category.
    *****************************************************************/
    public static ErrorConfig getErrorConfigDetails(String errorCode, String category) {
        if (String.isBlank(errorCode) || String.isBlank(category)) {
            return null;
        }
        for (Core_MDF_External_API_Response_Codes__c setting : [Select Id, Core_Category__c, Core_Code__c, Core_Context_of_Error__c, Core_RestAPI_Error_Severity__c, Core_Http_Status_Code__c, Core_Log_Entry__c, Core_Message__c from Core_MDF_External_API_Response_Codes__c WHERE Core_Category__c =: category AND Core_Code__c =: errorCode]) {
                ErrorConfig config  = new ErrorConfig();
            	config.code         = setting.Core_Code__c;
            	config.message      = setting.Core_Message__c;
            	config.httpStatusCode = Integer.valueOf(setting.Core_Http_Status_Code__c);
                return config;
        }
        ErrorConfig genericConfig   = new ErrorConfig();
    	genericConfig.code          = '9999';
    	genericConfig.message       = System.Label.Core_MDF_ApplicationErrorMessage;
    	genericConfig.httpStatusCode = 500;
    	return genericConfig;
    }

    public static ErrorConfig getCachedErrorConfigDetails(String errorCode, String category) {
        if (String.isBlank(errorCode) || String.isBlank(category)) {
            return null;
        }

        if (!cachedErrorConfigsByCategory.containsKey(category)) {
            Map<String, ErrorConfig> configsByCode = new Map<String, ErrorConfig>();
            for (Core_MDF_External_API_Response_Codes__c setting : [
                SELECT Core_Code__c, Core_Message__c, Core_Http_Status_Code__c
                FROM Core_MDF_External_API_Response_Codes__c
                WHERE Core_Category__c = :category
            ]) {
                ErrorConfig config = new ErrorConfig();
                config.code = setting.Core_Code__c;
                config.message = setting.Core_Message__c;
                config.httpStatusCode = String.isBlank(setting.Core_Http_Status_Code__c)
                    ? 500
                    : Integer.valueOf(setting.Core_Http_Status_Code__c);
                configsByCode.put(config.code, config);
            }
            cachedErrorConfigsByCategory.put(category, configsByCode);
        }

        Map<String, ErrorConfig> configsByCode = cachedErrorConfigsByCategory.get(category);
        if (configsByCode.containsKey(errorCode)) {
            return configsByCode.get(errorCode);
        }

        ErrorConfig genericConfig = new ErrorConfig();
        genericConfig.code = '9999';
        genericConfig.message = System.Label.Core_MDF_ApplicationErrorMessage;
        genericConfig.httpStatusCode = 500;
        return genericConfig;
    }
}