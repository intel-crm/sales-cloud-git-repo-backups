/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_ListView_RestAPI_Wrapper
 * Description     : Request model and payload parser for Core_MDF_ListView_RestAPI.
 *                   parse() converts the POST body (key aliases, wrapper keys, array payloads)
 *                   into a ListViewRequest. Field configuration comes from
 *                   Core_MDF_CCP_RestAPI_Utility.loadFieldConfiguration().
 * ----------------------------------------------------------------------------------
 */
public class Core_MDF_ListView_RestAPI_Wrapper {

    // Accepted payload keys per request property (lowercase; payload keys are matched case-insensitively).
    private static final Set<String> OBJECT_KEYS = new Set<String>{ 'objectname', 'object', 'objectapiname', 'sobject', 'sobjecttype', 'entity' };
    private static final Set<String> PROGRAM_NAME_KEYS = new Set<String>{ 'programname','ProgramName','programName' };
    private static final Set<String> FILTER_KEYS = new Set<String>{ 'filters', 'filter', 'criteria', 'where' };
    private static final Set<String> FILTER_LOGIC_KEYS = new Set<String>{ 'filterlogic' };
    private static final Set<String> SORT_BY_KEYS = new Set<String>{ 'sortby', 'sortfield', 'orderby' };
    private static final Set<String> SORT_ORDER_KEYS = new Set<String>{ 'sortorder', 'order', 'direction' };
    private static final Set<String> FIELD_KEYS = new Set<String>{ 'field' };
    private static final Set<String> OPERATOR_KEYS = new Set<String>{ 'operator' };
    private static final Set<String> VALUE_KEYS = new Set<String>{ 'value', 'values' };
    // Keys that identify a single { field, operator, value } criterion map.
    private static final Set<String> CRITERION_KEYS = new Set<String>{ 'field', 'operator', 'value', 'values' };
    // Wrapper keys checked in this order; the first one holding an object becomes the inner payload.
    private static final List<String> WRAPPER_KEYS = new List<String>{ 'request', 'data', 'payload', 'body', 'input' };
    // Top-level keys that are never inferred as field filters (includes legacy 'logic'/'fields' aliases).
    private static final Set<String> RESERVED_KEYS = new Set<String>{
        'filters', 'filter', 'criteria', 'where', 'logic', 'filterlogic', 'condition', 'operator',
        'fields', 'columns', 'sortby', 'sortfield', 'orderby', 'sortorder', 'order', 'direction',
        'objectname', 'object', 'objectapiname', 'sobject', 'sobjecttype', 'entity',
        'programname',
        'response field', 'responsefield', 'request', 'data', 'payload', 'body', 'input'
    };

    /*
     * 1. PAYLOAD PARSING
     */

    /** Entry point: converts the raw POST body into a ListViewRequest; invalid JSON throws (reported as 7010). */
    public static ListViewRequest parse(String requestBody) {
        if (String.isBlank(requestBody)) {
            return new ListViewRequest();
        }
        try {
            Object parsed = JSON.deserializeUntyped(requestBody);
            if (parsed instanceof Map<String, Object>) {
                return fromPayload((Map<String, Object>) parsed);
            }
            if (parsed instanceof List<Object>) {
                // A bare JSON array is a filter list.
                ListViewRequest request = new ListViewRequest();
                request.filters = toFilters(parsed);
                return request;
            }
        } catch (Exception ex) {
            // Fall back to typed deserialization below.
        }
        // Typed fallback raises the parse error for non-object JSON; a "null" body is rejected the same way.
        ListViewRequest request = (ListViewRequest) JSON.deserialize(requestBody, ListViewRequest.class);
        if (request == null) {
            throw new IllegalArgumentException('Request body must be a JSON object.');
        }
        return request;
    }

    /** Reads request properties; values under a wrapper key (request/data/...) take precedence over top-level ones. */
    private static ListViewRequest fromPayload(Map<String, Object> payload) {
        Map<String, Object> innerPayload = unwrapPayload(payload);

        ListViewRequest request = new ListViewRequest();
        request.objectName = toText(readValue(innerPayload, payload, OBJECT_KEYS));
        request.programName = toText(readValue(innerPayload, payload, PROGRAM_NAME_KEYS));
        request.filters = toFilters(readValue(innerPayload, payload, FILTER_KEYS));
        request.filterLogic = toText(readValue(innerPayload, payload, FILTER_LOGIC_KEYS));
        request.sortBy = toText(readValue(innerPayload, payload, SORT_BY_KEYS));
        request.sortOrder = toText(readValue(innerPayload, payload, SORT_ORDER_KEYS));

        // Without explicit filters, top-level keys matching a configured filter label become equality filters.
        if (request.getFilters().isEmpty() && String.isNotBlank(request.objectName)) {
            Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig = Core_MDF_CCP_RestAPI_Utility.loadFieldConfiguration(
                request.objectName,
               'API%List%View',
                    request.programName
            );
            request.filters = inferFilters(innerPayload, fieldConfig);
            if (request.filters.isEmpty()) {
                request.filters = inferFilters(payload, fieldConfig);
            }
        }
        return request;
    }

    /** Returns the first nested map found under a wrapper key, otherwise the payload itself. */
    private static Map<String, Object> unwrapPayload(Map<String, Object> payload) {
        for (String wrapperKey : WRAPPER_KEYS) {
            Object wrapper = findValue(payload, new Set<String>{ wrapperKey });
            if (wrapper instanceof Map<String, Object>) {
                return (Map<String, Object>) wrapper;
            }
        }
        return payload;
    }

    /** Reads a property from the inner payload first, then from the outer payload. */
    private static Object readValue(Map<String, Object> innerPayload, Map<String, Object> outerPayload, Set<String> keys) {
        Object value = findValue(innerPayload, keys);
        return value != null ? value : findValue(outerPayload, keys);
    }

    /** Returns the value of the first map key (trimmed, case-insensitive) that matches a candidate key. */
    private static Object findValue(Map<String, Object> source, Set<String> keys) {
        for (String key : source.keySet()) {
            if (String.isNotBlank(key) && keys.contains(key.trim().toLowerCase())) {
                return source.get(key);
            }
        }
        return null;
    }

    /** Normalizes filters sent as an array, a single criterion map, or a { field: value | {operator, value} } map. */
    private static List<FilterCriteria> toFilters(Object rawFilters) {
        List<FilterCriteria> filters = new List<FilterCriteria>();
        if (rawFilters instanceof List<Object>) {
            for (Object rawFilter : (List<Object>) rawFilters) {
                addCriterion(filters, rawFilter);
            }
            return filters;
        }
        if (!(rawFilters instanceof Map<String, Object>)) {
            return filters;
        }
        Map<String, Object> filterMap = (Map<String, Object>) rawFilters;
        if (hasCriterionKey(filterMap)) {
            addCriterion(filters, filterMap);
            return filters;
        }
        // Field-keyed form: a plain value means equality; a nested map carries operator and value.
        for (String fieldName : filterMap.keySet()) {
            Object criteria = filterMap.get(fieldName);
            Map<String, Object> criteriaMap = criteria instanceof Map<String, Object> ? (Map<String, Object>) criteria : null;
            filters.add(criteriaMap == null
                ? new FilterCriteria(fieldName, '=', criteria)
                : new FilterCriteria(fieldName, toText(findValue(criteriaMap, OPERATOR_KEYS)), findValue(criteriaMap, VALUE_KEYS)));
        }
        return filters;
    }

    /** True when the map is a single criterion, i.e. it has a field, operator, value or values key. */
    private static Boolean hasCriterionKey(Map<String, Object> filterMap) {
        for (String key : filterMap.keySet()) {
            if (CRITERION_KEYS.contains(key.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    /** Adds a { field, operator, value|values } map as a criterion when at least one part is present. */
    private static void addCriterion(List<FilterCriteria> filters, Object rawFilter) {
        if (!(rawFilter instanceof Map<String, Object>)) {
            return;
        }
        Map<String, Object> filterMap = (Map<String, Object>) rawFilter;
        FilterCriteria filter = new FilterCriteria(
            toText(findValue(filterMap, FIELD_KEYS)),
            toText(findValue(filterMap, OPERATOR_KEYS)),
            findValue(filterMap, VALUE_KEYS)
        );
        if (String.isNotBlank(filter.field) || String.isNotBlank(filter.operator) || filter.value != null) {
            filters.add(filter);
        }
    }

    /** Builds equality filters from non-reserved keys that match a configured filter label. */
    @TestVisible
    private static List<FilterCriteria> inferFilters(Map<String, Object> source, Core_MDF_CCP_RestAPI_Utility.FieldConfiguration fieldConfig) {
        List<FilterCriteria> filters = new List<FilterCriteria>();
        for (String key : source.keySet()) {
            Object value = source.get(key);
            String fieldPath = String.isBlank(key) || RESERVED_KEYS.contains(key.trim().toLowerCase())
                ? null
                : fieldConfig.filterFieldLabelToApiName.get(key.trim().toLowerCase());
            Boolean hasValue = value != null && !(value instanceof String && String.isBlank((String) value));
            if (String.isNotBlank(fieldPath) && hasValue) {
                filters.add(new FilterCriteria(key.trim(), '=', value));
            }
        }
        return filters;
    }

    /** Converts a payload value to trimmed text, preserving null. */
    private static String toText(Object rawValue) {
        return rawValue == null ? null : String.valueOf(rawValue).trim();
    }

    /*
     * 2. MODELS
     */

    /** Parsed list request. */
    public class ListViewRequest {
        public String objectName;                  // Target object API name (required).
        public String programName;                 // Required layout configuration selector.
        public List<FilterCriteria> filters;       // Filter criteria in payload order.
        public String filterLogic;                 // Optional expression such as "(1 OR 2) AND 3".
        public String sortBy;                      // Sort field label; replaced by the API path during validation.
        public String sortOrder;                   // ASC or DESC (default DESC).
        /** Returns the filters, or an empty list when none were supplied. */
        public List<FilterCriteria> getFilters() {
            return filters != null ? filters : new List<FilterCriteria>();
        }
    }

    /** One filter condition as sent by the caller. */
    public class FilterCriteria {
        public String field;     // Configured field label.
        public String operator;  // Operator symbol or phrase, e.g. '=', 'EQ', 'GREATER THAN'.
        public Object value;     // Raw value; converted to the field type during validation.

        // No-arg constructor is required for typed JSON deserialization.
        public FilterCriteria() {
        }

        public FilterCriteria(String field, String operator, Object value) {
            this.field = field;
            this.operator = operator;
            this.value = value;
        }
    }
}