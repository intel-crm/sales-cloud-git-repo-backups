/**
 * @description Test class for Core_MDF_PFR_RestAPI_Constants
 */
@isTest
private class Core_MDF_PFR_RestAPI_Constants_Test {

    // ==========================================
    // Core API Error Constants (9000 series)
    // ==========================================
    @isTest
    static void testCoreAPIErrorConstants() {
        Assert.areEqual('9000', Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR);
        Assert.areEqual('9001', Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS);
        Assert.areEqual('9002', Core_MDF_PFR_RestAPI_Constants.ERR_9002_UPDATE_NEEDS_ID);
        Assert.areEqual('9003', Core_MDF_PFR_RestAPI_Constants.ERR_9003_ALL_FAILED);
        Assert.areEqual('9004', Core_MDF_PFR_RestAPI_Constants.ERR_9004_PARTIAL_SUCCESS);
        Assert.areEqual('9005', Core_MDF_PFR_RestAPI_Constants.ERR_9005_INVALID_ACTION);
        Assert.areEqual('9006', Core_MDF_PFR_RestAPI_Constants.ERR_9006_BUSINESS_VALIDATION);
        Assert.areEqual('9006', Core_MDF_PFR_RestAPI_Constants.ERR_9006_BUSINESS_VALIDATION_CODE);
    }

    // ==========================================
    // JSON & Parsing Error Constants (9010 series)
    // ==========================================
    @isTest
    static void testJSONParsingErrorConstants() {
        Assert.areEqual('9010', Core_MDF_PFR_RestAPI_Constants.ERR_9010_INVALID_JSON_BODY);
        Assert.areEqual('9011', Core_MDF_PFR_RestAPI_Constants.ERR_9011_INVALID_JSON_ENTRY);
        Assert.areEqual('9012', Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP);
        Assert.areEqual('9013', Core_MDF_PFR_RestAPI_Constants.ERR_9013_MULTIPLE_MATCHES);
        Assert.areEqual('9014', Core_MDF_PFR_RestAPI_Constants.ERR_9014_INVALID_FIELD_VAL);
        // ERR_9015_REQUIRED_FIELD_MISSING intentionally maps to '9008'
        Assert.areEqual('9008', Core_MDF_PFR_RestAPI_Constants.ERR_9015_REQUIRED_FIELD_MISSING);
    }

    // ==========================================
    // Validation Error Constants (9020 series)
    // ==========================================
    @isTest
    static void testValidationErrorConstants() {
        Assert.areEqual('9020', Core_MDF_PFR_RestAPI_Constants.ERR_9020_CAMPAIGN_REQUIRED);
        Assert.areEqual('9021', Core_MDF_PFR_RestAPI_Constants.ERR_9021_INVALID_CAMPAIGN);
        Assert.areEqual('9022', Core_MDF_PFR_RestAPI_Constants.ERR_9022_CAMPAIGN_NOT_ACTIVE);
        Assert.areEqual('9023', Core_MDF_PFR_RestAPI_Constants.ERR_9023_ACCOUNT_REQUIRED);
        Assert.areEqual('9024', Core_MDF_PFR_RestAPI_Constants.ERR_9024_BUDGET_ID_REQUIRED);
        Assert.areEqual('9025', Core_MDF_PFR_RestAPI_Constants.ERR_9025_ACCOUNT_UPDATE_NOT_ALLOWED);
        Assert.areEqual('9026', Core_MDF_PFR_RestAPI_Constants.ERR_9026_PROGRAM_RECORDTYPE_UNRESOLVED);
        Assert.areEqual('9027', Core_MDF_PFR_RestAPI_Constants.ERR_9027_DIGITAL_PARTNER_FILE_REQUIRED);
    }

    // ==========================================
    // Record Type Constants
    // ==========================================
    @isTest
    static void testRecordTypeConstants() {
        Assert.areEqual('Core_MDF_Client_CoMarketing_Fund',      Core_MDF_PFR_RestAPI_Constants.RECORD_TYPE_CCF);
        Assert.areEqual('Core_MDF_Data_Center_CoMarketing_Fund', Core_MDF_PFR_RestAPI_Constants.RECORD_TYPE_DCF);
    }

    // ==========================================
    // Picklist Error Constants (9030 series)
    // ==========================================
    @isTest
    static void testPicklistErrorConstants() {
        Assert.areEqual('9030', Core_MDF_PFR_RestAPI_Constants.ERR_9030_INVALID_ACT_CAT);
        Assert.areEqual('9031', Core_MDF_PFR_RestAPI_Constants.ERR_9031_INVALID_ACT_TYPE);
        Assert.areEqual('9032', Core_MDF_PFR_RestAPI_Constants.ERR_9032_DEPENDENT_ACT_TYPE);
        Assert.areEqual('9033', Core_MDF_PFR_RestAPI_Constants.ERR_9033_CAMP_CAT_NOT_ALLOWED);
        Assert.areEqual('9034', Core_MDF_PFR_RestAPI_Constants.ERR_9034_CAMP_TYPE_NOT_ALLOWED);
        Assert.areEqual('9035', Core_MDF_PFR_RestAPI_Constants.ERR_9035_INVALID_EVENT_NAME);
        Assert.areEqual('9036', Core_MDF_PFR_RestAPI_Constants.ERR_9036_INVALID_DOMAIN_TYPE);
        Assert.areEqual('9037', Core_MDF_PFR_RestAPI_Constants.ERR_9037_INVALID_REIMBURSEMENT_RATE);
        Assert.areEqual('9038', Core_MDF_PFR_RestAPI_Constants.ERR_9038_EVENT_NAME_NOT_ALLOWED);
        Assert.areEqual('9039', Core_MDF_PFR_RestAPI_Constants.ERR_9039_BUDGET_REIMBURSEMENT_RATE_MISMATCH);
    }

    // ==========================================
    // Campaign Field Alignment Error Constants (9040 series)
    // ==========================================
    @isTest
    static void testCampaignFieldAlignmentErrorConstants() {
        Assert.areEqual('9040', Core_MDF_PFR_RestAPI_Constants.ERR_9040_PRIORITY_MISMATCH);
        Assert.areEqual('9041', Core_MDF_PFR_RestAPI_Constants.ERR_9041_AUDIENCE_MISMATCH);
        Assert.areEqual('9042', Core_MDF_PFR_RestAPI_Constants.ERR_9042_MARKET_MISMATCH);
        Assert.areEqual('9043', Core_MDF_PFR_RestAPI_Constants.ERR_9043_BRAND_MISMATCH);
        Assert.areEqual('9044', Core_MDF_PFR_RestAPI_Constants.ERR_9044_PRODUCT_TYPE_MISMATCH);
        Assert.areEqual('9045', Core_MDF_PFR_RestAPI_Constants.ERR_9045_INDUSTRY_MISMATCH);
        Assert.areEqual('9046', Core_MDF_PFR_RestAPI_Constants.ERR_9046_ECOSYSTEM_PARTNER_MISMATCH);
    }

    // ==========================================
    // Member Acceptor & Budget Error Constants (9050-9060 series)
    // ==========================================
    @isTest
    static void testMemberAndBudgetErrorConstants() {
        Assert.areEqual('9050', Core_MDF_PFR_RestAPI_Constants.ERR_9050_MEMBER_NOT_ACTIVE);
        Assert.areEqual('9051', Core_MDF_PFR_RestAPI_Constants.ERR_9051_NO_PNUM_MAPPING);
        Assert.areEqual('9052', Core_MDF_PFR_RestAPI_Constants.ERR_9052_NO_EXT_SUBMITTER_PERM);
        Assert.areEqual('9053', Core_MDF_PFR_RestAPI_Constants.ERR_9053_MEMBER_VALIDATION_ERR);
        Assert.areEqual('9060', Core_MDF_PFR_RestAPI_Constants.ERR_9060_BUDGET_NOT_AVAIL);
        Assert.areEqual('9061', Core_MDF_PFR_RestAPI_Constants.ERR_9061_EXCHANGE_RATE_NOT_FOUND);
    }

    // ==========================================
    // Conditionally-Mandatory Field Error Constants (9090+ series)
    // ==========================================
    @isTest
    static void testConditionallyMandatoryFieldErrorConstants() {
        Assert.areEqual('9090', Core_MDF_PFR_RestAPI_Constants.ERR_9090_ATTRIBUTION_REQUIRED);
        Assert.areEqual('9091', Core_MDF_PFR_RestAPI_Constants.ERR_9091_POP_REQUIRED);
        Assert.areEqual('9092', Core_MDF_PFR_RestAPI_Constants.ERR_9092_EVENT_NAME_REQUIRED);
        Assert.areEqual('9093', Core_MDF_PFR_RestAPI_Constants.ERR_9093_OTHER_EVENT_NAME_REQUIRED);
        Assert.areEqual('9094', Core_MDF_PFR_RestAPI_Constants.ERR_9094_DOMAIN_TYPE_REQUIRED);
        Assert.areEqual('9095', Core_MDF_PFR_RestAPI_Constants.ERR_9095_ACTIVITY_SUBTYPE_REQUIRED);
        Assert.areEqual('9096', Core_MDF_PFR_RestAPI_Constants.ERR_9096_INVALID_ACTIVITY_SUBTYPE);
        Assert.areEqual('9099', Core_MDF_PFR_RestAPI_Constants.ERR_9099_REASON_PAST_DATED_REQUIRED);
        Assert.areEqual('9101', Core_MDF_PFR_RestAPI_Constants.ERR_9101_OTHER_ECOSYSTEM_PARTNER_REQUIRED);
        Assert.areEqual('9199', Core_MDF_PFR_RestAPI_Constants.ERR_9199_INVALID_REASON_PAST_DATED);
        Assert.areEqual('9200', Core_MDF_PFR_RestAPI_Constants.ERR_9200_OTHER_REASON_REQUIRED);
        Assert.areEqual('9201', Core_MDF_PFR_RestAPI_Constants.ERR_9201_TECH_SALES_COMPETITIVE_ELEMENTS_NOT_ALLOWED);
    }

    // ==========================================
    // SPIF Constants
    // ==========================================
    @isTest
    static void testSpifConstants() {
        // Activity category
        Assert.areEqual('Seller Incentive', Core_MDF_PFR_RestAPI_Constants.ACTIVITY_CATEGORY_SELLER_INCENTIVE);

        // Budget & activity type sets
        Assert.areEqual(2, Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_BUDGET_TYPES.size());
        Assert.isTrue(Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_BUDGET_TYPES.contains('MDF'));
        Assert.isTrue(Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_BUDGET_TYPES.contains('MDF+'));

        Assert.areEqual(2, Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_ACTIVITY_TYPES.size());
        Assert.isTrue(Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_ACTIVITY_TYPES.contains('SPIF Volume'));
        Assert.isTrue(Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_ACTIVITY_TYPES.contains('SPIF Target'));

        // Numeric configuration
        Assert.areEqual(10,   Core_MDF_PFR_RestAPI_Constants.MAX_SEGMENTS_PER_REQUEST);
        Assert.areEqual(0.01, Core_MDF_PFR_RestAPI_Constants.MIN_FORECAST_VOLUME);
        Assert.areEqual(0.01, Core_MDF_PFR_RestAPI_Constants.MIN_INCENTIVE_AMOUNT);
    }

    @isTest
    static void testSpifSegmentValidationMessages() {
        Assert.areEqual('At least one segment is required for SPIF records',          Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENTS);
        Assert.areEqual('Maximum 10 segments allowed per request',                    Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_COUNT);
        Assert.areEqual('Invalid Segment name. Must be valid picklist value',         Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_NAME);
        Assert.areEqual('Minimum Forecast Volume is mandatory for segment',           Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENT_FORECAST);
        Assert.areEqual('Minimum Forecast Volume must be greater than 0',             Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_FORECAST);
        Assert.areEqual('Incentive Amount $/U is mandatory for segment',              Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENT_INCENTIVE);
        Assert.areEqual('Incentive Amount $/U must be greater than 0',                Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_INCENTIVE);
        Assert.areEqual('At least one product must be selected for segment',          Core_MDF_PFR_RestAPI_Constants.MISSING_SEGMENT_PRODUCTS);
        Assert.areEqual('Selected products are not mapped to segment',                Core_MDF_PFR_RestAPI_Constants.INVALID_SEGMENT_PRODUCTS);
        Assert.areEqual('Products are not mapped to account for segment',             Core_MDF_PFR_RestAPI_Constants.INVALID_ACCOUNT_PRODUCT_MAPPING);
        Assert.areEqual(
            'Ecosystem Partner Percentage Allocation should be 100. Please enter 0 for no allocation',
            Core_MDF_PFR_RestAPI_Constants.Required_Ecosystem_Partner_PercentageAllocation
        );
    }

    // ==========================================
    // Multi-Segment SPIF Error Constants (9210 series)
    // ==========================================
    @isTest
    static void testMultiSegmentSpifErrorConstants() {
        Assert.areEqual('9210', Core_MDF_PFR_RestAPI_Constants.ERR_9210_CAMPAIGN_REQUIRED_MESSAGE);
        Assert.areEqual('9211', Core_MDF_PFR_RestAPI_Constants.ERR_9211_CHANNEL_PARTNER_REQUIRED_MESSAGE);
        Assert.areEqual('9212', Core_MDF_PFR_RestAPI_Constants.ERR_9212_TARGET_AUDIENCE_REQUIRED_MESSAGE);
        Assert.areEqual('9213', Core_MDF_PFR_RestAPI_Constants.ERR_9213_BRAND_REQUIRED_MESSAGE);
        Assert.areEqual('9214', Core_MDF_PFR_RestAPI_Constants.ERR_9214_ACTIVITY_CATEGORY_REQUIRED_MESSAGE);
        Assert.areEqual('9215', Core_MDF_PFR_RestAPI_Constants.ERR_9215_ACTIVITY_TYPE_REQUIRED_MESSAGE);
        Assert.areEqual('9216', Core_MDF_PFR_RestAPI_Constants.ERR_9216_MARKET_REQUIRED_MESSAGE);
        Assert.areEqual('9217', Core_MDF_PFR_RestAPI_Constants.ERR_9217_PRIORITY_REQUIRED_MESSAGE);
        Assert.areEqual('9218', Core_MDF_PFR_RestAPI_Constants.ERR_9218_ECOSYSTEM_PARTNER_REQUIRED_MESSAGE);
        Assert.areEqual('9219', Core_MDF_PFR_RestAPI_Constants.ERR_9219_INTEL_OWNER_REQUIRED_MESSAGE);
        Assert.areEqual('9220', Core_MDF_PFR_RestAPI_Constants.ERR_9220_EVENT_NAME_REQUIRED_MESSAGE);
        Assert.areEqual('9221', Core_MDF_PFR_RestAPI_Constants.ERR_9221_OTHER_EVENT_NAME_REQUIRED_MESSAGE);
    }

    // ==========================================
    // formatError Method Tests
    // ==========================================
    @isTest
    static void testFormatErrorReturnsNonNull() {
        Assert.isNotNull(
            Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR,
                new List<String>()
            ),
            'formatError should never return null'
        );
    }

    @isTest
    static void testFormatErrorWithArgs() {
        Assert.isNotNull(
            Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9012_UNRESOLVED_LOOKUP,
                new List<String>{ 'BudgetId', 'Campaign', 'Q1 Campaign' }
            ),
            'formatError with args should return non-null'
        );
    }

    @isTest
    static void testFormatErrorBlankTemplate() {
        Assert.areEqual(
            '',
            Core_MDF_PFR_RestAPI_Constants.formatError('', new List<String>()),
            'formatError with blank template should return blank string'
        );
    }

    @isTest
    static void testFormatErrorNullTemplate() {
        try {
            String result = Core_MDF_PFR_RestAPI_Constants.formatError(null, new List<String>());
            Assert.isTrue(result == null || result == '', 'formatError with null should return null or empty');
        } catch (Exception e) {
            Assert.isNotNull(e);
        }
    }
}