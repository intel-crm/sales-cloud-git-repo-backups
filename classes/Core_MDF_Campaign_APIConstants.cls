/**
 * Centralized constants for Campaign REST API.
 * Reference pattern: Core_MDF_PFR_RestAPIConstants.
 */
public class Core_MDF_Campaign_APIConstants {
    // --------------------------------------------------
    // API Route and Request Parameter Constants
    // Why needed: Keep endpoint and request token handling centralized.
    // --------------------------------------------------
    public static final String CAMPAIGN_SEGMENT1 = '/v1.0/partnercenter/campaigndetails/';
    public static final String CAMPAIGN_SEGMENT = '/v1.0/partnercenter/campaign/';
    public static final Integer MAX_CHILD_ROWS = 200;
    public static final String FIELD_DISPLAY_PARAM = 'fielddisplay';
    public static final String FIELD_DISPLAY_LABEL = 'label';
    public static final String FIELD_DISPLAY_TECHNICAL_NAME = 'technicalname';

    // --------------------------------------------------
    // Response Payload Key Constants
    // Why needed: Preserve response structure keys consistently.
    // --------------------------------------------------
    public static final String RESPONSE_KEY_CAMPAIGN_BUDGETS = 'Campaign Budgets';
    public static final String RESPONSE_KEY_CAMPAIGN_PURPOSE = 'Campaign Purpose';
    public static final String RESPONSE_CODE_CATEGORY_CAMPAIGN = 'Campaign';
    public static final String ERROR_MESSAGE_CONFIG_MISSING = 'Error configuration is missing for this API error code';

    // --------------------------------------------------
    // Success Response Codes
    // Why needed: Maintain consistent success status in all API responses.
    // --------------------------------------------------
    public static final String SUCCESS_200 = '200';
    public static final Integer HTTP_STATUS_500 = 500;

    // --------------------------------------------------
    // 7000 Series API Error Codes
    // Why needed: Replace generic ERRORxx keys with structured code sequence.
    // --------------------------------------------------
    public static final String CODE_7002_CAMPAIGN_ID_EMPTY = '7002';
    public static final String CODE_7003_CAMPAIGN_INTERNAL_SERVER_ERROR = '7003';
    public static final String CODE_7004_INVALID_CAMPAIGN_ID = '7004';
    public static final String CODE_7005_INVALID_FIELD_DISPLAY = '7005';
    public static final String CODE_7008_INSUFFICIENT_PERMISSIONS = '7008';

    // --------------------------------------------------
    // Fallback Error Message
    // Why needed: Used when no dynamic error configuration can be resolved.
    // --------------------------------------------------
    public static final String MSG_GENERIC_ERROR = 'An error occurred processing your request';

    // --------------------------------------------------
    // Success Messages
    // Why needed: Keep success communication consistent for all clients.
    // --------------------------------------------------
    public static final String MSG_CAMPAIGN_DETAILS_RETRIEVED = 'Campaign details retrieved successfully';

    // --------------------------------------------------
    // URI / Id Validation Constants
    // Why needed: Avoid magic literals while parsing and validating path IDs.
    // --------------------------------------------------
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

}