/**
 * Apex Plugin for External Client App OAuth policy.
 *
 * Purpose:
 * Enforce integration-user authorization at token issuance time so accidental
 * permission set assignments do not allow additional users to obtain tokens.
 */
global with sharing class Core_MDF_RestAPI_ConnectedAppPlugin extends Auth.ExternalClientAppOauthHandler {

    // TEMP QA BYPASS CONFIG (REMOVE BEFORE PRODUCTION GO-LIVE): START
    // This bypass allows QA API testing without JWT token only when both are true:
    // 1) Request base URL is https://test.salesforce.com
    // 2) User profile is System Administrator or IT Admin
    @TestVisible
    private static final Set<String> TEMP_QA_BYPASS_PROFILE_NAMES = new Set<String>{
        'System Administrator',
        'IT Admin'
    };

    // TEMP QA BYPASS CONFIG (REMOVE BEFORE PRODUCTION GO-LIVE): END

    // Strict 1:1 user-to-external-client-app mapping is stored in hierarchy custom setting
    // Core_MDF_External_App_User_Mapping__c at user/profile/org level.

    global override Boolean authorize(Id userId, Id ecAppId, Boolean isAdminApproved, Auth.InvocationContext context) {
        try {
            if (userId == null || ecAppId == null) {
                return false;
            }

            User tokenUser = [SELECT Id, Username, IsActive, Profile.Name FROM User WHERE Id = :userId LIMIT 1];
            if (!tokenUser.IsActive) {
                return false;
            }

            // TEMP QA PROFILE ENFORCEMENT (REMOVE BEFORE PRODUCTION GO-LIVE): START
            // During QA, only allow token issuance for explicitly approved admin profiles.
            /*if (!isTemporaryQaBypassProfileAllowed(tokenUser.Profile.Name)) {
                return false;
            }*/
            // TEMP QA PROFILE ENFORCEMENT (REMOVE BEFORE PRODUCTION GO-LIVE): END

            // TEMP QA BYPASS (REMOVE BEFORE PRODUCTION GO-LIVE): START
            // Keep this check isolated so it can be deleted cleanly later.
            /*if (isTemporaryQaBypassProfileAllowed(tokenUser.Profile.Name)) {
                return true;
            }*/
            // TEMP QA BYPASS (REMOVE BEFORE PRODUCTION GO-LIVE): END

            if (!isMappedExternalClientAppForUser(userId, ecAppId)) {
                return false;
            }

            if (!hasExternalClientAppAccess(userId, ecAppId)) {
                return false;
            }

            // Authorization is based on active user + strict user-to-app mapping + app access.
            return true;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return false;
        }
    }

    @TestVisible
    private static Boolean isMappedExternalClientAppForUser(Id userId, Id ecAppId) {
        Core_MDF_External_App_User_Mapping__c mappingConfig =
            Core_MDF_External_App_User_Mapping__c.getInstance(userId);

        String mappedEcAppId = (mappingConfig == null)
            ? null
            : String.valueOf(mappingConfig.get('External_Client_App_Id__c'));

        if (String.isBlank(mappedEcAppId)) {
            return false;
        }

        return mappedEcAppId == String.valueOf(ecAppId);
    }

    @TestVisible
    private static Boolean hasExternalClientAppAccess(Id userId, Id ecAppId) {
        try {
            Set<Id> assignedPermissionSetIds = new Set<Id>();
            for (PermissionSetAssignment psa : [
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                AND PermissionSetId != null
            ]) {
                assignedPermissionSetIds.add(psa.PermissionSetId);
            }

            if (assignedPermissionSetIds.isEmpty()) {
                return false;
            }

            return [
                SELECT Id
                FROM SetupEntityAccess
                WHERE ParentId IN :assignedPermissionSetIds
                AND SetupEntityId = :ecAppId
                LIMIT 1
            ].size() > 0;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return false;
        }
    }

    // TEMP QA BYPASS HELPER (REMOVE BEFORE PRODUCTION GO-LIVE)
    @TestVisible
    private static Boolean isTemporaryQaBypassProfileAllowed(String profileName) {
        return TEMP_QA_BYPASS_PROFILE_NAMES.contains(profileName);
    }

    global override Map<String, String> customAttributes(
        Id userId,
        Id ecAppId,
        Map<String, String> formulaDefinedAttributes,
        Auth.InvocationContext context
    ) {
        return formulaDefinedAttributes;
    }

    global override void refresh(Id userId, Id ecAppId, Auth.InvocationContext context) {
        // No-op: token refresh policy does not require additional behavior.
    }
}