/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Campaign_Details_RestAPI
 * Description     : Optimized REST API endpoint for retrieving campaign details.
 *                   Returns campaign record with related child objects:
 *                   - Core_MDF_Campaign_Budgets__c
 *                   - Core_MDF_Campaign_Outcomes__c
 * ----------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/v1.0/partnercenter/campaign/*')
global without sharing class Core_MDF_Campaign_Details_RestAPI {

    private static final Map<String, Map<String, String>> FIELD_LABEL_CACHE_BY_OBJECT = new Map<String, Map<String, String>>();

    @HttpGet
    global static void getCampaignDetails() {
        Datetime entryTime = System.now();
        CampaignDetailsResponse response = new CampaignDetailsResponse();
        List<String> logErrors;

        try {
            String campaignId = extractCampaignIdFromUrl();
            FieldDisplayMode fieldDisplayMode = resolveFieldDisplayMode();

            if (!fieldDisplayMode.isValid) {
                sendAndTrackError(
                    response,
                    Core_MDF_Campaign_APIUtil.CODE_7005_INVALID_FIELD_DISPLAY,
                    buildInvalidFieldDisplayDetails(fieldDisplayMode.invalidParameter),
                    fieldDisplayMode.invalidValue
                );
                return;
            }

            Boolean useFieldLabels = fieldDisplayMode.useLabels;

            if (String.isBlank(campaignId)) {
                sendAndTrackError(response, Core_MDF_Campaign_APIUtil.CODE_7002_CAMPAIGN_ID_EMPTY, null);
                return;
            }

            if (!isValidCampaignId(campaignId)) {
                sendAndTrackError(response, Core_MDF_Campaign_APIUtil.CODE_7004_INVALID_CAMPAIGN_ID, null);
                return;
            }

            CampaignDetailsData details = getCompositeDetails(campaignId, useFieldLabels);
            if (details == null) {
                // Treat null as permission error instead of "not found"
                // In multi-account scenarios, inaccessible records = permission denied
                sendAndTrackError(response, Core_MDF_Campaign_APIUtil.CODE_7008_INSUFFICIENT_PERMISSIONS, null);
                return;
            }

            sendSuccessResponse(details, Core_MDF_Campaign_APIUtil.MSG_CAMPAIGN_DETAILS_RETRIEVED, Core_MDF_Campaign_APIUtil.SUCCESS_200);
            response.statusCode = Core_MDF_Campaign_APIUtil.SUCCESS_200;
            response.isSuccess = true;
        } catch (Exception ex) {
            if (ex instanceof Core_MDF_CCP_RestAPI_Utility.AccessDeniedException) {
                sendAndTrackError(response, Core_MDF_Campaign_APIUtil.CODE_7008_INSUFFICIENT_PERMISSIONS, null);
                logErrors = new List<String>{ ex.getMessage() };
            } else {
                Core_MDF_CCP_UtilityClass.logError(ex);
                logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
                sendAndTrackError(response, Core_MDF_Campaign_APIUtil.CODE_7003_CAMPAIGN_INTERNAL_SERVER_ERROR, null);
            }
        } finally {
            Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
            String responseBodyText = (RestContext.response != null && RestContext.response.responseBody != null)
                ? RestContext.response.responseBody.toString()
                : null;
            logReq.apiName = 'Core_MDF_Campaign_Details_RestAPI';
            logReq.apiVersion = 'v1.0';
            logReq.contextMessage = 'GET campaign details';
            logReq.responsePayload = String.isNotBlank(responseBodyText)
                ? deserializeResponseForLog(responseBodyText)
                : response;
            logReq.statusCode = RestContext.response != null
                ? String.valueOf(RestContext.response.statusCode)
                : (response != null ? response.statusCode : '500');
            logReq.isSuccess = response != null ? response.isSuccess : false;
            logReq.errors = logErrors;
            logReq.entryTime = entryTime;
            logReq.exitTime = System.now();

            // Dynamically derive Core_API__c and Core_Params__c from the request URI.
            // requestURI does not include query params — those come from request.params.
            String reqUri = (RestContext.request != null) ? RestContext.request.requestURI : null;
            if (String.isNotBlank(reqUri)) {
                String normalizedPath = reqUri.removeStart('/services/apexrest');
                Integer lastSlash = normalizedPath.lastIndexOf('/');
                if (lastSlash > 0) {
                    logReq.endpoint = normalizedPath.substring(0, lastSlash);
                    String idSegment = normalizedPath.substring(lastSlash + 1);
                    if (String.isNotBlank(idSegment)) {
                        Map<String, String> qParams = RestContext.request.params;
                        List<String> qParts = new List<String>();
                        if (qParams != null) {
                            List<String> paramKeys = new List<String>();
                            paramKeys.addAll(qParams.keySet());
                            paramKeys.sort();
                            for (String k : paramKeys) {
                                qParts.add(k + '=' + qParams.get(k));
                            }
                        }
                        String paramsValue = idSegment + (qParts.isEmpty() ? '' : '?' + String.join(qParts, '&'));
                        logReq.additionalFields = new Map<String, Object>{ 'Core_Params__c' => paramsValue };
                    }
                }
            }

            Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
        }
    }

    /**
     * Retrieve campaign record and related child objects.
     * Uses standard REST API for campaign details retrieval with field filtering.
     * Throws AccessDeniedException if user lacks permission.
     * Returns null if campaign cannot be retrieved or does not exist.
     * 
     * @param campaignId The ID of the campaign to retrieve
     * @return CampaignDetailsData wrapper containing campaign data and related child records, or null if not found
     * @throws Core_MDF_CCP_RestAPI_Utility.AccessDeniedException when user lacks permission
     */
    private static CampaignDetailsData getCompositeDetails(String campaignId, Boolean useFieldLabels) {
        // Retrieve campaign details via standard REST API with configured field filtering
        // REST API call will detect permission errors (403) and throw AccessDeniedException
        Map<String, Object> filteredCampaignData = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            Core_MDF_Campaign_APIUtil.CAMPAIGN_OBJECT_API_NAME,
            campaignId,
            Core_MDF_Campaign_APIUtil.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );

        if (filteredCampaignData == null) {
            return null;
        }

        // Create response wrapper with guaranteed field order
        CampaignDetailsData responseData = new CampaignDetailsData();
        responseData.details = useFieldLabels
            ? applyCampaignFieldLabels(filteredCampaignData)
            : filteredCampaignData;
        responseData.budgets = queryChildRecords(Core_MDF_Campaign_APIUtil.CAMPAIGN_BUDGETS_OBJECT_API, campaignId, useFieldLabels);
        responseData.outcomes = queryChildRecords(Core_MDF_Campaign_APIUtil.CAMPAIGN_OUTCOMES_OBJECT_API, campaignId, useFieldLabels);

        return responseData;
    }

    /**
     * Query child records for a given parent Campaign and child object type.
     * 
     * @param objectApiName The API name of the child object
     * @param campaignId The parent campaign ID
    * @return List of maps containing child record data with field labels as keys
     */
    private static List<Map<String, Object>> queryChildRecords(String objectApiName, String campaignId, Boolean useFieldLabels) {
        List<SObject> rows;
        List<String> queryFieldApiNames = new List<String>();
        Boolean isBudgetObject = objectApiName == Core_MDF_Campaign_APIUtil.CAMPAIGN_BUDGETS_OBJECT_API;

        // Hardcoded field selections for each child object type - explicit for performance
        if (isBudgetObject) {
            queryFieldApiNames.addAll(new List<String>{
                'Core_MDF_Budget_Amt__c',
                'Core_MDF_Reimbursement_Rate_Pct__c',
                'Core_MDF_Reimbursement_Amt__c'
            });
            rows = [
                SELECT Core_MDF_Budget_Name_Id__r.Title, Core_MDF_Budget_Amt__c,
                       Core_MDF_Reimbursement_Rate_Pct__c, Core_MDF_Reimbursement_Amt__c
                FROM Core_MDF_Campaign_Budgets__c
                WHERE Core_MDF_Active_Ind__c=true AND Core_MDF_Campaign_Id__c = :campaignId
                  AND (Core_MDF_Budget_Type_Nm__c = null OR Core_MDF_Budget_Type_Nm__c NOT IN ('MDF', 'MDF+'))
                                    LIMIT :Core_MDF_Campaign_APIUtil.MAX_CHILD_ROWS
            ];
        } else if (objectApiName == Core_MDF_Campaign_APIUtil.CAMPAIGN_OUTCOMES_OBJECT_API) {
            queryFieldApiNames.addAll(new List<String>{
                'Core_MDF_Outcomes_nm__c',
                'Core_MDF_Goal_Quantity_nbr__c',
                'Core_MDF_Quantity_nbr__c',
                'Core_MDF_Outcome_Criteria_txt__c',
                'Core_MDF_Initial_Baseline_Quantity_nbr__c'
            });
            rows = [
                SELECT Core_MDF_Outcomes_nm__c, Core_MDF_Goal_Quantity_nbr__c,
                       Core_MDF_Quantity_nbr__c, Core_MDF_Outcome_Criteria_txt__c,Core_MDF_Initial_Baseline_Quantity_nbr__c
                FROM Core_MDF_Campaign_Outcomes__c
                WHERE Core_MDF_Active_Ind__c=true AND Core_MDF_Campaign_Id__c = :campaignId
                LIMIT :Core_MDF_Campaign_APIUtil.MAX_CHILD_ROWS
            ];
        } else {
            return new List<Map<String, Object>>();
        }

        Map<String, String> fieldLabelsByApiName = useFieldLabels
            ? getDescribeFieldLabelsByApiName(objectApiName, queryFieldApiNames)
            : new Map<String, String>();
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (SObject row : rows) {
            Map<String, Object> rowMap = toLabelMap(row, fieldLabelsByApiName);
            if (isBudgetObject) {
                SObject budgetNameRef = row.getSObject('Core_MDF_Budget_Name_Id__r');
                rowMap.put('Title', budgetNameRef != null ? budgetNameRef.get('Title') : null);
                rowMap.remove('Core_MDF_Budget_Name_Id__r');
                rowMap.remove('Core_MDF_Budget_Name_Id__c');
            }
            result.add(rowMap);
        }
        return result;
    }

    private static Map<String, Object> toLabelMap(SObject record, Map<String, String> fieldLabelsByApiName) {
        Map<String, Object> result = new Map<String, Object>();

        if (record == null) {
            return result;
        }

        try {
            Map<String, Object> fieldsToValue = record.getPopulatedFieldsAsMap();
            for (String fieldName : fieldsToValue.keySet()) {
                if (fieldName == 'Id') {
                    continue;
                }

                String labelName = (fieldLabelsByApiName != null && fieldLabelsByApiName.containsKey(fieldName))
                    ? fieldLabelsByApiName.get(fieldName)
                    : fieldName;
                result.put(labelName, fieldsToValue.get(fieldName));
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }

        return result;
    }

    private static Map<String, Object> applyCampaignFieldLabels(Map<String, Object> campaignData) {
        Map<String, Object> labeledData = new Map<String, Object>();
        if (campaignData == null || campaignData.isEmpty()) {
            return labeledData;
        }

        Map<String, String> labelByApiName = getConfiguredFieldLabelMap(
            Core_MDF_Campaign_APIUtil.CAMPAIGN_OBJECT_API_NAME,
            new List<String>(campaignData.keySet())
        );
        for (String fieldApiName : campaignData.keySet()) {
            String fieldLabel = labelByApiName.containsKey(fieldApiName) ? labelByApiName.get(fieldApiName) : fieldApiName;
            labeledData.put(fieldLabel, campaignData.get(fieldApiName));
        }

        return labeledData;
    }

    private static Map<String, String> getConfiguredFieldLabelMap(String objectApiName, List<String> fieldApiNames) {
        Map<String, String> labelByApiName = new Map<String, String>();
        if (String.isBlank(objectApiName)) {
            return labelByApiName;
        }

        Map<String, String> configuredLabelsByApiName = getOrLoadConfiguredLabelsByObject(objectApiName);
        if (configuredLabelsByApiName.isEmpty()) {
            return labelByApiName;
        }

        Set<String> filterFields = new Set<String>();
        if (fieldApiNames != null) {
            for (String fieldApiName : fieldApiNames) {
                if (String.isNotBlank(fieldApiName)) {
                    filterFields.add(fieldApiName.trim());
                }
            }
        }

        if (filterFields.isEmpty()) {
            labelByApiName.putAll(configuredLabelsByApiName);
            return labelByApiName;
        }

        for (String fieldApiName : filterFields) {
            if (configuredLabelsByApiName.containsKey(fieldApiName)) {
                labelByApiName.put(fieldApiName, configuredLabelsByApiName.get(fieldApiName));
            }
        }

        return labelByApiName;
    }

    private static Map<String, String> getOrLoadConfiguredLabelsByObject(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return new Map<String, String>();
        }

        if (FIELD_LABEL_CACHE_BY_OBJECT.containsKey(objectApiName)) {
            return FIELD_LABEL_CACHE_BY_OBJECT.get(objectApiName);
        }

        Map<String, String> labelsByApiName = new Map<String, String>();
        for (Core_MDF_Custom_Layout_Configurations__c config : [
            SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c, Core_MDF_Record_Name_nm__c
            FROM Core_MDF_Custom_Layout_Configurations__c
            WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
              AND API_Visibility__c = true
            ORDER BY Core_MDF_Field_API_Name_txt__c ASC, CreatedDate DESC, Id DESC
        ]) {
            if (String.isBlank(config.Core_MDF_Field_API_Name_txt__c)) {
                continue;
            }

            String rawFieldApiName = config.Core_MDF_Field_API_Name_txt__c.trim();
            // Prefer the configured lookup display path (Core_MDF_Record_Name_nm__c) over the raw field API name.
            String lookupFieldApiName = String.isNotBlank(config.Core_MDF_Record_Name_nm__c)
                ? config.Core_MDF_Record_Name_nm__c.trim()
                : null;

            String fieldLabel = String.isBlank(config.Core_MDF_Field_Label_txt__c)
                ? (lookupFieldApiName != null ? lookupFieldApiName : rawFieldApiName)
                : config.Core_MDF_Field_Label_txt__c.trim();

            // Map both the raw field name and the lookup display path so the label resolves
            // regardless of which key format the filtered record data ends up using.
            if (!labelsByApiName.containsKey(rawFieldApiName)) {
                labelsByApiName.put(rawFieldApiName, fieldLabel);
            }
            if (lookupFieldApiName != null && !labelsByApiName.containsKey(lookupFieldApiName)) {
                labelsByApiName.put(lookupFieldApiName, fieldLabel);
            }
        }

        FIELD_LABEL_CACHE_BY_OBJECT.put(objectApiName, labelsByApiName);
        return labelsByApiName;
    }

    private static Map<String, String> getDescribeFieldLabelsByApiName(String objectApiName, List<String> fieldApiNames) {
        Map<String, String> labelByApiName = new Map<String, String>();
        if (String.isBlank(objectApiName) || fieldApiNames == null || fieldApiNames.isEmpty()) {
            return labelByApiName;
        }

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType == null) {
            return labelByApiName;
        }

        Map<String, Schema.SObjectField> fields = objectType.getDescribe().fields.getMap();
        for (String fieldApiName : fieldApiNames) {
            if (String.isBlank(fieldApiName) || !fields.containsKey(fieldApiName)) {
                continue;
            }

            try {
                String fieldLabel = fields.get(fieldApiName).getDescribe().getLabel();
                labelByApiName.put(fieldApiName, String.isBlank(fieldLabel) ? fieldApiName : fieldLabel);
            } catch (Exception ex) {
                labelByApiName.put(fieldApiName, fieldApiName);
            }
        }

        return labelByApiName;
    }

    private static FieldDisplayMode resolveFieldDisplayMode() {
        FieldDisplayMode mode = new FieldDisplayMode();
        if (RestContext.request == null || RestContext.request.params == null) {
            return mode;
        }

        Map<String, String> params = RestContext.request.params;
        String fieldParam;
        for (String paramKey : params.keySet()) {
            if (String.isBlank(paramKey)) {
                continue;
            }
            if (Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_PARAM == normalizeFieldDisplayToken(paramKey)) {
                fieldParam = params.get(paramKey);
                continue;
            }

            mode.isValid = false;
            mode.invalidParameter = paramKey;
            mode.invalidValue = paramKey;
            return mode;
        }

        if (String.isBlank(fieldParam)) {
            return mode;
        }

        String normalizedValue = normalizeFieldDisplayToken(fieldParam);
        if (Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_LABEL == normalizedValue) {
            mode.useLabels = true;
            return mode;
        }
        if (Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_TECHNICAL_NAME == normalizedValue) {
            return mode;
        }

        mode.isValid = false;
        mode.invalidParameter = Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_PARAM;
        mode.invalidValue = fieldParam;

        return mode;
    }

    private static String normalizeFieldDisplayToken(String token) {
        if (String.isBlank(token)) {
            return null;
        }

        return token.trim().toLowerCase().replaceAll('[^a-z0-9]', '');
    }

    /**
     * Extract campaign ID from REST request URI.
     * Expected format: /services/apexrest/v1.0/partnercenter/campaigndetails/{campaignId}
     * Handles query parameters and extra path segments gracefully.
     * 
     * @return The extracted campaign ID, or null if not found
     */
    private static String extractCampaignIdFromUrl() {
        try {
            if (RestContext.request == null || String.isBlank(RestContext.request.requestURI)) {
                return null;
            }

            String requestUri = RestContext.request.requestURI;
            Integer segmentIndex = requestUri.indexOf(Core_MDF_Campaign_APIUtil.CAMPAIGN_SEGMENT);
            if (segmentIndex == -1) {
                return null;
            }

            String campaignIdPart = requestUri.substring(segmentIndex + Core_MDF_Campaign_APIUtil.CAMPAIGN_SEGMENT.length());
            Integer queryIndex = campaignIdPart.indexOf('?');
            if (queryIndex != -1) {
                campaignIdPart = campaignIdPart.substring(0, queryIndex);
            }

            if (String.isBlank(campaignIdPart)) {
                return null;
            }
            return campaignIdPart.trim();
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    /**
     * Validate that the provided string is a valid Salesforce Campaign ID.
     * Checks length (15 or 18 chars), alphanumeric format, and Campaign prefix.
     * 
     * @param campaignId The ID string to validate
     * @return true if valid Campaign ID, false otherwise
     */
    private static Boolean isValidCampaignId(String campaignId) {
        if (String.isBlank(campaignId)) {
            return false;
        }

        String normalized = campaignId.trim();
        Integer idLength = normalized.length();

        // Salesforce IDs are 15 or 18 characters
        if (idLength != Core_MDF_Campaign_APIUtil.SALESFORCE_ID_LENGTH_15 && idLength != Core_MDF_Campaign_APIUtil.SALESFORCE_ID_LENGTH_18) {
            return false;
        }

        // IDs contain only alphanumeric characters
        if (!Pattern.matches('^[a-zA-Z0-9]+$', normalized)) {
            return false;
        }

        try {
            Id typedId = Id.valueOf(normalized);
            String idString = String.valueOf(typedId);

            // Campaign object has key prefix 701
            return idString.startsWith(Core_MDF_Campaign_APIUtil.CAMPAIGN_KEY_PREFIX);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return false;
        }
    }

    private static Object deserializeResponseForLog(String responseBodyText) {
        if (String.isBlank(responseBodyText)) {
            return null;
        }

        try {
            return JSON.deserializeUntyped(responseBodyText);
        } catch (Exception ex) {
            return responseBodyText;
        }
    }

    /**
     * Send success response with campaign data.
     * Uses standard Core_MDF_APIResponse wrapper.
     * Response structure: { isSuccess, success, details }
     * 
     * @param data Campaign details and related child records
     * @param message Success message to return
     * @param code HTTP status code as string (e.g., '200')
     */
    private static void sendSuccessResponse(Object data, String message, String code) {
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            Integer statusCodeInt = parseStatusCode(code);
            response.statusCode = statusCodeInt;

            // Build data structure with guaranteed field order
            Map<String, Object> detailsMap = null;
            if (data instanceof CampaignDetailsData) {
                CampaignDetailsData campaignData = (CampaignDetailsData) data;
                detailsMap = new Map<String, Object>();
                detailsMap.put('details', campaignData.details);
                detailsMap.put(Core_MDF_Campaign_APIUtil.RESPONSE_KEY_CAMPAIGN_BUDGETS, campaignData.budgets);
                detailsMap.put(Core_MDF_Campaign_APIUtil.RESPONSE_KEY_CAMPAIGN_PURPOSE, campaignData.outcomes);
            } else {
                detailsMap = (Map<String, Object>) data;
            }

            // Create standard API response
            Core_MDF_APIResponse apiResponse = new Core_MDF_APIResponse();
            apiResponse.setSuccessInfo(message, code);
            apiResponse.details = detailsMap;

            response.responseBody = Blob.valueOf(JSON.serialize(apiResponse.getSerializedResponse()));
            RestContext.response = response;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            sendMinimalErrorResponse(String.valueOf(Core_MDF_Campaign_APIUtil.HTTP_STATUS_500));
        }
    }

    /**
     * Send error response.
     * Uses standard Core_MDF_APIResponse wrapper.
     * Response structure: { isSuccess, error, details }
     * 
     * @param code HTTP error code as string (e.g., '7004')
     */
    private static void sendErrorResponse(String code) {
        sendErrorResponse(code, null, null);
    }

    private static void sendAndTrackError(CampaignDetailsResponse response, String code, Object details) {
        sendAndTrackError(response, code, details, null);
    }

    private static void sendAndTrackError(CampaignDetailsResponse response, String code, Object details, String errorMessageOverride) {
        sendErrorResponse(code, details, errorMessageOverride);
        setErrorTracking(response);
    }

    private static void sendErrorResponse(String code, Object details) {
        sendErrorResponse(code, details, null);
    }

    private static void sendErrorResponse(String code, Object details, String errorMessageOverride) {
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            CampaignErrorConfig errorConfig = getCampaignErrorConfig(code);
            if (errorConfig == null) {
                sendMinimalErrorResponse(String.valueOf(Core_MDF_Campaign_APIUtil.HTTP_STATUS_500));
                return;
            }
            response.statusCode = errorConfig.httpStatusCode;
            String responseMessage = errorConfig.message;
            if (String.isNotBlank(errorMessageOverride)) {
                if (String.isNotBlank(responseMessage) && responseMessage.contains('{value}')) {
                    responseMessage = responseMessage.replace('{value}', errorMessageOverride);
                } else {
                    String separator = (String.isBlank(responseMessage) || responseMessage.endsWith(' ')) ? '' : ' ';
                    responseMessage = String.valueOf(responseMessage) + separator + errorMessageOverride;
                }
            }

            // Create standard API error response
            Core_MDF_APIResponse apiResponse = new Core_MDF_APIResponse();
            apiResponse.setErrorInfo(responseMessage, errorConfig.code);
            apiResponse.details = details;

            response.responseBody = Blob.valueOf(JSON.serialize(apiResponse.getSerializedResponse()));
            RestContext.response = response;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            sendMinimalErrorResponse(String.valueOf(Core_MDF_Campaign_APIUtil.HTTP_STATUS_500));
        }
    }
   
    private static Map<String, Object> buildInvalidFieldDisplayDetails() {
        return buildInvalidFieldDisplayDetails(null);
    }
   
    private static Map<String, Object> buildInvalidFieldDisplayDetails(String invalidParameter) {
        return new Map<String, Object>{
            'parameter' => String.isBlank(invalidParameter) ? Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_PARAM : invalidParameter,
            'expectedParameter' => Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_PARAM,
            'allowedValues' => new List<String>{
                Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_LABEL,
                Core_MDF_Campaign_APIUtil.FIELD_DISPLAY_TECHNICAL_NAME
            }
        };
    }

    private static void setErrorTracking(CampaignDetailsResponse response) {
        response.statusCode = (RestContext.response != null && RestContext.response.statusCode != null)
            ? String.valueOf(RestContext.response.statusCode)
            : String.valueOf(Core_MDF_Campaign_APIUtil.HTTP_STATUS_500);
        response.isSuccess = false;
    }

    private static CampaignErrorConfig getCampaignErrorConfig(String errorCode) {
        if (String.isBlank(errorCode)) {
            return null;
        }

        try {
            Core_MDF_RestAPI_Logger.ErrorConfig loggerConfig = Core_MDF_RestAPI_Logger.getCachedErrorConfigDetails(
                errorCode,
                Core_MDF_Campaign_APIUtil.RESPONSE_CODE_CATEGORY_CAMPAIGN
            );
            if (loggerConfig == null) {
                return null;
            }

            if (String.isBlank(loggerConfig.message) || loggerConfig.httpStatusCode == null) {
                return null;
            }

            CampaignErrorConfig config = new CampaignErrorConfig();
            config.code = String.isBlank(loggerConfig.code) ? errorCode : loggerConfig.code;
            config.message = loggerConfig.message;
            config.httpStatusCode = loggerConfig.httpStatusCode;
            return config;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }

        return null;
    }

    /**
     * Send minimal error response as fallback when sendErrorResponse fails.
     * Ensures a response is always returned even on exception.
     * 
     * @param statusCodeStr HTTP status code as string
     */
    private static void sendMinimalErrorResponse(String statusCodeStr) {
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            response.statusCode = parseStatusCode(statusCodeStr);
            // Minimal response following standard API structure
            Map<String, Object> minimalResponse = new Map<String, Object>();
            minimalResponse.put('isSuccess', false);
            minimalResponse.put('error', new Map<String, String>{
                'code' => statusCodeStr,
                'message' => Core_MDF_Campaign_APIUtil.ERROR_MESSAGE_CONFIG_MISSING
            });
            response.responseBody = Blob.valueOf(JSON.serialize(minimalResponse));
            RestContext.response = response;
        } catch (Exception ex) {
            // Silently fail - unable to send any response
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    /**
     * Parse HTTP status code string to Integer with error handling.
     * Returns 500 if parsing fails.
     * 
     * @param code Status code as string
     * @return Parsed Integer status code, or HTTP_STATUS_500 on error
     */
    
    private static Integer parseStatusCode(String code) {
        try {
            return String.isBlank(code) ? Core_MDF_Campaign_APIUtil.HTTP_STATUS_500 : Integer.valueOf(code);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return Core_MDF_Campaign_APIUtil.HTTP_STATUS_500;
        }
    }

    /**
     * Response tracking wrapper for logging purposes.
     * Tracks status code and success state to be logged in finally block.
     */
    private class CampaignDetailsResponse {
        public String statusCode;
        public Boolean isSuccess;
    }

    /**
     * Campaign details response wrapper with guaranteed field order.
     * Fields must be defined in the desired JSON serialization order:
     * 1. details (campaign record)
    * 2. Campaign Budgets (child records)
    * 3. Campaign Purpose (child records)
     */
    private class CampaignDetailsData {
        public Map<String, Object> details;
        public List<Map<String, Object>> budgets;
        public List<Map<String, Object>> outcomes;
    }

    private class CampaignErrorConfig {
        public String code;
        public String message;
        public Integer httpStatusCode;
    }

    private class FieldDisplayMode {
        public Boolean isValid = true;
        public Boolean useLabels = false;
        public String invalidParameter;
        public String invalidValue;
    }

}