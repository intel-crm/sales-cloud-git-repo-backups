/**
 * Class Name      : Core_MDF_PFC_RestAPI
 * Author          : 
 * Created Date    : 
 * Description     : REST entrypoint for Partner Fund Claims 
 */

@RestResource(urlMapping='/v1.0/partnercenter/claims/create/*')
global without sharing class Core_MDF_PFC_RestAPI {
    private static final Integer MAX_CLAIMS_PER_REQUEST = Core_MDF_PFC_RestAPIConstants.MAX_CLAIMS_PER_REQUEST;
    @HttpPost
    global static void handleRequest() {
        Datetime entryTime = System.now();
        String requestBodyForLog;
        List<String> logErrors;

        try {
            // Validate Request Body
            String requestBody = getRequestBody();
            requestBodyForLog = requestBody;
            if (String.isBlank(requestBody)) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8001_REQUEST_BODY_REQUIRED));
                return;
            }

            // Validate payload structure and parse into the typed input wrapper.
            List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claimsPayload;
            try {
                Core_MDF_PFC_RestAPI_InputWrapper inputWrapper = Core_MDF_PFC_RestAPI_InputWrapper.parse(requestBody);
                claimsPayload = inputWrapper.getClaimDetails();
            } catch (Exception ex) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE));
                return;
            }
            if (claimsPayload == null || claimsPayload.isEmpty()) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE));
                return;
            }
            if (claimsPayload.size() > MAX_CLAIMS_PER_REQUEST) {
                Core_MDF_PFC_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_RestAPIConstants.CODE_8031_MAX_CLAIMS_EXCEEDED
                );
                String configuredMessage = response != null && response.error != null
                    ? response.error.message
                    : null;
                if (String.isNotBlank(configuredMessage) && configuredMessage.contains('{value}')) {
                    response.setErrorInfo(
                        configuredMessage.replace('{value}', String.valueOf(MAX_CLAIMS_PER_REQUEST)),
                        Core_MDF_PFC_RestAPIConstants.CODE_8031_MAX_CLAIMS_EXCEEDED
                    );
                }
                sendResponse(response);
                return;
            }

            // Validate Claims
            Core_MDF_PFC_APIUtil.ValidationResult validationResult = Core_MDF_PFC_APIUtil.validateClaims(claimsPayload, false);
            if (validationResult == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR));
                return;
            }
            if (!validationResult.isSuccess) {
                sendResponse(validationResult.response);
                return;
            }  

            Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidationResult = Core_MDF_PFC_APIUtil.validateActivityAndCountry(validationResult.validWrappers);
            if (businessValidationResult == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR));
                return;
            }     
            sendResponse(Core_MDF_PFC_APIUtil.processClaimsInBulk(validationResult.validWrappers, businessValidationResult));
            return;

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            Core_MDF_PFC_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR);
            sendResponse(response);
            return;
        } finally {
            try {
                Core_MDF_RestAPI_Logger.LogRequest logReq = new Core_MDF_RestAPI_Logger.LogRequest();
                String responseBodyText = (RestContext.response != null && RestContext.response.responseBody != null)
                    ? RestContext.response.responseBody.toString()
                    : null;
                Object responsePayloadForLog = deserializeResponseForLog(responseBodyText);

                if (logErrors == null) {
                    logErrors = extractErrorsForLog(responsePayloadForLog);
                }

                Boolean isSuccessForLog = false;
                if (responsePayloadForLog instanceof Map<String, Object>) {
                    Map<String, Object> payloadMap = (Map<String, Object>) responsePayloadForLog;
                    Object successValue = payloadMap.get('isSuccess');
                    if (successValue instanceof Boolean) {
                        isSuccessForLog = (Boolean) successValue;
                    }
                }

                logReq.apiName = 'Core_MDF_PFC_RestAPI';
                logReq.apiVersion = 'v1.0';
                logReq.contextMessage = 'POST partner fund claims';
                logReq.requestPayload = requestBodyForLog;
                logReq.responsePayload = responsePayloadForLog;
                logReq.statusCode = RestContext.response != null
                    ? String.valueOf(RestContext.response.statusCode)
                    : '500';
                logReq.isSuccess = isSuccessForLog;
                logReq.errors = logErrors;
                logReq.entryTime = entryTime;
                logReq.exitTime = System.now();

                Core_MDF_RestAPI_Logger.logToTransactionEntry(logReq);
            } catch (Exception logEx) {
                Core_MDF_CCP_UtilityClass.logError(logEx);
            }
        }
    }

    private static void sendResponse(Core_MDF_PFC_APIResponse response) {
        try {
            if (RestContext.response == null) {
                RestContext.response = new RestResponse();
            }
            RestContext.response.statusCode = resolveHttpStatusCode(response);
            RestContext.response.addHeader(
                Core_MDF_PFC_RestAPIConstants.CONTENT_TYPE_HEADER,
                Core_MDF_PFC_RestAPIConstants.CONTENT_TYPE_JSON
            );
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response.getSerializedResponse()));
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    private static String getRequestBody() {
        try {
            RestRequest request = RestContext.request;
            return request?.requestBody?.toString();
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return Core_MDF_PFC_RestAPIConstants.EMPTY_STRING; }
    }

    private static Integer resolveHttpStatusCode(Core_MDF_PFC_APIResponse response) {
        if (response == null) {
            return 500;
        }

        // Primary path: buildErrorResponseFromCode now copies Core_Http_Status_Code__c
        // from Core_MDF_External_API_Response_Codes__c into response.httpStatusCode.
        // When that value is present, we should use it directly instead of any local mapping.
        if (response.httpStatusCode != null) {
            return response.httpStatusCode;
        }

        // Legacy fallback path: keep this logic for responses that are still assembled manually
        // with setErrorInfo/setSuccessInfo and do not yet populate response.httpStatusCode.
        // Once every response path is config-driven and sets httpStatusCode, this block can be removed.
        if (response.isSuccess == true) {
            return 200;
        }

        String responseCode = response.getCode();
        if (responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8018_INTERNAL_SERVER_ERROR
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR) {
            return 500;
        }

        if (responseCode == Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS) {
            return 207;
        }

        if (responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8001_REQUEST_BODY_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8003_CLAIM_TITLE_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8004_ACTIVITY_NUMBER_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8005_CLAIM_SUBMITTER_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8006_INVALID_CLAIM_DATES
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8009_CLAIM_CURRENCY_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8012_INVALID_TOTAL_AMOUNT_LOCAL
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8013_INVALID_COSTS_NOT_REIMBURSABLE
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8015_CLAIM_COUNTRY_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8019_COUNTRY_NOT_IN_ACTIVITY
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8022_PROOF_OF_COST_NUMBER_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8027_PROCESSING_PREFERENCE_REQUIRED
            || responseCode == Core_MDF_PFC_RestAPIConstants.CODE_8039_INVALID_CLAIM_TYPE) {
            return 400;
        }

        return 200;
    }

    private static Object deserializeResponseForLog(String responseBodyText) {
        if (String.isBlank(responseBodyText)) {
            return null;
        }

        try {
            return JSON.deserializeUntyped(responseBodyText);
        } catch (Exception ex) {
            return responseBodyText;
        }
    }

    private static List<String> extractErrorsForLog(Object responsePayloadForLog) {
        List<String> errors = new List<String>();
        if (!(responsePayloadForLog instanceof Map<String, Object>)) {
            return errors;
        }

        Map<String, Object> payloadMap = (Map<String, Object>) responsePayloadForLog;
        Object successValue = payloadMap.get('isSuccess');
        if (!(successValue instanceof Boolean) || (Boolean) successValue == true) {
            return errors;
        }

        Object errorObj = payloadMap.get('error');
        if (errorObj instanceof Map<String, Object>) {
            Map<String, Object> errorMap = (Map<String, Object>) errorObj;
            if (errorMap.containsKey('message') && errorMap.get('message') != null) {
                errors.add(String.valueOf(errorMap.get('message')));
            }
        }

        return errors;
    }

}