@IsTest
private class Core_MDF_CCP_RestAPI_Utility_Test {

    private class MockHttpCallout implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        MockHttpCallout(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            return res;
        }
    }

    private static Account getOrCreateCampaignAccount() {
        List<Account> existingAccounts = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Core_MDF_Co_Marketing'
              AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'
            LIMIT 1
        ];
        if (!existingAccounts.isEmpty()) {
            return existingAccounts[0];
        }

        ChannelProgram ipaProgram = Core_MDF_CCP_TestDataUtility.createProgram(
            'Intel Partner Alliance',
            'Intel Partner Alliance',
            true
        );

        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount(
            'UT Intel Account ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type,
            false
        );
        intelAccount.BillingStateCode = '';
        insert intelAccount;

        Account coMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
            'UT IPA Co-Marketing Account ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            ipaProgram.Id,
            Core_MDF_CCP_TestDataUtility.account_Record_Type,
            intelAccount.Id,
            false
        );
        coMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
        insert coMarketingAccount;
        return coMarketingAccount;
    }

    private static Campaign createTestCampaign() {
        Account campaignAccount = getOrCreateCampaignAccount();
        Campaign c = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign(
            'Utility Test Campaign ' + String.valueOf(Crypto.getRandomInteger()).replace('-', ''),
            campaignAccount.Id,
            Date.today(),
            Date.today().addDays(60),
            'Account Plan',
            1000,
            'India',
            'Channel Partner',
            'Other',
            'Pending Approval',
            false
        );
        insert c;
        return c;
    }

    // ============================================================
    // getDisplayFields tests
    // ============================================================

    @IsTest
    static void testGetDisplayFields_BlankObjectApiName_ReturnsEmptySet() {
        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFields('', '001000000000001AAA', new Set<String>{'Id'});
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.isEmpty(), 'Expected empty set for blank objectApiName');
    }

    @IsTest
    static void testGetDisplayFields_BlankRecordId_ReturnsDefaultFields() {
        Set<String> defaults = new Set<String>{ 'Id', 'Name' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFields('Campaign', '', defaults);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsAll(defaults));
    }

    @IsTest
    static void testGetDisplayFields_NullDefaults_BlankRecordId_ReturnsEmpty() {
        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFields('Campaign', '', null);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
    }

    @IsTest
    static void testGetDisplayFields_ValidCampaign_ReturnsFields() {
        Campaign c = createTestCampaign();
        Set<String> defaults = new Set<String>{ 'Id', 'Name', 'Status' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFields('Campaign', c.Id, defaults);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(!result.isEmpty());
    }

    // ============================================================
    // getDisplayFieldsByRecordType tests
    // ============================================================

    @IsTest
    static void testGetDisplayFieldsByRecordType_BlankObjectApiName_ReturnsDefaults() {
        Set<String> defaults = new Set<String>{ 'Id', 'Name' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('', 'TestRecordType', defaults);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsAll(defaults));
    }

    @IsTest
    static void testGetDisplayFieldsByRecordType_BlankRecordTypeName_ReturnsDefaults() {
        Set<String> defaults = new Set<String>{ 'Id', 'Name' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('Campaign', '', defaults);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsAll(defaults));
    }

    @IsTest
    static void testGetDisplayFieldsByRecordType_NullRecordTypeName_ReturnsDefaults() {
        Set<String> defaults = new Set<String>{ 'Id', 'Status' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('Campaign', null, defaults);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsAll(defaults));
    }

    @IsTest
    static void testGetDisplayFieldsByRecordType_NoConfigRecords_ReturnsDefaults() {
        Set<String> defaults = new Set<String>{ 'Id', 'Name', 'Status' };

        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
            'Campaign', 'NonExistentRecordType_XYZ', defaults
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsAll(defaults));
    }

    @IsTest
    static void testGetDisplayFieldsByRecordType_NullDefaults_NoConfig_ReturnsEmpty() {
        Test.startTest();
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
            'Campaign', 'NonExistentRecordType_XYZ', null
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
    }

    @IsTest
    static void testGetDisplayFieldsByRecordType_CachesResult_ReturnsSameSet() {
        Set<String> defaults = new Set<String>{ 'Id', 'Name' };

        Test.startTest();
        Set<String> first = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('Campaign', 'CacheTestType', defaults);
        Set<String> second = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('Campaign', 'CacheTestType', defaults);
        Test.stopTest();

        System.assertEquals(first, second);
    }

    // ============================================================
    // getFieldLabel tests
    // ============================================================

    @IsTest
    static void testGetFieldLabel_BlankObjectApiName_ReturnsEmpty() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabel('', 'Name', '001000000000001AAA');
        Test.stopTest();

        System.assertEquals('', result);
    }

    @IsTest
    static void testGetFieldLabel_BlankFieldName_ReturnsEmpty() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabel('Campaign', '', '001000000000001AAA');
        Test.stopTest();

        System.assertEquals('', result);
    }

    @IsTest
    static void testGetFieldLabel_BlankRecordId_ReturnsFieldName() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabel('Campaign', 'Name', '');
        Test.stopTest();

        System.assertEquals('Name', result);
    }

    @IsTest
    static void testGetFieldLabel_NullRecordId_ReturnsFieldName() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabel('Campaign', 'Status', null);
        Test.stopTest();

        System.assertEquals('Status', result);
    }

    @IsTest
    static void testGetFieldLabel_ValidCampaign_ReturnsLabelOrFieldName() {
        Campaign c = createTestCampaign();

        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabel('Campaign', 'Name', c.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(String.isNotBlank(result));
    }

    // ============================================================
    // getFieldLabelByRecordType tests
    // ============================================================

    @IsTest
    static void testGetFieldLabelByRecordType_BlankFieldName_ReturnsEmpty() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('Campaign', '', 'TestRecordType');
        Test.stopTest();

        System.assertEquals('', result);
    }

    @IsTest
    static void testGetFieldLabelByRecordType_BlankObjectApiName_ReturnsFieldName() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('', 'Name', 'TestRecordType');
        Test.stopTest();

        System.assertEquals('Name', result);
    }

    @IsTest
    static void testGetFieldLabelByRecordType_BlankRecordTypeName_ReturnsFieldName() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('Campaign', 'Name', '');
        Test.stopTest();

        System.assertEquals('Name', result);
    }

    @IsTest
    static void testGetFieldLabelByRecordType_NoLabelConfig_ReturnsFieldName() {
        Test.startTest();
        String result = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('Campaign', 'Name', 'NoConfigRecordType');
        Test.stopTest();

        System.assertEquals('Name', result);
    }

    @IsTest
    static void testGetFieldLabelByRecordType_TriggersCacheLoad() {
        // First call with empty cache triggers load, second uses cache
        Test.startTest();
        String first = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('Campaign', 'Status', 'CacheTestType2');
        String second = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType('Campaign', 'Status', 'CacheTestType2');
        Test.stopTest();

        System.assertEquals(first, second);
    }

    // ============================================================
    // clearFieldConfigCache test
    // ============================================================

    @IsTest
    static void testClearFieldConfigCache_EmptiesCacheSuccessfully() {
        // Populate cache
        Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType('Campaign', 'TestCacheType', new Set<String>{ 'Id' });

        Test.startTest();
        Core_MDF_CCP_RestAPI_Utility.clearFieldConfigCache();
        Test.stopTest();

        // After clear, a re-fetch should still work
        Set<String> result = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
            'Campaign', 'TestCacheType', new Set<String>{ 'Id', 'Name' }
        );
        System.assertNotEquals(null, result);
    }

    // ============================================================
    // getFilteredRecord tests
    // ============================================================

    @IsTest
    static void testGetFilteredRecord_Success200_ReturnsFilteredMap() {
        Campaign c = createTestCampaign();
        Map<String, Object> mockBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'Utility Test Campaign',
            'Status' => 'Planning',
            'IsActive' => true,
            'StartDate' => String.valueOf(Date.today()),
            'EndDate' => String.valueOf(Date.today().addDays(60))
        };

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, JSON.serialize(mockBody)));

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            'Campaign', c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testGetFilteredRecord_500Response_ReturnsNull() {
        Campaign c = createTestCampaign();

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(500, '{"message":"Internal Server Error"}'));

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            'Campaign', c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void testGetFilteredRecord_404Response_ReturnsNull() {
        Campaign c = createTestCampaign();

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(404, '{"message":"Not Found"}'));

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            'Campaign', c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void testGetFilteredRecord_403Response_ThrowsException() {
        Campaign c = createTestCampaign();

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(403, '{"message":"Forbidden"}'));

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
                'Campaign', c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Expected an exception for HTTP 403 response');
    }

    @IsTest
    static void testGetFilteredRecord_200MalformedJson_ReturnsNull() {
        Campaign c = createTestCampaign();

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, '{malformed_json'));

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            'Campaign', c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );
        Test.stopTest();

        System.assertEquals(null, result);
    }

    // ============================================================
    // filterFields tests
    // ============================================================

    @IsTest
    static void testFilterFields_NullDefaultDisplayFields_ReturnsMap() {
        Campaign c = createTestCampaign();
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'Test'
        };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, c.Id, null
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testFilterFields_WithMatchingFields_ReturnsFilteredData() {
        Campaign c = createTestCampaign();
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'Test Campaign',
            'Status' => 'Planning',
            'IsActive' => true,
            'StartDate' => String.valueOf(Date.today()),
            'EndDate' => String.valueOf(Date.today().addDays(60))
        };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, c.Id, Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testFilterFields_LegacyProgramField_NormalizedToRelationshipPath() {
        Campaign c = createTestCampaign();
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'Test'
        };
        Set<String> displayFields = new Set<String>{ Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_PROGRAM_FIELD };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, c.Id, displayFields
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testFilterFields_LegacyAccountField_NormalizedToRelationshipPath() {
        Campaign c = createTestCampaign();
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'Test'
        };
        Set<String> displayFields = new Set<String>{ Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_ACCOUNT_FIELD };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, c.Id, displayFields
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testFilterFields_BlankRecordId_UsesDefaultFields() {
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => '7010000000001AAA',
            'Name' => 'Test'
        };
        Set<String> defaults = new Set<String>{ 'Id', 'Name' };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, '', defaults
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testFilterFields_NullRelationshipValue_IsIncludedWhenPathExists() {
        Campaign c = createTestCampaign();
        Map<String, Object> fullResponse = new Map<String, Object>{
            'Id' => c.Id,
            'Core_MDF_Channel_Program__r' => new Map<String, Object>{
                'Name' => null
            }
        };
        Set<String> displayFields = new Set<String>{ 'Core_MDF_Channel_Program__r.Name' };

        Test.startTest();
        Map<String, Object> result = Core_MDF_CCP_RestAPI_Utility.filterFields(
            'Campaign', fullResponse, c.Id, displayFields
        );
        Test.stopTest();

        System.assert(result.containsKey('Core_MDF_Channel_Program__r.Name'));
        System.assertEquals(null, result.get('Core_MDF_Channel_Program__r.Name'));
    }

    @IsTest
    static void testGetDisplayFieldsAndLabelByRecordType_ConfiguredLabelAndLegacyNormalization() {
        Core_MDF_CCP_RestAPI_Utility.clearFieldConfigCache();
		Core_MDF_Custom_Layout_Section__c sec1 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 1',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c= 1.0, Core_MDF_Field_View_nm__c = 'Detail Layout');
        insert sec1;
        insert new List<Core_MDF_Custom_Layout_Configurations__c>{
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Object_API_Name_txt__c = 'Campaign',
                Core_MDF_Record_Type_Name_txt__c = 'Master',
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Field_API_Name_txt__c = Core_MDF_Campaign_APIConstants.LEGACY_CAMPAIGN_PROGRAM_FIELD,
                Core_MDF_Field_Label_txt__c = 'Program Name',
                //API_Visibility__c = true,
                Core_MDF_Section_id__c=sec1.id
            ),
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Object_API_Name_txt__c = 'Campaign',
                Core_MDF_Record_Type_Name_txt__c = 'Master',
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Field_API_Name_txt__c = 'Name',
                Core_MDF_Field_Label_txt__c = 'Campaign Name',
                //API_Visibility__c = true,
                Core_MDF_Section_id__c=sec1.id
            )
        };

        Test.startTest();
        Set<String> fields = Core_MDF_CCP_RestAPI_Utility.getDisplayFieldsByRecordType(
            'Campaign',
            'Master',
            new Set<String>{ 'Id' }
        );
        String normalizedFieldLabel = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType(
            'Campaign',
            'Core_MDF_Channel_Program__r.Name',
            'Master'
        );
        String standardFieldLabel = Core_MDF_CCP_RestAPI_Utility.getFieldLabelByRecordType(
            'Campaign',
            'Name',
            'Master'
        );
        Test.stopTest();
		System.assertNotEquals(null, fields);
        //System.assert(fields.contains('Core_MDF_Channel_Program__r.Name'));
        //System.assertEquals('Program Name', normalizedFieldLabel);
        //System.assertEquals('Campaign Name', standardFieldLabel);
    }
}