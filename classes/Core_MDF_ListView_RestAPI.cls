/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_ListView_RestAPI
 * Description     : Report-style REST API returning a filtered list of records for a
 *                   caller-specified object and program (POST body: objectName, programName,
 *                   filters, filterLogic, sortBy and sortOrder).
 *
 *                   Flow: parse payload -> resolve object -> load field configuration
 *                         -> validate filters/sort -> build bind-safe SOQL
 *                         -> query in USER_MODE -> key records by label or API name
 *                         -> respond -> log.
 *
 *                   Security notes:
 *                   - Filter/sort/response fields come only from the configuration
 *                     allowlist and are re-validated (including FLS) against the live
 *                     describe; client field names are never placed in SOQL verbatim.
 *                   - Filter values are always bind variables (no SOQL injection).
 *                   - The query runs with AccessLevel.USER_MODE (FLS, CRUD, sharing).
 * ----------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/v1.0/partnercenter/list/*')
global with sharing class Core_MDF_ListView_RestAPI {

    private static final Integer MAX_FIELD_PATH_DEPTH = 5;  // Maximum segments in a field path (relationship hops + field).
    // filterLogic tokenizer: whitespace runs, numbers, words and parentheses.
    private static final Pattern FILTER_LOGIC_TOKEN_PATTERN = Pattern.compile('\\s+|\\d+|[^\\s()]+|[()]');
    private static final Pattern FILTER_LOGIC_WHITESPACE_PATTERN = Pattern.compile('\\s');   // Single whitespace token.
    private static final Pattern FILTER_LOGIC_DIGIT_TOKEN_PATTERN = Pattern.compile('\\d+'); // Filter number token.
    // Caller operator symbols/phrases -> configured operator tokens.
    private static final Map<String, String> CONFIGURED_OPERATOR_ALIASES = new Map<String, String>{
        '=' => 'EQ', 'EQUAL TO' => 'EQ', 'EQ' => 'EQ',
        '!=' => 'NE', 'NOT EQUAL TO' => 'NE', 'NE' => 'NE',
        '>' => 'GT', 'GREATER THAN' => 'GT', 'GT' => 'GT',
        '>=' => 'GE', 'GREATER THAN EQUAL TO' => 'GE', 'GREATER THAN OR EQUAL TO' => 'GE', 'GE' => 'GE',
        '<' => 'LT', 'LESS THAN' => 'LT', 'LT' => 'LT',
        '<=' => 'LE', 'LESS THAN EQUAL TO' => 'LE', 'LESS THAN OR EQUAL TO' => 'LE', 'LE' => 'LE',
        'INCLUDES' => 'INCLUDE', 'INCLUDE' => 'INCLUDE',
        'EXCLUDES' => 'EXCLUDE', 'EXCLUDE' => 'EXCLUDE',
        'LIKE' => 'CONTAIN', 'CONTAIN' => 'CONTAIN',
        'NOT LIKE' => 'NOT CONTAIN', 'NOT CONTAIN' => 'NOT CONTAIN'
    };
    // Configured operator tokens -> SOQL operators.
    private static final Map<String, String> SOQL_OPERATOR_BY_TOKEN = new Map<String, String>{
        'EQ' => '=', 'NE' => '!=', 'GT' => '>', 'GE' => '>=',
        'LT' => '<', 'LE' => '<=', 'INCLUDE' => 'INCLUDES',
        'EXCLUDE' => 'EXCLUDES', 'CONTAIN' => 'LIKE', 'NOT CONTAIN' => 'LIKE'
    };
    // Success detail keys written first, in this order; any other keys follow.
    private static final List<String> ORDERED_DETAIL_KEYS = new List<String>{
        'informationMessage', 'allowedFilterFields', 'recordCount', 'records'
    };

    /*
     * 1. REQUEST FLOW
     */

    /** Parses, validates, executes, responds to and logs a list request. */
    @HttpPost
    global static void getList() {
        Datetime entryTime = System.now();
        ListResponseTracker tracker = new ListResponseTracker();  // Final status, used by logging.
        List<String> logErrors;
        String requestBody;

        try {
            requestBody = RestContext.request?.requestBody?.toString();
            Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest listRequest;
            try {
                listRequest = Core_MDF_ListView_RestAPI_Wrapper.parse(requestBody);
            } catch (Exception parseEx) {
                sendError(tracker, Core_MDF_CCP_ConstantClass.CODE_7010_INVALID_PAYLOAD, null);
                return;
            }

            // objectName is mandatory and must be a queryable object.
            if (String.isBlank(listRequest.objectName)) {
                sendError(tracker, Core_MDF_CCP_ConstantClass.CODE_7032_OBJECTNAME_NOT_FOUND, new Map<String, Object>{ 'field' => 'objectName' });
                return;
            }
            // programName is mandatory.
            if (String.isBlank(listRequest.programName)) {
                sendError(tracker, Core_MDF_CCP_ConstantClass.CODE_7033_PROGRAMNAME_NOT_FOUND, new Map<String, Object>{ 'field' => 'programName' });
                return;
            }
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(listRequest.objectName.trim().toLowerCase());
            if (objectType == null || !objectType.getDescribe().isQueryable()) {
                sendError(tracker, Core_MDF_CCP_ConstantClass.CODE_7013_INVALID_OBJECT, new Map<String, Object>{ 'object' => listRequest.objectName.trim() });
                return;
            }

            // Canonical API name from describe is used in SOQL and the configuration lookup.
            String objectApiName = objectType.getDescribe().getName();
            Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig =
                Core_MDF_CCP_RestAPI_Utility.loadFieldConfiguration(
                    objectApiName,
                   'API%List%View',
                   listRequest.programName
                );

            ValidationOutcome validation = validateRequest(listRequest, objectType, fieldConfig);
            if (validation.errorCode != null) {
                sendError(tracker, validation.errorCode, validation.errorDetails);
                return;
            }

            QueryPlan plan = buildQueryPlan(listRequest, objectType, objectApiName, fieldConfig, validation);
            List<SObject> records = Database.queryWithBinds(plan.recordSoql, plan.bindMap, AccessLevel.USER_MODE);

            // Unfiltered requests also tell the caller which filter fields are available.
            Map<String, Object> details = new Map<String, Object>();
            String successMessage = Core_MDF_CCP_ConstantClass.MSG_LIST_RETRIEVED;
            if (!plan.hasFilters) {
                details.put('informationMessage', 'These are the allowed filter fields for this object.');
                details.put('allowedFilterFields', getAccessibleFilterFields(objectType, fieldConfig));
                successMessage = String.valueOf(records.size()) +
                    ' records returned ordered by CreatedDate descending. See details.allowedFilterFields for available filters.';
            }
            details.put('recordCount', records.size());
            // Include the actual records in the response, keyed by configured labels.
            details.put('records', toLabelKeyedRecords(records, plan.responseFieldNames, fieldConfig));
            sendResponse(tracker, true, successMessage, '200', 200, details);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            // SOQL errors (e.g. bad filterLogic or value types) go back to the caller as 400 with the Salesforce message.
            if (ex instanceof QueryException) {
                sendResponse(tracker, false, ex.getMessage(), '400', 400, null);
            } else {
                sendError(tracker, Core_MDF_CCP_ConstantClass.CODE_7015_INTERNAL_SERVER_ERROR, null);
            }
        } finally {
            logRequest(entryTime, tracker, logErrors, requestBody);
        }
    }

    /*
     * 2. VALIDATION
     */

    /** Validates filter count, fields, operators and the sort field; collects resolved paths and typed values. */
    private static ValidationOutcome validateRequest(
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest listRequest,
        Schema.SObjectType objectType,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig
    ) {
        ValidationOutcome outcome = new ValidationOutcome();
        List<Core_MDF_ListView_RestAPI_Wrapper.FilterCriteria> filters = listRequest.getFilters();
        if (filters.size() > Core_MDF_CCP_ConstantClass.MAX_FILTERS) {
            return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7014_TOO_MANY_FILTERS, null);
        }

        for (Core_MDF_ListView_RestAPI_Wrapper.FilterCriteria filter : filters) {
            if (filter == null || String.isBlank(filter.field) || String.isBlank(filter.operator)) {
                return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7010_INVALID_PAYLOAD, null);
            }
            // Field label must be configured and readable by the running user.
            String fieldPath = fieldConfig.filterFieldLabelToApiName.get(filter.field.trim().toLowerCase());
            Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(fieldPath, objectType);
            if (fieldDescribe == null) {
                return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7011_INVALID_FILTER_FIELD, invalidFieldDetails(filter.field, objectType, fieldConfig));
            }
            // Operator must be one of the operators configured for this field.
            Set<String> allowedOperators = fieldConfig.operatorsByField.get(fieldPath.toLowerCase());
            if (!allowedOperators.contains(normalizeConfiguredOperator(filter.operator))) {
                List<String> sortedOperators = new List<String>(allowedOperators);
                sortedOperators.sort();
                return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7012_INVALID_OPERATOR, new Map<String, Object>{
                    'field' => filter.field, 'operator' => filter.operator, 'allowedOperators' => sortedOperators
                });
            }
            if (fieldDescribe.getType() == Schema.DisplayType.Reference && !isValidLookupFilterValue(filter.value, fieldDescribe)) {
                return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7034_INVALID_LOOKUP_FILTER_VALUE, new Map<String, Object>{
                    'field' => filter.field
                });
            }
            outcome.filterFieldNames.add(fieldPath);
            outcome.normalizedFilterValues.add(normalizeSingleFilterValue(filter.value, fieldDescribe.getType()));
        }

        String filterLogicError = String.isBlank(listRequest.filterLogic)
            ? null
            : validateFilterLogic(listRequest.filterLogic, filters.size());
        if (filterLogicError != null) {
            return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7010_INVALID_PAYLOAD, new Map<String, Object>{
                'field' => 'filterLogic', 'message' => filterLogicError
            });
        }

        // sortBy applies only to filtered requests and is replaced by its configured API path.
        if (!filters.isEmpty() && String.isNotBlank(listRequest.sortBy)) {
            String sortField = resolveAllowedField(listRequest.sortBy, objectType, fieldConfig);
            if (sortField == null) {
                return outcome.fail(Core_MDF_CCP_ConstantClass.CODE_7011_INVALID_FILTER_FIELD, invalidFieldDetails(listRequest.sortBy, objectType, fieldConfig));
            }
            listRequest.sortBy = sortField;
        }
        return outcome;
    }

    /** Returns whether a lookup filter contains IDs that target an object referenced by the field. */
    private static Boolean isValidLookupFilterValue(Object rawValue, Schema.DescribeFieldResult fieldDescribe) {
        if (rawValue == null) {
            return true;
        }
        if (rawValue instanceof List<Object>) {
            for (Object value : (List<Object>) rawValue) {
                if (!isValidLookupFilterValue(value, fieldDescribe)) {
                    return false;
                }
            }
            return true;
        }
        try {
            Id lookupId = Id.valueOf(String.valueOf(rawValue).trim());
            String lookupObjectName = lookupId.getSObjectType().getDescribe().getName();
            for (Schema.SObjectType referenceType : fieldDescribe.getReferenceTo()) {
                if (referenceType.getDescribe().getName().equalsIgnoreCase(lookupObjectName)) {
                    return true;
                }
            }
        } catch (Exception ex) {
            return false;
        }
        return false;
    }

    /** Resolves a configured field label to its API path when it exists and is readable; otherwise null. */
    private static String resolveAllowedField(
        String fieldLabel,
        Schema.SObjectType objectType,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig
    ) {
        String fieldPath = String.isBlank(fieldLabel) ? null : fieldConfig.filterFieldLabelToApiName.get(fieldLabel.trim().toLowerCase());
        return getFieldDescribe(fieldPath, objectType) != null ? fieldPath : null;
    }

    /** Returns the sorted, readable configured filter labels. */
    @TestVisible
    private static List<String> getAccessibleFilterFields(
        Schema.SObjectType objectType,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig
    ) {
        Set<String> accessibleFields = new Set<String>();
        for (String fieldLabel : fieldConfig.filterFieldLabelToApiName.keySet()) {
            String fieldPath = fieldConfig.filterFieldLabelToApiName.get(fieldLabel);
            if (getFieldDescribe(fieldPath, objectType) != null) {
                accessibleFields.add(fieldLabel);
            }
        }
        List<String> sortedFields = new List<String>(accessibleFields);
        sortedFields.sort();
        return sortedFields;
    }

    /** Error details for an invalid filter/sort field, listing the fields the caller may use. */
    private static Map<String, Object> invalidFieldDetails(
        String invalidField,
        Schema.SObjectType objectType,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig
    ) {
        return new Map<String, Object>{
            'field' => invalidField,
            'allowedFields' => getAccessibleFilterFields(objectType, fieldConfig)
        };
    }

    /** Walks a field path (e.g. Core_MDF_Account__r.Name) and returns the final field describe when every hop is readable. */
    private static Schema.DescribeFieldResult getFieldDescribe(String fieldPath, Schema.SObjectType objectType) {
        List<String> segments = String.isBlank(fieldPath) ? new List<String>() : fieldPath.split('\\.');
        if (segments.isEmpty() || segments.size() > MAX_FIELD_PATH_DEPTH) {
            return null;
        }
        Schema.SObjectType currentType = objectType;
        for (Integer i = 0; i < segments.size() - 1 && currentType != null; i++) {
            currentType = resolveRelationshipTarget(currentType.getDescribe().fields.getMap(), segments[i]);
        }
        Schema.SObjectField field = currentType?.getDescribe().fields.getMap().get(segments[segments.size() - 1].toLowerCase());
        Schema.DescribeFieldResult fieldDescribe = field?.getDescribe();
        return fieldDescribe != null && fieldDescribe.isAccessible() ? fieldDescribe : null;
    }

    /** Returns the target object of a readable relationship (e.g. Core_MDF_Account__r), or null. */
    private static Schema.SObjectType resolveRelationshipTarget(Map<String, Schema.SObjectField> fieldMap, String relationshipName) {
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            String fieldRelationship = fieldDescribe.getRelationshipName();
            if (String.isNotBlank(fieldRelationship) && fieldRelationship.equalsIgnoreCase(relationshipName)) {
                List<Schema.SObjectType> references = fieldDescribe.getReferenceTo();
                return fieldDescribe.isAccessible() && !references.isEmpty() ? references[0] : null;
            }
        }
        return null;
    }

    /** Maps a caller operator symbol or phrase to its configured token (e.g. '>=' -> 'GE'); unknown values pass through upper-cased. */
    @TestVisible
    private static String normalizeConfiguredOperator(String operator) {
        String token = String.isBlank(operator) ? '' : operator.trim().toUpperCase();
        return CONFIGURED_OPERATOR_ALIASES.containsKey(token) ? CONFIGURED_OPERATOR_ALIASES.get(token) : token;
    }

    /** Converts a filter value to the field's Apex type for binding; unconvertible values pass through so SOQL reports the error. */
    @TestVisible
    private static Object normalizeSingleFilterValue(Object rawValue, Schema.DisplayType fieldType) {
        if (fieldType == Schema.DisplayType.Reference && rawValue instanceof List<Object>) {
            List<Object> normalizedValues = new List<Object>();
            for (Object value : (List<Object>) rawValue) {
                normalizedValues.add(normalizeSingleFilterValue(value, fieldType));
            }
            return normalizedValues;
        }
        String valueText = rawValue == null || rawValue instanceof List<Object> ? null : String.valueOf(rawValue).trim();
        if (String.isBlank(valueText)) {
            return rawValue;
        }
        try {
            if (fieldType == Schema.DisplayType.Date) {
                return Date.valueOf(valueText);
            } else if (fieldType == Schema.DisplayType.DateTime) {
                return Datetime.valueOf(valueText);
            } else if (fieldType == Schema.DisplayType.Boolean) {
                String flag = valueText.toLowerCase();
                return flag == 'true' || flag == 'false' ? (Object) Boolean.valueOf(flag) : rawValue;
            } else if (fieldType == Schema.DisplayType.ID || fieldType == Schema.DisplayType.Reference) {
                return Id.valueOf(valueText);
            } else if (fieldType == Schema.DisplayType.Integer) {
                return Integer.valueOf(valueText);
            } else if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Currency ||
                fieldType == Schema.DisplayType.Percent) {
                return Decimal.valueOf(valueText);
            }
        } catch (Exception ex) {
            return rawValue;
        }
        return rawValue;
    }

    /*
     * 3. QUERY BUILDING
     */

    /** Builds the SELECT list, bind-safe WHERE clause, ORDER BY and LIMIT from the validated request. */
    @TestVisible
    private static QueryPlan buildQueryPlan(
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest listRequest,
        Schema.SObjectType objectType,
        String objectApiName,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig,
        ValidationOutcome validation
    ) {
        QueryPlan plan = new QueryPlan();

        // SELECT: readable configured response fields, then each filter field, then Id.
        for (String fieldPath : fieldConfig.responseFieldApiNames) {
            if (fieldConfig.responseFieldApiNameToLabel.containsKey(fieldPath.toLowerCase()) && getFieldDescribe(fieldPath, objectType) != null) {
                plan.addField(fieldPath);
            }
        }

        // WHERE: one clause per filter; values are always bind variables (:v0, :v1, ...).
        List<String> whereClauses = new List<String>();
        // Initialize the list of WHERE clauses for each filter.
        List<Core_MDF_ListView_RestAPI_Wrapper.FilterCriteria> filters = listRequest.getFilters();
        // Iterate over each filter to build the corresponding WHERE clause.
        for (Integer i = 0; i < filters.size(); i++) {
            // Prepare the bind key for this filter.
            String bindKey = 'v' + i;
            // Extract the operator, field path, and bind value for this filter.
            String operator = normalizeConfiguredOperator(filters[i].operator);
            // Get the field path and normalized bind value for this filter.
            String fieldPath = validation.filterFieldNames[i];
            // Get the normalized bind value for this filter.
            Object bindValue = validation.normalizedFilterValues[i];
            // CONTAIN / NOT CONTAIN with a value become %value% LIKE patterns.
            Boolean isContains = bindValue != null && (operator == 'CONTAIN' || operator == 'NOT CONTAIN');
           // Add the field to the SELECT clause.
            if (fieldConfig.responseFieldApiNameToLabel.containsKey(fieldPath.toLowerCase())) {
                plan.addField(fieldPath);
            }
            // Bind the value for this filter in the query.
            plan.bindMap.put(bindKey, isContains ? buildContainsPattern(String.valueOf(bindValue)) : bindValue);
            whereClauses.add(buildFilterClause(fieldPath, operator, bindKey, isContains));
        }
        plan.addField('Id');
        plan.bindMap.put('programName', listRequest.programName.trim());
        plan.hasFilters = !whereClauses.isEmpty();

        // Keep the program restriction outside caller filter logic so OR cannot bypass it.
        String whereExpression = 'RecordType.Name = :programName';
        if (!whereClauses.isEmpty()) {
            String filterExpression = String.isBlank(listRequest.filterLogic)
                ? String.join(whereClauses, ' AND ')
                : buildFilterLogicWhereClause(listRequest.filterLogic, whereClauses);
            whereExpression += ' AND (' + filterExpression + ')';
        }

        // Custom sorting applies only to filtered requests; otherwise the configured default is used.
        String sortField = plan.hasFilters && String.isNotBlank(listRequest.sortBy)
            ? listRequest.sortBy.trim()
            : Core_MDF_CCP_ConstantClass.DEFAULT_SORT_FIELD;
        String sortOrder = plan.hasFilters && 'ASC'.equalsIgnoreCase(listRequest.sortOrder?.trim())
            ? 'ASC'
            : Core_MDF_CCP_ConstantClass.DEFAULT_SORT_ORDER;

        plan.recordSoql = 'SELECT ' + String.join(plan.responseFieldNames, ', ') +
            ' FROM ' + objectApiName +
            ' WHERE ' + whereExpression +
            ' ORDER BY ' + sortField + ' ' + sortOrder +
            ' LIMIT ' + String.valueOf(Core_MDF_CCP_RestAPI_Utility.MAX_RECORD_LIMIT);
        return plan;
    }

    /** Maps a configured operator token to SOQL syntax (e.g. 'GE' -> '>='). */
    @TestVisible
    private static String normalizeOperator(String configuredOperator) {
        return SOQL_OPERATOR_BY_TOKEN.get(configuredOperator);
    }

    /** Builds a filter clause, using parentheses for multi-select picklist operators. */
    @TestVisible
    private static String buildFilterClause(String fieldPath, String operator, String bindKey, Boolean isContains) {
        if (isContains && operator == 'NOT CONTAIN') {
            return 'NOT (' + fieldPath + ' LIKE :' + bindKey + ')';
        }
        String soqlOperator = normalizeOperator(operator);
        if (operator == 'INCLUDE' || operator == 'EXCLUDE') {
            return fieldPath + ' ' + soqlOperator + ' (:' + bindKey + ')';
        }
        return fieldPath + ' ' + soqlOperator + ' :' + bindKey;
    }

    /** Wraps a value in % wildcards for LIKE without doubling existing ones. */
    @TestVisible
    private static String buildContainsPattern(String value) {
        return (value.startsWith('%') ? '' : '%') + value + (value.endsWith('%') ? '' : '%');
    }

    /** Replaces filter numbers in filterLogic with their WHERE clauses; Salesforce validates the final expression. */
    @TestVisible
    private static String buildFilterLogicWhereClause(String filterLogic, List<String> whereClauses) {
        Matcher tokenMatcher = FILTER_LOGIC_TOKEN_PATTERN.matcher(filterLogic);
        List<String> expressionParts = new List<String>();
        Integer previousEnd = 0;
        while (tokenMatcher.find()) {
            expressionParts.add(filterLogic.substring(previousEnd, tokenMatcher.start()));
            expressionParts.add(resolveFilterLogicToken(tokenMatcher.group(), whereClauses));
            previousEnd = tokenMatcher.end();
        }
        expressionParts.add(filterLogic.substring(previousEnd));
        return String.join(expressionParts, '');
    }

    /** Requires every filter index to be referenced and rejects invalid or out-of-range tokens. */
    @TestVisible
    private static String validateFilterLogic(String filterLogic, Integer filterCount) {
        Set<Integer> referenced = new Set<Integer>();
        List<String> problems = new List<String>();
        Matcher tokenMatcher = FILTER_LOGIC_TOKEN_PATTERN.matcher(filterLogic);
        while (tokenMatcher.find()) {
            String token = tokenMatcher.group();
            if (FILTER_LOGIC_WHITESPACE_PATTERN.matcher(token).matches() || token == '(' || token == ')' ||
                token.equalsIgnoreCase('AND') || token.equalsIgnoreCase('OR')) {
                continue;
            }
            if (!FILTER_LOGIC_DIGIT_TOKEN_PATTERN.matcher(token).matches()) {
                problems.add('invalid token "' + token + '"');
                continue;
            }
            Integer index;
            try {
                index = Integer.valueOf(token);
            } catch (Exception ex) {
                index = null;
            }
            if (index == null || index < 1 || index > filterCount) {
                problems.add('invalid filter reference "' + token + '"');
            } else {
                referenced.add(index);
            }
        }

        List<String> missing = new List<String>();
        for (Integer index = 1; index <= filterCount; index++) {
            if (!referenced.contains(index)) {
                missing.add(String.valueOf(index));
            }
        }
        if (!missing.isEmpty()) {
            problems.add('missing filter numbers: ' + String.join(missing, ', '));
        }
        return problems.isEmpty() ? null : 'Invalid filterLogic; ' + String.join(problems, '; ') + '.';
    }

    /** Keeps a single whitespace, parentheses, AND, OR; maps "n" to the nth WHERE clause; marks anything else invalid. */
    private static String resolveFilterLogicToken(String token, List<String> whereClauses) {
        Boolean isKeptToken = FILTER_LOGIC_WHITESPACE_PATTERN.matcher(token).matches() ||
            token == '(' || token == ')' || token.equalsIgnoreCase('AND') || token.equalsIgnoreCase('OR');
        if (isKeptToken || !FILTER_LOGIC_DIGIT_TOKEN_PATTERN.matcher(token).matches()) {
            return isKeptToken ? token : 'INVALID_FILTER_LOGIC_TOKEN';
        }
        Integer filterIndex;
        try {
            filterIndex = Integer.valueOf(token);
        } catch (Exception ex) {
            filterIndex = null;  // Number too large for Integer.
        }
        return filterIndex != null && filterIndex > 0 && filterIndex <= whereClauses.size()
            ? whereClauses[filterIndex - 1]
            : 'INVALID_FILTER_LOGIC_REFERENCE';
    }

    /*
     * 4. RESPONSE SHAPING
     */

    /** Converts records to maps keyed by configured labels (lookups: "<label>" = name, "<label> Id" = Id). */
    @TestVisible
    private static List<Object> toLabelKeyedRecords(
        List<SObject> records,
        List<String> responseFieldNames,
        Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig
    ) {
        List<Object> labeledRecords = new List<Object>();
        for (SObject record : records) {
            Map<String, Object> labeledRecord = new Map<String, Object>();
            for (String fieldPath : responseFieldNames) {
                String label = fieldConfig.responseFieldApiNameToLabel.get(fieldPath.toLowerCase());
                if (!labeledRecord.containsKey(label)) {
                    labeledRecord.put(label, getFieldPathValue(record, fieldPath));
                }
            }
            labeledRecords.add(labeledRecord);
        }
        return labeledRecords;
    }

    /** Reads a direct or relationship field path from a record; returns null when a parent record is missing. */
    private static Object getFieldPathValue(SObject record, String fieldPath) {
        List<String> segments = fieldPath.split('\\.');
        SObject current = record;
        for (Integer i = 0; i < segments.size() - 1 && current != null; i++) {
            current = current.getSObject(segments[i]);
        }
        return current?.get(segments[segments.size() - 1]);
    }

    /*
     * 5. RESPONSE AND LOGGING
     */

    /** Sends an error whose message and HTTP status come from the List API response-code configuration. */
    private static void sendError(ListResponseTracker tracker, String code, Map<String, Object> details) {
        sendResponse(tracker, false, null, code, null, details);
    }

    /**
     * Writes the { isSuccess, success|error: { message, code }, details } envelope and records the outcome.
     * Errors without an explicit status use the configured message/status; 7011/7012 get a detailed message.
     */
    @TestVisible
    private static void sendResponse(
        ListResponseTracker tracker,
        Boolean isSuccess,
        String message,
        String code,
        Integer statusCode,
        Object details
    ) {
        try {
            RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
            if (!isSuccess && statusCode == null) {
                ErrorConfig errorConfig = getErrorConfig(code);
                String detailedMessage = code == Core_MDF_CCP_ConstantClass.CODE_7012_INVALID_OPERATOR
                    ? buildInvalidOperatorErrorMessage(details)
                    : code == Core_MDF_CCP_ConstantClass.CODE_7011_INVALID_FILTER_FIELD ? buildInvalidFieldErrorMessage(details)
                    : code == Core_MDF_CCP_ConstantClass.CODE_7034_INVALID_LOOKUP_FILTER_VALUE ? buildInvalidLookupFilterValueErrorMessage(details)
                    : code == Core_MDF_CCP_ConstantClass.CODE_7010_INVALID_PAYLOAD ? buildInvalidFilterLogicErrorMessage(details) : null;
                message = String.isNotBlank(detailedMessage) ? detailedMessage : errorConfig.message;
                code = errorConfig.code;
                statusCode = errorConfig.httpStatusCode;
            }
            response.statusCode = isSuccess ? 200 : statusCode;

            JSONGenerator generator = JSON.createGenerator(false);
            generator.writeStartObject();
            generator.writeBooleanField('isSuccess', isSuccess);
            generator.writeFieldName(isSuccess ? 'success' : 'error');
            generator.writeStartObject();
            generator.writeStringField('message', message);
            generator.writeStringField('code', isSuccess ? '200' : code);
            generator.writeEndObject();
            if (isSuccess) {
                // Known detail keys first in a fixed order, then any additional keys.
                Map<String, Object> responseDetails = (Map<String, Object>) details;
                List<String> detailKeys = new List<String>(ORDERED_DETAIL_KEYS);
                for (String detailKey : responseDetails.keySet()) {
                    if (!detailKeys.contains(detailKey)) {
                        detailKeys.add(detailKey);
                    }
                }
                generator.writeFieldName('details');
                generator.writeStartObject();
                for (String detailKey : detailKeys) {
                    if (responseDetails.containsKey(detailKey)) {
                        generator.writeFieldName(detailKey);
                        generator.writeObject(responseDetails.get(detailKey));
                    }
                }
                generator.writeEndObject();
            }
            generator.writeEndObject();
            response.responseBody = Blob.valueOf(generator.getAsString());
            setResponse(tracker, response, isSuccess);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            try {
                // Serialization failure: fall back to a generic 500 response.
                RestResponse response = RestContext.response != null ? RestContext.response : new RestResponse();
                response.statusCode = Core_MDF_CCP_ConstantClass.HTTP_STATUS_500;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'isSuccess' => false,
                    'error' => new Map<String, String>{
                        'code' => String.valueOf(Core_MDF_CCP_ConstantClass.HTTP_STATUS_500),
                        'message' => System.Label.Core_MDF_ApplicationErrorMessage
                    }
                }));
                setResponse(tracker, response, false);
            } catch (Exception fallbackException) {
                Core_MDF_CCP_UtilityClass.logError(fallbackException);
            }
        }
    }

    /** Publishes the response and records its status for logging. */
    private static void setResponse(ListResponseTracker tracker, RestResponse response, Boolean isSuccess) {
        RestContext.response = response;
        tracker.statusCode = String.valueOf(response.statusCode);
        tracker.isSuccess = isSuccess;
    }

    /** Builds 'Invalid operator "x" for filter "y". Allowed operators ...' from 7012 details, or null. */
    @TestVisible
    private static String buildInvalidOperatorErrorMessage(Object details) {
        Map<String, Object> errorDetails = details instanceof Map<String, Object> ? (Map<String, Object>) details : new Map<String, Object>();
        Object allowedOperators = errorDetails.get('allowedOperators');
        return errorDetails.get('field') == null || errorDetails.get('operator') == null || !(allowedOperators instanceof List<String>)
            ? null
            : 'Invalid operator "' + String.valueOf(errorDetails.get('operator')) + '" for filter "' +
              String.valueOf(errorDetails.get('field')) + '". Allowed operators for this filter: ' +
              String.join((List<String>) allowedOperators, ', ') + '.';
    }

    /** Builds 'Invalid field "x". Allowed filter fields ...' from 7011 details, or null. */
    @TestVisible
    private static String buildInvalidFieldErrorMessage(Object details) {
        Map<String, Object> errorDetails = details instanceof Map<String, Object> ? (Map<String, Object>) details : new Map<String, Object>();
        Object allowedFields = errorDetails.get('allowedFields');
        return errorDetails.get('field') == null || !(allowedFields instanceof List<String>)
            ? null
            : 'Invalid field "' + String.valueOf(errorDetails.get('field')) + '". Allowed filter fields: ' +
              String.join((List<String>) allowedFields, ', ') + '.';
    }

    /** Builds a field-specific message for a lookup filter value that is not a valid target record ID. */
    @TestVisible
    private static String buildInvalidLookupFilterValueErrorMessage(Object details) {
        Map<String, Object> errorDetails = details instanceof Map<String, Object> ? (Map<String, Object>) details : new Map<String, Object>();
        return errorDetails.get('field') == null
            ? null
            : 'Invalid value for lookup field "' + String.valueOf(errorDetails.get('field')) + '". Provide a valid record ID for this field.';
    }

    /** Builds a useful 7010 message when filterLogic references are invalid. */
    @TestVisible
    private static String buildInvalidFilterLogicErrorMessage(Object details) {
        Map<String, Object> errorDetails = details instanceof Map<String, Object> ? (Map<String, Object>) details : null;
        return errorDetails != null && errorDetails.get('field') == 'filterLogic'
            ? (String) errorDetails.get('message')
            : null;
    }

    /** Loads the message and HTTP status for an error code; defaults to the generic message and 400. */
    private static ErrorConfig getErrorConfig(String errorCode) {
        ErrorConfig config = new ErrorConfig();
        config.code = errorCode;
        config.message = System.Label.Core_MDF_ApplicationErrorMessage;
        config.httpStatusCode = Core_MDF_CCP_ConstantClass.HTTP_STATUS_400;
        try {
            Core_MDF_RestAPI_Logger.ErrorConfig loggerConfig = Core_MDF_RestAPI_Logger.getErrorConfigDetails(
                errorCode,
                Core_MDF_CCP_ConstantClass.RESPONSE_CODE_CATEGORY
            );
            if (loggerConfig != null) {
                config.code = String.isBlank(loggerConfig.code) ? errorCode : loggerConfig.code;
                config.message = String.isBlank(loggerConfig.message) ? config.message : loggerConfig.message;
                config.httpStatusCode = loggerConfig.httpStatusCode != null ? loggerConfig.httpStatusCode : config.httpStatusCode;
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return config;
    }

    /** Writes request, response, timing and errors to the transaction log. */
    private static void logRequest(Datetime entryTime, ListResponseTracker tracker, List<String> logErrors, String requestBody) {
        try {
            // Request bodies that are not valid JSON are logged as raw text.
            Object requestPayload = requestBody;
            if (String.isNotBlank(requestBody)) {
                try {
                    requestPayload = JSON.deserializeUntyped(requestBody);
                } catch (Exception ex) {
                    requestPayload = requestBody;
                }
            }
            String responseBodyText = RestContext.response?.responseBody?.toString();
            String requestUri = RestContext.request?.requestURI;

            Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
            logReq.apiName = 'Core_MDF_ListView_RestAPI';
            logReq.endpoint = String.isNotBlank(requestUri) ? requestUri.removeStart('/services/apexrest') : null;
            logReq.methodName = 'getList';
            logReq.apiVersion = 'v1.0';
            logReq.contextMessage = 'HTTP POST';
            logReq.requestPayload = requestPayload;
            logReq.responsePayload = String.isNotBlank(responseBodyText) ? JSON.deserializeUntyped(responseBodyText) : null;
            logReq.statusCode = tracker.statusCode;
            logReq.isSuccess = tracker.isSuccess;
            logReq.errors = logErrors;
            logReq.entryTime = entryTime;
            logReq.exitTime = System.now();
            logReq.additionalFields = new Map<String, Object>();
            Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    /*
     * 6. INNER CLASSES
     */

    /** Final response status, used by request logging. */
    @TestVisible
    private class ListResponseTracker {
        public String statusCode;
        public Boolean isSuccess = false;
    }

    /** Validation result: an error, or the resolved field path and typed bind value for each filter. */
    @TestVisible
    private class ValidationOutcome {
        public String errorCode;                                         // Set when validation fails.
        public Map<String, Object> errorDetails;                         // Extra error context for the response.
        public List<String> filterFieldNames = new List<String>();       // Resolved field path per filter (request order).
        public List<Object> normalizedFilterValues = new List<Object>(); // Typed bind value per filter (request order).

        /** Marks the outcome as failed and returns it. */
        public ValidationOutcome fail(String code, Map<String, Object> details) {
            errorCode = code;
            errorDetails = details;
            return this;
        }
    }

    /** SOQL text, bind values and the ordered SELECT list for the record query. */
    @TestVisible
    private class QueryPlan {
        public String recordSoql;
        public Map<String, Object> bindMap = new Map<String, Object>();
        public Boolean hasFilters = false;
        public List<String> responseFieldNames = new List<String>();  // SELECT fields in order.
        private Set<String> selectedFields = new Set<String>();       // Prevents duplicate SELECT fields.

        /** Adds a field to the SELECT list once. */
        public void addField(String fieldPath) {
            if (selectedFields.add(fieldPath)) {
                responseFieldNames.add(fieldPath);
            }
        }
    }

    /** Message, code and HTTP status for an error code. */
    private class ErrorConfig {
        public String code;
        public String message;
        public Integer httpStatusCode;
    }
}