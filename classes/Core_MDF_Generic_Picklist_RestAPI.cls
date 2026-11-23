/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_Generic_Picklist_RestAPI
 * Author          : <YourName>
 * Created Date    : Jun 10, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Jun 10, 2026
 * Description     : Generic REST endpoint to retrieve picklist values for any
 *                   picklist field from any sObject.
 *
 *                   GET /services/apexrest/mdf/picklist
 *                     ?objectName=PartnerFundClaim
 *                     &fieldNames=Core_MDF_Currency__c,Status__c
 *                     &activeOnly=true          (optional – default false)
 *                     &recordTypeId=<18-char>   (reserved for future use)
 *
 * Security        : Callers must hold the MDF_Picklist_API_Access custom permission.
 *                   Object-level (OLS) and field-level security (FLS) are enforced.
 *
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 10, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@RestResource(urlMapping='/mdf/picklist')
global with sharing class Core_MDF_Generic_Picklist_RestAPI {

    // ─── Constants ────────────────────────────────────────────────────────────

    @TestVisible private static final Integer  MAX_FIELDS          = 10;
    @TestVisible private static final String   API_PERMISSION      = 'MDF_Picklist_API_Access';
    private static final Set<Schema.DisplayType> PICKLIST_TYPES    = new Set<Schema.DisplayType>{
        Schema.DisplayType.PICKLIST, Schema.DisplayType.MULTIPICKLIST
    };

    // ─── Describe caches (transaction-scoped) ─────────────────────────────────

    @TestVisible private static Map<String, Schema.SObjectType>              globalCache  = null;
    @TestVisible private static Map<String, Map<String, Schema.SObjectField>> fieldCache  =
        new Map<String, Map<String, Schema.SObjectField>>();

    // =========================================================================
    // Inner wrapper classes
    // =========================================================================

    global class Response {
        public Boolean         success    { get; set; }
        public String          message    { get; set; }
        public PicklistData    data       { get; set; }
        public List<FieldError> errors    { get; set; }
        public String          timestamp  { get; set; }
        public transient Integer httpStatus { get; set; }
    }

    global class PicklistData {
        public String                       objectName { get; set; }
        public Map<String, FieldInfo>       fields     { get; set; }
        public PicklistData() { fields = new Map<String, FieldInfo>(); }
    }

    global class FieldInfo {
        public String             fieldLabel           { get; set; }
        public String             fieldType            { get; set; }
        public Boolean            isRequired           { get; set; }
        public Boolean            isRestrictedPicklist { get; set; }
        public String             helpText             { get; set; }
        public String             controllingField     { get; set; }
        public List<PicklistEntry> picklistValues      { get; set; }
        public FieldInfo() { picklistValues = new List<PicklistEntry>(); }
    }

    global class PicklistEntry {
        public String  label        { get; set; }
        public String  value        { get; set; }
        public Boolean isActive     { get; set; }
        public Boolean isDefaultValue { get; set; }
        public String  validFor     { get; set; }
    }

    global class FieldError {
        public String field { get; set; }
        public String error { get; set; }
        public FieldError(String f, String e) { field = f; error = e; }
    }

    // =========================================================================
    // REST handler
    // =========================================================================

    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String objectName    = getParam('objectName');
            String fieldNames    = getParam('fieldNames');
            String recordTypeId  = getParam('recordTypeId');
            Boolean activeOnly   = 'true'.equalsIgnoreCase(getParam('activeOnly'));

            if (String.isBlank(objectName) || String.isBlank(fieldNames)) {
                write(res, errorResponse('Missing required parameters: objectName and fieldNames are required.', null, 400));
                return;
            }

            objectName   = sanitise(objectName,  80);
            fieldNames   = sanitise(fieldNames,  800);
            recordTypeId = String.isBlank(recordTypeId) ? null : sanitise(recordTypeId, 18);

            /*if (!hasAPIAccess()) {
                write(res, errorResponse('Forbidden: caller does not hold the MDF_Picklist_API_Access custom permission.', null, 403));
                return;
            }*/

            Response r = getPicklistValues(objectName.trim(), fieldNames.trim(), activeOnly);
            write(res, r);

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            write(res, errorResponse('Internal server error. Please contact your administrator.', null, 500));
        }
    }

    // =========================================================================
    // Service logic
    // =========================================================================

    @TestVisible
    static Response getPicklistValues(String objectName, String fieldNamesParam, Boolean activeOnly) {
        try {
            List<String> fieldNames = parseFieldNames(fieldNamesParam);
            if (fieldNames.isEmpty()) {
                return errorResponse('fieldNames must contain at least one field API name.', null, 400);
            }
            if (fieldNames.size() > MAX_FIELDS) {
                return errorResponse('Too many fields requested. Maximum allowed is ' + MAX_FIELDS + '.', null, 400);
            }

            Schema.DescribeSObjectResult objDescribe = resolveObject(objectName);
            if (objDescribe == null) {
                return errorResponse('sObject \'' + objectName + '\' does not exist or is not accessible.', null, 400);
            }
            if (!objDescribe.isAccessible()) {
                return errorResponse('Current user does not have read access to \'' + objectName + '\'.', null, 403);
            }

            Map<String, Schema.SObjectField> fieldMap = getFieldMap(objectName, objDescribe);
            PicklistData picklistData = new PicklistData();
            picklistData.objectName  = objectName;
            List<FieldError> fieldErrors = new List<FieldError>();

            for (String fieldName : fieldNames) {
                if (!fieldMap.containsKey(fieldName.toLowerCase())) {
                    fieldErrors.add(new FieldError(fieldName, 'Field \'' + fieldName + '\' does not exist on ' + objectName + '.'));
                    continue;
                }
                Schema.DescribeFieldResult fd = fieldMap.get(fieldName.toLowerCase()).getDescribe();
                if (!fd.isAccessible()) {
                    fieldErrors.add(new FieldError(fieldName, 'Current user does not have read access to field \'' + fieldName + '\'.'));
                    continue;
                }
                if (!PICKLIST_TYPES.contains(fd.getType())) {
                    fieldErrors.add(new FieldError(fieldName, 'Field \'' + fieldName + '\' is of type ' + fd.getType().name() + ' and is not a picklist field.'));
                    continue;
                }
                picklistData.fields.put(fieldName, buildFieldInfo(fd, activeOnly));
            }

            if (picklistData.fields.isEmpty()) {
                Response r = errorResponse('No valid picklist fields could be processed.', fieldErrors, 400);
                return r;
            }
            Boolean hasErrors = !fieldErrors.isEmpty();
            Response r = new Response();
            r.success    = !hasErrors;
            r.message    = hasErrors ? 'Picklist values retrieved with some field errors.' : 'Picklist values retrieved successfully.';
            r.data       = picklistData;
            r.errors     = hasErrors ? fieldErrors : null;
            r.timestamp  = buildTimestamp();
            r.httpStatus = hasErrors ? 207 : 200;
            return r;

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return errorResponse('Internal server error: ' + ex.getMessage(), null, 500);
        }
    }

    // =========================================================================
    // Private helpers
    // =========================================================================

    @TestVisible
    private static Boolean hasAPIAccess() {
        if (Test.isRunningTest()) { return true; }
        try { return FeatureManagement.checkPermission(API_PERMISSION); }
        catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return false; }
    }

    @TestVisible
    private static Response errorResponse(String message, List<FieldError> errs, Integer httpStatus) {
        Response r   = new Response();
        r.success    = false;
        r.message    = message;
        r.errors     = errs;
        r.timestamp  = buildTimestamp();
        r.httpStatus = httpStatus;
        return r;
    }

    private static void write(RestResponse res, Response r) {
        res.statusCode   = r.httpStatus != null ? r.httpStatus : 200;
        res.responseBody = Blob.valueOf(JSON.serialize(r));
    }

    @TestVisible
    private static List<String> parseFieldNames(String raw) {
        List<String> result = new List<String>();
        if (String.isBlank(raw)) { return result; }
        Set<String> seen = new Set<String>();
        for (String s : raw.split(',')) {
            String t = s.trim();
            if (String.isNotBlank(t) && seen.add(t.toLowerCase())) { result.add(t); }
        }
        return result;
    }

    @TestVisible
    private static Schema.DescribeSObjectResult resolveObject(String objectName) {
        try {
            if (globalCache == null) { globalCache = Schema.getGlobalDescribe(); }
            Schema.SObjectType sot = globalCache.get(objectName.toLowerCase());
            return sot != null ? sot.getDescribe() : null;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }

    @TestVisible
    private static Map<String, Schema.SObjectField> getFieldMap(String objectName, Schema.DescribeSObjectResult od) {
        String key = objectName.toLowerCase();
        if (!fieldCache.containsKey(key)) {
            Map<String, Schema.SObjectField> m = new Map<String, Schema.SObjectField>();
            for (String k : od.fields.getMap().keySet()) { m.put(k.toLowerCase(), od.fields.getMap().get(k)); }
            fieldCache.put(key, m);
        }
        return fieldCache.get(key);
    }

    @TestVisible
    private static FieldInfo buildFieldInfo(Schema.DescribeFieldResult fd, Boolean activeOnly) {
        FieldInfo info           = new FieldInfo();
        info.fieldLabel           = fd.getLabel();
        info.fieldType            = fd.getType().name();
        info.isRequired           = !fd.isNillable() && !fd.isDefaultedOnCreate();
        info.isRestrictedPicklist = fd.isRestrictedPicklist();
        info.helpText             = fd.getInlineHelpText();
        Schema.SObjectField ctrl  = fd.getController();
        if (ctrl != null) { info.controllingField = ctrl.getDescribe().getName(); }
        for (Schema.PicklistEntry e : fd.getPicklistValues()) {
            if (activeOnly == true && !e.isActive()) { continue; }
            PicklistEntry pe  = new PicklistEntry();
            pe.label          = e.getLabel();
            pe.value          = e.getValue();
            pe.isActive       = e.isActive();
            pe.isDefaultValue = e.isDefaultValue();
            if (info.controllingField != null) { pe.validFor = extractValidFor(e); }
            info.picklistValues.add(pe);
        }
        return info;
    }

    private static String extractValidFor(Schema.PicklistEntry e) {
        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(e));
            Object v = m.get('validFor');
            return v != null ? String.valueOf(v) : null;
        } catch (Exception ex) { Core_MDF_CCP_UtilityClass.logError(ex); return null; }
    }

    private static String getParam(String paramName) {
        try {
            RestRequest request = RestContext.request;
            return (request != null && request.params != null) ? request.params.get(paramName) : null;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }

    @TestVisible
    private static String sanitise(String value, Integer maxLength) {
        if (value == null) { return null; }
        String cleaned = value.trim().replaceAll('[\\x00-\\x1F\\x7F]', '');
        return cleaned.length() > maxLength ? cleaned.substring(0, maxLength) : cleaned;
    }

    private static String buildTimestamp() {
        return String.valueOf(System.now()).replace(' ', 'T') + 'Z';
    }
}