@IsTest
private class Core_MDF_RestAPI_ConnectedAppPlugin_Test {

    @IsTest
    static void testAuthorizeReturnsFalseWhenUserIdNull() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Boolean isAuthorized = plugin.authorize(
            null,
            UserInfo.getUserId(),
            false,
            null
        );

        System.assertEquals(false, isAuthorized, 'Null userId must not be authorized.');
    }

    @IsTest
    static void testAuthorizeUsesAllowListForCurrentUser() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Boolean isAuthorized = plugin.authorize(
            UserInfo.getUserId(),
            UserInfo.getUserId(),
            false,
            null
        );

        System.assertEquals(false, isAuthorized,
            'Authorization requires both allow-list match and explicit External Client App access.');
    }

    @IsTest
    static void testAuthorizeReturnsFalseWhenEcAppIdNull() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        Boolean isAuthorized = plugin.authorize(
            UserInfo.getUserId(),
            null,
            false,
            null
        );

        System.assertEquals(false, isAuthorized, 'Null ecAppId must not be authorized.');
    }

    @IsTest
    static void testHasExternalClientAppAccessReturnsFalseForInvalidAppId() {
        // Use a valid Salesforce Id format for a non-app setup entity to force a safe false path.
        Id nonAppSetupEntityId = Id.valueOf('001000000000000AAA');

        Boolean hasAccess = Core_MDF_RestAPI_ConnectedAppPlugin.hasExternalClientAppAccess(
            UserInfo.getUserId(),
            nonAppSetupEntityId
        );

        System.assertEquals(false, hasAccess,
            'User should not have External Client App access for a non-app setup entity Id.');
    }

    @IsTest
    static void testMappedExternalClientAppReturnsFalseWhenUserNotConfigured() {
        Boolean isMapped = Core_MDF_RestAPI_ConnectedAppPlugin.isMappedExternalClientAppForUser(
            UserInfo.getUserId(),
            Id.valueOf('0so000000000000AAA')
        );

        System.assertEquals(false, isMapped,
            'Authorization must fail when user is not mapped to any external client app.');
    }

    @IsTest
    static void testMappedExternalClientAppReturnsFalseWhenAppIdMismatch() {
        // Uses static placeholder key from plugin map to validate mismatch logic deterministically.
        Id mappedUserId = Id.valueOf('005XXXXXXXXXXXXAAA');
        Id wrongEcAppId = Id.valueOf('0so000000000000AAA');

        Boolean isMapped = Core_MDF_RestAPI_ConnectedAppPlugin.isMappedExternalClientAppForUser(
            mappedUserId,
            wrongEcAppId
        );

        System.assertEquals(false, isMapped,
            'Mapped user should be denied when presented external client app does not match map.');
    }

    @IsTest
    static void testCustomAttributesAndRefresh() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();
        Map<String, String> inputAttributes = new Map<String, String>{
            'preferred_username' => 'integration.user@intel.com',
            'locale' => 'en_US'
        };

        Map<String, String> outputAttributes = plugin.customAttributes(
            UserInfo.getUserId(),
            UserInfo.getUserId(),
            inputAttributes,
            null
        );

        System.assertEquals(inputAttributes, outputAttributes, 'customAttributes should currently pass through formula-defined attributes.');

        Test.startTest();
        plugin.refresh(UserInfo.getUserId(), UserInfo.getUserId(), null);
        Test.stopTest();

        System.assert(true, 'refresh should execute without throwing exceptions.');
    }

    @IsTest
    static void testAuthorizeReturnsFalseOnQueryException() {
        Core_MDF_RestAPI_ConnectedAppPlugin plugin = new Core_MDF_RestAPI_ConnectedAppPlugin();

        // Valid Id format, but not a User Id. This forces the query path into handled exception logic.
        Id nonUserId = Id.valueOf('001000000000000AAA');

        Boolean isAuthorized = plugin.authorize(
            nonUserId,
            UserInfo.getUserId(),
            false,
            null
        );

        System.assertEquals(false, isAuthorized, 'Non-User Id should fail authorization via handled exception path.');
    }
}