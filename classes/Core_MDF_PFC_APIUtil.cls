/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_APIUtil
 * Author          : <YourName>
 * Created Date    : May 21, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 21, 2026
 * Description     : This class implements for helper functions of claim creation API
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 21, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class Core_MDF_PFC_APIUtil {
    /** Transaction-scoped cache: fieldApiName → ordered list of active picklist values. */
    private static final Map<String, List<String>> picklistCache = new Map<String, List<String>>();
    // Backward-compatible alias used by older compiled references during rollback.
    private static final String CODE_8030_INVALID_CLAIM_SUBMITTER_ID = Core_MDF_PFC_RestAPIConstants.CODE_8030_INVALID_CLAIM_SUBMITTER_ID;

    /***************************************************************************************************** 
    Method Name:        getRequestParam
    @return  :          String
    @parameters:        String paramName
    Description:        This method retrieves a specific parameter value from the incoming
                        REST API request URL parameters.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/
    public static String getRequestParam(String paramName) {
        try {
            RestRequest request = RestContext.request;
            if (request != null && request.params != null) {
                return request.params.get(paramName);
            }
            return null;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return Core_MDF_PFC_RestAPIConstants.EMPTY_STRING; }
    }

    /*****************************************************************************************************************************************
    Method Name             : buildErrorResponseFromCode
    Description             : Builds and returns a standardized API error response using the supplied error code.
                              Retrieves the corresponding error message from the configured error definitions
                              and populates the response object with failure status, error code, and message.
    @Added By               :

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/ 
    public static Core_MDF_PFC_APIResponse buildErrorResponseFromCode(String errorCode) {
        try {
            Core_MDF_PFC_APIResponse response =  new Core_MDF_PFC_APIResponse();
            Core_MDF_RestAPI_Logger.ErrorConfig errorConfig = Core_MDF_RestAPI_Logger.getCachedErrorConfigDetails(
                errorCode,
                Core_MDF_PFC_RestAPIConstants.RESPONSE_CODE_CATEGORY_CLAIM
            );

            String resolvedCode = (errorConfig != null && String.isNotBlank(errorConfig.code))
                ? errorConfig.code
                : errorCode;
            String resolvedMessage = (errorConfig != null && String.isNotBlank(errorConfig.message))
                ? errorConfig.message
                : getApplicationErrorMessage();
            Integer resolvedHttpStatusCode = (errorConfig != null && errorConfig.httpStatusCode != null)
                ? errorConfig.httpStatusCode
                : 500;

            response.setErrorInfo(resolvedMessage, resolvedCode);
            response.httpStatusCode = resolvedHttpStatusCode;
            response.details = null;
            return response;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            Core_MDF_PFC_APIResponse fallbackResponse = new Core_MDF_PFC_APIResponse();
            fallbackResponse.setErrorInfo(
                getApplicationErrorMessage(),
                Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR
            );
            fallbackResponse.httpStatusCode = 500;
            fallbackResponse.details = null;
            return fallbackResponse;
        }
    }
    /*****************************************************************************************************************************************
    Method Name             : getErrorDetails
    Description             : Retrieves the error details associated with the supplied error code.
                              Returns a map containing the predefined error message and any additional
                              error-related information configured for the specified error code.
    @Added By               :

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/
    public static Map<String, Object> getErrorDetails(String errorCode) {
        try {
            Core_MDF_RestAPI_Logger.ErrorConfig errorConfig = Core_MDF_RestAPI_Logger.getCachedErrorConfigDetails(
                errorCode,
                Core_MDF_PFC_RestAPIConstants.RESPONSE_CODE_CATEGORY_CLAIM
            );

            Map<String, Object> details = new Map<String, Object>();
            details.put(
                Core_MDF_PFC_RestAPIConstants.KEY_MESSAGE,
                (errorConfig != null && String.isNotBlank(errorConfig.message))
                    ? errorConfig.message
                    : getApplicationErrorMessage()
            );
            return details;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return new Map<String, Object>{ Core_MDF_PFC_RestAPIConstants.KEY_MESSAGE => getApplicationErrorMessage() };
        }
    }

    /*****************************************************************************************************************************************
    Method Name             : validateClaims
    Description             : Validates all incoming claim payload records including mandatory fields, dates, numeric values, and claim submitter Id validations.
    @Added By               :

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/
    public static ValidationResult validateClaims(List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claimsPayload, Boolean isLateClaimRequest) {
        try {
            ValidationResult validationResult =  new ValidationResult();
            List<ClaimProcessingResult> results =  new List<ClaimProcessingResult>();
            Map<Integer, Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrapperByIndex = new Map<Integer, Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput>();
            Set<String> activityNumbersForCountryHint = new Set<String>();
            Set<Id> activityIdsForCountryHint = new Set<Id>();
            Map<String, Id> claimSubmitterByInput = resolveClaimSubmitters(claimsPayload);
            for (Integer i = 0; i < claimsPayload.size(); i++) {
                ClaimProcessingResult itemResult =  new ClaimProcessingResult();
                itemResult.index = i;
                try {
                    Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw = claimsPayload[i];
                    if (cw == null) {
                        throw new IllegalArgumentException(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE));
                    }
                    List<String> fieldErrors =   new List<String>();
                    List<String> fieldErrorCodes = new List<String>();
                    Boolean lateClaimEscalationMissing = false;
                    String activityNumberInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER);
                    String claimCountryInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY);
                    String escalationIdInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ESCALATION_ID);
                    String normalizedClaimType = normalizeClaimType(cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_TYPE));
                    if (String.isBlank(normalizedClaimType)) {
                        fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8039_INVALID_CLAIM_TYPE));
                        fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8039_INVALID_CLAIM_TYPE);
                    } else if (normalizedClaimType != Core_MDF_PFC_RestAPIConstants.CLAIM_TYPE_NORMAL && normalizedClaimType != Core_MDF_PFC_RestAPIConstants.CLAIM_TYPE_LATE) {
                        fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8039_INVALID_CLAIM_TYPE));
                        fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8039_INVALID_CLAIM_TYPE);
                    }

                    String rawClaimSubmitter = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_SUBMITTER);
                    if (String.isNotBlank(rawClaimSubmitter)) {
                        if (claimSubmitterByInput.containsKey(rawClaimSubmitter)) {
                            cw.setValue(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_SUBMITTER, String.valueOf(claimSubmitterByInput.get(rawClaimSubmitter)));
                        } else {
                            fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8030_INVALID_CLAIM_SUBMITTER_ID));
                            fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8030_INVALID_CLAIM_SUBMITTER_ID);
                        }
                    }

                    lateClaimEscalationMissing = addLateClaimEscalationError(cw, fieldErrors, normalizedClaimType == Core_MDF_PFC_RestAPIConstants.CLAIM_TYPE_LATE);

                    wrapperByIndex.put(i, cw);
                    if (String.isNotBlank(activityNumberInput) && String.isNotBlank(claimCountryInput)) {
                        try {
                            activityIdsForCountryHint.add((Id) activityNumberInput);
                        } catch (Exception ex) {
                            activityNumbersForCountryHint.add(activityNumberInput);
                        }
                    }

                    // Required/format rules come from Core_MDF_Custom_Layout_Configurations__c, not from code.
                    addConfiguredFieldErrors(
                        cw,
                        Core_MDF_PFC_RestAPI_InputWrapper.getAllClaimFieldConfigs(),
                        fieldErrors,
                        fieldErrorCodes,
                        new Set<String>{Core_MDF_PFC_RestAPIConstants.FIELD_BANK_SUPPLIER_NUMBER}
                    );

                    if (String.isNotBlank(escalationIdInput)) {
                        try {
                            Id escalationRecordId = (Id) escalationIdInput;
                        } catch (Exception ex) {
                            fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8024_INVALID_ESCALATION_ID));
                            fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8024_INVALID_ESCALATION_ID);
                        }
                    }

                    // Attachments are always mandatory; the nested array cannot be expressed as a layout configuration field.
                    if (cw.documents == null || cw.documents.isEmpty()) {
                        fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8043_DOCUMENTS_REQUIRED));
                        fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8043_DOCUMENTS_REQUIRED);
                    } else {
                        for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimDocumentInput documentItem : cw.documents) {
                            if (documentItem == null) {
                                fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT));
                                fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT);
                                continue;
                            }

                            if (String.isBlank(documentItem.fileContent)) {
                                fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT));
                                fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT);
                                continue;
                            }
                            if (String.isBlank(documentItem.fileName)) {
                                fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8034_INVALID_FILE_NAME));
                                fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8034_INVALID_FILE_NAME);
                                continue;
                            }
                            if (String.isBlank(documentItem.documentType)) {
                                fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8036_DOCUMENT_TYPE_REQUIRED));
                                fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8036_DOCUMENT_TYPE_REQUIRED);
                                continue;
                            }
                            try {
                                EncodingUtil.base64Decode(normalizeBase64Payload(documentItem.fileContent));
                            } catch (Exception ex) {
                                fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT));
                                fieldErrorCodes.add(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT);
                            }
                        }
                    }

                    // Picklist validation for every configured payload field that maps to a picklist on PartnerFundClaim
                    for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig fieldConfig : Core_MDF_PFC_RestAPI_InputWrapper.getAllClaimFieldConfigs()) {
                        String cwField = fieldConfig.payloadFieldName;
                        if (Core_MDF_PFC_RestAPIConstants.FIELD_DOCUMENTS.equalsIgnoreCase(cwField)) { continue; }
                        String submittedValue = cw.getText(cwField);
                        if (String.isBlank(submittedValue)) { continue; } // required-field errors handled above
                        List<String> allowed = getActivePicklistValues(fieldConfig.fieldApiName);
                        if (!allowed.isEmpty() && !allowed.contains(submittedValue)) {
                            fieldErrors.add(
                                Core_MDF_PFC_RestAPIConstants.MSG_INVALID_PICKLIST_VALUE_PREFIX +
                                submittedValue +
                                Core_MDF_PFC_RestAPIConstants.MSG_INVALID_PICKLIST_VALUE_MIDDLE +
                                cwField
                            );
                            if (itemResult.invalidPicklistFields == null) {
                                itemResult.invalidPicklistFields = new Map<String, List<String>>();
                            }
                            itemResult.invalidPicklistFields.put(cwField, allowed);
                        }
                    }

                    if (!fieldErrors.isEmpty()) {
                        itemResult.success = false;
                        itemResult.code = lateClaimEscalationMissing
                            ? Core_MDF_PFC_RestAPIConstants.CODE_8040_ESCALATION_ID_REQUIRED
                            : (!fieldErrorCodes.isEmpty()
                                ? fieldErrorCodes[0]
                                : Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED);
                        itemResult.message = String.join(fieldErrors, Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE);
                        validationResult.isSuccess = false;
                    } else {
                        itemResult.success = true;
                        itemResult.code = Core_MDF_PFC_RestAPIConstants.STATUS_200_SUCCESS;
                        itemResult.message = Core_MDF_PFC_RestAPIConstants.MSG_VALIDATED;
                        validationResult.validWrappers.add(cw);
                    }
                } catch (Exception ex) {
                    itemResult.success = false;
                    itemResult.code = Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE;
                    itemResult.message = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE);
                    validationResult.isSuccess = false;
                }
                results.add(itemResult);
            }

            // Add activity-scoped claimCountry hints even when rows fail earlier validations.
            if (!activityNumbersForCountryHint.isEmpty() || !activityIdsForCountryHint.isEmpty()) {
                Map<String, PartnerFundRequest> activityByNumber = new Map<String, PartnerFundRequest>();
                Map<Id, PartnerFundRequest> activityById = new Map<Id, PartnerFundRequest>();
                for (PartnerFundRequest requestRec : [
                    SELECT Id, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c
                    FROM PartnerFundRequest
                    WHERE Core_MDF_Activity_Number__c IN :activityNumbersForCountryHint
                        OR Id IN :activityIdsForCountryHint
                ]) {
                    activityByNumber.put(requestRec.Core_MDF_Activity_Number__c, requestRec);
                    activityById.put(requestRec.Id, requestRec);
                }

                for (ClaimProcessingResult rowResult : results) {
                    Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput rowWrapper = wrapperByIndex.get(rowResult.index);
                    String rowActivityNumber = rowWrapper == null ? null : rowWrapper.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER);
                    String rowClaimCountry = rowWrapper == null ? null : rowWrapper.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY);
                    if (rowWrapper == null || String.isBlank(rowActivityNumber) || String.isBlank(rowClaimCountry)) {
                        continue;
                    }

                    PartnerFundRequest matchedActivity = null;
                    try {
                        matchedActivity = activityById.get((Id) rowActivityNumber);
                    } catch (Exception ex) {
                        matchedActivity = activityByNumber.get(rowActivityNumber);
                    }
                    if (matchedActivity == null) {
                        matchedActivity = activityByNumber.get(rowActivityNumber);
                    }
                    if (matchedActivity == null) {
                        continue;
                    }

                    List<String> allowedCountriesForActivity = getAllowedActivityCountries(matchedActivity.Core_MDF_Country_nm__c);
                    if (allowedCountriesForActivity.isEmpty()) {
                        continue;
                    }

                    if (!isCountryInAllowedList(rowClaimCountry, allowedCountriesForActivity)) {
                        if (rowResult.invalidPicklistFields == null) {
                            rowResult.invalidPicklistFields = new Map<String, List<String>>();
                        }
                        rowResult.invalidPicklistFields.put(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY, allowedCountriesForActivity);
                    }
                }
            }

            if (!validationResult.isSuccess) {
                Core_MDF_PFC_APIResponse response =  new Core_MDF_PFC_APIResponse();
                List<String> validationMessages =  new List<String>();
                List<Core_MDF_PFC_APIResult> apiResults = new List<Core_MDF_PFC_APIResult>();
                for (ClaimProcessingResult r : results) {
                    if (r.success == false) {
                        validationMessages.add(
                            Core_MDF_PFC_RestAPIConstants.MSG_ROW_PREFIX +
                            (r.index + 1) +
                            Core_MDF_PFC_RestAPIConstants.MSG_ROW_SEPARATOR +
                            r.message
                        );
                    }
                    Core_MDF_PFC_APIResult apiResult = new Core_MDF_PFC_APIResult();
                    //apiResult.index = r.index;
                    apiResult.rowNumber = r.index + 1;
                    apiResult.success = r.success;
                    apiResult.code = r.code;
                    apiResult.message = r.message;
                    apiResult.recordId = r.recordId;
                    //apiResult.allowedPicklistValues = r.invalidPicklistFields; // hidden; re-enable when needed
                    apiResults.add(apiResult);
                }
                response.setErrorInfo(
                    Core_MDF_PFC_RestAPIConstants.MSG_VALIDATION_FAILED_PREFIX +
                    String.valueOf(validationMessages.size()) +
                    Core_MDF_PFC_RestAPIConstants.MSG_VALIDATION_FAILED_SUFFIX,
                    resolveTopValidationCode(results)
                );
                applyConfiguredHttpStatusCode(response, response.error.code, 400);
                response.details = new Map<String, Object>{
                    Core_MDF_PFC_RestAPIConstants.KEY_RESULTS => apiResults
                };
                validationResult.response = response;
            }
            return validationResult;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            ValidationResult fallbackValidationResult = new ValidationResult();
            fallbackValidationResult.isSuccess = false;
            fallbackValidationResult.response = buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR);
            return fallbackValidationResult;
        }
    }
    /*****************************************************************************************************************************************
    Method Name             : getErrorMessage
    Description             : Retrieves the configured error message corresponding to the supplied error code.
    @Added By               :

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/
    public static String getErrorMessage(String errorCode) {
        try {
            Map<String, Object> errorDetails = getErrorDetails(errorCode);
            return (String) errorDetails.get(Core_MDF_PFC_RestAPIConstants.KEY_MESSAGE);
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return getApplicationErrorMessage(); }
    }

    private static String getApplicationErrorMessage() {
        try {
            Core_MDF_RestAPI_Logger.ErrorConfig errorConfig = Core_MDF_RestAPI_Logger.getCachedErrorConfigDetails(
                Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR,
                Core_MDF_PFC_RestAPIConstants.RESPONSE_CODE_CATEGORY_CLAIM
            );
            if (errorConfig != null && String.isNotBlank(errorConfig.message)) {
                return errorConfig.message;
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return Core_MDF_PFC_RestAPIConstants.MSG_APPLICATION_ERROR;
    }

    private static void applyConfiguredHttpStatusCode(Core_MDF_PFC_APIResponse response, String errorCode, Integer fallbackStatusCode) {
        if (response == null) {
            return;
        }

        Integer resolvedStatusCode = fallbackStatusCode;
        try {
            Core_MDF_RestAPI_Logger.ErrorConfig errorConfig = Core_MDF_RestAPI_Logger.getCachedErrorConfigDetails(
                errorCode,
                Core_MDF_PFC_RestAPIConstants.RESPONSE_CODE_CATEGORY_CLAIM
            );
            if (errorConfig != null && String.isNotBlank(errorConfig.code) && errorConfig.code == errorCode && errorConfig.httpStatusCode != null) {
                resolvedStatusCode = errorConfig.httpStatusCode;
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }

        response.httpStatusCode = resolvedStatusCode;
    }

    private static String resolveTopValidationCode(List<ClaimProcessingResult> results) {
        if (results == null || results.isEmpty()) {
            return Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED;
        }

        String firstFailureCode;
        for (ClaimProcessingResult resultItem : results) {
            if (resultItem == null || resultItem.success == true) {
                continue;
            }

            if (String.isBlank(resultItem.code)) {
                return Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED;
            }

            if (firstFailureCode == null) {
                firstFailureCode = resultItem.code;
            } else if (firstFailureCode != resultItem.code) {
                return Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED;
            }
        }

        return String.isBlank(firstFailureCode)
            ? Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED
            : firstFailureCode;
    }

     /*****************************************************************************************************************************************
    Method Name             : getActivePicklistValues
    Description             : Returns an ordered list of active picklist value API values for a given
                              PartnerFundClaim field.  Results are cached for the lifetime of the
                              transaction to avoid redundant describe calls.
    @param fieldApiName     : API name of the picklist field on PartnerFundClaim.
    @return                 : Ordered list of active value strings; empty list if field not found.
    Added By                : <YourName> – Jun 10, 2026
    ******************************************************************************************************************************************/
    public static List<String> getActivePicklistValues(String fieldApiName) {
        try {
            if (picklistCache.containsKey(fieldApiName)) {
                return picklistCache.get(fieldApiName);
            }
            List<String> values = new List<String>();
            Map<String, Schema.SObjectField> fieldMap =
                PartnerFundClaim.SObjectType.getDescribe().fields.getMap();
            if (fieldMap.containsKey(fieldApiName)) {
                for (Schema.PicklistEntry entry : fieldMap.get(fieldApiName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) { values.add(entry.getValue()); }
                }
            }
            picklistCache.put(fieldApiName, values);
            return values;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return new List<String>(); }
    }

    /*****************************************************************************************************************************************
    Method Name             : validateActivityAndCountry
    Description             : Validates activity number and claim country using one bulk PartnerFundRequest lookup.
    @Added By               : 

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/
    public static BusinessValidationResult validateActivityAndCountry(List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers) {
        try {
            BusinessValidationResult validationResult = new BusinessValidationResult();

            Set<String> activityNumbers = new Set<String>();
            Set<Id> activityIds = new Set<Id>();
            Set<Id> escalationIds = new Set<Id>();

            for (Integer i = 0; i < wrappers.size(); i++) {
                Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw = wrappers[i];
                ClaimProcessingResult result =  new ClaimProcessingResult();
                result.index = i;
                validationResult.results.add(result);
                String activityNumberInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER);
                String escalationIdInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ESCALATION_ID);
                if (String.isNotBlank(activityNumberInput)) {
                    try {
                        activityIds.add((Id) activityNumberInput);
                    } catch (Exception ex) {
                        activityNumbers.add(activityNumberInput);
                    }
                }
                if (String.isNotBlank(escalationIdInput)) {
                    try {
                        escalationIds.add((Id) escalationIdInput);
                    } catch (Exception ex) {
                        // invalid escalation id is handled earlier in validateClaims; ignore here
                    }
                }
            }

            // Resolve activities by either Salesforce Id or activity number.
            Map<String, PartnerFundRequest> activityToRequest =  new Map<String, PartnerFundRequest>();
            Map<Id, PartnerFundRequest> activityToRequestById = new Map<Id, PartnerFundRequest>();
            if (!activityNumbers.isEmpty() || !activityIds.isEmpty()) {
                for (PartnerFundRequest requestRec : [
                    SELECT Id, ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c,
                        Core_MDF_Start_Date__c, Core_MDF_End_Date__c,
                        Core_MDF_Budget_Type_nm__c, Core_MDF_Brand_nm__c,
                        RecordType.DeveloperName
                    FROM PartnerFundRequest
                    WHERE Core_MDF_Activity_Number__c IN :activityNumbers
                        OR Id IN :activityIds
                ]) {
                    activityToRequest.put(requestRec.Core_MDF_Activity_Number__c, requestRec);
                    activityToRequestById.put(requestRec.Id, requestRec);
                }
            }

            Map<Id, Id> escalationToActivityId = new Map<Id, Id>();
            if (!escalationIds.isEmpty()) {
                for (Core_MDF_Escalation__c escalationRec : [
                    SELECT Id, Core_MDF_Co_Marketing_Activity_id__c
                    FROM Core_MDF_Escalation__c
                    WHERE Id IN :escalationIds
                ]) {
                    if (escalationRec.Core_MDF_Co_Marketing_Activity_id__c != null) {
                        escalationToActivityId.put(escalationRec.Id, escalationRec.Core_MDF_Co_Marketing_Activity_id__c);
                    }
                }
            }

            Map<Id, PartnerFundRequest> activityById = new Map<Id, PartnerFundRequest>();
            if (!escalationToActivityId.isEmpty()) {
                for (PartnerFundRequest requestRec : [
                    SELECT Id, ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c,
                        Core_MDF_Start_Date__c, Core_MDF_End_Date__c,
                        Core_MDF_Budget_Type_nm__c, Core_MDF_Brand_nm__c,
                        RecordType.DeveloperName
                    FROM PartnerFundRequest
                    WHERE Id IN :new Set<Id>(escalationToActivityId.values())
                ]) {
                    activityById.put(requestRec.Id, requestRec);
                }
            }

            for (Integer i = 0; i < wrappers.size(); i++) {
                Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw = wrappers[i];
                ClaimProcessingResult r = validationResult.results[i];
                PartnerFundRequest matchedRequest = null;
                String activityNumberInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER);
                String escalationIdInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ESCALATION_ID);

                if (String.isNotBlank(activityNumberInput)) {
                    try {
                        matchedRequest = activityToRequestById.get((Id) activityNumberInput);
                    } catch (Exception ex) {
                        matchedRequest = activityToRequest.get(activityNumberInput);
                    }
                    if (matchedRequest == null) {
                        matchedRequest = activityToRequest.get(activityNumberInput);
                    }
                } else if (String.isNotBlank(escalationIdInput)) {
                    Id resolvedActivityId = escalationToActivityId.get((Id) escalationIdInput);
                    if (resolvedActivityId != null) {
                        matchedRequest = activityById.get(resolvedActivityId);
                        if (matchedRequest != null) {
                            activityNumberInput = matchedRequest.Core_MDF_Activity_Number__c;
                            cw.setValue(Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER, activityNumberInput);
                        }
                    }
                }

                if (matchedRequest == null) {
                    r.success = false;
                    r.code = Core_MDF_PFC_RestAPIConstants.CODE_8032_NO_ACTIVITY_FOUND;
                    String configuredMessage = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8032_NO_ACTIVITY_FOUND);
                    String activityNumberValue = String.isNotBlank(activityNumberInput) ? activityNumberInput : String.valueOf(escalationIdInput);
                    if (String.isNotBlank(configuredMessage) && configuredMessage.contains('{value}')) {
                        r.message = configuredMessage.replace('{value}', activityNumberValue);
                    } 
                    continue;
                }

                String claimCountryInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY);
                if (String.isBlank(claimCountryInput)) {
                    claimCountryInput = matchedRequest.Core_MDF_Country_nm__c;
                    cw.setValue(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY, claimCountryInput);
                }

                // Program-specific required fields (for example taxesLocal on Datacenter, bankSupplierNumber on CMP budget
                // types) come from the layout configuration, resolved to the row matching this activity's budget type.
                List<String> programFieldErrors = new List<String>();
                List<String> programFieldErrorCodes = new List<String>();
                addConfiguredFieldErrors(
                    cw,
                    Core_MDF_PFC_RestAPI_InputWrapper.getClaimFieldConfigs(
                        matchedRequest.Core_MDF_Program__c,
                        matchedRequest.Core_MDF_Budget_Type_nm__c
                    ),
                    programFieldErrors,
                    programFieldErrorCodes
                );
                if (!programFieldErrors.isEmpty()) {
                    r.success = false;
                    r.code = programFieldErrorCodes[0];
                    r.message = String.join(programFieldErrors, Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE);
                    continue;
                }

                List<String> dateErrors = buildUiDateValidationErrors(cw, matchedRequest);

                Boolean countryMatch = false;
                List<String> allowedCountriesForActivity = getAllowedActivityCountries(matchedRequest.Core_MDF_Country_nm__c);
                countryMatch = isCountryInAllowedList(claimCountryInput, allowedCountriesForActivity);

                if (!countryMatch) {
                    r.success = false;
                    r.code = Core_MDF_PFC_RestAPIConstants.CODE_8019_COUNTRY_NOT_IN_ACTIVITY;
                    String configuredMessage = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8019_COUNTRY_NOT_IN_ACTIVITY);
                    String claimCountryValue = String.valueOf(claimCountryInput);
                    if (String.isNotBlank(configuredMessage) && configuredMessage.contains('{value}')) {
                        r.message = configuredMessage.replace('{value}', claimCountryValue);
                    } 
                    r.invalidPicklistFields = new Map<String, List<String>>{
                        Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY => allowedCountriesForActivity
                    };
                    continue;
                }

                r.success = true;
                r.code = Core_MDF_PFC_RestAPIConstants.STATUS_200_SUCCESS;
                r.message = Core_MDF_PFC_RestAPIConstants.MSG_VALIDATED;
                validationResult.requestByIndex.put(i, matchedRequest);
            }

            return validationResult;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            BusinessValidationResult fallbackValidationResult = new BusinessValidationResult();
            for (Integer i = 0; i < wrappers.size(); i++) {
                ClaimProcessingResult deniedResult = new ClaimProcessingResult();
                deniedResult.index = i;
                deniedResult.success = false;
                deniedResult.code = Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR;
                deniedResult.message = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR);
                fallbackValidationResult.results.add(deniedResult);
            }
            return fallbackValidationResult;
        }
    }

    /*****************************************************************************************************************************************
    Method Name             : processClaimsInBulk
    Description             : Inserts claims that passed request-level and business validation with partial success handling.
    @Added By               : 

    Modified By             Date:           Changes:
    ******************************************************************************************************************************************/
    public static Core_MDF_PFC_APIResponse processClaimsInBulk(List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers, BusinessValidationResult businessValidationResult) {
        try {
            List<ClaimProcessingResult> results = businessValidationResult.results;
            System.debug('businessValidationResult===' + JSON.serialize(businessValidationResult));
            Set<String> bankSupplierNumbers = new Set<String>();
            for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw : wrappers) {
                String bankSupplierNumber = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_BANK_SUPPLIER_NUMBER);
                if (String.isNotBlank(bankSupplierNumber)) {
                    bankSupplierNumbers.add(bankSupplierNumber);
                }
            }

            // Collect activity account IDs for bank-account membership validation
            Set<Id> activityAccountIds = new Set<Id>();
            for (Integer i = 0; i < wrappers.size(); i++) {
                PartnerFundRequest req = businessValidationResult.requestByIndex.get(i);
                if (req != null && req.ChannelPartnerId != null) {
                    activityAccountIds.add(req.ChannelPartnerId);
                }
            }

            // Key: supplierNumber + '|' + accountId → bank Id; validates bank belongs to activity account
            Map<String, Id> supplierAccountKeyToBankId = new Map<String, Id>();
            if (!bankSupplierNumbers.isEmpty() && !activityAccountIds.isEmpty()) {
                for (Core_MDF_Account_Bank_Mapping__c mapping : [
                    SELECT Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Account__c
                    FROM Core_MDF_Account_Bank_Mapping__c
                    WHERE Core_MDF_Bank__r.Core_MDF_Supplier_Number__c IN :bankSupplierNumbers
                      AND Core_MDF_Account__c IN :activityAccountIds
                      AND Core_MDF_Active_ind__c = true
                ]) {
                    String key = mapping.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '|' + mapping.Core_MDF_Account__c;
                    supplierAccountKeyToBankId.put(key, mapping.Core_MDF_Bank__c);
                }
            }

            List<PartnerFundClaim> claimsToSave = new List<PartnerFundClaim>();
            List<Integer> recordToPayloadIndex = new List<Integer>();
            Set<Id> successfulClaimIds = new Set<Id>();

            // Resolve RecordTypeId using Core_MDF_ObjRecType_Budget_FieldSetMap__mdt (same source as the UI)
            Set<String> activityRecordTypeDevNames = new Set<String>();
            for (Integer i = 0; i < wrappers.size(); i++) {
                PartnerFundRequest req = businessValidationResult.requestByIndex.get(i);
                if (req != null && req.RecordType != null && String.isNotBlank(req.RecordType.DeveloperName)) {
                    activityRecordTypeDevNames.add(req.RecordType.DeveloperName);
                }
            }
            // activity RecordType dev name → claim RecordType dev name
            Map<String, String> activityToClaimRecordType = new Map<String, String>();
            for (Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  m : [
                SELECT Core_MDF_Activity_RecordType_txt__c, Core_MDF_Claim_RecordType_txt__c
                FROM Core_MDF_ObjRecType_Budget_FieldSetMap__mdt
                WHERE Core_MDF_Activity_RecordType_txt__c IN :activityRecordTypeDevNames
            ]) {
                if (!activityToClaimRecordType.containsKey(m.Core_MDF_Activity_RecordType_txt__c)) {
                    activityToClaimRecordType.put(m.Core_MDF_Activity_RecordType_txt__c, m.Core_MDF_Claim_RecordType_txt__c);
                }
            }
            Map<String, Id> claimRecordTypeIdByDevName = new Map<String, Id>();
            if (!activityToClaimRecordType.isEmpty()) {
                for (RecordType rt : [
                    SELECT Id, DeveloperName
                    FROM RecordType
                    WHERE SObjectType = 'PartnerFundClaim'
                      AND DeveloperName IN :activityToClaimRecordType.values()
                      AND IsActive = true
                ]) {
                    claimRecordTypeIdByDevName.put(rt.DeveloperName, rt.Id);
                }
            }

            for (Integer i = 0; i < wrappers.size(); i++) {
                Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw = wrappers[i];
                ClaimProcessingResult r = results[i];
                if (r.success == false) {
                    continue;
                }

                PartnerFundRequest matchedRequest = businessValidationResult.requestByIndex.get(i);

                Id resolvedClaimSubmitterId = UserInfo.getUserId();
                String claimSubmitterInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_SUBMITTER);
                if (String.isNotBlank(claimSubmitterInput)) {
                    try {
                        resolvedClaimSubmitterId = Id.valueOf(claimSubmitterInput);
                    } catch (Exception ex) {
                        // Falls back to current user if payload claimSubmitter is unexpectedly not normalized.
                    }
                }

                Id resolvedBankId = null;
                String bankSupplierNumberInput = normalizeBankSupplierNumber(
                    cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_BANK_SUPPLIER_NUMBER)
                );
                if (String.isNotBlank(bankSupplierNumberInput)) {
                    String bankKey = bankSupplierNumberInput + '|' + matchedRequest.ChannelPartnerId;
                    if (!supplierAccountKeyToBankId.containsKey(bankKey)) {
                        r.success = false;
                        r.code = Core_MDF_PFC_RestAPIConstants.CODE_8038_INVALID_BANK_SUPPLIER_NUMBER;
                        r.message = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8038_INVALID_BANK_SUPPLIER_NUMBER);
                        continue;
                    }
                    resolvedBankId = supplierAccountKeyToBankId.get(bankKey);
                }
                PartnerFundClaim pfc = cw.toPartnerFundClaim(matchedRequest.Id, resolvedClaimSubmitterId, resolvedBankId, matchedRequest.Core_MDF_Program__c);

                // Set RecordTypeId — derived from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt, same as UI flow
                if (matchedRequest.RecordType != null) {
                    String actDevName = matchedRequest.RecordType.DeveloperName;
                    if (activityToClaimRecordType.containsKey(actDevName)) {
                        String claimDevName = activityToClaimRecordType.get(actDevName);
                        if (claimRecordTypeIdByDevName.containsKey(claimDevName)) {
                            pfc.RecordTypeId = claimRecordTypeIdByDevName.get(claimDevName);
                        }
                    }
                }

                // Propagate activity fields onto the claim — mirrors what the UI's fetchActivityDetails does
                // Always set to avoid NPE in Core_MDF_Claim_Utility when it does a null-unsafe string check
                pfc.Core_MDF_Budget_Type_Options_Nm__c = String.isNotBlank(matchedRequest.Core_MDF_Budget_Type_nm__c)
                    ? matchedRequest.Core_MDF_Budget_Type_nm__c
                    : '';
                if (String.isNotBlank(matchedRequest.Core_MDF_Brand_nm__c)) {
                    pfc.Core_MDF_Brand_nm__c = matchedRequest.Core_MDF_Brand_nm__c;
                }

                claimsToSave.add(pfc);
                recordToPayloadIndex.add(i);
            }

            if (!claimsToSave.isEmpty()) {
                Database.SaveResult[] saveResults = Database.insert(claimsToSave, false);
                for (Integer i = 0; i < saveResults.size(); i++) {
                    Integer payloadIndex = recordToPayloadIndex[i];
                    ClaimProcessingResult r = results[payloadIndex];
                    if (saveResults[i].isSuccess()) {
                        Id savedClaimId = saveResults[i].getId();
                        r.success = true;
                        r.code = Core_MDF_PFC_RestAPIConstants.STATUS_200_SUCCESS;
                        r.message = Core_MDF_PFC_RestAPIConstants.MSG_CREATED;
                        r.recordId = savedClaimId;
                        successfulClaimIds.add(savedClaimId);
                    } else {
                        Database.Error[] dmlErrors = saveResults[i].getErrors();
                        Boolean isCustomValidation = false;
                        for (Database.Error err : dmlErrors) {
                            if (err != null && (
                                err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION ||
                                err.getStatusCode() == StatusCode.REQUIRED_FIELD_MISSING
                            )) {
                                isCustomValidation = true;
                                break;
                            }
                        }
                        r.success = false;
                        r.code = isCustomValidation
                            ? Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED
                            : Core_MDF_PFC_RestAPIConstants.CODE_8018_INTERNAL_SERVER_ERROR;
                        r.message = buildUiCreateErrorMessage(dmlErrors);
                        // Always log raw DML errors to Core_Log_Entry__c for diagnosis
                        List<String> rawMsgs = new List<String>();
                        for (Database.Error err : dmlErrors) {
                            if (err != null) rawMsgs.add('STATUS=' + err.getStatusCode() + ' MSG=' + err.getMessage() + ' FIELDS=' + err.getFields());
                        }
                        CalloutException dmlLogEx = new CalloutException();
                        dmlLogEx.setMessage('DML-ERROR row ' + (results[payloadIndex].index + 1) + ': ' + String.join(rawMsgs, '; '));
                        Core_MDF_CCP_UtilityClass.logError(dmlLogEx);
                    }
                }
            }

            if (!successfulClaimIds.isEmpty()) {
                Map<Id, String> claimNumberById = new Map<Id, String>();
                for (PartnerFundClaim savedClaim : [
                    SELECT Id, Core_MDF_Claim_Ref_Number__c
                    FROM PartnerFundClaim
                    WHERE Id IN :successfulClaimIds
                ]) {
                    claimNumberById.put(savedClaim.Id, savedClaim.Core_MDF_Claim_Ref_Number__c);
                }

                for (ClaimProcessingResult resultItem : results) {
                    if (resultItem != null && resultItem.recordId != null && claimNumberById.containsKey(resultItem.recordId)) {
                        resultItem.claimNumber = claimNumberById.get(resultItem.recordId);
                    }
                }
            }

            attachDocumentsToClaims(wrappers, results);

            Integer successCount = 0;
            for (ClaimProcessingResult r : results) {
                if (r.success == true) {
                    successCount++;
                }
            }

            Core_MDF_PFC_APIResponse response = new Core_MDF_PFC_APIResponse();
            /* Build detailed response message */
            List<String> errorMessages = new List<String>();
            for (ClaimProcessingResult r : results) {
                if (r.success == false && String.isNotBlank(r.message)) {
                    errorMessages.add(
                        Core_MDF_PFC_RestAPIConstants.MSG_ROW_PREFIX +
                        (r.index + 1) +
                        Core_MDF_PFC_RestAPIConstants.MSG_ROW_SEPARATOR +
                        r.message
                    );
                }
            }
            String responseMessage;
            if (!errorMessages.isEmpty()) {
                responseMessage = String.join(errorMessages, Core_MDF_PFC_RestAPIConstants.DELIMITER_PIPE);
            } else {
                responseMessage = Core_MDF_PFC_RestAPIConstants.MSG_ALL_CLAIMS_PROCESSED_SUCCESS;
            }

            /* Populate results array */
            List<Core_MDF_PFC_APIResult> apiResults =  new List<Core_MDF_PFC_APIResult>();
            for (ClaimProcessingResult r : results) {
                Core_MDF_PFC_APIResult apiResult = new Core_MDF_PFC_APIResult();
                //apiResult.index = r.index;
                apiResult.rowNumber = r.index + 1;
                apiResult.success = r.success;
                apiResult.code = r.code;
                apiResult.message = r.message;
                apiResult.recordId = r.recordId;
                apiResult.claimNumber = r.claimNumber;
                //apiResult.allowedPicklistValues = r.invalidPicklistFields; // hidden; re-enable when needed
                apiResults.add(apiResult);
            }

            if (successCount == results.size()) {
                response.setSuccessInfo(responseMessage, Core_MDF_PFC_RestAPIConstants.STATUS_200_SUCCESS);
                response.httpStatusCode = 200;
            } else if (successCount == 0) {
                String topCode = resolveTopValidationCode(results);
                response.setErrorInfo(responseMessage, topCode);
                applyConfiguredHttpStatusCode(
                    response,
                    topCode,
                    topCode == Core_MDF_PFC_RestAPIConstants.CODE_8018_INTERNAL_SERVER_ERROR ||
                    topCode == Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR
                        ? 500
                        : 400
                );
            } else {
                response.setErrorInfo(responseMessage, Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS);
                response.httpStatusCode = 207;
            }
            response.details = new Map<String, Object>{
                Core_MDF_PFC_RestAPIConstants.KEY_RESULTS => apiResults
            };
            return response;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return buildErrorResponseFromCode(Core_MDF_PFC_RestAPIConstants.CODE_8021_APPLICATION_ERROR); }
    }

    private static String normalizeBankSupplierNumber(String bankSupplierNumber) {
        if (String.isBlank(bankSupplierNumber)) {
            return null;
        }

        String normalizedValue = bankSupplierNumber.trim();
        if (normalizedValue.equalsIgnoreCase('null') || normalizedValue.equalsIgnoreCase('undefined')) {
            return null;
        }

        return normalizedValue;
    }

    private static void attachDocumentsToClaims(List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> wrappers, List<ClaimProcessingResult> results) {
        if (wrappers == null || results == null || wrappers.isEmpty() || results.isEmpty()) {
            return;
        }

        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        List<Integer> contentVersionRowIndexes = new List<Integer>();
        List<String> contentVersionDocumentTypes = new List<String>();
        List<String> contentVersionTitles = new List<String>();
        List<Core_MDF_Audit_Document__c> auditDocsToInsert = new List<Core_MDF_Audit_Document__c>();
        List<Integer> auditDocRowIndexes = new List<Integer>();

        for (Integer i = 0; i < wrappers.size(); i++) {
            ClaimProcessingResult rowResult = results[i];
            Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput rowWrapper = wrappers[i];
            if (rowResult == null || rowWrapper == null || rowResult.success != true || rowResult.recordId == null) {
                continue;
            }
            if (rowWrapper.documents == null || rowWrapper.documents.isEmpty()) {
                continue;
            }

            for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimDocumentInput documentItem : rowWrapper.documents) {
                if (documentItem == null) {
                    continue;
                }

                if (String.isNotBlank(documentItem.fileContent) && String.isNotBlank(documentItem.fileName)) {
                    try {
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.Title = deriveFileTitle(documentItem.fileName);
                        contentVersion.PathOnClient = documentItem.fileName;
                        contentVersion.VersionData = EncodingUtil.base64Decode(normalizeBase64Payload(documentItem.fileContent));
                        contentVersion.FirstPublishLocationId = rowResult.recordId;
                        contentVersionsToInsert.add(contentVersion);
                        contentVersionRowIndexes.add(i);
                        contentVersionDocumentTypes.add(documentItem.documentType);
                        contentVersionTitles.add(documentItem.fileName); // full name with extension, matching UI uploadedFile.name
                    } catch (Exception ex) {
                        addFileErrorMessage(
                            rowResult,
                            Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT,
                            null
                        );
                    }
                    continue;
                }
            }
        }

        Map<Integer, List<String>> rowFileErrors = new Map<Integer, List<String>>();

        if (!contentVersionsToInsert.isEmpty()) {
            Database.SaveResult[] contentVersionSaveResults = Database.insert(contentVersionsToInsert, false);
            Set<Id> successfulContentVersionIds = new Set<Id>();
            Map<Id, Integer> contentVersionIdToRowIndex = new Map<Id, Integer>();
            Map<Id, String> contentVersionIdToDocType = new Map<Id, String>();
            Map<Id, String> contentVersionIdToTitle = new Map<Id, String>();
            Map<Id, String> contentVersionIdToVersionId = new Map<Id, String>();

            for (Integer i = 0; i < contentVersionSaveResults.size(); i++) {
                if (contentVersionSaveResults[i].isSuccess()) {
                    Id contentVersionId = contentVersionSaveResults[i].getId();
                    successfulContentVersionIds.add(contentVersionId);
                    contentVersionIdToRowIndex.put(contentVersionId, contentVersionRowIndexes[i]);
                    contentVersionIdToDocType.put(contentVersionId, contentVersionDocumentTypes[i]);
                    contentVersionIdToTitle.put(contentVersionId, contentVersionTitles[i]);
                    contentVersionIdToVersionId.put(contentVersionId, String.valueOf(contentVersionId));
                    continue;
                }
                Integer rowIndex = contentVersionRowIndexes[i];
                addFileErrors(rowFileErrors, rowIndex, contentVersionSaveResults[i].getErrors());
            }

            if (!successfulContentVersionIds.isEmpty()) {
                for (ContentVersion insertedVersion : [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :successfulContentVersionIds
                ]) {
                    Integer rowIndex = contentVersionIdToRowIndex.get(insertedVersion.Id);
                    if (rowIndex == null || insertedVersion.ContentDocumentId == null || rowIndex >= results.size()) {
                        continue;
                    }

                    ClaimProcessingResult rowResult = results[rowIndex];
                    if (rowResult == null || rowResult.recordId == null) {
                        continue;
                    }

                    String docType = contentVersionIdToDocType.get(insertedVersion.Id);
                    String resolvedDocType = String.isNotBlank(docType) ? docType : Core_MDF_PFC_RestAPIConstants.DEFAULT_DOCUMENT_TYPE;
                    Core_MDF_Audit_Document__c auditDocument = new Core_MDF_Audit_Document__c();
                    auditDocument.Core_MDF_Claim__c = rowResult.recordId;
                    auditDocument.Core_MDF_Document_Id__c = insertedVersion.ContentDocumentId;
                    auditDocument.Core_MDF_Document_Types__c = resolvedDocType;
                    auditDocument.Core_MDF_App_Document_Types_nm__c = Core_MDF_PFC_RestAPIConstants.DEFAULT_APP_DOCUMENT_TYPES;
                    auditDocument.Core_MDF_Document_Title__c = contentVersionIdToTitle.get(insertedVersion.Id);
                    auditDocument.Core_MDF_ContentVersion_Id__c = contentVersionIdToVersionId.get(insertedVersion.Id);
                    auditDocsToInsert.add(auditDocument);
                    auditDocRowIndexes.add(rowIndex);
                }
            }
        }

        if (!auditDocsToInsert.isEmpty()) {
            Database.SaveResult[] auditDocSaveResults = Database.insert(auditDocsToInsert, false);
            for (Integer i = 0; i < auditDocSaveResults.size(); i++) {
                if (auditDocSaveResults[i].isSuccess()) {
                    continue;
                }
                Integer rowIndex = auditDocRowIndexes[i];
                addFileErrors(rowFileErrors, rowIndex, auditDocSaveResults[i].getErrors());
            }
        }

        if (rowFileErrors.isEmpty()) {
            return;
        }

        for (Integer rowIndex : rowFileErrors.keySet()) {
            if (rowIndex == null || rowIndex < 0 || rowIndex >= results.size()) {
                continue;
            }
            ClaimProcessingResult rowResult = results[rowIndex];
            if (rowResult == null) {
                continue;
            }
            rowResult.success = false;
            rowResult.code = Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT;
            String configuredUploadError = getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8035_INVALID_BASE64_FILE_CONTENT);
            String detailedErrors = String.join(rowFileErrors.get(rowIndex), Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE);
            rowResult.message = String.isNotBlank(configuredUploadError)
                ? configuredUploadError + Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE + detailedErrors
                : detailedErrors;
        }
    }

    private static void addFileErrors(Map<Integer, List<String>> rowFileErrors, Integer rowIndex, Database.Error[] errors) {
        if (rowIndex == null || errors == null || errors.isEmpty()) {
            return;
        }
        if (!rowFileErrors.containsKey(rowIndex)) {
            rowFileErrors.put(rowIndex, new List<String>());
        }

        List<String> rowErrors = rowFileErrors.get(rowIndex);
        Boolean hasUnhandledSystemError = false;
        for (Database.Error errorItem : errors) {
            if (errorItem == null) {
                continue;
            }

            if (errorItem.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                String uiError = extractCustomValidationMessage(errorItem.getMessage());
                if (String.isNotBlank(uiError)) {
                    rowErrors.add(uiError);
                    continue;
                }
            }

            hasUnhandledSystemError = true;
        }

        if (hasUnhandledSystemError && !rowErrors.contains(Core_MDF_PFC_RestAPIConstants.MSG_APPLICATION_ERROR)) {
            rowErrors.add(Core_MDF_PFC_RestAPIConstants.MSG_APPLICATION_ERROR);
        }
    }

    private static void addFileErrorMessage(ClaimProcessingResult rowResult, String errorCode, String details) {
        if (rowResult == null || String.isBlank(errorCode)) {
            return;
        }

        String message = getErrorMessage(errorCode);
        if (String.isNotBlank(details)) {
            message = String.isNotBlank(message)
                ? message + Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE + details
                : details;
        }
        if (String.isBlank(message)) {
            return;
        }

        rowResult.success = false;
        rowResult.code = errorCode;
        if (String.isBlank(rowResult.message)) {
            rowResult.message = message;
        } else {
            rowResult.message += Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE + message;
        }
    }

    private static String normalizeBase64Payload(String rawPayload) {
        if (String.isBlank(rawPayload)) {
            return Core_MDF_PFC_RestAPIConstants.EMPTY_STRING;
        }

        String normalized = rawPayload.trim();
        Integer markerIndex = normalized.indexOf('base64,');
        if (markerIndex > -1) {
            normalized = normalized.substring(markerIndex + 7);
        }
        return normalized;
    }

    private static String deriveFileTitle(String fileName) {
        if (String.isBlank(fileName)) {
            return 'Uploaded File';
        }

        String normalizedName = fileName.trim();
        Integer extensionIndex = normalizedName.lastIndexOf('.');
        if (extensionIndex > 0) {
            return normalizedName.substring(0, extensionIndex);
        }
        return normalizedName;
    }

    private static List<String> getAllowedActivityCountries(String activityCountryValue) {
        List<String> allowedCountries = new List<String>();
        if (String.isBlank(activityCountryValue)) {
            return allowedCountries;
        }

        for (String country : activityCountryValue.split(Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON)) {
            if (String.isNotBlank(country)) {
                allowedCountries.add(country.trim());
            }
        }
        return allowedCountries;
    }

    private static Boolean isCountryInAllowedList(String claimCountry, List<String> allowedCountries) {
        if (String.isBlank(claimCountry) || allowedCountries == null || allowedCountries.isEmpty()) {
            return false;
        }

        for (String allowedCountry : allowedCountries) {
            if (allowedCountry != null && allowedCountry.equalsIgnoreCase(claimCountry)) {
                return true;
            }
        }
        return false;
    }

    private static List<String> buildUiDateValidationErrors(Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw, PartnerFundRequest activity) {
        List<String> errors = new List<String>();
        if (cw == null || activity == null) {
            return errors;
        }
        String claimStartDateInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_START_DATE);
        String claimEndDateInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_END_DATE);
        if (String.isBlank(claimStartDateInput) || String.isBlank(claimEndDateInput)) {
            return errors;
        }

        try {
            Date claimStart = Date.valueOf(claimStartDateInput);
            Date claimEnd = Date.valueOf(claimEndDateInput);
            Date userToday = Date.today();

            String startError = Core_MDF_PFC_RestAPIConstants.EMPTY_STRING;
            String endError = Core_MDF_PFC_RestAPIConstants.EMPTY_STRING;

            if (claimStart > userToday) {
                startError = Core_MDF_PFC_RestAPIConstants.MSG_START_DATE_FUTURE_VALIDATION;
            } else if (activity.Core_MDF_Start_Date__c != null && activity.Core_MDF_End_Date__c != null &&
                (claimStart < activity.Core_MDF_Start_Date__c || claimStart > activity.Core_MDF_End_Date__c)) {
                startError = Core_MDF_PFC_RestAPIConstants.MSG_START_DATE_VALIDATION;
            } else if (claimStart > claimEnd) {
                startError = Core_MDF_PFC_RestAPIConstants.MSG_START_DATE_END_DATE_VALIDATION;
            }

            if (claimEnd > userToday) {
                endError = Core_MDF_PFC_RestAPIConstants.MSG_END_DATE_FUTURE_VALIDATION;
            } else if (activity.Core_MDF_Start_Date__c != null && activity.Core_MDF_End_Date__c != null &&
                (claimEnd < activity.Core_MDF_Start_Date__c || claimEnd > activity.Core_MDF_End_Date__c)) {
                endError = Core_MDF_PFC_RestAPIConstants.MSG_END_DATE_VALIDATION;
            } else if (claimStart > claimEnd) {
                endError = Core_MDF_PFC_RestAPIConstants.MSG_END_DATE_START_DATE_VALIDATION;
            }

            if (String.isNotBlank(startError)) {
                errors.add(startError);
            }
            if (String.isNotBlank(endError)) {
                errors.add(endError);
            }
        } catch (Exception ex) {
            // Date parsing format validation is handled in validateClaims.
        }

        return errors;
    }

    private static String buildUiCreateErrorMessage(Database.Error[] dmlErrors) {
        if (dmlErrors == null || dmlErrors.isEmpty()) {
            return Core_MDF_PFC_RestAPIConstants.MSG_APPLICATION_ERROR;
        }

        List<String> customValidationErrors = new List<String>();
        for (Database.Error err : dmlErrors) {
            if (err == null) {
                continue;
            }

            if (err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                String uiError = extractCustomValidationMessage(err.getMessage());
                if (String.isNotBlank(uiError)) {
                    customValidationErrors.add(uiError);
                }
            } else if (err.getStatusCode() == StatusCode.REQUIRED_FIELD_MISSING) {
                String uiError = extractCustomValidationMessage(err.getMessage());
                customValidationErrors.add(String.isNotBlank(uiError) ? uiError : err.getMessage());
            }
        }

        if (!customValidationErrors.isEmpty()) {
            return String.join(customValidationErrors, Core_MDF_PFC_RestAPIConstants.DELIMITER_SEMICOLON_SPACE);
        }

        return Core_MDF_PFC_RestAPIConstants.MSG_APPLICATION_ERROR;
    }

    private static String extractCustomValidationMessage(String rawErrorMessage) {
        if (String.isBlank(rawErrorMessage)) {
            return Core_MDF_PFC_RestAPIConstants.EMPTY_STRING;
        }

        String marker = Core_MDF_PFC_RestAPIConstants.FIELD_CUSTOM_VALIDATION_EXCEPTION + ',';
        Integer markerIndex = rawErrorMessage.lastIndexOf(marker);
        if (markerIndex == -1) {
            return rawErrorMessage;
        }

        String messageSegment = rawErrorMessage.substring(markerIndex + marker.length()).trim();
        Integer colonIndex = messageSegment.indexOf(':');
        if (colonIndex > -1) {
            messageSegment = messageSegment.substring(0, colonIndex).trim();
        }
        return messageSegment;
    }

    private static Boolean addLateClaimEscalationError(Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw, List<String> fieldErrors, Boolean isLateClaimRequest) {
        if (cw == null || fieldErrors == null) {
            return false;
        }

        if (isLateClaimRequest != true || String.isNotBlank(cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ESCALATION_ID))) {
            return false;
        }

        fieldErrors.add(getErrorMessage(Core_MDF_PFC_RestAPIConstants.CODE_8040_ESCALATION_ID_REQUIRED));
        return true;
    }

    private static String normalizeClaimType(String claimTypeValue) {
        if (String.isBlank(claimTypeValue)) {
            return null;
        }
        return claimTypeValue.trim().toLowerCase();
    }

    /*****************************************************************************************************************************************
    Method Name             : addConfiguredFieldErrors
    Description             : Applies the required and format rules configured on Core_MDF_Custom_Layout_Configurations__c
                              (Core_MDF_API_Required_Ind__c / Core_MDF_API_Error_Code__c) to a single payload row.
    ******************************************************************************************************************************************/
    private static void addConfiguredFieldErrors(
        Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig> fieldConfigs,
        List<String> fieldErrors,
        List<String> fieldErrorCodes
    ) {
        addConfiguredFieldErrors(cw, fieldConfigs, fieldErrors, fieldErrorCodes, new Set<String>());
    }

    private static void addConfiguredFieldErrors(
        Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw,
        List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig> fieldConfigs,
        List<String> fieldErrors,
        List<String> fieldErrorCodes,
        Set<String> deferredRequiredFields
    ) {
        if (cw == null || fieldConfigs == null || fieldConfigs.isEmpty()) {
            return;
        }

        // activityNumber and claimCountry are derived from the escalation's activity when one is supplied.
        Boolean hasEscalation = String.isNotBlank(cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_ESCALATION_ID));
        Set<String> escalationDerivedFields = new Set<String>{
            Core_MDF_PFC_RestAPIConstants.FIELD_ACTIVITY_NUMBER.toLowerCase(),
            Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_COUNTRY.toLowerCase()
        };
        Map<String, Schema.SObjectField> claimFields = PartnerFundClaim.SObjectType.getDescribe().fields.getMap();

        for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimFieldConfig fieldConfig : fieldConfigs) {
            String submittedValue = cw.getText(fieldConfig.payloadFieldName);

            if (String.isBlank(submittedValue)) {
                Boolean derivedFromEscalation = hasEscalation && escalationDerivedFields.contains(fieldConfig.payloadFieldName.toLowerCase());
                if (fieldConfig.isRequired == true
                    && !derivedFromEscalation
                    && (deferredRequiredFields == null
                        || !deferredRequiredFields.contains(fieldConfig.payloadFieldName))) {
                    addConfiguredError(fieldConfig.errorCode, fieldErrors, fieldErrorCodes);
                }
                continue;
            }

            if (!claimFields.containsKey(fieldConfig.fieldApiName)) {
                continue;
            }

            Schema.DisplayType fieldType = claimFields.get(fieldConfig.fieldApiName).getDescribe().getType();
            if (fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DATETIME) {
                try {
                    Date.valueOf(submittedValue);
                } catch (Exception ex) {
                    addConfiguredError(fieldConfig.errorCode, fieldErrors, fieldErrorCodes);
                }
            } else if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.PERCENT) {
                Decimal numericValue = cw.getNumber(fieldConfig.payloadFieldName);
                if (numericValue == null || numericValue < 0) {
                    addConfiguredError(fieldConfig.errorCode, fieldErrors, fieldErrorCodes);
                }
            }
        }
    }

    private static void addConfiguredError(String configuredErrorCode, List<String> fieldErrors, List<String> fieldErrorCodes) {
        String errorCode = String.isNotBlank(configuredErrorCode)
            ? configuredErrorCode
            : Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED;
        fieldErrors.add(getErrorMessage(errorCode));
        fieldErrorCodes.add(errorCode);
    }

    private static Map<String, Id> resolveClaimSubmitters(List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> claimsPayload) {
        Map<String, Id> resolvedByInput = new Map<String, Id>();
        if (claimsPayload == null || claimsPayload.isEmpty()) {
            return resolvedByInput;
        }

        Set<Id> idCandidates = new Set<Id>();
        Set<String> emailOrUsernameCandidates = new Set<String>();

        for (Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput cw : claimsPayload) {
            if (cw == null) {
                continue;
            }

            String submitterInput = cw.getText(Core_MDF_PFC_RestAPIConstants.FIELD_CLAIM_SUBMITTER);
            if (String.isBlank(submitterInput)) {
                continue;
            }

            try {
                Id submitterId = Id.valueOf(submitterInput);
                if (submitterId.getSObjectType() == User.SObjectType) {
                    idCandidates.add(submitterId);
                }
            } catch (Exception ex) {
                emailOrUsernameCandidates.add(submitterInput);
            }
        }

        if (!idCandidates.isEmpty()) {
            for (User userRec : [
                SELECT Id
                FROM User
                WHERE Id IN :idCandidates
            ]) {
                resolvedByInput.put(String.valueOf(userRec.Id), userRec.Id);
            }
        }

        if (!emailOrUsernameCandidates.isEmpty()) {
            for (User userRec : [
                SELECT Id, Email, Username
                FROM User
                WHERE Email IN :emailOrUsernameCandidates
                    OR Username IN :emailOrUsernameCandidates
            ]) {
                if (String.isNotBlank(userRec.Email)) {
                    resolvedByInput.put(userRec.Email, userRec.Id);
                }
                if (String.isNotBlank(userRec.Username)) {
                    resolvedByInput.put(userRec.Username, userRec.Id);
                }
            }
        }

        return resolvedByInput;
    }

    /*
     * WRAPPERS
     */
    public class ValidationResult {
        public Boolean isSuccess;
        public Core_MDF_PFC_APIResponse response;
        public List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput> validWrappers;
        public ValidationResult() {
            isSuccess = true;
            validWrappers = new List<Core_MDF_PFC_RestAPI_InputWrapper.ClaimInput>();
        }
    }
    public class ClaimProcessingResult {
        public Integer index;
        public Boolean success;
        public String code;
        public String message;
        public Id recordId;
        public String claimNumber;
        public Map<String, List<String>> invalidPicklistFields;
    }

    public class Core_MDF_PFC_APIResult {
        public Integer rowNumber;
        public Boolean success;
        public String code;
        public String message;
        public Id recordId;
        public String claimNumber;
    }
    public class BusinessValidationResult {
        public List<ClaimProcessingResult> results;
        public Map<Integer, PartnerFundRequest> requestByIndex;
        public BusinessValidationResult() {
            results = new List<ClaimProcessingResult>();
            requestByIndex = new Map<Integer, PartnerFundRequest>();
        }
    }
    
}