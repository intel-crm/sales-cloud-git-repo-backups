/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Campaign_RestAPI
 * Author          : <YourName>
 * Created Date    : Jun 15, 2026
 * Description     : Wrapper around Salesforce standard REST API endpoint that calls
 *                   /services/data/v66.0/sobjects/campaign/{id} and filters response
 *                   to display only configured fields.
 * ----------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/v1.0/partnercenter/campaigndetails/*')
global with sharing class Core_MDF_Campaign_RestAPI {

    /**
     * Handle campaign details GET request.
     * Validates campaign id and returns filtered campaign data.
     */
    @HttpGet
    global static void getCampaignDetails() {
        ensureRestResponse();
        Datetime entryTime = System.now();
        Core_MDF_Campaign_APIResponse response;
        List<String> logErrors;
        try {
            String campaignId = extractCampaignIdFromUrl();
            if (String.isBlank(campaignId)) {
                response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
                sendErrorResponse(400, Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY);
                return;
            }

            if (!isValidCampaignId(campaignId)) {
                response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
                sendErrorResponse(400, Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID);
                return;
            }

            //Core_MDF_Campaign_APIResponse response = getCampaignDetailsViaStandardAPI(campaignId);
            response = getCampaignDetailsViaStandardAPI(campaignId); 
            RestContext.response.statusCode = response.isSuccess ? 200 : 500;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            response = createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            sendErrorResponse(500, Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
        } finally {
            Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
            logReq.apiName         = 'Core_MDF_Campaign_RestAPI';
            logReq.apiVersion      = 'v1.0';
            logReq.contextMessage  = 'GET campaign details';
            logReq.responsePayload = response;
            logReq.statusCode      = response != null ? response.code : Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR;
            logReq.isSuccess       = response != null ? response.isSuccess : false;
            logReq.errors          = logErrors;
            logReq.entryTime       = entryTime;
            logReq.exitTime        = System.now();
            Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
        }
    }

    /**
     * Fetch campaign data from standard API and apply configured filtering.
     * Returns success response when data is available, otherwise error response.
     *
     * @param campaignId Campaign record id from request URL.
     * @return API response wrapper with filtered details or error.
     */
    private static Core_MDF_Campaign_APIResponse getCampaignDetailsViaStandardAPI(String campaignId) {
        try {
            Map<String, Object> filteredData = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
                Core_MDF_Campaign_APIConstants.CAMPAIGN_OBJECT_API_NAME,
                campaignId,
                Core_MDF_Campaign_APIConstants.DEFAULT_CAMPAIGN_DISPLAY_FIELDS
            );
            if (filteredData == null) {
                return createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
            }
            return buildSuccessResponse(filteredData);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return createErrorResponse(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Clear cache to force refresh of configurations.
     * Useful for testing or when user mappings change.
     */
    public static void clearConfigCache() {
        Core_MDF_Campaign_APIUtil.clearCache();
    }

    /**
     * Extract campaign ID from the REST request URI.
     * URL format: /services/apexrest/v1.0/mdf/campaign/{campaignId}
     *
     * @return Campaign ID if present in URL, or null
     */
    private static String extractCampaignIdFromUrl() {
        try {
            if (RestContext.request == null) {
                return null;
            }

            String requestUri = RestContext.request.requestURI;
            System.debug('Request URI: ' + requestUri);

            // Extract the part after '/campaign/'
            Integer campaignIndex = requestUri.indexOf('/campaign/');
            if (campaignIndex == -1) {
                return null;
            }

            // Get the part after '/campaign/'
            String campaignIdPart = requestUri.substring(campaignIndex + 10); // '/campaign/' is 10 characters

            // Remove any query parameters
            Integer queryIndex = campaignIdPart.indexOf('?');
            if (queryIndex != -1) {
                campaignIdPart = campaignIdPart.substring(0, queryIndex);
            }

            // Trim whitespace
            campaignIdPart = campaignIdPart.trim();

            return String.isBlank(campaignIdPart) ? null : campaignIdPart;

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error extracting campaign ID from URL: ' + ex.getMessage());
            return null;
        }
    }

    /**
     * Validate campaign id format and object type.
     * Ensures id is alphanumeric, valid Salesforce Id, and belongs to Campaign.
     *
     * @param campaignId Candidate campaign id.
     * @return True when id is valid Campaign id; otherwise false.
     */
    private static Boolean isValidCampaignId(String campaignId) {
        if (String.isBlank(campaignId)) {
            return false;
        }

        String normalizedCampaignId = campaignId.trim();
        Integer idLength = normalizedCampaignId.length();
        if (idLength != 15 && idLength != 18) {
            return false;
        }

        if (!Pattern.matches('^[a-zA-Z0-9]+$', normalizedCampaignId)) {
            return false;
        }

        try {
            Id typedId = Id.valueOf(normalizedCampaignId);
            String idString = String.valueOf(typedId);

            Boolean hasCampaignPrefix = idString.startsWith(Core_MDF_Campaign_APIConstants.CAMPAIGN_KEY_PREFIX);
            Boolean isCampaignObjectType = typedId.getSObjectType() == Campaign.SObjectType;

            return hasCampaignPrefix && isCampaignObjectType;
        } catch (Exception ex) {
            return false;
        }
    }

    /**
     * Build a success response using Core_MDF_Campaign_APIResponse wrapper.
     * The filtered details map is assigned directly to response.details (type Object),
     * supporting any configured fields including custom fields.
     *
     * @param filteredData The filtered campaign data to include in response.
     * @return Core_MDF_Campaign_APIResponse with success status and data.
     */
    private static Core_MDF_Campaign_APIResponse buildSuccessResponse(Map<String, Object> filteredData) {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = true;
        response.code = Core_MDF_Campaign_APIConstants.SUCCESS_200;
        response.message = Core_MDF_Campaign_APIConstants.MSG_CAMPAIGN_DETAILS_RETRIEVED;
        response.details = filteredData;
        return response;
    }

    /**
     * Create standardized error response from error code.
     * Resolves user-facing message using constants map.
     *
     * @param errorCode Error code constant.
     * @return API response wrapper in error state.
     */
    private static Core_MDF_Campaign_APIResponse createErrorResponse(String errorCode) {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = false;
        response.code = errorCode;
        response.message = Core_MDF_Campaign_APIConstants.getErrorMessageByCode(errorCode);
        response.details = null;
        return response;
    }

    /**
     * Send serialized error response to REST context.
     * Sets status code and response body in one place.
     *
     * @param statusCode HTTP status code to return.
     * @param errorCode API error code to include in response.
     */
    private static void sendErrorResponse(Integer statusCode, String errorCode) {
        RestContext.response.statusCode = statusCode;
        Core_MDF_Campaign_APIResponse errorResponse = createErrorResponse(errorCode);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
    }

    /**
     * Ensure REST response object is initialized.
     * Creates response when context response is null.
     */
    private static void ensureRestResponse() {
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
    }
}