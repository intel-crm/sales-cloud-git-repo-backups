/***************************************************************************************************
 * @Name IPS_QualityBuilderReportQueries
 * @Description Converts a Salesforce Analytics describe response into an equivalent
 *              SOQL query for a Quality Builder job. 
 *
 * @version 1.0
 ***************************************************************************************************/
public class IPS_QualityBuilderReportQueries {

    public static final String NAMED_CREDENTIAL = 'callout:IPS_Quality_Builder';
    public static Map<String, Schema.SObjectType> globalDescribe;
    public static Map<String, ObjectMeta> metacache = new Map<String, ObjectMeta>();
    public static Map<String, List<ChildLink>> childPathCache = new Map<String, List<ChildLink>>();
    public static final Integer MAX_RELATIONSHIP_DEPTH = 5;
    public static final Integer MAX_CHILD_DEPTH = 3;

    //Caches schema field descriptions indexed by field API name and relationship name.
    public class ObjectMeta {
        Map<String, Schema.DescribeFieldResult> byFieldName = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> byRelName   = new Map<String, Schema.DescribeFieldResult>();
    }

    //Holds a resolved SOQL field path and, when available, its Salesforce display type.
    public class ResolvedColumn {
        public String soqlPath;
        public Schema.DisplayType displayType;
        public String label;
        public List<ChildLink> childPath; 
    }

    //Contains the generated SOQL query, selected field paths, and matching field labels.
    public class QueryBuildResult {
        public String query;
        public List<String> fields;
        public List<String> fieldLabels;
    }

    //Groups the resolved field paths and their display labels.
    public class FieldsWrapper {
        public List<String> fields;
        public List<String> fieldLabels;
        public List<String> selectExpressions;
    }

    public class ChildLink {
        public String objectName;
        public String relName;
        public String fkField;
    }

    public class ChildNode {
        public ChildLink link;
        public List<String> fields = new List<String>();
        public List<ChildNode> kids = new List<ChildNode>();
    }

    // Maps Analytics API filter operator codes
    public static final Map<String, String> OPERATOR_MAP = new Map<String, String>{
        'equals'        => '=',
        'notEqual'      => '!=',
        'lessThan'      => '<',
        'greaterThan'   => '>',
        'lessOrEqual'   => '<=',
        'greaterOrEqual'=> '>=',
        'contains'      => 'LIKE',
        'notContain'    => 'NOT LIKE',
        'startsWith'    => 'STARTS WITH',
        'includes'       => 'INCLUDES',
        'excludes'       => 'EXCLUDES'
    };

    //Entry point, builds the SOQL query and associated field metadata for a Salesforce report.
    public static QueryBuildResult buildQueryDetailsFromReportId(String jobName, String reportId, String objectApiName) {

        if(jobName==null || reportId == null || objectApiName == null) {
            return null;
        }

        Map<String, Object> describeResult = getReportDescribe(jobName, reportId);
        if (describeResult == null || !describeResult.containsKey('reportExtendedMetadata')) {
            return null;
        }

        Map<String, Object> reportMetadata = (Map<String, Object>) describeResult.get('reportMetadata');
        if (reportMetadata == null) {
            return null;
        }

        FieldsWrapper fw = getFieldList(reportMetadata, describeResult, objectApiName);
        // List<String> fields = getFieldList(reportMetadata, describeResult, objectApiName);
        if (fw == null || fw.fields.isEmpty()) {
            return null;
        }

        String whereClause = buildWhereClause(reportMetadata, describeResult, objectApiName);

        String query = 'SELECT ' + String.join(fw.selectExpressions, ', ') + ' FROM ' + objectApiName;
        if (String.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }

        QueryBuildResult result = new QueryBuildResult();
        result.fields = fw.fields;
        result.fieldLabels = fw.fieldLabels;
        result.query = query;
        return result;
    }

    //Calls the Salesforce Analytics report describe endpoint and parses its JSON response.
    public static Map<String, Object> getReportDescribe(String jobName, String reportId) {
        if (Test.isRunningTest()) {
            return null;
        }

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(NAMED_CREDENTIAL + '/services/data/v66.0/analytics/reports/' + reportId + '/describe');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(30000);
    
            Http http = new Http();
            HttpResponse res = http.send(req);
    
            if (res.getStatusCode() != 200) {
               
               Core_Log_Entry.logEntryWithDetails('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', 'Describe API', 'Failed to retrieve data for job', 'Survey report', 'null', 'Success');
                //System.debug(LoggingLevel.ERROR, 'Report describe callout failed [' + res.getStatusCode() + ']: ' + res.getBody());
                return null;
            }
    
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        } catch(Exception exp) {
           
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', 'Describe API', 'Failed to request report API for job', 'Survey report', 'null', 'Success', null);
            return null;
        }
    }

    //Extracts the "detailColumnInfo" map from a report describe response. This map is what resolves a report's short column keys to their fully-qualified SObject field paths.
    public static Map<String, Object> getDetailColumnInfo(Map<String, Object> describeResult) {
        if (describeResult == null) {
            return null;
        }
        Map<String, Object> reportExtendedMetadata = (Map<String, Object>) describeResult.get('reportExtendedMetadata');
        if (reportExtendedMetadata == null) {
            return null;
        }
        return (Map<String, Object>) reportExtendedMetadata.get('detailColumnInfo');
    }
        //Builds the SELECT field list from the report's detail columns. Resolves the report's detail columns into usable SOQL field paths and display labels.
    public static FieldsWrapper getFieldList(Map<String, Object> reportMetadata, Map<String, Object> describeResult, String objectApiName) {
        FieldsWrapper fw = new FieldsWrapper();
        List<String> fields = new List<String>();       // CSV columns (repeats allowed)
        List<String> labels = new List<String>();       // CSV headers (one per column)
        List<String> selectExprs = new List<String>();  // SOQL SELECT (unique)
        List<String> seenFields = new List<String>();
        List<ChildNode> childRoots = new List<ChildNode>();

        List<Object> detailColumns = (List<Object>) reportMetadata.get('detailColumns');
        Map<String, Object> detailColumnInfo = getDetailColumnInfo(describeResult);

        if (detailColumns != null) {
            for (Object colObj : detailColumns) {
                String columnKey = (String) colObj;
                ResolvedColumn rc = resolveColumn(columnKey, objectApiName);
                String fieldName = rc == null ? null : rc.soqlPath;

                if (String.isBlank(fieldName) || !isPlausibleFieldPath(fieldName)) {
                    continue;
                }

                // Unique key: child fields are prefixed with their relationship chain.
                String fieldKey = rc.childPath == null ? fieldName : childFieldKey(rc.childPath, fieldName);

                // CSV: every report column, repeats included
                fields.add(fieldKey);
                String schemaLabel = String.isNotBlank(rc.label) ? rc.label : fieldName;
                labels.add(resolveColumnLabel(columnKey, detailColumnInfo, schemaLabel));

                // SOQL: each field selected only once
                if (seenFields.contains(fieldKey)) continue;
                seenFields.add(fieldKey);

                //String expr = isDateType(rc.displayType) ? 'Format(' + fieldName + ')' : fieldName;
                String expr = fieldName;
                if (isDateType(rc.displayType)) {
                expr = 'Format(' + fieldName + ')';
                } else if (rc.displayType == Schema.DisplayType.PICKLIST
                || rc.displayType == Schema.DisplayType.MULTIPICKLIST) {
                expr = 'toLabel(' + fieldName + ')';        // picklist → label instead of API value
                }
                if (rc.childPath == null) {
                    selectExprs.add(expr);
                } else {
                    addToChildTree(childRoots, rc.childPath, expr);
                }
            }
        }

        // Id is needed for most downstream processing (dedupe, upsert, etc.), regardless of
        // whether the report itself displayed it.
        if (!seenFields.contains('Id')) {
            selectExprs.add('Id');
        }

        for (ChildNode n : childRoots) {
            selectExprs.add(renderChild(n));
        }

        fw.fields = fields;
        fw.fieldLabels = labels;
        fw.selectExpressions = selectExprs;
        return fw;
    }
    
    public static String childFieldKey(List<ChildLink> path, String fieldName) {
        List<String> rels = new List<String>();
        for (ChildLink l : path) rels.add(l.relName);
        return String.join(rels, '.') + '.' + fieldName;
    }

    public static void addToChildTree(List<ChildNode> roots, List<ChildLink> path, String expr) {
        List<ChildNode> level = roots;
        ChildNode node;
        for (ChildLink link : path) {
            node = null;
            for (ChildNode n : level) {
                if (n.link.relName == link.relName) { node = n; break; }
            }
            if (node == null) {
                node = new ChildNode();
                node.link = link;
                level.add(node);
            }
            level = node.kids;
        }
        node.fields.add(expr);
    }

    public static String renderChild(ChildNode n) {
        List<String> parts = new List<String>(n.fields);
        for (ChildNode k : n.kids) parts.add(renderChild(k));
        if (parts.isEmpty()) parts.add('Id');
        return '(SELECT ' + String.join(parts, ', ') + ' FROM ' + n.link.relName + ')';
    }

    //Determines the display label for a report column.
    public static String resolveColumnLabel(String columnKey, Map<String, Object> detailColumnInfo, String fallbackFieldName) {
        if(detailColumnInfo == null || String.isBlank(columnKey)) {
            return fallbackFieldName;
        }
        
        Object raw = detailColumnInfo.get(columnKey);
        if(raw == null) {
            String target = columnKey.trim().toLowerCase();
            for(String k : detailColumnInfo.keySet()) {
                if(k!=null && k.trim().toLowerCase() == target) {
                    raw = detailColumnInfo.get(k);
                    break;
                }
            }
        }
        if(raw != null) {
            Map<String, Object> columnInfo = (Map<String, Object>) raw;
            String label = (String) columnInfo.get('label');
            if(String.isNotBlank(label)) {
                return label;
            }
        }
        return fallbackFieldName;
    }

    //Resolves a report column key to a normalized SOQL field path. 
    public static String resolveEntityColumnName(String columnKey, String objectApiName) {
        ResolvedColumn rc = resolveColumn(columnKey, objectApiName);
        return rc == null ? null : rc.soqlPath;
    }


    /**
     * Resolves a standard (non-custom) relationship segment — e.g. "Owner", "Contact" — to

    /**
     * Sanity check that a resolved field path only contains characters valid in a SOQL field
     * reference (letters, digits, underscore, dot).
     */
    public static Boolean isPlausibleFieldPath(String fieldPath) {
        return Pattern.matches('^[A-Za-z0-9_.]+$', fieldPath);
    }

    /**
     * Builds the WHERE clause from the report's filters.
     */
    public static String buildWhereClause(Map<String, Object> reportMetadata, Map<String, Object> describeResult, String objectApiName) {
        List<Object> filters = (List<Object>) reportMetadata.get('reportFilters');
        if (filters == null || filters.isEmpty()) {
            return null;
        }

        Map<String, Object> detailColumnInfo = getDetailColumnInfo(describeResult);
        Map<Integer, String> indexedConditions = new Map<Integer, String>();
        Integer idx = 1;

        for (Object filterObj : filters) {
            Map<String, Object> filter = (Map<String, Object>) filterObj;
            String column = (String) filter.get('column');
            String operator = (String) filter.get('operator');
            String value = (String) filter.get('value');

            ResolvedColumn rc = resolveColumn(column, objectApiName);
            String fieldName = rc == null ? null : rc.soqlPath;
            if (String.isBlank(fieldName) || !isPlausibleFieldPath(fieldName)) {
                System.debug('Filter #' + idx + ' (column: ' + column
                    + ') unresolvable — likely a bucket/cross/formula field. Dropping as no-op.');
                idx++; // Keep numbering aligned with reportBooleanFilter even on failure.
                continue;
            }

            String soqlOperator = OPERATOR_MAP.containsKey(operator) ? OPERATOR_MAP.get(operator) : '=';
            String cond = rc.childPath == null 
                ? buildCondition(fieldName, soqlOperator, value, objectApiName) 
                : buildChildCondition(rc, soqlOperator, value);
            indexedConditions.put(idx, cond);
            idx++;
        }

        if (indexedConditions.isEmpty()) {
            return null;
        }

        String booleanFilter = (String) reportMetadata.get('reportBooleanFilter');
        if (String.isNotBlank(booleanFilter)) {
            return applyBooleanFilterTemplate(booleanFilter, indexedConditions);
        }

        // No custom boolean logic specified — Salesforce reports default to ANDing all filters.
        return String.join(indexedConditions.values(), ' AND ');
    }

    //Wraps a child-object condition in a semi-join (or anti-join for negative operators).
    public static String buildChildCondition(ResolvedColumn rc, String soqlOperator, String value) {
        List<ChildLink> path = rc.childPath;
        String leafObject = path[path.size() - 1].objectName;

        // Negative operators become an anti-join over the positive condition, so Cases
        // with no child record still pass (matches the report's outer-join behaviour).
        String posOp = soqlOperator;
        Boolean negate = false;
        if (soqlOperator == '!=')            { posOp = '=';        negate = true; }
        else if (soqlOperator == 'NOT LIKE') { posOp = 'LIKE';     negate = true; }
        else if (soqlOperator == 'EXCLUDES') { posOp = 'INCLUDES'; negate = true; }

        String expr = buildCondition(rc.soqlPath, posOp, value, leafObject);

        for (Integer i = path.size() - 1; i >= 0; i--) {
            String op = (i == 0 && negate) ? 'NOT IN' : 'IN';
            expr = 'Id ' + op + ' (SELECT ' + path[i].fkField + ' FROM ' + path[i].objectName
                + ' WHERE ' + expr + ')';
        }
        return expr;
    }

    /**
     * Expands a report's custom boolean-filter template (e.g. "1 AND (2 OR 3)") into a real
     * SOQL WHERE fragment by substituting each filter number with its resolved condition.
     */
    public static String applyBooleanFilterTemplate(String booleanFilter, Map<Integer, String> indexedConditions) {
        String template = wrapNotGroups(booleanFilter);

        // Pass 1: find every distinct filter-number reference in the ORIGINAL template only.
        Set<Integer> allRefs = new Set<Integer>();
        Matcher numMatcher = Pattern.compile('\\b\\d+\\b').matcher(template);
        while (numMatcher.find()) {
            allRefs.add(Integer.valueOf(numMatcher.group()));
        }

        // Pass 2: convert every reference to a unique, non-numeric placeholder BEFORE any
        // real condition text (which may itself contain digits) is inserted.
        for (Integer ref : allRefs) {
            String placeholder = '@@COND_' + ref + '@@';
            template = template.replaceAll('\\b' + ref + '\\b', placeholder);
        }

        // Pass 3: now that no bare digits remain, it's safe to substitute in the actual
        // conditions (literal, non-regex replace — condition text is never treated as a pattern).
        for (Integer ref : allRefs) {
            String placeholder = '@@COND_' + ref + '@@';
            String replacement = indexedConditions.containsKey(ref)
                ? '(' + indexedConditions.get(ref) + ')'
                : '(Id != null)'; // Unresolvable filter dropped as a SOQL-valid no-op.
            template = template.replace(placeholder, replacement);
        }

        return template;
    }

    /**
     * Parenthesizes each "NOT <number>" or "NOT (...)" group in a boolean-filter template so
     * that later regex-based number substitution can safely target.
     */
    public static String wrapNotGroups(String template) {
        String result = '';
        Integer i = 0;
        Integer len = template.length();

        while (i < len) {
            Boolean isNotHere = (i + 3 <= len)
                && template.substring(i, i + 3).equalsIgnoreCase('NOT')
                && (i == 0 || !isWordChar(template.substring(i - 1, i)))
                && (i + 3 == len || !isWordChar(template.substring(i + 3, i + 4)));

            if (!isNotHere) {
                result += template.substring(i, i + 1);
                i++;
                continue;
            }

            Integer j = i + 3;
            while (j < len && isWhitespace(template.substring(j, j + 1))) {
                j++;
            }

            if (j < len && template.substring(j, j + 1) == '(') {
                // NOT is followed by a parenthesized group — find its matching close paren.
                Integer depth = 0;
                Integer k = j;
                Integer closeIdx = -1;
                while (k < len) {
                    String ch = template.substring(k, k + 1);
                    if (ch == '(') {
                        depth++;
                    } else if (ch == ')') {
                        depth--;
                        if (depth == 0) {
                            closeIdx = k;
                            break;
                        }
                    }
                    k++;
                }
                if (closeIdx != -1) {
                    result += '(' + template.substring(i, closeIdx + 1) + ')';
                    i = closeIdx + 1;
                    continue;
                }

                // Malformed input (unbalanced parens) — pass "NOT" through unchanged rather than fail.
                result += template.substring(i, i + 3);
                i += 3;
                continue;
            }

            // NOT is followed by a bare number — wrap just the number.
            Integer k = j;
            while (k < len && isDigit(template.substring(k, k + 1))) {
                k++;
            }
            if (k > j) {
                result += '(' + template.substring(i, k) + ')';
                i = k;
                continue;
            }

            // "NOT" wasn't followed by a group or a number — pass it through unchanged.
            result += template.substring(i, i + 3);
            i += 3;
        }

        return result;
    }

    public static Boolean isWordChar(String ch) {
        return Pattern.matches('[A-Za-z0-9_]', ch);
    }

    public static Boolean isWhitespace(String ch) {
        return Pattern.matches('\\s', ch);
    }

    public static Boolean isDigit(String ch) {
        return Pattern.matches('[0-9]', ch);
    }

    /**
     * Builds a single SOQL condition fragment ("Field OPERATOR value") for one report filter,
     * choosing the correct value formatting based on the operator and the field's data type:
     */
    public static String buildCondition(String fieldName, String soqlOperator, String value, String objectApiName) {
        Schema.DisplayType fieldType = getFieldDisplayType(fieldName, objectApiName);
        List<String> tokens = parseMultiValueList(value);
        if (soqlOperator == 'LIKE' || soqlOperator == 'NOT LIKE' || soqlOperator == 'STARTS WITH') {
            String lead = soqlOperator == 'STARTS WITH' ? '' : '%';
            List<String> clauses = new List<String>();
            for(String token : tokens) {
                if(String.isEmpty(token)) {
                    continue;
                }
                clauses.add(fieldName + ' LIKE \'' + lead + escapeLike(token) + '%\'');
            }

            if(clauses.isEmpty()) {
                return 'Id != null';
            }

            if (soqlOperator == 'NOT LIKE') {
                return '(NOT (' + String.join(clauses, ' OR ') + '))';
            }

            return clauses.size() == 1 ? clauses[0] : '(' + String.join(clauses, ' OR ') + ')';
        }

        if (soqlOperator == 'INCLUDES' || soqlOperator == 'EXCLUDES') {
            List<String> quoted = new List<String>();
            for (String token : tokens) {
                if (String.isNotEmpty(token)) {
                    quoted.add('\'' + String.escapeSingleQuotes(token) + '\'');
                }
            }
            if (quoted.isEmpty()) {
                return 'Id != null';
            }
            return fieldName + ' ' + soqlOperator + ' (' + String.join(quoted, ', ') + ')';
        }

        if (soqlOperator == '=' || soqlOperator == '!=') {
            if (tokens.isEmpty()) {
                return fieldName + ' ' + soqlOperator + ' null'; // blank filter value = "is blank"
            }
            if (tokens.size() > 1) {
                List<String> literals = new List<String>();
                for (String token : tokens) {
                    literals.add(formatLiteral(token, fieldType));
                }
                String inOperator = soqlOperator == '=' ? 'IN' : 'NOT IN';
                return fieldName + ' ' + inOperator + ' (' + String.join(literals, ', ') + ')';
            }
            return fieldName + ' ' + soqlOperator + ' ' + formatLiteral(tokens[0], fieldType);
        }

        // Comparisons: <, >, <=, >=
        if (String.isBlank(value)) {
            return 'Id != null';
        }
        return fieldName + ' ' + soqlOperator + ' ' + formatLiteral(value.trim(), fieldType);

        
    }

    /** True if value is a plain integer or decimal number (optionally negative). */
    public static Boolean isNumericValue(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        return Pattern.matches('^-?\\d+(\\.\\d+)?$', value);
    }

    /**
     * True if value is a recognized SOQL relative-date literal
     */
    public static Boolean isDateLiteral(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        String v = value.trim();
        return Pattern.matches(
            '^(?:' +
            'TODAY|YESTERDAY|TOMORROW|' +
            'THIS_WEEK|LAST_WEEK|NEXT_WEEK|' +
            'THIS_MONTH|LAST_MONTH|NEXT_MONTH|' +
            'THIS_QUARTER|LAST_QUARTER|NEXT_QUARTER|' +
            'THIS_YEAR|LAST_YEAR|NEXT_YEAR|' +
            'THIS_FISCAL_QUARTER|LAST_FISCAL_QUARTER|NEXT_FISCAL_QUARTER|' +
            'THIS_FISCAL_YEAR|LAST_FISCAL_YEAR|NEXT_FISCAL_YEAR|' +
            'LAST_90_DAYS|NEXT_90_DAYS|' +
            'LAST_N_DAYS:\\d+|NEXT_N_DAYS:\\d+|N_DAYS_AGO:\\d+|' +
            'LAST_N_WEEKS:\\d+|NEXT_N_WEEKS:\\d+|N_WEEKS_AGO:\\d+|' +
            'LAST_N_MONTHS:\\d+|NEXT_N_MONTHS:\\d+|N_MONTHS_AGO:\\d+|' +
            'LAST_N_QUARTERS:\\d+|NEXT_N_QUARTERS:\\d+|N_QUARTERS_AGO:\\d+|' +
            'LAST_N_YEARS:\\d+|NEXT_N_YEARS:\\d+|N_YEARS_AGO:\\d+|' +
            'LAST_N_FISCAL_QUARTERS:\\d+|NEXT_N_FISCAL_QUARTERS:\\d+|N_FISCAL_QUARTERS_AGO:\\d+|' +
            'LAST_N_FISCAL_YEARS:\\d+|NEXT_N_FISCAL_YEARS:\\d+|N_FISCAL_YEARS_AGO:\\d+' +
            ')$',
            v
        );
    }

    /**
     * Converts the Analytics API's human-readable relative-date text 
     * into the equivalent parameterized SOQL relative-date literal.
     */
    public static String convertRelativeDurationToSoqlLiteral(String value) {
        if (String.isBlank(value)) {
            return null;
        }

        Matcher m = Pattern.compile('(?i)^(\\d+)\\s+(DAY|DAYS|WEEK|WEEKS|MONTH|MONTHS|QUARTER|QUARTERS|YEAR|YEARS)\\s+AGO$')
            .matcher(value.trim());
        if (!m.matches()) {
            return null;
        }

        Integer n = Integer.valueOf(m.group(1));
        String unit = m.group(2).toUpperCase();

        String tokenUnit;
        if (unit.startsWith('DAY')) {
            tokenUnit = 'N_DAYS_AGO';
        } else if (unit.startsWith('WEEK')) {
            tokenUnit = 'N_WEEKS_AGO';
        } else if (unit.startsWith('MONTH')) {
            tokenUnit = 'N_MONTHS_AGO';
        } else if (unit.startsWith('QUARTER')) {
            tokenUnit = 'N_QUARTERS_AGO';
        } else {
            tokenUnit = 'N_YEARS_AGO';
        }

        return tokenUnit + ':' + n;
    }

    /**
     * Looks up the display type (e.g. BOOLEAN, DATE, PICKLIST) of a top-level field on the
     * given object, via schema describe.
     */
    public static Schema.DisplayType getFieldDisplayType(String fieldName, String objectApiName) {
        ResolvedColumn rc = resolveColumn(fieldName, objectApiName);
        return rc == null ? null : rc.displayType;
    }

    //Retrieves cached schema metadata for a Salesforce object, loading it when necessary. Metadata indexes fields by API name and relationship name for case-insensitive lookup.
    public static ObjectMeta getObjectMeta(String apiName) {
        if(String.isBlank(apiName)) return null;

        String key = apiName.toLowerCase();
        if(metaCache.containsKey(key)) return metaCache.get(key);

        if(globalDescribe == null) globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objType = globalDescribe.get(key);   
        if(objType == null) {
            metaCache.put(key, null);
            return null;
        }
        
        ObjectMeta meta = new ObjectMeta();
        for(Schema.SObjectField f : objType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult d = f.getDescribe();
            meta.byFieldName.put(d.getName().toLowerCase(), d);
            if(String.isNotBlank(d.getRelationshipName())) {
                meta.byRelName.put(d.getRelationshipName().toLowerCase(), d);
            }
        }
        metaCache.put(key, meta);
        return meta;
    }

    //Chooses the target object for a reference field.
    public static String pickReferenceTarget(Schema.DescribeFieldResult fieldDescribe) {
        List<Schema.SObjectType> refs = fieldDescribe.getReferenceTo();
        if (refs==null || refs.isEmpty()) {
            return null;
        }
        for(Schema.SObjectType ref : refs) {
            if(ref.getDescribe().getName() == 'User') {
                return 'User';
            }
        }
        return refs[0].getDescribe().getName();
    }

    //Resolves a field or relationship path against Salesforce schema metadata. Returns a ResolvedColumn containing the normalized SOQL path and display type, or null if the path is invalid.
    public static ResolvedColumn resolveColumn(String columnKey, String rootObjectApiName) {
        if (String.isBlank(columnKey) || String.isBlank(rootObjectApiName)) return null;
        // The report API keys a related object's Name field as "<lookup>.Name__lookup".
        // "__lookup" is not a real field: strip it so the path resolves to <lookup>__r.Name.
        String key = columnKey.trim();
        if (key.endsWithIgnoreCase('__lookup')) {
            key = key.removeEndIgnoreCase('__lookup');
        }

        List<String> segs = key.split('\\.');
        if (segs[0].equalsIgnoreCase(rootObjectApiName)) {
            segs.remove(0);
        } else if (segs.size() > 1 && getObjectMeta(segs[0]) != null) {
            return resolveChildColumn(key, segs[0], rootObjectApiName);
        }

        if (segs.isEmpty()) return null;
        String currentObject = rootObjectApiName;
        List<String> out = new List<String>();
        ResolvedColumn rc = new ResolvedColumn();

        for (Integer i = 0; i < segs.size(); i++) {
            ObjectMeta m = getObjectMeta(currentObject);
            if (m == null) return null;

            String seg = segs[i].toLowerCase();
            Boolean isLast = (i == segs.size() - 1);

            if (!isLast) {
                Schema.DescribeFieldResult f = m.byRelName.get(seg);          
                if (f == null) f = m.byFieldName.get(seg);                    
                if (f == null || String.isBlank(f.getRelationshipName()) || !f.isAccessible()) return null;
                out.add(f.getRelationshipName());
                currentObject = pickReferenceTarget(f);
                if (currentObject == null) return null;
            } else {
                Schema.DescribeFieldResult f = m.byFieldName.get(seg);
                if (f != null && f.isAccessible()) {
                    out.add(f.getName());
                    rc.displayType = f.getType();
                    rc.label = f.getLabel();
                } else {
                    f = m.byRelName.get(seg);                                 
                    if (f == null || !f.isAccessible()) return null;
                    out.add(f.getRelationshipName());
                    out.add('Name');
                    rc.displayType = Schema.DisplayType.STRING;
                    rc.label = f.getLabel();
                }
            }
        }

        if (out.size() - 1 > MAX_RELATIONSHIP_DEPTH) return null;
        rc.soqlPath = String.join(out, '.');
        return rc;
    }

    public static Boolean isDateType(Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.DATE || displayType == Schema.DisplayType.DATETIME;
    }

    // Formats one raw value as a SOQL literal based on the field's data type.
    public static String formatLiteral(String raw, Schema.DisplayType fieldType) {
        String v = raw == null ? '' : raw;
        String trimmed = v.trim();

        if (fieldType == Schema.DisplayType.BOOLEAN) {
            return trimmed.equalsIgnoreCase('true') ? 'true' : 'false';
        }

        if (isNumericType(fieldType)) {
            if (isNumericValue(trimmed)) {
                return trimmed;
            }
        } else if (isDateType(fieldType)) {
            if (isDateLiteral(trimmed) || isIsoDateTime(trimmed)) {
                return trimmed;
            }
            if (isIsoDate(trimmed)) {
                return fieldType == Schema.DisplayType.DATETIME ? trimmed + 'T00:00:00Z' : trimmed;
            }
            String relative = convertRelativeDurationToSoqlLiteral(trimmed);
            if (relative != null) {
                return relative;
            }
        } else if (fieldType == null) {
            // Type unknown: fall back to value-shape heuristics.
            if (isNumericValue(trimmed) || isDateLiteral(trimmed) || isIsoDate(trimmed) || isIsoDateTime(trimmed)) {
                return trimmed;
            }
            String relative = convertRelativeDurationToSoqlLiteral(trimmed);
            if (relative != null) {
                return relative;
            }
        }

        // Strings, picklists, ids, references and anything else: always quoted.
        return '\'' + String.escapeSingleQuotes(v) + '\'';
    }

    // Escapes a LIKE operand so % and _ in report values match literally.
    public static String escapeLike(String raw) {
        return String.escapeSingleQuotes(raw).replace('%', '\\%').replace('_', '\\_');
    }

    public static Boolean isNumericType(Schema.DisplayType t) {
        return t == Schema.DisplayType.DOUBLE   || t == Schema.DisplayType.INTEGER
            || t == Schema.DisplayType.LONG     || t == Schema.DisplayType.CURRENCY
            || t == Schema.DisplayType.PERCENT;
    }

    public static Boolean isIsoDate(String v) {
        return String.isNotBlank(v) && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', v);
    }

    public static Boolean isIsoDateTime(String v) {
        return String.isNotBlank(v)
            && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?(Z|[+-]\\d{2}:?\\d{2})$', v);
    }

    public static List<String> parseMultiValueList(String raw) {
        List<String> tokens = new List<String>();
        if (String.isBlank(raw)) {
            return tokens;
        }

        String current = '';
        Boolean inQuotes = false;
        Boolean wasQuoted = false;
        Integer len = raw.length();

        for (Integer i = 0; i < len; i++) {
            String ch = raw.substring(i, i + 1);
            if (ch == '"') {
                inQuotes = !inQuotes;
                wasQuoted = true;
                continue;
            }
            if (ch == ',' && !inQuotes) {
                tokens.add(wasQuoted ? current : current.trim());
                current = '';
                wasQuoted = false;
                continue;
            }
            current += ch;
        }
        tokens.add(wasQuoted ? current : current.trim());
        return tokens;
    }

    public static List<ChildLink> findChildPath(String rootObj, String targetObj) {
        String cacheKey = (rootObj + '>' + targetObj).toLowerCase();
        if (childPathCache.containsKey(cacheKey)) return childPathCache.get(cacheKey);

        if (globalDescribe == null) globalDescribe = Schema.getGlobalDescribe();
        List<ChildLink> found = null;
        List<List<ChildLink>> queue = new List<List<ChildLink>>{ new List<ChildLink>() };
        Set<String> visited = new Set<String>{ rootObj.toLowerCase() };
        Integer guard = 0;

        while(!queue.isEmpty() && found==null && guard++ < 500) {
            List<ChildLink> current = queue.remove(0);
            if (current.size() >= MAX_CHILD_DEPTH) continue;
            
            String parentName = current.isEmpty() ? rootObj : current[current.size() - 1].objectName;
            Schema.SObjectType pType = globalDescribe.get(parentName.toLowerCase());
            if (pType == null) continue;
            for (Schema.ChildRelationship cr : pType.getDescribe().getChildRelationships()) {
                if (cr.getRelationshipName() == null) continue;

                ChildLink link = new ChildLink();
                link.objectName = cr.getChildSObject().getDescribe().getName();
                link.relName    = cr.getRelationshipName();
                link.fkField    = cr.getField().getDescribe().getName();

                List<ChildLink> next = current.clone();
                next.add(link);

                if (link.objectName.equalsIgnoreCase(targetObj)) { found = next; break; }
                if (link.objectName.endsWithIgnoreCase('__c') && visited.add(link.objectName.toLowerCase())) {
                    queue.add(next);
                }
            }
            
        }
        childPathCache.put(cacheKey, found);
        return found;
    }

    public static ResolvedColumn resolveChildColumn(String columnKey, String childObj, String rootObj) {
        List<ChildLink> path = findChildPath(rootObj, childObj);
        if (path == null) return null;

        ResolvedColumn leaf = resolveColumn(columnKey, childObj); // strips the child prefix, resolves against child schema
        if (leaf == null) return null;

        leaf.childPath = path;
        return leaf;
    }
}