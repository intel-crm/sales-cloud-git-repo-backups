/**
 * @description Constants class for PartnerFundRequest REST API to centralize error messages and codes.
 * This class ensures consistency across the API by providing single points of reference for errors.
 */
public inherited sharing class Core_MDF_PFR_RestAPI_Constants {
    
    // ==========================================
    // Core API Errors (9000 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9000_GENERIC_TECH_ERROR = '9000';
    public static final String ERR_9001_NO_RECORDS = '9001';
    public static final String ERR_9002_UPDATE_NEEDS_ID = '9002';
    public static final String ERR_9003_ALL_FAILED = '9003';
    public static final String ERR_9004_PARTIAL_SUCCESS = '9004';
    public static final String ERR_9005_INVALID_ACTION = '9005';
    public static final String ERR_9006_BUSINESS_VALIDATION = '9006';
    // Code-only prefix used when returning the exact, unmodified validation-rule message to the caller.
    public static final String ERR_9006_BUSINESS_VALIDATION_CODE = '9006';

    // ==========================================
    // JSON & Parsing Errors (9010 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // For templated messages, the custom setting message should contain {0}, {1} placeholders
    // ==========================================
    public static final String ERR_9010_INVALID_JSON_BODY = '9010';
    public static final String ERR_9011_INVALID_JSON_ENTRY = '9011';
    public static final String ERR_9012_UNRESOLVED_LOOKUP = '9012';
    public static final String ERR_9013_MULTIPLE_MATCHES = '9013';
    public static final String ERR_9014_INVALID_FIELD_VAL = '9014';
    public static final String ERR_9015_REQUIRED_FIELD_MISSING = '9008';

    // ==========================================
    // Validation Errors (9020 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9020_CAMPAIGN_REQUIRED = '9020';
    public static final String ERR_9021_INVALID_CAMPAIGN = '9021';
    public static final String ERR_9022_CAMPAIGN_NOT_ACTIVE = '9022';
    public static final String ERR_9023_ACCOUNT_REQUIRED = '9023';
    public static final String ERR_9024_BUDGET_ID_REQUIRED = '9024';
    public static final String ERR_9025_ACCOUNT_UPDATE_NOT_ALLOWED = '9025';
    public static final String ERR_9026_PROGRAM_RECORDTYPE_UNRESOLVED = '9026';
    public static final String ERR_9027_DIGITAL_PARTNER_FILE_REQUIRED = '9027';

    // PartnerFundRequest CCF/DCF record type developer names (used to derive the record type from the Campaign program).
    public static final String RECORD_TYPE_CCF = 'Core_MDF_Client_CoMarketing_Fund';
    public static final String RECORD_TYPE_DCF = 'Core_MDF_Data_Center_CoMarketing_Fund';

    // ==========================================
    // Picklist & Dependent Value Errors (9030 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9030_INVALID_ACT_CAT = '9030';
    public static final String ERR_9031_INVALID_ACT_TYPE = '9031';
    public static final String ERR_9032_DEPENDENT_ACT_TYPE = '9032';
    public static final String ERR_9033_CAMP_CAT_NOT_ALLOWED = '9033';
    public static final String ERR_9034_CAMP_TYPE_NOT_ALLOWED = '9034';
    public static final String ERR_9035_INVALID_EVENT_NAME = '9035';
    public static final String ERR_9036_INVALID_DOMAIN_TYPE = '9036';
    public static final String ERR_9037_INVALID_REIMBURSEMENT_RATE = '9037';
    public static final String ERR_9038_EVENT_NAME_NOT_ALLOWED = '9038';
    public static final String ERR_9039_BUDGET_REIMBURSEMENT_RATE_MISMATCH = '9039';
    // ==========================================
    // Campaign Field Alignment Errors (9040 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9040_PRIORITY_MISMATCH = '9040';
    public static final String ERR_9041_AUDIENCE_MISMATCH = '9041';
    public static final String ERR_9042_MARKET_MISMATCH = '9042';
    public static final String ERR_9043_BRAND_MISMATCH = '9043';
    public static final String ERR_9044_PRODUCT_TYPE_MISMATCH = '9044';
    public static final String ERR_9045_INDUSTRY_MISMATCH = '9045';
    public static final String ERR_9046_ECOSYSTEM_PARTNER_MISMATCH = '9046';

    // ==========================================
    // Member Acceptor & Permissions Errors (9050 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9050_MEMBER_NOT_ACTIVE = '9050';
    public static final String ERR_9051_NO_PNUM_MAPPING = '9051';
    public static final String ERR_9052_NO_EXT_SUBMITTER_PERM = '9052';
    public static final String ERR_9053_MEMBER_VALIDATION_ERR = '9053';
    public static final String ERR_9054_INTEL_NOT_ACTIVE = '9054';
    public static final String ERR_9055_INTEL_VALIDATION_ERR = '9055';

    // ==========================================
    // Budget & Program Alignment Errors (9060 series)
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9060_BUDGET_NOT_AVAIL = '9060';
    public static final String ERR_9061_EXCHANGE_RATE_NOT_FOUND = '9061';
    public static final String ERR_9062_CLAIM_AVAILABLE_AMOUNT_EXCEEDED = '9062';

    // ==========================================
    // Conditionally-mandatory field Errors (9090 series)
    // Fields required only when the activity category / activity type combination demands it.
    // Message text is fetched through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    // ==========================================
    public static final String ERR_9092_EVENT_NAME_REQUIRED = '9092';
    public static final String ERR_9093_OTHER_EVENT_NAME_REQUIRED = '9093';
    public static final String ERR_9094_DOMAIN_TYPE_REQUIRED = '9094';
    public static final String ERR_9095_ACTIVITY_SUBTYPE_REQUIRED = '9095';
    public static final String ERR_9096_INVALID_ACTIVITY_SUBTYPE = '9096';
    public static final String ERR_9199_INVALID_REASON_PAST_DATED = '9199';
    public static final String ERR_9201_TECH_SALES_COMPETITIVE_ELEMENTS_NOT_ALLOWED = '9201';
    public static final String ERR_9202_TECH_SALES_GOVERNMENT_NEXUS_NOT_ALLOWED = '9202';
    public static final String ERR_9204_COUNTRY_GEO_MISMATCH = '9204';
    public static final String ERR_9101_OTHER_ECOSYSTEM_PARTNER_REQUIRED = '9101';
    public static final String ERR_9128_START_DATE_PRIOR_TO_TODAY = '9128';

    // Business validation codes 9070-9142 are now resolved fully from
    // Core_MDF_RestAPI_Logger.getErrorConfigDetails() using the emitted validation code.
    // No static Apex map is retained for Validation Rules or addError() labels.

    // Utility validation messages resolved through Core_MDF_RestAPI_Logger.getErrorConfigDetails().
    public static final String ERR_9222_INCENTIVE_NOT_ALLOWED_FOR_BUDGET = '9222';
    public static final String ERR_9223_NO_ECOSYSTEM_PARTNER_WITH_NONE = '9223';
    public static final String ERR_9224_DUPLICATE_SEGMENT_NAME = '9224';
    public static final String ERR_9225_SEGMENT_NAME_REQUIRED = '9225';
    public static final String ERR_9226_MIN_FORECAST_VOLUME_REQUIRED = '9226';
    public static final String ERR_9227_MIN_FORECAST_VOLUME_GT_ZERO = '9227';
    public static final String ERR_9228_INCENTIVE_AMOUNT_REQUIRED = '9228';
    public static final String ERR_9229_INCENTIVE_AMOUNT_GT_ZERO = '9229';
    public static final String ERR_9230_PRODUCT_ID_REQUIRED = '9230';
    public static final String ERR_9231_PRODUCT_ID_BLANK_AT_POSITION = '9231';
    public static final String ERR_9232_DUPLICATE_PRODUCT_ID = '9232';
    public static final String ERR_9233_NO_VALID_PRODUCT_IDS = '9233';
    public static final String ERR_9234_PRODUCT_IDS_MUST_BE_ARRAY = '9234';
    public static final String ERR_9235_PRODUCT_IDS_ARRAY_REQUIRED = '9235';
    public static final String ERR_9236_SEGMENT_VALIDATION_ERROR = '9236';
    public static final String ERR_9237_SELECT_DIFFERENT_ACTIVITY_TYPES = '9237';
    public static final String ERR_9239_MISSING_SEGMENTS = '9239';
    public static final String ERR_9240_INVALID_SEGMENT_COUNT = '9240';
    public static final String ERR_9241_ALL_SEGMENTS_VALIDATED = '9241';
    public static final String ERR_9242_SOME_SEGMENTS_FAILED = '9242';
    public static final String ERR_9243_SEGMENTS_VALIDATION_ERROR = '9243';

    /**
     * @description Helper method to format dynamic error strings
     * @param template The error constant containing placeholders (e.g. {0})
     * @param args The arguments to replace the placeholders
     * @return Formatted error string
     */
    public static String formatError(String template, List<String> args) {
        String code = Core_MDF_PFR_RestAPI_Utility.normalizeErrorCode(template);
        if (String.isBlank(code)) {
            return template;
        }

        String resolvedMessage = Core_MDF_PFR_RestAPI_Utility.getFormattedErrorMessage(code, args);
        if (String.isNotBlank(resolvedMessage)) {
            String expectedValues = getExpectedValuesArgument(args);
            if (String.isNotBlank(expectedValues) && !resolvedMessage.contains(expectedValues)
                && !resolvedMessage.contains('Expected value:') && !resolvedMessage.contains('Allowed values:')) {
                resolvedMessage += '\nExpected value:\n' + expectedValues;
            }
            return code + ': ' + resolvedMessage;
        }

        // Fallback to numeric code only when no custom setting row/message exists.
        return code;
    }

    private static String getExpectedValuesArgument(List<String> args) {
        if (args == null || args.isEmpty()) {
            return null;
        }
        for (Integer i = args.size() - 1; i >= 0; i--) {
            String value = args[i];
            if (String.isNotBlank(value) && value != 'none' && value.trim().startsWith('1. ')) {
                return value;
            }
        }
        return null;
    }

    // ===== MULTI-SEGMENT SPIF CONSTANTS - APPENDED =====
    // Activity Categories
    public static final String ACTIVITY_CATEGORY_SELLER_INCENTIVE = 'Seller Incentive';
    
    // Budget Types - SPIF
    public static final Set<String> VALID_SPIF_BUDGET_TYPES = new Set<String>{
        'MDF', 'MDF+'
    };
    
    // Activity Types - SPIF
    public static final Set<String> VALID_SPIF_ACTIVITY_TYPES = new Set<String>{
        'SPIF Volume', 'SPIF Target'
    };
    
    // Segment Validation Messages
    public static final String MISSING_SEGMENTS = 'At least one segment is required for SPIF records';
    public static final String INVALID_SEGMENT_COUNT = 'Maximum 10 segments allowed per request';
    public static final String INVALID_SEGMENT_NAME = 'Invalid Segment name. Must be valid picklist value';
    public static final String MISSING_SEGMENT_FORECAST = 'Minimum Forecast Volume is mandatory for segment';
    public static final String INVALID_SEGMENT_FORECAST = 'Minimum Forecast Volume must be greater than 0';
    public static final String MISSING_SEGMENT_INCENTIVE = 'Incentive Amount $/U is mandatory for segment';
    public static final String INVALID_SEGMENT_INCENTIVE = 'Incentive Amount $/U must be greater than 0';
    public static final String MISSING_SEGMENT_PRODUCTS = 'At least one product must be selected for segment';
    public static final String INVALID_SEGMENT_PRODUCTS = 'Selected products are not mapped to segment';
    public static final String INVALID_ACCOUNT_PRODUCT_MAPPING = 'Products are not mapped to account for segment';
    public static final String Required_Ecosystem_Partner_PercentageAllocation = 'Ecosystem Partner Percentage Allocation should be 100. Please enter 0 for no allocation';
    // Segment Configuration
    public static final Integer MAX_SEGMENTS_PER_REQUEST = 10;
    public static final Decimal MIN_FORECAST_VOLUME = 0.01;
    public static final Decimal MIN_INCENTIVE_AMOUNT = 0.01;

    
    public static final String ERR_9210_CAMPAIGN_REQUIRED_MESSAGE = '9210';
    public static final String ERR_9211_CHANNEL_PARTNER_REQUIRED_MESSAGE = '9211';
    public static final String ERR_9212_TARGET_AUDIENCE_REQUIRED_MESSAGE = '9212';
    public static final String ERR_9213_BRAND_REQUIRED_MESSAGE = '9213';
    public static final String ERR_9214_ACTIVITY_CATEGORY_REQUIRED_MESSAGE = '9214';
    public static final String ERR_9215_ACTIVITY_TYPE_REQUIRED_MESSAGE = '9215';
    public static final String ERR_9216_MARKET_REQUIRED_MESSAGE = '9216';
    public static final String ERR_9217_PRIORITY_REQUIRED_MESSAGE = '9217';
    public static final String ERR_9218_ECOSYSTEM_PARTNER_REQUIRED_MESSAGE = '9218';
    public static final String ERR_9219_INTEL_OWNER_REQUIRED_MESSAGE = '9219';
    public static final String ERR_9220_EVENT_NAME_REQUIRED_MESSAGE = '9220';
    public static final String ERR_9221_OTHER_EVENT_NAME_REQUIRED_MESSAGE = '9221';
}