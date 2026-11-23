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
    
    // Cache for field configurations to avoid repeated SOQL queries
    private static final Map<String, String> RECORD_TYPE_CACHE = new Map<String, String>();

    /**
     * Get the display fields for Campaign REST API based on campaign record type.
     * Queries Core_MDF_Custom_Layout_Configurations__c for dynamic field configuration.
     * 
     * @param campaignId The Campaign record ID to determine record type.
     * @return Set of field API names to include in responses.
     */
    public static Set<String> getDisplayFields(String campaignId) {
        if (String.isBlank(campaignId)) {
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, null);
        }        
        try {
            String recordTypeName = getRecordTypeName(campaignId);
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, recordTypeName);
        } catch (Exception e) {
            System.debug('Error retrieving display fields: ' + e.getMessage());
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, null);
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
        Set<String> displayFields = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, recordTypeName);
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
            return Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType(Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME, fieldName, recordTypeName);
        } catch (Exception ex) {
            System.debug('Error retrieving field label: ' + ex.getMessage());
            return fieldName;
        }
    }

    /**
     * Clear the cache to force refresh of configurations.
     * Useful for testing or manual cache refresh.
     */
    public static void clearCache() {
        RECORD_TYPE_CACHE.clear();
        Core_MDF_CCP_RestAPI_Utility.clearFieldConfigCache();
    }

    /**
     * Custom exception for configuration-related errors.
     */
    public class ConfigurationException extends Exception {}
}