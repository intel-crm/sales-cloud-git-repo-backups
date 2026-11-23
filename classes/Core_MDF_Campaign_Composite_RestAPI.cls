/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Campaign_Composite_RestAPI
 * Author          : <YourName>
 * Created Date    : Jun 25, 2026
 * Description     : Composite Campaign REST endpoint.
 *                   Returns campaign details with sub-object records:
 *                   - Core_MDF_Campaign_Budgets__c
 *                   - Core_MDF_Campaign_Outcomes__c
 * ----------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/v1.0/mdf/campaign-details/*')
global without sharing class Core_MDF_Campaign_Composite_RestAPI {

    private static final String CAMPAIGN_SEGMENT = '/campaign-details/';
    private static final String CAMPAIGN_LOOKUP_FIELD = 'Core_MDF_Campaign_Id__c';
    private static final Integer MAX_CHILD_ROWS = 200;
    private static final Integer MAX_CHILD_QUERY_FIELDS = 80;
    private static final Map<String, List<String>> CHILD_OBJECT_ALLOWED_FIELDS = new Map<String, List<String>>{
        'Core_MDF_Campaign_Budgets__c' => new List<String>{
            'Core_MDF_Budget_Name_Id__c',
            'Name',
            'Core_MDF_Budget_Amt__c',
            'Core_MDF_Reimbursement_Rate_Pct__c',
            'Core_MDF_Reimbursement_Amt__c'
        },
        'Core_MDF_Campaign_Outcomes__c' => new List<String>{
            'Core_MDF_Outcomes_nm__c',
            'Core_MDF_Goal_Quantity_nbr__c',
            'Core_MDF_Quantity_nbr__c',
            'Core_MDF_Outcome_Criteria_txt__c'
        }
    };

    @HttpGet
    global static void getCampaignCompositeDetails() {
        ensureRestResponse();
        Datetime entryTime = System.now();
        Core_MDF_Campaign_APIResponse response;
        List<String> logErrors;

        try {
            String campaignId = extractCampaignIdFromUrl();
            if (String.isBlank(campaignId)) {
                response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
                sendErrorResponse(400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
                return;
            }

            if (!isValidCampaignId(campaignId)) {
                response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
                sendErrorResponse(400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
                return;
            }

            response = getCompositeDetails(campaignId);
            RestContext.response.statusCode = response.isSuccess ? 200 : 500;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response.getSerializedResponse()));
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            sendErrorResponse(500, Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
        } finally {
            Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
            logReq.apiName = 'Core_MDF_Campaign_Composite_RestAPI';
            logReq.apiVersion = 'v1.0';
            logReq.contextMessage = 'GET campaign composite details';
            logReq.responsePayload = response;
            logReq.statusCode = response != null ? response.getCode() : Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR;
            logReq.isSuccess = response != null ? response.isSuccess : false;
            logReq.errors = logErrors;
            logReq.entryTime = entryTime;
            logReq.exitTime = System.now();
            Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
        }
    }

    private static Core_MDF_Campaign_APIResponse getCompositeDetails(String campaignId) {
        try {
            Map<String, Object> campaignData = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
                Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                campaignId,
                Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );

            if (campaignData == null) {
                return createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
            }

            Map<String, Object> details = new Map<String, Object>();
            details.put('campaign', campaignData);
            details.put(getObjectLabel('Core_MDF_Campaign_Budgets__c'), queryRelatedRecords('Core_MDF_Campaign_Budgets__c', campaignId));
            details.put(getObjectLabel('Core_MDF_Campaign_Outcomes__c'), queryRelatedRecords('Core_MDF_Campaign_Outcomes__c', campaignId));

            Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
            response.setSuccessInfo(
                Core_MDF_Campaign_APIConstants.MSG_CAMPAIGN_DETAILS_RETRIEVED,
                Core_MDF_Campaign_APIConstants.SUCCESS_200
            );
            response.details = details;
            return response;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
        }
    }

    private static List<Map<String, Object>> queryRelatedRecords(String objectApiName, String campaignId) {
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
            if (objectType == null) {
                return new List<Map<String, Object>>();
            }

            if (!objectType.getDescribe().isAccessible()) {
                return new List<Map<String, Object>>();
            }

            Map<String, Schema.SObjectField> fields = objectType.getDescribe().fields.getMap();
            if (!fields.containsKey(CAMPAIGN_LOOKUP_FIELD)) {
                return new List<Map<String, Object>>();
            }

            if (!fields.get(CAMPAIGN_LOOKUP_FIELD).getDescribe().isAccessible()) {
                return new List<Map<String, Object>>();
            }

            List<String> queryFields = buildAccessibleFieldList(objectApiName, fields);
            if (queryFields.isEmpty()) {
                queryFields = new List<String>{ 'Id', CAMPAIGN_LOOKUP_FIELD };
            }

            String soql = 'SELECT ' + String.join(queryFields, ',')
                + ' FROM ' + objectApiName
                + ' WHERE ' + CAMPAIGN_LOOKUP_FIELD + ' = \'' + String.escapeSingleQuotes(campaignId) + '\''
                + ' LIMIT ' + String.valueOf(MAX_CHILD_ROWS);

            System.debug('Child Object Query SOQL: ' + soql);

            Map<String, String> fieldLabelByApiName = getFieldLabelMap(fields, queryFields);

            List<SObject> rows;
            try {
                rows = Database.query(soql);
            } catch (Exception queryEx) {
                System.debug('Child query failed, retrying with minimal fields: ' + queryEx.getMessage());
                String fallbackSoql = 'SELECT Id,' + CAMPAIGN_LOOKUP_FIELD
                    + ' FROM ' + objectApiName
                    + ' WHERE ' + CAMPAIGN_LOOKUP_FIELD + ' = \'' + String.escapeSingleQuotes(campaignId) + '\''
                    + ' LIMIT ' + String.valueOf(MAX_CHILD_ROWS);
                rows = Database.query(fallbackSoql);
                queryFields = new List<String>{ 'Id', CAMPAIGN_LOOKUP_FIELD };
                fieldLabelByApiName = getFieldLabelMap(fields, queryFields);
            }

            return toSerializableRows(rows, queryFields, fieldLabelByApiName);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            System.debug('queryRelatedRecords failed: ' + ex.getMessage() + ' | ' + ex.getStackTraceString());
            return new List<Map<String, Object>>();
        }
    }

    private static List<String> buildAccessibleFieldList(String objectApiName, Map<String, Schema.SObjectField> fields) {
        if (CHILD_OBJECT_ALLOWED_FIELDS.containsKey(objectApiName)) {
            List<String> allowedFields = CHILD_OBJECT_ALLOWED_FIELDS.get(objectApiName);
            List<String> selectedFields = new List<String>();
            for (String fieldName : allowedFields) {
                if (fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isAccessible()) {
                    selectedFields.add(fields.get(fieldName).getDescribe().getName());
                }
            }
            return selectedFields;
        }

        Set<String> normalizedFieldSet = new Set<String>();
        List<String> orderedFields = new List<String>();
        List<String> priorityFields = new List<String>{ 'Id', CAMPAIGN_LOOKUP_FIELD, 'Name', 'Title' };

        for (String priorityField : priorityFields) {
            if (fields.containsKey(priorityField) && fields.get(priorityField).getDescribe().isAccessible()) {
                String canonicalName = fields.get(priorityField).getDescribe().getName();
                String key = canonicalName.toLowerCase();
                if (!normalizedFieldSet.contains(key)) {
                    normalizedFieldSet.add(key);
                    orderedFields.add(canonicalName);
                }
            }
        }

        for (String fieldName : fields.keySet()) {
            if (orderedFields.size() >= MAX_CHILD_QUERY_FIELDS) {
                break;
            }

            try {
                Schema.DescribeFieldResult dfr = fields.get(fieldName).getDescribe();
                if (dfr.isAccessible() && !dfr.isCalculated()) {
                    String canonicalName = dfr.getName();
                    String key = canonicalName.toLowerCase();
                    if (!normalizedFieldSet.contains(key)) {
                        normalizedFieldSet.add(key);
                        orderedFields.add(canonicalName);
                    }
                }
            } catch (Exception ex) {
                continue;
            }
        }

        return orderedFields;
    }

    private static Map<String, String> getFieldLabelMap(Map<String, Schema.SObjectField> fields, List<String> queryFields) {
        Map<String, String> fieldLabelByApiName = new Map<String, String>();
        if (fields == null || queryFields == null) {
            return fieldLabelByApiName;
        }

        for (String fieldName : queryFields) {
            if (!fields.containsKey(fieldName)) {
                continue;
            }

            try {
                Schema.DescribeFieldResult dfr = fields.get(fieldName).getDescribe();
                String label = dfr.getLabel();
                fieldLabelByApiName.put(fieldName, String.isBlank(label) ? fieldName : label);
            } catch (Exception ex) {
                fieldLabelByApiName.put(fieldName, fieldName);
            }
        }

        return fieldLabelByApiName;
    }

    private static String getObjectLabel(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return objectApiName;
        }

        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
            if (objectType == null) {
                return objectApiName;
            }

            Schema.DescribeSObjectResult dsr = objectType.getDescribe();
            String pluralLabel = dsr.getLabelPlural();
            if (!String.isBlank(pluralLabel)) {
                return pluralLabel;
            }

            String singularLabel = dsr.getLabel();
            return String.isBlank(singularLabel) ? objectApiName : singularLabel;
        } catch (Exception ex) {
            return objectApiName;
        }
    }

    private static List<Map<String, Object>> toSerializableRows(List<SObject> rows, List<String> queryFields, Map<String, String> fieldLabelByApiName) {
        List<Map<String, Object>> serializedRows = new List<Map<String, Object>>();
        for (SObject row : rows) {
            Map<String, Object> resultRow = new Map<String, Object>();
            if (queryFields != null) {
                for (String fieldName : queryFields) {
                    try {
                        String responseFieldName = fieldLabelByApiName != null && fieldLabelByApiName.containsKey(fieldName)
                            ? fieldLabelByApiName.get(fieldName)
                            : fieldName;
                        resultRow.put(responseFieldName, row.get(fieldName));
                    } catch (Exception ex) {
                        continue;
                    }
                }
            }
            serializedRows.add(resultRow);
        }
        return serializedRows;
    }

    private static Core_MDF_Campaign_APIResponse createErrorResponse(String errorCode) {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setErrorInfo(
            Core_MDF_Campaign_APIConstants.getErrorMessageByCode(errorCode),
            errorCode
        );
        response.details = null;
        return response;
    }

    private static void sendErrorResponse(Integer statusCode, String errorCode) {
        RestContext.response.statusCode = statusCode;
        Core_MDF_Campaign_APIResponse errorResponse = createErrorResponse(errorCode);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse.getSerializedResponse()));
    }

    private static String extractCampaignIdFromUrl() {
        try {
            if (RestContext.request == null || String.isBlank(RestContext.request.requestURI)) {
                return null;
            }

            String requestUri = RestContext.request.requestURI;
            Integer segmentIndex = requestUri.indexOf(CAMPAIGN_SEGMENT);
            if (segmentIndex == -1) {
                return null;
            }

            String campaignIdPart = requestUri.substring(segmentIndex + CAMPAIGN_SEGMENT.length());
            Integer queryIndex = campaignIdPart.indexOf('?');
            if (queryIndex != -1) {
                campaignIdPart = campaignIdPart.substring(0, queryIndex);
            }

            campaignIdPart = campaignIdPart.trim();
            return String.isBlank(campaignIdPart) ? null : campaignIdPart;
        } catch (Exception ex) {
            return null;
        }
    }

    private static Boolean isValidCampaignId(String campaignId) {
        if (String.isBlank(campaignId)) {
            return false;
        }

        String normalizedCampaignId = campaignId.trim();
        Integer idLength = normalizedCampaignId.length();
        if (idLength != 15 && idLength != 18) {
            return false;
        }

        if (!Pattern.matches('^[a-zA-Z0-9]+$', normalizedCampaignId)) {
            return false;
        }

        try {
            Id typedId = Id.valueOf(normalizedCampaignId);
            String idString = String.valueOf(typedId);

            Boolean hasCampaignPrefix = idString.startsWith(Core_MDF_Campaign_APIConstants.CAMPAIGN_KEY_PREFIX);
            Boolean isCampaignObjectType = typedId.getSObjectType() == Campaign.SObjectType;

            return hasCampaignPrefix && isCampaignObjectType;
        } catch (Exception ex) {
            return false;
        }
    }

    private static void ensureRestResponse() {
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
    }
}