/**
 * @description Wrapper for PFC REST input payload and claim-to-sObject field mapping.
 */
public class Core_MDF_PFC_RestAPI_InputWrapper {
    public static final String KEY_CLAIM_DETAILS = 'claimDetails';

    private static final String CLAIM_OBJECT_API_NAME = 'PartnerFundClaim';
    private static final String CONFIG_USER_TYPE = 'External User';
    private static final String ALL_RECORD_TYPES_CACHE_KEY = '*';

    private static final Map<String, List<ClaimFieldConfig>> CLAIM_FIELD_CONFIG_CACHE = new Map<String, List<ClaimFieldConfig>>();

    /**
     * @description Payload field contract for one claim field, driven by Core_MDF_Custom_Layout_Configurations__c.
     */
    public class ClaimFieldConfig {
        public String payloadFieldName;
        public String fieldApiName;
        public Boolean isRequired;
        public String errorCode;
        public String budgetType;
    }

    /**
     * @description Field configuration for the given program/record type and activity budget type, in configured sequence.
     *              Any field with a budget-type-specific row (not just bank supplier number) resolves to the row matching
     *              the activity's budget type, falling back to the budget-type-agnostic row when none matches.
     */
    public static List<ClaimFieldConfig> getClaimFieldConfigs(String recordTypeName, String activityBudgetType) {
        String recordTypeKey = String.isBlank(recordTypeName) ? '' : recordTypeName.trim();
        String budgetTypeKey = String.isBlank(activityBudgetType) ? '' : activityBudgetType.trim();
        String cacheKey = recordTypeKey + '|' + budgetTypeKey;
        if (CLAIM_FIELD_CONFIG_CACHE.containsKey(cacheKey)) {
            return CLAIM_FIELD_CONFIG_CACHE.get(cacheKey);
        }

        List<ClaimFieldConfig> allConfigs = getClaimFieldConfigs(recordTypeName);
        Map<String, ClaimFieldConfig> resolvedByField = resolveConfigsByBudgetType(allConfigs, budgetTypeKey);

        List<ClaimFieldConfig> configs = new List<ClaimFieldConfig>();
        Set<String> addedFields = new Set<String>();
        for (ClaimFieldConfig config : allConfigs) {
            String fieldKey = config.payloadFieldName.toLowerCase();
            if (addedFields.contains(fieldKey)) {
                continue;
            }
            addedFields.add(fieldKey);
            // A budget-specific-only field with no row matching this activity's budget type has nothing to enforce here.
            ClaimFieldConfig resolvedConfig = resolvedByField.get(fieldKey);
            if (resolvedConfig != null) {
                configs.add(resolvedConfig);
            }
        }

        CLAIM_FIELD_CONFIG_CACHE.put(cacheKey, configs);
        return configs;
    }

    private static Map<String, ClaimFieldConfig> resolveConfigsByBudgetType(List<ClaimFieldConfig> allConfigs, String budgetTypeKey) {
        Map<String, ClaimFieldConfig> matchingByField = new Map<String, ClaimFieldConfig>();
        Map<String, ClaimFieldConfig> fallbackByField = new Map<String, ClaimFieldConfig>();
        Set<String> fieldsWithBudgetSpecificRow = new Set<String>();

        for (ClaimFieldConfig config : allConfigs) {
            String fieldKey = config.payloadFieldName.toLowerCase();
            if (String.isBlank(config.budgetType)) {
                if (!fallbackByField.containsKey(fieldKey)) {
                    fallbackByField.put(fieldKey, config);
                }
                continue;
            }
            fieldsWithBudgetSpecificRow.add(fieldKey);
            if (!matchingByField.containsKey(fieldKey) && budgetTypesMatch(config.budgetType, budgetTypeKey)) {
                matchingByField.put(fieldKey, config);
            }
        }

        Map<String, ClaimFieldConfig> resolvedByField = new Map<String, ClaimFieldConfig>(fallbackByField);
        resolvedByField.putAll(matchingByField);
        for (String fieldKey : fieldsWithBudgetSpecificRow) {
            if (!matchingByField.containsKey(fieldKey) && fallbackByField.containsKey(fieldKey)) {
                // A default row must not make the field mandatory when no budget-specific row matches.
                ClaimFieldConfig fallback = fallbackByField.get(fieldKey);
                fallback.isRequired = false;
                resolvedByField.put(fieldKey, fallback);
            }
        }
        return resolvedByField;
    }

    /**
     * @description Field configuration for the given program/record type, in configured sequence.
     */
    public static List<ClaimFieldConfig> getClaimFieldConfigs(String recordTypeName) {
        String cacheKey = String.isBlank(recordTypeName) ? '' : recordTypeName.trim();
        if (CLAIM_FIELD_CONFIG_CACHE.containsKey(cacheKey)) {
            return CLAIM_FIELD_CONFIG_CACHE.get(cacheKey);
        }

        List<ClaimFieldConfig> configs = new List<ClaimFieldConfig>();
        if (String.isNotBlank(cacheKey)) {
            for (Core_MDF_Custom_Layout_Configurations__c record : queryClaimFieldConfigurationRecords(cacheKey, 200)) {
                ClaimFieldConfig fieldConfig = toFieldConfig(record);
                if (fieldConfig != null) {
                    configs.add(fieldConfig);
                }
            }
        }

        CLAIM_FIELD_CONFIG_CACHE.put(cacheKey, configs);
        return configs;
    }

    /**
     * @description Field configuration merged across every program, for stages where the claim's program is not yet resolved.
     *              A field is treated as required here only when it is required for every program.
     */
    public static List<ClaimFieldConfig> getAllClaimFieldConfigs() {
        if (CLAIM_FIELD_CONFIG_CACHE.containsKey(ALL_RECORD_TYPES_CACHE_KEY)) {
            return CLAIM_FIELD_CONFIG_CACHE.get(ALL_RECORD_TYPES_CACHE_KEY);
        }

                List<ClaimFieldConfig> configs = new List<ClaimFieldConfig>();
                Map<String, ClaimFieldConfig> configByPayloadField = new Map<String, ClaimFieldConfig>();
                for (Core_MDF_Custom_Layout_Configurations__c record : queryClaimFieldConfigurationRecords(null, 2000)) {
            ClaimFieldConfig fieldConfig = toFieldConfig(record);
            if (fieldConfig == null) {
                continue;
            }
            ClaimFieldConfig existing = configByPayloadField.get(fieldConfig.payloadFieldName.toLowerCase());
            if (existing == null) {
                configByPayloadField.put(fieldConfig.payloadFieldName.toLowerCase(), fieldConfig);
                configs.add(fieldConfig);
            } else {
                existing.isRequired = existing.isRequired && fieldConfig.isRequired;
                if (String.isBlank(existing.errorCode)) {
                    existing.errorCode = fieldConfig.errorCode;
                }
            }
        }

        CLAIM_FIELD_CONFIG_CACHE.put(ALL_RECORD_TYPES_CACHE_KEY, configs);
        return configs;
    }

    private static List<Core_MDF_Custom_Layout_Configurations__c> queryClaimFieldConfigurationRecords(
        String recordTypeName,
        Integer recordLimit
    ) {
        String soql =
            'SELECT Core_MDF_Field_Label_txt__c, Core_MDF_Field_API_Name_txt__c, ' +
            'Core_MDF_API_Required_Ind__c, Core_MDF_API_Error_Code__c, ' +
            'Core_MDF_Budget_Type_nm__c ' +
            'FROM Core_MDF_Custom_Layout_Configurations__c ' +
            'WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName ' +
            'AND Core_MDF_User_Type_nm__c = :userType ' +
            'AND API_Visibility__c = true ' +
            'AND Core_MDF_Section_id__r.Core_MDF_Field_View_nm__c = :fieldView';

        Map<String, Object> bindVariables = new Map<String, Object>{
            'objectApiName' => CLAIM_OBJECT_API_NAME,
            'userType' => CONFIG_USER_TYPE,
            'fieldView' => 'API Create'
        };
        if (String.isNotBlank(recordTypeName)) {
            soql += ' AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName';
            bindVariables.put('recordTypeName', recordTypeName);
        }

        soql += ' ORDER BY Core_MDF_Sequence_No_nbr__c NULLS LAST, Core_MDF_Field_Label_txt__c LIMIT ' + String.valueOf(recordLimit);
        return (List<Core_MDF_Custom_Layout_Configurations__c>) Database.queryWithBinds(
            soql,
            bindVariables,
            AccessLevel.SYSTEM_MODE
        );
    }

    private static ClaimFieldConfig toFieldConfig(Core_MDF_Custom_Layout_Configurations__c record) {
        if (String.isBlank(record.Core_MDF_Field_Label_txt__c) || String.isBlank(record.Core_MDF_Field_API_Name_txt__c)) {
            return null;
        }
        ClaimFieldConfig fieldConfig = new ClaimFieldConfig();
        fieldConfig.payloadFieldName = record.Core_MDF_Field_Label_txt__c.trim();
        fieldConfig.fieldApiName = record.Core_MDF_Field_API_Name_txt__c.trim();
        fieldConfig.isRequired = record.Core_MDF_API_Required_Ind__c == true;
        fieldConfig.budgetType = String.isBlank(record.Core_MDF_Budget_Type_nm__c)
            ? null
            : record.Core_MDF_Budget_Type_nm__c.trim();
        fieldConfig.errorCode = String.isBlank(record.Core_MDF_API_Error_Code__c)
            ? null
            : record.Core_MDF_API_Error_Code__c.trim();
        return fieldConfig;
    }

    private static Boolean budgetTypesMatch(String configuredBudgetType, String activityBudgetType) {
        if (String.isBlank(configuredBudgetType) || String.isBlank(activityBudgetType)) {
            return false;
        }
        return configuredBudgetType.equalsIgnoreCase(activityBudgetType);
    }

    public List<ClaimInput> claimDetails { get; set; }

    public List<ClaimInput> getClaimDetails() {
        return claimDetails != null ? claimDetails : new List<ClaimInput>();
    }

    public static Core_MDF_PFC_RestAPI_InputWrapper parse(String requestBody) {
        Core_MDF_PFC_RestAPI_InputWrapper wrapper = new Core_MDF_PFC_RestAPI_InputWrapper();
        wrapper.claimDetails = new List<ClaimInput>();

        if (String.isBlank(requestBody)) {
            return wrapper;
        }

        Object payloadObj = JSON.deserializeUntyped(requestBody);
        if (!(payloadObj instanceof Map<String, Object>)) {
            throw new IllegalArgumentException('Invalid payload structure');
        }

        Map<String, Object> payloadMap = (Map<String, Object>) payloadObj;
        Object claimsObj = payloadMap.get(KEY_CLAIM_DETAILS);
        if (!(claimsObj instanceof List<Object>)) {
            throw new IllegalArgumentException(KEY_CLAIM_DETAILS + ' missing');
        }

        for (Object rowObj : (List<Object>) claimsObj) {
            if (!(rowObj instanceof Map<String, Object>)) {
                wrapper.claimDetails.add(null);
                continue;
            }
            try {
                ClaimInput claim = new ClaimInput();
                claim.payloadFields = (Map<String, Object>) rowObj;
                wrapper.claimDetails.add(claim);
            } catch (Exception ex) {
                wrapper.claimDetails.add(null);
            }
        }

        return wrapper;
    }

    public class ClaimInput {
        private Map<String, Object> payloadFields = new Map<String, Object>();

        public Object getValue(String payloadFieldName) {
            if (String.isBlank(payloadFieldName)) {
                return null;
            }
            if (payloadFields.containsKey(payloadFieldName)) {
                return payloadFields.get(payloadFieldName);
            }
            for (String key : payloadFields.keySet()) {
                if (key.equalsIgnoreCase(payloadFieldName)) {
                    return payloadFields.get(key);
                }
            }
            return null;
        }

        public String getText(String payloadFieldName) {
            Object value = getValue(payloadFieldName);
            return value == null ? null : String.valueOf(value).trim();
        }

        public Decimal getNumber(String payloadFieldName) {
            Object value = getValue(payloadFieldName);
            if (value == null) {
                return null;
            }
            try {
                return Decimal.valueOf(String.valueOf(value).trim());
            } catch (Exception ex) {
                return null;
            }
        }

        public void setValue(String payloadFieldName, Object value) {
            if (String.isBlank(payloadFieldName)) {
                return;
            }
            String existingKey = null;
            for (String key : payloadFields.keySet()) {
                if (key.equalsIgnoreCase(payloadFieldName)) {
                    existingKey = key;
                    break;
                }
            }
            if (existingKey != null) {
                payloadFields.remove(existingKey);
            }
            payloadFields.put(payloadFieldName, value);
        }

        public PartnerFundClaim toPartnerFundClaim(Id requestId, Id claimSubmitterId, Id bankId, String programName) {
            PartnerFundClaim claim = new PartnerFundClaim();

            List<ClaimFieldConfig> claimFieldConfigs = getClaimFieldConfigs(programName);
            if (claimFieldConfigs.isEmpty()) {
                return claim;
            }

            // Values already resolved by the service layer take precedence over the raw payload.
            Map<String, Object> resolvedValues = new Map<String, Object>{
                Core_MDF_PFC_APIUtil.FIELD_ACTIVITY_NUMBER.toLowerCase() => requestId,
                Core_MDF_PFC_APIUtil.FIELD_CLAIM_SUBMITTER.toLowerCase() => claimSubmitterId,
                Core_MDF_PFC_APIUtil.FIELD_BANK_SUPPLIER_NUMBER.toLowerCase() => bankId
            };
            Map<String, Schema.SObjectField> claimFields = PartnerFundClaim.SObjectType.getDescribe().fields.getMap();

            for (ClaimFieldConfig fieldConfig : claimFieldConfigs) {
                if (fieldConfig.fieldApiName == null || !claimFields.containsKey(fieldConfig.fieldApiName)) {
                    continue;
                }
                String payloadKey = fieldConfig.payloadFieldName.toLowerCase();
                Object rawValue = resolvedValues.containsKey(payloadKey)
                    ? resolvedValues.get(payloadKey)
                    : getRawFieldValue(fieldConfig.payloadFieldName, fieldConfig.fieldApiName);
                if (rawValue != null) {
                    applyDynamicValue(claim, fieldConfig.fieldApiName, rawValue, claimFields.get(fieldConfig.fieldApiName).getDescribe());
                }
            }

            return claim;
        }

        private Object getRawFieldValue(String payloadFieldName, String fieldApiName) {
            Object value = getValue(payloadFieldName);
            return value != null ? value : getValue(fieldApiName);
        }

        private void applyDynamicValue(PartnerFundClaim claim, String fieldApiName, Object rawValue, Schema.DescribeFieldResult fieldDescribe) {
            // An omitted value arrives as an empty string; converting it would throw for Id/Date/number fields.
            if (rawValue instanceof String && String.isBlank((String) rawValue)) {
                return;
            }

            Schema.DisplayType fieldType = fieldDescribe.getType();
            Object convertedValue = rawValue;
            if (fieldType == Schema.DisplayType.DATE) {
                convertedValue = Date.valueOf(String.valueOf(rawValue));
            } else if (fieldType == Schema.DisplayType.DATETIME) {
                convertedValue = (Datetime) JSON.deserialize('"' + String.valueOf(rawValue) + '"', Datetime.class);
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                convertedValue = Boolean.valueOf(String.valueOf(rawValue));
            } else if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.PERCENT) {
                convertedValue = Decimal.valueOf(String.valueOf(rawValue));
            } else if (fieldType == Schema.DisplayType.REFERENCE) {
                convertedValue = Id.valueOf(String.valueOf(rawValue));
            }
            applyValue(claim, fieldApiName, convertedValue);
        }

        private void applyValue(PartnerFundClaim record, String fieldApiName, Object value) {
            if (String.isNotBlank(fieldApiName) && value != null) {
                if (value instanceof String && String.isBlank((String) value)) {
                    return;
                }
                if (value instanceof Decimal) {
                    record.put(fieldApiName, (Decimal) value);
                } else {
                    record.put(fieldApiName, value);
                }
            }
        }
    }

}