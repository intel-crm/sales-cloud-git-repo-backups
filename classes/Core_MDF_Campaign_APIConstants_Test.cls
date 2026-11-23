@IsTest
private class Core_MDF_Campaign_APIConstants_Test {

    @IsTest
    static void testApiRouteConstants() {
        System.assertEquals('/v1.0/partnercenter/campaigndetails/', Core_MDF_Campaign_APIConstants.CAMPAIGN_SEGMENT1);
        System.assertEquals('/v1.0/partnercenter/campaign/', Core_MDF_Campaign_APIConstants.CAMPAIGN_SEGMENT);
        System.assertEquals(200, Core_MDF_Campaign_APIConstants.MAX_CHILD_ROWS);
        System.assertEquals('fielddisplay', Core_MDF_Campaign_APIConstants.FIELD_DISPLAY_PARAM);
        System.assertEquals('label', Core_MDF_Campaign_APIConstants.FIELD_DISPLAY_LABEL);
        System.assertEquals('technicalname', Core_MDF_Campaign_APIConstants.FIELD_DISPLAY_TECHNICAL_NAME);
    }

    @IsTest
    static void testCampaignFieldMappingConstants() {
        System.assertEquals('Core_MDF_Program__c', Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_PROGRAM_FIELD);
        System.assertEquals('Core_MDF_Channel_Program__r.Name', Core_MDF_Campaign_APIConstants.CAMPAIGN_PROGRAM_NAME_FIELD);
        System.assertEquals('Core_MDF_Account__c', Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_ACCOUNT_FIELD);
        System.assertEquals('Core_MDF_Account__r.Name', Core_MDF_Campaign_APIConstants.CAMPAIGN_ACCOUNT_NAME_FIELD);
    }

    @IsTest
    static void testResponsePayloadKeyConstants() {
        System.assertEquals('Campaign Budgets', Core_MDF_Campaign_APIConstants.RESPONSE_KEY_CAMPAIGN_BUDGETS);
        System.assertEquals('Campaign Purpose', Core_MDF_Campaign_APIConstants.RESPONSE_KEY_CAMPAIGN_PURPOSE);
        System.assertEquals('Campaign', Core_MDF_Campaign_APIConstants.RESPONSE_CODE_CATEGORY_CAMPAIGN);
        System.assertNotEquals(null, Core_MDF_Campaign_APIConstants.ERROR_MESSAGE_CONFIG_MISSING);
    }

    @IsTest
    static void testSuccessAndErrorCodes() {
        System.assertEquals('200', Core_MDF_Campaign_APIConstants.SUCCESS_200);
        System.assertEquals(500, Core_MDF_Campaign_APIConstants.HTTP_STATUS_500);
        System.assertEquals('7002', Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
        System.assertEquals('7003', Core_MDF_Campaign_APIConstants.CODE_7003_CAMPAIGN_INTERNAL_SERVER_ERROR);
        System.assertEquals('7004', Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
        System.assertEquals('7005', Core_MDF_Campaign_APIConstants.CODE_7005_INVALID_FIELD_DISPLAY);
        System.assertEquals('7008', Core_MDF_Campaign_APIConstants.CODE_7008_INSUFFICIENT_PERMISSIONS);
    }

    @IsTest
    static void testIdValidationConstants() {
        System.assertEquals('Campaign', Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME);
        System.assertEquals('Core_MDF_Campaign_Budgets__c', Core_MDF_Campaign_APIConstants.CAMPAIGN_BUDGETS_OBJECT_API);
        System.assertEquals('Core_MDF_Campaign_Outcomes__c', Core_MDF_Campaign_APIConstants.CAMPAIGN_OUTCOMES_OBJECT_API);
        System.assertEquals('701', Core_MDF_Campaign_APIConstants.CAMPAIGN_KEY_PREFIX);
        System.assertEquals(15, Core_MDF_Campaign_APIConstants.SALESFORCE_ID_LENGTH_15);
        System.assertEquals(18, Core_MDF_Campaign_APIConstants.SALESFORCE_ID_LENGTH_18);
    }

    @IsTest
    static void testDefaultCampaignDisplayFields() {
        Set<String> fields = Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS;
        System.assertNotEquals(null, fields);
        System.assert(fields.contains('Id'));
        System.assert(fields.contains('Name'));
        System.assert(fields.contains('Status'));
        System.assert(fields.contains('StartDate'));
        System.assert(fields.contains('EndDate'));
        System.assert(fields.contains('IsActive'));
    }

    @IsTest
    static void testMessagesAreNotBlank() {
        System.assert(String.isNotBlank(Core_MDF_Campaign_APIConstants.MSG_GENERIC_ERROR));
        System.assert(String.isNotBlank(Core_MDF_Campaign_APIConstants.MSG_CAMPAIGN_DETAILS_RETRIEVED));
    }
}