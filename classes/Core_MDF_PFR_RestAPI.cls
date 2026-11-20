@RestResource(urlMapping='/v1.0/partnercenter/activity/*')
global without sharing class Core_MDF_PFR_RestAPI extends TriggerHandler {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_MDF_PFR_RestAPI.class.getName();
    private static final String BUSINESS_VALIDATION_STATUS = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private static final String ERR_CAMPAIGN_ACCESS_DENIED = '7008';
    private static final String CAMPAIGN_ACCESS_DENIED_MESSAGE = 'User does not have permission to view this campaign';
    private static final Boolean INCLUDE_ORIGINAL_ERROR_FOR_TESTING = false; // Set to false to hide technical errors from external system
    public static Core_MDF_PFR_RestAPI_Response response = new Core_MDF_PFR_RestAPI_Response();
    public static String actionType;
    public static List<String> rawErrorLogs = new List<String>();
    public static FileUploadResponse fileUploadResponse;
    
    /**
     * Helper method to get error message from custom settings
     * @param errorCode Numeric error code (e.g., '9000')
     * @param httpStatus Optional HTTP status code hint
     * @param context Optional context hint
     * @return Message from custom settings, or fallback message if not found
     */
    private static String getErrorMessage(String errorCode, String httpStatus, String context) {
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting = Core_MDF_PFR_RestAPI_Utility.getResponseCodeSetting(errorCode, httpStatus, context);
        if (setting != null && String.isNotBlank(setting.message)) {
            return setting.message;
        }
        // Fallback if custom setting not found
        return 'An error occurred. Please contact system administrator.';
    }
    
    @HttpPost
    global static void doPost() {
        response = new Core_MDF_PFR_RestAPI_Response();
        fileUploadResponse = null;
        rawErrorLogs = new List<String>();
        try {
            // Step 1: Validate the request body is not empty
            String requestBody = getRequestBody();
            if (String.isBlank(requestBody)) {
                handleException(null, '400');
                response.errorcode = Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS;
                response.message = getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS, '400', 'NO_RECORDS');
                serializeAndLogResponse();
                return;
            }
            // File-upload route: when the URL ends with "/uploadfile" (e.g. /v1.0/activity/uploadfile)
            // the request attaches a file to an existing activity instead of creating/updating a record.
            if (isFileUploadRequest()) {
                processFileUpload(requestBody);
                serializeAndLogResponse();
                return;
            }
            // Multi-Segment SPIF route: when the URL ends with "/validatespif"
            if (isSPIFValidationRequest()) {
                processSPIFValidation(requestBody);
                serializeAndLogResponse();
                return;
            }
            // Step 2: Validate the action parameter (defaults to "create")
            if (!validateActionParam()) {
                handleException(null, '400');
                serializeAndLogResponse();
                return;
            }
            processRequest(requestBody);

        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            handleException(e, '500');
        } finally {
            serializeAndLogResponse();
        }
    }
    private static Boolean isSPIFValidationRequest() {
        RestRequest req = RestContext.request;
        if (req == null || String.isBlank(req.requestURI)) {
            return false;
        }
        String path = req.requestURI;
        Integer queryIndex = path.indexOf('?');
        if (queryIndex >= 0) {
            path = path.substring(0, queryIndex);
        }
        return path.toLowerCase().endsWith('/validatespif');
    }
    private static void processSPIFValidation(String reqBody) {
        RestResponse restResponse = RestContext.response;
        
        try {
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
            List<Map<String, Object>> segments = new List<Map<String, Object>>();
            Object segmentsObj = requestMap.get('Segments');
            if (segmentsObj instanceof List<Object>) {
                List<Object> segList = (List<Object>) segmentsObj;
                for (Object seg : segList) {
                    if (seg instanceof Map<String, Object>) {
                        segments.add((Map<String, Object>) seg);
                    }
                }
            }
            String accountId = String.valueOf(requestMap.get('AccountId'));
            String program = String.valueOf(requestMap.get('Program'));
            String campaignId = String.valueOf(requestMap.get('CampaignId'));
            String budgetId = String.valueOf(requestMap.get('BudgetId'));
            String channelPartnerId = String.valueOf(requestMap.get('ChannelPartnerId'));
            Map<String, Object> validationResult = Core_MDF_PFR_RestAPI_Utility.validateSPIFSegments(
                segments,
                accountId,
                program,
                campaignId,
                budgetId,
                channelPartnerId
            );
            if (Boolean.valueOf(validationResult.get('isSuccess')) == true) {
                restResponse.statusCode = 200;
                restResponse.responseBody = Blob.valueOf(JSON.serialize(validationResult));
            } else {
                Map<String, Object> errorResponse = Core_MDF_PFR_RestAPI_Response.toErrorResponsePayload(
                    String.valueOf(validationResult.get('message')),
                    '400'
                );
                restResponse.statusCode = getHttpStatusCode(errorResponse, 400);
                restResponse.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            }
            restResponse.addHeader('Content-Type', 'application/json');
            
            Core_MDF_RestAPI_Logger.info('SPIF validation response sent');
            
        } catch (JSONException je) {
            Core_MDF_CCP_UtilityClass.logError(je);
            Core_MDF_RestAPI_Logger.error('JSON error: ' + je.getMessage());
            restResponse.statusCode = 400;
            Map<String, Object> errorResponse = Core_MDF_PFR_RestAPI_Response.toErrorResponsePayload(
                Core_MDF_PFR_RestAPI_Constants.ERR_9010_INVALID_JSON_BODY,
                '400'
            );
            restResponse.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            restResponse.addHeader('Content-Type', 'application/json');
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            Core_MDF_RestAPI_Logger.error('SPIF error: ' + e.getMessage());
            restResponse.statusCode = 500;
            Map<String, Object> errorResponse = Core_MDF_PFR_RestAPI_Response.toErrorResponsePayload(
                Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR,
                '500'
            );
            restResponse.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            restResponse.addHeader('Content-Type', 'application/json');
        }
    }
    private static void serializeAndLogResponse() {
        if (String.isBlank(response.code)) {
            response.code = '200';
        }
        if (RestContext.response != null) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            Object payload = getResponsePayload();
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(payload, true));
            RestContext.response.statusCode = Integer.valueOf(response.code);
        }
        Object responsePayload = getResponsePayload();
        Core_MDF_RestAPI_Logger.logFromRestContext(
            'Core_MDF_PFR_RestAPI',
            responsePayload,
            response.code,
            Boolean.valueOf(response.isSuccess),
            rawErrorLogs,
            'POST /v1.0/activity'
        );
        logToCoreLogEntry('API Transaction');
    }        
    private static Object getResponsePayload() {
        if (fileUploadResponse != null) {
            return fileUploadResponse.isSuccess == true
                ? (Object) fileUploadResponse
                : (Object) Core_MDF_PFR_RestAPI_Response.toErrorResponsePayload(fileUploadResponse.errorContent, fileUploadResponse.code);
        }
        return response.isSuccess == true ? (Object) response : response.toErrorResponsePayloadBody();
    }

    private static Integer getHttpStatusCode(Map<String, Object> payload, Integer fallbackStatusCode) {
        if (payload == null || payload.get('httpStatusCode') == null) {
            return fallbackStatusCode;
        }
        try {
            return Integer.valueOf(String.valueOf(payload.get('httpStatusCode')));
        } catch (Exception e) {
            return fallbackStatusCode;
        }
    }

    private static String getRequestBody() {
        try {
            RestRequest request = RestContext.request;
            if (request == null || request.requestBody == null) {
                return null;
            }
            return request.requestBody.toString();
        } catch (Exception e) {  return null; }
        }
    public static boolean validateActionParam() {
        actionType = Core_MDF_PFR_RestAPI_Utility.getRequestParam('action');
        if (String.isBlank(actionType)) {
            // An update always supplies the record Id via the URL "id" parameter, so infer "update"
            // when an id is present; otherwise default to "create". This ensures partial-update
            // payloads are not rejected by the create-time required-field validation.
            actionType = String.isNotBlank(Core_MDF_PFR_RestAPI_Utility.getRequestParam('id')) ? 'update' : 'create';
        }
        return 'create'.equalsIgnoreCase(actionType) || 'update'.equalsIgnoreCase(actionType);
    }
    
    /**
     * Orchestrates a single activity request: deserialize the "activity" root node,
     * run business validations, attempt DML and capture record-level errors.
     */
    public static void processRequest(String reqBody) {
        try {
            Boolean isUpdate = 'update'.equalsIgnoreCase(actionType);

            // Step 3 & 4: Validate JSON / root node "activity" and deserialize into PartnerFundRequest
            Core_MDF_PFR_RestAPI_InputWrapper wrapper = Core_MDF_PFR_RestAPI_InputWrapper.parse(reqBody);
            List<PartnerFundRequest> pfrs = wrapper.getPartnerFundRequests();
            List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures = wrapper.getValidationFailures();

            // No activity record could be read from the payload
            if (pfrs.isEmpty() && failures.isEmpty()) {
                handleException(null, '400');
                response.errorcode = Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS;
                response.message = getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS, '400', 'NO_RECORDS');
                return;
            } else if (pfrs.isEmpty()) {
                // Only structural / deserialization failures were found
                prepareValidationOnlyResponse(failures);
                return;
            }
            if (isUpdate) {
                applyRecordIdFromUrl(pfrs);
            }
            failures.addAll(Core_MDF_PFR_RestAPI_Utility.normalizeAndValidateApiOnly(pfrs, isUpdate));
            failures.addAll(Core_MDF_PFR_RestAPI_Utility.validateFileUploadRequirement(pfrs, wrapper.getFileUploads()));
            if (!validateCampaignAccess(pfrs, failures)) {
                prepareCampaignAccessDeniedResponse();
                return;
            }
            validateSegmentPayload(pfrs, failures, wrapper.getSegmentMaps());

            Map<String, Decimal> ecosystemPartnerAllocations = wrapper.getEcosystemPartnerAllocations();
            if (!ecosystemPartnerAllocations.isEmpty()) {
                String allocationValidationError = validateEcosystemPartnerPercentages(ecosystemPartnerAllocations);
                if (String.isNotBlank(allocationValidationError)) {
                    for (Integer index = pfrs.size() - 1; index >= 0; index--) {
                        failures.add(Core_MDF_PFR_RestAPI_Utility.buildValidationFailure(pfrs[index], new List<String>{ allocationValidationError }));
                        pfrs.remove(index);
                    }
                }
            }
            
            if (isUpdate) {
                failures.addAll(removeInvalidUpdateRecords(pfrs));
            }
            if (pfrs.isEmpty() || !failures.isEmpty()) {
                prepareValidationOnlyResponse(failures);
            } else {
                processDmlResults(pfrs, isUpdate ? Database.update(pfrs, false) : Database.insert(pfrs, false), failures);
                
             
            if (!ecosystemPartnerAllocations.isEmpty()) {
                    processEcosystemPartnerAllocations(pfrs, failures, ecosystemPartnerAllocations);
                }
                attachInlineFiles(pfrs, wrapper.getFileUploads());
                processActivitySegments(pfrs, wrapper.getSegmentProductString());
            }

        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            handleException(e, '500');
        } finally {
            if (String.isBlank(response.code)) {
                response.code = '200';
            }
        }
    }

    private static void validateSegmentPayload(List<PartnerFundRequest> pfrs, List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures, List<Map<String, Object>> segmentMaps) {
        if (segmentMaps == null || segmentMaps.isEmpty() || pfrs == null || pfrs.isEmpty()) {
            return;
        }

        PartnerFundRequest pfr = pfrs[0];
        Map<String, Object> validationResult = Core_MDF_PFR_RestAPI_Utility.validateSPIFSegments(
            segmentMaps,
            String.valueOf(pfr.ChannelPartnerId),
            pfr.Core_MDF_Program__c,
            String.valueOf(pfr.CampaignId),
            String.valueOf(pfr.BudgetId),
            String.valueOf(pfr.ChannelPartnerId)
        );

        List<String> errors = new List<String>();
        if (Boolean.valueOf(validationResult.get('isSuccess')) != true && validationResult.containsKey('message')) {
            errors.add(String.valueOf(validationResult.get('message')));
        }
        Object invalidSegmentsObj = validationResult.get('invalidSegments');
        if (invalidSegmentsObj instanceof List<Object>) {
            for (Object invalidSegmentObj : (List<Object>) invalidSegmentsObj) {
                if (!(invalidSegmentObj instanceof Map<String, Object>)) {
                    continue;
                }
                Map<String, Object> invalidSegment = (Map<String, Object>) invalidSegmentObj;
                String segmentName = invalidSegment.containsKey('segmentName') ? String.valueOf(invalidSegment.get('segmentName')) : 'Segment';
                Object segmentErrorsObj = invalidSegment.get('errors');
                if (segmentErrorsObj instanceof List<Object>) {
                    for (Object segmentError : (List<Object>) segmentErrorsObj) {
                        errors.add(segmentName + ': ' + String.valueOf(segmentError));
                    }
                }
            }
        }

        errors.addAll(validateSegmentPayoutAgainstIntelContribution(pfr, segmentMaps));

        if (errors.isEmpty()) {
            return;
        }

        failures.add(Core_MDF_PFR_RestAPI_Utility.buildValidationFailure(pfr, errors));
        pfrs.clear();
    }

    private static Boolean validateCampaignAccess(List<PartnerFundRequest> pfrs, List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures) {
        if (pfrs == null || pfrs.isEmpty()) {
            return true;
        }

        Set<Id> campaignIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrs) {
            if (pfr != null && pfr.CampaignId != null) {
                campaignIds.add(pfr.CampaignId);
            }
        }
        if (campaignIds.isEmpty()) {
            return true;
        }

        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([
            SELECT Id, Core_MDF_Account__c
            FROM Campaign
            WHERE Id IN :campaignIds
        ]);

        for (PartnerFundRequest pfr : pfrs) {
            if (pfr == null || pfr.CampaignId == null) {
                continue;
            }
            Campaign campaignRecord = campaignMap.get(pfr.CampaignId);
            if (campaignRecord == null || !Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(campaignRecord)) {
                failures.add(Core_MDF_PFR_RestAPI_Utility.buildValidationFailure(pfr, new List<String>{ ERR_CAMPAIGN_ACCESS_DENIED + ': ' + CAMPAIGN_ACCESS_DENIED_MESSAGE }));
                return false;
            }
        }

        return true;
    }

    private static void prepareCampaignAccessDeniedResponse() {
        response.isSuccess = false;
        response.code = '403';
        response.errorcode = ERR_CAMPAIGN_ACCESS_DENIED;
        response.message = CAMPAIGN_ACCESS_DENIED_MESSAGE;
        response.successContent = null;
        response.totalRecords = 0;
    }

    @TestVisible
    private static List<String> validateSegmentPayoutAgainstIntelContribution(PartnerFundRequest pfr, List<Map<String, Object>> segmentMaps) {
        List<String> errors = new List<String>();
        Decimal intelContribution = calculateIntelContributionAmount(pfr);
        if (intelContribution == null || segmentMaps == null || segmentMaps.isEmpty()) {
            return errors;
        }

        for (Map<String, Object> segmentMap : segmentMaps) {
            if (segmentMap == null) {
                continue;
            }
            Decimal minimumForecastVolume = decimalFromObject(segmentMap.get('MinimumForecastVolume'));
            Decimal incentiveAmountPerUnit = decimalFromObject(segmentMap.get('IncentiveAmountPerUnit'));
            if (minimumForecastVolume == null || incentiveAmountPerUnit == null) {
                continue;
            }

            Decimal segmentPayout = (minimumForecastVolume * incentiveAmountPerUnit).setScale(2, System.RoundingMode.HALF_UP);
            if (segmentPayout > intelContribution) {
                String segmentName = segmentMap.containsKey('SegmentName') ? String.valueOf(segmentMap.get('SegmentName')) : 'Segment';
                errors.add(segmentName + ': Minimum Forecast Volume * Incentive Amount $/U should less than intel contribution.');
            }
        }
        return errors;
    }

    private static Decimal calculateIntelContributionAmount(PartnerFundRequest pfr) {
        if (pfr == null) {
            return null;
        }
        Decimal requestedAmount = pfr.RequestedAmount != null
            ? pfr.RequestedAmount
            : pfr.Core_MDF_Budget_Amount_Local_amt__c;
        Decimal reimbursementRate = parseReimbursementRate(pfr.Core_MDF_Reimbursement_Rate_txt__c);
        if (requestedAmount == null || requestedAmount <= 0 || reimbursementRate == null) {
            return null;
        }
        return ((requestedAmount * reimbursementRate) / 100).setScale(2, System.RoundingMode.HALF_UP);
    }

    private static Decimal parseReimbursementRate(String reimbursementRate) {
        if (String.isBlank(reimbursementRate)) {
            return null;
        }
        String normalizedRate = reimbursementRate.trim();
        normalizedRate = normalizedRate.endsWith('%')
            ? normalizedRate.substring(0, normalizedRate.length() - 1).trim()
            : normalizedRate;
        return decimalFromObject(normalizedRate);
    }

    private static Decimal decimalFromObject(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return Decimal.valueOf(String.valueOf(value).trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static void processActivitySegments(List<PartnerFundRequest> pfrs, String segmentProductString) {
        if (String.isBlank(segmentProductString) || pfrs == null || pfrs.isEmpty()) {
            return;
        }

        for (PartnerFundRequest pfr : pfrs) {
            if (pfr.Id != null) {
                Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id, segmentProductString);
            }
        }
    }

    private static void processDmlResults(List<PartnerFundRequest> pfrs, Database.SaveResult[] results, List<Core_MDF_PFR_RestAPI_Response.ErrorContent> preDmlFailures) {
        List<PartnerFundRequest> successList = new List<PartnerFundRequest>();
        response.failureContent = preDmlFailures != null ? preDmlFailures : new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                if (String.isNotBlank(results[i].getId())) {
                    pfrs[i].Id = results[i].getId();
                }
                successList.add(pfrs[i]);
            } else {
                Core_MDF_PFR_RestAPI_Response.ErrorContent failure = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
                failure.pfrId = pfrs[i].Id;
                failure.pfrName = pfrs[i].Title;
                for (Database.Error err : results[i].getErrors()) {
                    failure.errors.add(formatDmlError(err));
                }
                response.failureContent.add(failure);
            }
        }

        // The endpoint processes a single activity record, so partial success cannot occur: the request
        // either fully succeeds or fully fails.
        if (successList.isEmpty()) {
            prepareValidationOnlyResponse(response.failureContent);
        } else {
            prepareSuccessResponse(successList);
            response.failureContent = null;
        }
    }

    /**
     * Processes Ecosystem Partner allocations for successfully saved records.
     * Reuses Core_MDF_Ecosystem_Partner_Handler.saveEcosystemPartnerAllocations() which handles
     * all DML, error handling, and allocation creation internally.
     * Validates that percentage allocations sum to 100 when provided (allows blank).
     * @param pfrs List of PartnerFundRequest records with Ids
     * @param failures List to accumulate any allocation processing errors (best-effort)
     * @param allocationPercentages Map of partner name to percentage allocation from payload
     */
    private static void processEcosystemPartnerAllocations(List<PartnerFundRequest> pfrs, List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures, Map<String, Decimal> allocationPercentages) {
        if (pfrs == null || pfrs.isEmpty() || allocationPercentages == null || allocationPercentages.isEmpty()) {
            return;
        }

        String validationError = validateEcosystemPartnerPercentages(allocationPercentages);
        if (String.isNotBlank(validationError)) {
            Core_MDF_PFR_RestAPI_Response.ErrorContent validationFailure = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
            validationFailure.pfrName = 'Ecosystem Partner Allocation Validation';
            validationFailure.errors.add(validationError);
            failures.add(validationFailure);
            return; // Stop processing if allocation percentages are invalid
        }

        // Collect all record Ids for querying ecosystem partner data
        Set<Id> pfrIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrs) {
            if (pfr.Id != null) {
                pfrIds.add(pfr.Id);
            }
        }

        if (pfrIds.isEmpty()) {
            return;
        }

        try {
            // Query the saved records to get ecosystem partner values
            List<PartnerFundRequest> savedPfrs = [
                SELECT Id, Core_MDF_Channel_Partner__c 
                FROM PartnerFundRequest 
                WHERE Id IN :pfrIds
            ];

            // Process each record and reuse the handler
            for (PartnerFundRequest savedPfr : savedPfrs) {
                // Skip if no ecosystem partner data
                if (String.isBlank(savedPfr.Core_MDF_Channel_Partner__c)) {
                    continue;
                }

                try {
                    List<Core_MDF_Ecosystem_Partner_Handler.EcosystemPartnerAllocationWrapper> wrappers = 
                        new List<Core_MDF_Ecosystem_Partner_Handler.EcosystemPartnerAllocationWrapper>();
                    
                    for (String partner : savedPfr.Core_MDF_Channel_Partner__c.split(';')) {
                        if (String.isNotBlank(partner)) {
                            Core_MDF_Ecosystem_Partner_Handler.EcosystemPartnerAllocationWrapper wrapper = 
                                new Core_MDF_Ecosystem_Partner_Handler.EcosystemPartnerAllocationWrapper();
                            wrapper.ecosystemPartner = partner.trim();
                            // Use percentage from payload if provided, otherwise default to 0
                            wrapper.percent = getAllocationPercentage(allocationPercentages, wrapper.ecosystemPartner);
                            wrappers.add(wrapper);
                        }
                    }
                    if (!wrappers.isEmpty()) {
                        Core_MDF_Ecosystem_Partner_Handler.saveEcosystemPartnerAllocations(savedPfr.Id, wrappers);
                    }

                } catch (Exception e) {
                    Core_MDF_CCP_UtilityClass.logError(e);
                    // Handler errors are logged by the handler itself; just log to raw logs for audit trail
                    rawErrorLogs.add('Ecosystem Partner Allocation Error for Activity ' + savedPfr.Id + ': ' + e.getMessage());
                    Core_MDF_PFR_RestAPI_Response.ErrorContent warning = new Core_MDF_PFR_RestAPI_Response.ErrorContent();
                    warning.pfrId = savedPfr.Id;
                    warning.pfrName = 'Allocation Warning';
                    warning.errors.add('Warning: Ecosystem Partner allocation processing failed.');
                    failures.add(warning);
                }
            }

        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            // Log general query/processing error
            rawErrorLogs.add('Error querying PartnerFundRequest records for ecosystem partner allocation: ' + e.getMessage());
        }
    }

    private static Decimal getAllocationPercentage(Map<String, Decimal> allocationPercentages, String ecosystemPartner) {
        if (allocationPercentages == null || allocationPercentages.isEmpty() || String.isBlank(ecosystemPartner)) {
            return 0;
        }
        if (allocationPercentages.containsKey(ecosystemPartner)) {
            return allocationPercentages.get(ecosystemPartner);
        }

        String normalizedPartner = normalizeAllocationKey(ecosystemPartner);
        for (String partnerKey : allocationPercentages.keySet()) {
            if (normalizeAllocationKey(partnerKey) == normalizedPartner) {
                return allocationPercentages.get(partnerKey);
            }
        }
        return 0;
    }

    private static String normalizeAllocationKey(String value) {
        return String.isBlank(value) ? '' : value.replaceAll('\\s+', '').toLowerCase();
    }

    /**
     * Validates ecosystem partner percentage allocations.
     * Ensures that all provided percentages sum to 100. Allows blank/null (skips validation).
     * @param allocationPercentages Map of partner name to percentage
     * @return Error message if validation fails, empty string if valid
     */
    private static String validateEcosystemPartnerPercentages(Map<String, Decimal> allocationPercentages) {
        if (allocationPercentages == null || allocationPercentages.isEmpty()) {
            return ''; // Allow blank allocations
        }

        Decimal totalPercent = 0;
        Boolean hasNonZeroPercent = false;
        for (Decimal percent : allocationPercentages.values()) {
            if (percent != null) {
                totalPercent += percent;
                if (percent != 0) {
                    hasNonZeroPercent = true;
                }
            }
        }

        // Explicit zero allocations are valid (e.g. "0" for one partner, or "0;0" for multiple).
        if (!hasNonZeroPercent) {
            return '';
        }

        if (totalPercent != 100) {
            return Core_MDF_PFR_RestAPI_Constants.Required_Ecosystem_Partner_PercentageAllocation;
        }

        return ''; // Valid
    }

    private static List<Core_MDF_PFR_RestAPI_Response.ErrorContent> removeInvalidUpdateRecords(List<PartnerFundRequest> pfrs) {
        List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures = new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
        for (Integer i = pfrs.size() - 1; i >= 0; i--) {
            if (String.isBlank(pfrs[i].Id)) {
                failures.add(Core_MDF_PFR_RestAPI_Utility.buildValidationFailure(pfrs[i], new List<String>{ Core_MDF_PFR_RestAPI_Constants.ERR_9002_UPDATE_NEEDS_ID }));
                pfrs.remove(i);
            }
        }
        return failures;
    }

    /**
     * For update requests, assigns the PartnerFundRequest Id supplied via the URL onto the parsed
     * record(s) so the existing record is updated. An invalid Id is left unset so the standard
     * "update requires a valid Id" validation (ERR-9002) reports it.
     */
    private static void applyRecordIdFromUrl(List<PartnerFundRequest> pfrs) {
        String urlId = getRecordIdFromUrl();
        if (String.isBlank(urlId)) {
            return;
        }
        try {
            Id parsedId = Id.valueOf(urlId);
            if (parsedId.getSObjectType() == PartnerFundRequest.SObjectType) {
                for (PartnerFundRequest pfr : pfrs) {
                    if (pfr.Id == null) {
                        pfr.Id = parsedId;
                    }
                }
            }
        } catch (Exception e) {
            
        }
    }

    /**
     * Reads the record Id from the request URL. Only the "id" query parameter is accepted
     * (e.g. /v1.0/activity/?action=update&id=a0X...). A path-style Id such as
     * /v1.0/activity/a0X... is intentionally NOT accepted, so it falls through to the
     * standard "update requires a valid Id" validation (ERR-9002).
     */
    private static String getRecordIdFromUrl() {
        String idParam = Core_MDF_PFR_RestAPI_Utility.getRequestParam('id');
        return String.isNotBlank(idParam) ? idParam.trim() : null;
    }

    /**
     * Returns true when the request URL targets the file-upload action (path ends with "/uploadfile",
     * e.g. /services/apexrest/v1.0/activity/uploadfile). Query parameters are ignored.
     */
    private static Boolean isFileUploadRequest() {
        RestRequest req = RestContext.request;
        if (req == null || String.isBlank(req.requestURI)) {
            return false;
        }
        String path = req.requestURI;
        Integer queryIndex = path.indexOf('?');
        if (queryIndex >= 0) {
            path = path.substring(0, queryIndex);
        }
        return path.toLowerCase().endsWith('/partnercenter/activity/uploadfile');
    }

    /**
     * Handles a file-upload request: validates the payload, decodes the base64 file content and
     * attaches it to the supplied activity (PartnerFundRequest) record. Reuses the standard response
     * object so the output structure stays consistent with the create/update endpoint.
     *
     * Expected body: { "activity": "<recordId>", "fileName": "<name.ext>", "file": "<base64>", "comment": "" }
     */
    private static void processFileUpload(String reqBody) {
        FileUploadRequest uploadReq;
        try {
            uploadReq = (FileUploadRequest) JSON.deserialize(reqBody, FileUploadRequest.class);
        } catch (Exception e) {
            setFileUploadFailure('400', 'Request body must be a valid JSON object.');
            return;
        }

        if (uploadReq == null || String.isBlank(uploadReq.activity)) {
            setFileUploadFailure('400', 'activity (record Id or activity number) is required.');
            return;
        }
        if (String.isBlank(uploadReq.fileName)) {
            setFileUploadFailure('400', 'fileName is required.');
            return;
        }
        if (String.isBlank(uploadReq.file)) {
            setFileUploadFailure('400', 'file (base64 content) is required.');
            return;
        }

        // Validate file extension
        String fileExtensionValidationError = validateFileExtension(uploadReq.fileName);
        if (String.isNotBlank(fileExtensionValidationError)) {
            setFileUploadFailure('400', fileExtensionValidationError);
            return;
        }

        Id activityId = resolveActivityId(uploadReq.activity.trim());
        if (activityId == null) {
            setFileUploadFailure('400', 'activity "' + uploadReq.activity + '" is not a valid record Id or activity number.');
            return;
        }

        Blob fileBody;
        try {
            fileBody = EncodingUtil.base64Decode(uploadReq.file);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            setFileUploadFailure('400', 'file content is not valid base64.');
            return;
        }

        try {
            attachFileToActivity(activityId, uploadReq.fileName.trim(), fileBody);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            setFileUploadFailure('500', getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR, '500', null));
            return;
        }

        fileUploadResponse = new FileUploadResponse();
        fileUploadResponse.totalRecords = 1;
        fileUploadResponse.successContent = new List<FileUploadSuccess>{
            new FileUploadSuccess('File Uploaded successfully for Activity: ' + activityId)
        };
        fileUploadResponse.isSuccess = true;
        fileUploadResponse.errorContent = null;
        fileUploadResponse.code = '200';
    }

    /**
     * Builds the failure-shaped file-upload response (no success content, message in errorContent).
     */
    private static void setFileUploadFailure(String code, String message) {
        fileUploadResponse = new FileUploadResponse();
        fileUploadResponse.totalRecords = 0;
        fileUploadResponse.successContent = null;
        fileUploadResponse.isSuccess = false;
        fileUploadResponse.errorContent = message;
        fileUploadResponse.code = code;
        if (RestContext.response != null) {
            RestContext.response.statusCode = Integer.valueOf(code);
        }
    }

    /**
     * Attaches inline files (from the payload "Files" node) to a successfully-saved activity. Runs
     * best-effort: any file that is incomplete or fails to attach is skipped/logged and never affects
     * the activity create/update outcome. Results are added to the response.
     */
    private static void attachInlineFiles(List<PartnerFundRequest> pfrs, List<Core_MDF_PFR_RestAPI_InputWrapper.FileUpload> files) {
        if (files == null || files.isEmpty() || pfrs == null || pfrs.isEmpty()) {
            return;
        }
        Id activityId = pfrs[0].Id;
        if (activityId == null) {
            return;
        }
        List<Core_MDF_PFR_RestAPI_Response.FileUploadResult> results = new List<Core_MDF_PFR_RestAPI_Response.FileUploadResult>();
        for (Core_MDF_PFR_RestAPI_InputWrapper.FileUpload upload : files) {
            if (upload == null || String.isBlank(upload.FileName) || String.isBlank(upload.file)) {
                continue;
            }
            
            // Validate file extension before attempting attachment
            String fileExtensionValidationError = validateFileExtension(upload.FileName);
            if (String.isNotBlank(fileExtensionValidationError)) {
                results.add(new Core_MDF_PFR_RestAPI_Response.FileUploadResult(upload.FileName.trim(), 'Failed: ' + fileExtensionValidationError));
                continue; // Skip this file if validation fails
            }
            
            try {
                attachFileToActivity(activityId, upload.FileName.trim(), EncodingUtil.base64Decode(upload.file));
                results.add(new Core_MDF_PFR_RestAPI_Response.FileUploadResult(upload.FileName.trim(), 'File Uploaded successfully'));
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
                results.add(new Core_MDF_PFR_RestAPI_Response.FileUploadResult(upload.FileName.trim(), 'Failed: ' + getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR, '500', null)));
            }
        }
        if (!results.isEmpty()) {
            response.fileUploadContent = results;
        }
    }

    /*
     * Inserts a ContentVersion for the supplied file (any extension) and links the resulting
     * ContentDocument to the activity record. The file type is derived from the fileName extension.
     */
    private static void attachFileToActivity(Id activityId, String fileName, Blob fileBody) {
        String safeFileName = String.isNotBlank(fileName) ? fileName.trim() : 'file';
        String titleOnly = safeFileName;
    
        Integer lastDotIndex = safeFileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            titleOnly = safeFileName.substring(0, lastDotIndex);
        }
    
        Network n = [
            SELECT Id
            FROM Network
            WHERE Name = 'Partnercenter Unified Community'
            LIMIT 1
        ];
    
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = titleOnly;
        cv.PathOnClient = safeFileName;
        cv.VersionData = fileBody;
        cv.NetworkId=n.Id;
        insert cv;
    
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    
        insert new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = activityId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }

    private static void prepareValidationOnlyResponse(List<Core_MDF_PFR_RestAPI_Response.ErrorContent> validationFailures) {
        response.isSuccess = false; response.code = '400'; response.totalRecords = 0;
            response.errorcode = Core_MDF_PFR_RestAPI_Constants.ERR_9003_ALL_FAILED;
        response.message = getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9003_ALL_FAILED, '400', 'ALL_FAILED');
        response.successContent = null;
        response.failureContent = validationFailures;
        
    }

    private static void prepareSuccessResponse(List<PartnerFundRequest> pfrs) {
        Map<Id, PartnerFundRequest> pfrMap = new Map<Id, PartnerFundRequest>(pfrs);
        for (PartnerFundRequest res : [SELECT Id, Title, Status, Core_MDF_Fund_Request_Status__c, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Id IN :pfrMap.keySet()]) {
            PFRSuccess success = new PFRSuccess(
                res.Core_MDF_Activity_Number__c,
                res.Title,
                String.isNotBlank(res.Core_MDF_Fund_Request_Status__c) ? res.Core_MDF_Fund_Request_Status__c : res.Status
            );
            response.successContent.add(success);
        }
        response.code = '201'; response.message = 'Success'; response.totalRecords = response.successContent.size();
    }
    
    private static void handleException(Exception e, String code) {
        response.isSuccess = false; response.code = code; response.successContent = null;
        if (e != null) {
            response.errorcode = Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR;
            response.message = getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR, code, null) + (INCLUDE_ORIGINAL_ERROR_FOR_TESTING ? ' | Original Error: ' + e.getMessage() : '');
            rawErrorLogs.add('Technical Exception: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
        } else {
            response.errorcode = Core_MDF_PFR_RestAPI_Constants.ERR_9005_INVALID_ACTION;
            response.message = getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9005_INVALID_ACTION, '400', 'INVALID_ACTION');
        }
    }

    private static String formatDmlError(Database.Error err) {
        if (String.valueOf(err.getStatusCode()) == BUSINESS_VALIDATION_STATUS) return getBusinessValidationMessage(err.getMessage());
        
        String originalErr = err.getStatusCode() + ': ' + err.getMessage() + (err.getFields().isEmpty() ? '' : ' [' + String.join(err.getFields(), ',') + ']');
        rawErrorLogs.add('DML Technical Error: ' + originalErr);
        
        return getErrorMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9000_GENERIC_TECH_ERROR, '500', null) + (INCLUDE_ORIGINAL_ERROR_FOR_TESTING ? ' | Original Error: ' + originalErr : '');
    }

    @TestVisible
    private static String getBusinessValidationMessage(String errorMessage) {
        if (String.isBlank(errorMessage)) {
            return toConfiguredBusinessValidationError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9006_BUSINESS_VALIDATION_CODE,
                Core_MDF_PFR_RestAPI_Constants.ERR_9006_BUSINESS_VALIDATION
            );
        }
        // Strip the Salesforce wrapper so only the admin-authored, user-facing message remains.
        String cleanedMsg = errorMessage.removeStart(BUSINESS_VALIDATION_STATUS + ', ').removeEnd(': []').trim();

        // Business validation uses the configured generic code and preserves the exact rule message.
        return toConfiguredBusinessValidationError(
            Core_MDF_PFR_RestAPI_Constants.ERR_9006_BUSINESS_VALIDATION_CODE,
            cleanedMsg
        );
    }

    @TestVisible
    private static String toConfiguredBusinessValidationError(String codeValue, String fallbackMessage) {
        String resolvedCode = normalizeErrorCode(codeValue);
        String resolvedMessage = fallbackMessage;
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting =
            Core_MDF_PFR_RestAPI_Utility.getResponseCodeSetting(resolvedCode, '400', 'BUSINESS_VALIDATION');
        if (setting != null) {
            if (String.isNotBlank(setting.code)) {
                resolvedCode = normalizeErrorCode(setting.code);
            }
            if (String.isNotBlank(setting.message)) {
                resolvedMessage = setting.message;
            }
        }
        return resolvedCode + ': ' + resolvedMessage;
    }

    private static String normalizeErrorCode(String codeValue) {
        if (String.isBlank(codeValue)) {
            return codeValue;
        }
        String normalized = codeValue.trim();
        if (normalized.toUpperCase().startsWith('ERR-') && normalized.length() > 4) {
            return normalized.substring(4).trim();
        }
        return normalized;
    }
    
    

    private static void logToCoreLogEntry(String contextMsg) {
        try {
            // Only log when there are raw internal errors or unhandled exceptions — skip success/info logs.
            if (rawErrorLogs.isEmpty()) {
                return;
            }

            RestRequest req = RestContext.request;
            String uri = (req != null) ? String.ValueOf(req.requestURI).abbreviate(255) : RESTAPI_NAME;
            
            Core_Log_Entry__c log = new Core_Log_Entry__c();
            log.Core_Message__c = uri;
            log.Core_Origin__c = 'PartnerFundRequest RestAPI';
            log.Core_Project__c = 'PartnerFundRequest RestAPI';
            log.Core_When__c = ENTRY_TIME;
            log.Core_Severity__c = 'Error';
            log.Core_Tags__c = response.code;
            log.Core_Details__c = String.join(rawErrorLogs, '\n\n').abbreviate(32768);
            
            insert log;
        } catch (Exception e) {
           
        }
    }

    /**
     * Resolves activity identifier to a PartnerFundRequest record Id.
     * Tries to parse as a Salesforce record ID first; if that fails, queries by activity number.
     * @param activityIdentifier Either a Salesforce record ID or activity number
     * @return PartnerFundRequest record Id if found, null otherwise
     */
    private static Id resolveActivityId(String activityIdentifier) {
        if (String.isBlank(activityIdentifier)) {
            return null;
        }

        // First, try to parse as a Salesforce record ID
        try {
            Id parsedId = Id.valueOf(activityIdentifier);
            if (parsedId.getSObjectType() == PartnerFundRequest.SObjectType) {
                // Verify the record exists
                if ([SELECT COUNT() FROM PartnerFundRequest WHERE Id = :parsedId] > 0) {
                    return parsedId;
                }
            }
        } catch (Exception e) {
            // Not a valid ID; continue to activity number lookup
        }

        // Second, try to query by activity number
        try {
            List<PartnerFundRequest> results = [
                SELECT Id 
                FROM PartnerFundRequest 
                WHERE Core_MDF_Activity_Number__c = :activityIdentifier 
                LIMIT 1
            ];
            if (!results.isEmpty()) {
                return results[0].Id;
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }

        return null;
    }

    /**
     * Validates file extension against allowed formats.
     * @param fileName The name of the file including extension (e.g. "document.pdf")
     * @return Error message if extension is not allowed or missing, empty string if valid
     */
    private static String validateFileExtension(String fileName) {
        if (String.isBlank(fileName)) {
            return 'fileName is required.';
        }

        // Define allowed file extensions
        Set<String> allowedExtensions = new Set<String>{
            'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf', 'csv'
        };

        // Extract file extension
        Integer lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex == -1 || lastDotIndex == fileName.length() - 1) {
            return 'File extension is mandatory. Supported formats: .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .csv';
        }

        String fileExtension = fileName.substring(lastDotIndex + 1).toLowerCase().trim();
        if (!allowedExtensions.contains(fileExtension)) {
            return 'File extension ".' + fileExtension + '" is not supported. Supported formats: .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .csv';
        }

        return ''; // Valid
    }


    
    
    public class PFRSuccess {
        public String activityNumber { get; set; }
        public String pfrName { get; set; }
        public String status { get; set; }
        public Datetime createdDate { get; set; }
        
        public PFRSuccess(String activityNumber, String name, String status) {
            this.activityNumber = activityNumber; this.pfrName = name; this.status = status;
            this.createdDate = System.now();
        }
    }

    /**
     * Inbound payload for the "/uploadfile" route. "activity" can be either a Salesforce record ID
     * or an activity number (e.g., "00322964"). "file" is the base64-encoded file body and
     * "comment" is optional/unused (accepted for request compatibility).
     */
    public class FileUploadRequest {
        public String activity;
        public String fileName;
        public String file;
        public String comment;
    }

    /**
     * Response shape for the "/uploadfile" route. Field declaration order controls the JSON key order:
     * totalRecords, successContent, isSuccess, errorContent, code.
     */
    public class FileUploadResponse {
        public Integer totalRecords;
        public List<FileUploadSuccess> successContent;
        public Boolean isSuccess;
        public String errorContent;
        public String code;
    }

    /**
     * Single success entry for the file-upload response (e.g. { "activity": "File Uploaded ..." }).
     */
    public class FileUploadSuccess {
        public String activity;

        public FileUploadSuccess(String activity) {
            this.activity = activity;
        }
    }

}