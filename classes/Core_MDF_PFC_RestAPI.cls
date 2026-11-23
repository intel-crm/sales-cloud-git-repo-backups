/**
 * Class Name      : Core_MDF_PFC_RestAPI
 * Author          : 
 * Created Date    : 
 * Description     : Validates Partner Fund Claims and prepares batch records.
 */

@RestResource(urlMapping='/v1.0/partnercenter/claims/create/*')
global without sharing class Core_MDF_PFC_RestAPI {
    private static final Integer MAX_CLAIMS_PER_REQUEST = Core_MDF_PFC_APIUtil.MAX_CLAIMS_PER_REQUEST;
    private static final Map<String, Schema.SObjectField> STAGE_FIELDS = Core_MDF_Claim_Batch_Stage__c.SObjectType.getDescribe().fields.getMap();
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
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8001_REQUEST_BODY_REQUIRED));
                return;
            }

            // Validate payload structure and parse into the typed input wrapper.
            List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claimsPayload;
            try {
                Core_MDF_PFC_RestAPI_InputWrapper inputWrapper = Core_MDF_PFC_RestAPI_InputWrapper.parse(requestBody);
                claimsPayload = inputWrapper.getClaimDetails();
            } catch (Exception ex) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE));
                return;
            }
            if (claimsPayload == null || claimsPayload.isEmpty()) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE));
                return;
            }
            if (claimsPayload.size() > MAX_CLAIMS_PER_REQUEST) {
                Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8031_MAX_CLAIMS_EXCEEDED
                );
                String configuredMessage = response != null && response.error != null
                    ? response.error.message
                    : null;
                if (String.isNotBlank(configuredMessage) && configuredMessage.contains('{value}')) {
                    response.setErrorInfo(
                        configuredMessage.replace('{value}', String.valueOf(MAX_CLAIMS_PER_REQUEST)),
                        Core_MDF_PFC_APIUtil.CODE_8031_MAX_CLAIMS_EXCEEDED
                    );
                }
                sendResponse(response);
                return;
            }

            // Validate Claims
            Core_MDF_PFC_APIUtil.ValidationResult validationResult = Core_MDF_PFC_APIUtil.validateClaims(claimsPayload, false);
            if (validationResult == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR));
                return;
            }
            if (!validationResult.isSuccess) {
                sendResponse(validationResult.response);
                return;
            }  

            Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidationResult = Core_MDF_PFC_APIUtil.validateActivityAndCountry(validationResult.validWrappers);
            if (businessValidationResult == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR));
                return;
            }

            Core_MDF_APIResponse businessError = getBusinessValidationErrorResponse(businessValidationResult.results);
            if (businessError != null) {
                sendResponse(businessError);
                return;
            }

            Core_MDF_PFC_APIUtil.validateDuplicateClaims(validationResult.validWrappers, businessValidationResult);
            businessError = getBusinessValidationErrorResponse(businessValidationResult.results);
            if (businessError != null) {
                sendResponse(businessError);
                return;
            }

            sendResponse(prepareClaimBatch(
                requestBody,
                validationResult.validWrappers,
                businessValidationResult
            ));
            return;

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR);
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

    private static void sendResponse(Core_MDF_APIResponse response) {
        try {
            if (RestContext.response == null) {
                RestContext.response = new RestResponse();
            }
            RestContext.response.statusCode = resolveHttpStatusCode(response);
            RestContext.response.addHeader(
                Core_MDF_PFC_APIUtil.CONTENT_TYPE_HEADER,
                Core_MDF_PFC_APIUtil.CONTENT_TYPE_JSON
            );
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response.getSerializedResponse()));
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    @TestVisible
    private static Core_MDF_APIResponse getBusinessValidationErrorResponse(
        List<Core_MDF_PFC_APIUtil.ClaimProcessingResult> results
    ) {
        for (Core_MDF_PFC_APIUtil.ClaimProcessingResult result : results) {
            if (result.success == false) {
                Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildProcessingResponse(results);
                if (response.httpStatusCode == 207) {
                    response.setErrorInfo(response.getMessage(), Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED);
                    response.httpStatusCode = 400;
                }
                return response;
            }
        }
        return null;
    }

    private static String getRequestBody() {
        try {
            RestRequest request = RestContext.request;
            return request?.requestBody?.toString();
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return Core_MDF_PFC_APIUtil.EMPTY_STRING; }
    }

    private static Core_MDF_APIResponse prepareClaimBatch(
        String requestBody,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers,
        Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidationResult
    ) {
        PartnerFundRequest batchContext;
        for (Integer index = 0; index < wrappers.size(); index++) {
            if (businessValidationResult.requestByIndex.containsKey(index)) {
                batchContext = businessValidationResult.requestByIndex.get(index);
                break;
            }
        }

        // Requests with no processable claims return their validation errors immediately and do not create empty batches.
        if (batchContext == null) {
            return Core_MDF_PFC_APIUtil.buildProcessingResponse(businessValidationResult.results);
        }

        Savepoint savepoint = Database.setSavepoint();
        try {
            Core_MDF_Claim_Batch__c batch = createClaimBatch(batchContext);
            List<Core_MDF_Claim_Batch_Stage__c> stages = insertClaimBatchStages(batch.Id, requestBody, wrappers, businessValidationResult);

            Core_MDF_APIResponse response = new Core_MDF_APIResponse();
            response.setSuccessInfo(
                'Claim batch prepared successfully.',
                '200'
            );
            response.httpStatusCode = 200;
            response.details = new Map<String, Object>{
                'batchId' => batch.Id,
                'temporaryClaimIds' => buildTemporaryClaimIds(stages, wrappers),
                'status' => 'Submitted'
            };
            return response;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            throw ex;
        }
    }

    @TestVisible
    private static List<Map<String, Object>> buildTemporaryClaimIds(
        List<Core_MDF_Claim_Batch_Stage__c> stages,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers
    ) {
        List<Map<String, Object>> temporaryClaimIds = new List<Map<String, Object>>();
        for (Integer index = 0; index < wrappers.size(); index++) {
            temporaryClaimIds.add(new Map<String, Object>{
                wrappers[index].getText('claimTitle') => new Map<String, String>{
                    'stageRecordId' => String.valueOf(stages[index].Id),
                    'stageRecordName' => stages[index].Name
                }
            });
        }
        return temporaryClaimIds;
    }

    private static Core_MDF_Claim_Batch__c createClaimBatch(PartnerFundRequest batchContext) {
        Id batchAccountId = null;
        Id channelProgramId = null;

        if (batchContext != null) {
            batchAccountId = batchContext.ChannelPartnerId;
            if (batchAccountId != null) {
                Account partnerAccount = [
                    SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c
                    FROM Account
                    WHERE Id = :batchAccountId
                    LIMIT 1
                ];
                if (partnerAccount.Core_MDF_CoMarketing_Ultimate_Account__c != null) {
                    batchAccountId = partnerAccount.Core_MDF_CoMarketing_Ultimate_Account__c;
                }
            }

            if (String.isNotBlank(batchContext.Core_MDF_Program__c)) {
                List<ChannelProgram> programs = [
                    SELECT Id
                    FROM ChannelProgram
                    WHERE Core_MDF_Technical_Program_Name__c = :batchContext.Core_MDF_Program__c
                        OR Name = :batchContext.Core_MDF_Program__c
                    LIMIT 1
                ];
                if (!programs.isEmpty()) {
                    channelProgramId = programs[0].Id;
                }
            }
        }

        Core_MDF_Claim_Batch__c batch = new Core_MDF_Claim_Batch__c(
            Core_MDF_Account__c = batchAccountId,
            Core_MDF_Program_Id__c = channelProgramId
        );
        Database.insert(batch, AccessLevel.USER_MODE);
        return batch;
    }

    private static List<Core_MDF_Claim_Batch_Stage__c> insertClaimBatchStages(
        Id batchId,
        String requestBody,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers,
        Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidationResult
    ) {
        Map<Integer, Id> recordTypeByIndex = resolveStageRecordTypes(businessValidationResult);
        List<Core_MDF_Claim_Batch_Stage__c> stages = new List<Core_MDF_Claim_Batch_Stage__c>();
        Set<String> programs = new Set<String>();
        for (PartnerFundRequest activity : businessValidationResult.requestByIndex.values()) {
            programs.add(activity.Core_MDF_Program__c);
        }
        List<Core_MDF_ClaimActAllocRecTypeMapping__mdt> programMappings = [
            SELECT Core_MDF_Channel_Program_txt__c, Core_MDF_Channel_Program_Name_txt__c
            FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
            WHERE Core_MDF_Channel_Program_txt__c IN :programs
        ];
        Map<String, String> templateProgramByActivityProgram = resolveTemplateProgramNames(programs, programMappings);
        Set<String> templatePrograms = new Set<String>(templateProgramByActivityProgram.values());
        Map<String, Map<String, String>> stageFieldsByProgram = new Map<String, Map<String, String>>();
        for (Core_MDF_CCP_Custom_Metadata_Utility__c mapping : [
            SELECT Core_MDF_Program__c, Core_MDF_Name_Criteria__c, Core_MDF_Field_2_txt__c
            FROM Core_MDF_CCP_Custom_Metadata_Utility__c
            WHERE Core_MDF_Program__c IN :templatePrograms
                AND Core_MDF_Category__c = :Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE
                AND Core_MDF_Sub_Category__c = :Label.Core_MDF_PFCText
        ]) {
            if (String.isBlank(mapping.Core_MDF_Name_Criteria__c) || String.isBlank(mapping.Core_MDF_Field_2_txt__c)) {
                continue;
            }
            if (!stageFieldsByProgram.containsKey(mapping.Core_MDF_Program__c)) {
                stageFieldsByProgram.put(mapping.Core_MDF_Program__c, new Map<String, String>());
            }
            stageFieldsByProgram.get(mapping.Core_MDF_Program__c).put(
                mapping.Core_MDF_Name_Criteria__c.trim().toLowerCase(),
                mapping.Core_MDF_Field_2_txt__c.trim()
            );
        }
        Map<String, Object> payloadRoot = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        List<Object> claimRows = (List<Object>) payloadRoot.get(Core_MDF_PFC_RestAPI_InputWrapper.KEY_CLAIM_DETAILS);
        for (Integer index = 0; index < wrappers.size(); index++) {
            Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput wrapper = wrappers[index];
            PartnerFundRequest activity = businessValidationResult.requestByIndex.get(index);
            Core_MDF_PFC_APIUtil.ClaimProcessingResult result = businessValidationResult.results[index];
            Map<String, Object> stagePayload = (Map<String, Object>) claimRows[index];
            Core_MDF_Claim_Batch_Stage__c stage = new Core_MDF_Claim_Batch_Stage__c(
                Core_MDF_Batch_ID__c = batchId,
                Core_MDF_Request_Id__c = String.valueOf(index + 1)
            );
            if (activity != null) {
                Map<String, String> stageFields = stageFieldsByProgram.get(
                    templateProgramByActivityProgram.get(activity.Core_MDF_Program__c)
                );
                if (stageFields == null || stageFields.isEmpty()) {
                    throw new IllegalArgumentException('Missing claim batch stage mapping for the activity program.');
                }
                populateStage(stage, wrapper, Core_MDF_PFC_RestAPI_InputWrapper.getClaimFieldConfigs(
                    activity.Core_MDF_Program__c, activity.Core_MDF_Budget_Type_nm__c
                ), stageFields);
                stage.Core_MDF_Activity_Nbr__c = activity.Core_MDF_Activity_Number__c;
            }
            if (result.success == false) {
                stage.Core_MDF_Processing_Status_Nm__c = 'Failed';
                stage.Core_MDF_Failure_Reason_Txt__c = result.message;
                stage.Core_MDF_Message_txt__c = result.message;
                stage.Core_MDF_Log_Info_txt__c = result.code;
            }
            stage.Core_MDF_Claim_Attributes_JSON_txt__c = JSON.serialize(stagePayload);
            if (recordTypeByIndex.containsKey(index)) {
                stage.RecordTypeId = recordTypeByIndex.get(index);
            }
            stages.add(stage);
        }
        Database.insert(stages, AccessLevel.USER_MODE);
        Map<Id, Core_MDF_Claim_Batch_Stage__c> savedStages = new Map<Id, Core_MDF_Claim_Batch_Stage__c>([
            SELECT Id, Name
            FROM Core_MDF_Claim_Batch_Stage__c
            WHERE Id IN :stages
        ]);
        for (Integer index = 0; index < stages.size(); index++) {
            stages[index] = savedStages.get(stages[index].Id);
        }
        return stages;
    }

    @TestVisible
    private static Map<String, String> resolveTemplateProgramNames(
        Set<String> programs,
        List<Core_MDF_ClaimActAllocRecTypeMapping__mdt> programMappings
    ) {
        Map<String, String> templateProgramByActivityProgram = new Map<String, String>();
        Map<String, String> configuredNames = new Map<String, String>();
        for (String program : programs) {
            templateProgramByActivityProgram.put(program, program);
        }
        for (Core_MDF_ClaimActAllocRecTypeMapping__mdt mapping : programMappings) {
            String program = mapping.Core_MDF_Channel_Program_txt__c;
            String templateProgram = mapping.Core_MDF_Channel_Program_Name_txt__c;
            if (String.isBlank(program) || String.isBlank(templateProgram) || !programs.contains(program)) {
                continue;
            }
            if (configuredNames.containsKey(program) && configuredNames.get(program) != templateProgram) {
                throw new IllegalArgumentException('Conflicting claim batch program mappings.');
            }
            configuredNames.put(program, templateProgram);
            templateProgramByActivityProgram.put(program, templateProgram);
        }
        return templateProgramByActivityProgram;
    }

    private static void populateStage(
        Core_MDF_Claim_Batch_Stage__c stage,
        Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput wrapper,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig> configs,
        Map<String, String> stageFields
    ) {
        for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig config : configs) {
            if (String.isBlank(config.fieldApiName)) {
                continue;
            }
            String stageField = stageFields.get(config.fieldApiName.toLowerCase());
            if (stageField == null) {
                continue;
            }
            Object value = wrapper.getValue(config.payloadFieldName);
            if (value == null) {
                value = wrapper.getValue(config.fieldApiName);
            }
            if (value == null || (value instanceof String && String.isBlank((String) value))) {
                continue;
            }
            if (!STAGE_FIELDS.containsKey(stageField)) {
                throw new IllegalArgumentException('Invalid claim batch stage field mapping.');
            }
            Schema.DisplayType fieldType = STAGE_FIELDS.get(stageField).getDescribe().getType();
            if (fieldType == Schema.DisplayType.DATE) {
                value = Date.valueOf(String.valueOf(value));
            } else if (fieldType == Schema.DisplayType.DATETIME) {
                value = JSON.deserialize(JSON.serialize(value), Datetime.class);
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                value = Boolean.valueOf(String.valueOf(value));
            } else if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.PERCENT || fieldType == Schema.DisplayType.INTEGER) {
                value = Decimal.valueOf(String.valueOf(value));
            } else {
                value = String.valueOf(value);
            }
            stage.put(stageField, value);
        }
    }

    private static Map<Integer, Id> resolveStageRecordTypes(
        Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidationResult
    ) {
        Set<String> activityRecordTypes = new Set<String>();
        for (PartnerFundRequest requestRecord : businessValidationResult.requestByIndex.values()) {
            if (requestRecord.RecordType != null) {
                activityRecordTypes.add(requestRecord.RecordType.DeveloperName);
            }
        }

        Map<String, String> stageTypeByActivityType = new Map<String, String>();
        for (Core_MDF_ClaimActAllocRecTypeMapping__mdt mapping : [
            SELECT Core_MDF_Activity_RecordType_txt__c, Core_MDF_ClaimStage_RecordType_txt__c
            FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
            WHERE Core_MDF_Activity_RecordType_txt__c IN :activityRecordTypes
        ]) {
            stageTypeByActivityType.put(
                mapping.Core_MDF_Activity_RecordType_txt__c,
                mapping.Core_MDF_ClaimStage_RecordType_txt__c
            );
        }

        Map<String, Id> stageRecordTypeIds = new Map<String, Id>();
        for (Schema.RecordTypeInfo recordTypeInfo : Core_MDF_Claim_Batch_Stage__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            stageRecordTypeIds.put(recordTypeInfo.getDeveloperName(), recordTypeInfo.getRecordTypeId());
        }

        Map<Integer, Id> recordTypeByIndex = new Map<Integer, Id>();
        for (Integer index : businessValidationResult.requestByIndex.keySet()) {
            PartnerFundRequest requestRecord = businessValidationResult.requestByIndex.get(index);
            String stageRecordTypeName = requestRecord.RecordType == null
                ? null
                : stageTypeByActivityType.get(requestRecord.RecordType.DeveloperName);
            if (stageRecordTypeIds.containsKey(stageRecordTypeName)) {
                recordTypeByIndex.put(index, stageRecordTypeIds.get(stageRecordTypeName));
            }
        }
        return recordTypeByIndex;
    }

    private static Integer resolveHttpStatusCode(Core_MDF_APIResponse response) {
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
        if (responseCode == Core_MDF_PFC_APIUtil.CODE_8018_INTERNAL_SERVER_ERROR
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR) {
            return 500;
        }

        if (responseCode == Core_MDF_PFC_APIUtil.STATUS_207_PARTIAL_SUCCESS) {
            return 207;
        }

        if (responseCode == Core_MDF_PFC_APIUtil.CODE_8001_REQUEST_BODY_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8003_CLAIM_TITLE_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8004_ACTIVITY_NUMBER_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8005_CLAIM_SUBMITTER_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8006_INVALID_CLAIM_DATES
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8009_CLAIM_CURRENCY_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8012_INVALID_TOTAL_AMOUNT_LOCAL
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8013_INVALID_COSTS_NOT_REIMBURSABLE
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8015_CLAIM_COUNTRY_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8019_COUNTRY_NOT_IN_ACTIVITY
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8022_PROOF_OF_COST_NUMBER_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8027_PROCESSING_PREFERENCE_REQUIRED
            || responseCode == Core_MDF_PFC_APIUtil.CODE_8039_INVALID_CLAIM_TYPE) {
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