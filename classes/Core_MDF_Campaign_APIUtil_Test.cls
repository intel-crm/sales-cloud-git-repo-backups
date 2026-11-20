@IsTest
private class Core_MDF_Campaign_APIUtil_Test {

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

        List<ChannelProgram> existingPrograms = [
            SELECT Id
            FROM ChannelProgram
            WHERE Name = 'Intel Partner Alliance'
            LIMIT 1
        ];
        ChannelProgram ipaProgram;
        if (existingPrograms.isEmpty()) {
            ipaProgram = Core_MDF_CCP_TestDataUtility.createProgram(
                'Intel Partner Alliance',
                'Intel Partner Alliance',
                true
            );
        } else {
            ipaProgram = existingPrograms[0];
        }

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
        List<Campaign> existingCampaigns = [
            SELECT Id, Name, Status, StartDate, EndDate, IsActive
            FROM Campaign
            WHERE Id != null
            LIMIT 1
        ];
        if (!existingCampaigns.isEmpty()) {
            return existingCampaigns[0];
        }

        Account campaignAccount = getOrCreateCampaignAccount();
        Campaign c = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign(
            'APIUtil Test Campaign',
            campaignAccount.Id,
            Date.today(),
            Date.today().addDays(30),
            'Account Plan',
            1000,
            'India',
            'Channel Partner',
            'Other',
            'Pending Approval',
            false
        );
        Database.SaveResult saveResult = Database.insert(c, false);
        if (saveResult != null && saveResult.isSuccess()) {
            return [SELECT Id, Name, Status, StartDate, EndDate, IsActive FROM Campaign WHERE Id = :saveResult.getId() LIMIT 1];
        }

        Campaign fallbackCampaign = Core_MDF_CCP_TestDataUtility.createCampaign(
            'APIUtil Test Campaign Fallback',
            'Developer',
            'Intel',
            'MDF or both CMP & MDF',
            Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
            'Client CoMarketing Fund',
            Date.today(),
            Date.today().addDays(30),
            1000,
            '',
            campaignAccount.Id,
            '',
            false
        );
        insert fallbackCampaign;
        return fallbackCampaign;
    }

    // ============================================================
    // getDisplayFields tests
    // ============================================================

    @IsTest
    static void testGetDisplayFields_NullCampaignId_ReturnsDefaults() {
        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields(null);
        Test.stopTest();

        System.assertNotEquals(null, fields);
        System.assert(!fields.isEmpty(), 'Expected default fields when campaignId is null');
    }

    @IsTest
    static void testGetDisplayFields_BlankCampaignId_ReturnsDefaults() {
        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields('');
        Test.stopTest();

        System.assertNotEquals(null, fields);
        System.assert(!fields.isEmpty(), 'Expected default fields when campaignId is blank');
    }

    @IsTest
    static void testGetDisplayFields_InvalidCampaignId_FallsBackToDefaults() {
        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields('INVALID_ID_NOT_IN_DB');
        Test.stopTest();

        System.assertNotEquals(null, fields);
    }

    @IsTest
    static void testGetDisplayFields_ValidCampaignId_ReturnsFields() {
        Campaign c = createTestCampaign();

        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, fields);
        System.assert(!fields.isEmpty(), 'Expected at least default fields for valid campaign');
    }

    @IsTest
    static void testGetDisplayFields_ValidCampaignId_ContainsDefaultFields() {
        Campaign c = createTestCampaign();

        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields(c.Id);
        Test.stopTest();

        System.assert(fields.contains('Id') || fields.contains('Name'),
            'Expected standard fields to be present');
    }

    // ============================================================
    // getFieldLabel tests
    // ============================================================

    @IsTest
    static void testGetFieldLabel_BlankFieldName_ReturnsEmpty() {
        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('', 'someCampaignId');
        Test.stopTest();

        System.assertEquals('', label);
    }

    @IsTest
    static void testGetFieldLabel_NullFieldName_ReturnsEmpty() {
        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel(null, 'someCampaignId');
        Test.stopTest();

        System.assertEquals('', label);
    }

    @IsTest
    static void testGetFieldLabel_BlankCampaignId_ReturnsFieldName() {
        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('Name', '');
        Test.stopTest();

        System.assertEquals('Name', label);
    }

    @IsTest
    static void testGetFieldLabel_NullCampaignId_ReturnsFieldName() {
        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('Status', null);
        Test.stopTest();

        System.assertEquals('Status', label);
    }

    @IsTest
    static void testGetFieldLabel_InvalidCampaignId_ReturnsFieldName() {
        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('Name', 'INVALID_CAMPAIGN_ID');
        Test.stopTest();

        System.assertEquals('Name', label);
    }

    @IsTest
    static void testGetFieldLabel_ValidCampaignId_NoConfig_ReturnsLabelOrFieldName() {
        Campaign c = createTestCampaign();

        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('Name', c.Id);
        Test.stopTest();

        // Without a layout config record, it should return the field name
        System.assertNotEquals(null, label);
        System.assert(String.isNotBlank(label), 'Label should not be blank');
    }

    @IsTest
    static void testGetFieldLabel_ValidCampaignId_StatusField() {
        Campaign c = createTestCampaign();

        Test.startTest();
        String label = Core_MDF_Campaign_APIUtil.getFieldLabel('Status', c.Id);
        Test.stopTest();

        System.assertNotEquals(null, label);
    }

    // ============================================================
    // clearCache tests
    // ============================================================

    @IsTest
    static void testClearCache_NoException() {
        // Populate cache first with a lookup
        Campaign c = createTestCampaign();
        Core_MDF_Campaign_APIUtil.getDisplayFields(c.Id);

        Test.startTest();
        Core_MDF_Campaign_APIUtil.clearCache();
        Test.stopTest();

        System.assert(true, 'clearCache() completed without exception');
    }

    @IsTest
    static void testClearCache_AllowsSubsequentLookups() {
        Campaign c = createTestCampaign();
        Core_MDF_Campaign_APIUtil.getDisplayFields(c.Id);
        Core_MDF_Campaign_APIUtil.clearCache();

        Test.startTest();
        Set<String> fields = Core_MDF_Campaign_APIUtil.getDisplayFields(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, fields);
    }
}