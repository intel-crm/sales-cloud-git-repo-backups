/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_Campaign_FieldConfig
 * Author          : <YourName>
 * Created Date    : Jun 15, 2026
 * Description     : Configurable field mapping for Campaign REST API response filtering.
 *                   Queries fields dynamically from Core_MDF_Custom_Layout_Configurations__c
 *                   based on object type, user type, record type, and visibility settings.
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public class Core_MDF_Campaign_FieldConfig {
    
    // Constants
    private static final String OBJECT_API_NAME = 'Campaign';
    private static final String USER_TYPE = 'External User';
    private static final String CONFIG_OBJECT = 'Core_MDF_Custom_Layout_Configurations__c';
    
    // Cache for field configurations to avoid repeated SOQL queries
    private static final Map<String, Set<String>> FIELD_CACHE = new Map<String, Set<String>>();
    private static final Map<String, String> RECORD_TYPE_CACHE = new Map<String, String>();
    private static final Map<String, Map<String, String>> FIELD_LABEL_CACHE = new Map<String, Map<String, String>>();
    
    // Default fallback fields if no configuration is found
    private static final Set<String> DEFAULT_FIELDS = new Set<String>{
        'Id',
        'Name',
        'Status',
        'StartDate',
        'EndDate',
        'IsActive'
    };

    /**
     * Get the display fields for Campaign REST API based on campaign record type.
     * Queries Core_MDF_Custom_Layout_Configurations__c for dynamic field configuration.
     * 
     * @param campaignId The Campaign record ID to determine record type.
     * @return Set of field API names to include in responses.
     */
    public static Set<String> getDisplayFields(String campaignId) {
        if (String.isBlank(campaignId)) {
            return new Set<String>(DEFAULT_FIELDS);
        }        
        try {
            String recordTypeName = getRecordTypeName(campaignId);
            return getDisplayFieldsByRecordType(recordTypeName);
        } catch (Exception e) {
            System.debug('Error retrieving display fields: ' + e.getMessage());
            return new Set<String>(DEFAULT_FIELDS);
        }
    }

    /**
     * Get the display fields based on record type name.
     * Uses caching to minimize SOQL queries.
     * 
     * @param recordTypeName The record type name of the Campaign.
     * @return Set of field API names configured for this record type.
     */
    public static Set<String> getDisplayFieldsByRecordType(String recordTypeName) {
        if (String.isBlank(recordTypeName)) {
            return new Set<String>(DEFAULT_FIELDS);
        }        
        // Check cache first
        if (FIELD_CACHE.containsKey(recordTypeName)) {
            System.debug('Returning cached fields for record type: ' + recordTypeName);
            return FIELD_CACHE.get(recordTypeName);
        }        
        try {
            System.debug('Querying configuration for - Object: ' + OBJECT_API_NAME + ', UserType: ' + USER_TYPE + ', RecordType: ' + recordTypeName);
            
            // Query configuration from custom object
            List<Core_MDF_Custom_Layout_Configurations__c> configs = 
                [SELECT Core_MDF_Field_API_Name_txt__c, Core_MDF_Field_Label_txt__c
                 FROM Core_MDF_Custom_Layout_Configurations__c
                 WHERE Core_MDF_Object_API_Name_txt__c = :OBJECT_API_NAME
                   AND Core_MDF_User_Type_nm__c = :USER_TYPE
                   AND Core_MDF_Record_Type_Name_txt__c = :recordTypeName
                   AND API_Visibility__c = true
                 ORDER BY Core_MDF_Field_API_Name_txt__c ASC];
            
            System.debug('Found ' + configs.size() + ' configuration records');
            
            Set<String> displayFields = new Set<String>();
            Map<String, String> fieldLabelsByApiName = new Map<String, String>();
            for (Core_MDF_Custom_Layout_Configurations__c config : configs) {
                if (String.isNotBlank(config.Core_MDF_Field_API_Name_txt__c)) {
                    String fieldApiName = config.Core_MDF_Field_API_Name_txt__c.trim();
                    displayFields.add(fieldApiName);
                    System.debug('Config Field: ' + fieldApiName + ' -> Label: ' + config.Core_MDF_Field_Label_txt__c);
                    if (String.isNotBlank(config.Core_MDF_Field_Label_txt__c)) {
                        fieldLabelsByApiName.put(fieldApiName, config.Core_MDF_Field_Label_txt__c.trim());
                    }
                }
            }            
            // Use default fields if no configuration found
            if (displayFields.isEmpty()) {
                System.debug('No configuration found, using DEFAULT_FIELDS');
                displayFields = new Set<String>(DEFAULT_FIELDS);
            }            
            // Cache the result
            FIELD_CACHE.put(recordTypeName, displayFields);
            FIELD_LABEL_CACHE.put(recordTypeName, fieldLabelsByApiName);
            return displayFields;            
        } catch (QueryException qe) {
            System.debug('Query error retrieving field configuration: ' + qe.getMessage());
            return new Set<String>(DEFAULT_FIELDS);
        }
    }

    /**
     * Get the record type name of a Campaign record by its ID.
     * Uses caching to minimize SOQL queries.
     * 
     * @param campaignId The Campaign record ID.
     * @return The record type name of the Campaign.
     */
    private static String getRecordTypeName(String campaignId) {
        // Check cache first
        if (RECORD_TYPE_CACHE.containsKey(campaignId)) {
            System.debug('Returning cached record type for campaign: ' + campaignId);
            return RECORD_TYPE_CACHE.get(campaignId);
        }        
        try {
            Campaign campaign = [SELECT RecordType.Name FROM Campaign WHERE Id = :campaignId LIMIT 1];            
            String recordTypeName = campaign.RecordType.Name;
            System.debug('Campaign ' + campaignId + ' has RecordType: ' + recordTypeName);
            RECORD_TYPE_CACHE.put(campaignId, recordTypeName);
            return recordTypeName;            
        } catch (QueryException qe) {
            System.debug('Error retrieving Campaign record type: ' + qe.getMessage());
            throw new ConfigurationException('Unable to retrieve record type for Campaign: ' + campaignId);
        }
    }

    /**
     * Check if a field is configured for display based on campaign ID.
     * 
     * @param fieldName The field API name to check.
     * @param campaignId The Campaign record ID.
     * @return Boolean indicating if field should be displayed.
     */
    public static Boolean isFieldDisplayable(String fieldName, String campaignId) {
        Set<String> displayFields = getDisplayFields(campaignId);
        return displayFields.contains(fieldName);
    }

    /**
     * Check if a field is configured for display based on record type name.
     * 
     * @param fieldName The field API name to check.
     * @param recordTypeName The record type name.
     * @return Boolean indicating if field should be displayed.
     */
    public static Boolean isFieldDisplayableByRecordType(String fieldName, String recordTypeName) {
        Set<String> displayFields = getDisplayFieldsByRecordType(recordTypeName);
        return displayFields.contains(fieldName);
    }

    /**
     * Get user-friendly label for a field based on campaign ID.
     * 
     * @param fieldName The field API name.
     * @param campaignId The Campaign record ID.
     * @return User-friendly label or original field name.
     */
    public static String getFieldLabel(String fieldName, String campaignId) {
        if (String.isBlank(fieldName)) {
            return '';
        }

        if (String.isBlank(campaignId)) {
            return fieldName;
        }

        try {
            String recordTypeName = getRecordTypeName(campaignId);
            return getFieldLabelByRecordType(fieldName, recordTypeName);
        } catch (Exception ex) {
            System.debug('Error retrieving field label: ' + ex.getMessage());
            return fieldName;
        }
    }

    /**
     * Get user-friendly label for a field based on record type name.
     * 
     * @param fieldName The field API name.
     * @param recordTypeName The record type name.
     * @return User-friendly label or original field name.
     */
    public static String getFieldLabelByRecordType(String fieldName, String recordTypeName) {
        if (String.isBlank(fieldName)) {
            return '';
        }

        if (String.isBlank(recordTypeName)) {
            return fieldName;
        }

        if (!FIELD_CACHE.containsKey(recordTypeName)) {
            getDisplayFieldsByRecordType(recordTypeName);
        }

        Map<String, String> fieldLabelsByApiName = FIELD_LABEL_CACHE.get(recordTypeName);
        if (fieldLabelsByApiName == null || !fieldLabelsByApiName.containsKey(fieldName)) {
            return fieldName;
        }

        String configuredLabel = fieldLabelsByApiName.get(fieldName);
        return String.isBlank(configuredLabel) ? fieldName : configuredLabel;
    }

    /**
     * Clear the cache to force refresh of configurations.
     * Useful for testing or manual cache refresh.
     */
    public static void clearCache() {
        FIELD_CACHE.clear();
        RECORD_TYPE_CACHE.clear();
        FIELD_LABEL_CACHE.clear();
    }

    /**
     * Custom exception for configuration-related errors.
     */
    public class ConfigurationException extends Exception {}
}