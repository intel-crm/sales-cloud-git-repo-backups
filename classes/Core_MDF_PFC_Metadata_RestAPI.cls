/* ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_PFC_Metadata_RestAPI
 * Description     : REST API endpoint for returning PartnerFundClaim metadata required for claim creation
 * ---------------------------------------------------------------------------------- */
@RestResource(urlMapping='/v1.0/partnercenter/claimmetadata/*')
global without sharing class Core_MDF_PFC_Metadata_RestAPI {

    private static final Map<String, List<ClaimFieldConfig>> CLAIM_FIELD_CONFIG_CACHE = new Map<String, List<ClaimFieldConfig>>();
    private static final Map<String, String> SECTION_SAMPLE_PAYLOAD_CACHE = new Map<String, String>();
    private static final Map<String, Schema.DescribeFieldResult> PFC_FIELD_DESCRIBE_CACHE = new Map<String, Schema.DescribeFieldResult>();
    
    @HttpGet
    global static void getFieldMetadata() {
        Datetime entryTime = System.now();
        Core_MDF_APIResponse apiResponse;
        List<String> logErrors;
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            response.addHeader('Content-Type', 'application/json');
            apiResponse = processMetadataRequest(response);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR, null, buildErrorDetails(null));
        } finally {
            logApiRequest(apiResponse, logErrors, entryTime);
        }
    }

    private static Core_MDF_APIResponse processMetadataRequest(RestResponse response) {
        Core_MDF_APIResponse apiResponse;
            String clmType = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_TYPE);
            String actIdOrNum = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER);
            String escId = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID);
            String progNm = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME);
            String claimId = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_ID);
            String claimStatus = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_STATUS);
            String action = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTION);

            // Check if no parameters provided at all
            if (String.isBlank(clmType) && String.isBlank(actIdOrNum) && String.isBlank(escId) && String.isBlank(progNm) && String.isBlank(claimId) && String.isBlank(claimStatus) && String.isBlank(action)) {
                apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS, null, buildErrorDetails(null));
                return apiResponse;
            }
            // Validate parameters based on claimType
            String validationError = validateRequestParams(clmType, actIdOrNum, escId, progNm, claimId, claimStatus, action);
            if (String.isNotBlank(validationError)) {
                if (Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_ACTIVITY == validationError) {
                    apiResponse = buildErrorRes(validationError, null, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER));
                } else if (Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_ESCALATION == validationError) {
                    apiResponse = buildErrorRes(validationError, null, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID));
                } else if (Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_INVALID_CLAIM_TYPE == validationError) {
                    apiResponse = buildErrorRes(validationError, null, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_TYPE));
                } else {
                    apiResponse = buildErrorRes(validationError, null, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTION));
                }
                return apiResponse;
            }
            Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams resolveParams = new Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams();
            resolveParams.clmType = clmType;
            setActivityIdOrNum(resolveParams, actIdOrNum);
            resolveParams.escId = escId;
            resolveParams.progNm = progNm;
            resolveParams.action = action;
            Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(resolveParams);
            ctx.clmType = clmType;

            String requestedEditStatus;
            if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(action) && String.isNotBlank(claimId)) {
                ClaimUpdateContext claimContext = resolveClaimUpdateContext(claimId);
                if (claimContext == null) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_INVALID_CLAIM_ID, claimId, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_ID));
                    return apiResponse;
                }
                requestedEditStatus = claimContext.status;
                ctx = claimContext.activityContext;
            } else if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(action) && String.isNotBlank(claimStatus)) {
                requestedEditStatus = claimStatus;
            }

            if (!ctx.recFound) {
                if ('ESCALATION_NOT_FOUND'.equals(ctx.resolutionError)) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_ESCALATION_NF, escId, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID));
                    return apiResponse;
                } else if ('ACTIVITY_NOT_FOUND'.equals(ctx.resolutionError)) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_ACTIVITY_NF, actIdOrNum, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER));
                    return apiResponse;
                } else if (!ctx.progEligible) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_INVALID_PROG, progNm, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME));
                    return apiResponse;
                }
            }

            Boolean programOnlyRequest = String.isBlank(actIdOrNum) && String.isBlank(escId) && String.isBlank(claimId);
            if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(action)) {
                List<UpdateFieldMetadata> respFields = buildUpdateFldsFromClaimConfig(ctx.progNm, action, ctx.budgetType, programOnlyRequest);
                if (String.isNotBlank(requestedEditStatus)) {
                    respFields = filterEditableUpdateFields(respFields, requestedEditStatus);
                    if (respFields.isEmpty()) {
                        apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_CLAIM_NOT_EDITABLE, requestedEditStatus, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_STATUS));
                        return apiResponse;
                    }
                }
                for (UpdateFieldMetadata field : respFields) {
                    if (field != null) {
                        field.allowedValues = String.isNotBlank(claimStatus) && String.isBlank(claimId)
                            ? toPicklistVal(Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues(field.fieldAPIName)) 
                            : getAllowedValues(field.fieldAPIName, ctx);
                    }
                }
                Boolean includeEditableFor = String.isNotBlank(progNm) && String.isBlank(claimId) && String.isBlank(claimStatus);
                apiResponse = buildUpdateSuccessRes(respFields, ctx, action, includeEditableFor, claimId, requestedEditStatus);
            } else {
                List<FieldMetadata> respFields = buildFldsFromClaimConfig(ctx.progNm, action, ctx.budgetType, programOnlyRequest);
                for (FieldMetadata field : respFields) {
                    if (field != null) {
                        field.allowedValues = getAllowedValues(field.fieldAPIName, ctx);
                    }
                }
                respFields = normalizeResponseFields(respFields);
                String samplePayloadJson = getSectionSamplePayload(ctx.progNm, action, ctx.budgetType, programOnlyRequest);
                apiResponse = buildSuccessRes(respFields, ctx, samplePayloadJson);
            }
            setResponseBody(response, apiResponse, String.isNotBlank(progNm));
            RestContext.response = response;
            return apiResponse;
    }

/**************************************************************
* Method Name: validateRequestParams
* Parameters: String clmType, String actIdOrNum, String escId, String progNm, String action
* Description: Validates request parameters and returns error code if validation fails, else null.
**************************************************************/
    private static String validateRequestParams(String clmType, String actIdOrNum, String escId, String progNm, String claimId, String claimStatus, String action) {
        Set<String> allowedParams = new Set<String>{Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTION};
        if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_CREATE.equalsIgnoreCase(action)) {
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER);
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_TYPE);
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID);
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME);
        } else if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(action)) {
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME);
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_ID);
            allowedParams.add(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_STATUS);
        }
        if (RestContext.request != null && RestContext.request.params != null) {
            for (String key : RestContext.request.params.keySet()) {
                if (String.isNotBlank(key)) {
                    Boolean allowed = false;
                    for (String paramName : allowedParams) {
                        if (paramName.equalsIgnoreCase(key.trim())) {
                            allowed = true;
                            break;
                        }
                    }
                    if (!allowed) {
                        return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS; 
                    }
                }
            }
        }
        if (String.isBlank(action) || String.isBlank(resolveFieldViewForAction(action))) {
            return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS;
        }
        // If claimType is provided, validate based on type
        if (String.isNotBlank(clmType)) {
            if (Core_MDF_PFC_Metadata_RestAPIUtility.CLAIM_TYPE_LATE_CLAIM.equalsIgnoreCase(clmType)) {
                if (String.isBlank(escId)) { 
                    return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_ESCALATION; 
                }
            } else if (Core_MDF_PFC_Metadata_RestAPIUtility.CLAIM_TYPE_NORMAL.equalsIgnoreCase(clmType)){
                if (String.isBlank(actIdOrNum)) { 
                    return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_ACTIVITY; 
                }
            } else{
                return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_INVALID_CLAIM_TYPE;
            }
        } else {
            if (String.isBlank(actIdOrNum) && String.isBlank(escId) && String.isBlank(progNm) && String.isBlank(claimId) && String.isBlank(claimStatus)) {
                return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS;
            }
        }
        return null;
    }
    
    private static String resolveFieldViewForAction(String action) {
        if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_CREATE.equalsIgnoreCase(action)) {
            return Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_VIEW_API_CREATE;
        }
        if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(action)) {
            return Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_VIEW_API_UPDATE;
        }
        return null;
    }

    /**************************************************************
* Method Name: setActivityIdOrNum
* Parameters: Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams resolveParams, String actIdOrNum
* Description: Maps activityIdOrNumber to activityId when format/prefix is Salesforce activity ID; otherwise maps to activityNumber.
**************************************************************/
    private static void setActivityIdOrNum(Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams resolveParams, String actIdOrNum) {
        if (resolveParams == null || String.isBlank(actIdOrNum)) { return; }
        String candidate = actIdOrNum.trim();
        if (candidate.length() == 15 || candidate.length() == 18) {
            if (Pattern.matches('^[a-zA-Z0-9]+$', candidate) && candidate.toUpperCase().startsWith('0RJ')) {
                resolveParams.actId = candidate;
                return;
            }
        }
        resolveParams.actNum = candidate;
    }

    /**************************************************************
* Method Name: buildErrorDetails
* Parameters: String parameterName
* Description: Builds a standardized error details object with supportedParameters and request parameter context.
**************************************************************/
    private static Map<String, Object> buildErrorDetails(String parameterName) {
        return new Map<String, Object>{
            'supportedParameters' => Core_MDF_PFC_Metadata_RestAPIUtility.VALID_PARAMS,
            'parameter' => parameterName,
            'fields' => new List<FieldMetadata>(),
            'totalFields' => 0,
            'objectAPIName' => Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME
        };
    }

    /**************************************************************
* Method Name: buildFldDefFromObj
* Parameters: FieldDefinitionSpec spec
* Description: Builds a FieldMetadata instance from a PartnerFundClaim field describe result.
**************************************************************/
    private static FieldMetadata buildFldDefFromObj(FieldDefinitionSpec spec) {
        if (spec == null || String.isBlank(spec.fieldAPIName)) {
            return null;
        }
        Schema.DescribeFieldResult fldDesc = getPfcFldDesc(spec.fieldAPIName);
        if (fldDesc == null) {
            return null;
        }

        String fieldLabel = fldDesc.getLabel();
        String fieldType = String.isBlank(Core_MDF_PFC_Metadata_RestAPIUtility.FLD_TYPE_MAP.get(fldDesc.getType())) ? 'Text' : Core_MDF_PFC_Metadata_RestAPIUtility.FLD_TYPE_MAP.get(fldDesc.getType());
        Boolean isRequired = !fldDesc.isNillable() && !fldDesc.isDefaultedOnCreate();
        String description = fldDesc.getInlineHelpText();
        String defaultValue = getFldDefaultVal(fldDesc);
        String parentObject = spec.parentObject;
        String parentField = spec.parentField;
        if (fldDesc.getType() == Schema.DisplayType.REFERENCE) {
            List<Schema.SObjectType> referenceTypes = fldDesc.getReferenceTo();
            if (String.isBlank(parentObject) && referenceTypes != null && !referenceTypes.isEmpty()) {
                parentObject = referenceTypes[0].getDescribe().getName();
            }
            if (String.isBlank(parentField)) { parentField = 'Id'; }
        }
        FieldMetadata fm = new FieldMetadata();
        fm.fieldLabel = fldDesc.getLabel();
        fm.fieldAPIName = spec.fieldAPIName;
        fm.fieldType = fieldType;
        fm.isRequired = isRequired;
        fm.allowedValues = null;
        fm.parentObject = parentObject;
        fm.parentField = parentField;
        fm.description = description;
        fm.defaultValue = defaultValue;
        return fm;
    }

/**************************************************************
* Method Name: getPfcFldDesc
* Parameters: String fldApi
* Description: Returns the DescribeFieldResult for a PartnerFundClaim field; null if the field is not in the describe map.
**************************************************************/
    private static Schema.DescribeFieldResult getPfcFldDesc(String fldApi) {
        if (String.isBlank(fldApi)) { return null; }
        if (PFC_FIELD_DESCRIBE_CACHE.containsKey(fldApi)) {
            return PFC_FIELD_DESCRIBE_CACHE.get(fldApi);
        }
        try {
            if (!Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_FIELDS.containsKey(fldApi)) { 
                PFC_FIELD_DESCRIBE_CACHE.put(fldApi, null);
                return null; 
            }
            Schema.DescribeFieldResult fieldDescribe = Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_FIELDS.get(fldApi).getDescribe();
            PFC_FIELD_DESCRIBE_CACHE.put(fldApi, fieldDescribe);
            return fieldDescribe;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            PFC_FIELD_DESCRIBE_CACHE.put(fldApi, null);
            return null;
        }
    }

    private static String getFldDefaultVal(Schema.DescribeFieldResult fldDesc) {
        try {
            Object defaultVal = fldDesc.getDefaultValue();
            if (defaultVal != null) { 
                return String.valueOf(defaultVal); 
            }
            String defaultFormula = fldDesc.getDefaultValueFormula();
            if (String.isNotBlank(defaultFormula)) { 
                return defaultFormula; 
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return null;
    }

    private static String getQueryParam(String key) {
        if (String.isBlank(key) || RestContext.request == null || RestContext.request.params == null) {
            return null;
        }
        Map<String, String> params = RestContext.request.params;
        for (String paramKey : params.keySet()) {
            if (String.isNotBlank(paramKey) && key.equalsIgnoreCase(paramKey.trim())) {
                String paramValue = params.get(paramKey);
                return String.isBlank(paramValue) ? null : paramValue.trim();
            }
        }
        return null;
    }
/**************************************************************
* Method Name: getAllowedValues
* Parameters: String fldApi, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx
* Description: Returns context-scoped allowed values for a field.
**************************************************************/
    private static List<PicklistValue> getAllowedValues(String fldApi, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx) {
        if (String.isBlank(fldApi)) { 
            return new List<PicklistValue>(); 
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_ACTIVITY_REQUEST_LOOKUP && String.isNotBlank(ctx.actNum)) {
            PicklistValue pv = new PicklistValue();
            pv.label = ctx.actNum;
            pv.value = ctx.actNum;
            return normalizePicklistVal(new List<PicklistValue>{ pv }, fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_ESCALATION_ID && String.isNotBlank(ctx.escId)) {
            PicklistValue pv = new PicklistValue();
            pv.label = ctx.escId;
            pv.value = ctx.escId;
            return normalizePicklistVal(new List<PicklistValue>{ pv }, fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_SUBMITTER) {
            return normalizePicklistVal(toPicklistVal(ctx.clmSubmitters), fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_BANK_LOOKUP) {
            return normalizePicklistVal(toPicklistVal(ctx.bankSupNum), fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_COUNTRY && !ctx.clmCountry.isEmpty()) {
            return normalizePicklistVal(toPicklistVal(ctx.clmCountry), fldApi);
        }
        return normalizePicklistVal(toPicklistVal(Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues(fldApi)), fldApi);
    }

/**************************************************************
* Method Name: toPicklistVal
* Parameters: List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> source
* Description: Converts LabelValue entries from the service into PicklistValue instances for the response.
**************************************************************/
    private static List<PicklistValue> toPicklistVal(List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> source) {
        List<PicklistValue> result = new List<PicklistValue>();
        if (source == null) { 
            return result; 
        }
        for (Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue lv : source) {
            if (lv != null) { 
                PicklistValue pv = new PicklistValue();
                pv.label = lv.label;
                pv.value = lv.value;
                result.add(pv);
            }
        }
        return result;
    }

    /**************************************************************
* Method Name: getClaimFieldConfigs
* Parameters: String progNm, String action
* Description: Queries Core_MDF_Custom_Layout_Configurations__c for the claim fields configured for a program, in sequence order. Cached per program for the transaction.
**************************************************************/
    private static List<ClaimFieldConfig> getClaimFieldConfigs(String progNm, String action, String budgetType, Boolean includeAllBudgetTypes) {
        String cacheKey = String.isBlank(progNm) ? '' : progNm.trim();
        String fieldView = resolveFieldViewForAction(action);
        cacheKey += ':' + (String.isBlank(fieldView) ? '' : fieldView);
        cacheKey += ':' + (includeAllBudgetTypes == true ? '*' : (String.isBlank(budgetType) ? '' : budgetType.trim()));
        if (CLAIM_FIELD_CONFIG_CACHE.containsKey(cacheKey)) {
            return CLAIM_FIELD_CONFIG_CACHE.get(cacheKey);
        }
        List<ClaimFieldConfig> configs = new List<ClaimFieldConfig>();
        String samplePayloadJson;
        if (String.isNotBlank(progNm) && String.isNotBlank(fieldView)) {
            try {
                for (Core_MDF_Custom_Layout_Configurations__c record : [SELECT Core_MDF_Field_Label_txt__c, Core_MDF_Field_API_Name_txt__c, Core_MDF_API_Required_Ind__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Field_Editability_Rules__c, Core_MDF_Section_id__r.Core_MDF_External_API_Sample_Payload_txt__c FROM Core_MDF_Custom_Layout_Configurations__c
                    WHERE Core_MDF_Object_API_Name_txt__c = :Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME AND Core_MDF_User_Type_nm__c = :Core_MDF_PFC_Metadata_RestAPIUtility.CONFIG_USER_TYPE AND Core_MDF_Record_Type_Name_txt__c = :progNm AND API_Visibility__c = true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView
                    ORDER BY Core_MDF_Sequence_No_nbr__c NULLS LAST, Core_MDF_Field_Label_txt__c]) {
                    if (String.isBlank(samplePayloadJson) && String.isNotBlank(record.Core_MDF_Section_id__r.Core_MDF_External_API_Sample_Payload_txt__c)) {
                        samplePayloadJson = record.Core_MDF_Section_id__r.Core_MDF_External_API_Sample_Payload_txt__c;
                    }
                    if (String.isBlank(record.Core_MDF_Field_Label_txt__c) || String.isBlank(record.Core_MDF_Field_API_Name_txt__c)) {
                        continue;
                    }
                    ClaimFieldConfig cfg = new ClaimFieldConfig();
                    cfg.payloadFieldName = record.Core_MDF_Field_Label_txt__c.trim();
                    cfg.fieldApiName = record.Core_MDF_Field_API_Name_txt__c.trim();
                    cfg.isRequired = record.Core_MDF_API_Required_Ind__c == true;
                    cfg.budgetType = String.isBlank(record.Core_MDF_Budget_Type_nm__c) ? null : record.Core_MDF_Budget_Type_nm__c.trim();
                    cfg.editabilityRulesJson = (String) record.Core_MDF_Field_Editability_Rules__c;
                    if (includeAllBudgetTypes == true) {
                        configs.add(cfg);
                    } else if (String.isBlank(cfg.budgetType) || cfg.budgetType.equalsIgnoreCase(budgetType)) {
                        configs.add(cfg);
                    }
                }
            } catch (Exception ex) {
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
        }
        CLAIM_FIELD_CONFIG_CACHE.put(cacheKey, configs);
        SECTION_SAMPLE_PAYLOAD_CACHE.put(cacheKey, samplePayloadJson);
        return configs;
    }

/**************************************************************
* Method Name: getSectionSamplePayload
* Parameters: String progNm, String action, String budgetType, Boolean includeAllBudgetTypes
* Description: Returns the raw Core_MDF_External_API_Sample_Payload_txt__c JSON configured on the section for this program/action, populating the config cache first if needed.
**************************************************************/
    private static String getSectionSamplePayload(String progNm, String action, String budgetType, Boolean includeAllBudgetTypes) {
        String cacheKey = String.isBlank(progNm) ? '' : progNm.trim();
        String fieldView = resolveFieldViewForAction(action);
        cacheKey += ':' + (String.isBlank(fieldView) ? '' : fieldView);
        cacheKey += ':' + (includeAllBudgetTypes == true ? '*' : (String.isBlank(budgetType) ? '' : budgetType.trim()));
        if (!SECTION_SAMPLE_PAYLOAD_CACHE.containsKey(cacheKey)) {
            getClaimFieldConfigs(progNm, action, budgetType, includeAllBudgetTypes);
        }
        return SECTION_SAMPLE_PAYLOAD_CACHE.get(cacheKey);
    }
    /**************************************************************
* Method Name: buildFldsFromClaimConfig
* Parameters: String progNm, String action
* Description: Builds FieldMetadata from Core_MDF_Custom_Layout_Configurations__c; isRequired comes from the layout configuration.
**************************************************************/
    private static List<FieldMetadata> buildFldsFromClaimConfig(String progNm, String action, String budgetType, Boolean includeAllBudgetTypes) {
        List<FieldMetadata> fields = new List<FieldMetadata>();
        if (String.isBlank(progNm)) { return fields; }
        try {
            Map<String, ClaimFieldConfig> selectedConfigs = new Map<String, ClaimFieldConfig>();
            Map<String, FieldMetadata> fieldsByApiName = new Map<String, FieldMetadata>();
            for (ClaimFieldConfig cfg : getClaimFieldConfigs(progNm, action, budgetType, includeAllBudgetTypes)) {
                if (cfg == null || String.isBlank(cfg.fieldApiName) || Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_DOCUMENTS.equalsIgnoreCase(cfg.payloadFieldName)) {
                    continue;
                }
                String fieldKey = cfg.fieldApiName.toLowerCase();
                if (includeAllBudgetTypes == true) {
                    FieldMetadata existingField = fieldsByApiName.get(fieldKey);
                    if (existingField == null) {
                        FieldDefinitionSpec spec = cfg.fieldApiName.equalsIgnoreCase(Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_ACTIVITY_REQUEST_LOOKUP) ? new FieldDefinitionSpec(cfg.fieldApiName, 'PartnerFundRequest', 'Core_MDF_Activity_Number__c') : new FieldDefinitionSpec(cfg.fieldApiName);
                        existingField = buildFldDefFromObj(spec);
                        if (existingField == null) {
                            continue;
                        }
                        existingField.isRequired = cfg.isRequired == true;
                        existingField.applicableBudgetTypes = new List<String>();
                        fieldsByApiName.put(fieldKey, existingField);
                    } else {
                        existingField.isRequired = existingField.isRequired == true || cfg.isRequired == true;
                    }
                    if (String.isBlank(cfg.budgetType)) {
                        existingField.unrestrictedBudgetType = true;
                        existingField.applicableBudgetTypes.clear();
                    } else if (existingField.unrestrictedBudgetType != true && existingField.applicableBudgetTypes != null && !existingField.applicableBudgetTypes.contains(cfg.budgetType)) {
                        existingField.applicableBudgetTypes.add(cfg.budgetType);
                    }
                } else {
                    ClaimFieldConfig existing = selectedConfigs.get(fieldKey);
                    if (existing == null || (String.isBlank(existing.budgetType) && String.isNotBlank(cfg.budgetType))) {
                        selectedConfigs.put(fieldKey, cfg);
                    }
                }
            }
            fields.addAll(fieldsByApiName.values());
            for (ClaimFieldConfig cfg : selectedConfigs.values()) {
                FieldDefinitionSpec spec = cfg.fieldApiName.equalsIgnoreCase(Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_ACTIVITY_REQUEST_LOOKUP) ? new FieldDefinitionSpec(cfg.fieldApiName, 'PartnerFundRequest', 'Core_MDF_Activity_Number__c') : new FieldDefinitionSpec(cfg.fieldApiName);
                FieldMetadata meta = buildFldDefFromObj(spec);
                if (meta == null) {
                    continue;
                }
                meta.isRequired = cfg.isRequired == true;
                meta.budgetType = cfg.budgetType;
                fields.add(meta);
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return fields;
    }

    private static List<UpdateFieldMetadata> buildUpdateFldsFromClaimConfig(String progNm, String action, String budgetType, Boolean includeAllBudgetTypes) {
        List<UpdateFieldMetadata> fields = new List<UpdateFieldMetadata>();
        if (String.isBlank(progNm)) {
            return fields;
        }
        try {
            Map<String, UpdateFieldMetadata> fieldsByApiName = new Map<String, UpdateFieldMetadata>();
            Map<String, ClaimFieldConfig> selectedConfigs = new Map<String, ClaimFieldConfig>();
            for (ClaimFieldConfig cfg : getClaimFieldConfigs(progNm, action, budgetType, includeAllBudgetTypes)) {
                if (cfg == null || String.isBlank(cfg.fieldApiName) || Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_DOCUMENTS.equalsIgnoreCase(cfg.payloadFieldName)) {
                    continue;
                }
                String fieldKey = cfg.fieldApiName.toLowerCase();
                if (includeAllBudgetTypes == true) {
                    UpdateFieldMetadata field = fieldsByApiName.get(fieldKey);
                    if (field == null) {
                        field = buildUpdateFieldMetadata(cfg);
                        if (field == null) {
                            continue;
                        }
                        field.applicableBudgetTypes = new List<String>();
                        fieldsByApiName.put(fieldKey, field);
                    }
                    field.isRequired = field.isRequired == true || cfg.isRequired == true;
                    if (String.isBlank(cfg.budgetType)) {
                        field.unrestrictedBudgetType = true;
                        field.applicableBudgetTypes.clear();
                    } else if (field.unrestrictedBudgetType != true && !field.applicableBudgetTypes.contains(cfg.budgetType)) {
                        field.applicableBudgetTypes.add(cfg.budgetType);
                    }
                    field.editabilityRulesJson = mergeEditabilityRulesJson(field.editabilityRulesJson, cfg.editabilityRulesJson);
                } else {
                    ClaimFieldConfig existing = selectedConfigs.get(fieldKey);
                    if (existing == null || (String.isBlank(existing.budgetType) && String.isNotBlank(cfg.budgetType))) {
                        selectedConfigs.put(fieldKey, cfg);
                    }
                }
            }
            fields.addAll(fieldsByApiName.values());
            for (ClaimFieldConfig cfg : selectedConfigs.values()) {
                UpdateFieldMetadata field = buildUpdateFieldMetadata(cfg);
                if (field != null) {
                    fields.add(field);
                }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return fields;
    }

    private static ClaimUpdateContext resolveClaimUpdateContext(String claimId) {
        if (String.isBlank(claimId)) {
            return null;
        }
        try {
            Id pfcId = Id.valueOf(claimId.trim());
            List<PartnerFundClaim> claims = [SELECT Id, Core_MDF_Status__c, Core_MDF_Program__c, RequestId FROM PartnerFundClaim WHERE Id = :pfcId LIMIT 1];
            if (claims.isEmpty()) {
                return null;
            }
            PartnerFundClaim claim = claims[0];
            Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams params = new Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams();
            params.action = Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE;
            if (claim.RequestId != null) {
                params.actId = String.valueOf(claim.RequestId);
            } else {
                params.progNm = claim.Core_MDF_Program__c;
            }
            Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(params);
            if (!ctx.recFound && String.isNotBlank(claim.Core_MDF_Program__c)) {
                params.actId = null;
                params.progNm = claim.Core_MDF_Program__c;
                ctx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(params);
            }
            if (!ctx.recFound || String.isBlank(ctx.progNm)) {
                return null;
            }
            ClaimUpdateContext result = new ClaimUpdateContext();
            result.status = claim.Core_MDF_Status__c;
            result.activityContext = ctx;
            return result;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    private static List<UpdateFieldMetadata> filterEditableUpdateFields(List<UpdateFieldMetadata> fields, String claimStatus) {
        List<UpdateFieldMetadata> editableFields = new List<UpdateFieldMetadata>();
        if (fields == null || String.isBlank(claimStatus)) {
            return editableFields;
        }
        for (UpdateFieldMetadata field : fields) {
            if (field != null && isEditableForStatus(field.editabilityRulesJson, claimStatus)) {
                editableFields.add(field);
            }
        }
        return editableFields;
    }

    private static Boolean isEditableForStatus(String rulesJson, String claimStatus) {
        if (String.isBlank(rulesJson) || String.isBlank(claimStatus)) {
            return false;
        }
        for (EditabilityRule rule : deserializeEditabilityRules(rulesJson)) {
            if (rule == null || rule.statuses == null) {
                continue;
            }
            for (String status : rule.statuses) {
                if (String.isNotBlank(status) && status.trim().equalsIgnoreCase(claimStatus.trim())) {
                    return true;
                }
            }
        }
        return false;
    }

    private static String mergeEditabilityRulesJson(String existingRulesJson, String additionalRulesJson) {
        List<EditabilityRule> mergedRules = deserializeEditabilityRules(existingRulesJson);
        mergedRules.addAll(deserializeEditabilityRules(additionalRulesJson));
        List<Object> serializedRules = new List<Object>();
        Set<String> seenRuleKeys = new Set<String>();
        for (EditabilityRule rule : mergedRules) {
            if (rule != null && rule.statuses != null && !rule.statuses.isEmpty()) {
                List<String> normalizedStatuses = new List<String>();
                for (String status : rule.statuses) {
                    if (String.isNotBlank(status)) {
                        normalizedStatuses.add(status.trim().toLowerCase());
                    }
                }
                normalizedStatuses.sort();
                String ruleKey = String.join(normalizedStatuses, '|');
                if (normalizedStatuses.isEmpty() || seenRuleKeys.contains(ruleKey)) {
                    continue;
                }
                seenRuleKeys.add(ruleKey);
                serializedRules.add(new Map<String, Object>{'statuses' => rule.statuses});
            }
        }
        return JSON.serialize(serializedRules);
    }

    private static UpdateFieldMetadata buildUpdateFieldMetadata(ClaimFieldConfig cfg) {
        FieldDefinitionSpec spec = cfg.fieldApiName.equalsIgnoreCase(Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_ACTIVITY_REQUEST_LOOKUP)
            ? new FieldDefinitionSpec(cfg.fieldApiName, 'PartnerFundRequest', 'Core_MDF_Activity_Number__c')
            : new FieldDefinitionSpec(cfg.fieldApiName);
        FieldMetadata metadata = buildFldDefFromObj(spec);
        if (metadata == null) {
            return null;
        }
        UpdateFieldMetadata field = new UpdateFieldMetadata();
        field.fieldLabel = metadata.fieldLabel;
        field.fieldAPIName = metadata.fieldAPIName;
        field.fieldType = metadata.fieldType;
        field.isRequired = cfg.isRequired == true;
        field.parentObject = metadata.parentObject;
        field.parentField = metadata.parentField;
        field.description = metadata.description;
        field.defaultValue = metadata.defaultValue;
        field.editabilityRulesJson = cfg.editabilityRulesJson;
        return field;
    }

    private static List<EditabilityRule> deserializeEditabilityRules(String rulesJson) {
        List<EditabilityRule> rules = new List<EditabilityRule>();
        if (String.isBlank(rulesJson)) {
            return rules;
        }
        try {
            Object rawRules = JSON.deserializeUntyped(rulesJson);
            if (!(rawRules instanceof List<Object>)) {
                return rules;
            }
            for (Object rawRule : (List<Object>) rawRules) {
                if (!(rawRule instanceof Map<String, Object>)) {
                    continue;
                }
                Map<String, Object> ruleMap = (Map<String, Object>) rawRule;
                EditabilityRule rule = new EditabilityRule();
                rule.statuses = new List<String>();
                Object rawStatuses = ruleMap.get('statuses');
                if (rawStatuses instanceof List<Object>) {
                    for (Object status : (List<Object>) rawStatuses) {
                        if (status != null) {
                            rule.statuses.add(String.valueOf(status));
                        }
                    }
                }
                rules.add(rule);
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return rules;
    }

    private static List<FieldMetadata> normalizeResponseFields(List<FieldMetadata> fields) {
        List<FieldMetadata> normalizedFields = new List<FieldMetadata>();
        if (fields == null) {
            return normalizedFields;
        }
        Set<String> seenFieldApiNames = new Set<String>();
        for (FieldMetadata field : fields) {
            if (field == null || String.isBlank(field.fieldAPIName)) {
                continue;
            }
            String fieldKey = field.fieldAPIName.trim().toLowerCase();
            fieldKey += ':' + (String.isBlank(field.budgetType) ? '' : field.budgetType.trim().toLowerCase());
            if (seenFieldApiNames.contains(fieldKey)) {
                continue;
            }
            seenFieldApiNames.add(fieldKey);
            field.allowedValues = normalizePicklistVal(field.allowedValues, field.fieldAPIName);
            normalizedFields.add(field);
        }
        return normalizedFields;
    }

    private static List<PicklistValue> normalizePicklistVal(List<PicklistValue> source, String fldApi) {
        List<PicklistValue> normalizedValues = new List<PicklistValue>();
        if (source == null) {
            return normalizedValues;
        }
        Set<String> seenKeys = new Set<String>();
        for (PicklistValue item : source) {
            if (item == null) {
                continue;
            }
            String normalizedVal = String.isBlank(item.value) ? null : item.value.trim();
            String normalizedLbl = String.isBlank(item.label) ? normalizedVal : item.label.trim();
            if (String.isBlank(normalizedVal) && String.isBlank(normalizedLbl)) {
                continue;
            }
            String dedupeKey = buildPicklistDedupeKey(normalizedVal, normalizedLbl, fldApi);
            if (seenKeys.contains(dedupeKey)) {
                continue;
            }
            seenKeys.add(dedupeKey);
            PicklistValue normalizedItem = new PicklistValue();
            normalizedItem.value = normalizedVal;
            normalizedItem.label = normalizedLbl;
            normalizedValues.add(normalizedItem);
        }
        return normalizedValues;
    }

    private static String buildPicklistDedupeKey(String value, String label, String fldApi) {
        String baseValue = !String.isBlank(value) ? value : label;
        if (String.isBlank(baseValue)) {
            return '';
        }
        String normalized = baseValue.trim().toLowerCase();
        if (Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_BANK_LOOKUP == fldApi && String.isNotBlank(label)) {
            normalized += ':' + label.trim().toLowerCase();
        }
        return normalized;
    }

/**************************************************************
* Method Name: buildSuccessRes
* Parameters: List<FieldMetadata> fields, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx, String samplePayloadJson
* Description: Builds the success response details, including the flat fields list and sample claim payload.
**************************************************************/
    private static Core_MDF_APIResponse buildSuccessRes(List<FieldMetadata> fields, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx, String samplePayloadJson) {
        Core_MDF_APIResponse response = new Core_MDF_APIResponse();
        response.setSuccessInfo(Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_MESSAGE, Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_CODE);
        Map<String, Object> details = new Map<String, Object>{ 'objectAPIName' => Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME };

        details.put('totalFields', fields == null ? 0 : fields.size());
        details.put('fields', fields == null ? new List<FieldMetadata>() : fields);
        
	details.put('sampleClaimPayload', parseConfiguredSamplePayload(samplePayloadJson));
        
        if (String.isNotBlank(ctx.progNm))  { details.put('programName',    ctx.progNm); }
        if (String.isNotBlank(ctx.clmType)) { details.put('claimType',      ctx.clmType); }
        if (String.isBlank(ctx.escId)) {
            if (ctx.actIdInput && String.isNotBlank(ctx.actId)) {
                details.put('activityIdOrNumber', ctx.actId);
            } else if (String.isNotBlank(ctx.actNum)) {
                details.put('activityIdOrNumber', ctx.actNum);
            } else if (String.isNotBlank(ctx.actId)) {
                details.put('activityIdOrNumber', ctx.actId);
            }
        }
        if (String.isNotBlank(ctx.escId))   { details.put('escalationId',   ctx.escId); }
        details.put('businessRules:', getClaimCreationRules());
        response.details = details;
        return response;
    }

    private static Core_MDF_APIResponse buildUpdateSuccessRes(List<UpdateFieldMetadata> fields, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx, String action, Boolean includeEditableFor, String claimId, String claimStatus) {
        Core_MDF_APIResponse response = new Core_MDF_APIResponse();
        response.setSuccessInfo(Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_MESSAGE, Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_CODE);
        Map<String, Object> details = new Map<String, Object>{
            'objectAPIName' => Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME,
            'totalFields' => fields == null ? 0 : fields.size(),
            'fields' => fields == null ? new List<UpdateFieldMetadata>() : fields,
            'action' => action,
            'includeEditableFor' => includeEditableFor
        };
        if (String.isNotBlank(ctx.progNm)) {
            details.put('programName', ctx.progNm);
        }
        if (String.isNotBlank(ctx.clmType)) {
            details.put('claimType', ctx.clmType);
        }
        if (String.isNotBlank(claimId)) {
            details.put('claimId', claimId);
        }
        if (String.isNotBlank(claimStatus)) {
            details.put('claimStatus', claimStatus);
        }
        if (String.isBlank(ctx.escId) && Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_CREATE.equalsIgnoreCase(action)) {
            if (ctx.actIdInput && String.isNotBlank(ctx.actId)) {
                details.put('activityIdOrNumber', ctx.actId);
            } else if (String.isNotBlank(ctx.actNum)) {
                details.put('activityIdOrNumber', ctx.actNum);
            } else if (String.isNotBlank(ctx.actId)) {
                details.put('activityIdOrNumber', ctx.actId);
            }
        }
        if (String.isNotBlank(ctx.escId)) {
            details.put('escalationId', ctx.escId);
        }
        details.put('businessRules:', getClaimCreationRules());
        response.details = details;
        return response;
    }

    private static void setResponseBody(RestResponse response, Core_MDF_APIResponse apiResponse, Boolean includeBudgetType) {
        if (response == null || apiResponse == null) {
            return;
        }
        response.statusCode = apiResponse.isSuccess ? 200 : 500;
        response.responseBody = Blob.valueOf(serializeApiResponse(apiResponse, includeBudgetType, false));
    }

    private static String serializeApiResponse(Core_MDF_APIResponse apiResponse, Boolean includeBudgetType, Boolean includeEditableFor) {
        Core_MDF_APIResponse safeResponse = apiResponse;
        if (safeResponse == null) {
            safeResponse = new Core_MDF_APIResponse();
            safeResponse.setErrorInfo(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_MESSAGE, Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR);
        }
        List<String> responseParts = new List<String>{
            '"isSuccess":' + JSON.serialize(safeResponse.isSuccess)
        };
        if (safeResponse.isSuccess && safeResponse.success != null) {
            responseParts.add('"success":' + JSON.serialize(new Map<String, String>{
                'code' => safeResponse.success.code,
                'message' => safeResponse.success.message
            }));
        } else if (!safeResponse.isSuccess && safeResponse.error != null) {
            responseParts.add('"error":' + JSON.serialize(new Map<String, String>{
                'message' => safeResponse.error.message,
                'code' => safeResponse.error.code
            }));
        }
        responseParts.add('"details":' + serializeResponseDetails(safeResponse.details, includeBudgetType, includeEditableFor));
        return '{' + String.join(responseParts, ',') + '}';
    }

    private static String serializeResponseDetails(Object details, Boolean includeBudgetType, Boolean includeEditableFor) {
        if (details == null) {
            return 'null';
        }
        if (!(details instanceof Map<String, Object>)) {
            return JSON.serialize(details);
        }
        Map<String, Object> detailsMap = (Map<String, Object>) details;
        List<String> detailParts = new List<String>();
        List<String> orderedKeys = new List<String>{
            'businessRules:',
            'activityIdOrNumber',
            'escalationId',
            'claimId',
            'claimStatus',
            'claimType',
            'programName',
            'sampleClaimPayload',
            'fields',
            'objectAPIName',
            'totalFields',
            'action'
        };
        for (String key : orderedKeys) {
            if (!detailsMap.containsKey(key)) {
                continue;
            }
            Object value = detailsMap.get(key);
            String serializedValue = key == 'fields'
                ? (detailsMap.containsKey('action') && Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_UPDATE.equalsIgnoreCase(String.valueOf(detailsMap.get('action')))
                    ? serializeUpdateFieldMetadataList(value, includeBudgetType, includeEditableFor || (detailsMap.containsKey('includeEditableFor') && detailsMap.get('includeEditableFor') == true))
                    : serializeFieldMetadataList(value, includeBudgetType))
                : JSON.serialize(value);
            detailParts.add(JSON.serialize(key) + ':' + serializedValue);
        }
        return '{' + String.join(detailParts, ',') + '}';
    }

    private static String serializeFieldMetadataList(Object fieldsValue, Boolean includeBudgetType) {
        if (fieldsValue == null) {
            return '[]';
        }
        List<FieldMetadata> fields = (List<FieldMetadata>) fieldsValue;
        List<String> serializedFields = new List<String>();
        for (FieldMetadata field : fields) {
            if (field == null) {
                continue;
            }
            List<String> fieldParts = new List<String>{
                '"fieldLabel":' + JSON.serialize(field.fieldLabel),
                '"fieldAPIName":' + JSON.serialize(field.fieldAPIName),
                '"fieldType":' + JSON.serialize(field.fieldType),
                '"parentObject":' + JSON.serialize(field.parentObject),
                '"parentField":' + JSON.serialize(field.parentField),
                '"isRequired":' + JSON.serialize(field.isRequired),
                '"description":' + JSON.serialize(field.description),
                '"defaultValue":' + JSON.serialize(field.defaultValue),
                '"allowedValues":' + JSON.serialize(field.allowedValues)
            };
            if (includeBudgetType == true && field.applicableBudgetTypes != null && !field.applicableBudgetTypes.isEmpty()) {
                fieldParts.add('"applicableBudgetTypes":' + JSON.serialize(field.applicableBudgetTypes));
            }
            serializedFields.add('{' + String.join(fieldParts, ',') + '}');
        }
        return '[' + String.join(serializedFields, ',') + ']';
    }

    private static String serializeUpdateFieldMetadataList(Object fieldsValue, Boolean includeBudgetType, Boolean includeEditableFor) {
        if (fieldsValue == null) {
            return '[]';
        }
        List<UpdateFieldMetadata> fields = (List<UpdateFieldMetadata>) fieldsValue;
        List<String> serializedFields = new List<String>();
        for (UpdateFieldMetadata field : fields) {
            if (field == null) {
                continue;
            }
            List<String> fieldParts = new List<String>{
                '"fieldLabel":' + JSON.serialize(field.fieldLabel),
                '"fieldAPIName":' + JSON.serialize(field.fieldAPIName),
                '"fieldType":' + JSON.serialize(field.fieldType),
                '"parentObject":' + JSON.serialize(field.parentObject),
                '"parentField":' + JSON.serialize(field.parentField),
                '"isRequired":' + JSON.serialize(field.isRequired),
                '"description":' + JSON.serialize(field.description),
                '"defaultValue":' + JSON.serialize(field.defaultValue),
                '"allowedValues":' + JSON.serialize(field.allowedValues)
            };
            if (includeEditableFor == true) {
                fieldParts.add('"editableFor":' + serializeEditabilityRules(field.editabilityRulesJson));
            }
            if (includeBudgetType == true && field.applicableBudgetTypes != null && !field.applicableBudgetTypes.isEmpty()) {
                fieldParts.add('"applicableBudgetTypes":' + JSON.serialize(field.applicableBudgetTypes));
            }
            serializedFields.add('{' + String.join(fieldParts, ',') + '}');
        }
        return '[' + String.join(serializedFields, ',') + ']';
    }

    private static String serializeEditabilityRules(String rulesJson) {
        return JSON.serialize(deserializeEditabilityRules(rulesJson));
    }
    
	/**************************************************************
* Method Name: getClaimCreationRules
* Parameters: None
* Description: Returns strings that define claim creation business rules.
**************************************************************/
    private static List<String> getClaimCreationRules() {
        return new List<String>{
            System.Label.Core_MDF_StartDateFutureValidation,
            System.Label.Core_MDF_EndDateFutureValidation,
            System.Label.Core_MDF_StartDate_EndDate_Validation,
            System.Label.Core_MDF_EndDate_StartDate_Validation,
            System.Label.Core_MDF_StartDateValidation,
            System.Label.Core_MDF_EndDateValidation,
            System.Label.Core_MDF_Claim_Reimbursable_Transaction_Amount,
            System.Label.Core_MDF_Exclude_Tax_Message,
            System.Label.Core_MDF_ActivityStatus_Message,
            System.Label.Core_MDF_ClaimAccess_Message
        };
    }
    
/**************************************************************
* Method Name: parseConfiguredSamplePayload
* Parameters: String samplePayloadJson
* Description: Parses the section-configured sample payload JSON (Core_MDF_Custom_Layout_Section__c.Core_MDF_External_API_Sample_Payload_txt__c) into a Map; returns null if blank or invalid.
**************************************************************/
    private static Map<String, Object> parseConfiguredSamplePayload(String samplePayloadJson) {
        if (String.isBlank(samplePayloadJson)) {
            return null;
        }
        try {
            Object parsed = JSON.deserializeUntyped(samplePayloadJson);
            return parsed instanceof Map<String, Object> ? (Map<String, Object>) parsed : null;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    /**************************************************************
* Method Name: buildErrorRes
* Parameters: String errorCode, String msgOverride, Map<String, Object> details
* Description: Looks up error config from Core_MDF_RestAPI_Logger, applies optional {value} substitution to the message, and writes the REST error response.
**************************************************************/
    private static Core_MDF_APIResponse buildErrorRes(String errorCode, String msgOverride, Map<String, Object> details) {
        RestResponse res = RestContext.response != null ? RestContext.response : new RestResponse();
        Core_MDF_RestAPI_Logger.ErrorConfig config = Core_MDF_RestAPI_Logger.getErrorConfigDetails(String.isBlank(errorCode) ? Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR : errorCode, Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_CATEGORY);
        if (config == null) {
            config = new Core_MDF_RestAPI_Logger.ErrorConfig();
            config.code = Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR;
            config.message = Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_MESSAGE;
            config.httpStatusCode = 500;
        }
        if (String.isBlank(config.code)) {
            config.code = Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR;
        }
        if (config.httpStatusCode == null) {
            config.httpStatusCode = 500;
        }
        String resolvedMsg = config.message;
        if (String.isNotBlank(msgOverride)) {
            resolvedMsg = (String.isNotBlank(resolvedMsg) && resolvedMsg.contains('{value}')) ? resolvedMsg.replace('{value}', msgOverride) : msgOverride;
        }
        if (String.isBlank(resolvedMsg)) { 
            resolvedMsg = Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_MESSAGE; 
        }
        Core_MDF_APIResponse errorRes = new Core_MDF_APIResponse();
        errorRes.setErrorInfo(resolvedMsg, config.code);

        Map<String, Object> errorDetails = buildErrorDetails(null);
        if (details != null && !details.isEmpty()) { errorDetails.putAll(details); }
        errorRes.details = errorDetails;
        res.statusCode = config.httpStatusCode;
        res.responseBody = Blob.valueOf(serializeApiResponse(errorRes, false, false));
        RestContext.response = res;
        return errorRes;
    }

    /**************************************************************
* Method Name: logApiRequest
* Parameters: Core_MDF_APIResponse apiRes, List<String> logErrors, Datetime entryTime
* Description: Logs API transaction details to Core_RestAPI_Transaction_Entry__c.
**************************************************************/
    private static void logApiRequest(Core_MDF_APIResponse apiRes, List<String> logErrors, Datetime entryTime) {
        Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
        logReq.apiName = 'Core_MDF_PFC_Metadata_RestAPI';
        logReq.apiVersion = 'v1.0';
        logReq.contextMessage = 'GET PartnerFundClaim Metadata';
        logReq.responsePayload = apiRes;
        logReq.statusCode = apiRes != null ? apiRes.getCode() : Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR;
        logReq.isSuccess = apiRes != null ? apiRes.isSuccess : false;
        logReq.errors = logErrors;
        logReq.entryTime = entryTime;
        logReq.exitTime = System.now();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
    }
    
    global class FieldMetadata {
        public String fieldLabel;
        public String fieldAPIName;
        public String fieldType;
        public Boolean isRequired;
        public String budgetType;
        public List<String> applicableBudgetTypes;
        private Boolean unrestrictedBudgetType;
        public List<PicklistValue> allowedValues;
        public String parentObject;
        public String parentField;
        public String description;
        public String defaultValue;
    }

    global class UpdateFieldMetadata {
        public String fieldLabel;
        public String fieldAPIName;
        public String fieldType;
        public Boolean isRequired;
        public List<String> applicableBudgetTypes;
        private Boolean unrestrictedBudgetType;
        public List<PicklistValue> allowedValues;
        public String parentObject;
        public String parentField;
        public String description;
        public String defaultValue;
        private String editabilityRulesJson;
    }

    private class ClaimUpdateContext {
        public String status;
        public Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext activityContext;
    }

    global class EditabilityRule {
        public List<String> statuses;
    }

    global class PicklistValue {
        public String label;
        public String value;
    }

    private class FieldDefinitionSpec {
        public String fieldAPIName;
        public String parentObject;
        public String parentField;
        public FieldDefinitionSpec(String fieldAPIName) {
            this(fieldAPIName, null, null);
        }
        public FieldDefinitionSpec(String fieldAPIName, String parentObject, String parentField) {
            this.fieldAPIName = fieldAPIName;
            this.parentObject = parentObject;
            this.parentField = parentField;
        }
    }

    private class ClaimFieldConfig {
        public String payloadFieldName;
        public String fieldApiName;
        public String budgetType;
        public Boolean isRequired;
        public String editabilityRulesJson;
    }
}