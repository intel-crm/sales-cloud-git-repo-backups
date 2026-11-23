/**
 * Campaign details REST API implemented with standard SObject retrieval mode.
 *
 * Endpoint:
 * /services/apexrest/v1.0/mdf/campaign-standard/
 */
@RestResource(urlMapping='/v1.0/mdf/campaign-standard/*')
global with sharing class Core_MDF_Campaign_Standard_RestAPI {

    private static final String SUCCESS_200 = '200';
    private static final String CODE_7001_UNAUTHORIZED_ACCESS = '7001';
    private static final String CODE_7003_INTERNAL_SERVER_ERROR = '7003';
    private static final String CODE_7004_INVALID_CAMPAIGN_ID = '7004';
    private static final String CODE_7005_CAMPAIGN_ACCESS_DENIED = '7005';
    private static final String CODE_7006_CAMPAIGN_MAPPING_NOT_FOUND = '7006';

    private static final String MSG_7001_UNAUTHORIZED_ACCESS = 'User does not have access to Campaign API';
    private static final String MSG_7003_INTERNAL_SERVER_ERROR = 'Internal server error';
    private static final String MSG_7004_INVALID_CAMPAIGN_ID = 'Invalid Campaign Id';
    private static final String MSG_7005_CAMPAIGN_ACCESS_DENIED = 'User does not have access to the mapped Campaign';
    private static final String MSG_7006_CAMPAIGN_MAPPING_NOT_FOUND = 'No Campaign mapping configured for the current user';
    private static final String MSG_CAMPAIGN_DETAILS_RETRIEVED = 'Campaign details retrieved successfully';
    private static final String MSG_GENERIC_ERROR = 'An error occurred processing your request';

    private static final String PERMISSION_SET_NAME = 'IPIC_DELL_B2B';
    private static final String CAMPAIGN_KEY_PREFIX = '701';

    @TestVisible
    private static final Map<String, String> USERNAME_TO_CAMPAIGN_ID = new Map<String, String>{
        '12337753@intel.com.crm.crmdevccp' => '701dh00000kCu8tAAC'
    };

    @HttpGet
    global static Core_MDF_Campaign_APIResponse getCampaignDetails() {
        ensureRestResponse();
        try {
            if (!hasCCPAPIAccess()) {
                RestContext.response.statusCode = 401;
                return buildErrorResponseFromCode(CODE_7001_UNAUTHORIZED_ACCESS);
            }

            String campaignId = resolveMappedCampaignIdForCurrentUser();
            if (String.isBlank(campaignId)) {
                RestContext.response.statusCode = 500;
                return buildErrorResponseFromCode(CODE_7006_CAMPAIGN_MAPPING_NOT_FOUND);
            }

            if (!isValidCampaignId(campaignId)) {
                RestContext.response.statusCode = 500;
                return buildErrorResponseFromCode(CODE_7004_INVALID_CAMPAIGN_ID);
            }

            if (!hasCampaignAccess(campaignId)) {
                RestContext.response.statusCode = 403;
                return buildErrorResponseFromCode(CODE_7005_CAMPAIGN_ACCESS_DENIED);
            }

            Core_MDF_Campaign_APIResponse response = getCampaignDetailsWrapper(campaignId);

            RestContext.response.statusCode = response.isSuccess ? 200 : 500;
            return response;
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;
            Core_MDF_CCP_UtilityClass.logError(ex);
            return buildErrorResponseFromCode(CODE_7003_INTERNAL_SERVER_ERROR);
        }
    }

    private static Core_MDF_Campaign_APIResponse getCampaignDetailsWrapper(String campaignId) {
        return getCampaignDetailsUsingSObject(campaignId);
    }

    private static Core_MDF_Campaign_APIResponse getCampaignDetailsUsingSObject(String campaignId) {
        try {
            Campaign campaignRec = [
                SELECT Id, Name, Status, StartDate, EndDate, IsActive
                FROM Campaign
                WHERE Id = :campaignId
                WITH USER_MODE
                LIMIT 1
            ];
            return buildSuccessResponse(campaignRec);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return buildErrorResponseFromCode(CODE_7003_INTERNAL_SERVER_ERROR);
        }
    }

    private static Boolean hasCCPAPIAccess() {
        List<PermissionSetAssignment> psa = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
            AND PermissionSet.Name = :PERMISSION_SET_NAME
            LIMIT 1
        ];
        return !psa.isEmpty();
    }

    private static String resolveMappedCampaignIdForCurrentUser() {
        String username = UserInfo.getUserName();
        if (String.isBlank(username)) {
            return null;
        }
        String mappedCampaignId = USERNAME_TO_CAMPAIGN_ID.get(username.trim().toLowerCase());
        return String.isBlank(mappedCampaignId) ? null : mappedCampaignId.trim();
    }

    private static Boolean isValidCampaignId(String campaignId) {
        try {
            Id typedId = (Id)campaignId;
            String idString = String.valueOf(typedId);
            return idString.startsWith(CAMPAIGN_KEY_PREFIX);
        } catch (Exception ex) {
            return false;
        }
    }

    private static Boolean hasCampaignAccess(String campaignId) {
        if (!isValidCampaignId(campaignId)) {
            return false;
        }

        try {
            List<Campaign> campaignRows = [
                SELECT Id
                FROM Campaign
                WHERE Id = :campaignId
                WITH USER_MODE
                LIMIT 1
            ];
            return !campaignRows.isEmpty();
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return false;
        }
    }

    private static Core_MDF_Campaign_APIResponse buildSuccessResponse(Campaign campaignRec) {
        Core_MDF_Campaign_APIUtil.CampaignWrapper data = new Core_MDF_Campaign_APIUtil.CampaignWrapper();
        data.campaignId = campaignRec.Id;
        data.campaignName = campaignRec.Name;
        data.status = campaignRec.Status;
        data.startDate = campaignRec.StartDate;
        data.endDate = campaignRec.EndDate;
        data.isActive = campaignRec.IsActive;

        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = true;
        response.code = SUCCESS_200;
        response.message = MSG_CAMPAIGN_DETAILS_RETRIEVED;
        response.data = data;
        return response;
    }

    private static Core_MDF_Campaign_APIResponse buildErrorResponseFromCode(String errorCode) {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = false;
        response.code = errorCode;
        response.message = getErrorMessage(errorCode);
        return response;
    }

    private static String getErrorMessage(String errorCode) {
        if (errorCode == CODE_7001_UNAUTHORIZED_ACCESS) {
            return MSG_7001_UNAUTHORIZED_ACCESS;
        }
        if (errorCode == CODE_7003_INTERNAL_SERVER_ERROR) {
            return MSG_7003_INTERNAL_SERVER_ERROR;
        }
        if (errorCode == CODE_7004_INVALID_CAMPAIGN_ID) {
            return MSG_7004_INVALID_CAMPAIGN_ID;
        }
        if (errorCode == CODE_7005_CAMPAIGN_ACCESS_DENIED) {
            return MSG_7005_CAMPAIGN_ACCESS_DENIED;
        }
        if (errorCode == CODE_7006_CAMPAIGN_MAPPING_NOT_FOUND) {
            return MSG_7006_CAMPAIGN_MAPPING_NOT_FOUND;
        }
        return MSG_GENERIC_ERROR;
    }

    private static void ensureRestResponse() {
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
    }
}