@RestResource(urlMapping='/v1.0/partnercenter/activityactions/*')
global with sharing class Core_MDF_PFR_ActivityActionAPI {

    // ==========================================
    // CUSTOM LABEL
    // Value: "Id,Core_MDF_Activity_Number__c,
    //         Core_MDF_Activity_Description__c,
    //         Core_MDF_Start_Date__c,
    //         Core_MDF_End_Date__c,
    //         Core_MDF_Budget_Type_nm__c,
    //         Core_MDF_Fund_Request_Status__c"
    // ==========================================

    private static final String DISPLAY_FIELDS_LABEL =
        System.Label.Activity_Display_Fields;
    private static final String ADDITIONAL_DISPLAY_FIELDS_LABEL =
        System.Label.Activity_Display_Fields_Additional;

    // ==========================================
    // WRAPPER CLASSES
    // ==========================================

    global class ActivityRequestBody {
        global String activity_number { get; set; }
        global String activity_id     { get; set; }
        global List<String> activity_ids { get; set; }
        global List<String> activity_numbers { get; set; }
        global String Comments        { get; set; }
    }

    global class ActivityResponse {
        global Boolean success   { get; set; }
        global String  Code      { get; set; }
        global String  message   { get; set; }
        global Integer errorCode { get; set; }
        global Object  data      { get; set; }

        global ActivityResponse(
            Boolean success,
            String  message,
            Integer errorCode,
            Object  data
        ) {
            this.success   = success;
            this.message   = message;
            this.errorCode = errorCode;
            this.data      = data;
        }
    }

    // ==========================================
    // CONSTANTS
    // ==========================================

    private static final String STATUS_CLOSED =
        Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_ClosedStatus');
    private static final String STATUS_CANCELLED =
        Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');
    private static final String ERROR_RESPONSE_CATEGORY = 'Activity Actions';
    private static final Set<String> CCF_DCF_PROGRAMS =
        new Set<String>{ 'Client', 'Datacenter' };

    // ==========================================
    // HTTP POST
    // ==========================================

    @HttpPost
    global static void doPost() {
        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            ActivityRequestBody requestBody =
                parseRequestBody(req.requestBody);

            if (requestBody == null) {
                setErrorResponse(res, 400,
                    'INVALID_REQUEST_BODY', '5001',
                    'INVALID_REQUEST_BODY', null);
                return;
            }

            String action = extractActionFromURL(req.requestURI);

            if (String.isBlank(action) || !isValidAction(action)) {
                setErrorResponse(res, 400,
                    'INVALID_ENDPOINT', '5002', 'INVALID_ENDPOINT', null);
                return;
            }

            Boolean hasActivityIds = requestBody.activity_ids != null &&
                !requestBody.activity_ids.isEmpty();
            Boolean hasActivityNumbers = requestBody.activity_numbers != null &&
                !requestBody.activity_numbers.isEmpty();
            if ((hasActivityIds || hasActivityNumbers) && action != 'status') {
                setErrorResponse(res, 400,
                    'INVALID_REQUEST_BODY', '5001',
                    'INVALID_REQUEST_BODY', null);
                return;
            }

            Integer statusRequestCount = hasActivityIds
                ? requestBody.activity_ids.size()
                : hasActivityNumbers
                    ? requestBody.activity_numbers.size()
                    : 0;
            if (action == 'status' && statusRequestCount > 10) {
                setErrorResponse(
                    res,
                    400,
                    'BATCH_LIMIT_EXCEEDED',
                    '5016',
                    'STATUS_BATCH_LIMIT_EXCEEDED',
                    null
                );
                return;
            }

            String duplicateDetails =
                getDuplicateIdentifierDetails(requestBody);
            if (String.isNotBlank(duplicateDetails)) {
                setErrorResponse(
                    res,
                    400,
                    'VALIDATION_ERROR',
                    '5015',
                    'DUPLICATE_ACTIVITY_IDENTIFIER',
                    duplicateDetails
                );
                return;
            }

            String validationContext = validateRequest(requestBody);
            if (String.isNotBlank(validationContext)) {
                setErrorResponse(res, 400,
                    'VALIDATION_ERROR', getValidationSettingCode(validationContext),
                    validationContext, null);
                return;
            }

            switch on action {
                when 'close'  { closeActivity(requestBody, res);     }
                when 'cancel' { cancelActivity(requestBody, res);    }
                when 'status' { getActivityStatus(requestBody, res); }
            }

        } catch (Exception ex) {
            setErrorResponse(res, 500,
                'INTERNAL_SERVER_ERROR', '5006', 'UNHANDLED_ERROR',
                ex.getMessage());
        }
    }

    // ==========================================
    // ACTION METHODS
    // ==========================================

    private static void closeActivity(
        ActivityRequestBody requestBody,
        RestResponse res
    ) {
        Savepoint closeSavepoint = Database.setSavepoint();
        try {
            List<String> closeRoleNames =
                Label.Core_MDF_Close_Activity_Allowed_Roles.split(',');
            Map<String, List<String>> permissionSets =
                new Map<String, List<String>>{
                    'closeactivity' => closeRoleNames
                };
            if (!Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(
                permissionSets
            )) {
                setErrorResponse(res, 403,
                    'FORBIDDEN', '5012', 'CLOSE_PERMISSION_REQUIRED', null);
                return;
            }

            PartnerFundRequest record = fetchRecord(
                requestBody.activity_id,
                requestBody.activity_number,
                true,
                false,
                false
            );

            if (record == null) {
                setErrorResponse(res, 404,
                    'RECORD_NOT_FOUND', '5007', 'ACTIVITY_NOT_FOUND', null);
                return;
            }
            if (record.Core_MDF_Fund_Request_Status__c == STATUS_CLOSED) {
                setErrorResponse(res, 409,
                    'ALREADY_CLOSED', '5008',
                    'ACTIVITY_ALREADY_CLOSED', null);
                return;
            }
            if (!isCloseStatusAllowed(record)) {
                setErrorResponse(
                    res,
                    500,
                    'DML_ERROR',
                    '5017',
                    'CLOSE_STATUS_NOT_ALLOWED',
                    String.isBlank(record.Core_MDF_Fund_Request_Status__c)
                        ? 'Unknown'
                        : record.Core_MDF_Fund_Request_Status__c
                );
                return;
            }
            if (record.Core_MDF_Start_Date__c > Date.today()) {
                setErrorResponse(
                    res,
                    409,
                    'INVALID_STATUS_TRANSITION',
                    '5019',
                    'CLOSE_ACTIVITY_NOT_STARTED',
                    null
                );
                return;
            }
            Core_MDF_CloseActivity.activityCloseWrapper claimCheck =
                Core_MDF_CloseActivity.checkClaims(record.Id);
            if (claimCheck.hasActiveClaims) {
                setErrorResponse(
                    res,
                    409,
                    'INVALID_STATUS_TRANSITION',
                    '5020',
                    'CLOSE_ACTIVITY_ACTIVE_CLAIMS',
                    String.valueOf(claimCheck.listOfClaim.size())
                );
                return;
            }

            appendComment(record, requestBody.Comments, 'Close');

            Map<Id, PartnerFundRequest> activitiesToClose =
                new Map<Id, PartnerFundRequest>{ record.Id => record };
            String manualClosureType = Core_MDF_CustomLabelConfig.getTextValues(
                'Core_MDF_ActvityClosureType'
            ).split(';')[0];
            List<Database.SaveResult> closeResults =
                Core_MDF_CloseActivity.closeActivityAmountCalculation(
                    activitiesToClose, manualClosureType
                );

            for (Database.SaveResult closeResult : closeResults) {
                if (!closeResult.isSuccess()) {
                    Database.Error closeError = closeResult.getErrors()[0];
                    Database.rollback(closeSavepoint);
                    setErrorResponse(res, 500,
                        'DML_ERROR', '5009', 'CLOSE_DML_ERROR',
                        closeError.getMessage());
                    return;
                }
            }

            if (String.isNotBlank(requestBody.Comments)) {
                update new PartnerFundRequest(
                    Id = record.Id,
                    Description = record.Description
                );
            }

            setSuccessResponse(res, 201,
                'Activity successfully closed.',
                new Map<String, String>{
                    'activityId'     => record.Id,
                    'activityNumber' => record.Core_MDF_Activity_Number__c,
                    'status'         => STATUS_CLOSED
                }
            );

        } catch (DmlException dmlEx) {
            Database.rollback(closeSavepoint);
            setErrorResponse(res, 500,
                'DML_ERROR', '5009', 'CLOSE_DML_ERROR',
                dmlEx.getDmlMessage(0));
        } catch (Exception ex) {
            Database.rollback(closeSavepoint);
            setErrorResponse(res, 500,
                'CLOSE_ERROR', '5010', 'CLOSE_FAILURE', ex.getMessage());
        }
    }

    private static void cancelActivity(
        ActivityRequestBody requestBody,
        RestResponse res
    ) {
        try {
            PartnerFundRequest record = fetchRecord(
                requestBody.activity_id,
                requestBody.activity_number,
                false,
                false,
                true
            );

            if (record == null) {
                setErrorResponse(res, 404,
                    'RECORD_NOT_FOUND', '5007', 'ACTIVITY_NOT_FOUND', null);
                return;
            }
            if (record.Core_MDF_Fund_Request_Status__c == STATUS_CANCELLED) {
                setErrorResponse(res, 409,
                    'ALREADY_CANCELLED', '5011',
                    'ACTIVITY_ALREADY_CANCELLED', null);
                return;
            }
            if (!isCancellationStatusAllowed(record)) {
                setErrorResponse(
                    res,
                    500,
                    'DML_ERROR',
                    '5018',
                    'CANCEL_STATUS_NOT_ALLOWED',
                    String.isBlank(record.Core_MDF_Fund_Request_Status__c)
                        ? 'Unknown'
                        : record.Core_MDF_Fund_Request_Status__c
                );
                return;
            }
            if (!FeatureManagement.checkPermission(
                'Core_MDF_Allowed_Permission_Set_for_Cancel_Activity'
            )) {
                setErrorResponse(res, 403,
                    'FORBIDDEN', '5012', 'CANCEL_PERMISSION_REQUIRED', null);
                return;
            }

            PartnerFundRequest cancellationUpdate = new PartnerFundRequest(
                Id = record.Id,
                Core_MDF_Fund_Request_Status__c = STATUS_CANCELLED
            );
            if (String.isNotBlank(requestBody.Comments)) {
                appendComment(record, requestBody.Comments, 'Cancel');
                cancellationUpdate.Description = record.Description;
            }
            update cancellationUpdate;

            setSuccessResponse(res, 201,
                'Activity successfully cancelled.',
                new Map<String, String>{
                    'activityId'     => record.Id,
                    'activityNumber' => record.Core_MDF_Activity_Number__c,
                    'status'         => STATUS_CANCELLED
                }
            );

        } catch (DmlException dmlEx) {
            setErrorResponse(res, 500,
                'DML_ERROR', '5013', 'CANCEL_DML_ERROR',
                dmlEx.getDmlMessage(0));
        }
        catch (Exception ex) {
            setErrorResponse(res, 500,
                'CANCEL_ERROR', '5014', 'CANCEL_FAILURE',
                ex.getMessage());
        }
        
    }

    private static void getActivityStatus(
        ActivityRequestBody requestBody,
        RestResponse res
    ) {
        if (requestBody.activity_ids != null &&
            !requestBody.activity_ids.isEmpty()) {
            getMultipleActivityStatusByIds(requestBody.activity_ids, res);
            return;
        }
        if (requestBody.activity_numbers != null &&
            !requestBody.activity_numbers.isEmpty()) {
            getMultipleActivityStatusByNumbers(
                requestBody.activity_numbers, res
            );
            return;
        }

        PartnerFundRequest record = fetchRecord(
            requestBody.activity_id,
            requestBody.activity_number,
            false,
                true,
                false
        );

        if (record == null) {
            setErrorResponse(res, 404,
                'RECORD_NOT_FOUND', '5007', 'ACTIVITY_NOT_FOUND', null);
            return;
        }

        Map<Id, List<Object>> incentiveDetailsByPfr =
            Core_MDF_ActivitySegmentMapping.getIncentiveDetailsForRequests(
                new Set<Id>{ record.Id }
            );
        Map<Id, List<Object>> ecosystemAllocationsByPfr =
                Core_MDF_Ecosystem_Partner_Handler.getAllocations(
                new Set<Id>{ record.Id }
            );
        Map<Id, List<Object>> uploadAttachmentsByPfr =
            getUploadAttachments(new Set<Id>{ record.Id });

        setActivityStatusResponse(
            res,
            record,
            ecosystemAllocationsByPfr.get(record.Id),
            incentiveDetailsByPfr.get(record.Id),
            uploadAttachmentsByPfr.get(record.Id)
        );
    }

    private static void getMultipleActivityStatusByIds(
        List<String> requestedActivityIds,
        RestResponse res
    ) {
        try {
            Set<Id> activityIds = new Set<Id>();
            for (String activityId : requestedActivityIds) {
                activityIds.add((Id) activityId);
            }

            Set<String> selectFields = getStatusSelectFields(true);
            String query =
                'SELECT ' + String.join(new List<String>(selectFields), ', ') +
                ' FROM PartnerFundRequest WHERE Id IN :activityIds';
            List<PartnerFundRequest> records = Database.query(query);
            Map<String, PartnerFundRequest> recordsByIdentifier =
                new Map<String, PartnerFundRequest>();
            for (PartnerFundRequest record : records) {
                recordsByIdentifier.put(String.valueOf(record.Id), record);
            }
            setMultipleActivityStatusResponse(
                requestedActivityIds,
                recordsByIdentifier,
                'activityId',
                res
            );
        } catch (Exception ex) {
            setErrorResponse(res, 500,
                'STATUS_ERROR', '5006', 'UNHANDLED_ERROR',
                ex.getMessage());
        }
    }

    private static void getMultipleActivityStatusByNumbers(
        List<String> requestedActivityNumbers,
        RestResponse res
    ) {
        try {
            Set<String> activityNumbers = new Set<String>(
                requestedActivityNumbers
            );
            Set<String> selectFields = getStatusSelectFields(true);
            selectFields.add('Core_MDF_Activity_Number__c');
            String query =
                'SELECT ' + String.join(new List<String>(selectFields), ', ') +
                ' FROM PartnerFundRequest' +
                ' WHERE Core_MDF_Activity_Number__c IN :activityNumbers';
            List<PartnerFundRequest> records = Database.query(query);

            Map<String, PartnerFundRequest> recordsByIdentifier =
                new Map<String, PartnerFundRequest>();
            for (PartnerFundRequest record : records) {
                recordsByIdentifier.put(
                    record.Core_MDF_Activity_Number__c,
                    record
                );
            }
            setMultipleActivityStatusResponse(
                requestedActivityNumbers,
                recordsByIdentifier,
                'activityNumber',
                res
            );
        } catch (Exception ex) {
            setErrorResponse(res, 500,
                'STATUS_ERROR', '5006', 'UNHANDLED_ERROR',
                ex.getMessage());
        }
    }

    private static void setMultipleActivityStatusResponse(
        List<String> requestedIdentifiers,
        Map<String, PartnerFundRequest> recordsByIdentifier,
        String identifierField,
        RestResponse res
    ) {
        Set<Id> activityIds = new Set<Id>();
        for (PartnerFundRequest record : recordsByIdentifier.values()) {
            activityIds.add(record.Id);
        }
        Map<Id, List<Object>> incentiveDetailsByPfr =
            Core_MDF_ActivitySegmentMapping.getIncentiveDetailsForRequests(
                activityIds
            );
        Map<Id, List<Object>> ecosystemAllocationsByPfr =
                Core_MDF_Ecosystem_Partner_Handler.getAllocations(
                activityIds
            );
        Map<Id, List<Object>> uploadAttachmentsByPfr =
            getUploadAttachments(activityIds);

        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        generator.writeBooleanField('success', true);
        generator.writeStringField(
            'message', 'Activity details retrieved successfully.'
        );
        generator.writeNullField('errorCode');
        generator.writeFieldName('data');
        generator.writeStartObject();
        generator.writeFieldName('activities');
        generator.writeStartArray();

        for (String requestedIdentifier : requestedIdentifiers) {
            PartnerFundRequest record =
                recordsByIdentifier.get(requestedIdentifier);
            generator.writeStartObject();
            generator.writeStringField(identifierField, requestedIdentifier);
            generator.writeBooleanField('found', record != null);
            writeStatusSections(
                generator,
                record,
                record == null ? null : ecosystemAllocationsByPfr.get(record.Id),
                record == null ? null : incentiveDetailsByPfr.get(record.Id),
                record == null ? null : uploadAttachmentsByPfr.get(record.Id)
            );
            generator.writeEndObject();
        }

        generator.writeEndArray();
        generator.writeEndObject();
        generator.writeEndObject();
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(generator.getAsString());
    }

    private static void setActivityStatusResponse(
        RestResponse res,
        PartnerFundRequest record,
        List<Object> ecosystemAllocations,
        List<Object> incentiveDetails,
        List<Object> uploadAttachments
    ) {
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        generator.writeBooleanField('success', true);
        generator.writeStringField(
            'message', 'Activity details retrieved successfully.'
        );
        generator.writeNullField('errorCode');
        generator.writeFieldName('data');
        generator.writeStartObject();
        writeStatusSections(
            generator,
            record,
            ecosystemAllocations,
            incentiveDetails,
            uploadAttachments
        );
        generator.writeEndObject();
        generator.writeEndObject();
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(generator.getAsString());
    }

    private static void writeStatusSections(
        JSONGenerator generator,
        PartnerFundRequest record,
        List<Object> ecosystemAllocations,
        List<Object> incentiveDetails,
        List<Object> uploadAttachments
    ) {
        if (record == null) {
            generator.writeNullField('ActivityDetails');
            generator.writeNullField('ClaimDetails');
            generator.writeNullField('SystemInformation');
            generator.writeNullField('IncentiveInformation');
            generator.writeNullField('Metrics');
            generator.writeNullField('EcosystemPartnerPercentageAllocation');
            generator.writeNullField('UploadAttachment');
            return;
        }

        generator.writeObjectField(
            'ActivityDetails', buildDisplayFields(record)
        );
        generator.writeObjectField('ClaimDetails', buildClaimDetails(record));
        generator.writeObjectField(
            'SystemInformation', buildSystemInformation(record)
        );
        writeIncentiveInformation(generator, incentiveDetails);
        generator.writeObjectField('Metrics', buildMetrics(record));
        generator.writeObjectField(
            'EcosystemPartnerPercentageAllocation', ecosystemAllocations
        );
        generator.writeObjectField('UploadAttachment', uploadAttachments);
    }

    @TestVisible
    private static void writeIncentiveInformation(
        JSONGenerator generator,
        List<Object> incentiveDetails
    ) {
        if (incentiveDetails == null) {
            generator.writeNullField('IncentiveInformation');
            return;
        }

        generator.writeFieldName('IncentiveInformation');
        generator.writeStartArray();
        for (Object incentive : incentiveDetails) {
            Map<String, Object> fields = (Map<String, Object>) incentive;
            generator.writeStartObject();
            for (String fieldName : new List<String>{
                'Products', 'Segment', 'Minimum Forecast Volume', 'Incentive Amount $/U',
                'Maximum Bundled Volume', 'Maximum Cost of Bundle',
                'Estimated Share of Incentive'
            }) {
                generator.writeObjectField(fieldName, fields.get(fieldName));
            }
            generator.writeEndObject();
        }
        generator.writeEndArray();
    }

    // ==========================================
    // DYNAMIC LABEL FIELD METHODS
    // ==========================================

    /**
     * @description Parse comma-separated SObject field API names
     *              directly from Custom Label
     *              Label Value:
     *              "Id,Core_MDF_Activity_Number__c,
     *               Core_MDF_Start_Date__c,
     *               Core_MDF_Fund_Request_Status__c"
     */
    private static List<String> parseFieldsFromLabel() {
        return parseFieldsFromLabel(true);
    }

    private static List<String> parseFieldsFromLabel(
        Boolean includeAdditionalFields
    ) {
        List<String> fields = new List<String>();

        List<String> labelValues = new List<String>{ DISPLAY_FIELDS_LABEL };
        if (includeAdditionalFields) {
            labelValues.add(ADDITIONAL_DISPLAY_FIELDS_LABEL);
        }

        for (String labelValue : labelValues) {
            if (String.isBlank(labelValue)) continue;

            for (String field : labelValue.split(',')) {
                String trimmed = field.trim();
                if (String.isNotBlank(trimmed)) {
                    fields.add(trimmed);
                }
            }
        }
        return fields;
    }

    /**
     * @description Dynamically build displayFields from SObject record
     *              Iterates label field API names directly
     *              Reads value from SObject using record.get(fieldApiName)
     *              Gets UI label from Schema describe
     *              Key   → Schema Field Label  (e.g., "Activity Number")
     *              Value → SObject field value (e.g., "ACT-0001")
     */
    private static Map<String, String> buildDisplayFields(
        SObject record
    ) {
        return buildDisplayFields(record, parseFieldsFromLabel());
    }

    private static Map<String, String> buildSystemInformation(
        SObject record
    ) {
        Map<String, String> systemInformation = new Map<String, String>();
        Map<String, Schema.SObjectField> schemaFieldMap =
            Schema.SObjectType.PartnerFundRequest.fields.getMap();
        String intelSystemUser = Core_MDF_CustomLabelConfig.getTextValues(
            'Core_MDF_Intel_System_User'
        );
        Map<String, String> fallbackRelationships = new Map<String, String>{
            'Core_MDF_Owner_nm__c' => 'Owner',
            'Core_MDF_CreatedBy__c' => 'CreatedBy',
            'Core_MDF_Last_Modified_By_nm__c' => 'LastModifiedBy'
        };

        for (String fieldApiName : getSystemInformationFieldNames()) {
            Schema.SObjectField fieldToken =
                schemaFieldMap.get(fieldApiName.toLowerCase());
            if (fieldToken == null) {
                continue;
            }

            Object rawValue = record.get(fieldApiName);
            String displayValue = rawValue == null
                ? ''
                : String.valueOf(rawValue);
            if (displayValue == intelSystemUser) {
                SObject relatedRecord = record.getSObject(
                    fallbackRelationships.get(fieldApiName)
                );
                Object relatedName = relatedRecord == null
                    ? null
                    : relatedRecord.get('Name');
                if (relatedName != null) {
                    displayValue = String.valueOf(relatedName);
                }
            }
            systemInformation.put(
                fieldToken.getDescribe().getLabel(),
                displayValue
            );
        }
        return systemInformation;
    }

    private static Map<String, String> buildDisplayFields(
        SObject record,
        List<String> fieldApiNames
    ) {
        Map<String, String> displayFields = new Map<String, String>();

        // ✅ Get Schema field map for PartnerFundRequest
        Map<String, Schema.SObjectField> schemaFieldMap =
            Schema.SObjectType.PartnerFundRequest.fields.getMap();

        // ✅ Iterate each field API name from Custom Label
        for (String fieldApiName : fieldApiNames) {

            // ✅ Check field exists on SObject via Schema
            if (!schemaFieldMap.containsKey(fieldApiName.toLowerCase())) {
                continue;
            }

            Schema.DescribeFieldResult fieldDescribe = schemaFieldMap
                .get(fieldApiName.toLowerCase())
                .getDescribe();
            String uiLabel = fieldDescribe.getLabel();

            String relationshipName = getNameRelationshipName(fieldDescribe);
            Object rawValue;
            if (String.isNotBlank(relationshipName)) {
                SObject relatedRecord = record.getSObject(relationshipName);
                rawValue = relatedRecord == null
                    ? null
                    : relatedRecord.get('Name');
            } else {
                rawValue = record.get(fieldApiName);
            }
            String displayValue = '';

            if (rawValue instanceof DateTime) {
                displayValue = ((DateTime) rawValue).formatGmt('M/d/yyyy');
            } else if (rawValue instanceof Date) {
                displayValue = DateTime.newInstance(
                    (Date) rawValue,
                    Time.newInstance(0, 0, 0, 0)
                ).format('M/d/yyyy');
            } else if (rawValue != null) {
                displayValue = String.valueOf(rawValue);
            }

            // ✅ UI Label → Value
            displayFields.put(uiLabel, displayValue);
        }

        return displayFields;
    }

    private static List<String> getSystemInformationFieldNames() {
        return new List<String>{
            'Core_MDF_Owner_nm__c',
            'Core_MDF_CreatedBy__c',
            'Core_MDF_Last_Modified_By_nm__c'
        };
    }

    private static Map<String, Object> buildClaimDetails(SObject record) {
        Map<String, Object> claimDetails = new Map<String, Object>();
        claimDetails.put(
            Schema.SObjectType.PartnerFundRequest.fields.TotalApprovedFcs
                .getLabel(),
            record.get('TotalApprovedFcs')
        );
        claimDetails.put(
            Schema.SObjectType.PartnerFundRequest.fields.TotalReimbursedFcs
                .getLabel(),
            record.get('TotalReimbursedFcs')
        );
        return claimDetails;
    }

    private static Map<String, Object> buildMetrics(SObject record) {
        Map<String, Object> metrics = new Map<String, Object>();
        Object potentialWinners =
            record.get('Core_MDF_Num_of_Potential_Winners_nbr__c');
        Object expectedParticipants =
            record.get('Core_MDF_No_of_Expected_Participants_nbr__c');

        metrics.put(
            Schema.SObjectType.PartnerFundRequest.fields
                .Core_MDF_Num_of_Potential_Winners_nbr__c.getLabel(),
            potentialWinners == null ? '' : potentialWinners
        );
        metrics.put(
            Schema.SObjectType.PartnerFundRequest.fields
                .Core_MDF_No_of_Expected_Participants_nbr__c.getLabel(),
            expectedParticipants == null ? '' : expectedParticipants
        );
        return metrics;
    }

    private static Map<Id, List<Object>> getUploadAttachments(
        Set<Id> activityIds
    ) {
        Map<Id, List<Object>> attachmentsByActivityId =
            new Map<Id, List<Object>>();
        if (activityIds == null || activityIds.isEmpty()) {
            return attachmentsByActivityId;
        }

        for (Id activityId : activityIds) {
            attachmentsByActivityId.put(activityId, new List<Object>());
        }

        String downloadBaseUrl = UserInfo.getUserType() == 'PowerPartner'
            ? System.Label.Core_MDF_PFRCommunityLink +
                'sfc/servlet.shepherd/document/download/'
            : '/sfc/servlet.shepherd/document/download/';

        for (ContentDocumentLink documentLink : [
            SELECT LinkedEntityId, ContentDocumentId,
                ContentDocument.Title, ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :activityIds
            ORDER BY ContentDocument.Title
        ]) {
            attachmentsByActivityId.get(documentLink.LinkedEntityId).add(
                new Map<String, Object>{
                    'Title' => documentLink.ContentDocument.Title + '.' +
                        documentLink.ContentDocument.FileExtension,
                    'ContentDocumentId' => documentLink.ContentDocumentId,
                    'docurl' => downloadBaseUrl +
                        documentLink.ContentDocumentId +
                        '?operationContext=S1'
                }
            );
        }
        return attachmentsByActivityId;
    }

    private static String getNameRelationshipName(
        Schema.DescribeFieldResult fieldDescribe
    ) {
        if (fieldDescribe.getType() != Schema.DisplayType.Reference) {
            return null;
        }

        String relationshipName = fieldDescribe.getRelationshipName();
        List<Schema.SObjectType> referenceTypes = fieldDescribe.getReferenceTo();
        if (String.isBlank(relationshipName) || referenceTypes.isEmpty()) {
            return null;
        }

        for (Schema.SObjectType referenceType : referenceTypes) {
            if (!referenceType.getDescribe().fields.getMap().containsKey('name')) {
                return null;
            }
        }

        return relationshipName;
    }

    // ==========================================
    // HELPER METHODS
    // ==========================================

    /**
     * @description Fetch record - SOQL fields built
     *              dynamically from Custom Label
     */
    private static PartnerFundRequest fetchRecord(
        String activityId,
        String activityNumber,
        Boolean includeClosureFields,
        Boolean includeSystemInformationFields,
        Boolean includeCancellationFields
    ) {
        try {
            Set<String> selectFields = getStatusSelectFields(
                includeSystemInformationFields
            );
            selectFields.add('Core_MDF_Activity_Number__c');

            if (includeClosureFields) {
                selectFields.addAll(new Set<String>{
                    'Core_MDF_Budget_Type_nm__c', 'Core_MDF_Program__c',
                    'Core_MDF_Activity_Reimbursement_Amt_nbr__c',
                    'Core_MDF_ToBeClosedDate__c',
                    'Core_MDF_Is_Outcome_Based_Ind__c',
                    'Core_MDF_Start_Date__c'
                });
            }
            if (includeCancellationFields) {
                selectFields.addAll(new Set<String>{
                    'Core_MDF_Program__c'
                });
            }

            String whereClause = String.isNotBlank(activityId)
                ? 'Id = \'' + String.escapeSingleQuotes(activityId) + '\''
                : 'Core_MDF_Activity_Number__c = \'' +
                  String.escapeSingleQuotes(activityNumber) + '\'';

            String query =
                'SELECT ' +
                String.join(new List<String>(selectFields), ', ') +
                ' FROM PartnerFundRequest' +
                ' WHERE ' + whereClause +
                ' LIMIT 1';

            List<PartnerFundRequest> records = Database.query(query);
            return records.isEmpty() ? null : records[0];

        } catch (Exception ex) {
            throw ex;
        }
    }

    private static Set<String> getStatusSelectFields(
        Boolean includeSystemInformationFields
    ) {
        Set<String> selectFields = new Set<String>{
            'Id', 'Core_MDF_Fund_Request_Status__c', 'Description'
        };
        List<String> fieldsWithRelationships = parseFieldsFromLabel(
            includeSystemInformationFields
        );
        if (includeSystemInformationFields) {
            selectFields.addAll(new Set<String>{
                'TotalApprovedFcs', 'TotalReimbursedFcs'
            });
            selectFields.addAll(new Set<String>{
                'Owner.Name', 'CreatedBy.Name', 'LastModifiedBy.Name'
            });
            List<String> systemInformationFields =
                getSystemInformationFieldNames();
            fieldsWithRelationships.addAll(systemInformationFields);
            selectFields.addAll(new Set<String>{
                'Core_MDF_Num_of_Potential_Winners_nbr__c',
                'Core_MDF_No_of_Expected_Participants_nbr__c'
            });
        }

        Map<String, Schema.SObjectField> schemaFieldMap =
            Schema.SObjectType.PartnerFundRequest.fields.getMap();
        for (String fieldApiName : fieldsWithRelationships) {
            Schema.SObjectField fieldToken =
                schemaFieldMap.get(fieldApiName.toLowerCase());
            if (fieldToken == null) {
                continue;
            }
            selectFields.add(fieldApiName);
            String relationshipName = getNameRelationshipName(
                fieldToken.getDescribe()
            );
            if (String.isNotBlank(relationshipName)) {
                selectFields.add(relationshipName + '.Name');
            }
        }
        return selectFields;
    }

    private static Boolean isCloseStatusAllowed(PartnerFundRequest record) {
        Set<String> disallowedStatuses = new Set<String>(
            Label.Core_MDF_Close_Activity_NotAllowed_ActStatus.split(',')
        );
        return !disallowedStatuses.contains(
            record.Core_MDF_Fund_Request_Status__c
        );
    }

    private static Boolean isCancellationStatusAllowed(
        PartnerFundRequest record
    ) {
        String status = record.Core_MDF_Fund_Request_Status__c;
        return status == Label.Core_MDF_pfrInprogress ||
            status == STATUS_CLOSED ||
            (status == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS &&
                CCF_DCF_PROGRAMS.contains(record.Core_MDF_Program__c)) ||
            (status == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS &&
                CCF_DCF_PROGRAMS.contains(
                    record.Core_MDF_Program__c
                ));
    }

    private static void appendComment(
        PartnerFundRequest record,
        String comments,
        String actionType
    ) {
        if (String.isNotBlank(comments)) {
            record.Description =
                (String.isNotBlank(record.Description)
                    ? record.Description : '') +
                '\n[' + actionType + ' Comment]: ' + comments;
        }
    }

    private static String extractActionFromURL(String requestURI) {
        if (String.isBlank(requestURI)) return null;
        List<String> parts = requestURI.split('/');
        return parts.isEmpty()
               ? null
               : parts[parts.size() - 1].toLowerCase();
    }

    private static Boolean isValidAction(String action) {
        return action == 'close'  ||
               action == 'cancel' ||
               action == 'status';
    }

    private static ActivityRequestBody parseRequestBody(Blob body) {
        if (body == null || body.size() == 0) return null;
        try {
            return (ActivityRequestBody) JSON.deserialize(
                body.toString(), ActivityRequestBody.class
            );
        } catch (Exception ex) {
            return null;
        }
    }

    private static String validateRequest(ActivityRequestBody req) {
        Boolean hasNumber = String.isNotBlank(req.activity_number);
        Boolean hasId     = String.isNotBlank(req.activity_id);
        Boolean hasIds    = req.activity_ids != null &&
            !req.activity_ids.isEmpty();
        Boolean hasNumbers = req.activity_numbers != null &&
            !req.activity_numbers.isEmpty();

        if (!hasNumber && !hasId && !hasIds && !hasNumbers) {
            return 'VALIDATION_MISSING_IDENTIFIER';
        }
        if ((hasNumber && hasId) ||
            (hasIds && (hasNumber || hasId || hasNumbers)) ||
            (hasNumbers && (hasNumber || hasId))) {
            return 'VALIDATION_BOTH_IDENTIFIERS';
        }
        if (hasId && req.activity_id.length() != 18) {
            return 'VALIDATION_INVALID_ACTIVITY_ID';
        }
        if (hasIds) {
            for (String activityId : req.activity_ids) {
                if (String.isBlank(activityId) || activityId.length() != 18) {
                    return 'VALIDATION_INVALID_ACTIVITY_ID';
                }
                try {
                    Id.valueOf(activityId);
                } catch (Exception ex) {
                    return 'VALIDATION_INVALID_ACTIVITY_ID';
                }
            }
        }
        if (hasNumbers) {
            for (String activityNumber : req.activity_numbers) {
                if (String.isBlank(activityNumber)) {
                    return 'VALIDATION_MISSING_IDENTIFIER';
                }
            }
        }
        return null;
    }

    private static String getDuplicateIdentifierDetails(
        ActivityRequestBody req
    ) {
        List<String> duplicateMessages = new List<String>();
        List<String> duplicateIds = findDuplicateValues(req.activity_ids);
        List<String> duplicateNumbers = findDuplicateValues(
            req.activity_numbers
        );

        if (!duplicateIds.isEmpty()) {
            duplicateMessages.add(
                'activity IDs: ' + String.join(duplicateIds, ', ')
            );
        }
        if (!duplicateNumbers.isEmpty()) {
            duplicateMessages.add(
                'activity numbers: ' + String.join(duplicateNumbers, ', ')
            );
        }

        return duplicateMessages.isEmpty()
            ? null
                        : String.join(duplicateMessages, '; ');
    }

    private static List<String> findDuplicateValues(List<String> values) {
        List<String> duplicates = new List<String>();
        if (values == null) return duplicates;

        Set<String> seen = new Set<String>();
        Set<String> duplicateSet = new Set<String>();
        for (String value : values) {
            if (seen.contains(value) && !duplicateSet.contains(value)) {
                duplicates.add(value);
                duplicateSet.add(value);
            } else {
                seen.add(value);
            }
        }
        return duplicates;
    }

    private static String getValidationSettingCode(String validationContext) {
        switch on validationContext {
            when 'VALIDATION_MISSING_IDENTIFIER' { return '5003'; }
            when 'VALIDATION_BOTH_IDENTIFIERS' { return '5004'; }
            when 'VALIDATION_INVALID_ACTIVITY_ID' { return '5005'; }
            when else { return null; }
        }
    }

    private static void setSuccessResponse(
        RestResponse res, Integer statusCode,
        String message,   Object data
    ) {
        res.statusCode   = 200;
        ActivityResponse response =
            new ActivityResponse(true, message, null, data);
        response.Code = String.valueOf(statusCode);
        res.responseBody = Blob.valueOf(serializeResponse(response));
    }

    private static void setErrorResponse(
        RestResponse res, Integer statusCode,
        String errorCode, String settingCode, String contextKey, String detail
    ) {
        res.statusCode   = statusCode;
        String message = resolveErrorMessage(settingCode, contextKey, detail);
        String responseCode = String.isNotBlank(settingCode)
            ? settingCode
            : errorCode;
        Integer numericErrorCode;
        try {
            numericErrorCode = Integer.valueOf(responseCode);
        } catch (Exception ex) {
            numericErrorCode = null;
        }
        ActivityResponse response =
            new ActivityResponse(false, message, numericErrorCode, null);
        response.Code = '401';
        res.responseBody = Blob.valueOf(serializeResponse(response));
    }

    private static String serializeResponse(ActivityResponse response) {
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        generator.writeBooleanField('success', response.success);
        if (response.Code == null) {
            generator.writeNullField('Code');
        } else {
            generator.writeStringField('Code', response.Code);
        }
        if (response.message == null) {
            generator.writeNullField('message');
        } else {
            generator.writeStringField('message', response.message);
        }
        if (response.errorCode == null) {
            generator.writeNullField('errorCode');
        } else {
            generator.writeNumberField('errorCode', response.errorCode);
        }
        generator.writeFieldName('data');
        if (response.data == null) {
            generator.writeNull();
        } else {
            generator.writeObject(response.data);
        }
        generator.writeEndObject();
        return generator.getAsString();
    }

    private static void setErrorResponseWithMessage(
        RestResponse res,
        Integer statusCode,
        Integer errorCode,
        String message
    ) {
        res.statusCode = statusCode;
        ActivityResponse response =
            new ActivityResponse(false, message, errorCode, null);
        response.Code = '401';
        res.responseBody = Blob.valueOf(serializeResponse(response));
    }

    private static String resolveErrorMessage(
        String settingCode, String contextKey, String detail
    ) {
        try {
            List<Core_MDF_External_API_Response_Codes__c> settings = [
                SELECT Core_Message__c
                FROM Core_MDF_External_API_Response_Codes__c
                WHERE Core_Category__c = :ERROR_RESPONSE_CATEGORY
                    AND Core_Code__c = :settingCode
                    AND Core_Context_of_Error__c = :contextKey
                LIMIT 1
            ];

            if (!settings.isEmpty() &&
                String.isNotBlank(settings[0].Core_Message__c)) {
                String configuredMessage = settings[0].Core_Message__c;
                Boolean isLabelReference = configuredMessage.startsWith('@Label:');
                if (isLabelReference) {
                    String labelName = configuredMessage.substring(7);
                    if (String.isBlank(labelName)) {
                        return System.Label.Core_MDF_ApplicationErrorMessage;
                    }
                    configuredMessage = System.Label.get('', labelName);
                    if (String.isBlank(configuredMessage)) {
                        return System.Label.Core_MDF_ApplicationErrorMessage;
                    }
                }
                if (configuredMessage.contains('{value}')) {
                    configuredMessage = configuredMessage.replace(
                        '{value}', String.isBlank(detail) ? '' : detail
                    );
                }
                if (isLabelReference && configuredMessage.contains('{0}')) {
                    configuredMessage = configuredMessage.replace(
                        '{0}', String.isBlank(detail) ? '' : detail
                    );
                }
                if (isLabelReference) {
                    while (configuredMessage.contains('  ')) {
                        configuredMessage = configuredMessage.replace('  ', ' ');
                    }
                }
                return configuredMessage;
            }
        } catch (Exception ex) {
        }

        return System.Label.Core_MDF_ApplicationErrorMessage;
    }
}