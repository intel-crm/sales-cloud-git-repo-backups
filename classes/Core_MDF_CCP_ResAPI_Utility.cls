public with sharing class Core_MDF_CCP_ResAPI_Utility {

    private static final String SF_INSTANCE_URL = URL.getOrgDomainURL().toExternalForm();
    private static final String SF_API_VERSION = '66.0';
    private static final String USER_TYPE = 'External User';
    private static final Map<String, Set<String>> FIELD_CACHE = new Map<String, Set<String>>();
    private static final Map<String, Map<String, String>> FIELD_LABEL_CACHE = new Map<String, Map<String, String>>();

    public static Map<String, Object> getFilteredRecord(String objectApiName, String recordId) {
        try {
            System.debug('=== Generic REST API Debug ===');
            System.debug('Object API Name: ' + objectApiName);
            System.debug('Record ID: ' + recordId);

            String sfEndpoint = SF_INSTANCE_URL + '/services/data/v' + SF_API_VERSION + '/sobjects/' + objectApiName + '/' + recordId;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(sfEndpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() != 200) {
                System.debug(LoggingLevel.ERROR, 'Standard API Error: ' + response.getStatusCode());
                return null;
            }

            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('Full Response from Standard API: ' + JSON.serialize(fullResponse));

            Map<String, Object> filteredData = filterFields(objectApiName, fullResponse, recordId);
            System.debug('Filtered Data: ' + JSON.serialize(filteredData));
            return filteredData;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception in getFilteredRecord: ' + ex.getMessage());
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }

    public static Map<String, Object> filterFields(String objectApiName, Map<String, Object> fullResponse, String recordId) {
        Map<String, Object> filteredData = new Map<String, Object>();

        Set<String> displayFields = getDisplayFields(objectApiName, recordId);
        System.debug('Display Fields to filter for ' + objectApiName + ': ' + displayFields);

        for (String fieldName : displayFields) {
            System.debug('Checking field: ' + fieldName + ', exists in response: ' + fullResponse.containsKey(fieldName));

            if (fullResponse.containsKey(fieldName)) {
                String displayLabel = getFieldLabel(objectApiName, fieldName, recordId);
                Object fieldValue = fullResponse.get(fieldName);
                System.debug('Field: ' + fieldName + ' -> Label: ' + displayLabel + ' -> Value: ' + fieldValue);
                filteredData.put(displayLabel, fieldValue);
            }
        }

        return filteredData;
    }

    public static Set<String> getDisplayFields(String objectApiName, String recordId) {
        if (String.isBlank(objectApiName) || String.isBlank(recordId)) {
            return getDefaultFields(objectApiName);
        }

        if (Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME.equalsIgnoreCase(objectApiName)) {
            return Core_MDF_Campaign_APIUtil.getDisplayFields(recordId);
        }

        return getDefaultFields(objectApiName);
    }

    public static String getFieldLabel(String objectApiName, String fieldName, String recordId) {
        if (String.isBlank(objectApiName) || String.isBlank(fieldName)) {
            return '';
        }

        if (Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME.equalsIgnoreCase(objectApiName)) {
            return Core_MDF_Campaign_APIUtil.getFieldLabel(fieldName, recordId);
        }

        return fieldName;
    }

    public static Set<String> getDisplayFieldsByRecordType(String objectApiName, String recordTypeName) {
        if (String.isBlank(objectApiName) || String.isBlank(recordTypeName)) {
            return getDefaultFields(objectApiName);
        }

        String cacheKey = buildCacheKey(objectApiName, recordTypeName);
        if (FIELD_CACHE.containsKey(cacheKey)) {
            System.debug('Returning cached fields for key: ' + cacheKey);
            return FIELD_CACHE.get(cacheKey);
        }

        try {
            System.debug('Querying configuration for - Object: ' + objectApiName + ', UserType: ' + USER_TYPE + ', RecordType: ' + recordTypeName);

            List<Core_MDF_Custom_Layout_Configurations__c> configs = [
                SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c
                FROM Core_MDF_Custom_Layout_Configurations__c
                WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
                  AND Core_MDF_User_Type_nm__c = :USER_TYPE
                  AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                  AND API_Visibility__c = true
                ORDER BY Core_MDF_Field_API_Name_txt__c ASC
            ];

            System.debug('Found ' + configs.size() + ' configuration records with UserType filter');

            if (configs.isEmpty()) {
                System.debug('No configs found for UserType ' + USER_TYPE + ', trying without UserType filter');
                configs = [
                    SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c
                    FROM Core_MDF_Custom_Layout_Configurations__c
                    WHERE Core_MDF_Object_API_Name_txt__c = :objectApiName
                      AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                      AND API_Visibility__c = true
                    ORDER BY Core_MDF_Field_API_Name_txt__c ASC
                ];
                System.debug('Found ' + configs.size() + ' configuration records without UserType filter');
            }

            Set<String> displayFields = new Set<String>();
            Map<String, String> fieldLabelsByApiName = new Map<String, String>();
            for (Core_MDF_Custom_Layout_Configurations__c config : configs) {
                if (String.isNotBlank(config.Core_MDF_Field_API_Name_txt__c)) {
                    String fieldApiName = config.Core_MDF_Field_API_Name_txt__c.trim();
                    displayFields.add(fieldApiName);
                    if (String.isNotBlank(config.Core_MDF_Field_Label_txt__c)) {
                        fieldLabelsByApiName.put(fieldApiName, config.Core_MDF_Field_Label_txt__c.trim());
                    }
                }
            }

            if (displayFields.isEmpty()) {
                System.debug('No configuration found, using default fields for object: ' + objectApiName);
                displayFields = getDefaultFields(objectApiName);
            }

            FIELD_CACHE.put(cacheKey, displayFields);
            FIELD_LABEL_CACHE.put(cacheKey, fieldLabelsByApiName);
            return displayFields;
        } catch (QueryException qe) {
            System.debug('Query error retrieving field configuration: ' + qe.getMessage());
            return getDefaultFields(objectApiName);
        }
    }

    public static String getFieldLabelByRecordType(String objectApiName, String fieldName, String recordTypeName) {
        if (String.isBlank(fieldName)) {
            return '';
        }

        if (String.isBlank(objectApiName) || String.isBlank(recordTypeName)) {
            return fieldName;
        }

        String cacheKey = buildCacheKey(objectApiName, recordTypeName);
        if (!FIELD_CACHE.containsKey(cacheKey)) {
            getDisplayFieldsByRecordType(objectApiName, recordTypeName);
        }

        Map<String, String> fieldLabelsByApiName = FIELD_LABEL_CACHE.get(cacheKey);
        if (fieldLabelsByApiName == null || !fieldLabelsByApiName.containsKey(fieldName)) {
            return fieldName;
        }

        String configuredLabel = fieldLabelsByApiName.get(fieldName);
        return String.isBlank(configuredLabel) ? fieldName : configuredLabel;
    }

    public static void clearFieldConfigCache() {
        FIELD_CACHE.clear();
        FIELD_LABEL_CACHE.clear();
    }

    private static String buildCacheKey(String objectApiName, String recordTypeName) {
        return objectApiName + '::' + recordTypeName;
    }

    private static Set<String> getDefaultFields(String objectApiName) {
        if (Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME.equalsIgnoreCase(objectApiName)) {
            return new Set<String>{
                'Id',
                'Name',
                'Status',
                'StartDate',
                'EndDate',
                'IsActive'
            };
        }

        return new Set<String>();
    }
}