/**
 * Creates a PartnerFundClaim from an uploaded claim-batch stage.
 */
@RestResource(urlMapping='/v1.0/partnercenter/claim/create/*')
global without sharing class Core_MDF_PFC_CreateAPI {
    private static final Integer MAX_STAGE_RECORDS_PER_REQUEST = Core_MDF_PFC_APIUtil.MAX_CLAIMS_PER_REQUEST;
    private static final Integer MAX_POP_FILES_PER_REQUEST = 500;
    private static final String DOCUMENT_REQUIRED_CODE = '8044';
    private static final String CLAIM_ALREADY_CREATED_MESSAGE = 'A claim has already been created for this stage.';
    private static final String POP_CONFIGURATION_MESSAGE = 'No required POP document types are configured for this claim.';

    @HttpPost
    global static void handleRequest() {
        Datetime entryTime = System.now();
        String requestPayload;
        List<String> logErrors;

        try {
            requestPayload = RestContext.request?.requestBody?.toString();
            if (String.isBlank(requestPayload)) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8001_REQUEST_BODY_REQUIRED
                ));
                return;
            }

            List<Id> stageIds;
            Boolean isStageIdArray = false;
            try {
                Object payload = JSON.deserializeUntyped(requestPayload);
                if (!(payload instanceof Map<String, Object>)) {
                    throw new IllegalArgumentException();
                }
                Map<String, Object> payloadMap = (Map<String, Object>) payload;
                if (payloadMap.size() != 1) {
                    throw new IllegalArgumentException();
                }
                if (payloadMap.get('stageRecordIds') instanceof List<Object>) {
                    isStageIdArray = true;
                    stageIds = parseStageRecordIds((List<Object>) payloadMap.get('stageRecordIds'));
                } else if (payloadMap.get('stageRecordId') instanceof String) {
                    stageIds = new List<Id>{ Id.valueOf((String) payloadMap.get('stageRecordId')) };
                    if (stageIds[0].getSObjectType() != Core_MDF_Claim_Batch_Stage__c.SObjectType) {
                        throw new IllegalArgumentException();
                    }
                } else {
                    throw new IllegalArgumentException();
                }
            } catch (Exception ex) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE
                ));
                return;
            }
            if (stageIds.isEmpty()) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE
                ));
                return;
            }
            if (stageIds.size() > MAX_STAGE_RECORDS_PER_REQUEST) {
                sendResponse(buildMaximumStageLimitError());
                return;
            }
            if (isStageIdArray) {
                sendResponse(createClaimsForStages(stageIds));
                return;
            }
            Id stageId = stageIds[0];

            List<Core_MDF_Claim_Batch_Stage__c> stageRows = [
                SELECT Id, Core_MDF_Activity_Nbr__c, Core_MDF_Claim_Attributes_JSON_txt__c,
                    Core_MDF_Processing_Status_Nm__c, Core_MDF_Claim_Reference_Nbr__c
                FROM Core_MDF_Claim_Batch_Stage__c
                WHERE Id = :stageId
                WITH USER_MODE
                FOR UPDATE
            ];
            if (stageRows.isEmpty()) {
                sendResponse(buildBusinessError('Claim stage was not found or is not accessible.'));
                return;
            }

            Core_MDF_Claim_Batch_Stage__c stage = stageRows[0];
            if (String.isNotBlank(stage.Core_MDF_Claim_Reference_Nbr__c)
                || stage.Core_MDF_Processing_Status_Nm__c == 'Successful') {
                sendResponse(buildBusinessError(CLAIM_ALREADY_CREATED_MESSAGE));
                return;
            }

            Set<Id> contentDocumentIds = getStageContentDocumentIds(stage.Id);
            if (contentDocumentIds.isEmpty()) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(DOCUMENT_REQUIRED_CODE));
                return;
            }
            Map<Id, ContentVersion> latestVersions = getLatestContentVersions(contentDocumentIds);
            if (latestVersions.size() != contentDocumentIds.size()) {
                sendResponse(buildBusinessError('One or more uploaded POP files are unavailable.'));
                return;
            }

            List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claims = parseStageClaim(stage);
            if (claims == null || claims.size() != 1 || claims[0] == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE
                ));
                return;
            }

            Core_MDF_PFC_APIUtil.ValidationResult validation = Core_MDF_PFC_APIUtil.validateClaims(claims, false);
            if (validation == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR
                ));
                return;
            }
            if (!validation.isSuccess) {
                sendResponse(validation.response);
                return;
            }

            Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidation =
                Core_MDF_PFC_APIUtil.validateActivityAndCountry(validation.validWrappers);
            if (businessValidation == null) {
                sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR
                ));
                return;
            }
            Core_MDF_PFC_APIUtil.ClaimProcessingResult businessResult = businessValidation.results[0];
            if (businessResult.success != true) {
                sendResponse(Core_MDF_PFC_APIUtil.buildProcessingResponse(businessValidation.results));
                return;
            }

            PartnerFundRequest activity = [
                SELECT Id, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c,
                    ChannelPartner.Core_MDF_Channel_Program__r.Name
                FROM PartnerFundRequest
                WHERE Id = :businessValidation.requestByIndex.get(0).Id
                WITH USER_MODE
                LIMIT 1
            ];
            if (hasDuplicateClaim(validation.validWrappers[0], activity)) {
                sendResponse(buildBusinessError('A duplicate claim already exists for these claim details.'));
                return;
            }

            List<Core_MDF_POP_Document_Types_Revamp__mdt> documentRules = getPOPDocumentRules(
                activity.Core_MDF_Program__c,
                activity.Core_MDF_Budget_Type_nm__c
            );
            List<String> applicableDocumentTypes = new List<String>();
            List<String> requiredDocumentTypes = new List<String>();
            for (Core_MDF_POP_Document_Types_Revamp__mdt rule : documentRules) {
                if (rule == null || String.isBlank(rule.Core_MDF_Document_Type_nm__c)) {
                    continue;
                }
                applicableDocumentTypes.add(rule.Core_MDF_Document_Type_nm__c);
                if (rule.Core_MDF_ReqforPOPSubmission_ind__c == true) {
                    requiredDocumentTypes.add(rule.Core_MDF_Document_Type_nm__c);
                }
            }
            if (requiredDocumentTypes.isEmpty()) {
                sendResponse(buildBusinessError(POP_CONFIGURATION_MESSAGE));
                return;
            }

            Savepoint savepoint = Database.setSavepoint();
            try {
                Core_MDF_APIResponse claimResponse = Core_MDF_PFC_APIUtil.processClaimsInBulk(
                    validation.validWrappers,
                    businessValidation
                );
                if (claimResponse == null || claimResponse.isSuccess != true || businessResult.recordId == null) {
                    updateStageFailure(stage.Id, businessResult);
                    sendResponse(claimResponse == null
                        ? Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR)
                        : claimResponse);
                    return;
                }

                List<Core_MDF_Audit_Document__c> auditDocuments = buildAuditDocuments(
                    latestVersions.values(),
                    stage.Id,
                    businessResult.recordId,
                    applicableDocumentTypes,
                    requiredDocumentTypes
                );
                Database.insert(auditDocuments, AccessLevel.USER_MODE);

                List<ContentDocumentLink> claimFileLinks = new List<ContentDocumentLink>();
                for (ContentVersion version : latestVersions.values()) {
                    claimFileLinks.add(new ContentDocumentLink(
                        ContentDocumentId = version.ContentDocumentId,
                        LinkedEntityId = businessResult.recordId,
                        ShareType = 'I',
                        Visibility = 'AllUsers'
                    ));
                }
                Database.insert(claimFileLinks, AccessLevel.USER_MODE);
                updateLastPOPSubmissionDate(auditDocuments, businessResult.recordId);

                Database.update(new Core_MDF_Claim_Batch_Stage__c(
                    Id = stage.Id,
                    Core_MDF_Processing_Status_Nm__c = 'Successful',
                    Core_MDF_Claim_Reference_Nbr__c = businessResult.claimNumber,
                    Core_MDF_Failure_Reason_Txt__c = null,
                    Core_MDF_Message_txt__c = 'Claim created and POP documents attached.',
                    Core_MDF_Log_Info_txt__c = businessResult.code
                ), AccessLevel.USER_MODE);

                if (claimResponse.details instanceof Map<String, Object>) {
                    ((Map<String, Object>) claimResponse.details).put('stageRecordId', stage.Id);
                }
                sendResponse(claimResponse);
            } catch (Exception ex) {
                Database.rollback(savepoint);
                Core_MDF_CCP_UtilityClass.logError(ex);
                Core_MDF_APIResponse failure = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                    Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR
                );
                sendResponse(failure);
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            logErrors = new List<String>{ ex.getMessage(), ex.getStackTraceString() };
            sendResponse(Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
                Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR
            ));
        } finally {
            logRequest(requestPayload, logErrors, entryTime);
        }
    }

    private static List<Id> parseStageRecordIds(List<Object> payloadStageIds) {
        if (payloadStageIds == null || payloadStageIds.isEmpty()) {
            throw new IllegalArgumentException('stageRecordIds must not be empty.');
        }
        List<Id> stageIds = new List<Id>();
        Set<Id> uniqueStageIds = new Set<Id>();
        for (Object value : payloadStageIds) {
            if (!(value instanceof String)) {
                throw new IllegalArgumentException('Each stageRecordId must be a string.');
            }
            Id stageId = Id.valueOf((String) value);
            if (stageId.getSObjectType() != Core_MDF_Claim_Batch_Stage__c.SObjectType
                || uniqueStageIds.contains(stageId)) {
                throw new IllegalArgumentException('stageRecordIds must contain unique claim batch stage IDs.');
            }
            uniqueStageIds.add(stageId);
            stageIds.add(stageId);
        }
        return stageIds;
    }

    private static Core_MDF_APIResponse buildMaximumStageLimitError() {
        Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
            Core_MDF_PFC_APIUtil.CODE_8031_MAX_CLAIMS_EXCEEDED
        );
        String message = response != null && response.error != null ? response.error.message : null;
        if (String.isNotBlank(message) && message.contains('{value}')) {
            response.setErrorInfo(
                message.replace('{value}', String.valueOf(MAX_STAGE_RECORDS_PER_REQUEST)),
                Core_MDF_PFC_APIUtil.CODE_8031_MAX_CLAIMS_EXCEEDED
            );
        }
        return response;
    }

    private static Core_MDF_APIResponse createClaimsForStages(List<Id> stageIds) {
        Map<Id, Integer> indexByStageId = new Map<Id, Integer>();
        for (Integer index = 0; index < stageIds.size(); index++) {
            indexByStageId.put(stageIds[index], index);
        }

        Map<Id, Core_MDF_Claim_Batch_Stage__c> stageById = new Map<Id, Core_MDF_Claim_Batch_Stage__c>([
            SELECT Id, Core_MDF_Activity_Nbr__c, Core_MDF_Claim_Attributes_JSON_txt__c,
                Core_MDF_Processing_Status_Nm__c, Core_MDF_Claim_Reference_Nbr__c
            FROM Core_MDF_Claim_Batch_Stage__c
            WHERE Id IN :stageIds
            WITH USER_MODE
            FOR UPDATE
        ]);
        Set<Integer> missingStageIndexes = new Set<Integer>();
        for (Id stageId : stageIds) {
            if (!stageById.containsKey(stageId)) {
                missingStageIndexes.add(indexByStageId.get(stageId));
            }
        }
        if (!missingStageIndexes.isEmpty()) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                'One or more claim stages were not found or are not accessible.',
                stageIds,
                missingStageIndexes
            );
        }

        Set<Integer> completedStageIndexes = new Set<Integer>();
        for (Id stageId : stageIds) {
            Core_MDF_Claim_Batch_Stage__c stage = stageById.get(stageId);
            if (String.isNotBlank(stage.Core_MDF_Claim_Reference_Nbr__c)
                || stage.Core_MDF_Processing_Status_Nm__c == 'Successful') {
                completedStageIndexes.add(indexByStageId.get(stageId));
            }
        }
        if (!completedStageIndexes.isEmpty()) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                CLAIM_ALREADY_CREATED_MESSAGE,
                stageIds,
                completedStageIndexes
            );
        }

        Map<Id, Set<Id>> documentIdsByStage = getStageContentDocumentIds(new Set<Id>(stageIds));
        Set<Id> allDocumentIds = new Set<Id>();
        Set<Integer> missingDocumentIndexes = new Set<Integer>();
        Integer totalFileCount = 0;
        for (Id stageId : stageIds) {
            Set<Id> documentIds = documentIdsByStage.get(stageId);
            if (documentIds == null || documentIds.isEmpty()) {
                missingDocumentIndexes.add(indexByStageId.get(stageId));
                continue;
            }
            totalFileCount += documentIds.size();
            allDocumentIds.addAll(documentIds);
        }
        if (!missingDocumentIndexes.isEmpty()) {
            Core_MDF_APIResponse error = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(DOCUMENT_REQUIRED_CODE);
            return addStageResults(error, stageIds, missingDocumentIndexes, error.getCode(), error.getMessage());
        }
        if (totalFileCount > MAX_POP_FILES_PER_REQUEST) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                'A maximum of ' + MAX_POP_FILES_PER_REQUEST + ' POP files is allowed per request.',
                stageIds,
                null
            );
        }

        Map<Id, ContentVersion> latestVersionByDocumentId = getLatestContentVersions(allDocumentIds);
        Set<Integer> unavailableFileIndexes = new Set<Integer>();
        for (Id stageId : stageIds) {
            for (Id documentId : documentIdsByStage.get(stageId)) {
                if (!latestVersionByDocumentId.containsKey(documentId)) {
                    unavailableFileIndexes.add(indexByStageId.get(stageId));
                    break;
                }
            }
        }
        if (!unavailableFileIndexes.isEmpty()) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                'One or more uploaded POP files are unavailable.',
                stageIds,
                unavailableFileIndexes
            );
        }

        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claims =
            new List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput>();
        for (Id stageId : stageIds) {
            List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> stageClaim = parseStageClaim(stageById.get(stageId));
            if (stageClaim == null || stageClaim.size() != 1 || stageClaim[0] == null) {
                return buildStageBatchError(
                    Core_MDF_PFC_APIUtil.CODE_8002_INVALID_PAYLOAD_STRUCTURE,
                    null,
                    stageIds,
                    new Set<Integer>{ indexByStageId.get(stageId) }
                );
            }
            claims.add(stageClaim[0]);
        }

        Core_MDF_PFC_APIUtil.ValidationResult validation = Core_MDF_PFC_APIUtil.validateClaims(claims, false);
        if (validation == null) {
            return Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR);
        }
        if (!validation.isSuccess) {
            return addStageRecordIds(validation.response, stageIds);
        }

        Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidation =
            Core_MDF_PFC_APIUtil.validateActivityAndCountry(validation.validWrappers);
        if (businessValidation == null) {
            return Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR);
        }
        if (hasBusinessValidationFailures(businessValidation.results)) {
            Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildProcessingResponse(businessValidation.results);
            normalizePreflightError(response);
            return addStageRecordIds(response, stageIds);
        }

        List<PartnerFundRequest> activities = lockAndLoadActivities(businessValidation, stageIds);
        if (activities == null) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                'One or more claim activities are unavailable.',
                stageIds,
                null
            );
        }

        Set<Integer> duplicateIndexes = getDuplicateClaimIndexes(validation.validWrappers, activities);
        if (!duplicateIndexes.isEmpty()) {
            for (Integer index : duplicateIndexes) {
                Core_MDF_PFC_APIUtil.ClaimProcessingResult result = businessValidation.results[index];
                result.success = false;
                result.code = Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED;
                result.message = 'A duplicate claim already exists for these claim details.';
            }
            Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildProcessingResponse(businessValidation.results);
            normalizePreflightError(response);
            return addStageRecordIds(response, stageIds);
        }

        Set<String> programNames = new Set<String>();
        for (PartnerFundRequest activity : activities) {
            programNames.add(activity.Core_MDF_Program__c);
        }
        Map<String, List<Core_MDF_POP_Document_Types_Revamp__mdt>> rulesByProgram = getPOPDocumentRules(programNames);
        Map<Integer, List<String>> applicableTypesByIndex = new Map<Integer, List<String>>();
        Map<Integer, List<String>> requiredTypesByIndex = new Map<Integer, List<String>>();
        Set<Integer> missingPopConfiguration = new Set<Integer>();
        for (Integer index = 0; index < activities.size(); index++) {
            PartnerFundRequest activity = activities[index];
            List<String> applicableTypes = new List<String>();
            List<String> requiredTypes = new List<String>();
            List<Core_MDF_POP_Document_Types_Revamp__mdt> programRules = rulesByProgram.get(activity.Core_MDF_Program__c);
            if (programRules != null) {
                for (Core_MDF_POP_Document_Types_Revamp__mdt rule : programRules) {
                    if (rule.Core_MDF_ApplicableToAll_BudgetTypes_Ind__c != true
                        && rule.Core_MDF_Budget_Type_txt__c != activity.Core_MDF_Budget_Type_nm__c) {
                        continue;
                    }
                    applicableTypes.add(rule.Core_MDF_Document_Type_nm__c);
                    if (rule.Core_MDF_ReqforPOPSubmission_ind__c == true) {
                        requiredTypes.add(rule.Core_MDF_Document_Type_nm__c);
                    }
                }
            }
            if (requiredTypes.isEmpty()) {
                missingPopConfiguration.add(index);
            }
            applicableTypesByIndex.put(index, applicableTypes);
            requiredTypesByIndex.put(index, requiredTypes);
        }
        if (!missingPopConfiguration.isEmpty()) {
            return buildStageBatchError(
                Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED,
                POP_CONFIGURATION_MESSAGE,
                stageIds,
                missingPopConfiguration
            );
        }

        Savepoint savepoint = Database.setSavepoint();
        try {
            Core_MDF_APIResponse claimResponse = Core_MDF_PFC_APIUtil.processClaimsInBulk(
                validation.validWrappers,
                businessValidation
            );
            if (claimResponse == null || businessValidation.results == null
                || businessValidation.results.size() != stageIds.size()) {
                throw new IllegalArgumentException('Claim processing did not return one result per stage.');
            }

            List<Core_MDF_Audit_Document__c> auditDocuments = new List<Core_MDF_Audit_Document__c>();
            List<ContentDocumentLink> claimFileLinks = new List<ContentDocumentLink>();
            List<Core_MDF_Claim_Batch_Stage__c> stagesToUpdate = new List<Core_MDF_Claim_Batch_Stage__c>();
            for (Integer index = 0; index < stageIds.size(); index++) {
                Core_MDF_PFC_APIUtil.ClaimProcessingResult result = businessValidation.results[index];
                if (result.success == true && result.recordId != null) {
                    List<ContentVersion> versions = new List<ContentVersion>();
                    for (Id documentId : documentIdsByStage.get(stageIds[index])) {
                        ContentVersion version = latestVersionByDocumentId.get(documentId);
                        versions.add(version);
                        claimFileLinks.add(new ContentDocumentLink(
                            ContentDocumentId = documentId,
                            LinkedEntityId = result.recordId,
                            ShareType = 'I',
                            Visibility = 'AllUsers'
                        ));
                    }
                    auditDocuments.addAll(buildAuditDocuments(
                        versions,
                        stageIds[index],
                        result.recordId,
                        applicableTypesByIndex.get(index),
                        requiredTypesByIndex.get(index)
                    ));
                    stagesToUpdate.add(new Core_MDF_Claim_Batch_Stage__c(
                        Id = stageIds[index],
                        Core_MDF_Processing_Status_Nm__c = 'Successful',
                        Core_MDF_Claim_Reference_Nbr__c = result.claimNumber,
                        Core_MDF_Failure_Reason_Txt__c = null,
                        Core_MDF_Message_txt__c = 'Claim created and POP documents attached.',
                        Core_MDF_Log_Info_txt__c = result.code
                    ));
                } else {
                    stagesToUpdate.add(new Core_MDF_Claim_Batch_Stage__c(
                        Id = stageIds[index],
                        Core_MDF_Processing_Status_Nm__c = 'Failed',
                        Core_MDF_Failure_Reason_Txt__c = result.message,
                        Core_MDF_Message_txt__c = result.message,
                        Core_MDF_Log_Info_txt__c = result.code
                    ));
                }
            }

            if (!auditDocuments.isEmpty()) {
                Database.insert(auditDocuments, AccessLevel.USER_MODE);
                Database.insert(claimFileLinks, AccessLevel.USER_MODE);
                updateLastPOPSubmissionDates(auditDocuments);
            }
            Database.update(stagesToUpdate, AccessLevel.USER_MODE);
            return addStageRecordIds(claimResponse, stageIds);
        } catch (Exception ex) {
            Database.rollback(savepoint);
            Core_MDF_CCP_UtilityClass.logError(ex);
            return Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(Core_MDF_PFC_APIUtil.CODE_8021_APPLICATION_ERROR);
        }
    }

    private static Set<Integer> getDuplicateClaimIndexes(
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claims,
        List<PartnerFundRequest> activities
    ) {
        List<PartnerFundClaim> candidates = new List<PartnerFundClaim>();
        for (Integer index = 0; index < claims.size(); index++) {
            PartnerFundRequest activity = activities[index];
            PartnerFundClaim candidate = claims[index].toPartnerFundClaim(
                activity.Id,
                UserInfo.getUserId(),
                null,
                activity.Core_MDF_Program__c
            );
            candidate.RequestId = activity.Id;
            Map<String, Object> candidateFields = new Map<String, Object>(candidate.getPopulatedFieldsAsMap());
            candidateFields.put('Core_MDF_Program__c', activity.ChannelPartner.Core_MDF_Channel_Program__r.Name);
            candidates.add((PartnerFundClaim) JSON.deserialize(JSON.serialize(candidateFields), PartnerFundClaim.class));
        }
        Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(candidates);
        Set<Integer> duplicateIndexes = new Set<Integer>();
        for (Integer index = 0; index < candidates.size(); index++) {
            if (candidates[index].Core_MDF_Duplicate_Claim__c == true) {
                duplicateIndexes.add(index);
            }
        }
        return duplicateIndexes;
    }

    private static List<PartnerFundRequest> lockAndLoadActivities(
        Core_MDF_PFC_APIUtil.BusinessValidationResult businessValidation,
        List<Id> stageIds
    ) {
        Set<Id> activityIds = new Set<Id>();
        for (PartnerFundRequest activity : businessValidation.requestByIndex.values()) {
            if (activity != null) {
                activityIds.add(activity.Id);
            }
        }
        Map<Id, PartnerFundRequest> activitiesById = new Map<Id, PartnerFundRequest>([
            SELECT Id, ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Activity_Number__c,
                Core_MDF_Country_nm__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c,
                Core_MDF_Budget_Type_nm__c, Core_MDF_Brand_nm__c, RecordType.DeveloperName,
                ChannelPartner.Core_MDF_Channel_Program__r.Name
            FROM PartnerFundRequest
            WHERE Id IN :activityIds
            WITH USER_MODE
            FOR UPDATE
        ]);
        if (activitiesById.size() != activityIds.size()) {
            return null;
        }
        List<PartnerFundRequest> activities = new List<PartnerFundRequest>();
        for (Integer index = 0; index < stageIds.size(); index++) {
            PartnerFundRequest validatedActivity = businessValidation.requestByIndex.get(index);
            PartnerFundRequest activity = validatedActivity == null ? null : activitiesById.get(validatedActivity.Id);
            if (activity == null) {
                return null;
            }
            businessValidation.requestByIndex.put(index, activity);
            activities.add(activity);
        }
        return activities;
    }

    private static Map<String, List<Core_MDF_POP_Document_Types_Revamp__mdt>> getPOPDocumentRules(
        Set<String> programs
    ) {
        Map<String, List<Core_MDF_POP_Document_Types_Revamp__mdt>> rulesByProgram =
            new Map<String, List<Core_MDF_POP_Document_Types_Revamp__mdt>>();
        if (programs == null || programs.isEmpty()) {
            return rulesByProgram;
        }
        for (Core_MDF_POP_Document_Types_Revamp__mdt rule : [
            SELECT Core_MDF_Program_nm__c, Core_MDF_Budget_Type_txt__c,
                Core_MDF_ApplicableToAll_BudgetTypes_Ind__c, Core_MDF_Document_Type_nm__c,
                Core_MDF_ReqforPOPSubmission_ind__c, Core_MDF_Order_nbr__c
            FROM Core_MDF_POP_Document_Types_Revamp__mdt
            WHERE Core_MDF_Program_nm__c IN :programs
                AND Core_MDF_Active_ind__c = true
            ORDER BY Core_MDF_Order_nbr__c
        ]) {
            if (!rulesByProgram.containsKey(rule.Core_MDF_Program_nm__c)) {
                rulesByProgram.put(rule.Core_MDF_Program_nm__c, new List<Core_MDF_POP_Document_Types_Revamp__mdt>());
            }
            rulesByProgram.get(rule.Core_MDF_Program_nm__c).add(rule);
        }
        return rulesByProgram;
    }

    private static Core_MDF_APIResponse buildStageBatchError(
        String errorCode,
        String message,
        List<Id> stageIds,
        Set<Integer> failedIndexes
    ) {
        Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(errorCode);
        if (String.isNotBlank(message)) {
            response.setErrorInfo(message, response.getCode());
        }
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Integer index = 0; index < stageIds.size(); index++) {
            if (failedIndexes != null && !failedIndexes.contains(index)) {
                continue;
            }
            results.add(new Map<String, Object>{
                'rowNumber' => index + 1,
                'stageRecordId' => stageIds[index],
                'success' => false,
                'code' => response.getCode(),
                'message' => response.getMessage()
            });
        }
        response.details = new Map<String, Object>{
            Core_MDF_PFC_APIUtil.KEY_RESULTS => results,
            'stageRecordIds' => stageIds
        };
        return response;
    }

    private static Core_MDF_APIResponse addStageResults(
        Core_MDF_APIResponse response,
        List<Id> stageIds,
        Set<Integer> failedIndexes,
        String errorCode,
        String errorMessage
    ) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Integer index : failedIndexes) {
            if (index == null || index < 0 || index >= stageIds.size()) {
                continue;
            }
            results.add(new Map<String, Object>{
                'rowNumber' => index + 1,
                'stageRecordId' => stageIds[index],
                'success' => false,
                'code' => errorCode,
                'message' => errorMessage
            });
        }
        response.details = new Map<String, Object>{
            Core_MDF_PFC_APIUtil.KEY_RESULTS => results,
            'stageRecordIds' => stageIds
        };
        return response;
    }

    private static Core_MDF_APIResponse addStageRecordIds(Core_MDF_APIResponse response, List<Id> stageIds) {
        Map<String, Object> details = response != null && response.details instanceof Map<String, Object>
            ? (Map<String, Object>) response.details
            : new Map<String, Object>();
        Object rawResults = details.get(Core_MDF_PFC_APIUtil.KEY_RESULTS);
        if (rawResults != null) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(JSON.serialize(rawResults));
            for (Integer index = 0; index < results.size() && index < stageIds.size(); index++) {
                if (results[index] instanceof Map<String, Object>) {
                    ((Map<String, Object>) results[index]).put('stageRecordId', stageIds[index]);
                }
            }
            details.put(Core_MDF_PFC_APIUtil.KEY_RESULTS, results);
        }
        details.put('stageRecordIds', stageIds);
        if (stageIds.size() == 1) {
            details.put('stageRecordId', stageIds[0]);
        }
        response.details = details;
        return response;
    }

    private static Boolean hasBusinessValidationFailures(List<Core_MDF_PFC_APIUtil.ClaimProcessingResult> results) {
        for (Core_MDF_PFC_APIUtil.ClaimProcessingResult result : results) {
            if (result == null || result.success != true) {
                return true;
            }
        }
        return false;
    }

    private static void normalizePreflightError(Core_MDF_APIResponse response) {
        if (response != null && response.httpStatusCode == 207) {
            response.setErrorInfo(response.getMessage(), Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED);
            response.httpStatusCode = 400;
        }
    }

    private static void updateLastPOPSubmissionDates(List<Core_MDF_Audit_Document__c> auditDocuments) {
        Set<Id> auditDocumentIds = new Set<Id>();
        for (Core_MDF_Audit_Document__c auditDocument : auditDocuments) {
            auditDocumentIds.add(auditDocument.Id);
        }
        Map<Id, Date> latestDateByClaimId = new Map<Id, Date>();
        Map<Id, Date> existingDateByClaimId = new Map<Id, Date>();
        for (Core_MDF_Audit_Document__c auditDocument : [
            SELECT CreatedDate, Core_MDF_Claim__c, Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c
            FROM Core_MDF_Audit_Document__c
            WHERE Id IN :auditDocumentIds
        ]) {
            if (auditDocument.Core_MDF_Claim__c == null) {
                continue;
            }
            Date createdDate = Date.newInstance(
                auditDocument.CreatedDate.year(),
                auditDocument.CreatedDate.month(),
                auditDocument.CreatedDate.day()
            );
            Date existingDate = auditDocument.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c;
            if (!latestDateByClaimId.containsKey(auditDocument.Core_MDF_Claim__c)
                || createdDate > latestDateByClaimId.get(auditDocument.Core_MDF_Claim__c)) {
                latestDateByClaimId.put(auditDocument.Core_MDF_Claim__c, createdDate);
                existingDateByClaimId.put(auditDocument.Core_MDF_Claim__c, existingDate);
            }
        }
        List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>();
        for (Id claimId : latestDateByClaimId.keySet()) {
            Date latestDate = latestDateByClaimId.get(claimId);
            Date existingDate = existingDateByClaimId.get(claimId);
            if (existingDate == null || latestDate > existingDate) {
                claimsToUpdate.add(new PartnerFundClaim(
                    Id = claimId,
                    Core_MDF_RMF_Last_POP_Submission_Dt__c = latestDate
                ));
            }
        }
        if (!claimsToUpdate.isEmpty()) {
            Database.update(claimsToUpdate, AccessLevel.USER_MODE);
        }
    }

    private static Map<Id, Set<Id>> getStageContentDocumentIds(Set<Id> stageIds) {
        Map<Id, Set<Id>> documentIdsByStage = new Map<Id, Set<Id>>();
        for (Id stageId : stageIds) {
            documentIdsByStage.put(stageId, new Set<Id>());
        }
        for (ContentDocumentLink link : [
            SELECT LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :stageIds
            WITH USER_MODE
        ]) {
            documentIdsByStage.get(link.LinkedEntityId).add(link.ContentDocumentId);
        }
        return documentIdsByStage;
    }

    private static Map<Id, ContentVersion> getLatestContentVersions(Set<Id> documentIds) {
        Map<Id, ContentVersion> versions = new Map<Id, ContentVersion>();
        if (documentIds == null || documentIds.isEmpty()) {
            return versions;
        }
        for (ContentVersion version : [
            SELECT Id, ContentDocumentId, Title, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId IN :documentIds AND IsLatest = true
            WITH USER_MODE
        ]) {
            versions.put(version.ContentDocumentId, version);
        }
        return versions;
    }

    private static Set<Id> getStageContentDocumentIds(Id stageId) {
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :stageId
            WITH USER_MODE
        ]) {
            documentIds.add(link.ContentDocumentId);
        }
        return documentIds;
    }

    private static List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> parseStageClaim(
        Core_MDF_Claim_Batch_Stage__c stage
    ) {
        if (String.isBlank(stage.Core_MDF_Claim_Attributes_JSON_txt__c)) {
            return null;
        }
        Object row = JSON.deserializeUntyped(stage.Core_MDF_Claim_Attributes_JSON_txt__c);
        if (!(row instanceof Map<String, Object>)) {
            return null;
        }
        String requestBody = JSON.serialize(new Map<String, Object>{
            Core_MDF_PFC_RestAPI_InputWrapper.KEY_CLAIM_DETAILS => new List<Object>{ row }
        });
        return Core_MDF_PFC_RestAPI_InputWrapper.parse(requestBody).getClaimDetails();
    }

    private static Boolean hasDuplicateClaim(
        Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput claim,
        PartnerFundRequest activity
    ) {
        PartnerFundClaim candidate = claim.toPartnerFundClaim(activity.Id, UserInfo.getUserId(), null, activity.Core_MDF_Program__c);
        candidate.RequestId = activity.Id;
        Map<String, Object> candidateFields = new Map<String, Object>(candidate.getPopulatedFieldsAsMap());
        candidateFields.put('Core_MDF_Program__c', activity.ChannelPartner.Core_MDF_Channel_Program__r.Name);
        candidate = (PartnerFundClaim) JSON.deserialize(JSON.serialize(candidateFields), PartnerFundClaim.class);
        Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(new List<PartnerFundClaim>{ candidate });
        return candidate.Core_MDF_Duplicate_Claim__c == true;
    }

    private static List<Core_MDF_POP_Document_Types_Revamp__mdt> getPOPDocumentRules(
        String programName,
        String budgetType
    ) {
        List<Core_MDF_POP_Document_Types_Revamp__mdt> applicableRules = new List<Core_MDF_POP_Document_Types_Revamp__mdt>();
        if (String.isBlank(programName)) {
            return applicableRules;
        }
        for (Core_MDF_POP_Document_Types_Revamp__mdt rule : [
            SELECT Core_MDF_Program_nm__c, Core_MDF_Budget_Type_txt__c,
                Core_MDF_ApplicableToAll_BudgetTypes_Ind__c, Core_MDF_Active_ind__c,
                Core_MDF_Document_Type_nm__c, Core_MDF_ReqforPOPSubmission_ind__c,
                Core_MDF_Req_Doc_Types_ind__c, Core_MDF_Order_nbr__c
            FROM Core_MDF_POP_Document_Types_Revamp__mdt
            WHERE Core_MDF_Program_nm__c = :programName
                AND Core_MDF_Active_ind__c = true
            ORDER BY Core_MDF_Order_nbr__c
        ]) {
            if (rule.Core_MDF_ApplicableToAll_BudgetTypes_Ind__c == true
                || rule.Core_MDF_Budget_Type_txt__c == budgetType) {
                applicableRules.add(rule);
            }
        }
        return applicableRules;
    }

    private static List<Core_MDF_Audit_Document__c> buildAuditDocuments(
        List<ContentVersion> versions,
        Id stageId,
        Id claimId,
        List<String> applicableDocumentTypes,
        List<String> requiredDocumentTypes
    ) {
        List<Core_MDF_Audit_Document__c> documents = new List<Core_MDF_Audit_Document__c>();
        String applicableTypes = String.join(applicableDocumentTypes, ';');
        String selectedTypes = String.join(requiredDocumentTypes, ';');
        for (ContentVersion version : versions) {
            String fileName = String.isNotBlank(version.PathOnClient) ? version.PathOnClient : version.Title;
            Integer slashIndex = fileName.lastIndexOf('/');
            if (slashIndex >= 0) {
                fileName = fileName.substring(slashIndex + 1);
            }
            if (fileName.length() > 225) {
                fileName = fileName.substring(fileName.length() - 225);
            }
            String encodedTitle = EncodingUtil.urlEncode(fileName, 'UTF-8').replace('+', '%20');
            if (encodedTitle.length() > 255) {
                fileName = fileName.substring(fileName.length() - 70);
                encodedTitle = EncodingUtil.urlEncode(fileName, 'UTF-8').replace('+', '%20');
            }

            documents.add(new Core_MDF_Audit_Document__c(
                Core_MDF_Claim__c = claimId,
                Core_MDF_Claim_Batch_Record__c = stageId,
                Core_MDF_Document_Id__c = String.valueOf(version.ContentDocumentId),
                Core_MDF_ContentVersion_Id__c = String.valueOf(version.Id),
                Core_MDF_Document_Title__c = fileName,
                Core_MDF_Download_Document_Title_txt__c = fileName,
                Core_MDF_Encoded_Document_Title_txt__c = encodedTitle,
                Core_MDF_Old_Document_Id__c = EncodingUtil.convertToHex(Crypto.generateAesKey(128))
                    + String.valueOf(System.now().getTime()),
                Core_MDF_App_Document_Types_nm__c = applicableTypes,
                Core_MDF_Document_Types__c = selectedTypes
            ));
        }
        return documents;
    }

    private static void updateLastPOPSubmissionDate(List<Core_MDF_Audit_Document__c> auditDocuments, Id claimId) {
        Set<Id> auditDocumentIds = new Set<Id>();
        for (Core_MDF_Audit_Document__c auditDocument : auditDocuments) {
            auditDocumentIds.add(auditDocument.Id);
        }
        Date latestSubmissionDate;
        for (Core_MDF_Audit_Document__c auditDocument : [
            SELECT CreatedDate
            FROM Core_MDF_Audit_Document__c
            WHERE Id IN :auditDocumentIds
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]) {
            latestSubmissionDate = Date.newInstance(
                auditDocument.CreatedDate.year(),
                auditDocument.CreatedDate.month(),
                auditDocument.CreatedDate.day()
            );
        }
        if (latestSubmissionDate != null) {
            Database.update(new PartnerFundClaim(
                Id = claimId,
                Core_MDF_RMF_Last_POP_Submission_Dt__c = latestSubmissionDate
            ), AccessLevel.USER_MODE);
        }
    }

    private static void updateStageFailure(Id stageId, Core_MDF_PFC_APIUtil.ClaimProcessingResult result) {
        Database.update(new Core_MDF_Claim_Batch_Stage__c(
            Id = stageId,
            Core_MDF_Processing_Status_Nm__c = 'Failed',
            Core_MDF_Failure_Reason_Txt__c = result == null ? null : result.message,
            Core_MDF_Message_txt__c = result == null ? null : result.message,
            Core_MDF_Log_Info_txt__c = result == null ? null : result.code
        ), AccessLevel.USER_MODE);
    }

    private static Core_MDF_APIResponse buildBusinessError(String message) {
        Core_MDF_APIResponse response = Core_MDF_PFC_APIUtil.buildErrorResponseFromCode(
            Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED
        );
        response.setErrorInfo(message, Core_MDF_PFC_APIUtil.CODE_8017_BUSINESS_VALIDATION_FAILED);
        response.httpStatusCode = 400;
        return response;
    }

    private static void sendResponse(Core_MDF_APIResponse response) {
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.statusCode = response == null || response.httpStatusCode == null
            ? 500
            : response.httpStatusCode;
        RestContext.response.addHeader(
            Core_MDF_PFC_APIUtil.CONTENT_TYPE_HEADER,
            Core_MDF_PFC_APIUtil.CONTENT_TYPE_JSON
        );
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response.getSerializedResponse()));
    }

    private static void logRequest(String requestPayload, List<String> errors, Datetime entryTime) {
        try {
            Core_MDF_RestAPI_Logger.LogRequest logRequest = new Core_MDF_RestAPI_Logger.LogRequest();
            String responseBody = RestContext.response?.responseBody?.toString();
            Object responsePayload = String.isBlank(responseBody)
                ? null
                : JSON.deserializeUntyped(responseBody);
            Map<String, Object> responseMap = responsePayload instanceof Map<String, Object>
                ? (Map<String, Object>) responsePayload
                : new Map<String, Object>();
            if (errors == null) {
                errors = new List<String>();
                Map<String, Object> errorMap = responseMap.get('error') instanceof Map<String, Object>
                    ? (Map<String, Object>) responseMap.get('error')
                    : null;
                if (errorMap != null && errorMap.get('message') != null) {
                    errors.add(String.valueOf(errorMap.get('message')));
                }
            }
            logRequest.apiName = 'Core_MDF_PFC_CreateAPI';
            logRequest.apiVersion = 'v1.0';
            logRequest.contextMessage = 'POST partner fund claim create from batch stage';
            logRequest.requestPayload = requestPayload;
            logRequest.responsePayload = responsePayload;
            logRequest.statusCode = RestContext.response == null
                ? '500'
                : String.valueOf(RestContext.response.statusCode);
            logRequest.isSuccess = responseMap.get('isSuccess') instanceof Boolean
                ? (Boolean) responseMap.get('isSuccess')
                : false;
            logRequest.errors = errors;
            logRequest.entryTime = entryTime;
            logRequest.exitTime = System.now();
            Core_MDF_RestAPI_Logger.logToTransactionEntry(logRequest);
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}