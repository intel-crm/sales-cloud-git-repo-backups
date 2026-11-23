public without sharing class Core_MDF_CCP_RestAPI_Utility {

    private static final String SF_INSTANCE_URL = URL.getOrgDomainURL().toExternalForm();
    private static final String SF_API_VERSION = '66.0';
    private static final String API_VERSION = '1.0';
    private static final String USER_TYPE = 'External User';
    private static final Map<String, Set<String>> FIELD_CACHE = new Map<String, Set<String>>();
    private static final Map<String, Map<String, String>> FIELD_LABEL_CACHE = new Map<String, Map<String, String>>();
    private static final Map<String, Set<String>> LOOKUP_FIELD_CACHE = new Map<String, Set<String>>();
    public static Decimal MAX_RECORD_LIMIT;
    /**
     * Fetch object record from Salesforce standard REST API and apply field filtering.
     * Returns null when API call fails or an exception occurs.
     * Throws AccessDeniedException when user lacks permission to view record.
     *
     * @param objectApiName API name of object to query.
     * @param recordId Record id to retrieve.
     * @param defaultDisplayFields Default fields used when no config exists.
     * @return Filtered map keyed by API field names.
     * @throws AccessDeniedException when HTTP 403 (Forbidden) or permission denied error
     */
    public static Map<String, Object> getFilteredRecord(String objectApiName, String recordId, Set<String> defaultDisplayFields) {
        try {
            String sfEndpoint = SF_INSTANCE_URL + '/services/data/v' + SF_API_VERSION + '/sobjects/' + objectApiName + '/' + recordId;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sfEndpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = new Http().send(request);
            String responseBody = response.getBody();

            // Check for explicit permission error (HTTP 403)
            if (response.getStatusCode() == 403) {
                System.debug('HTTP 403 Forbidden returned from REST API');
                throw new AccessDeniedException('Insufficient permissions to access this record');
            }

            if (response.getStatusCode() != 200) {
                System.debug('REST API returned status ' + response.getStatusCode() + ': ' + responseBody);
                return null;
            }

            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            return filterFields(objectApiName, fullResponse, recordId, defaultDisplayFields);
        } catch (AccessDeniedException ex) {
            throw ex;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    /**
     * Filter full response using configured display fields.
     * Returns fields keyed by API names (not labels).
     *
     * @param objectApiName API name of object.
     * @param fullResponse Full response from standard API.
     * @param recordId Record id used for record type resolution.
     * @param defaultDisplayFields Default fields used as fallback.
     * @return Filtered map of field API name to value.
     */
    public static Map<String, Object> filterFields(String objectApiName, Map<String, Object> fullResponse, String recordId, Set<String> defaultDisplayFields) {
        Map<String, Object> filteredData = new Map<String, Object>();

        Set<String> displayFields = normalizeDisplayFields(objectApiName, getDisplayFields(objectApiName, recordId, defaultDisplayFields));
        // Any field with a configured Core_MDF_Record_Name_nm__c must be shown regardless of record-type/user-type matching.
        displayFields.addAll(getConfiguredLookupFields(objectApiName));
        // Field paths from config can differ only by casing (e.g. ".Name" vs ".name"); collapse those to one entry.
        displayFields = dedupeFieldPathsIgnoreCase(displayFields);
        enrichMissingRelationshipFields(objectApiName, recordId, fullResponse, displayFields);

        for (String fieldName : displayFields) {
            Object fieldValue = resolveFieldValue(fullResponse, fieldName);
            if (fieldValue != null || containsFieldPath(fullResponse, fieldName)) {
                filteredData.put(fieldName, fieldValue);
            }
        }

        return filteredData;
    }

    /**
     * Collapse field paths that are identical except for casing (Set<String> equality is case-sensitive)
     * so the same field never appears twice in the response under different casing.
     *
     * @param fieldPaths Field paths to dedupe.
     * @return Set with one entry per case-insensitive field path.
     */
    private static Set<String> dedupeFieldPathsIgnoreCase(Set<String> fieldPaths) {
        Set<String> deduped = new Set<String>();
        Set<String> seenLowercase = new Set<String>();
        if (fieldPaths == null) {
            return deduped;
        }

        for (String fieldPath : fieldPaths) {
            if (String.isBlank(fieldPath)) {
                continue;
            }
            String lowercaseKey = fieldPath.toLowerCase();
            if (seenLowercase.contains(lowercaseKey)) {
                continue;
            }
            seenLowercase.add(lowercaseKey);
            deduped.add(fieldPath);
        }

        return deduped;
    }

    /**
     * Get displayable field API names for the given record.
     * Resolves record type and falls back to default fields when needed.
     *
     * @param objectApiName API name of object.
     * @param recordId Target record id.
     * @param defaultDisplayFields Default fields when config is missing.
     * @return Set of field API names.
     */
    public static Set<String> getDisplayFields(String objectApiName, String recordId, Set<String> defaultDisplayFields) {
        if (String.isBlank(objectApiName)) {
            return new Set<String>();
        }

        if (String.isBlank(recordId)) {
            return getDefaultFields(defaultDisplayFields);
        }

        String recordTypeName = getRecordTypeName(objectApiName, recordId);
        return getDisplayFieldsByRecordType(objectApiName, recordTypeName, defaultDisplayFields);
    }

    /**
     * Resolve display label for a field using record-type configuration.
     * Returns original field name when no label mapping exists.
     *
     * @param objectApiName API name of object.
     * @param fieldName Field API name.
     * @param recordId Target record id.
     * @return Configured label or original field name.
     */
    public static String getFieldLabel(String objectApiName, String fieldName, String recordId) {
        if (String.isBlank(objectApiName) || String.isBlank(fieldName)) {
            return '';
        }

        if (String.isBlank(recordId)) {
            return fieldName;
        }

        String recordTypeName = getRecordTypeName(objectApiName, recordId);
        return getFieldLabelByRecordType(objectApiName, fieldName, recordTypeName);
    }

    /**
     * Load display fields for a specific object and record type.
     * Uses cache and falls back to default fields when no config exists.
     * Queries without USER_TYPE filter if no results are found.
     *
     * @param objectApiName API name of object.
     * @param recordTypeName Record type developer label.
     * @param defaultDisplayFields Default fields when config is missing.
     * @return Set of displayable field API names.
     */
    public static Set<String> getDisplayFieldsByRecordType(String objectApiName, String recordTypeName, Set<String> defaultDisplayFields) {
        if (String.isBlank(objectApiName) || String.isBlank(recordTypeName)) {
            return getDefaultFields(defaultDisplayFields);
        }

        String cacheKey = buildCacheKey(objectApiName, recordTypeName);
        if (FIELD_CACHE.containsKey(cacheKey)) {
            return FIELD_CACHE.get(cacheKey);
        }

        try {
            List<Core_MDF_Custom_Layout_Configurations__c> configs = [
                SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c, Core_MDF_Record_Name_nm__c
                FROM Core_MDF_Custom_Layout_Configurations__c
                WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
                  AND Core_MDF_User_Type_nm__c = :USER_TYPE
                  AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                  AND API_Visibility__c = true
                ORDER BY Core_MDF_Field_API_Name_txt__c ASC
            ];

            // Fallback query without USER_TYPE filter
            if (configs.isEmpty()) {
                configs = [
                    SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c, Core_MDF_Record_Name_nm__c
                    FROM Core_MDF_Custom_Layout_Configurations__c
                    WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
                      AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                      AND API_Visibility__c = true
                    ORDER BY Core_MDF_Field_API_Name_txt__c ASC
                ];
            }

            Set<String> displayFields = new Set<String>();
            Map<String, String> fieldLabelsByApiName = new Map<String, String>();
            for (Core_MDF_Custom_Layout_Configurations__c config : configs) {
                if (String.isNotBlank(config.Core_MDF_Field_API_Name_txt__c)) {
                    // Prefer the configured lookup display path (Core_MDF_Record_Name_nm__c) over the raw field API name.
                    String fieldApiName = String.isNotBlank(config.Core_MDF_Record_Name_nm__c)
                        ? config.Core_MDF_Record_Name_nm__c.trim()
                        : normalizeConfiguredFieldPath(objectApiName, config.Core_MDF_Field_API_Name_txt__c.trim());
                    displayFields.add(fieldApiName);
                    if (String.isNotBlank(config.Core_MDF_Field_Label_txt__c)) {
                        fieldLabelsByApiName.put(fieldApiName, config.Core_MDF_Field_Label_txt__c.trim());
                    }
                }
            }

            if (displayFields.isEmpty()) {
                displayFields = getDefaultFields(defaultDisplayFields);
            }

            FIELD_CACHE.put(cacheKey, displayFields);
            FIELD_LABEL_CACHE.put(cacheKey, fieldLabelsByApiName);
            return displayFields;
        } catch (QueryException qe) {
            return getDefaultFields(defaultDisplayFields);
        }
    }

    /**
     * Resolve configured label for a field using object and record type.
     * Falls back to field API name when label mapping is unavailable.
     *
     * @param objectApiName API name of object.
     * @param fieldName Field API name.
     * @param recordTypeName Record type developer label.
     * @return Configured field label or original field name.
     */
    public static String getFieldLabelByRecordType(String objectApiName, String fieldName, String recordTypeName) {
        if (String.isBlank(fieldName)) {
            return '';
        }

        if (String.isBlank(objectApiName) || String.isBlank(recordTypeName)) {
            return fieldName;
        }

        String cacheKey = buildCacheKey(objectApiName, recordTypeName);
        if (!FIELD_CACHE.containsKey(cacheKey)) {
            getDisplayFieldsByRecordType(objectApiName, recordTypeName, new Set<String>());
        }

        Map<String, String> fieldLabelsByApiName = FIELD_LABEL_CACHE.get(cacheKey);
        if (fieldLabelsByApiName == null || !fieldLabelsByApiName.containsKey(fieldName)) {
            return fieldName;
        }

        String configuredLabel = fieldLabelsByApiName.get(fieldName);
        return String.isBlank(configuredLabel) ? fieldName : configuredLabel;
    }

    /**
     * Clear in-memory caches for field configuration and label mappings.
     * Useful after metadata/configuration updates.
     */
    public static void clearFieldConfigCache() {
        FIELD_CACHE.clear();
        FIELD_LABEL_CACHE.clear();
        LOOKUP_FIELD_CACHE.clear();
    }

    /**
     * Build cache key for object and record type pair.
     * Ensures consistent key generation across cache operations.
     *
     * @param objectApiName API name of object.
     * @param recordTypeName Record type name.
     * @return Composite cache key.
     */
    private static String buildCacheKey(String objectApiName, String recordTypeName) {
        return objectApiName + '::' + recordTypeName;
    }

    /**
     * Load every field path configured via Core_MDF_Record_Name_nm__c for the object, independent
     * of record type/user type, so configured lookup fields are always fetched and displayed.
     *
     * @param objectApiName API name of object.
     * @return Set of configured lookup field paths (e.g. Core_MDF_Account__r.Name).
     */
    private static Set<String> getConfiguredLookupFields(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return new Set<String>();
        }

        if (LOOKUP_FIELD_CACHE.containsKey(objectApiName)) {
            return LOOKUP_FIELD_CACHE.get(objectApiName);
        }

        Set<String> lookupFields = new Set<String>();
        try {
            for (Core_MDF_Custom_Layout_Configurations__c config : [
                SELECT Core_MDF_Record_Name_nm__c
                FROM Core_MDF_Custom_Layout_Configurations__c
                WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
                  AND Core_MDF_Record_Name_nm__c != null
                  AND API_Visibility__c = true
            ]) {
                if (String.isNotBlank(config.Core_MDF_Record_Name_nm__c)) {
                    lookupFields.add(config.Core_MDF_Record_Name_nm__c.trim());
                }
            }
        } catch (QueryException qe) {
            Core_MDF_CCP_UtilityClass.logError(qe);
        }

        LOOKUP_FIELD_CACHE.put(objectApiName, lookupFields);
        return lookupFields;
    }

    /**
     * Resolve record type name for a given record id.
     * Uses SOQL to safely retrieve record type without schema introspection.
     * Returns null if record not accessible or record type unavailable.
     * Note: SOQL silently filters inaccessible records, so null is returned
     * for both "record doesn't exist" and "no permission" scenarios.
     *
     * @param objectApiName API name of object.
     * @param recordId Target record id.
     * @return Record type name or null when unavailable.
     */
    private static String getRecordTypeName(String objectApiName, String recordId) {
        if (String.isBlank(objectApiName) || String.isBlank(recordId)) {
            return null;
        }

        try {
            String soql = 'SELECT RecordType.Name FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
            SObject recordRow = Database.query(soql);
            
            if (recordRow == null) {
                return null;
            }
            
            SObject recordTypeRow = recordRow.getSObject('RecordType');

            if (recordTypeRow == null) {
                return null;
            }

            Object recordTypeNameValue = recordTypeRow.get('Name');
            return recordTypeNameValue == null ? null : String.valueOf(recordTypeNameValue);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    /**
     * Return safe copy of default display fields.
     * Prevents callers from mutating shared set instances.
     *
     * @param defaultDisplayFields Fallback set from caller.
     * @return New set instance with fallback fields.
     */
    private static Set<String> getDefaultFields(Set<String> defaultDisplayFields) {
        if (defaultDisplayFields == null) {
            return new Set<String>();
        }
        return new Set<String>(defaultDisplayFields);
    }

    private static Set<String> normalizeDisplayFields(String objectApiName, Set<String> displayFields) {
        Set<String> normalizedFields = new Set<String>();
        if (displayFields == null) {
            return normalizedFields;
        }

        for (String fieldName : displayFields) {
            normalizedFields.add(normalizeConfiguredFieldPath(objectApiName, fieldName));
        }

        return normalizedFields;
    }

    private static String normalizeConfiguredFieldPath(String objectApiName, String fieldPath) {
        if (String.isBlank(fieldPath)) {
            return fieldPath;
        }
        return fieldPath;
    }

    private static void enrichMissingRelationshipFields(String objectApiName, String recordId, Map<String, Object> sourceData, Set<String> displayFields) {
        if (String.isBlank(objectApiName) || String.isBlank(recordId) || sourceData == null || displayFields == null || displayFields.isEmpty()) {
            return;
        }

        List<String> missingRelationshipFields = new List<String>();
        for (String fieldPath : displayFields) {
            if (String.isBlank(fieldPath) || !fieldPath.contains('.') || containsFieldPath(sourceData, fieldPath)) {
                continue;
            }
            missingRelationshipFields.add(fieldPath);
        }

        if (missingRelationshipFields.isEmpty()) {
            return;
        }

        try {
            String soql = 'SELECT ' + String.join(missingRelationshipFields, ', ') +
                ' FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
            SObject recordRow = Database.query(soql);
            applyRelationshipFieldsFromRecord(recordRow, missingRelationshipFields, sourceData);
        } catch (Exception ex) {
            // Combined query can fail (e.g. two relationship paths ending in the same field name,
            // "duplicate field selected"), so fall back to fetching each configured field individually
            // rather than losing every lookup field in the response.
            Core_MDF_CCP_UtilityClass.logError(ex);
            fetchRelationshipFieldsIndividually(objectApiName, recordId, missingRelationshipFields, sourceData);
        }
    }

    private static void applyRelationshipFieldsFromRecord(SObject recordRow, List<String> fieldPaths, Map<String, Object> sourceData) {
        if (recordRow == null || fieldPaths == null) {
            return;
        }
        for (String fieldPath : fieldPaths) {
            FieldPathResult resolvedValue = resolveSObjectFieldPath(recordRow, fieldPath);
            if (resolvedValue.found) {
                putFieldPath(sourceData, fieldPath, resolvedValue.value);
            }
        }
    }

    private static void fetchRelationshipFieldsIndividually(String objectApiName, String recordId, List<String> fieldPaths, Map<String, Object> sourceData) {
        if (fieldPaths == null) {
            return;
        }
        for (String fieldPath : fieldPaths) {
            try {
                String soql = 'SELECT ' + fieldPath + ' FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
                SObject recordRow = Database.query(soql);
                applyRelationshipFieldsFromRecord(recordRow, new List<String>{ fieldPath }, sourceData);
            } catch (Exception ex) {
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
        }
    }

    private static FieldPathResult resolveSObjectFieldPath(SObject sourceRecord, String fieldPath) {
        FieldPathResult result = new FieldPathResult();
        if (sourceRecord == null || String.isBlank(fieldPath)) {
            return result;
        }

        List<String> pathSegments = fieldPath.split('\\.');
        SObject currentRecord = sourceRecord;
        for (Integer index = 0; index < pathSegments.size(); index++) {
            String pathSegment = pathSegments[index];
            Boolean isLastSegment = index == pathSegments.size() - 1;

            if (isLastSegment) {
                result.found = true;
                result.value = currentRecord == null ? null : currentRecord.get(pathSegment);
                return result;
            }

            if (currentRecord == null) {
                result.found = true;
                result.value = null;
                return result;
            }

            currentRecord = currentRecord.getSObject(pathSegment);
        }

        return result;
    }

    private static void putFieldPath(Map<String, Object> sourceData, String fieldPath, Object value) {
        if (sourceData == null || String.isBlank(fieldPath)) {
            return;
        }

        if (!fieldPath.contains('.')) {
            sourceData.put(fieldPath, value);
            return;
        }

        List<String> pathSegments = fieldPath.split('\\.');
        Map<String, Object> currentMap = sourceData;
        for (Integer index = 0; index < pathSegments.size(); index++) {
            String pathSegment = pathSegments[index];
            Boolean isLastSegment = index == pathSegments.size() - 1;

            if (isLastSegment) {
                currentMap.put(pathSegment, value);
                return;
            }

            Object nextValue = currentMap.get(pathSegment);
            if (!(nextValue instanceof Map<String, Object>)) {
                nextValue = new Map<String, Object>();
                currentMap.put(pathSegment, nextValue);
            }

            currentMap = (Map<String, Object>)nextValue;
        }
    }

    private static Boolean containsFieldPath(Map<String, Object> sourceData, String fieldPath) {
        if (sourceData == null || String.isBlank(fieldPath)) {
            return false;
        }

        if (!fieldPath.contains('.')) {
            return sourceData.containsKey(fieldPath);
        }

        List<String> pathSegments = fieldPath.split('\\.');
        Object currentValue = sourceData;
        for (String pathSegment : pathSegments) {
            if (!(currentValue instanceof Map<String, Object>)) {
                return false;
            }

            Map<String, Object> currentMap = (Map<String, Object>)currentValue;
            if (!currentMap.containsKey(pathSegment)) {
                return false;
            }

            currentValue = currentMap.get(pathSegment);
        }

        return true;
    }

    private static Object resolveFieldValue(Map<String, Object> sourceData, String fieldPath) {
        if (sourceData == null || String.isBlank(fieldPath)) {
            return null;
        }

        if (!fieldPath.contains('.')) {
            return sourceData.get(fieldPath);
        }

        List<String> pathSegments = fieldPath.split('\\.');
        Object currentValue = sourceData;
        for (String pathSegment : pathSegments) {
            if (!(currentValue instanceof Map<String, Object>)) {
                return null;
            }

            currentValue = ((Map<String, Object>)currentValue).get(pathSegment);
        }

        return currentValue;
    }


    /**
     * Returns response fields, filter fields, allowed operators and labels for an object,
     * section field-view LIKE pattern (fieldViewPattern = API%Filter) and record type (recordTypeName = Client).
     */
    public static FieldConfiguration loadFieldConfiguration(String objectApiName, String fieldViewPattern, String recordTypeName) {
        List<Core_MDF_Custom_Layout_Configurations__c> configurations = new List<Core_MDF_Custom_Layout_Configurations__c>();
        try {
            // Attempt to retrieve layout configurations for the specified object, field view pattern, and record type.
            configurations = getLayoutConfigurations(objectApiName, fieldViewPattern, recordTypeName);
        } catch (Exception ex) {
            // A failed query yields an empty configuration, so callers get a clear invalid-field error.
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        // Build and return the field configuration based on the retrieved layout configurations.
        return buildFieldConfiguration(configurations);
    }

    /** Returns API-visible external-user configuration rows for an object, section field-view LIKE pattern (blank = API%Filter) and record type (blank = Client). */
    public static List<Core_MDF_Custom_Layout_Configurations__c> getLayoutConfigurations(
        String objectApiName,
        String fieldViewPattern,
        String recordTypeName
    ) {
        String objectFilter = String.isBlank(objectApiName) ? '' : objectApiName.trim();
        String fieldViewFilter = String.isBlank(fieldViewPattern) ? fieldViewPattern : fieldViewPattern.trim();
        String recordTypeFilter = String.isBlank(recordTypeName) ? recordTypeName : recordTypeName.trim();
        return [
            SELECT id,Name,Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c, Core_MDF_Record_Name_nm__c,Core_MDF_API_Required_Ind__c,Core_MDF_API_Error_Code__c,Core_MDF_Hidden_Ind__c,
                   API_Visibility__c, Core_MDF_List_Api_Filter_Field_Ind__c, Core_MDF_List_Api_Filter_Operator_nm__c,
                   Core_MDF_Record_Type_Name_txt__c,Core_MDF_Budget_Type_nm__c,
                   Core_MDF_Section_id__r.Core_MDF_List_API_Record_Count_Limit_nbr__c
            FROM Core_MDF_Custom_Layout_Configurations__c
            WHERE Core_MDF_Object_API_Name_txt__c = :objectFilter
              AND Core_MDF_User_Type_nm__c = :Core_MDF_CCP_ConstantClass.CONFIG_USER_TYPE
              AND Core_MDF_Record_Type_Name_txt__c = :recordTypeFilter
              AND API_Visibility__c = true
              AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c LIKE :fieldViewFilter
        ];
    }

    /**
     * Builds a FieldConfiguration from configuration rows. Each row adds its API field and, for lookups,
     * its record-name path. The configured label maps to the field path (lookup labels map to the record-name path).
     * Example: the label "Account" maps to "Core_MDF_Account__r.Name".
     * Hidden fields are omitted from the response label map, while filter mappings are controlled independently
     * by the list API filter flag.
     */
    @TestVisible
    private static FieldConfiguration buildFieldConfiguration(List<Core_MDF_Custom_Layout_Configurations__c> configurations) {
        FieldConfiguration config = new FieldConfiguration();
        if (configurations != null && !configurations.isEmpty() && configurations[0].Core_MDF_Section_id__r != null) {
            MAX_RECORD_LIMIT = configurations[0].Core_MDF_Section_id__r.Core_MDF_List_API_Record_Count_Limit_nbr__c;
        }
          // Iterate over each configuration row to populate the field configuration.
        for (Core_MDF_Custom_Layout_Configurations__c cfg : configurations) {
            String apiPath = cfg.Core_MDF_Field_API_Name_txt__c?.trim();
            String recordNamePath = cfg.Core_MDF_Record_Name_nm__c?.trim();
            String label = cfg.Core_MDF_Field_Label_txt__c?.trim();
            Boolean isLookup = String.isNotBlank(recordNamePath);
            Boolean isFilter = cfg.Core_MDF_List_Api_Filter_Field_Ind__c == true;
           
            // Determine if the field is hidden.
                 Boolean isHidden = cfg.Core_MDF_Hidden_Ind__c == true;
         // Add the API field and, if applicable, the record name path as configured fields.
                addConfiguredField(config, apiPath, isFilter, cfg.Core_MDF_List_Api_Filter_Operator_nm__c);
         // Add the record name path as a configured field if this is a lookup.
                 addConfiguredField(config, recordNamePath, isFilter, cfg.Core_MDF_List_Api_Filter_Operator_nm__c);

            // Labels: the main label points to the record name for lookups, otherwise to the API field.
            String labeledPath = isLookup ? recordNamePath : apiPath;
            String idLabel = isLookup && String.isNotBlank(label) ? label + ' Id' : null;
            if (!isHidden) {
                // Hidden fields are excluded from responses.
                addIfMissing(config.responseFieldApiNameToLabel, labeledPath, label);
            }
            if (isFilter) {
                // Add the field to the filter mapping if it is filterable.
                addIfMissing(config.filterFieldLabelToApiName, label, labeledPath);
            }
        }
        system.debug('Built field configuration: ' + config);
       // Return the fully built field configuration.
        return config;
    }

    /** Adds one field path as a response field and, when filterable, as a filter field with its ';'-separated operators. */
    private static void addConfiguredField(FieldConfiguration config, String fieldPath, Boolean isFilter, String operators) {
        if (String.isBlank(fieldPath)) {
            return;
        }
        config.responseFieldApiNames.add(fieldPath);
        if (!isFilter) {
            return;
        }
        String fieldKey = fieldPath.toLowerCase();
        config.allowedFilterFields.add(fieldPath);
        // Initialize the set of allowed operators for this field if not already present.
        if (!config.operatorsByField.containsKey(fieldKey)) {
            config.operatorsByField.put(fieldKey, new Set<String>());
        }
        // Add each operator to the set of allowed operators for this field.
        for (String operator : String.isBlank(operators) ? new List<String>() : operators.split(';')) {
            if (String.isNotBlank(operator)) {
                config.operatorsByField.get(fieldKey).add(operator.trim().toUpperCase());
            }
        }
    }

    /** Adds key (lowercased) -> value only when both are set and the key is new, so the first row wins. */
    private static void addIfMissing(Map<String, String> target, String key, String value) {
       // Only add the key-value pair if both key and value are set and the key is not already present.
        if (String.isNotBlank(key) && String.isNotBlank(value) && !target.containsKey(key.toLowerCase())) {
           // Add the key-value pair to the map, using the lowercase key.
            target.put(key.toLowerCase(), value);
        }
    }

    /** Field configuration for one object. Filled by buildFieldConfiguration; map keys are lowercase. */
    public class FieldConfiguration {
        public Set<String> responseFieldApiNames = new Set<String>();                      // Fields selected in the response.
        public Set<String> allowedFilterFields = new Set<String>();                        // Fields allowed in filters.
        public Map<String, String> filterFieldLabelToApiName = new Map<String, String>();  // Configured filter label -> API name.
        public Map<String, Set<String>> operatorsByField = new Map<String, Set<String>>(); // Filter field -> allowed operators.
        public Map<String, String> responseFieldApiNameToLabel = new Map<String, String>{ 'id' => 'Id' }; // API name -> response label.
    }

    /**
     * Custom exception for access denied errors.
     * Thrown when user lacks sufficient permissions to view record.
     */
    public class AccessDeniedException extends Exception {}

    private class FieldPathResult {
        public Boolean found = false;
        public Object value;
    }
}