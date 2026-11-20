/* ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_PFC_Metadata_RestAPI
 * Description     : REST API endpoint for returning PartnerFundClaim metadata required for claim creation
 * ---------------------------------------------------------------------------------- */
@RestResource(urlMapping='/v1.0/partnercenter/claimmetadata/*')
global without sharing class Core_MDF_PFC_Metadata_RestAPI {

    private static final Map<String, List<ClaimFieldConfig>> CLAIM_FIELD_CONFIG_CACHE = new Map<String, List<ClaimFieldConfig>>();
    @HttpGet
    global static void getFieldMetadata() {
        Datetime entryTime = System.now();
        Core_MDF_Campaign_APIResponse apiResponse;
        List<String> logErrors;
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            response.addHeader('Content-Type', 'application/json');
            String clmType = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_CLAIM_TYPE);
            String actIdOrNum = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER);
            String escId = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID);
            String progNm = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME);
            String action = getQueryParam(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTION);

            // Check if no parameters provided at all
            if (String.isBlank(clmType) && String.isBlank(actIdOrNum) && String.isBlank(escId) && String.isBlank(progNm) && String.isBlank(action)) {
                apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS, null, buildErrorDetails(null));
                return;
            }
            // Validate parameters based on claimType
            String validationError = validateRequestParams(clmType, actIdOrNum, escId, progNm, action);
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
                return;
            }
            Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams resolveParams = new Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams();
            resolveParams.clmType = clmType;
            setActivityIdOrNum(resolveParams, actIdOrNum);
            resolveParams.escId = escId;
            resolveParams.progNm = progNm;
            resolveParams.action = action;
            Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(resolveParams);
            ctx.clmType = clmType;

            if (!ctx.recFound) {
                if ('ESCALATION_NOT_FOUND'.equals(ctx.resolutionError)) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_ESCALATION_NF, escId, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ESCALATION_ID));
                    return;
                } else if ('ACTIVITY_NOT_FOUND'.equals(ctx.resolutionError)) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_ACTIVITY_NF, actIdOrNum, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_ACTIVITY_ID_OR_NUMBER));
                    return;
                } else if (!ctx.progEligible) {
                    apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_INVALID_PROG, progNm, buildErrorDetails(Core_MDF_PFC_Metadata_RestAPIUtility.PARAM_PROGRAM_NAME));
                    return;
                }
            }

            Boolean programOnlyRequest = String.isBlank(actIdOrNum) && String.isBlank(escId);
            List<FieldMetadata> respFields = buildFldsFromClaimConfig(ctx.progNm, action, ctx.budgetType, programOnlyRequest);
            for (FieldMetadata f : respFields) {
                if (f == null) { continue; }
                f.allowedValues = getAllowedValues(f.fieldAPIName, ctx);
            }
            respFields = normalizeResponseFields(respFields);
            apiResponse = buildSuccessRes(respFields, ctx);
            setResponseBody(response, apiResponse, String.isNotBlank(progNm));
            RestContext.response = response;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            apiResponse = buildErrorRes(Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_APP_ERROR, null, buildErrorDetails(null));
        } finally {
            logApiRequest(apiResponse, logErrors, entryTime);
        }
    }

/**************************************************************
* Method Name: validateRequestParams
* Parameters: String clmType, String actIdOrNum, String escId, String progNm, String action
* Description: Validates request parameters and returns error code if validation fails, else null.
**************************************************************/
    private static String validateRequestParams(String clmType, String actIdOrNum, String escId, String progNm, String action) {
        if (RestContext.request != null && RestContext.request.params != null) {
            for (String key : RestContext.request.params.keySet()) {
                if (String.isNotBlank(key)) {
                    Boolean found = false;
                    for (String p : Core_MDF_PFC_Metadata_RestAPIUtility.VALID_PARAMS) { 
                        if (p.equalsIgnoreCase(key.trim())) { 
                            found = true; 
                            break; 
                        } 
                    }
                    if (!found) { 
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
            if (String.isBlank(actIdOrNum) && String.isBlank(escId) && String.isBlank(progNm)) {
                return Core_MDF_PFC_Metadata_RestAPIUtility.ERROR_CODE_NO_PARAMS;
            }
        }
        return null;
    }
    
    private static String resolveFieldViewForAction(String action) {
        if (Core_MDF_PFC_Metadata_RestAPIUtility.ACTION_CREATE.equalsIgnoreCase(action)) {
            return Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_VIEW_API_CREATE;
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
        String fieldType = getResFldType(fldDesc);
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
        try {
            if (!Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_FIELDS.containsKey(fldApi)) { 
                return null; 
            }
            return Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_FIELDS.get(fldApi).getDescribe();
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    private static String getResFldType(Schema.DescribeFieldResult fldDesc) {
        String type = Core_MDF_PFC_Metadata_RestAPIUtility.FLD_TYPE_MAP.get(fldDesc.getType());
        return String.isBlank(type) ? 'Text' : type;
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
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_SUBMITTER) {
            return normalizePicklistVal(toPicklistVal(ctx.clmSubmitters), fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_BANK_LOOKUP) {
            return normalizePicklistVal(toPicklistVal(ctx.bankSupNum), fldApi);
        }
        if (fldApi == Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_COUNTRY && !ctx.clmCountry.isEmpty()) {
            return normalizePicklistVal(toPicklistVal(ctx.clmCountry), fldApi);
        }
        return normalizePicklistVal(getStaticPicklistVal(fldApi), fldApi);
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

    private static List<PicklistValue> getStaticPicklistVal(String fieldAPIName) {
        return toPicklistVal(Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues(fieldAPIName));
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
        if (String.isNotBlank(progNm) && String.isNotBlank(fieldView)) {
            try {
                for (Core_MDF_Custom_Layout_Configurations__c record : [
                    SELECT Core_MDF_Field_Label_txt__c, Core_MDF_Field_API_Name_txt__c, Core_MDF_API_Required_Ind__c, Core_MDF_Budget_Type_nm__c
                    FROM Core_MDF_Custom_Layout_Configurations__c
                    WHERE Core_MDF_Object_API_Name_txt__c = :Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME
                    AND Core_MDF_User_Type_nm__c = :Core_MDF_PFC_Metadata_RestAPIUtility.CONFIG_USER_TYPE
                    AND Core_MDF_Record_Type_Name_txt__c = :progNm
                    AND API_Visibility__c = true
                    AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView
                    ORDER BY Core_MDF_Sequence_No_nbr__c NULLS LAST, Core_MDF_Field_Label_txt__c]) {
                    if (String.isBlank(record.Core_MDF_Field_Label_txt__c) || String.isBlank(record.Core_MDF_Field_API_Name_txt__c)) {
                        continue;
                    }
                    ClaimFieldConfig cfg = new ClaimFieldConfig();
                    cfg.payloadFieldName = record.Core_MDF_Field_Label_txt__c.trim();
                    cfg.fieldApiName = record.Core_MDF_Field_API_Name_txt__c.trim();
                    cfg.isRequired = record.Core_MDF_API_Required_Ind__c == true;
                    cfg.budgetType = String.isBlank(record.Core_MDF_Budget_Type_nm__c) ? null : record.Core_MDF_Budget_Type_nm__c.trim();
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
        return configs;
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
        if (Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_BANK_LOOKUP == fldApi) {
            normalized = normalized.replaceAll('[^a-z0-9]', '');
        }
        return normalized;
    }

/**************************************************************
* Method Name: buildSuccessRes
* Parameters: List<FieldMetadata> fields, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx
* Description: Builds the success response details, including the flat fields list and sample claim payload.
**************************************************************/
    private static Core_MDF_Campaign_APIResponse buildSuccessRes(List<FieldMetadata> fields, Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext ctx) {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo(Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_MESSAGE, Core_MDF_PFC_Metadata_RestAPIUtility.SUCCESS_CODE);
        Map<String, Object> details = new Map<String, Object>{ 'objectAPIName' => Core_MDF_PFC_Metadata_RestAPIUtility.PARTNER_FUND_CLAIM_OBJECT_API_NAME };

        details.put('totalFields', fields == null ? 0 : fields.size());
        details.put('fields', fields == null ? new List<FieldMetadata>() : fields);
        details.put('sampleClaimPayload', buildSamplePayload(ctx, fields));

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

    private static void setResponseBody(RestResponse response, Core_MDF_Campaign_APIResponse apiResponse, Boolean includeBudgetType) {
        if (response == null || apiResponse == null) {
            return;
        }
        response.statusCode = apiResponse.isSuccess ? 200 : 500;
        response.responseBody = Blob.valueOf(serializeApiResponse(apiResponse, includeBudgetType));
    }

    private static String serializeApiResponse(Core_MDF_Campaign_APIResponse apiResponse, Boolean includeBudgetType) {
        Core_MDF_Campaign_APIResponse safeResponse = apiResponse;
        if (safeResponse == null) {
            safeResponse = new Core_MDF_Campaign_APIResponse();
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
        responseParts.add('"details":' + serializeResponseDetails(safeResponse.details, includeBudgetType));
        return '{' + String.join(responseParts, ',') + '}';
    }

    private static String serializeResponseDetails(Object details, Boolean includeBudgetType) {
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
            'claimType',
            'programName',
            'sampleClaimPayload',
            'fields',
            'objectAPIName',
            'totalFields'
        };
        for (String key : orderedKeys) {
            if (!detailsMap.containsKey(key)) {
                continue;
            }
            Object value = detailsMap.get(key);
            String serializedValue = key == 'fields'
                ? serializeFieldMetadataList(value, includeBudgetType)
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
* Method Name: buildSamplePayload
* Parameters: Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext actContext, List<FieldMetadata> fields
* Description: Returns a sample claim payload.
**************************************************************/
    private static Map<String, Object> buildSamplePayload(Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext actContext, List<FieldMetadata> fields) {
        String sampleClaimSubmitter = (!actContext.clmSubmitters.isEmpty() && actContext.clmSubmitters[0] != null) ? actContext.clmSubmitters[0].value : '';
        String sampleBankSupplier = hasConfiguredField(fields, Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_BANK_LOOKUP) && !actContext.bankSupNum.isEmpty() && actContext.bankSupNum[0] != null ? actContext.bankSupNum[0].value : '';
        String sampleCountry = (!actContext.clmCountry.isEmpty() && actContext.clmCountry[0] != null) ? actContext.clmCountry[0].value : '';
		Boolean isProgNmOnly = String.isNotBlank(actContext.progNm) && String.isBlank(actContext.actId) && String.isBlank(actContext.actNum) && String.isBlank(actContext.escId);
        String sampleAct = isProgNmOnly ? System.Label.Core_MDF_NormalClaim_Message : (String.isBlank(actContext.actNum) || String.isNotBlank(actContext.escId) ? '' : actContext.actNum);
        String sampleEsc = isProgNmOnly ? System.Label.Core_MDF_LateClaim_Message : (String.isBlank(actContext.escId) ? '' : actContext.escId);
        
        return new Map<String, Object>{
            'claimTitle' => 'API Claim 1',
            'activityNumber' => sampleAct,
            'claimSubmitter' => sampleClaimSubmitter,
            'claimStartDate' => '2026-05-15',
            'claimEndDate' => '2026-05-30',
            'bankSupplierNumber' => sampleBankSupplier,
            'proofOfCostDate' => '2026-05-20',
            'proofOfCostNumber' => 'INV-10001',
            'claimCurrency' => 'USD',
            'escalationId' => sampleEsc,
            'totalAmountLocal' => 0.1,
            'costsNotReimbursableLocal' => 0,
            'claimCountry' => sampleCountry,
            'processingPreference' => '',
            'mediaVehicle' => '',
            'claimComments' => '',
            'documents' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'fileName' => 'invoice.pdf',
                    'fileContent' => 'JVBERi0xLjQKJcTl8uXr...<base64-content>...',
                    'documentType' => ''
                }
            }
        };
    }

    private static Boolean hasConfiguredField(List<FieldMetadata> fields, String fieldAPIName) {
        if (fields == null || String.isBlank(fieldAPIName)) {
            return false;
        }
        for (FieldMetadata field : fields) {
            if (field != null && fieldAPIName.equalsIgnoreCase(field.fieldAPIName)) {
                return true;
            }
        }
        return false;
    }

    /**************************************************************
* Method Name: buildErrorRes
* Parameters: String errorCode, String msgOverride, Map<String, Object> details
* Description: Looks up error config from Core_MDF_RestAPI_Logger, applies optional {value} substitution to the message, and writes the REST error response.
**************************************************************/
    private static Core_MDF_Campaign_APIResponse buildErrorRes(String errorCode, String msgOverride, Map<String, Object> details) {
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
        Core_MDF_Campaign_APIResponse errorRes = new Core_MDF_Campaign_APIResponse();
        errorRes.setErrorInfo(resolvedMsg, config.code);

        Map<String, Object> errorDetails = buildErrorDetails(null);
        if (details != null && !details.isEmpty()) { errorDetails.putAll(details); }
        errorRes.details = errorDetails;
        res.statusCode = config.httpStatusCode;
        res.responseBody = Blob.valueOf(serializeApiResponse(errorRes, false));
        RestContext.response = res;
        return errorRes;
    }

    /**************************************************************
* Method Name: logApiRequest
* Parameters: Core_MDF_Campaign_APIResponse apiRes, List<String> logErrors, Datetime entryTime
* Description: Logs API transaction details to Core_RestAPI_Transaction_Entry__c.
**************************************************************/
    private static void logApiRequest(Core_MDF_Campaign_APIResponse apiRes, List<String> logErrors, Datetime entryTime) {
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
    }
}