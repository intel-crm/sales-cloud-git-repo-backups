/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Campaign_APIUtil
 * Description     : Simplified wrapper for campaign field configuration retrieval.
 *                   Delegates to Core_MDF_CCP_RestAPI_Utility for all operations.
 * ----------------------------------------------------------------------------------
 */
public class Core_MDF_Campaign_APIUtil {

    public static final String CAMPAIGN_SEGMENT1 = '/v1.0/partnercenter/campaigndetails/';
    public static final String CAMPAIGN_SEGMENT = '/v1.0/partnercenter/campaign/';
    public static final Integer MAX_CHILD_ROWS = 200;
    public static final String FIELD_DISPLAY_PARAM = 'fielddisplay';
    public static final String FIELD_DISPLAY_LABEL = 'label';
    public static final String FIELD_DISPLAY_TECHNICAL_NAME = 'technicalname';    
    public static final String RESPONSE_KEY_CAMPAIGN_BUDGETS = 'Campaign Budgets';
    public static final String RESPONSE_KEY_CAMPAIGN_PURPOSE = 'Campaign Purpose';
    public static final String RESPONSE_CODE_CATEGORY_CAMPAIGN = 'Campaign';
    public static final String ERROR_MESSAGE_CONFIG_MISSING = 'Error configuration is missing for this API error code';    
    public static final String SUCCESS_200 = '200';
    public static final Integer HTTP_STATUS_500 = 500;    
    public static final String CODE_7002_CAMPAIGN_ID_EMPTY = '7002';
    public static final String CODE_7003_CAMPAIGN_INTERNAL_SERVER_ERROR = '7003';
    public static final String CODE_7004_INVALID_CAMPAIGN_ID = '7004';
    public static final String CODE_7005_INVALID_FIELD_DISPLAY = '7005';
    public static final String CODE_7008_INSUFFICIENT_PERMISSIONS = '7008';
    public static final String MSG_GENERIC_ERROR = 'An error occurred processing your request';    
    public static final String MSG_CAMPAIGN_DETAILS_RETRIEVED = 'Campaign details retrieved successfully';    
    public static final String CAMPAIGN_OBJECT_API_NAME = 'Campaign';
    public static final String CAMPAIGN_BUDGETS_OBJECT_API = 'Core_MDF_Campaign_Budgets__c';
    public static final String CAMPAIGN_OUTCOMES_OBJECT_API = 'Core_MDF_Campaign_Outcomes__c';
    public static final String CAMPAIGN_KEY_PREFIX = '701';
    public static final Integer SALESFORCE_ID_LENGTH_15 = 15;
    public static final Integer SALESFORCE_ID_LENGTH_18 = 18;
    public static final Set<String> DEFAULT_CAMPAIGN_DISPLAY_FIELDS = new Set<String>{
        'Id',
        'Name',
        'Status',
        'StartDate',
        'EndDate',
        'IsActive'
    };

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
                Core_MDF_Campaign_APIUtil.CAMPAIGN_OBJECT_API_NAME,
                recordTypeName,
                Core_MDF_Campaign_APIUtil.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );
        } catch (Exception ex) {
            return Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
                Core_MDF_Campaign_APIUtil.CAMPAIGN_OBJECT_API_NAME,
                null,
                Core_MDF_Campaign_APIUtil.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
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
                Core_MDF_Campaign_APIUtil.CAMPAIGN_OBJECT_API_NAME,
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