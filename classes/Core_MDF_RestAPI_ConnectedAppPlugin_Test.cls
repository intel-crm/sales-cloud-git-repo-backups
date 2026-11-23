@IsTest
private class Core_MDF_RestAPI_ConnectedAppPlugin_Test {

    // ============================================================
    // authorize() tests — null/invalid argument guards
    // ============================================================

    @IsTest
    static void testAuthorize_BothIdsNull_ReturnsFalse() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Test.startTest();
        Boolean result = plugin.authorize(null, null, false, null);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when both userId and ecAppId are null');
    }

    @IsTest
    static void testAuthorize_NullUserId_NonNullEcAppId_ReturnsFalse() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Id fakeEcAppId = UserInfo.getUserId();

        Test.startTest();
        Boolean result = plugin.authorize(null, fakeEcAppId, false, null);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when userId is null');
    }

    @IsTest
    static void testAuthorize_NullEcAppId_NonNullUserId_ReturnsFalse() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Test.startTest();
        Boolean result = plugin.authorize(UserInfo.getUserId(), null, false, null);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when ecAppId is null');
    }

    @IsTest
    static void testAuthorize_ActiveUser_NoMapping_ReturnsFalse() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Id userId = UserInfo.getUserId();
        Id fakeEcAppId = UserInfo.getUserId();

        Test.startTest();
        Boolean result = plugin.authorize(userId, fakeEcAppId, false, null);
        Test.stopTest();

        // Active user but no custom setting mapping — isMappedExternalClientAppForUser returns false
        System.assertEquals(false, result, 'Expected false when no user-to-app mapping exists');
    }

    // ============================================================
    // isMappedExternalClientAppForUser() tests
    // ============================================================

    @IsTest
    static void testIsMappedExternalClientAppForUser_NoCustomSetting_ReturnsFalse() {
        Id userId = UserInfo.getUserId();
        Id fakeEcAppId = UserInfo.getUserId();

        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isMappedExternalClientAppForUser(userId, fakeEcAppId);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when no custom setting mapping exists');
    }

    @IsTest
    static void testIsMappedExternalClientAppForUser_MappingExists_WrongAppId_ReturnsFalse() {
        Id userId = UserInfo.getUserId();
        Core_MDF_External_App_User_Mapping__c mapping = new Core_MDF_External_App_User_Mapping__c(
            SetupOwnerId = userId,
            External_Client_App_Id__c = 'SOME_OTHER_APP_ID'
        );
        insert mapping;

        Id differentFakeEcAppId = UserInfo.getUserId(); // different from the stored value

        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isMappedExternalClientAppForUser(userId, differentFakeEcAppId);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when mapped app ID does not match');
    }

    @IsTest
    static void testIsMappedExternalClientAppForUser_MatchingAppId_ReturnsTrue() {
        Id userId = UserInfo.getUserId();
        // Store the same ID string that String.valueOf(ecAppId) will produce
        String matchingAppId = String.valueOf(userId);
        Core_MDF_External_App_User_Mapping__c mapping = new Core_MDF_External_App_User_Mapping__c(
            SetupOwnerId = userId,
            External_Client_App_Id__c = matchingAppId
        );
        insert mapping;

        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isMappedExternalClientAppForUser(userId, userId);
        Test.stopTest();

        System.assertEquals(true, result, 'Expected true when mapped app ID matches the provided ecAppId');
    }

    @IsTest
    static void testAuthorize_MappingMatches_NoEcAppAccess_ReturnsFalse() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Id userId = UserInfo.getUserId();
        Id ecAppId = userId; // reused as fake ecApp ID — no real SetupEntityAccess will match

        // Mapping where External_Client_App_Id__c matches String.valueOf(ecAppId)
        Core_MDF_External_App_User_Mapping__c mapping = new Core_MDF_External_App_User_Mapping__c(
            SetupOwnerId = userId,
            External_Client_App_Id__c = String.valueOf(ecAppId)
        );
        insert mapping;

        Test.startTest();
        Boolean result = plugin.authorize(userId, ecAppId, false, null);
        Test.stopTest();

        // Mapping matches → isMappedExternalClientAppForUser returns true
        // No real SetupEntityAccess exists for this ecAppId → hasExternalClientAppAccess returns false
        System.assertEquals(false, result, 'Expected false when mapping matches but ecApp access is not granted');
    }

    // ============================================================
    // hasExternalClientAppAccess() tests
    // ============================================================

    @IsTest
    static void testHasExternalClientAppAccess_UserWithNoMatchingPermission_ReturnsFalse() {
        Id userId = UserInfo.getUserId();
        Id fakeEcAppId = UserInfo.getUserId();

        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.hasExternalClientAppAccess(userId, fakeEcAppId);
        Test.stopTest();

        // SetupEntityAccess query with a non-ecApp ID will return 0 rows
        System.assertEquals(false, result, 'Expected false when no SetupEntityAccess record matches');
    }

    @IsTest
    static void testHasExternalClientAppAccess_NewUserWithNoMatchingAccess_ReturnsFalse() {
        // Retrieve any valid profile to create a minimal test user
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'NoAccess',
            Email = 'testnoacc_' + System.currentTimeMillis() + '@example.com.test',
            Username = 'testnoacc_' + System.currentTimeMillis() + '@example.com.test',
            Alias = 'tna',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        // Isolate user DML from setup-object queries to prevent MIXED_DML_OPERATION
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }

        Id fakeEcAppId = UserInfo.getUserId(); // non-ecApp ID — SetupEntityAccess will return 0 rows

        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.hasExternalClientAppAccess(testUser.Id, fakeEcAppId);
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false when no SetupEntityAccess matches the provided ecAppId');
    }

    // ============================================================
    // isTemporaryQaBypassProfileAllowed() tests
    // ============================================================

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_SystemAdministrator_ReturnsTrue() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed('System Administrator');
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_ITAdmin_ReturnsTrue() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed('IT Admin');
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_StandardUser_ReturnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed('Standard User');
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_NullProfile_ReturnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed(null);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_EmptyString_ReturnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed('');
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @IsTest
    static void testIsTemporaryQaBypassProfileAllowed_PartialMatch_ReturnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_RestAPI_ConnectedAppPlugin.isTemporaryQaBypassProfileAllowed('System');
        Test.stopTest();

        System.assertEquals(false, result);
    }

    // ============================================================
    // TEMP_QA_BYPASS_PROFILE_NAMES constant test
    // ============================================================

    @IsTest
    static void testTempQaBypassProfileNames_ContainsExpectedProfiles() {
        Set<String> profiles = Core_MDF_RestAPI_ConnectedAppPlugin.TEMP_QA_BYPASS_PROFILE_NAMES;

        System.assertNotEquals(null, profiles);
        System.assert(profiles.contains('System Administrator'));
        System.assert(profiles.contains('IT Admin'));
        System.assertEquals(2, profiles.size());
    }

    // ============================================================
    // customAttributes() tests
    // ============================================================

    @IsTest
    static void testCustomAttributes_ReturnsInputMapUnmodified() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Map<String, String> inputAttributes = new Map<String, String>{
            'attr1' => 'value1',
            'attr2' => 'value2'
        };

        Test.startTest();
        Map<String, String> result = plugin.customAttributes(
            UserInfo.getUserId(), UserInfo.getUserId(), inputAttributes, null
        );
        Test.stopTest();

        System.assertEquals(inputAttributes, result);
        System.assertEquals('value1', result.get('attr1'));
        System.assertEquals('value2', result.get('attr2'));
    }

    @IsTest
    static void testCustomAttributes_NullInputMap_ReturnsNull() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Test.startTest();
        Map<String, String> result = plugin.customAttributes(
            UserInfo.getUserId(), UserInfo.getUserId(), null, null
        );
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void testCustomAttributes_EmptyMap_ReturnsEmptyMap() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Map<String, String> emptyMap = new Map<String, String>();

        Test.startTest();
        Map<String, String> result = plugin.customAttributes(
            UserInfo.getUserId(), UserInfo.getUserId(), emptyMap, null
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
    }

    // ============================================================
    // refresh() tests
    // ============================================================

    @IsTest
    static void testRefresh_NoException() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Test.startTest();
        plugin.refresh(UserInfo.getUserId(), UserInfo.getUserId(), null);
        Test.stopTest();

        System.assert(true, 'refresh() is a no-op and completed without exception');
    }

    @IsTest
    static void testRefresh_NullIds_NoException() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Test.startTest();
        plugin.refresh(null, null, null);
        Test.stopTest();

        System.assert(true, 'refresh() with null IDs completed without exception');
    }
}