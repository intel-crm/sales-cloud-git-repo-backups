/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Campaign_APIUtil
 * Description     : Simplified wrapper for campaign field configuration retrieval.
 *                   Delegates to Core_MDF_CCP_RestAPI_Utility for all operations.
 * ----------------------------------------------------------------------------------
 */
public class Core_MDF_Campaign_APIUtil {

    /**
     * Get the display fields for Campaign REST API based on campaign record type.
     * Delegates to Core_MDF_CCP_RestAPI_Utility for cached field configuration lookup.
     *
     * @param campaignId The Campaign record ID to determine record type.
     * @return Set of field API names to include in responses.
     */
    public static Set<String> getDisplayFields(String campaignId) {
        try {
            String recordTypeName = String.isBlank(campaignId) ? null : getRecordTypeName(campaignId);
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
                Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                recordTypeName,
                Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );
        } catch (Exception ex) {
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
                Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                null,
                Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );
        }
    }

    /**
     * Get the record type name of a Campaign record by its ID.
     *
     * @param campaignId The Campaign record ID.
     * @return The record type name of the Campaign.
     */
    private static String getRecordTypeName(String campaignId) {
        try {
            Campaign campaign = [SELECT RecordType.Name FROM Campaign WHERE Id = :campaignId LIMIT 1];
            return campaign.RecordType.Name;
        } catch (QueryException qe) {
            return null;
        }
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
            return Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType(
                Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                fieldName,
                recordTypeName
            );
        } catch (Exception ex) {
            return fieldName;
        }
    }

    /**
     * Clear the cache to force refresh of configurations.
     * Clears cache in Core_MDF_CCP_RestAPI_Utility.
     */
    public static void clearCache() {
        Core_MDF_CCP_RestAPI_Utility.clearFieldConfigCache();
    }

}