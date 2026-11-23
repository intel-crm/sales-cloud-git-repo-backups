@RestResource(urlMapping='/v1.0/partnercenter/attributesbyprogram/*')
global without sharing class Core_MDF_PicklistAttributes_RestAPI {
    /**************************************************************
* Method Name: getPicklistValues
* Parameters: None
* Description: Handles the REST GET request and returns picklist attributes for the requested program.
**************************************************************/
    @HttpGet
    global static void getPicklistValues() {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.addHeader('Content-Type','application/json');
        Datetime entryTime = System.now();
        Core_MDF_Campaign_APIResponse apiRes;
        List<String> logErrors;
        try {
            RestRequest req = RestContext.request;
            String programName = extractProgNmFromPath(req);
            if (String.isBlank(programName) && req != null && req.params != null) {
                programName = req.params.get('programName');
            }
            Map<String, Object> paramValidation = validateAllParams(req);
            if (paramValidation.containsKey('error')) {
                Core_MDF_Campaign_APIResponse paramError = (Core_MDF_Campaign_APIResponse) paramValidation.get('error');
                setResponseBody(res, paramError);
                return;
            }
            String ctrlFldVal = (String) paramValidation.get('ctrlFldVal');
            Boolean useFieldLabels = (Boolean) paramValidation.get('useFieldLabels');
            apiRes = processAttributes(programName, ctrlFldVal, useFieldLabels);
            setResponseBody(res, apiRes);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            apiRes = createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1004_APPLICATION_ERROR,null,null);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            setResponseBody(res, apiRes);
        } finally {
            logApiRequest(apiRes, logErrors, entryTime);
        }
    }

    private static final Map<String, String> SUPPORTED_QUERY_PARAMETER_MAP = new Map<String, String>{
        'programName' => 'programName',
        'controllingFieldValue' => 'controllingFieldValue',
        'fielddisplay' => 'fielddisplay'
    };
    private static final String CTRL_FLD_API = 'Core_MDF_Controlling_Field_nm__c';
    private static final String CTRL_FLD_BUDGET_TYPE = 'Budget Type';
    private static final String CTRL_FLD_FOCUS_AREA = 'Focus Area';
    private static Map<String, Schema.SObjectType> sObjectType = new Map<String, Schema.SObjectType>();
    private static Map<String, Schema.DescribeSObjectResult> sObjectDescribe = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> fieldMap = new Map<String, Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, Schema.FieldSet>> fieldSetMap = new Map<String, Map<String, Schema.FieldSet>>();
    private static Map<String, Schema.DescribeFieldResult> fieldDescribe = new Map<String, Schema.DescribeFieldResult>();
    private static Map<String, Map<String, Schema.RecordTypeInfo>> recTypeByDevName = new Map<String, Map<String, Schema.RecordTypeInfo>>();
    private static Boolean progRecTypeMapLoaded = false;
    private static Map<String, Object> progRecTypeMap;
    private static Map<String, Map<String, Object>> picklistPayloadByRecType = new Map<String, Map<String, Object>>();
    private static Set<String> picklistPayloadInit = new Set<String>();

    private static String buildCacheKey(String objApiName, String fldApiName) {
        return String.valueOf(objApiName) + '::' + String.valueOf(fldApiName);
    }

    private static Schema.SObjectType getSObjectType(String objApiName) {
        if (String.isBlank(objApiName)) {
            return null;
        }
        if (!sObjectType.containsKey(objApiName)) {
            sObjectType.put(objApiName, Schema.getGlobalDescribe().get(objApiName));
        }
        return sObjectType.get(objApiName);
    }
    private static Schema.DescribeSObjectResult getSObjectDescribe(String objApiName) {
        if (String.isBlank(objApiName)) {
            return null;
        }
        if (!sObjectDescribe.containsKey(objApiName)) {
            Schema.SObjectType sObjType = getSObjectType(objApiName);
            sObjectDescribe.put(objApiName, sObjType == null ? null : sObjType.getDescribe());
        }
        return sObjectDescribe.get(objApiName);
    }
    private static Map<String, Schema.SObjectField> getFieldMap(String objApiName) {
        if (String.isBlank(objApiName)) {
            return null;
        }
        if (!fieldMap.containsKey(objApiName)) {
            Schema.DescribeSObjectResult describe = getSObjectDescribe(objApiName);
            fieldMap.put(objApiName, describe == null ? null : describe.fields.getMap());
        }
        return fieldMap.get(objApiName);
    }
    private static Map<String, Schema.FieldSet> getFldSetMap(String objApiName) {
        if (String.isBlank(objApiName)) {
            return null;
        }
        if (!fieldSetMap.containsKey(objApiName)) {
            Schema.DescribeSObjectResult describe = getSObjectDescribe(objApiName);
            Map<String, Schema.FieldSet> fieldSet = (describe == null || describe.fieldSets == null) ? null : describe.fieldSets.getMap();
            fieldSetMap.put(objApiName, fieldSet);
        }
        return fieldSetMap.get(objApiName);
    }
    private static Schema.DescribeFieldResult getFldDesc(String objApiName, String fldApiName) {
        if (String.isBlank(objApiName) || String.isBlank(fldApiName)) {
            return null;
        }
        String cacheKey = buildCacheKey(objApiName, fldApiName);
        if (!fieldDescribe.containsKey(cacheKey)) {
            Schema.DescribeFieldResult fieldDesc;
            Map<String, Schema.SObjectField> fieldMap = getFieldMap(objApiName);
            if (fieldMap != null && fieldMap.containsKey(fldApiName) && fieldMap.get(fldApiName) != null) {
                fieldDesc = fieldMap.get(fldApiName).getDescribe();
            }
            fieldDescribe.put(cacheKey, fieldDesc);
        }
        return fieldDescribe.get(cacheKey);
    }
    private static Map<String, Schema.RecordTypeInfo> getRecTypeInfoByDevNm(String objApiName) {
        if (String.isBlank(objApiName)) {
            return null;
        }
        if (!recTypeByDevName.containsKey(objApiName)) {
            Schema.DescribeSObjectResult describe = getSObjectDescribe(objApiName);
            recTypeByDevName.put(objApiName, describe == null ? null : describe.getRecordTypeInfosByDeveloperName());
        }
        return recTypeByDevName.get(objApiName);
    }
/****************************************************************
* Method Name: resolveCtrlFldVal
* Parameters: RestRequest req
* Description: Returns the controllingFieldValue query parameter, reconstructing it when the raw value contained an unencoded '&'. 
*****************************************************************/
    private static String resolveCtrlFldVal(RestRequest req) {
        if (req == null || req.params == null) {
            return null;
        }
        Map<String, String> params = req.params;
        String baseVal = params.get('controllingFieldValue');
        if (String.isBlank(baseVal)) {
            return baseVal;
        }
        // Collect orphan fragments: unrecognized parameter keys with a blank value.
        List<String> orphanFragments = new List<String>();
        for (String key : params.keySet()) {
            if (!SUPPORTED_QUERY_PARAMETER_MAP.containsKey(key) && String.isBlank(params.get(key))) {
                orphanFragments.add(key);
            }
        }
        if (orphanFragments.isEmpty()) {
            return baseVal;
        }
        orphanFragments.sort();
        return baseVal + '&' + String.join(orphanFragments, '&');
    }
/****************************************************************
* Method Name: validateAllParams
* Parameters: RestRequest req
* Description: Validates all UI parameters (keys, fielddisplay value, controlling field value). 
*****************************************************************/
    private static Map<String, Object> validateAllParams(RestRequest req) {
        Map<String, Object> rslt = new Map<String, Object>();
        if (req == null || req.params == null) {
            rslt.put('ctrlFldVal', null);
            rslt.put('useFieldLabels', true);
            return rslt;
        }
        // Validate parameter keys
        for (String key : req.params.keySet()) {
            if (!SUPPORTED_QUERY_PARAMETER_MAP.containsKey(key)) {
                String paramValue = req.params.get(key);
                if (String.isNotBlank(paramValue)) {
                	List<String> allowedVal = new List<String>{ 'controllingFieldValue', 'fielddisplay' };
                	rslt.put('error', createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1003_INVALID_PARAMETER_KEY, buildInvalidReqParamDetails(key, allowedVal), key));
                	return rslt;
                }
            }
        }
        // Validate fielddisplay value
        String fldDisplayParam = req.params.get('fielddisplay');
        // Labels are the default; only an explicit fielddisplay=technicalname switches to API names.
        Boolean useFieldLabels = true;
        if (!String.isBlank(fldDisplayParam)) {
            String normalizedVal = fldDisplayParam.trim().toLowerCase();
            if (normalizedVal == 'technicalname') {
                useFieldLabels = false;
            } else if (normalizedVal != 'label') {
                List<String> allowedVal = new List<String>{'label', 'technicalname'};
                rslt.put('error', createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1005_INVALID_FIELDDISPLAY_VALUE, buildInvalidReqParamDetails('fielddisplay', allowedVal), fldDisplayParam));
                return rslt;
            }
        }
        // Resolve controlling field value
        String ctrlFldVal = resolveCtrlFldVal(req);
        rslt.put('ctrlFldVal', ctrlFldVal);
        rslt.put('useFieldLabels', useFieldLabels);
        return rslt;
    }
    /****************************************************************
* Method Name: validateCtrlFldVal
* Parameters: String ctrlFldVal, List<String> rtDevNames, String progName
* Description: Validates controllingFieldValue exists in program context. Returns Error 1006 if invalid.
*****************************************************************/
    private static Core_MDF_Campaign_APIResponse validateCtrlFldVal(String ctrlFldVal, List<String> rtDevNames, String progName) {
        if (String.isBlank(ctrlFldVal)) {
            return null;
        }
        List<String> allowedVal = getAllowedValForParam('controllingFieldValue', progName, rtDevNames);
        if (allowedVal != null && !allowedVal.isEmpty()) {
            Boolean valFound = false;
            // Generate candidate values to handle URL encoding ambiguities
            List<String> candidates = buildValueCandidates(ctrlFldVal);
            for (String candidate : candidates) {
                for (String allowed : allowedVal) {
                    if (allowed.equalsIgnoreCase(candidate)) {
                        valFound = true;
                        break;
                    }
                }
                if (valFound) {
                    break;
                }
            }
            if (!valFound) {
                return createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1006_INVALID_CONTROLLING_VALUE, buildInvalidReqParamDetails('controllingFieldValue', allowedVal), ctrlFldVal);
            }
        }
        return null;
    }
    /****************************************************************
* Method Name: setResponseBody
* Parameters: RestResponse res, Core_MDF_Campaign_APIResponse apiRes
* Description: Sets response statusCode and responseBody based on API response.
*****************************************************************/
    private static void setResponseBody(RestResponse res, Core_MDF_Campaign_APIResponse apiRes) {
        if (res == null || apiRes == null) {
            return;
        }
        res.statusCode = resolveHttpStatusCode(apiRes);
        res.responseBody = Blob.valueOf(serializeApiResponse(apiRes));
    }
    /****************************************************************
* Method Name: logApiRequest
* Parameters: Core_MDF_Campaign_APIResponse apiRes, List<String> logErrors, Datetime entryTime
* Description: Logs API request details to transaction entry.
*****************************************************************/
    private static void logApiRequest(Core_MDF_Campaign_APIResponse apiRes, List<String> logErrors, Datetime entryTime) {
        Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
        logReq.apiName = 'Core_MDF_PicklistAttributesAPI';
        logReq.apiVersion = 'v1.0';
        logReq.contextMessage = 'GET Custom Picklist Attributes by Program';
        logReq.responsePayload = apiRes;
        logReq.statusCode = apiRes != null ? apiRes.getCode() : Core_MDF_Attributes_RestAPIConstants.CODE_1004_APPLICATION_ERROR;
        logReq.isSuccess = apiRes != null ? apiRes.isSuccess : false;
        logReq.errors = logErrors;
        logReq.entryTime = entryTime;
        logReq.exitTime = System.now();
        Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
    }
    /****************************************************************
* Method Name: extractProgNmFromPath
* Parameters: RestRequest req
* Description: Extracts and URL-decodes the program name segment from the request URI path.
*****************************************************************/
    private static String extractProgNmFromPath(RestRequest req) {
        if (req == null || String.isBlank(req.requestURI)) {
            return null;
        }
        List<String> uriParts = req.requestURI.split('/');
        if (uriParts == null || uriParts.isEmpty()) {
            return null;
        }
        Integer attrbyProgIndex = -1;
        for (Integer i = 0; i < uriParts.size(); i++) {
            if (uriParts[i].equalsIgnoreCase('attributesbyprogram')) {
                attrbyProgIndex = i;
                break;
            }
        }
        if (attrbyProgIndex < 0 || attrbyProgIndex + 1 >= uriParts.size()) {
            return null;
        }
        String rawProgNm = uriParts[attrbyProgIndex + 1];
        if (String.isBlank(rawProgNm)) {
            return null;
        }
        try {
            return EncodingUtil.urlDecode(rawProgNm, 'UTF-8');
        } catch (Exception ex) {
            return rawProgNm;
        }
    }

    /****************************************************************
* Method Name: processAttributes
* Parameters: String progNmRaw, String ctrlFldVal, Boolean useFieldLabels
* Description: Validates input and builds a response containing record-type filtered picklist attributes.
*****************************************************************/
    private static Core_MDF_Campaign_APIResponse processAttributes(String progNmRaw, String ctrlFldVal, Boolean useFieldLabels) {
        try {
            String progNm = String.isBlank(progNmRaw) ? null : progNmRaw.trim();
            if (String.isBlank(progNm)) {
                return createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1000_PROGRAM_NAME_REQUIRED, buildInvalidReqParamDetails('programName', getValidProgNm()), null);
            }
            Map<String, Object> progResult = queryChannelProgram(progNm);
            if (progResult == null || progResult.isEmpty()) {
                return createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1001_INVALID_PROGRAM_NAME, buildInvalidReqParamDetails('programName', getValidProgNm()), null);
            }
            List<String> rtDevNames = (List<String>) progResult.get('rtDevNames');
            String canonicalProg = (String) progResult.get('canonicalProgram');
            Core_MDF_Campaign_APIResponse ctrlValueError = validateCtrlFldVal(ctrlFldVal, rtDevNames, progNm);
            if (ctrlValueError != null) {
                return ctrlValueError;
            }
            Map<String, Object> attrsByRt = new Map<String, Object>();
            Map<String, Set<String>> mergedValsByFld = new Map<String, Set<String>>();
            Map<String, Object> depsByRt = new Map<String, Object>();
            Map<String, Object> mergedDepsByFld = new Map<String, Object>();
            boolean ctrlValProvided = !String.isBlank(ctrlFldVal);
            boolean foundResultsForCtrlVal = false;
            for (String rtDevName : rtDevNames) {
                RecTypePicklistResult recTypeResult = getRecTypeEnabledPicklstVal(rtDevName, ctrlFldVal, useFieldLabels, canonicalProg);
                Map<String, List<String>> recTypeVal = recTypeResult.valuesByField;
                if (recTypeVal == null || recTypeVal.isEmpty()) {
                    continue;
                }
                foundResultsForCtrlVal = true;
                Set<String> allowedFldApiNames = getFldApiNmFromFldSet('Core_MDF_Custom_Picklist__c', rtDevName);
                recTypeVal = filterValByAllowedFlds(recTypeVal, allowedFldApiNames);
                // The controlling field is surfaced as controllingField and the dependentValues keys instead.
                recTypeVal.remove(CTRL_FLD_API);
                if (recTypeVal.isEmpty()) {
                    continue;
                }
                Map<String, Object> recTypeDependency = filterDepMdtByAllowedFld(recTypeResult.dependenciesByField, allowedFldApiNames, new Set<String>(recTypeVal.keySet()));
                addCtrlFldDependencies(recTypeDependency, recTypeResult.ctrlDependenciesByField, recTypeVal.keySet());
                String recTypeNm = resolveRecTypeNmByDevNm('Core_MDF_Custom_Picklist__c', rtDevName);
                attrsByRt.put(String.isBlank(recTypeNm) ? rtDevName : recTypeNm, recTypeVal);
                if (!recTypeDependency.isEmpty()) {
                    depsByRt.put(String.isBlank(recTypeNm) ? rtDevName : recTypeNm, recTypeDependency);
                }  
                mergeFldValues(mergedValsByFld, recTypeVal);
                mergeDependencyMetadata(mergedDepsByFld, recTypeDependency);
            }
            Map<String, List<String>> data = sortMergedValByFld(mergedValsByFld);

            if (attrsByRt.isEmpty() || data.isEmpty()) {
                return createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1002_NO_PICKLIST_VALUES_FOUND, null, null);
            }
            Set<String> fldApiNames = new Set<String>(data.keySet());
            getFldApiFromDepMdt(fldApiNames, mergedDepsByFld);
            // An empty label map keeps API names as keys when fielddisplay=technicalname.
            Map<String, String> attrFldLabels = useFieldLabels ? getFldLabels(fldApiNames) : new Map<String, String>();
            Object attributesPayload = rtDevNames.size() > 1 ? injectDepIntoAttrByRecType(attrsByRt, depsByRt, attrFldLabels) : injectDepIntoAttr(data, mergedDepsByFld, attrFldLabels);
            Core_MDF_Campaign_APIResponse apiRes = new Core_MDF_Campaign_APIResponse();
            Map<String, Object> respDetails = new Map<String, Object>();
            respDetails.put('programName', canonicalProg);
            respDetails.put('controllingField', resolveCtrlFldDisplayNm(canonicalProg));
            if (!String.isBlank(ctrlFldVal)) {
                respDetails.put('controllingFieldValue', resolveCanonicalCtrlFldVal(rtDevNames, ctrlFldVal));
            }
            respDetails.put('attributes', attributesPayload);
            apiRes.details = respDetails;
            apiRes.setSuccessInfo('Success', Core_MDF_Attributes_RestAPIConstants.CODE_200);
            return apiRes;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1004_APPLICATION_ERROR,null,null);
        }
    }
    /****************************************************************
* Method Name: mergeFldValues
* Parameters: Map<String, Set<String>> mergedValByFld, Map<String, List<String>> recTypeVal
* Description: Merges one record type's field values into the aggregate set map.
*****************************************************************/
    private static void mergeFldValues(Map<String, Set<String>> mergedValByFld, Map<String, List<String>> recTypeVal) {
        if (mergedValByFld == null || recTypeVal == null || recTypeVal.isEmpty()) {
            return;
        }
        for (String fldApiName : recTypeVal.keySet()) {
            Set<String> fieldSet = mergedValByFld.get(fldApiName);
            if (fieldSet == null) {
                fieldSet = new Set<String>();
                mergedValByFld.put(fldApiName, fieldSet);
            }
            for (String fieldVal : recTypeVal.get(fldApiName)) {
                if (!String.isBlank(fieldVal)) {
                    fieldSet.add(fieldVal);
                }
            }
        }
    }
    /****************************************************************
* Method Name: sortMergedValByFld
* Parameters: Map<String, Set<String>> mergedValByFld
* Description: Returns a sorted/distinct list view of the aggregate field values.
*****************************************************************/
    private static Map<String, List<String>> sortMergedValByFld(Map<String, Set<String>> mergedValByFld) {
        Map<String, List<String>> sortedValByFld = new Map<String, List<String>>();
        if (mergedValByFld == null || mergedValByFld.isEmpty()) {
            return sortedValByFld;
        }
        for (String fieldApiName : mergedValByFld.keySet()) {
            Set<String> valueSet = mergedValByFld.get(fieldApiName);
            if (valueSet != null && !valueSet.isEmpty()) {
                sortedValByFld.put(fieldApiName, getSortedDistinctVal(new List<String>(valueSet)));
            }
        }
        return sortedValByFld;
    }
    /****************************************************************
* Method Name: resolveRecTypeInfo
* Parameters: String objApiNm, String recTypeDevNm
* Description: Resolves both record type Id and Name in a single lookup. Returns map with 'id' and 'name' keys, or null if not found.
*****************************************************************/
    private static Map<String, Object> resolveRecTypeInfo(String objApiNm, String recTypeDevNm) {
        if (String.isBlank(objApiNm) || String.isBlank(recTypeDevNm)) {
            return null;
        }
        try {
            Map<String, Schema.RecordTypeInfo> rtInfoByDevNm = getRecTypeInfoByDevNm(objApiNm);
            if (rtInfoByDevNm == null || !rtInfoByDevNm.containsKey(recTypeDevNm)) {
                return null;
            }
            Schema.RecordTypeInfo rtInfo = rtInfoByDevNm.get(recTypeDevNm);
            Map<String, Object> rslt = new Map<String, Object>();
            rslt.put('id', rtInfo.getRecordTypeId());
            rslt.put('name', rtInfo.getName());
            return rslt;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
   }
    private static Id resolveRecTypeIdByDevNm(String objApiNm, String recTypeDevNm) {
        Map<String, Object> info = resolveRecTypeInfo(objApiNm, recTypeDevNm);
        return info != null ? (Id) info.get('id') : null;
    }
    
    private static String resolveRecTypeNmByDevNm(String objApiNm, String recTypeDevNm) {
        Map<String, Object> info = resolveRecTypeInfo(objApiNm, recTypeDevNm);
        return info != null ? (String) info.get('name') : null;
    }
    
    /****************************************************************
* Method Name: getRecTypeEnabledPicklstVal
* Parameters: String recTypeDevNm, String cntrFldVal, Boolean useFldLabels, String progNm
* Description: Returns active and distinct picklist values grouped by field for the given record type.
*****************************************************************/
    private static RecTypePicklistResult getRecTypeEnabledPicklstVal(String recTypeDevNm, String cntrFldVal, Boolean useFldLabels, String progNm) {
        RecTypePicklistResult rslt = new RecTypePicklistResult();
        Map<String, List<String>> valByField = rslt.valuesByField;
        Map<String, Object> payload = String.isBlank(recTypeDevNm) ? null : fetchPicklistForRecType(recTypeDevNm);
        if (payload == null || !payload.containsKey('picklistFieldValues')) {
            return rslt;
        }        
        Set<String> allowedCtrlVals = new Set<String>();
        for (String ctrlVal : getActiveValFromPayload(payload, CTRL_FLD_API)) {
            allowedCtrlVals.add(ctrlVal.trim().toLowerCase());
        }
        allowedCtrlVals.removeAll(getLegacyBudgetTypeSet());
        Integer cntrFldValIndex = null;        
            if (!String.isBlank(cntrFldVal)) {
                cntrFldValIndex = findCntrFldValIndexInFld(payload, 'Core_MDF_Controlling_Field_nm__c', cntrFldVal);
                if (cntrFldValIndex == null) {
                    return rslt;
                }
            }        
    Map<String, Object> picklistFldVal = (Map<String, Object>) payload.get('picklistFieldValues');
        for (String fieldApiName : picklistFldVal.keySet()) {
            Map<String, Object> fldDetails = (Map<String, Object>) picklistFldVal.get(fieldApiName);
            if (fldDetails == null || !fldDetails.containsKey('values')) {
                continue;
            }            
            List<String> eligibleVal = new List<String>();
            List<Map<String, Object>> eligibleValDetails = new List<Map<String, Object>>();
            List<Object> values = (List<Object>) fldDetails.get('values');            
            boolean shouldApplyCntrValFilter = false;
            boolean shouldSkipFld = false;
            boolean shouldApplyProgFilter = false;
            Integer progControllerIndex = null;
            if (cntrFldValIndex != null && !fieldApiName.equalsIgnoreCase('Core_MDF_Controlling_Field_nm__c')) {
                boolean isDependentOnThisCntrFld = isDependentOnCntrFld(fldDetails, payload, 'Core_MDF_Controlling_Field_nm__c');
                if (isDependentOnThisCntrFld) {
                    Map<String, Object> fldDependencyInfo = getFldDependencyInfo(fldDetails, cntrFldVal);
                    shouldApplyCntrValFilter = (Boolean) fldDependencyInfo.get('isDependent');
                    shouldSkipFld = (Boolean) fldDependencyInfo.get('shouldSkip');
                }
            }
            if (!shouldSkipFld && !String.isBlank(progNm) && !fieldApiName.equalsIgnoreCase('Core_MDF_Program__c')) {
                boolean isDependentOnProg = isDependentOnCntrFld(fldDetails, payload, 'Core_MDF_Program__c');
                if (isDependentOnProg) {
                    Map<String, Object> ctrlrValues = (Map<String, Object>) fldDetails.get('controllerValues');
                    if (ctrlrValues != null) {
                        List<String> progCandidates = buildValueCandidates(progNm);
                        Integer bestProgCandidateIdx = -1;
                        for (String ctrlrKey : ctrlrValues.keySet()) {
                            String keyNorm = ctrlrKey.trim().toLowerCase();
                            for (Integer ci = 0; ci < progCandidates.size(); ci++) {
                                if (progCandidates.get(ci).equals(keyNorm) && ci > bestProgCandidateIdx) {
                                    bestProgCandidateIdx = ci;
                                    try {
                                        progControllerIndex = (Integer) ctrlrValues.get(ctrlrKey);
                                    } catch (Exception ex) {
                                        try {
                                            progControllerIndex = Integer.valueOf(String.valueOf(ctrlrValues.get(ctrlrKey)));
                                        } catch (Exception ignoreEx) {}
                                    }
                                }
                            }
                        }
                        // Step 2: direct match failed (e.g. ChannelProgram.Name='Datacenter' but
                        // Core_MDF_Program__c stored value='Data Center CoMarketing Fund').
                        // Fall back to matching progNm against the UI API label of Core_MDF_Program__c
                        // picklist entries, then re-try with the resolved stored value.
                        if (progControllerIndex == null) {
                            Map<String, Object> pklstFldValsForProg = (Map<String, Object>) payload.get('picklistFieldValues');
                            Map<String, Object> progFldInPayload = (pklstFldValsForProg != null && pklstFldValsForProg.containsKey('Core_MDF_Program__c'))
                                ? (Map<String, Object>) pklstFldValsForProg.get('Core_MDF_Program__c')
                                : null;
                            if (progFldInPayload != null && progFldInPayload.containsKey('values')) {
                                String resolvedProgStoredVal = null;
                                for (Object progValObj : (List<Object>) progFldInPayload.get('values')) {
                                    Map<String, Object> progValDetails = (Map<String, Object>) progValObj;
                                    if (progValDetails == null) continue;
                                    Object labelObj = progValDetails.get('label');
                                    if (labelObj == null) continue;
                                    String labelNorm = htmlDecodePicklistValue(String.valueOf(labelObj)).trim().toLowerCase();
                                    for (String cand : progCandidates) {
                                        if (cand.equals(labelNorm)) {
                                            resolvedProgStoredVal = getPicklistRawVal(progValDetails);
                                            break;
                                        }
                                    }
                                    if (!String.isBlank(resolvedProgStoredVal)) break;
                                }
                                if (!String.isBlank(resolvedProgStoredVal)) {
                                    List<String> resolvedCandidates = buildValueCandidates(resolvedProgStoredVal);
                                    Integer bestResolveCandidateIdx = -1;
                                    for (String ctrlrKey : ctrlrValues.keySet()) {
                                        String keyNorm = ctrlrKey.trim().toLowerCase();
                                        for (Integer ci = 0; ci < resolvedCandidates.size(); ci++) {
                                            if (resolvedCandidates.get(ci).equals(keyNorm) && ci > bestResolveCandidateIdx) {
                                                bestResolveCandidateIdx = ci;
                                                try {
                                                    progControllerIndex = (Integer) ctrlrValues.get(ctrlrKey);
                                                } catch (Exception ex) {
                                                    try {
                                                        progControllerIndex = Integer.valueOf(String.valueOf(ctrlrValues.get(ctrlrKey)));
                                                    } catch (Exception ignoreEx) {}
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (progControllerIndex != null) {
                            shouldApplyProgFilter = true;
                        }
                        // If progControllerIndex is still null after both passes, no filtering applied.
                    }
                }
            }
            if (shouldSkipFld) {
                continue;
            }            
            for (Object valueObj : values) {
                Map<String, Object> valDetails = (Map<String, Object>) valueObj;
                if (valDetails == null || !valDetails.containsKey('value')) {
                    continue;
                }
                Object activeObj = valDetails.get('active');
                Boolean isActive = activeObj == null ? true : (Boolean) activeObj;                
                if (!isActive) {
                    continue;
                }                
                if (shouldApplyCntrValFilter && !isValValidForCntrFld(valDetails, cntrFldValIndex)) {
                    continue;
                }
                if (shouldApplyProgFilter && !isValValidForCntrFld(valDetails, progControllerIndex)) {
                    continue;
                }
                String valueStr = getPicklistDisplayVal(valDetails, useFldLabels);
                if (!String.isBlank(valueStr)) {
                    eligibleVal.add(valueStr);
                    eligibleValDetails.add(valDetails);
                }
            }            
            List<String> sortedDistinct = getSortedDistinctVal(eligibleVal);
            if (!sortedDistinct.isEmpty()) {
                valByField.put(fieldApiName, sortedDistinct);                
                Map<String, Object> dependencyMdt = buildDependencyMdtForFld(fieldApiName, fldDetails, picklistFldVal, eligibleValDetails, useFldLabels);
                if (dependencyMdt != null) {
                    rslt.dependenciesByField.put(fieldApiName, dependencyMdt);
                }
                if (!fieldApiName.equalsIgnoreCase(CTRL_FLD_API)) {
                    Map<String, Object> ctrlDependency = buildCtrlFldDependency(fldDetails, payload, eligibleValDetails, cntrFldValIndex, allowedCtrlVals, useFldLabels);
                    if (ctrlDependency != null) {
                        rslt.ctrlDependenciesByField.put(fieldApiName, ctrlDependency);
                    }
                }
            }
        }
        normalizeDependencyMdtToEligibleVal(valByField, rslt.dependenciesByField);
        return rslt;
    }
    /****************************************************************
* Method Name: normalizeDependencyMdtToEligibleVal
* Parameters: Map<String, List<String>> valByField, Map<String, Object> dependencyByFld
* Description: Trims dependency metadata so it references only controlling/dependent values that remain eligible after filtering.
*****************************************************************/
    private static void normalizeDependencyMdtToEligibleVal(Map<String, List<String>> valByField, Map<String, Object> dependencyByFld) {
        if (valByField == null || valByField.isEmpty() || dependencyByFld == null || dependencyByFld.isEmpty()) {
            return;
        }
        List<String> dependentFlds = new List<String>(dependencyByFld.keySet());
        for (String dependentFldApi : dependentFlds) {
            if (!valByField.containsKey(dependentFldApi)) {
                dependencyByFld.remove(dependentFldApi);
                continue;
            }
            Map<String, Object> mdt = (Map<String, Object>) dependencyByFld.get(dependentFldApi);
            if (mdt == null || !mdt.containsKey('dependentOn') || !mdt.containsKey('dependentValues')) {
                dependencyByFld.remove(dependentFldApi);
                continue;
            }
            String controllingFldApiNm = String.valueOf(mdt.get('dependentOn'));
            if (String.isBlank(controllingFldApiNm) || !valByField.containsKey(controllingFldApiNm)) {
                dependencyByFld.remove(dependentFldApi);
                continue;
            }
            Set<String> eligibleCntrVal = new Set<String>(valByField.get(controllingFldApiNm));
            Set<String> eligibleDepVal = new Set<String>(valByField.get(dependentFldApi)); 
            Map<String, Object> depValuesRaw = (Map<String, Object>) mdt.get('dependentValues');
            if (depValuesRaw == null || depValuesRaw.isEmpty() || eligibleCntrVal.isEmpty() || eligibleDepVal.isEmpty()) {
                dependencyByFld.remove(dependentFldApi);
                continue;
            }
            Map<String, Object> normalizedDepVal = new Map<String, Object>();
            for (String controllingValue : depValuesRaw.keySet()) {
                if (!eligibleCntrVal.contains(controllingValue)) {
                    continue;
                }
                List<String> dependentList = (List<String>) depValuesRaw.get(controllingValue);
                if (dependentList == null || dependentList.isEmpty()) {
                    continue;
                }
                List<String> filteredDepList = new List<String>();
                for (String dependentValue : dependentList) {
                    if (eligibleDepVal.contains(dependentValue)) {
                        filteredDepList.add(dependentValue);
                    }
                }
                filteredDepList = getSortedDistinctVal(filteredDepList);
                if (!filteredDepList.isEmpty()) {
                    normalizedDepVal.put(controllingValue, filteredDepList);
                }
            }
            if (normalizedDepVal.isEmpty()) {
                dependencyByFld.remove(dependentFldApi);
                continue;
            }
            mdt.put('dependentValues', normalizedDepVal);
        }
    }
    /****************************************************************
* Method Name: fetchPicklistForRecType
* Parameters: String recTypeDevNm
* Description: Retrieves record-type-specific picklist payload from test hook or UI API.
*****************************************************************/
    private static Map<String, Object> fetchPicklistForRecType(String recTypeDevNm) {
        if (String.isBlank(recTypeDevNm)) {
            return null;
        }
        if (picklistPayloadInit.contains(recTypeDevNm)) {
            return picklistPayloadByRecType.get(recTypeDevNm);
        }
        Map<String, Object> payload;
        /*if (Test.isRunningTest()) {
            payload = Core_MDF_CampaignCreatePage.PicklistFetcher(recTypeDevNm);
        } else {*/
            Id recTypeId = resolveRecTypeIdByDevNm('Core_MDF_Custom_Picklist__c', recTypeDevNm);
            if (recTypeId != null) {
                payload = fetchRecTypeValFromUiApi('Core_MDF_Custom_Picklist__c', recTypeId);
            }
        //}
        picklistPayloadInit.add(recTypeDevNm);
        picklistPayloadByRecType.put(recTypeDevNm, payload);
        return payload;    }
    
    /****************************************************************
* Method Name: getActiveValFromPayload
* Parameters: Map<String, Object> payload, String fldApi
* Description: Extracts active values for a field from UI API payload and returns sorted distinct entries.
*****************************************************************/
    private static List<String> getActiveValFromPayload(Map<String, Object> payload, String fldApi) {
        List<String> values = new List<String>();
        if (payload == null || String.isBlank(fldApi) || !payload.containsKey('picklistFieldValues')) {
            return values;
        }
        Map<String, Object> picklistVal = (Map<String, Object>) payload.get('picklistFieldValues');
        if (picklistVal == null || !picklistVal.containsKey(fldApi)) {
            return values;
        }
        Map<String, Object> fldDetails = (Map<String, Object>) picklistVal.get(fldApi);
        if (fldDetails == null || !fldDetails.containsKey('values')) {
            return values;
        }
        List<Object> fldVal = (List<Object>) fldDetails.get('values');
        for (Object val : fldVal) {
            Map<String, Object> valDetails = (Map<String, Object>) val;
            if (valDetails == null || !valDetails.containsKey('value')) {
                continue;
            }
            Object activeObj = valDetails.get('active');
            Boolean isActive = activeObj == null ? true : (Boolean) activeObj;
            if (!isActive) {
                continue;
            }
            String valueStr = htmlDecodePicklistValue(String.valueOf(valDetails.get('value')));
            if (!String.isBlank(valueStr)) {
                values.add(valueStr);
            }
        }        
        return getSortedDistinctVal(values);
    }
    
    /****************************************************************
* Method Name: buildInvalidReqParamDetails
* Parameters: String paramName, List<String> allowedVal
* Description: Builds a standardized invalid parameter details object for API errors.
*****************************************************************/
    private static Map<String, Object> buildInvalidReqParamDetails(String paramName, List<String> allowedVal) {
        return new Map<String, Object>{
            'parameter' => paramName,
            'allowedValues' => allowedVal == null ? new List<String>() : allowedVal};
    }
    
    /****************************************************************
* Method Name: getAllowedValForParam
* Parameters: String expectedParam, String programNm, List<String> matchedRecTypeDevNm
* Description: Resolves allowed values list for a supported query parameter.
*****************************************************************/
    private static List<String> getAllowedValForParam(String expectedParam, String programNm, List<String> matchedRecTypeDevNm) {
        if (String.isBlank(expectedParam)) {
            return new List<String>();
        }
        if ('programName' == expectedParam) {
            return getValidProgNm();
        }
        if ('fielddisplay' == expectedParam) {
            return new List<String>{'label','technicalname'};
        }
        if ('controllingFieldValue' == expectedParam) {
            List<String> recTypeDevNm = matchedRecTypeDevNm;
            if (recTypeDevNm == null || recTypeDevNm.isEmpty()) {
                String normalizedProgName = String.isBlank(programNm) ? null : programNm.trim();
                if (String.isBlank(normalizedProgName)) {
                    return new List<String>();
                }
                recTypeDevNm = inferRecTypeDevNmFromProg(normalizedProgName);
            }
            return getValidCntrFldVal(recTypeDevNm);
        }
        return new List<String>();
    }
    
    /****************************************************************
* Method Name: getValidProgNm
* Parameters: None
* Description: Returns sorted eligible Channel Program names for request validation.
*****************************************************************/
    private static List<String> getValidProgNm() {
        List<String> validProg = new List<String>();
        try {
            // Query ChannelProgram where Core_MDF_Project_Platform__c is not null (eligible programs)
            List<ChannelProgram> eligibleProgs = [SELECT Id, Name FROM ChannelProgram WHERE Core_MDF_Project_Platform__c != null ORDER BY Name ASC];
            if (eligibleProgs == null || eligibleProgs.isEmpty()) {
                return validProg;
            }
            for (ChannelProgram prog : eligibleProgs) {
                if (prog != null && !String.isBlank(prog.Name)) {
                    validProg.add(prog.Name.trim());
                }
            }
            return getSortedDistinctVal(validProg);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return validProg;
        }
    }
    
    /****************************************************************
* Method Name: getValidCntrFldVal
* Parameters: List<String> matchedRecTypeDevNm
* Description: Returns valid controlling field values across matched record types, excluding legacy values.
*****************************************************************/
    private static List<String> getValidCntrFldVal(List<String> matchedRecTypeDevNm) {
        Set<String> validCntrFldVal = new Set<String>();
        if (matchedRecTypeDevNm == null || matchedRecTypeDevNm.isEmpty()) {
            return new List<String>();
        }
        for (String recTypeDevNm : matchedRecTypeDevNm) {
            Map<String, Object> payload = fetchPicklistForRecType(recTypeDevNm);
            for (String value : getActiveValFromPayload(payload, 'Core_MDF_Controlling_Field_nm__c')) {
                validCntrFldVal.add(value);
            }
        }
        List<String> allValues = getSortedDistinctVal(new List<String>(validCntrFldVal));
        // Filter out legacy budget types (e.g. 'CCF 1.0', 'DCF 1.0')
        Set<String> legacySet = getLegacyBudgetTypeSet();
        if (!legacySet.isEmpty()) {
            List<String> filtered = new List<String>();
            for (String val : allValues) {
                if (!legacySet.contains(val.trim().toLowerCase())) {
                    filtered.add(val);
                }
            }
            return filtered;
        }
        return allValues;
    }    
    /****************************************************************
* Method Name: getFldDependencyInfo
* Parameters: Map<String, Object> fldDetails, String cntrFldVal
* Description: Determines if a field is dependent and whether it should be included for the given controlling value.
*              Returns a map with 'isDependent' and 'shouldSkip' flags.
*              - isDependent: true if field has validFor arrays (is a dependent picklist)
*              - shouldSkip: true if field is dependent but controlling value is not valid for it
*****************************************************************/
    private static Map<String, Object> getFldDependencyInfo(Map<String, Object> fldDetails, String cntrFldVal) {
        Map<String, Object> rslt = new Map<String, Object>();
        rslt.put('isDependent', false);
        rslt.put('shouldSkip', false);        
        if (fldDetails == null || String.isBlank(cntrFldVal)) {
            return rslt;
        }        
        try {
            // Check if field has validFor arrays (indicates dependent picklist)
            List<Object> values = (List<Object>) fldDetails.get('values');
            if (values == null || values.isEmpty()) {
                return rslt;
            }            
            boolean hasValidFor = false;
            for (Object valueObj : values) {
                Map<String, Object> valMap = (Map<String, Object>) valueObj;
                if (valMap != null && valMap.containsKey('validFor')) {
                    hasValidFor = true;
                    break;
                }
            }            
            if (!hasValidFor) {
                // Field is independent (no validFor arrays)
                return rslt;
            }            
            // Field has validFor, so it's dependent on some controlling field
            rslt.put('isDependent', true);            
            Map<String, Object> controllerVal = (Map<String, Object>) fldDetails.get('controllerValues');
            if (!fldDetails.containsKey('controllerValues') || controllerVal == null || controllerVal.isEmpty()) {
                rslt.put('shouldSkip', true);
                return rslt;
            }
            // Build candidates for this controlling field value (handles space/plus/ampersand variants)
            List<String> candidates = buildValueCandidates(cntrFldVal);
            // Find best match: prefer higher-index candidates to handle "MDF" vs "MDF+" disambiguation
            Integer bestMatchCandidateIndex = -1;
            for (String controllerKey : controllerVal.keySet()) {
                String controllerKeyNorm = controllerKey.trim().toLowerCase();
                for (Integer i = 0; i < candidates.size(); i++) {
                    if (candidates.get(i).equals(controllerKeyNorm)) {
                        if (i > bestMatchCandidateIndex) {
                            bestMatchCandidateIndex = i;
                        }
                        break;
                    }
                }
            }            
            if (bestMatchCandidateIndex < 0) {
                rslt.put('shouldSkip', true);
                return rslt;
            }            
            return rslt;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return rslt;
    }    
    /****************************************************************
* Method Name: isDependentOnCntrFld
* Parameters: Map<String, Object> fieldDetails, Map<String, Object> uiApiPayload, String cntrFldApi
* Description: Determines if a specific field is dependent on the specified controlling field.
*****************************************************************/
    private static boolean isDependentOnCntrFld(Map<String, Object> fieldDetails, Map<String, Object> uiApiPayload, String cntrFldApi) {
        try {
            if (!fieldDetails.containsKey('controllerValues')) {
                return false;
            }            
            Map<String, Object> fieldControllerVal = (Map<String, Object>) fieldDetails.get('controllerValues');
            if (fieldControllerVal == null || fieldControllerVal.isEmpty()) {
                return false;
            }            
            Map<String, Object> picklistFldVal = (Map<String, Object>) uiApiPayload.get('picklistFieldValues');
            if (picklistFldVal == null || !picklistFldVal.containsKey(cntrFldApi)) {
                return false;
            }            
            Map<String, Object> cntrFldDetails = (Map<String, Object>) picklistFldVal.get(cntrFldApi);
            if (cntrFldDetails == null || !cntrFldDetails.containsKey('values')) {
                return false;
            }            
            List<Object> cntrFldVal = (List<Object>) cntrFldDetails.get('values');
            Set<String> cntrFldValSet = new Set<String>();
            for (Object valueObj : cntrFldVal) {
                Map<String, Object> valDetails = (Map<String, Object>) valueObj;
                if (valDetails != null && valDetails.containsKey('value')) {
                    cntrFldValSet.add(String.valueOf(valDetails.get('value')).trim().toLowerCase());
                }
            }            
            Set<String> fieldCntrValKeys = new Set<String>();
            for (String key : fieldControllerVal.keySet()) {
                fieldCntrValKeys.add(key.trim().toLowerCase());
            }            
            Set<String> intersection = new Set<String>(fieldCntrValKeys);
            intersection.retainAll(cntrFldValSet);
            return !intersection.isEmpty();
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return false;
        }
    }    
    /****************************************************************
* Method Name: buildValueCandidates
* Parameters: String inputVal
* Description: Generates candidate string variants to handle URL-decoding ambiguity in Experience Cloud, where '+' in a query param is decoded as a space bEFORE Apex receives it.
*                "MDF "  (received) -> {mdf, mdf+}   prioritizes mdf+ match for "MDF+"
*                "MDF+"  (received) -> {mdf+, mdf}   prioritizes mdf+ exact match
*                "MDF"   (received) -> {mdf}          no ambiguity
*****************************************************************/
    private static List<String> buildValueCandidates(String inputVal) {
        if (String.isBlank(inputVal)) {
            return new List<String>();
        }
        String lower = inputVal.toLowerCase();
        String trimmed = lower.trim();
        Set<String> candidateSet = new Set<String>();
        List<String> candidateList = new List<String>();
        candidateSet.add(trimmed);
        candidateList.add(trimmed);    
        // If input contains spaces, add variant with spaces replaced by plus signs
        if (lower.contains(' ')) {
            String withPlus = lower.replace(' ', '+');
            if (!candidateSet.contains(withPlus)) {
                candidateSet.add(withPlus);
                candidateList.add(withPlus);
            }
        }    
        // If input contains plus signs, add variants with plus replaced by spaces
        if (lower.contains('+')) {
            String withSpace = lower.replace('+', ' ');
            if (!candidateSet.contains(withSpace)) {
                candidateSet.add(withSpace);
                candidateList.add(withSpace);
            }        
            String withSpaceTrimmed = withSpace.trim();
            if (!candidateSet.contains(withSpaceTrimmed)) {
                candidateSet.add(withSpaceTrimmed);
                candidateList.add(withSpaceTrimmed);
            }
            // Callers prefer the highest index, so the literal '+' value must rank last to win over its prefix (MDF+ vs MDF).
            candidateList.remove(0);
            candidateList.add(trimmed);
        }    
        // Handle HTML-encoded ampersands
        if (trimmed.contains('&') && !trimmed.contains('&amp;')) {
            String withAmpEntity = trimmed.replace('&', '&amp;');
            if (!candidateSet.contains(withAmpEntity)) {
                candidateList.add(withAmpEntity);
            }
        }
        if (trimmed.contains('&amp;')) {
            String withoutAmpEntity = trimmed.replace('&amp;', '&');
            if (!candidateSet.contains(withoutAmpEntity)) {
                candidateList.add(withoutAmpEntity);
            }
        }
        return candidateList;
    }
    /****************************************************************
* Method Name: findCntrFldValIndexInFld
* Parameters: Map<String, Object> uiApiPayload, String cntrFldApi, String cntrFldVal
* Description: Gets the index of the provided controlling field value within the specified controlling field.
*              Returns the index position of the value in that field's picklist values.
*****************************************************************/
    private static Integer findCntrFldValIndexInFld(Map<String, Object> uiApiPayload, String cntrFldApi, String cntrFldVal) {
        if (uiApiPayload == null || String.isBlank(cntrFldApi) || String.isBlank(cntrFldVal)) {
            return null;
        }        
        try {
            Map<String, Object> picklistFldVal = (Map<String, Object>) uiApiPayload.get('picklistFieldValues');
            Map<String, Object> fldDetails = (picklistFldVal == null || !picklistFldVal.containsKey(cntrFldApi)) ? null : (Map<String, Object>) picklistFldVal.get(cntrFldApi);
            if (fldDetails == null || !fldDetails.containsKey('values')) {
                return null;
            }            
            List<Object> values = (List<Object>) fldDetails.get('values');
            List<String> candidates = buildValueCandidates(cntrFldVal);
            Integer valueIndex = 0;
            Integer bestMatchValIndex = null;
            Integer bestMatchCandidateIndex = -1;            
            for (Object valueObj : values) {
                Map<String, Object> valueDetails = (Map<String, Object>) valueObj;
                if (valueDetails != null && valueDetails.containsKey('value')) {
                    String picklistValNorm = String.valueOf(valueDetails.get('value')).trim().toLowerCase();
                    for (Integer i = 0; i < candidates.size(); i++) {
                        if (candidates.get(i).equals(picklistValNorm) && i > bestMatchCandidateIndex) {
                            bestMatchCandidateIndex = i;
                            bestMatchValIndex = valueIndex;
                            break;
                        }
                    }
                }
                valueIndex++;
            }            
            if (bestMatchValIndex != null) {
                return bestMatchValIndex;
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }        
        return null;
    }    
    /****************************************************************
* Method Name: isValValidForCntrFld
* Parameters: Map<String, Object> valueDetails, Integer cntrFldValIndex
* Description: Checks if a dependent picklist value is valid for the given controlling field value index.
*****************************************************************/
    private static Boolean isValValidForCntrFld(Map<String, Object> valueDetails, Integer cntrFldValIndex) {
        if (valueDetails == null || cntrFldValIndex == null) {
            return true;
        }        
        try {
            if (!valueDetails.containsKey('validFor')) {
                return true;// No validFor array means this is an independent value
            }
            List<Object> validForList = (List<Object>) valueDetails.get('validFor');
            String valueStr = String.valueOf(valueDetails.get('value'));
            if (validForList == null || validForList.isEmpty()) {
                return true;
            }            
            for (Object validForObj : validForList) {
                try {
                    Integer validForIndex = (Integer) validForObj;
                    if (validForIndex == cntrFldValIndex) {
                        return true;
                    }
                } catch (Exception ex) {
                    try {
                        Integer validForInt = Integer.valueOf(String.valueOf(validForObj));
                        if (validForInt == cntrFldValIndex) {
                            return true;
                        }
                    } catch (Exception e2) {
                        // Type conversion failed, continue to next item
                    }
                }
            }            
            return false;            
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return true;
        }
    }    
    /****************************************************************
* Method Name: getFldApiNmFromFldSet
* Parameters: String objectApi, String recTypeDevNm
* Description: Loads all fieldsets mapped to a record type and returns the union of field API names across them.
*****************************************************************/
    private static Set<String> getFldApiNmFromFldSet(String objectApi, String recTypeDevNm) {
        Set<String> allowedFldApi = new Set<String>();
        if (String.isBlank(objectApi) || String.isBlank(recTypeDevNm)) {
            return allowedFldApi;
        }
        Map<String, Schema.FieldSet> fieldSetMap = getFldSetMap(objectApi);
        if (fieldSetMap == null || fieldSetMap.isEmpty()) {
            return allowedFldApi;
        }        
        List<Core_MDF_RecordType_FieldSet_Mapping__mdt> mappings = [SELECT Core_MDF_Field_Set_API_Name_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c = :objectApi AND Core_MDF_Record_Type_DeveloperName_nm__c = :recTypeDevNm];
        for (Core_MDF_RecordType_FieldSet_Mapping__mdt rec : mappings) {
            String fieldSetApi = rec.Core_MDF_Field_Set_API_Name_nm__c;
            if (String.isBlank(fieldSetApi) || !fieldSetMap.containsKey(fieldSetApi)) {
                continue;
            }            
            for (Schema.FieldSetMember fieldSetMember : fieldSetMap.get(fieldSetApi).getFields()) {
                String fieldPath = fieldSetMember.getFieldPath();
                if (!String.isBlank(fieldPath)) {
                    allowedFldApi.add(fieldPath);
                }
            }
        }
        return allowedFldApi;
    }    
    /****************************************************************
* Method Name: filterValByAllowedFlds
* Parameters: Map<String, List<String>> recTypeVal, Set<String> allowedFldApi
* Description: Keeps only picklist fields that are included in the mapped fieldset union.
*****************************************************************/
    private static Map<String, List<String>> filterValByAllowedFlds(Map<String, List<String>> recTypeVal, Set<String> allowedFldApi) {
        Map<String, List<String>> filteredValues = new Map<String, List<String>>();
        if (recTypeVal == null || recTypeVal.isEmpty()) {
            return filteredValues;
        }
        if (allowedFldApi == null || allowedFldApi.isEmpty()) {
            return recTypeVal;
        }
        for (String fieldApiName : recTypeVal.keySet()) {
            if (allowedFldApi.contains(fieldApiName)) {
                filteredValues.put(fieldApiName, recTypeVal.get(fieldApiName));
            }
        }
        return filteredValues;
    }    
    /****************************************************************
* Method Name: fetchRecTypeValFromUiApi
* Parameters: String objApi, Id recTypeId
* Description: Calls the Salesforce UI API to retrieve picklist metadata for a specific record type.
*****************************************************************/
    private static Map<String, Object> fetchRecTypeValFromUiApi(String objApi, Id recTypeId) {
        if (String.isBlank(objApi) || recTypeId == null) {
            return null;
        }        
        try {            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Custom_Picklist_Values/'+recTypeId);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setTimeout(120000);
            HttpResponse res = new Http().send(req);
            if (res == null || res.getStatusCode() < 200 || res.getStatusCode() >= 300 || String.isBlank(res.getBody())) {
                return null;
            }            
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }    
    /****************************************************************
* Method Name: queryChannelProgram
* Parameters: String progName
* Description: Queries ChannelProgram standard object to verify program eligibility via Program_Type__c field.
*              If eligible, uses Core_MDF_ProgramRecordTypeMapping to identify associated record type developer names.
*****************************************************************/
    private static Map<String, Object> queryChannelProgram(String progName) {
        if (String.isBlank(progName)) {
            return null;
        }
        try {
            String normalizedProgram = progName.trim().toLowerCase();
            // Query ChannelProgram to verify program is eligible (has Program_Type__c value)
            List<ChannelProgram> progRecords = [select Id, Name, IsActive, Core_MDF_Project_Platform__c from ChannelProgram WHERE Name =: normalizedProgram AND Core_MDF_Project_Platform__c != null LIMIT 100];
            if (progRecords == null || progRecords.isEmpty()) {
                return null;
            }            
            // Check if program name matches an eligible ChannelProgram record
            String canonicalProgram = null;
            for (ChannelProgram prog : progRecords) {
                String progNameLower = String.isBlank(prog.Name) ? null : prog.Name.trim().toLowerCase();
                if (normalizedProgram.equals(progNameLower)) {
                    canonicalProgram = prog.Name;
                    break;
                }
            }            
            // If eligible program found, get record types from Core_MDF_ProgramRecordTypeMapping
            if (canonicalProgram == null) {
                return null;
            }            
            List<String> rtDevNames = inferRecTypeDevNmFromProg(canonicalProgram);
            if (rtDevNames == null || rtDevNames.isEmpty()) {
                return null;
            }            
            Map<String, Object> rslt= new Map<String, Object>();
            rslt.put('rtDevNames', rtDevNames);
            rslt.put('canonicalProgram', canonicalProgram);
            return rslt;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }    
    /****************************************************************
* Method Name: inferRecTypeDevNmFromProg
* Parameters: String progName
* Description: Maps a normalized program name to one or more record type developer names.
*****************************************************************/
    private static List<String> inferRecTypeDevNmFromProg(String progName) {
        if (String.isBlank(progName)) {
            return new List<String>();
        }        
        String normalizedProgram = String.isBlank(progName) ? null : progName.trim().toLowerCase();
        if (String.isBlank(normalizedProgram)) {
            return new List<String>();
        }
        Map<String, Object> recTypeToProgMap = getProgRecTypeMap();
        if (recTypeToProgMap == null || recTypeToProgMap.isEmpty()) {
            return new List<String>();
        }        
        List<String> matchedRecTypes = new List<String>();
        for (String recTypeDevNm : recTypeToProgMap.keySet()) {
            String mappedProgram = String.isBlank(String.valueOf(recTypeToProgMap.get(recTypeDevNm))) ? null : String.valueOf(recTypeToProgMap.get(recTypeDevNm)).trim().toLowerCase();
            if (normalizedProgram.equals(mappedProgram)) {
                matchedRecTypes.add(recTypeDevNm);
            }
        }        
        matchedRecTypes.sort();
        return matchedRecTypes;
    }
    /****************************************************************
* Method Name: resolveCanonicalCtrlFldVal
* Parameters: List<String> rtDevNames, String ctrlFldVal
* Description: Returns the actual decoded controlling field value as stored in Salesforce
*****************************************************************/
    private static String resolveCanonicalCtrlFldVal(List<String> rtDevNames, String ctrlFldVal) {
        if (String.isBlank(ctrlFldVal) || rtDevNames == null || rtDevNames.isEmpty()) {
            return ctrlFldVal;
        }
        try {
            for (String rtDevName : rtDevNames) {
                Map<String, Object> payload = fetchPicklistForRecType(rtDevName);
                if (payload == null || !payload.containsKey('picklistFieldValues')) {
                    continue;
                }
                Map<String, Object> pklstFldVals = (Map<String, Object>) payload.get('picklistFieldValues');
                if (!pklstFldVals.containsKey('Core_MDF_Controlling_Field_nm__c')) {
                    continue;
                }
                Map<String, Object> fldDetails = (Map<String, Object>) pklstFldVals.get('Core_MDF_Controlling_Field_nm__c');
                if (fldDetails == null || !fldDetails.containsKey('values')) {
                    continue;
                }
                List<String> candidates = buildValueCandidates(ctrlFldVal);
                List<Object> values = (List<Object>) fldDetails.get('values');
                Integer bestMatchCandidateIndex = -1;
                String bestMatchVal = null;
                for (Object valueObj : values) {
                    Map<String, Object> valDetails = (Map<String, Object>) valueObj;
                    if (valDetails == null || !valDetails.containsKey('value')) {
                        continue;
                    }
                    String picklistValNorm = String.valueOf(valDetails.get('value')).trim().toLowerCase();
                    for (Integer i = 0; i < candidates.size(); i++) {
                        if (candidates.get(i).equals(picklistValNorm) && i > bestMatchCandidateIndex) {
                            bestMatchCandidateIndex = i;
                            bestMatchVal = htmlDecodePicklistValue(String.valueOf(valDetails.get('value')));
                            break;
                        }
                    }
                }
                if (bestMatchVal != null) {
                    return bestMatchVal;
                }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return ctrlFldVal;
    }   
    /****************************************************************
* Method Name: getProgRecTypeMap
* Parameters: None
* Description: Loads and parses the program-to-record-type mapping from custom metadata JSON chunks.
*****************************************************************/
    private static Map<String, Object> getProgRecTypeMap() {
        if (progRecTypeMapLoaded) {
            return progRecTypeMap;
        }
        try {
            Core_MDF_Custom_Label_Configration__mdt mappingRec = [SELECT Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c, Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Value5_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE DeveloperName = 'Core_MDF_ProgramRecordTypeMapping' LIMIT 1];
            String mappingJson = '';
            for (String chunk : new List<String>{mappingRec.Core_MDF_Value_Txt__c, mappingRec.Core_MDF_Value2_Txt__c, mappingRec.Core_MDF_Value3_Txt__c, mappingRec.Core_MDF_Value4_Txt__c, mappingRec.Core_MDF_Value5_Txt__c}) {
                if (!String.isBlank(chunk)) {
                    mappingJson += chunk;
                }
            }
            if (String.isBlank(mappingJson)) {
                progRecTypeMapLoaded = true;
                progRecTypeMap = null;
                return null;
            }            
            //return (Map<String, Object>) JSON.deserializeUntyped(mappingJson);
            progRecTypeMap = (Map<String, Object>) JSON.deserializeUntyped(mappingJson);
            progRecTypeMapLoaded = true;
            return progRecTypeMap;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        progRecTypeMapLoaded = true;
        progRecTypeMap = null;
        return null;
    }
    /****************************************************************
* Method Name: htmlDecodePicklistValue
* Parameters: String value
* Description: Decodes common HTML entities that the Salesforce UI API encodes in picklist value and label fields.
*****************************************************************/
    private static String htmlDecodePicklistValue(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        return value
            .replace('&lt;',  '<')
            .replace('&gt;',  '>')
            .replace('&quot;', '"')
            .replace('&#39;',  '\'')
            .replace('&apos;', '\'')
            .replace('&amp;',  '&');
    }    
    /****************************************************************
* Method Name: getPicklistRawVal
* Parameters: Map<String, Object> valDetails
* Description: Returns decoded raw picklist value from a UI API value details object.
*****************************************************************/
    private static String getPicklistRawVal(Map<String, Object> valDetails) {
        if (valDetails == null || !valDetails.containsKey('value')) {
            return null;
        }
        return htmlDecodePicklistValue(String.valueOf(valDetails.get('value')));
    }
    
    /****************************************************************
* Method Name: getPicklistDisplayVal
* Parameters: Map<String, Object> valDetails, Boolean useFieldLabels
* Description: Returns label when requested and available; otherwise returns decoded raw value.
*****************************************************************/
    private static String getPicklistDisplayVal(Map<String, Object> valDetails, Boolean useFieldLabels) {
        String rawValue = getPicklistRawVal(valDetails);
        
        if (!useFieldLabels) {
            return rawValue;
        }
        
        Object labelObj = valDetails == null ? null : valDetails.get('label');
        if (labelObj != null && !String.isBlank(String.valueOf(labelObj))) {
            return htmlDecodePicklistValue(String.valueOf(labelObj));
        }
        
        return rawValue;
    }
    /****************************************************************
* Method Name: getSortedDistinctVal
* Parameters: List<String> values
* Description: Removes blank and duplicate values, then returns the list in sorted order.
*****************************************************************/
    private static List<String> getSortedDistinctVal(List<String> values) {
        Set<String> dedupeSet = new Set<String>();
        if (values != null) {
            for (String value : values) {
                if (!String.isBlank(value)) {
                    dedupeSet.add(value);
                }
            }
        }
        Map<String, List<String>> lowerToOriginals = new Map<String, List<String>>();
        for (String val : dedupeSet) {
            String lower = val.toLowerCase();
            if (!lowerToOriginals.containsKey(lower)) {
                lowerToOriginals.put(lower, new List<String>());
            }
            lowerToOriginals.get(lower).add(val);
        }        
        List<String> sortedLower = new List<String>(lowerToOriginals.keySet());
        sortedLower.sort();        
        List<String> rslt= new List<String>();
        for (String lower : sortedLower) {
            List<String> originals = lowerToOriginals.get(lower);
            originals.sort();
            rslt.addAll(originals);
        }        
        return rslt;
    }    
    /****************************************************************
* Method Name: createErrorApiResponse
* Parameters: String code, String message, String errorMsgOverride
* Description: Creates a standardized error API response with the provided code and message.
*****************************************************************/
	private static Core_MDF_Campaign_APIResponse createErrorApiResponse(String code, Object details, String errorMsgOverride) {
        Core_MDF_RestAPI_Logger.ErrorConfig config = Core_MDF_RestAPI_Logger.getErrorConfigDetails(code,'Custom Picklist Attributes');
        
        if (config == null) {
            config = new Core_MDF_RestAPI_Logger.ErrorConfig();
            config.code = code;
            config.message = System.Label.Core_MDF_ApplicationErrorMessage;
            config.httpStatusCode = Core_MDF_Attributes_RestAPIConstants.HTTP_500;
        }        
        String responseMessage = config.message;
        if (String.isNotBlank(errorMsgOverride)) {
            if (responseMessage.contains('{value}')) {
                responseMessage = responseMessage.replace('{value}', errorMsgOverride);
            }
        }
        Core_MDF_Campaign_APIResponse apiResponse = new Core_MDF_Campaign_APIResponse();
        apiResponse.details = details;
        apiResponse.setErrorInfo(responseMessage, config.code);
        return apiResponse;
    }
    /****************************************************************
* Method Name: resolveHttpStatusCode
* Parameters: Core_MDF_Campaign_APIResponse apiResponse
* Description: Converts the API response code to an HTTP status code with safe fallback handling.
*****************************************************************/
    private static Integer resolveHttpStatusCode(Core_MDF_Campaign_APIResponse apiResponse) {
        if (apiResponse == null || String.isBlank(apiResponse.getCode())) {
            return Core_MDF_Attributes_RestAPIConstants.HTTP_500;
        }        
        if (apiResponse.isSuccess) {
            return Core_MDF_Attributes_RestAPIConstants.HTTP_200;
        }        
        Core_MDF_RestAPI_Logger.ErrorConfig config = Core_MDF_RestAPI_Logger.getErrorConfigDetails(apiResponse.getCode(),'Custom Picklist Attributes');
        if (config != null) {
            return config.httpStatusCode;
        }        
        return Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(apiResponse.getCode());
    }
    
    /****************************************************************
* Method Name: serializeApiResponse
* Parameters: Core_MDF_Campaign_APIResponse apiResponse
* Description: Serializes the API response into a controlled JSON structure for REST output.
*****************************************************************/
    private static String serializeApiResponse(Core_MDF_Campaign_APIResponse apiResponse) {
        Core_MDF_Campaign_APIResponse safeResponse = apiResponse;
        if (safeResponse == null) {
            safeResponse = createErrorApiResponse(Core_MDF_Attributes_RestAPIConstants.CODE_1004_APPLICATION_ERROR,null,null);
        }
        String jsonStr = '{';
        jsonStr += '"isSuccess":' + (safeResponse.isSuccess ? 'true' : 'false');
        if (safeResponse.isSuccess && safeResponse.success != null) {
            jsonStr += ',"success":{"code":"' + safeResponse.success.code + '","message":"' + safeResponse.success.message.replace('"', '\\"') + '"}';
        } else if (!safeResponse.isSuccess && safeResponse.error != null) {
            jsonStr += ',"error":{"code":"' + safeResponse.error.code + '","message":"' + safeResponse.error.message.replace('"', '\\"') + '"}';
        }
        if (safeResponse.details == null) {
            jsonStr += ',"details":null';
        } else if (safeResponse.details instanceof Map<String, Object>) {
            Map<String, Object> detailsMap = (Map<String, Object>) safeResponse.details;
            jsonStr += ',"details":{';
            List<String> detailsParts = new List<String>();
            if (detailsMap.containsKey('programName')) {
                detailsParts.add('"programName":' + JSON.serialize(detailsMap.get('programName')));
            }
            if (detailsMap.containsKey('controllingField')) {
                detailsParts.add('"controllingField":' + JSON.serialize(detailsMap.get('controllingField')));
            }
            if (detailsMap.containsKey('controllingFieldValue')) {
                detailsParts.add('"controllingFieldValue":' + JSON.serialize(detailsMap.get('controllingFieldValue')));
            }
            if (detailsMap.containsKey('parameter')) {
                detailsParts.add('"parameter":' + JSON.serialize(detailsMap.get('parameter')));
            }
            if (detailsMap.containsKey('expectedParameter')) {
                detailsParts.add('"expectedParameter":' + JSON.serialize(detailsMap.get('expectedParameter')));
            }
            if (detailsMap.containsKey('allowedValues')) {
                detailsParts.add('"allowedValues":' + JSON.serialize(detailsMap.get('allowedValues')));
            }
            if (detailsMap.containsKey('attributes')) {
                detailsParts.add('"attributes":' + serializeWithSortedMapKeys(detailsMap.get('attributes'),false));
            }			
            if (detailsMap.containsKey('attributesByRecordType')) {
                detailsParts.add('"attributesByRecordType":' + serializeWithSortedMapKeys(detailsMap.get('attributesByRecordType'),false));
            }
            for (String key : detailsMap.keySet()) {
                if (key != 'programName' && key != 'controllingField' && key != 'controllingFieldValue' && key != 'parameter' && key != 'expectedParameter' && key != 'allowedValues' && key != 'attributes' && key != 'attributesByRecordType' /*&& key != 'attributeDependencies'*/) {
                    detailsParts.add('"' + key + '":' + JSON.serialize(detailsMap.get(key)));
                }
            }
            jsonStr += String.join(detailsParts, ',');
            jsonStr += '}';
        } else {
            jsonStr += ',"details":' + JSON.serialize(safeResponse.details);
        }        
        jsonStr += '}';
        return jsonStr;
    }    
    /****************************************************************
* Method Name: getFldLabels
* Parameters: Set<String> fldApiNm
* Description: Resolves the field label for each provided API name on Core_MDF_Custom_Picklist__c.
*              Falls back to the API name if the label cannot be retrieved.
*****************************************************************/
    private static Map<String, String> getFldLabels(Set<String> fldApiNm) {
        Map<String, String> labelByApi = new Map<String, String>();
        if (fldApiNm == null || fldApiNm.isEmpty()) {
            return labelByApi;
        }
        try {
            Map<String, Schema.SObjectField> fields = getFieldMap('Core_MDF_Custom_Picklist__c');
            if (fields == null || fields.isEmpty()) {
                return labelByApi;
            }
            for (String fldApi : fldApiNm) {
                if (String.isBlank(fldApi)) {
                    continue;
                }
                if (!fields.containsKey(fldApi)) {
                    labelByApi.put(fldApi, fldApi);
                    continue;
                }
                try {
                    Schema.DescribeFieldResult fieldDescribe = getFldDesc('Core_MDF_Custom_Picklist__c', fldApi);
                    String label = fieldDescribe == null ? null : fieldDescribe.getLabel();
                    labelByApi.put(fldApi, String.isBlank(label) ? fldApi : label);
                } catch (Exception ex) {
                    labelByApi.put(fldApi, fldApi);
                }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return labelByApi;
    }
    
    /****************************************************************
* Method Name: filterDepMdtByAllowedFld
* Parameters: Map<String, Object> dependencyByFld, Set<String> allowedFldApi, Set<String> returnedFldApi
* Description: Filters dependency metadata to include only dependencies whose dependent and controlling fields are allowed and returned.
*****************************************************************/
    private static Map<String, Object> filterDepMdtByAllowedFld(Map<String, Object> dependencyByFld, Set<String> allowedFldApi, Set<String> returnedFldApi) {
        Map<String, Object> filtered = new Map<String, Object>();
        if (dependencyByFld == null || dependencyByFld.isEmpty()) {
            return filtered;
        }
        for (String fldApiNm : dependencyByFld.keySet()) {
            if (returnedFldApi != null && !returnedFldApi.isEmpty() && !returnedFldApi.contains(fldApiNm)) {
                continue;
            }
            if (allowedFldApi != null && !allowedFldApi.isEmpty() && !allowedFldApi.contains(fldApiNm)) {
                continue;
            }
            Map<String, Object> metadata = (Map<String, Object>) dependencyByFld.get(fldApiNm);
            if (metadata == null || !metadata.containsKey('dependentOn')) {
                continue;
            }
            String cntrFldApiName = String.valueOf(metadata.get('dependentOn'));
            if (String.isBlank(cntrFldApiName)) {
                continue;
            }
            if (returnedFldApi != null && !returnedFldApi.isEmpty() && !returnedFldApi.contains(cntrFldApiName)) {
                continue;
            }
            if (allowedFldApi != null && !allowedFldApi.isEmpty() && !allowedFldApi.contains(cntrFldApiName)) {
                continue;
            }
            filtered.put(fldApiNm, metadata);
        }
        return filtered;
    }
    /****************************************************************
* Method Name: mergeDependencyMetadata
* Parameters: Map<String, Object> mergedDependencyByFld, Map<String, Object> recTypeDependency
* Description: Merges per-record-type dependency metadata into one combined map while deduplicating dependent values.
*****************************************************************/
    private static void mergeDependencyMetadata(Map<String, Object> mergedDependencyByFld, Map<String, Object> recTypeDependency) {
        if (mergedDependencyByFld == null || recTypeDependency == null || recTypeDependency.isEmpty()) {
            return;
        }
        for (String dependentFieldApiName : recTypeDependency.keySet()) {
            Map<String, Object> incomingMeta = (Map<String, Object>) recTypeDependency.get(dependentFieldApiName);
            if (incomingMeta == null || !incomingMeta.containsKey('dependentValues')) {
                continue;
            }
            if (!mergedDependencyByFld.containsKey(dependentFieldApiName)) {
                Map<String, Object> cloneMeta = new Map<String, Object>();
                cloneMeta.put('dependentOn', incomingMeta.get('dependentOn'));
                Map<String, Object> cloneDependentVal = new Map<String, Object>();
                Map<String, Object> incomingDependentVal = (Map<String, Object>) incomingMeta.get('dependentValues');
                for (String controllingValue : incomingDependentVal.keySet()) {
                    cloneDependentVal.put(controllingValue, new List<String>((List<String>) incomingDependentVal.get(controllingValue)));
                }
                cloneMeta.put('dependentValues', cloneDependentVal);
                mergedDependencyByFld.put(dependentFieldApiName, cloneMeta);
                continue;
            }
            Map<String, Object> mergedMeta = (Map<String, Object>) mergedDependencyByFld.get(dependentFieldApiName);
            if (!mergedMeta.containsKey('dependentOn')) {
                mergedMeta.put('dependentOn', incomingMeta.get('dependentOn'));
            }
            Map<String, Object> mergedDependentVal = (Map<String, Object>) mergedMeta.get('dependentValues');
            if (mergedDependentVal == null) {
                mergedDependentVal = new Map<String, Object>();
                mergedMeta.put('dependentValues', mergedDependentVal);
            }
            Map<String, Object> incomingDependentVal = (Map<String, Object>) incomingMeta.get('dependentValues');
            for (String controllingValue : incomingDependentVal.keySet()) {
                List<String> mergedList = mergedDependentVal.containsKey(controllingValue) ? (List<String>) mergedDependentVal.get(controllingValue) : new List<String>();
                for (String dependentValue : (List<String>) incomingDependentVal.get(controllingValue)) {
                    if (!mergedList.contains(dependentValue)) {
                        mergedList.add(dependentValue);
                    }
                }
                mergedList = getSortedDistinctVal(mergedList);
                mergedDependentVal.put(controllingValue, mergedList);
            }
        }
    }
    /****************************************************************
* Method Name: getFldApiFromDepMdt
* Parameters: Set<String> fldApi, Map<String, Object> dependenciesByFld
* Description: Adds dependent field keys and controlling field references found in dependency metadata to the provided field API accumulator.
*****************************************************************/
    private static void getFldApiFromDepMdt(Set<String> fldApi, Map<String, Object> dependenciesByFld) {
        if (fldApi == null || dependenciesByFld == null || dependenciesByFld.isEmpty()) {
            return;
        }
        for (String dependentFldApi : dependenciesByFld.keySet()) {
            fldApi.add(dependentFldApi);
            Map<String, Object> metadata = (Map<String, Object>) dependenciesByFld.get(dependentFldApi);
            if (metadata == null || !metadata.containsKey('dependentOn')) {
                continue;
            }
            String dependentOnFldApi = String.valueOf(metadata.get('dependentOn'));
            if (!String.isBlank(dependentOnFldApi)) {
                fldApi.add(dependentOnFldApi);
            }
        }
    }
    /****************************************************************
* Method Name: buildDependencyMdtForFld
* Parameters: String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal, List<Map<String, Object>> eligibleValDetails, Boolean useFldLabels
* Description: Builds dependentOn and dependentValues metadata for one dependent field using UI API data with schema fallback.
*****************************************************************/
    private static Map<String, Object> buildDependencyMdtForFld(String dependentFldApi,Map<String, Object> dependentFldDetails,Map<String, Object> picklistFldVal,List<Map<String, Object>> eligibleValDetails,Boolean useFldLabels) {
        if (String.isBlank(dependentFldApi) || dependentFldDetails == null || picklistFldVal == null || eligibleValDetails == null || eligibleValDetails.isEmpty()) {
            return null;
        }
        if (!dependentFldDetails.containsKey('controllerValues')) {
            return null;
        }
        Map<String, Object> cntrVal = (Map<String, Object>) dependentFldDetails.get('controllerValues');
        if (cntrVal == null || cntrVal.isEmpty()) {
            return null;
        }
        String cntrFldApi = resolveControllingFldApi(dependentFldApi, dependentFldDetails, picklistFldVal);
        if (String.isBlank(cntrFldApi) || !picklistFldVal.containsKey(cntrFldApi)) {
            return null;
        }
        if (cntrFldApi.equalsIgnoreCase('Core_MDF_Controlling_Field_nm__c') || cntrFldApi.equalsIgnoreCase('Core_MDF_Program__c')) {
                return null;
        }
        Map<String, Object> cntrFldDetails = (Map<String, Object>) picklistFldVal.get(cntrFldApi);
        Map<Integer, String> cntrDisplayByIndex = buildControllerIndexToDisplayValMapFromCntrVal(cntrVal, cntrFldDetails, useFldLabels);
        if (cntrDisplayByIndex.isEmpty()) {
            return null;
        }
        Map<String, List<String>> dependentValByCntrVal = new Map<String, List<String>>();
        for (Map<String, Object> valueDetails : eligibleValDetails) {
            if (valueDetails == null) {
                continue;
            }
            String dependentValDisplay = getPicklistDisplayVal(valueDetails, useFldLabels);
            if (String.isBlank(dependentValDisplay)) {
                continue;
            }
            List<Object> validForList = (List<Object>) valueDetails.get('validFor');
            if (validForList == null || validForList.isEmpty()) {
                continue;
            }
            for (Object validForObj : validForList) {
                Integer controllerIndex;
                try {
                    controllerIndex = (Integer) validForObj;
                } catch (Exception ex) {
                    try {
                        controllerIndex = Integer.valueOf(String.valueOf(validForObj));
                    } catch (Exception ignoreEx) {
                        controllerIndex = null;
                    }
                }
                if (controllerIndex == null || !cntrDisplayByIndex.containsKey(controllerIndex)) {
                    continue;
                }
                String cntrDisplayValue = cntrDisplayByIndex.get(controllerIndex);
                if (String.isBlank(cntrDisplayValue)) {
                    continue;
                }
                if (!dependentValByCntrVal.containsKey(cntrDisplayValue)) {
                    dependentValByCntrVal.put(cntrDisplayValue, new List<String>());
                }
                List<String> dependentList = dependentValByCntrVal.get(cntrDisplayValue);
                if (!dependentList.contains(dependentValDisplay)) {
                    dependentList.add(dependentValDisplay);
                }
            }
        }        
        if (!dependentValByCntrVal.isEmpty()) {
            Map<String, Object> serializedDependentVal = new Map<String, Object>();
            for (String cntrDisplayValue : dependentValByCntrVal.keySet()) {
                serializedDependentVal.put(cntrDisplayValue, getSortedDistinctVal(dependentValByCntrVal.get(cntrDisplayValue)));
            }
            return new Map<String, Object>{
                'dependentOn' => cntrFldApi,
                'dependentValues' => serializedDependentVal
            };
        }
        Map<String, Object> dependentValFromSchema = buildDependencyValFromSchema(cntrFldApi, dependentFldApi, cntrFldDetails, eligibleValDetails, useFldLabels);
        if (dependentValFromSchema == null || dependentValFromSchema.isEmpty()) {
            return null;
        }
        return new Map<String, Object>{
            'dependentOn' => cntrFldApi,
            'dependentValues' => dependentValFromSchema
        };
    }
    /****************************************************************
* Method Name: buildDependencyValFromSchema
* Parameters: String cntrFieldApi, String dependentFldApi, Map<String, Object> cntrFieldDetails, List<Map<String, Object>> eligibleVal, Boolean useFldLabels
* Description: Builds dependentValues mapping from schema-level validFor metadata constrained to currently eligible values.
*****************************************************************/
    private static Map<String, Object> buildDependencyValFromSchema(String cntrFieldApi, String dependentFldApi, Map<String, Object> cntrFieldDetails, List<Map<String, Object>> eligibleVal, Boolean useFieldLabels) {
        if (String.isBlank(cntrFieldApi) || String.isBlank(dependentFldApi) ||
            cntrFieldDetails == null || eligibleVal == null || eligibleVal.isEmpty()) {
                return null;
            }
        Map<String, Set<String>> schemaDependencyMap = getSchemaDependencyMap(cntrFieldApi, dependentFldApi);
        if (schemaDependencyMap == null || schemaDependencyMap.isEmpty()) {
            return null;
        }
        Map<String, String> controllingDisplayByRaw = buildControllerRawToDisplayValueMap(cntrFieldDetails, useFieldLabels);
        if (controllingDisplayByRaw.isEmpty()) {
            return null;
        }
        Map<String, String> eligibleDependentDisplayByRaw = buildDependentRawToDisplayValueMap(eligibleVal, useFieldLabels);
        if (eligibleDependentDisplayByRaw.isEmpty()) {
            return null;
        }
        Map<String, Object> dependentVal = new Map<String, Object>();
        for (String controllingRawVal : schemaDependencyMap.keySet()) {
            if (!controllingDisplayByRaw.containsKey(controllingRawVal)) {
                continue;
            }
            String controllingDisplayValue = controllingDisplayByRaw.get(controllingRawVal);
            Set<String> allowedDependentRawSet = schemaDependencyMap.get(controllingRawVal);
            if (allowedDependentRawSet == null || allowedDependentRawSet.isEmpty()) {
                continue;
            }
            List<String> dependentDisplayValues = new List<String>();
            for (String dependentRawValue : allowedDependentRawSet) {
                if (eligibleDependentDisplayByRaw.containsKey(dependentRawValue)) {
                    dependentDisplayValues.add(eligibleDependentDisplayByRaw.get(dependentRawValue));
                }
            }
            dependentDisplayValues = getSortedDistinctVal(dependentDisplayValues);
            if (!dependentDisplayValues.isEmpty()) {
                dependentVal.put(controllingDisplayValue, dependentDisplayValues);
            }
        }
        return dependentVal.isEmpty() ? null : dependentVal;
    }
    /****************************************************************
* Method Name: buildControllerRawToDisplayValueMap
* Parameters: Map<String, Object> cntrFldDetails, Boolean useFldLabels
* Description: Maps active controlling raw values to display values.
*****************************************************************/
    private static Map<String, String> buildControllerRawToDisplayValueMap(Map<String, Object> cntrFldDetails, Boolean useFldLabels) {
        Map<String, String> rawToDisplay = new Map<String, String>();
        if (cntrFldDetails == null || !cntrFldDetails.containsKey('values')) {
            return rawToDisplay;
        }
        List<Object> controllingValues = (List<Object>) cntrFldDetails.get('values');
        for (Object controllingValueObj : controllingValues) {
            Map<String, Object> controllingValueDetails = (Map<String, Object>) controllingValueObj;
            if (controllingValueDetails == null || !controllingValueDetails.containsKey('value')) {
                continue;
            }
            Object activeObj = controllingValueDetails.get('active');
            Boolean isActive = activeObj == null ? true : (Boolean) activeObj;
            if (!isActive) {
                continue;
            }
            String rawValue = getPicklistRawVal(controllingValueDetails);
            if (String.isBlank(rawValue)) {
                continue;
            }
            String displayValue = getPicklistDisplayVal(controllingValueDetails, useFldLabels);
            if (!String.isBlank(displayValue)) {
                rawToDisplay.put(rawValue, displayValue);
            }
        }
        return rawToDisplay;
    }
    /****************************************************************
* Method Name: buildDependentRawToDisplayValueMap
* Parameters: List<Map<String, Object>> eligibleValDetails, Boolean useFldLabels
* Description: Maps eligible dependent raw values to display values.
*****************************************************************/
    private static Map<String, String> buildDependentRawToDisplayValueMap(List<Map<String, Object>> eligibleValDetails, Boolean useFieldLabels) {
        Map<String, String> rawToDisplay = new Map<String, String>();
        if (eligibleValDetails == null || eligibleValDetails.isEmpty()) {
            return rawToDisplay;
        }
        for (Map<String, Object> valueDetails : eligibleValDetails) {
            if (valueDetails == null || !valueDetails.containsKey('value')) {
                continue;
            }
            String rawValue = getPicklistRawVal(valueDetails);
            if (String.isBlank(rawValue)) {
                continue;
            }
            String displayValue = getPicklistDisplayVal(valueDetails, useFieldLabels);
            if (!String.isBlank(displayValue)) {
                rawToDisplay.put(rawValue, displayValue);
            }
        }
        return rawToDisplay;
    }
    /****************************************************************
* Method Name: getSchemaDependencyMap
* Parameters: String controllingFldApi, String dependentFldApi
* Description: Decodes schema dependent-picklist validFor metadata into controlling raw value to dependent raw value mappings.
*****************************************************************/
    private static Map<String, Set<String>> getSchemaDependencyMap(String controllingFldApi, String dependentFieldApi) {
        Map<String, Set<String>> dependencyMap = new Map<String, Set<String>>();
        if (String.isBlank(controllingFldApi) || String.isBlank(dependentFieldApi)) {
            return dependencyMap;
        }
        try {
            Map<String, Schema.SObjectField> fieldMap = getFieldMap('Core_MDF_Custom_Picklist__c');
            if (fieldMap == null || !fieldMap.containsKey(controllingFldApi) || !fieldMap.containsKey(dependentFieldApi)) {
                return dependencyMap;
            }
            Schema.DescribeFieldResult controllingDescribe = getFldDesc('Core_MDF_Custom_Picklist__c', controllingFldApi);
            Schema.DescribeFieldResult dependentDescribe = getFldDesc('Core_MDF_Custom_Picklist__c', dependentFieldApi);
            if (controllingDescribe == null || dependentDescribe == null) {
                return dependencyMap;
            }
            List<Schema.PicklistEntry> controllingVal = controllingDescribe.getPicklistValues();
            List<Schema.PicklistEntry> dependentVal = dependentDescribe.getPicklistValues();
            if (controllingVal == null || controllingVal.isEmpty() || dependentVal == null || dependentVal.isEmpty()) {
                return dependencyMap;
            }
            for (Schema.PicklistEntry controllingEntry : controllingVal) {
                dependencyMap.put(
                    htmlDecodePicklistValue(controllingEntry.getValue()),
                    new Set<String>()
                );
            }
            for (Schema.PicklistEntry dependentEntry : dependentVal) {
                String dependentRawValue = htmlDecodePicklistValue(dependentEntry.getValue());
                if (String.isBlank(dependentRawValue)) {
                    continue;
                }
                String encodedValidFor = extractEncodedValidForFromPicklistEntry(dependentEntry);
                if (String.isBlank(encodedValidFor)) {
                    continue;
                }
                String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(encodedValidFor)).toUpperCase();
                Integer baseCount = 0;
                for (Integer curr : hexString.getChars()) {
                    Integer val;
                    if (curr >= 65) {
                        val = curr - 65 + 10;
                    } else {
                        val = curr - 48;
                    }
                    if ((val & 8) == 8 && controllingVal.size() > baseCount + 0) {
                        addDependencyEntry(dependencyMap, controllingVal[baseCount + 0], dependentRawValue);
                    }
                    if ((val & 4) == 4 && controllingVal.size() > baseCount + 1) {
                        addDependencyEntry(dependencyMap, controllingVal[baseCount + 1], dependentRawValue);
                    }
                    if ((val & 2) == 2 && controllingVal.size() > baseCount + 2) {
                        addDependencyEntry(dependencyMap, controllingVal[baseCount + 2], dependentRawValue);
                    }
                    if ((val & 1) == 1 && controllingVal.size() > baseCount + 3) {
                        addDependencyEntry(dependencyMap, controllingVal[baseCount + 3], dependentRawValue);
                    }
                    baseCount += 4;
                }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return dependencyMap;
    }
    /****************************************************************
* Method Name: addDependencyEntry
* Parameters: Map<String, Set<String>> dependencyMap, Schema.PicklistEntry controllingEntry, String dependentRawVal
* Description: Adds a dependent raw value to the set for a controlling raw value.
*****************************************************************/
    private static void addDependencyEntry(Map<String, Set<String>> dependencyMap, Schema.PicklistEntry controllingEntry, String dependentRawVal) {
        if (dependencyMap == null || controllingEntry == null || String.isBlank(dependentRawVal)) {
            return;
        }
        String controllingRawValue = htmlDecodePicklistValue(controllingEntry.getValue());
        if (String.isBlank(controllingRawValue) || !dependencyMap.containsKey(controllingRawValue)) {
            return;
        }
        dependencyMap.get(controllingRawValue).add(dependentRawVal);
    }
    /****************************************************************
* Method Name: extractEncodedValidForFromPicklistEntry
* Parameters: Schema.PicklistEntry picklistEntry
* Description: Extracts encoded validFor bitset from picklist entry JSON form.
*****************************************************************/
    private static String extractEncodedValidForFromPicklistEntry(Schema.PicklistEntry picklistEntry) {
        if (picklistEntry == null) {
            return null;
        }
        try {
            Map<String, Object> entryAsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(picklistEntry));
            if (entryAsMap != null && entryAsMap.containsKey('validFor') && entryAsMap.get('validFor') != null) {
                return String.valueOf(entryAsMap.get('validFor'));
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return null;
    }
    /****************************************************************
* Method Name: resolveControllingFldApi
* Parameters: String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal
* Description: Resolves controlling field API name for a dependent field via schema, metadata, then deterministic inference fallback.
*****************************************************************/
    private static String resolveControllingFldApi(String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal) {
        if (String.isBlank(dependentFldApi) || dependentFldDetails == null || picklistFldVal == null || !dependentFldDetails.containsKey('controllerValues')) {
            return null;
        }
        String controllingFieldFromSchema = resolveCntrFldFromSchema(dependentFldApi);
        if (!String.isBlank(controllingFieldFromSchema) && picklistFldVal.containsKey(controllingFieldFromSchema)) {
            return controllingFieldFromSchema;
        }
        String controllingFieldFromMetadata = extractControllingFldFromMdt(dependentFldApi, dependentFldDetails, picklistFldVal);
        if (!String.isBlank(controllingFieldFromMetadata)) {
            return controllingFieldFromMetadata;
        }
        return inferCntrFldByControllerIndexMap(dependentFldApi, dependentFldDetails, picklistFldVal);
    }
    /****************************************************************
* Method Name: resolveCntrFldFromSchema
* Parameters: String dependentFldApi
* Description: Resolves controlling field API name directly from schema metadata.
*****************************************************************/
    private static String resolveCntrFldFromSchema(String dependentFldApi) {
        if (String.isBlank(dependentFldApi)) {
            return null;
        }
        try {
            Map<String, Schema.SObjectField> fieldMap = getFieldMap('Core_MDF_Custom_Picklist__c');
            if (fieldMap == null || !fieldMap.containsKey(dependentFldApi)) {
                return null;
            }
            Schema.DescribeFieldResult dependentDescribe = getFldDesc('Core_MDF_Custom_Picklist__c', dependentFldApi);
            if (dependentDescribe == null || !dependentDescribe.isDependentPicklist()) {
                return null;
            }
            Schema.SObjectField controllerField = dependentDescribe.getController();
            if (controllerField == null) {
                return null;
            }
            Schema.DescribeFieldResult controllerDescribe = controllerField.getDescribe();
            return controllerDescribe == null ? null : controllerDescribe.getName();
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }
    /****************************************************************
* Method Name: inferCntrFldByControllerIndexMap
* Parameters: String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal
* Description: Infers controlling field by strict alignment of controllerValues indexes with candidate field value ordering.
*****************************************************************/
    private static String inferCntrFldByControllerIndexMap(String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal) {
        if (String.isBlank(dependentFldApi) || dependentFldDetails == null || picklistFldVal == null) {
            return null;
        }
        if (!dependentFldDetails.containsKey('controllerValues')) {
            return null;
        }
        Map<String, Object> controllerVal = (Map<String, Object>) dependentFldDetails.get('controllerValues');
        if (controllerVal == null || controllerVal.isEmpty()) {
            return null;
        }
        Integer expectedControllerKeyCount = 0;
        for (String controllerKey : controllerVal.keySet()) {
            if (String.isBlank(controllerKey)) {
                continue;
            }
            Object expectedIndexObj = controllerVal.get(controllerKey);
            Integer expectedIndex;
            try {
                expectedIndex = (Integer) expectedIndexObj;
            } catch (Exception ex) {
                try {
                    expectedIndex = Integer.valueOf(String.valueOf(expectedIndexObj));
                } catch (Exception ignoreEx) {
                    expectedIndex = null;
                }
            }
            if (expectedIndex != null) {
                expectedControllerKeyCount++;
            }
        }
        if (expectedControllerKeyCount == 0) {
            return null;
        }
        String bestFieldApiName;
        Integer bestStrictMatchCount = 0;
        Integer bestCoverageCount = 0;
        Boolean hasAmbiguousBestMatch = false;
        for (String candidateFldApi : picklistFldVal.keySet()) {
            if (candidateFldApi == dependentFldApi) {
                continue;
            }
            Map<String, Object> candidateFldDetails = (Map<String, Object>) picklistFldVal.get(candidateFldApi);
            if (candidateFldDetails == null || !candidateFldDetails.containsKey('values')) {
                continue;
            }
            List<Object> candidateValues = (List<Object>) candidateFldDetails.get('values');
            if (candidateValues == null || candidateValues.isEmpty()) {
                continue;
            }
            Map<String, Integer> candidateIndexByValue = new Map<String, Integer>();
            Integer idx = 0;
            for (Object candidateValueObj : candidateValues) {
                Map<String, Object> candidateValueDetails = (Map<String, Object>) candidateValueObj;
                if (candidateValueDetails != null && candidateValueDetails.containsKey('value')) {
                    String candidateValueNorm = String.valueOf(candidateValueDetails.get('value')).trim().toLowerCase();
                    if (!String.isBlank(candidateValueNorm) && !candidateIndexByValue.containsKey(candidateValueNorm)) {
                        candidateIndexByValue.put(candidateValueNorm, idx);
                    }
                }
                idx++;
            }
            Integer strictMatchCount = 0;
            Integer coverageCount = 0;
            for (String controllerKey : controllerVal.keySet()) {
                if (String.isBlank(controllerKey)) {
                    continue;
                }
                Integer expectedIndex;
                try {
                    expectedIndex = (Integer) controllerVal.get(controllerKey);
                } catch (Exception ex) {
                    try {
                        expectedIndex = Integer.valueOf(String.valueOf(controllerVal.get(controllerKey)));
                    } catch (Exception ignoreEx) {
                        expectedIndex = null;
                    }
                }
                if (expectedIndex == null) {
                    continue;
                }
                String controllerKeyNorm = controllerKey.trim().toLowerCase();
                if (candidateIndexByValue.containsKey(controllerKeyNorm)) {
                    coverageCount++;
                    if (candidateIndexByValue.get(controllerKeyNorm) == expectedIndex) {
                        strictMatchCount++;
                    }
                }
            }
            if (strictMatchCount == 0) {
                continue;
            }
            if (strictMatchCount > bestStrictMatchCount ||
                (strictMatchCount == bestStrictMatchCount && coverageCount > bestCoverageCount)) {
                    bestStrictMatchCount = strictMatchCount;
                    bestCoverageCount = coverageCount;
                    bestFieldApiName = candidateFldApi;
                    hasAmbiguousBestMatch = false;
                } else if (strictMatchCount == bestStrictMatchCount && coverageCount == bestCoverageCount) {
                    hasAmbiguousBestMatch = true;
                }
        }
        if (String.isBlank(bestFieldApiName) || hasAmbiguousBestMatch) {
            return null;
        }
        Integer minCoverageRequired = Math.min(2, expectedControllerKeyCount);
        if (bestCoverageCount < minCoverageRequired) {
            return null;
        }
        if (bestStrictMatchCount != bestCoverageCount) {
            return null;
        }
        return bestFieldApiName;
    }
    /****************************************************************
* Method Name: extractControllingFldFromMdt
* Parameters: String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistFldVal
* Description: Extracts controlling field API name from controllingFields metadata present in UI API payload details.
*****************************************************************/ 
    private static String extractControllingFldFromMdt(String dependentFldApi, Map<String, Object> dependentFldDetails, Map<String, Object> picklistVal) {
        if (String.isBlank(dependentFldApi) || dependentFldDetails == null || picklistVal == null) {
            return null;
        }
        if (!dependentFldDetails.containsKey('controllingFields')) {
            return null;
        }
        Object controllingFldsObj = dependentFldDetails.get('controllingFields');
        if (controllingFldsObj == null) {
            return null;
        }
        if (controllingFldsObj instanceof List<Object>) {
            List<Object> controllingFlds = (List<Object>) controllingFldsObj;
            for (Object fieldObj : controllingFlds) {
                String fieldApiName = fieldObj == null ? null : String.valueOf(fieldObj).trim();
                if (String.isBlank(fieldApiName) || fieldApiName == dependentFldApi) {
                    continue;
                }
                if (picklistVal.containsKey(fieldApiName)) {
                    return fieldApiName;
                }
            }
            return null;
        }
        String singleFieldApiName = String.valueOf(controllingFldsObj).trim();
        if (String.isBlank(singleFieldApiName) || singleFieldApiName == dependentFldApi) {
            return null;
        }
        return picklistVal.containsKey(singleFieldApiName) ? singleFieldApiName : null;
    }
    /****************************************************************
* Method Name: buildControllerIndexToDisplayValueMap
* Parameters: Map<String, Object> cntrFldDetails, Boolean useFldLabels
* Description: Builds index-to-display mapping for active controlling values.
*****************************************************************/
    private static Map<Integer, String> buildControllerIndexToDisplayValueMap(Map<String, Object> cntrFldDetails, Boolean useFldLabels) {
        Map<Integer, String> controllingDisplayByIndex = new Map<Integer, String>();
        if (cntrFldDetails == null || !cntrFldDetails.containsKey('values')) {
            return controllingDisplayByIndex;
        }
        List<Object> controllingValues = (List<Object>) cntrFldDetails.get('values');
        Integer idx = 0;
        for (Object controllingValueObj : controllingValues) {
            Map<String, Object> controllingValueDetails = (Map<String, Object>) controllingValueObj;
            if (controllingValueDetails == null || !controllingValueDetails.containsKey('value')) {
                idx++;
                continue;
            }
            Object activeObj = controllingValueDetails.get('active');
            Boolean isActive = activeObj == null ? true : (Boolean) activeObj;
            if (!isActive) {
                idx++;
                continue;
            }
            String displayValue = getPicklistDisplayVal(controllingValueDetails, useFldLabels);
            if (!String.isBlank(displayValue)) {
                controllingDisplayByIndex.put(idx, displayValue);
            }
            idx++;
        }
        return controllingDisplayByIndex;
    }
    /****************************************************************
* Method Name: buildControllerIndexToDisplayValMapFromCntrVal
* Parameters: Map<String, Object> controllerVal, Map<String, Object> controllingFldDetails, Boolean useFldLabels
* Description: Builds controller-index to display-value mapping using dependent controllerValues keys plus controlling field metadata.
*****************************************************************/
    private static Map<Integer, String> buildControllerIndexToDisplayValMapFromCntrVal(Map<String, Object> controllerVal, Map<String, Object> controllingFldDetails, Boolean useFldLabels) {
        Map<Integer, String> controllingDisplayByIndex = new Map<Integer, String>();
        if (controllerVal == null || controllerVal.isEmpty() || controllingFldDetails == null || !controllingFldDetails.containsKey('values')) {
            return controllingDisplayByIndex;
        }
        Map<String, String> displayByRaw = new Map<String, String>();
        List<Object> controllingValues = (List<Object>) controllingFldDetails.get('values');
        for (Object controllingValueObj : controllingValues) {
            Map<String, Object> controllingValueDetails = (Map<String, Object>) controllingValueObj;
            if (controllingValueDetails == null || !controllingValueDetails.containsKey('value')) {
                continue;
            }
            Object activeObj = controllingValueDetails.get('active');
            Boolean isActive = activeObj == null ? true : (Boolean) activeObj;
            if (!isActive) {
                continue;
            }
            String rawValue = getPicklistRawVal(controllingValueDetails);
            if (String.isBlank(rawValue)) {
                continue;
            }
            String displayValue = getPicklistDisplayVal(controllingValueDetails, useFldLabels);
            displayByRaw.put(rawValue.trim().toLowerCase(), displayValue);
        }
        for (String controllerKey : controllerVal.keySet()) {
            if (String.isBlank(controllerKey)) {
                continue;
            }
            Integer controllerIndex;
            try {
                controllerIndex = (Integer) controllerVal.get(controllerKey);
            } catch (Exception ex) {
                try {
                    controllerIndex = Integer.valueOf(String.valueOf(controllerVal.get(controllerKey)));
                } catch (Exception ignoreEx) {
                    controllerIndex = null;
                }
            }
            if (controllerIndex == null) {
                continue;
            }
            String keyNorm = controllerKey.trim().toLowerCase();
            if (displayByRaw.containsKey(keyNorm)) {
                controllingDisplayByIndex.put(controllerIndex, displayByRaw.get(keyNorm));
                continue;
            }
            String decodedKey = htmlDecodePicklistValue(controllerKey);
            if (!String.isBlank(decodedKey)) {
                controllingDisplayByIndex.put(controllerIndex, decodedKey);
            }
        }
        return controllingDisplayByIndex;
    }
    /****************************************************************
* Method Name: injectDepIntoAttr
* Parameters: Map<String, List<String>> attributesByFld, Map<String, Object> dependenciesByFld, Map<String, String> fldLabels
* Description: Shapes attributes keyed by field label (or API name when no label is supplied) with technicalName always holding the field API name; dependentOn is omitted when the controlling field is the Budget Type / Focus Area.
*****************************************************************/
    private static Map<String, Object> injectDepIntoAttr(Map<String, List<String>> attributesByFld, Map<String, Object> dependenciesByFld, Map<String, String> fldLabels) {
        Map<String, Object> attributes = new Map<String, Object>();
        if (attributesByFld == null || attributesByFld.isEmpty()) {
            return attributes;
        }
        for (String fieldApiName : sortStringKeys(new List<String>(attributesByFld.keySet()))) {
            List<String> values = attributesByFld.get(fieldApiName);
            Map<String, Object> fieldDetails = new Map<String, Object>{
                'values' => values == null ? new List<String>() : values,
                'technicalName' => fieldApiName
            };
            Map<String, Object> depMeta = dependenciesByFld == null ? null : (Map<String, Object>) dependenciesByFld.get(fieldApiName);
            if (depMeta != null && depMeta.containsKey('dependentOn') && depMeta.containsKey('dependentValues')) {
                String dependentOnApi = String.valueOf(depMeta.get('dependentOn'));
                if (!CTRL_FLD_API.equalsIgnoreCase(dependentOnApi)) {
                    fieldDetails.put('dependentOn', fldLabels.containsKey(dependentOnApi) ? fldLabels.get(dependentOnApi) : dependentOnApi);
                }
                fieldDetails.put('dependentValues', sortMapKeysAscending((Map<String, Object>) depMeta.get('dependentValues')));
            }
            String attrKey = fldLabels.containsKey(fieldApiName) ? fldLabels.get(fieldApiName) : fieldApiName;
            if (attributes.containsKey(attrKey)) {
                attrKey = attrKey + ' (' + fieldApiName + ')';
            }
            attributes.put(attrKey, fieldDetails);
        }
        return attributes;
    }
    /****************************************************************
* Method Name: injectDepIntoAttrByRecType
* Parameters: Map<String, Object> attributesByRecType, Map<String, Object> dependenciesByRecType, Map<String, String> fldLabels
* Description: Applies attribute shaping independently for each record type response branch.
*****************************************************************/
    private static Map<String, Object> injectDepIntoAttrByRecType(Map<String, Object> attributesByRecType, Map<String, Object> dependenciesByRecType, Map<String, String> fldLabels) {
        Map<String, Object> enrichedByRecordType = new Map<String, Object>();
        if (attributesByRecType == null || attributesByRecType.isEmpty()) {
            return enrichedByRecordType;
        }
        for (String recordTypeName : attributesByRecType.keySet()) {
            Map<String, List<String>> attrs = (Map<String, List<String>>) attributesByRecType.get(recordTypeName);
            Map<String, Object> deps = (dependenciesByRecType != null && dependenciesByRecType.containsKey(recordTypeName))
                ? (Map<String, Object>) dependenciesByRecType.get(recordTypeName)
                : new Map<String, Object>();
            enrichedByRecordType.put(recordTypeName, injectDepIntoAttr(attrs, deps, fldLabels));
        }
        return enrichedByRecordType;
    }
    /****************************************************************
* Method Name: addCtrlFldDependencies
* Parameters: Map<String, Object> dependencyByFld, Map<String, Object> ctrlDependencyByFld, Set<String> returnedFldApi
* Description: Adds dependencies on the controlling field for fields that remain in the response.
*****************************************************************/
    private static void addCtrlFldDependencies(Map<String, Object> dependencyByFld, Map<String, Object> ctrlDependencyByFld, Set<String> returnedFldApi) {
        if (dependencyByFld == null || ctrlDependencyByFld == null || returnedFldApi == null) {
            return;
        }
        for (String fldApi : ctrlDependencyByFld.keySet()) {
            if (returnedFldApi.contains(fldApi)) {
                dependencyByFld.put(fldApi, ctrlDependencyByFld.get(fldApi));
            }
        }
    }
    /****************************************************************
* Method Name: buildCtrlFldDependency
* Parameters: Map<String, Object> fldDetails, Map<String, Object> payload, List<Map<String, Object>> eligibleValDetails, Integer cntrFldValIndex, Set<String> allowedCtrlVals, Boolean useFldLabels
* Description: Maps each controlling field value (Budget Type / Focus Area) to the eligible values of a dependent field. When a controlling value was requested only that value is returned.
*****************************************************************/
    private static Map<String, Object> buildCtrlFldDependency(Map<String, Object> fldDetails, Map<String, Object> payload, List<Map<String, Object>> eligibleValDetails, Integer cntrFldValIndex, Set<String> allowedCtrlVals, Boolean useFldLabels) {
        if (fldDetails == null || eligibleValDetails == null || !isDependentOnCntrFld(fldDetails, payload, CTRL_FLD_API)) {
            return null;
        }
        Map<String, Object> controllerVal = (Map<String, Object>) fldDetails.get('controllerValues');
        Map<String, Object> picklistFldVal = (Map<String, Object>) payload.get('picklistFieldValues');
        Map<Integer, String> ctrlDisplayByIndex = buildControllerIndexToDisplayValMapFromCntrVal(controllerVal, (Map<String, Object>) picklistFldVal.get(CTRL_FLD_API), useFldLabels);
        Map<Integer, String> ctrlRawByIndex = new Map<Integer, String>();
        for (String controllerKey : controllerVal.keySet()) {
            Integer ctrlIndex = toInteger(controllerVal.get(controllerKey));
            if (ctrlIndex != null) {
                ctrlRawByIndex.put(ctrlIndex, htmlDecodePicklistValue(controllerKey));
            }
        }
        Map<String, List<String>> valByCtrlVal = new Map<String, List<String>>();
        for (Map<String, Object> valueDetails : eligibleValDetails) {
            String dependentVal = getPicklistDisplayVal(valueDetails, useFldLabels);
            List<Object> validForList = (List<Object>) valueDetails.get('validFor');
            if (String.isBlank(dependentVal) || validForList == null || validForList.isEmpty()) {
                continue;
            }
            for (Object validForObj : validForList) {
                Integer ctrlIndex = toInteger(validForObj);
                if (ctrlIndex == null || (cntrFldValIndex != null && ctrlIndex != cntrFldValIndex)) {
                    continue;
                }
                String ctrlRaw = ctrlRawByIndex.get(ctrlIndex);
                String ctrlNm = ctrlDisplayByIndex.get(ctrlIndex);
                if (String.isBlank(ctrlRaw) || String.isBlank(ctrlNm) || (!allowedCtrlVals.isEmpty() && !allowedCtrlVals.contains(ctrlRaw.trim().toLowerCase()))) {
                    continue;
                }
                if (!valByCtrlVal.containsKey(ctrlNm)) {
                    valByCtrlVal.put(ctrlNm, new List<String>());
                }
                valByCtrlVal.get(ctrlNm).add(dependentVal);
            }
        }
        if (valByCtrlVal.isEmpty()) {
            return null;
        }
        Map<String, Object> dependentValues = new Map<String, Object>();
        for (String ctrlNm : valByCtrlVal.keySet()) {
            dependentValues.put(ctrlNm, getSortedDistinctVal(valByCtrlVal.get(ctrlNm)));
        }
        return new Map<String, Object>{'dependentOn' => CTRL_FLD_API, 'dependentValues' => dependentValues};
    }
    /****************************************************************
* Method Name: toInteger
* Parameters: Object value
* Description: Converts a deserialized JSON number to Integer, returning null when it cannot be converted.
*****************************************************************/
    private static Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Integer) {
            return (Integer) value;
        }
        try {
            return Integer.valueOf(String.valueOf(value));
        } catch (Exception ex) {
            return null;
        }
    }
    /****************************************************************
* Method Name: getLegacyBudgetTypeSet
* Parameters: None
* Description: Returns the lower-cased legacy budget types (e.g. 'ccf 1.0') that are excluded from API output.
*****************************************************************/
    private static Set<String> getLegacyBudgetTypeSet() {
        Set<String> legacySet = new Set<String>();
        String legacyValues = System.Label.Core_MDF_LegacyRestricBudgetTypes;
        if (String.isBlank(legacyValues)) {
            return legacySet;
        }
        for (String entry : legacyValues.split(',')) {
            if (!String.isBlank(entry)) {
                legacySet.add(entry.trim().toLowerCase());
            }
        }
        return legacySet;
    }
    /****************************************************************
* Method Name: resolveCtrlFldDisplayNm
* Parameters: String canonicalProg
* Description: Returns 'Focus Area' for programs listed in label Core_MDF_IPA_Program_Name, otherwise 'Budget Type'.
*****************************************************************/
    private static String resolveCtrlFldDisplayNm(String canonicalProg) {
        String focusAreaProgs = System.Label.Core_MDF_IPA_Program_Name;
        if (!String.isBlank(canonicalProg) && !String.isBlank(focusAreaProgs)) {
            for (String entry : focusAreaProgs.split(',')) {
                if (entry.trim().equalsIgnoreCase(canonicalProg.trim())) {
                    return CTRL_FLD_FOCUS_AREA;
                }
            }
        }
        return CTRL_FLD_BUDGET_TYPE;
    }
    
    private class AttributeFieldDetails {
        public List<String> values;
        public String dependentOn;
        public Map<String, Object> dependentValues;
    }
    
    private class RecTypePicklistResult {
        public Map<String, List<String>> valuesByField = new Map<String, List<String>>();
        public Map<String, Object> dependenciesByField = new Map<String, Object>();
        public Map<String, Object> ctrlDependenciesByField = new Map<String, Object>();
    }
    /****************************************************************
* Method Name: serializeWithSortedMapKeys
* Parameters: Object value, Boolean isNormalizedValue
* Description: Normalizes and serializes data with deterministic key ordering.
*****************************************************************/    
    private static String serializeWithSortedMapKeys(Object value, Boolean isNormalizedValue) {
        if (value == null) {
            return 'null';
        }
        try {
            Object workingValue = value;
            if (!isNormalizedValue) {
                workingValue = JSON.deserializeUntyped(JSON.serialize(value));
            }
            if (workingValue instanceof Map<String, Object>) {
                Map<String, Object> valueMap = (Map<String, Object>) workingValue;
                if (isAttributeFieldDetailsShape(valueMap)) {
                    List<String> orderedParts = new List<String>();
                    if (valueMap.containsKey('values')) {
                        orderedParts.add('"values":' + serializeWithSortedMapKeys(valueMap.get('values'), true));
                    }
                    if (valueMap.containsKey('dependentOn')) {
                        orderedParts.add('"dependentOn":' + serializeWithSortedMapKeys(valueMap.get('dependentOn'), true));
                    }
                    if (valueMap.containsKey('dependentValues')) {
                        orderedParts.add('"dependentValues":' + serializeWithSortedMapKeys(valueMap.get('dependentValues'), true));
                    }
                    for (String key : sortStringKeys(new List<String>(valueMap.keySet()))) {
                        if (key != 'values' && key != 'dependentOn' && key != 'dependentValues') {
                            orderedParts.add(JSON.serialize(key) + ':' + serializeWithSortedMapKeys(valueMap.get(key), true));
                        }
                    }
                    return '{' + String.join(orderedParts, ',') + '}';
                }
                List<String> sortedKeys = sortStringKeys(new List<String>(valueMap.keySet()));
                List<String> parts = new List<String>();
                for (String key : sortedKeys) {
                    parts.add(JSON.serialize(key) + ':' + serializeWithSortedMapKeys(valueMap.get(key), true));
                }
                return '{' + String.join(parts, ',') + '}';
            }
            if (workingValue instanceof List<Object>) {
                List<Object> valueList = (List<Object>) workingValue;
                List<String> parts = new List<String>();
                for (Object entry : valueList) {
                    parts.add(serializeWithSortedMapKeys(entry, true));
                }
                return '[' + String.join(parts, ',') + ']';
            }
            return JSON.serialize(workingValue);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return JSON.serialize(value);
        }
    }    
    /****************************************************************
* Method Name: isAttributeFieldDetailsShape
* Parameters: Map<String, Object> valueMap
* Description: Identifies attribute field detail objects used for ordered serialization.
*****************************************************************/
    private static Boolean isAttributeFieldDetailsShape(Map<String, Object> valueMap) {
        if (valueMap == null || valueMap.isEmpty()) {
            return false;
        }
        if (!valueMap.containsKey('values')) {
            return false;
        }
        if (valueMap.containsKey('dependentOn')) {
            return valueMap.containsKey('dependentValues');
        }
        return true;
    }
    /****************************************************************
* Method Name: sortStringKeys
* Parameters: List<String> keys
* Description: Sorts keys alphabetically in a case-insensitive deterministic order.
*****************************************************************/
    private static List<String> sortStringKeys(List<String> keys) {
        if (keys == null || keys.isEmpty()) {
            return new List<String>();
        }
        Map<String, List<String>> lowerToOriginalKeys = new Map<String, List<String>>();
        for (String key : keys) {
            if (key == null) {
                continue;
            }
            String lower = key.toLowerCase();
            if (!lowerToOriginalKeys.containsKey(lower)) {
                lowerToOriginalKeys.put(lower, new List<String>());
            }
            lowerToOriginalKeys.get(lower).add(key);
        }
        List<String> sortedLowerKeys = new List<String>(lowerToOriginalKeys.keySet());
        sortedLowerKeys.sort();
        List<String> sortedKeys = new List<String>();
        for (String lowerKey : sortedLowerKeys) {
            List<String> originals = lowerToOriginalKeys.get(lowerKey);
            originals.sort();
            sortedKeys.addAll(originals);
        }
        return sortedKeys;
    }
    /****************************************************************
* Method Name: sortMapKeysAscending
* Parameters: Map<String, Object> inputMap
* Description: Returns a map with keys inserted in case-insensitive sorted order.
*****************************************************************/
    private static Map<String, Object> sortMapKeysAscending(Map<String, Object> inputMap) {
        Map<String, Object> sortedMap = new Map<String, Object>();
        if (inputMap == null || inputMap.isEmpty()) {
            return sortedMap;
        }
        Map<String, List<String>> lowerToOriginalKeys = new Map<String, List<String>>();
        for (String key : inputMap.keySet()) {
            if (String.isBlank(key)) {
                continue;
            }
            String lower = key.toLowerCase();
            if (!lowerToOriginalKeys.containsKey(lower)) {
                lowerToOriginalKeys.put(lower, new List<String>());
            }
            lowerToOriginalKeys.get(lower).add(key);
        }
        List<String> sortedLowerKeys = new List<String>(lowerToOriginalKeys.keySet());
        sortedLowerKeys.sort();
        for (String lowerKey : sortedLowerKeys) {
            List<String> originalKeys = lowerToOriginalKeys.get(lowerKey);
            originalKeys.sort();
            for (String originalKey : originalKeys) {
                sortedMap.put(originalKey, inputMap.get(originalKey));
            }
        }
        return sortedMap;
    }
}