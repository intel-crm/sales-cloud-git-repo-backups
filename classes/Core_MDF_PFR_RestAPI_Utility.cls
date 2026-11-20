/**
 * @description Simplified Utility for PartnerFundRequest REST API
 * Relies on existing triggers for business validation.
 */
public inherited sharing class Core_MDF_PFR_RestAPI_Utility {
    private static final String PFR_OBJECT_NAME = 'PartnerFundRequest';
    private static final String PFR_CUSTOM_PICKLIST_OBJECT_NAME = 'Core_MDF_PFRCustomPicklist__c';
    private static final String ACTIVITY_CATEGORY_FIELD = 'Core_MDF_ActivityCategory__c';
    private static final String ACTIVITY_TYPE_FIELD = 'Core_MDF_Activity_Types__c';
    private static final String PFR_REST_API_CATEGORY = 'PFR REST API';
    private static final String EVENT_NAME = 'Event';
    private static final String EVENT_TYPE = 'other';
    private static final String OTHER_EVENT_NAME = 'Other';
    private static final String ECOSYSTEMPARTNER= 'ecosystempartner.com' ;
    private static final String ACTIVITYTYPE_DIGITAL= 'digital' ;
    private static Map<String, List<ResponseCodeSetting>> externalApiResponseSettingsByCode;
    
    
    public class ResponseCodeSetting {
        public String name;
        public String code;
        public String message;
        public String httpStatusCode;
        public String context;
    }

    public static ResponseCodeSetting getResponseCodeSetting(String codeHint, String httpStatusHint, String contextHint) {
        ResponseCodeSetting setting = getExternalApiResponseCodeSettingByCode(codeHint, contextHint);
        if (isMatchingResponseCodeSetting(setting, codeHint)) {
            return setting;
        }

        setting = getExternalApiResponseCodeSettingByCode(codeHint, null);
        return isMatchingResponseCodeSetting(setting, codeHint) ? setting : null;
    }

    public static String normalizeErrorCode(String codeValue) {
        if (String.isBlank(codeValue)) {
            return null;
        }
        String normalized = codeValue.trim();
        if (normalized.toUpperCase().startsWith('ERR-') && normalized.length() > 4) {
            normalized = normalized.substring(4).trim();
        }
        return normalized;
    }

    private static String normalizeHttpStatusCode(String statusCode) {
        if (String.isBlank(statusCode)) {
            return null;
        }
        String normalized = statusCode.trim();
        return normalized.isNumeric() ? normalized : null;
    }

    private static ResponseCodeSetting toResponseCodeSetting(Object configDetails) {
        if (configDetails == null) {
            return null;
        }
        Map<String, Object> configValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(configDetails));
        ResponseCodeSetting result = new ResponseCodeSetting();
        result.name = firstConfigString(configValues, new List<String>{'name', 'Name'});
        result.code = normalizeErrorCode(firstConfigString(configValues, new List<String>{'code', 'Core_Code__c'}));
        result.message = firstConfigString(configValues, new List<String>{'message', 'Core_Message__c'});
        result.httpStatusCode = normalizeHttpStatusCode(firstConfigString(configValues, new List<String>{'httpStatusCode', 'Core_Http_Status_Code__c'}));
        result.context = firstConfigString(configValues, new List<String>{'category', 'context', 'Core_Context_of_Error__c'});
        return result;
    }

    private static ResponseCodeSetting getExternalApiResponseCodeSettingByCode(String codeHint, String contextHint) {
        String normalizedCode = normalizeErrorCode(codeHint);
        if (String.isBlank(normalizedCode)) {
            return null;
        }
        buildExternalApiResponseSettingsCache();
        if (!externalApiResponseSettingsByCode.containsKey(normalizedCode)) {
            return null;
        }

        List<ResponseCodeSetting> settings = externalApiResponseSettingsByCode.get(normalizedCode);
        if (String.isNotBlank(contextHint)) {
            for (ResponseCodeSetting setting : settings) {
                if (String.isNotBlank(setting.context) && setting.context.equalsIgnoreCase(contextHint)) {
                    return setting;
                }
            }
        }

        return settings.isEmpty() ? null : settings[0];
    }

    private static void buildExternalApiResponseSettingsCache() {
        if (externalApiResponseSettingsByCode != null) {
            return;
        }
        externalApiResponseSettingsByCode = new Map<String, List<ResponseCodeSetting>>();
        for (Core_MDF_External_API_Response_Codes__c settingRecord : [
            SELECT Name, Core_Code__c, Core_Message__c, Core_Http_Status_Code__c, Core_Context_of_Error__c
            FROM Core_MDF_External_API_Response_Codes__c
            WHERE Core_Code__c != null
            ORDER BY Name
        ]) {
            ResponseCodeSetting setting = toResponseCodeSetting(settingRecord);
            if (setting == null || String.isBlank(setting.code)) {
                continue;
            }
            if (!externalApiResponseSettingsByCode.containsKey(setting.code)) {
                externalApiResponseSettingsByCode.put(setting.code, new List<ResponseCodeSetting>());
            }
            externalApiResponseSettingsByCode.get(setting.code).add(setting);
        }
    }

    private static Boolean isMatchingResponseCodeSetting(ResponseCodeSetting setting, String expectedCode) {
        String normalizedExpectedCode = normalizeErrorCode(expectedCode);
        return setting != null && (String.isBlank(normalizedExpectedCode) || setting.code == normalizedExpectedCode);
    }

    private static String firstConfigString(Map<String, Object> configValues, List<String> fieldNames) {
        if (configValues == null || fieldNames == null) {
            return null;
        }
        for (String fieldName : fieldNames) {
            if (String.isBlank(fieldName) || !configValues.containsKey(fieldName) || configValues.get(fieldName) == null) {
                continue;
            }
            return String.valueOf(configValues.get(fieldName));
        }
        return null;
    }

    /**
     * Get formatted error message from custom settings
     * @param errorCode The error code (numeric like '9040' or with code prefix)
     * @param args Optional list of arguments for String.format() if message contains placeholders
     * @return Formatted message from custom settings, or provided fallback message
     */
    public static String getFormattedErrorMessage(String errorCode, List<String> args) {
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting = getResponseCodeSetting(errorCode, null, null);
        if (setting != null && String.isNotBlank(setting.message)) {
            String msg = setting.message;
            if (args != null && !args.isEmpty()) {
                try {
                    msg = String.format(msg, args);
                } catch (Exception e) {
                    Core_MDF_CCP_UtilityClass.logError(e);
                    // If formatting fails, return message as-is
                }
            }
            return msg;
        }
        return null;
    }
    
    /**
     * Reads one query-string parameter from the current REST request.
     */
    public static String getRequestParam(String key) {
        String paramValue = '';
        try {
            if (RestContext.request != null) {
                Map<String, String> params = RestContext.request.params;
                paramValue = params.get(key);
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            System.debug('========'+e.getLineNumber());
        }
        return paramValue;
    }

    /**
     * Validates file upload requirement for OEM CMP event activities with digital ecosystem partners and spending > $50,000.
     * Checks if files were provided when required conditions are met.
     * @param pfrs List of PartnerFundRequest records to validate
     * @param fileUploads List of file uploads from the payload
     * @return List of validation failures for activities requiring file upload
     */
    public static List<Core_MDF_PFR_RestAPI_Response.ErrorContent> validateFileUploadRequirement(List<PartnerFundRequest> pfrs, List<Core_MDF_PFR_RestAPI_InputWrapper.FileUpload> fileUploads) {
        List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failures = new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
        
        // Check if any file upload has actual content (non-blank FileName AND file data)
        Boolean hasValidFileUpload = false;
        if (fileUploads != null && !fileUploads.isEmpty()) {
            for (Core_MDF_PFR_RestAPI_InputWrapper.FileUpload upload : fileUploads) {
                if (upload != null && String.isNotBlank(upload.FileName) && String.isNotBlank(upload.file)) {
                    hasValidFileUpload = true;
                    break;
                }
            }
        }
        
        for (Integer index = pfrs.size() - 1; index >= 0; index--) {
            List<String> errors = validateDigitalEcosystemPartnerFileUpload(pfrs[index], hasValidFileUpload);
            if (!errors.isEmpty()) {
                failures.add(buildValidationFailure(pfrs[index], errors));
                pfrs.remove(index);
            }
        }
        
        return failures;
    }

    /**
     * Runs REST API pre-DML validation, applies API-only defaults, and removes invalid PFRs from the input list.
     */
    public static List<Core_MDF_PFR_RestAPI_Response.ErrorContent> normalizeAndValidateApiOnly(List<PartnerFundRequest> pfrs, Boolean isUpdateAction) {
        List<Core_MDF_PFR_RestAPI_Response.ErrorContent> validationFailures =
            new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
        Map<Id, PartnerFundRequest> existingPfrMap = isUpdateAction ? getExistingPfrMap(pfrs) : new Map<Id, PartnerFundRequest>();
        Map<Id, Campaign> campaignMap = getCampaignMap(pfrs, existingPfrMap);
        // On create, derive the PFR record type from the Campaign program (CCF/DCF). The external
        // system no longer supplies the record type directly via a "Program" payload field.
        if (!isUpdateAction) {
            applyRecordTypeFromCampaignProgram(pfrs, campaignMap);
        }
        Map<Id, String> recordTypeDeveloperNameById = getRecordTypeDeveloperNameById(pfrs, existingPfrMap);

        Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap = new Map<Id, List<Core_MDF_Campaign_Budgets__c>>();
        Map<Id, List<Core_MDF_Campaign_Budgets__c>> activeCampaignBudgetsForRatesMap = new Map<Id, List<Core_MDF_Campaign_Budgets__c>>();
        if (!campaignMap.isEmpty()) {
            for (Core_MDF_Campaign_Budgets__c cb : [SELECT Core_MDF_Campaign_Id__c, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Start_Date_Dt__c, Core_MDF_End_Date_Dt__c, Core_MDF_Reimbursement_Rate_Pct__c FROM Core_MDF_Campaign_Budgets__c WHERE Core_MDF_Campaign_Id__c IN :campaignMap.keySet() AND Core_MDF_Budget_Name_Id__r.TotalAllocatedAmount > 0 AND Core_MDF_Active_ind__c = true]) {
                if (!campaignBudgetsMap.containsKey(cb.Core_MDF_Campaign_Id__c)) {
                    campaignBudgetsMap.put(cb.Core_MDF_Campaign_Id__c, new List<Core_MDF_Campaign_Budgets__c>());
                }
                campaignBudgetsMap.get(cb.Core_MDF_Campaign_Id__c).add(cb);
            }
            for (Core_MDF_Campaign_Budgets__c cb : [SELECT Core_MDF_Campaign_Id__c, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Reimbursement_Rate_Pct__c FROM Core_MDF_Campaign_Budgets__c WHERE Core_MDF_Campaign_Id__c IN :campaignMap.keySet() AND Core_MDF_Active_ind__c = true]) {
                if (!activeCampaignBudgetsForRatesMap.containsKey(cb.Core_MDF_Campaign_Id__c)) {
                    activeCampaignBudgetsForRatesMap.put(cb.Core_MDF_Campaign_Id__c, new List<Core_MDF_Campaign_Budgets__c>());
                }
                activeCampaignBudgetsForRatesMap.get(cb.Core_MDF_Campaign_Id__c).add(cb);
            }
        }
        
        List<String> opalBudgetTypes = getConfiguredValues('Core_MDF_OPAL_BudgetTypes');
        List<PartnerFundRequest> validPfrs = new List<PartnerFundRequest>();

        for (PartnerFundRequest pfr : pfrs) {
            List<String> errors = new List<String>();
            errors.addAll(validateChannelPartnerUnchangedOnUpdate(pfr, existingPfrMap, isUpdateAction));
            if (!errors.isEmpty()) {
                validationFailures.add(buildValidationFailure(pfr, errors));
                continue;
            }

            PartnerFundRequest effectivePfr = buildEffectivePfr(pfr, existingPfrMap);
            String recType = recordTypeDeveloperNameById.get(effectivePfr.RecordTypeId);
            applyReimbursementRateFromBudget(pfr, effectivePfr, activeCampaignBudgetsForRatesMap);

            // On update, only validate the fields the external system actually sent in the payload, so an
            // update does not re-run the full create-time validation set on unchanged fields. On create,
            // every validation runs (incoming pfr fields below are simply non-null, so all flags are true).
            Boolean checkBudgetTypeReq = !isUpdateAction || pfr.Core_MDF_Budget_Type_nm__c != null || pfr.BudgetId != null;
            Boolean checkActivity = !isUpdateAction || pfr.Core_MDF_ActivityCategory__c != null || pfr.Core_MDF_Activity_Types__c != null;
            Boolean checkCountryGeoAlignment = !isUpdateAction || pfr.Core_MDF_Country_nm__c != null;
            Boolean checkCampaignFields = !isUpdateAction || isAnyCampaignAlignedFieldProvided(pfr);
            Boolean checkBudgetLink = !isUpdateAction || pfr.BudgetId != null;
            Boolean checkEcosystem = !isUpdateAction || pfr.Core_MDF_Channel_Partner__c != null;
            Boolean checkOtherEcosystem = !isUpdateAction || pfr.Core_MDF_Channel_Partner__c != null || pfr.Core_MDF_Other_Channel_Partner__c != null;
            Boolean checkMemberAcceptor = !isUpdateAction || pfr.Core_MDF_Member_Acceptor_Id__c != null;
            // Conditional mandatory + Event Name / Domain Type picklist checks run on create, and on
            // update when any field that drives them is part of the payload.
            Boolean checkConditional = !isUpdateAction
                || pfr.Core_MDF_ActivityCategory__c != null || pfr.Core_MDF_Activity_Types__c != null
                || pfr.Core_MDF_Event_Name_nm__c != null || pfr.Core_MDF_Other_Event_Name_txt__c != null
                || pfr.Core_MDF_Domain_Type_nm__c != null;
            // New validations for Activity Sub Type and Start Date
            Boolean checkSubType = !isUpdateAction || pfr.Core_MDF_Activity_SubType_nm__c != null || pfr.Core_MDF_Activity_Types__c != null;
            Boolean checkPastDated = !isUpdateAction || pfr.Core_MDF_Start_Date__c != null;
            Boolean checkEventActivityAdvanceSubmission = !isUpdateAction || pfr.Core_MDF_Budget_Type_nm__c != null || pfr.Core_MDF_ActivityCategory__c != null || pfr.Core_MDF_Budget_Amount_Local_amt__c != null || pfr.Core_MDF_Start_Date__c != null;

            // On create, the record type must resolve from the Campaign program (CCF/DCF).
            if (!isUpdateAction && effectivePfr.RecordTypeId == null && effectivePfr.CampaignId != null && campaignMap.containsKey(effectivePfr.CampaignId)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9026_PROGRAM_RECORDTYPE_UNRESOLVED, new List<String>{ String.valueOf(campaignMap.get(effectivePfr.CampaignId).Core_MDF_Program__c) }));
            }

            if (checkBudgetTypeReq && opalBudgetTypes.contains(effectivePfr.Core_MDF_Budget_Type_nm__c) && effectivePfr.BudgetId == null) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9024_BUDGET_ID_REQUIRED, new List<String>{ effectivePfr.Core_MDF_Budget_Type_nm__c }));
            }
            // Create-page required-field checks apply to record creation only, not to partial updates.
            if (!isUpdateAction) {
                errors.addAll(validateCreatePageRequiredFields(effectivePfr, campaignMap));
            }
            if (checkActivity) {
                errors.addAll(validateActivityCategoryAndType(effectivePfr, campaignMap.get(effectivePfr.CampaignId)));
            }

            // NEW: Conditional mandatory fields and Event Name / Domain Type picklist value checks.
            if (checkConditional) {
                errors.addAll(validateEventNameAndDomainType(effectivePfr));
                errors.addAll(validateConditionalMandatoryFields(effectivePfr));
            }

            // NEW: Validate Activity Sub Type for dependent picklists
            if (checkSubType) {
                errors.addAll(validateActivitySubType(effectivePfr));
            }

            // NEW: Validate Start Date is not in the past
            if (checkPastDated) {
                errors.addAll(validatePastDatedActivityReason(effectivePfr));
            }

            // NEW: Validate Event Activity Advance Submission (60 days for qualifying activities)
            if (checkEventActivityAdvanceSubmission) {
                errors.addAll(validateEventActivityAdvanceSubmission(effectivePfr));
            }

            // NEW: Validate Reimbursement Rate
            errors.addAll(validateReimbursementRate(effectivePfr, activeCampaignBudgetsForRatesMap));

            // NEW: Validate submitted countries belong to a single country-to-geo mapping region
            if (checkCountryGeoAlignment) {
                errors.addAll(validateCountryGeoAlignment(effectivePfr.Core_MDF_Country_nm__c));
            }

            // NEW: Validate campaign field values are present on campaign record
            if (checkCampaignFields) {
                errors.addAll(validateCampaignFieldValues(effectivePfr, campaignMap));
            }

            // NEW: Validate Budget is linked to the Campaign and Channel Partner via Program
            if (checkBudgetLink) {
                errors.addAll(validateBudgetLinkedToCampaign(effectivePfr, recType, campaignBudgetsMap));
                errors.addAll(validateClaimAvailableAmount(effectivePfr));
            }

            // NEW: Validate Ecosystem Partner eligibility
            if (checkEcosystem) {
                errors.addAll(validateEcosystemPartner(effectivePfr, campaignMap));
            }

            // NEW: Validate Other Ecosystem Partner when Ecosystem Partner is "Others"
            if (checkOtherEcosystem) {
                errors.addAll(validateOtherEcosystemPartner(effectivePfr));
            }

            // NEW: Validate Member Acceptor eligibility
            if (checkMemberAcceptor) {
                errors.addAll(validateMemberAcceptor(effectivePfr, recType));
            }

            if (!errors.isEmpty()) {
                validationFailures.add(buildValidationFailure(pfr, errors));
                continue;
            }

            // Keep legacy ReimbursementAmt blank so Intel Contribution formula uses rate-based inputs.
            calculateReimbursementValues(pfr, effectivePfr);
            
            // NEW: Normalize reimbursement rate by appending % symbol
            normalizeReimbursementRate(pfr);

            if (!isUpdateAction) {
                errors.addAll(calculateRequestedAmountAndExchangeRate(pfr));
            }

            if (!errors.isEmpty()) {
                validationFailures.add(buildValidationFailure(pfr, errors));
                continue;
            }
            
            normalizeApiOnlyDefaults(pfr, effectivePfr, recType, isUpdateAction);
            validPfrs.add(pfr);
        }

        pfrs.clear();
        pfrs.addAll(validPfrs);
        return validationFailures;
    }

    private static void applyReimbursementRateFromBudget(PartnerFundRequest incomingPfr, PartnerFundRequest effectivePfr, Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap) {
        String rate = getReimbursementRateFromBudget(effectivePfr, campaignBudgetsMap);
        if (String.isBlank(rate)) {
            return;
        }
        incomingPfr.Core_MDF_Reimbursement_Rate_txt__c = rate;
        effectivePfr.Core_MDF_Reimbursement_Rate_txt__c = rate;
    }

    private static String getReimbursementRateFromBudget(PartnerFundRequest pfr, Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap) {
        if (pfr == null || pfr.CampaignId == null || pfr.BudgetId == null || campaignBudgetsMap == null || !campaignBudgetsMap.containsKey(pfr.CampaignId)) {
            return null;
        }
        for (Core_MDF_Campaign_Budgets__c campaignBudget : campaignBudgetsMap.get(pfr.CampaignId)) {
            if (campaignBudget.Core_MDF_Budget_Name_Id__c == pfr.BudgetId && campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c != null) {
                return formatRateValue(campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c);
            }
        }
        return null;
    }

    /**
     * Builds one API failure response item for a PFR and its validation messages.
     */
    public static Core_MDF_PFR_RestAPI_Response.ErrorContent buildValidationFailure(PartnerFundRequest pfr, List<String> errors) {
        Core_MDF_PFR_RestAPI_Response.ErrorContent failure =
            new Core_MDF_PFR_RestAPI_Response.ErrorContent();
        failure.pfrId = pfr.Id;
        failure.pfrName = pfr.Title;
        failure.errors.addAll(errors);
        return failure;
    }

    /**
     * Validates fields that are required by the PFR create page rules for the effective record type.
     */
    private static List<String> validateCreatePageRequiredFields(PartnerFundRequest pfr, Map<Id, Campaign> campaignMap) {
        List<String> errors = new List<String>();

        if (pfr.CampaignId == null && pfr.Core_MDF_Is_Outcome_Based_Ind__c != true) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9210_CAMPAIGN_REQUIRED_MESSAGE));
        }
        if (pfr.ChannelPartnerId == null) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9211_CHANNEL_PARTNER_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_TargetAudience__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9212_TARGET_AUDIENCE_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_Brand_nm__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9213_BRAND_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_ActivityCategory__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9214_ACTIVITY_CATEGORY_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_Activity_Types__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9215_ACTIVITY_TYPE_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_Country_nm__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9216_MARKET_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_Priorities__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9217_PRIORITY_REQUIRED_MESSAGE));
        }
        if (String.isBlank(pfr.Core_MDF_Channel_Partner__c)) {
            errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9218_ECOSYSTEM_PARTNER_REQUIRED_MESSAGE));
        }
        // Intel Owner validation: rules depend on budget type
        if (String.isBlank(pfr.Core_MDF_Intel_Activity_Owner_Id__c)) {
            String normalizedBudgetType = String.isBlank(pfr.Core_MDF_Budget_Type_nm__c) ? '' : pfr.Core_MDF_Budget_Type_nm__c.replaceAll('\\s+', '').toLowerCase();
            Decimal intelContribution = calculateIntelContributionAmount(pfr);
            Boolean requireIntelOwner = false;
            
            if (normalizedBudgetType == 'oemcmp') {
                // OEM CMP: Check campaign approval checkbox (Core_MDF_Activity_Approval_Required_Ind__c)
                // If checkbox is YES → Intel Owner required; If NO → Allow without Intel Owner
                Campaign campaign = (pfr.CampaignId != null && campaignMap.containsKey(pfr.CampaignId)) ? campaignMap.get(pfr.CampaignId) : null;
                requireIntelOwner = (campaign != null && campaign.Core_MDF_Activity_Approval_Required_Ind__c == true);
            } else if (normalizedBudgetType == 'serviceprovidercmp') {
                // Service Provider CMP: Required only if IntelContribution > $50,000
                requireIntelOwner = (intelContribution != null && intelContribution > 50000);
            } else {
                // MDF and other budget types: Always required
                requireIntelOwner = true;
            }
            
            if (requireIntelOwner) {
                errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9219_INTEL_OWNER_REQUIRED_MESSAGE));
            }
        }
        if (isEventActivityType(pfr.Core_MDF_Activity_Types__c)) {
            if (String.isBlank(pfr.Core_MDF_Event_Name_nm__c)) {
                errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9220_EVENT_NAME_REQUIRED_MESSAGE));
            }
            if (OTHER_EVENT_NAME.equalsIgnoreCase(pfr.Core_MDF_Event_Name_nm__c) &&
                String.isBlank(pfr.Core_MDF_Other_Event_Name_txt__c)) {
                errors.add(getCreatePageRequiredFieldMessage(Core_MDF_PFR_RestAPI_Constants.ERR_9221_OTHER_EVENT_NAME_REQUIRED_MESSAGE));
            }
        }

        return errors;
    }

    /**
     * Validates activity category/type picklist values, dependencies, and campaign-allowed values.
     */
    private static List<String> validateActivityCategoryAndType(PartnerFundRequest pfr, Campaign campaignRecord) {
        List<String> errors = new List<String>();
        String category = pfr.Core_MDF_ActivityCategory__c;
        String activityType = pfr.Core_MDF_Activity_Types__c;
        String budgetType = pfr.Core_MDF_Budget_Type_nm__c;

        if (String.isBlank(category) || String.isBlank(activityType)) {
            return errors;
        }
        
        // Validate budget type restrictions for OEM CMP and Service Provider CMP
        if (String.isNotBlank(budgetType) && (budgetType == 'OEM CMP' || budgetType == 'Service Provider CMP')) {
            if (category.contains('Buyer Incentive') || category.contains('Seller Incentive') ||
                activityType.contains('Seller Incentive') || activityType.contains('Buyer Incentive')) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9222_INCENTIVE_NOT_ALLOWED_FOR_BUDGET, null));
                return errors;
            }
        }

        Set<String> validCategories = getActivePicklistValues(PFR_OBJECT_NAME, ACTIVITY_CATEGORY_FIELD);
        if (!validCategories.isEmpty() && !validCategories.contains(category)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9030_INVALID_ACT_CAT, new List<String>{ category, formatAllowedValues(validCategories) }));
            return errors;
        }

        Set<String> validActivityTypes = getActivePicklistValues(PFR_OBJECT_NAME, ACTIVITY_TYPE_FIELD);

        Map<Object, List<Map<String, String>>> dependentValues =
            getFieldDependenciesMaps(PFR_OBJECT_NAME, ACTIVITY_CATEGORY_FIELD, ACTIVITY_TYPE_FIELD);

        // Activity types the external system may actually select for this category (and campaign, when restricted).
        List<String> allowedActivityTypes = getAllowedActivityTypes(category, dependentValues, campaignRecord, validActivityTypes);

        if (!validActivityTypes.isEmpty() && !validActivityTypes.contains(activityType)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9031_INVALID_ACT_TYPE, new List<String>{ activityType, formatAllowedValues(allowedActivityTypes) }));
            return errors;
        }

        if (dependentValues.containsKey(category) && !containsDependentValue(dependentValues.get(category), activityType)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9032_DEPENDENT_ACT_TYPE, new List<String>{ activityType, category, formatAllowedValues(allowedActivityTypes) }));
        }

        if (campaignRecord != null) {
            if (String.isNotBlank(campaignRecord.Core_MDF_Activity_Category__c) &&
                !campaignRecord.Core_MDF_Activity_Category__c.split(';').contains(category)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9033_CAMP_CAT_NOT_ALLOWED, new List<String>{ category, formatAllowedValues(campaignRecord.Core_MDF_Activity_Category__c) }));
            }
            if (String.isNotBlank(campaignRecord.Core_MDF_Activity_Type__c) &&
                !campaignRecord.Core_MDF_Activity_Type__c.split(';').contains(activityType)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9034_CAMP_TYPE_NOT_ALLOWED, new List<String>{ activityType, formatAllowedValues(campaignRecord.Core_MDF_Activity_Type__c) }));
            }
        }

        return errors;
    }

    /**
     * Returns the Activity Types the external system may select for the given Activity Category.
     * Uses the category's dependent picklist values when a dependency is configured (otherwise all active
     * Activity Types), and further restricts the list to the Campaign-allowed Activity Types when the
     * Campaign limits them. This drives the "Allowed values" shown for ERR-9031/ERR-9032.
     * 
     * IMPORTANT: Only includes active picklist values in the returned list. Inactive values (like 
     * "Offer - Rewards") are filtered out so they do not appear in error messages.
     */
    private static List<String> getAllowedActivityTypes(String category, Map<Object, List<Map<String, String>>> dependentValues,
        Campaign campaignRecord, Set<String> validActivityTypes) {
        List<String> categoryTypes = new List<String>();

        if (dependentValues != null && dependentValues.containsKey(category)) {
            for (Map<String, String> dependentValue : dependentValues.get(category)) {
                String value = dependentValue.get('value');
                if (String.isNotBlank(value)) {
                    String trimmedValue = value.trim();
                    // Only include this value if it's in the active picklist values set
                    if (validActivityTypes != null && validActivityTypes.contains(trimmedValue)) {
                        categoryTypes.add(trimmedValue);
                    }
                }
            }
        } else if (validActivityTypes != null) {
            // No dependency configured for this category: fall back to all active Activity Types.
            categoryTypes.addAll(validActivityTypes);
        }

        // Restrict to Campaign-allowed Activity Types when the Campaign limits them.
        if (campaignRecord != null && String.isNotBlank(campaignRecord.Core_MDF_Activity_Type__c)) {
            Set<String> campaignTypes = splitValuesToLowercaseSet(campaignRecord.Core_MDF_Activity_Type__c);
            List<String> restricted = new List<String>();
            for (String type : categoryTypes) {
                if (campaignTypes.contains(type.toLowerCase())) {
                    restricted.add(type);
                }
            }
            return restricted;
        }

        return categoryTypes;
    }

    /**
     * Checks whether a submitted dependent picklist value is allowed for its controlling value.
     */
    private static Boolean containsDependentValue(List<Map<String, String>> dependentValues, String submittedValue) {
        if (dependentValues == null) {
            return false;
        }

        for (Map<String, String> dependentValue : dependentValues) {
            if (dependentValue.get('value') == submittedValue) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns active picklist values for an object field, or an empty set when the field cannot be described.
     */
    private static Set<String> getActivePicklistValues(String objectApiName, String fieldApiName) {
        Set<String> values = new Set<String>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType == null || !objectType.getDescribe().fields.getMap().containsKey(fieldApiName)) {
            return values;
        }

        for (Schema.PicklistEntry entry : objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                values.add(entry.getValue());
            }
        }
        return values;
    }

    /**
     * Checks whether the submitted activity type is one of the configured event activity types.
     * Pre-2025 variants (e.g. "Third Party Event (Pre-2025)") are normalised by stripping the
     * "(Pre-2025)" suffix before comparison so they resolve to the same base type.
     */
    private static Boolean isEventActivityType(String activityType) {
        if (String.isBlank(activityType)) {
            return false;
        }
        // Existing check — exact match for standard (non-pre-2025) activity types
        if (Core_MDF_CCP_ConstantClass.EVENT_ACTIVITY_TYPE.split(',').contains(activityType)) {
            return true;
        }
        // Strip "(Pre-2025)" suffix so pre-2025 variants match their base event type
        String baseType = activityType.replaceAll('(?i)\\s*\\(Pre-2025\\)\\s*$', '').trim();
        return Core_MDF_CCP_ConstantClass.EVENT_ACTIVITY_TYPE.split(',').contains(baseType);
    }

    /**
     * Retrieves a Create Page Required Field validation message from custom settings.
     * These messages are used for required field validations during activity create/edit operations.
     * @param errorCode Error code from the 9210-9221 series
     * @return Formatted validation message from custom settings
     */
    private static String getCreatePageRequiredFieldMessage(String errorCode) {
        return Core_MDF_PFR_RestAPI_Constants.formatError(errorCode, null);
    }

    /**
     * Applies REST API-only default values, external-user flags, and allocation defaults before DML.
     */
    private static void normalizeApiOnlyDefaults(PartnerFundRequest incomingPfr, PartnerFundRequest effectivePfr, String recType, Boolean isUpdateAction) {
        if (!isUpdateAction) {
            incomingPfr.Core_MDF_EndTime_dtm__c = System.now();
            // UI computes RequestedAmount; in REST payload this field is optional.
            // To avoid create-time REQUIRED_FIELD_MISSING, default it from Budget Amount Local
            // when the caller does not provide RequestedAmount.
            /*if (incomingPfr.RequestedAmount == null && effectivePfr.Core_MDF_Budget_Amount_Local_amt__c != null) {
                incomingPfr.RequestedAmount = effectivePfr.Core_MDF_Budget_Amount_Local_amt__c;
            }*/
        }
        if (UserInfo.getUserType() == getLabelValue('Core_MDF_Partner_User_Type')) {
            incomingPfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
            incomingPfr.Core_MDF_Is_Field_Modified__c = false;
        }
        if (effectivePfr.BudgetId != null && shouldPopulateAllocation(effectivePfr, recType)) {
            incomingPfr.AllocationId = getOrCreateAllocationId(effectivePfr.BudgetId, effectivePfr.ChannelPartnerId);
        }
    }

    /**
     * Determines whether an activity should automatically receive an allocation.
     * Budget-type eligibility is enforced earlier by campaign budget validation.
     */
    private static Boolean shouldPopulateAllocation(PartnerFundRequest pfr, String recType) {
        if (String.isBlank(recType) || pfr.BudgetId == null || pfr.ChannelPartnerId == null) {
            return false;
        }

        return getSafeLabel('Core_MDF_CCFDCF_RecordType_API_Name', '').contains(recType);
    }

    /**
     * Finds an existing PartnerFundAllocation for a budget/account pair or creates one when none exists.
     */
    public static Id getOrCreateAllocationId(Id budgetId, Id activityAccountId) {
        for (PartnerFundAllocation pfa : [SELECT Id FROM PartnerFundAllocation WHERE BudgetId = :budgetId AND ChannelPartnerId = :activityAccountId LIMIT 1]) {
            return pfa.Id;
        }

        PartnerMarketingBudget pmb = [SELECT Id, Title, Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c FROM PartnerMarketingBudget WHERE Id = :budgetId LIMIT 1];

        Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  recTypeMetaData = [SELECT Core_MDF_Allocation_RecordType_txt__c FROM Core_MDF_ObjRecType_Budget_FieldSetMap__mdt WHERE Core_MDF_Channel_Program_Name_txt__c = :pmb.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c LIMIT 1];
        PartnerFundAllocation pfa = new PartnerFundAllocation(
            Title = pmb.Title,
            RecordTypeId = Schema.SObjectType.PartnerFundAllocation
                .getRecordTypeInfosByDeveloperName()
                .get(recTypeMetaData.Core_MDF_Allocation_RecordType_txt__c)
                .getRecordTypeId(),
            BudgetId = budgetId,
            ChannelPartnerId = activityAccountId,
            Amount = 0
        );
        insert pfa;
        return pfa.Id;
    }

    /**
     * Loads existing PFR records needed to build effective update records for sparse update payloads.
     */
    public static Map<Id, PartnerFundRequest> getExistingPfrMap(List<PartnerFundRequest> pfrs) {
        Set<Id> pfrIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrs) {
            if (pfr.Id != null) {
                pfrIds.add(pfr.Id);
            }
        }

        if (pfrIds.isEmpty()) {
            return new Map<Id, PartnerFundRequest>();
        }

        return new Map<Id, PartnerFundRequest>([SELECT Id, RecordTypeId, CampaignId, ChannelPartnerId, BudgetId, AllocationId, RequestedAmount, Amount, Status, Core_MDF_Budget_Type_nm__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Fund_Request_Status__c, Core_MDF_Approval_Stage__c, Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Proposal_Based_Ind__c, Core_MDF_Focus_Area_nm__c, Core_MDF_TargetAudience__c, Core_MDF_TargetAudience_nm__c, Core_MDF_Brand_nm__c, Core_MDF_Initiative_nm__c, Core_MDF_ActivityCategory__c, Core_MDF_Activity_Types__c, Core_MDF_Country_nm__c, Core_MDF_Priorities__c, Core_MDF_Industry_Multi_nm__c, Core_MDF_Priority_nm__c, Core_MDF_ProductType__c, Core_MDF_Channel_Partner__c, Core_MDF_Program__c, Core_MDF_Technology_txt__c, Core_MDF_Outcomes_nm__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Core_MDF_Member_Acceptor_Id__c, Core_MDF_Member_Owner_txt__c, Core_MDF_Event_Name_nm__c, Core_MDF_Other_Event_Name_txt__c, Core_MDF_Domain_Type_nm__c, Core_MDF_Activity_SubType_nm__c, Core_MDF_Opportunity_id__c FROM PartnerFundRequest WHERE Id IN :pfrIds]);
    }

    /**
     * Loads Campaign records referenced by incoming or existing PFRs so validators can compare campaign-aligned fields.
     */
    private static Map<Id, Campaign> getCampaignMap(List<PartnerFundRequest> pfrs, Map<Id, PartnerFundRequest> existingPfrMap) {
        Set<Id> campaignIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrs) {
            PartnerFundRequest effectivePfr = buildEffectivePfr(pfr, existingPfrMap);
            if (effectivePfr.CampaignId != null) {
                campaignIds.add(effectivePfr.CampaignId);
            }
        }

        if (campaignIds.isEmpty()) {
            return new Map<Id, Campaign>();
        }

        return new Map<Id, Campaign>([SELECT Id, RecordTypeId,RecordType.Name, RecordType.DeveloperName, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c, Core_MDF_Priority_3_nm__c, Core_MDF_Audience__c, Core_MDF_Market__c, Core_MDF_Brand__c, Core_MDF_Product_Type__c, Core_MDF_Industry_Nm__c, Core_MDF_Program__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Name, Core_MDF_Account__c, Core_MDF_Activity_Approval_Required_Ind__c, StartDate, EndDate FROM Campaign WHERE Id IN :campaignIds]);
    }

    /**
     * Resolves record type Ids from incoming/effective PFRs to their developer names.
     */
    private static Map<Id, String> getRecordTypeDeveloperNameById(List<PartnerFundRequest> pfrs, Map<Id, PartnerFundRequest> existingPfrMap) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrs) {
            if (pfr.RecordTypeId != null) {
                recordTypeIds.add(pfr.RecordTypeId);
            } else if (pfr.Id != null && existingPfrMap.containsKey(pfr.Id)) {
                recordTypeIds.add(existingPfrMap.get(pfr.Id).RecordTypeId);
            }
        }

        Map<Id, String> result = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'PartnerFundRequest' AND Id IN :recordTypeIds]) {
            result.put(rt.Id, rt.DeveloperName);
        }
        return result;
    }

    /**
     * On create, derives the PartnerFundRequest record type from the related Campaign's program and
     * stamps it onto each record whose record type is not already set. Client programs map to the
     * CCF record type and Data Center programs map to the DCF record type. Records whose program
    * cannot be mapped are left without a record type so 9026 is reported in the main loop.
     */
    private static void applyRecordTypeFromCampaignProgram(List<PartnerFundRequest> pfrs, Map<Id, Campaign> campaignMap) {
        for (PartnerFundRequest pfr : pfrs) {
            if (pfr.RecordTypeId != null || pfr.CampaignId == null || !campaignMap.containsKey(pfr.CampaignId)) {
                continue;
            }
            String developerName = getRecordTypeDeveloperNameForProgram(campaignMap.get(pfr.CampaignId).Core_MDF_Program__c);
            if (String.isNotBlank(developerName)) {
                Id recordTypeId = getRecordTypeIdByDeveloperName(developerName);
                if (recordTypeId != null) {
                    pfr.RecordTypeId = recordTypeId;
                }
            }
        }
    }

    /**
     * Maps a Campaign program value to the CCF/DCF PartnerFundRequest record type developer name.
     * Returns null when the program is blank or does not correspond to a Client or Data Center program.
     */
    public static String getRecordTypeDeveloperNameForProgram(String program) {
        if (String.isBlank(program)) {
            return null;
        }
        String normalized = program.toLowerCase();
        String normalizedCompact = normalized.replace(' ', '');
        if (normalizedCompact.contains('datacenter') || normalized.contains('dcf')) {
            return Core_MDF_PFR_RestAPI_Constants.RECORD_TYPE_DCF;
        }
        if (normalized.contains('client') || normalized.contains('ccf')) {
            return Core_MDF_PFR_RestAPI_Constants.RECORD_TYPE_CCF;
        }
        return null;
    }

    /**
     * Returns the PartnerFundRequest record type Id for a developer name, or null when not found.
     */
    private static Id getRecordTypeIdByDeveloperName(String developerName) {
        Schema.RecordTypeInfo info = Schema.SObjectType.PartnerFundRequest
            .getRecordTypeInfosByDeveloperName()
            .get(developerName);
        return info != null ? info.getRecordTypeId() : null;
    }

    /**
     * Validates the conditionally-mandatory fields driven by the Activity Category / Activity Type:
     *  - Activity Type starts with "Other": Validation error with message to select different Activity Types.
     *  - Activity Category = Event and Activity Type starts with "Other": Event Name and Other Event Name
     *    are mandatory.
     *  - Activity Category = Digital: Domain Type is mandatory.
     *  - Activity Type does NOT start with "Other": Attribution Requirements and POP Requirements must be blank.
     */
    private static List<String> validateConditionalMandatoryFields(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        String category = pfr.Core_MDF_ActivityCategory__c;
        String activityType = pfr.Core_MDF_Activity_Types__c;
        Boolean activityTypeIncludesOther = String.isNotBlank(activityType) && activityType.toLowerCase().startsWith(EVENT_TYPE);
        if (activityTypeIncludesOther) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9237_SELECT_DIFFERENT_ACTIVITY_TYPES, null));
        }
        if (EVENT_NAME.equalsIgnoreCase(category) && activityTypeIncludesOther) {
            if (String.isBlank(pfr.Core_MDF_Event_Name_nm__c)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9092_EVENT_NAME_REQUIRED);
            }
            if (String.isBlank(pfr.Core_MDF_Other_Event_Name_txt__c)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9093_OTHER_EVENT_NAME_REQUIRED);
            }
        }

        if ('Digital'.equalsIgnoreCase(category) && String.isBlank(pfr.Core_MDF_Domain_Type_nm__c)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9094_DOMAIN_TYPE_REQUIRED);
        }

        return errors;
    }

    /**
     * Validates that submitted Event Name and Domain Type values are valid picklist values, returning
     * an error enriched with the list of allowed values (same style as the Activity Category/Type
     * picklist validations) when the external system provides an invalid value.
     */
    private static List<String> validateEventNameAndDomainType(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();

        if ((String.isNotBlank(pfr.Core_MDF_Event_Name_nm__c) || String.isNotBlank(pfr.Core_MDF_Other_Event_Name_txt__c)) &&
            !isEventCategory(pfr.Core_MDF_ActivityCategory__c)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9038_EVENT_NAME_NOT_ALLOWED);
            return errors;
        }

        if (String.isNotBlank(pfr.Core_MDF_Event_Name_nm__c)) {
            Set<String> validEventNames = getActivePicklistValues(PFR_OBJECT_NAME, 'Core_MDF_Event_Name_nm__c');
            if (!validEventNames.isEmpty() && !validEventNames.contains(pfr.Core_MDF_Event_Name_nm__c)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9035_INVALID_EVENT_NAME, new List<String>{ pfr.Core_MDF_Event_Name_nm__c, formatAllowedValues(validEventNames) }));
            }
        }

        if (String.isNotBlank(pfr.Core_MDF_Domain_Type_nm__c)) {
            Set<String> validDomainTypes = getActivePicklistValues(PFR_OBJECT_NAME, 'Core_MDF_Domain_Type_nm__c');
            if (!validDomainTypes.isEmpty() && !validDomainTypes.contains(pfr.Core_MDF_Domain_Type_nm__c)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9036_INVALID_DOMAIN_TYPE, new List<String>{ pfr.Core_MDF_Domain_Type_nm__c, formatAllowedValues(validDomainTypes) }));
            }
        }

        return errors;
    }

    private static Boolean isEventCategory(String activityCategory) {
        return String.isNotBlank(activityCategory) && activityCategory.trim().equalsIgnoreCase(EVENT_NAME);
    }

    /**
     * Merges sparse incoming update fields over the existing PFR so validation sees the effective final record.
     */
    private static PartnerFundRequest buildEffectivePfr(PartnerFundRequest incomingPfr, Map<Id, PartnerFundRequest> existingPfrMap) {
        PartnerFundRequest effectivePfr = incomingPfr.Id != null && existingPfrMap.containsKey(incomingPfr.Id)
            ? existingPfrMap.get(incomingPfr.Id).clone(true, true, false, false)
            : new PartnerFundRequest();

        Map<String, Object> populatedFields = incomingPfr.getPopulatedFieldsAsMap();
        for (String fieldName : populatedFields.keySet()) {
            effectivePfr.put(fieldName, populatedFields.get(fieldName));
        }
        return effectivePfr;
    }

    /**
     * Blocks update requests that attempt to change ChannelPartnerId, including values resolved from account aliases.
     */
    private static List<String> validateChannelPartnerUnchangedOnUpdate(
        PartnerFundRequest incomingPfr,
        Map<Id, PartnerFundRequest> existingPfrMap,
        Boolean isUpdateAction
    ) {
        List<String> errors = new List<String>();
        if (!isUpdateAction || incomingPfr.Id == null || !existingPfrMap.containsKey(incomingPfr.Id)) {
            return errors;
        }

        Map<String, Object> incomingFields = incomingPfr.getPopulatedFieldsAsMap();
        if (!incomingFields.containsKey('ChannelPartnerId')) {
            return errors;
        }

        Id incomingChannelPartnerId = (Id) incomingFields.get('ChannelPartnerId');
        Id existingChannelPartnerId = existingPfrMap.get(incomingPfr.Id).ChannelPartnerId;
        if (incomingChannelPartnerId != existingChannelPartnerId) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9025_ACCOUNT_UPDATE_NOT_ALLOWED);
        }

        return errors;
    }

    /**
     * Reads a semicolon-delimited configuration value from a label and returns it as a list.
     */
    private static List<String> getConfiguredValues(String labelApiName) {
        String labelValue = getLabelValue(labelApiName);
        return String.isNotBlank(labelValue) ? labelValue.split(';') : new List<String>();
    }

    /**
     * Returns a label value when present, otherwise returns a safe fallback.
     */
    private static String getSafeLabel(String labelApiName, String fallbackValue) {
        String labelValue = getLabelValue(labelApiName);
        return String.isNotBlank(labelValue) ? labelValue : fallbackValue;
    }

    /**
     * Safely reads a standard Salesforce label by API name and returns null when unavailable.
     */
    private static String getLabelValue(String labelApiName) {
        if (String.isBlank(labelApiName)) {
            return null;
        }

        try {
            return Label.get('', labelApiName.trim());
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }

    /**
     * @description Validates that payload field values exist on the provided campaign record
     * Checks: Priority, Target Audience, Country, Brand, Product Type, Industry
     * Only allows values that are present (non-blank) on the Campaign record
     */
    /**
     * Returns true when the incoming payload includes any campaign-aligned field value
     * (priority, target audience, country, brand, product type or industry). Used to decide
     * whether the campaign-field validation needs to run for an update.
     */
    private static Boolean isAnyCampaignAlignedFieldProvided(PartnerFundRequest pfr) {
        return pfr.Core_MDF_Priorities__c != null || pfr.Core_MDF_Priority_nm__c != null
            || pfr.Core_MDF_TargetAudience__c != null || pfr.Core_MDF_TargetAudience_nm__c != null
            || pfr.Core_MDF_Country_nm__c != null || pfr.Core_MDF_Brand_nm__c != null
            || pfr.Core_MDF_ProductType__c != null || pfr.Core_MDF_Industry_Multi_nm__c != null;
    }

    public static List<String> validateCampaignFieldValues(PartnerFundRequest pfr, Map<Id, Campaign> campaignMap) {
        List<String> errors = new List<String>();

        if (pfr.CampaignId == null || !campaignMap.containsKey(pfr.CampaignId)) {
            return errors; // No campaign to validate against
        }
        
        Campaign campaign = campaignMap.get(pfr.CampaignId);
        
        // Lists of payload field values to validate against campaign values, to reduce code duplication
        List<String> pfrValues = new List<String>{
            pfr.Core_MDF_Priorities__c, pfr.Core_MDF_Priority_nm__c,
            pfr.Core_MDF_TargetAudience__c, pfr.Core_MDF_TargetAudience_nm__c,
            pfr.Core_MDF_Country_nm__c, pfr.Core_MDF_Brand_nm__c,
            pfr.Core_MDF_ProductType__c, pfr.Core_MDF_Industry_Multi_nm__c
        };
        // Corresponding campaign values
        String allCampaignPriorities = (String.isNotBlank(campaign.Core_MDF_Priority__c) ? campaign.Core_MDF_Priority__c + ';' : '') +
                                       (String.isNotBlank(campaign.Core_MDF_Priority_2_nm__c) ? campaign.Core_MDF_Priority_2_nm__c + ';' : '') +
                                       (String.isNotBlank(campaign.Core_MDF_Priority_3_nm__c) ? campaign.Core_MDF_Priority_3_nm__c + ';' : '');
        
        List<String> campValues = new List<String>{
            allCampaignPriorities, allCampaignPriorities,
            campaign.Core_MDF_Audience__c, campaign.Core_MDF_Audience__c,
            campaign.Core_MDF_Market__c, campaign.Core_MDF_Brand__c,
            campaign.Core_MDF_Product_Type__c, campaign.Core_MDF_Industry_Nm__c
        };
        // Corresponding error codes
        List<String> errorCodes = new List<String>{
            Core_MDF_PFR_RestAPI_Constants.ERR_9040_PRIORITY_MISMATCH, Core_MDF_PFR_RestAPI_Constants.ERR_9040_PRIORITY_MISMATCH,
            Core_MDF_PFR_RestAPI_Constants.ERR_9041_AUDIENCE_MISMATCH, Core_MDF_PFR_RestAPI_Constants.ERR_9041_AUDIENCE_MISMATCH,
            Core_MDF_PFR_RestAPI_Constants.ERR_9042_MARKET_MISMATCH, Core_MDF_PFR_RestAPI_Constants.ERR_9043_BRAND_MISMATCH,
            Core_MDF_PFR_RestAPI_Constants.ERR_9044_PRODUCT_TYPE_MISMATCH, Core_MDF_PFR_RestAPI_Constants.ERR_9045_INDUSTRY_MISMATCH
        };

        // Validate all configured fields: every submitted semicolon-delimited value must exist on the Campaign field.
        for(Integer i = 0; i < pfrValues.size(); i++) {
            if (String.isNotBlank(pfrValues[i])) {
                // Only the submitted values that are NOT available on the Campaign are reported as invalid
                // (important for multi-select picklists, so we don't flag the whole list because of one bad value).
                List<String> invalidValues = getInvalidSubmittedValues(campValues[i], pfrValues[i]);
                if (!invalidValues.isEmpty()) {
                    errors.add(formatCampaignFieldMismatchError(
                        errorCodes[i],
                        pfrValues[i],
                        String.join(invalidValues, '; '),
                        formatAllowedValues(campValues[i])
                    ));
                }
            }
        }
        
        return errors;
    }

    private static List<String> validateCountryGeoAlignment(String submittedCountries) {
        List<String> errors = new List<String>();
        Set<String> selectedCountryKeys = splitValuesToLowercaseSet(submittedCountries);
        if (selectedCountryKeys.size() <= 1) {
            return errors;
        }

        Set<String> selectedGeos = new Set<String>();
        for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMapping : [
            SELECT Label, Core_MDF_All_Other_APJ_Ind__c, Core_MDF_Geo__c
            FROM Core_MDF_CCP_Country_Geo_Mapping__mdt
        ]) {
            String countryLabelKey = String.isBlank(countryGeoMapping.Label) ? null : countryGeoMapping.Label.trim().toLowerCase();
            if (String.isBlank(countryLabelKey) || !selectedCountryKeys.contains(countryLabelKey)) {
                continue;
            }

            String geo = countryGeoMapping.Core_MDF_Geo__c;
            if (String.isBlank(geo) && countryGeoMapping.Core_MDF_All_Other_APJ_Ind__c == true) {
                geo = 'APJ';
            }
            if (String.isNotBlank(geo)) {
                selectedGeos.add(geo.trim().toLowerCase());
            }
        }

        if (selectedGeos.size() > 1) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9204_COUNTRY_GEO_MISMATCH, null));
        }
        return errors;
    }

    /**
     * Returns the submitted (semicolon-delimited) values that are NOT present in the available value list,
     * preserving their original casing. An empty list means every submitted value is allowed.
     */
    private static List<String> getInvalidSubmittedValues(String availableValues, String submittedValues) {
        List<String> invalidValues = new List<String>();
        Set<String> availableValueSet = splitValuesToLowercaseSet(availableValues);
        for (String submittedValue : submittedValues.split(';')) {
            String trimmedValue = submittedValue != null ? submittedValue.trim() : '';
            if (String.isNotBlank(trimmedValue) && !availableValueSet.contains(trimmedValue.toLowerCase())) {
                invalidValues.add(trimmedValue);
            }
        }
        return invalidValues;
    }

    /**
     * Splits semicolon-delimited values into a trimmed lowercase set for case-insensitive comparison.
     */
    private static Set<String> splitValuesToLowercaseSet(String values) {
        Set<String> valueSet = new Set<String>();
        if (String.isBlank(values)) {
            return valueSet;
        }

        for (String value : values.split(';')) {
            if (String.isNotBlank(value)) {
                valueSet.add(value.trim().toLowerCase());
            }
        }
        return valueSet;
    }

    /**
     * Builds a numbered, newline-separated list of allowed values from a semicolon-delimited string,
     * so the external system can see which values it may select. Returns 'none' when nothing is available.
     */
    private static String formatAllowedValues(String semicolonDelimitedValues) {
        List<String> values = new List<String>();
        if (String.isNotBlank(semicolonDelimitedValues)) {
            for (String value : semicolonDelimitedValues.split(';')) {
                if (String.isNotBlank(value)) {
                    values.add(value.trim());
                }
            }
        }
        return buildNumberedList(values);
    }

    /**
     * Builds a numbered, newline-separated list of allowed values from a collection (Set or List),
     * so the external system can see which values it may select. Returns 'none' when nothing is available.
     */
    private static String formatAllowedValues(Iterable<String> allowedValues) {
        List<String> values = new List<String>();
        if (allowedValues != null) {
            Iterator<String> iterator = allowedValues.iterator();
            while (iterator.hasNext()) {
                String value = iterator.next();
                if (String.isNotBlank(value)) {
                    values.add(value.trim());
                }
            }
        }
        values.sort();
        return buildNumberedList(values);
    }

    /**
     * Builds the campaign field mismatch message using the configured custom-setting text as the
     * source of truth, but preserves the submitted value and allowed-values list for the caller.
     */
    private static String formatCampaignFieldMismatchError(String errorCode, String fieldValue, String invalidValues, String allowedValues) {
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting = getResponseCodeSetting(errorCode, '400', 'VALIDATION_ERROR');
        String messageTemplate = setting != null && String.isNotBlank(setting.message)
            ? setting.message
            : 'Field value is not available on the Campaign record.';

        String resolvedMessage = messageTemplate;
        if (messageTemplate.contains('{0}') || messageTemplate.contains('{1}')) {
            try {
                resolvedMessage = String.format(messageTemplate, new List<String>{ invalidValues, allowedValues });
            } catch (Exception e) {
                resolvedMessage = messageTemplate;
            }
        } else if (messageTemplate.contains(' value is not available on the Campaign record.')) {
            String fieldLabel = messageTemplate.substringBefore(' value is not available on the Campaign record.');
            resolvedMessage = fieldLabel + ' value "' + invalidValues + '" is not available on the Campaign record.';
        } else if (String.isBlank(resolvedMessage)) {
            resolvedMessage = fieldValue + ' value "' + invalidValues + '" is not available on the Campaign record.';
        }

        if (String.isNotBlank(allowedValues) && allowedValues != 'none'
            && !resolvedMessage.contains(allowedValues)
            && !resolvedMessage.contains('Expected value:') && !resolvedMessage.contains('Allowed values:')) {
            resolvedMessage += '\nExpected value:\n' + allowedValues;
        }

        return errorCode + ': ' + resolvedMessage;
    }

    /**
     * Formats a list of values as a numbered list with each value on its own line:
     * "1. Value A\n2. Value B". Returns 'none' when the list is empty.
     */
    private static String buildNumberedList(List<String> values) {
        if (values == null || values.isEmpty()) {
            return 'none';
        }
        List<String> numberedLines = new List<String>();
        for (Integer i = 0; i < values.size(); i++) {
            numberedLines.add((i + 1) + '. ' + values[i]);
        }
        return String.join(numberedLines, '\n');
    }

    /**
     * Returns valid countries from Core_MDF_CP_Countries__c for the provided campaign record type.
     * Supports either a single country or a comma/semicolon-delimited list.
     */
    public static List<String> getValidCountriesForCampaignProgram(String campaignRecordType, String countryInput) {
        List<String> validCountries = new List<String>();
        Set<String> requestedCountriesLower = parseDelimitedValuesToLowercaseSet(countryInput);
        if (requestedCountriesLower.isEmpty()) {
            return validCountries;
        }

        String programFilterToken = getProgramFilterTokenForCampaignRecordType(campaignRecordType);
        if (String.isBlank(programFilterToken)) {
            return validCountries;
        }

        Set<String> dedupedValidCountries = new Set<String>();
        for (Core_MDF_CP_Countries__c metaRecord : [
            SELECT Core_MDF_CP_Country__c, Core_MDF_Program_Name__c, Core_MDF_Is_Applicable_All_Programs_Ind__c
            FROM Core_MDF_CP_Countries__c
            WHERE Core_MDF_Is_Active__c = true
        ]) {
            if (String.isBlank(metaRecord.Core_MDF_CP_Country__c)) {
                continue;
            }

            String metadataCountryLower = metaRecord.Core_MDF_CP_Country__c.trim().toLowerCase();
            if (!requestedCountriesLower.contains(metadataCountryLower)) {
                continue;
            }

            if (isProgramMatchForRecordType(metaRecord, programFilterToken)) {
                dedupedValidCountries.add(metaRecord.Core_MDF_CP_Country__c.trim());
            }
        }

        validCountries.addAll(dedupedValidCountries);
        validCountries.sort();
        return validCountries;
    }

    private static Set<String> parseDelimitedValuesToLowercaseSet(String input) {
        Set<String> values = new Set<String>();
        if (String.isBlank(input)) {
            return values;
        }

        List<String> tokens = input.replace(';', ',').split(',');
        for (String token : tokens) {
            if (String.isNotBlank(token)) {
                values.add(token.trim().toLowerCase());
            }
        }
        return values;
    }

    /**
     * @description Validates Ecosystem Partner - ensures only eligible partners for this activity are allowed
     * Core_MDF_Channel_Partner__c is a multi-select picklist; validates each selected value
     * Uses Campaign country list and Campaign record type to build the allowed ecosystem list.
     */
    public static List<String> validateEcosystemPartner(PartnerFundRequest pfr, Map<Id, Campaign> campaignMap) {
        List<String> errors = new List<String>();

        if (String.isBlank(pfr.Core_MDF_Channel_Partner__c)) {
            return errors; // Field not populated, skip validation
        }

        // Parse multi-select picklist values (separated by semicolons)
        List<String> selectedcountries = pfr.Core_MDF_Country_nm__c.split(';');
        if (pfr.CampaignId != null && campaignMap.containsKey(pfr.CampaignId)) {
            Map<String, Set<String>> countryToCPMap = new Map<String, Set<String>>();

            List<String> selectedpartner = new List<String>();
            if (String.isNotBlank(pfr.Core_MDF_Channel_Partner__c)) {
                selectedpartner = pfr.Core_MDF_Channel_Partner__c.split(';');
            }

            Campaign campaign = campaignMap.get(pfr.CampaignId);
            if (campaign == null) {
                return errors;
            }

            String campaignCountries = campaign.Core_MDF_Market__c;
            String campaignRecordName = campaign.RecordType != null ? campaign.RecordType.Name : null;

            List<String> countryList = new List<String>();
            if (String.isNotBlank(campaignCountries)) {
                countryList = campaignCountries.split(';');
            }

            Set<String> campaignCountrySet = new Set<String>(countryList);

            Set<String> selectedCountry = new Set<String>();
            if (selectedcountries != null) {
                for (String country : selectedcountries) {
                    if (String.isNotBlank(country)) {
                        selectedCountry.add(country.trim());
                    }
                }
            }

            Set<String> selectedPartners = new Set<String>();
            Set<String> selectedPartnersLower = new Set<String>();
            for (String partner : selectedpartner) {
                if (String.isNotBlank(partner)) {
                    String trimmedPartner = partner.trim();
                    selectedPartners.add(trimmedPartner);
                    selectedPartnersLower.add(trimmedPartner.toLowerCase());
                }
            }

            if (selectedPartnersLower.contains('none')) {
                if (selectedPartnersLower.size() > 1) {
                    errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9223_NO_ECOSYSTEM_PARTNER_WITH_NONE, null));
                    return errors;
                }
                selectedPartners.clear();
                selectedPartners.add('None');
            }

            Set<String> allowedPartners = new Set<String>{'None','Others'};
            Set<String> invalidCountries = new Set<String>(selectedcountries);
            invalidCountries.removeAll(campaignCountrySet);

            if (!invalidCountries.isEmpty()) {
                List<String> cleanInvalidCountries = new List<String>();
                for (String country : invalidCountries) {
                    if (String.isNotBlank(country)) {
                        cleanInvalidCountries.add(country.trim());
                    }
                }

                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9046_ECOSYSTEM_PARTNER_MISMATCH,
                    new List<String>{ String.join(cleanInvalidCountries, ','), formatAllowedValues(new List<String>(campaignCountrySet)) }
                ));
            }

            String programFilterToken = getProgramFilterTokenForCampaignRecordType(campaignRecordName);
            List<Core_MDF_CP_Countries__c> countryRecords = [
                SELECT Id, Core_MDF_CP_Country__c, Core_MDF_CP_Name__c, Core_MDF_Program_Name__c,
                       Core_MDF_All_Countries__c, Core_MDF_Is_Applicable_All_Programs_Ind__c, Core_MDF_Is_Active__c
                FROM Core_MDF_CP_Countries__c
                WHERE Core_MDF_Is_Active__c = TRUE
                AND (Core_MDF_All_Countries__c = TRUE OR Core_MDF_CP_Country__c IN :selectedCountry)
            ];

            for (Core_MDF_CP_Countries__c rec : countryRecords) {
                if (String.isBlank(rec.Core_MDF_CP_Name__c) || !isProgramMatchForRecordType(rec, programFilterToken)) {
                    continue;
                }
                if (rec.Core_MDF_All_Countries__c == true) {
                    for (String country : selectedCountry) {
                        if (!countryToCPMap.containsKey(country)) {
                            countryToCPMap.put(country, new Set<String>());
                        }
                        countryToCPMap.get(country).add(rec.Core_MDF_CP_Name__c);
                    }
                } else if (String.isNotBlank(rec.Core_MDF_CP_Country__c)) {
                    if (!countryToCPMap.containsKey(rec.Core_MDF_CP_Country__c)) {
                        countryToCPMap.put(rec.Core_MDF_CP_Country__c, new Set<String>());
                    }
                    countryToCPMap.get(rec.Core_MDF_CP_Country__c).add(rec.Core_MDF_CP_Name__c);
                }
            }

            for (String country : selectedCountry) {
                if (countryToCPMap.containsKey(country)) {
                    allowedPartners.addAll(countryToCPMap.get(country));
                }
            }

            Set<String> invalidPartners = new Set<String>(selectedPartners);
            invalidPartners.removeAll(allowedPartners);

            if (!invalidPartners.isEmpty()) {
                List<String> cleanInvalidPartners = new List<String>();
                for (String partner : invalidPartners) {
                    if (String.isNotBlank(partner)) {
                        cleanInvalidPartners.add(partner.trim());
                    }
                }

                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9046_ECOSYSTEM_PARTNER_MISMATCH,
                    new List<String>{ String.join(cleanInvalidPartners, ','), formatAllowedValues(new List<String>(allowedPartners)) }
                ));
            }
        }

        return errors;
    }

    private static Boolean isProgramMatchForRecordType(Core_MDF_CP_Countries__c metaRecord, String programFilterToken) {
        if (metaRecord.Core_MDF_Is_Applicable_All_Programs_Ind__c == true) {
            return true;
        }

        if (String.isBlank(programFilterToken) || String.isBlank(metaRecord.Core_MDF_Program_Name__c)) {
            return false;
        }

        String programNameLower = metaRecord.Core_MDF_Program_Name__c.toLowerCase();
        String tokenLower = programFilterToken.toLowerCase();

        if (tokenLower == 'client') {
            return programNameLower.contains('client') || programNameLower.contains('ccf');
        }

        if (tokenLower == 'data%center') {
            String compact = programNameLower.replace(' ', '');
            return compact.contains('datacenter') || programNameLower.contains('dcf');
        }

        return programNameLower.contains(tokenLower.replace('%', ''));
    }

    /**
     * Maps Campaign record type to a program token used for ecosystem metadata filtering.
     */
    private static String getProgramFilterTokenForCampaignRecordType(String campaignRecordType) {
        if (String.isBlank(campaignRecordType)) {
            return null;
        }

        String normalized = campaignRecordType.toLowerCase();
        String normalizedCompact = normalized.replace(' ', '');
        if (normalized.contains('client') || normalized.contains('ccf')) {
            return 'Client';
        }
        if (normalizedCompact.contains('datacenter') || normalized.contains('dcf')) {
            return 'Data%Center';
        }

        return null;
    }

    /**
     * @description Validates Other Ecosystem Partner - when Ecosystem Partner is set to "Others" or "Other", 
     * the Other Ecosystem Partner field becomes mandatory
     */
    private static List<String> validateOtherEcosystemPartner(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        
        if (String.isBlank(pfr.Core_MDF_Channel_Partner__c)) {
            return errors; // Field not populated, skip validation
        }
        
        // Check if "Others" or "Other" is selected in the multi-select picklist
        Set<String> selectedPartners = new Set<String>();
        for (String partner : pfr.Core_MDF_Channel_Partner__c.split(';')) {
            if (String.isNotBlank(partner)) {
                selectedPartners.add(partner.trim().toLowerCase());
            }
        }
        
        // If "Others" or "Other" (case-insensitive) is selected, validate that Other Ecosystem Partner is provided
        if (selectedPartners.contains('others') || selectedPartners.contains('other')) {
            if (String.isBlank(pfr.Core_MDF_Other_Channel_Partner__c)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9101_OTHER_ECOSYSTEM_PARTNER_REQUIRED);
            }
        }
        
        return errors;
    }

    /**
     * @description Validates Member Acceptor - ensures only eligible users are allowed
     * Member Acceptor must be an active user and eligible for the activity record type
     */
    public static List<String> validateMemberAcceptor(PartnerFundRequest pfr, String recType) {
        List<String> errors = new List<String>();
        
        if (String.isBlank(pfr.Core_MDF_Member_Acceptor_Id__c)) {
            return errors; // Field not populated, skip validation
        }
        
        String memberAcceptorId = pfr.Core_MDF_Member_Acceptor_Id__c;
        Id accountId = pfr.ChannelPartnerId;
        
        try {
            // 1. Verify user exists and is active (or reclaimed)
            List<User> users = [SELECT Id FROM User WHERE Id = :memberAcceptorId AND (IsActive = true OR Partner_License_Reclaimed__c = true) LIMIT 1];
            if (users.isEmpty()) {
                errors.add(withMemberAcceptorAllowedValues(Core_MDF_PFR_RestAPI_Constants.ERR_9050_MEMBER_NOT_ACTIVE, accountId));
                return errors;
            }
            
            // Perform PNUM and Permission Set checks whenever ChannelPartnerId is present
            if (accountId != null) {
                // 2. Verify PNUM mapping is active for this account
                List<Core_MDF_Partner_Node_User_Mapping__c> pnums = [SELECT Id FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c = :accountId AND Core_MDF_User__c = :memberAcceptorId AND Core_MDF_Active_Ind__c = true LIMIT 1];
                if (pnums.isEmpty()) {
                    errors.add(withMemberAcceptorAllowedValues(Core_MDF_PFR_RestAPI_Constants.ERR_9051_NO_PNUM_MAPPING, accountId));
                    return errors;
                }
                
                // 3. Verify Permission Set Assignment
                String pSetSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter');
                String pSetEefSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_EEF_Activity_Submitter');
                
                List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :memberAcceptorId AND (PermissionSet.Name = :pSetSubmitter OR PermissionSet.Name = :pSetEefSubmitter) LIMIT 1];
                if (assignments.isEmpty()) {
                    errors.add(withMemberAcceptorAllowedValues(Core_MDF_PFR_RestAPI_Constants.ERR_9052_NO_EXT_SUBMITTER_PERM, accountId));
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9053_MEMBER_VALIDATION_ERR, new List<String>{ e.getMessage() }));
        }
        
        return errors;
    }

    /**
     * Validates that a user is eligible to be a Member Acceptor for the Channel Partner account.
     * Checks: active/reclaimed status, PNUM mapping, and permission set assignment.
     * @return Error message if validation fails, blank if validation passes
     */
    public static String validateMemberAcceptorEligibility(Id userId, Id accountId) {
        if (userId == null || accountId == null) {
            return 'Member acceptor user and account must be provided for eligibility check';
        }

        try {
            // Check if user is active and is Partner Community User (matching picklist endpoint logic)
            List<User> users = [
                SELECT Id, IsActive, Partner_License_Reclaimed__c, UserType 
                FROM User 
                WHERE Id = :userId LIMIT 1
            ];
            if (users.isEmpty()) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9050_MEMBER_NOT_ACTIVE,
                    new List<String>{});
            }
            if (!users[0].IsActive) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9050_MEMBER_NOT_ACTIVE,
                    new List<String>{});
            }
            if (users[0].UserType != 'PowerPartner') {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9050_MEMBER_NOT_ACTIVE,
                    new List<String>{});
            }

            // Check if PNUM mapping exists for this account
            List<Core_MDF_Partner_Node_User_Mapping__c> pnums = [
                SELECT Id FROM Core_MDF_Partner_Node_User_Mapping__c
                WHERE Core_MDF_Account__c = :accountId AND Core_MDF_User__c = :userId AND Core_MDF_Active_Ind__c = true
                LIMIT 1
            ];
            if (pnums.isEmpty()) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9051_NO_PNUM_MAPPING,
                    new List<String>{});
            }

            // Check if permission set is assigned
            String pSetSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter');
            String pSetEefSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_EEF_Activity_Submitter');
            
            List<PermissionSetAssignment> assignments = [
                SELECT Id FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND (PermissionSet.Name = :pSetSubmitter OR PermissionSet.Name = :pSetEefSubmitter)
                LIMIT 1
            ];
            if (assignments.isEmpty()) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9052_NO_EXT_SUBMITTER_PERM,
                    new List<String>{});
            }

            return ''; // All checks passed
        } catch (Exception e) {
            return Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9053_MEMBER_VALIDATION_ERR,
                new List<String>{ e.getMessage() });
        }
    }

    /**
     * Appends the list of eligible Member Acceptor usernames for the Channel Partner to a member
     * acceptor error, so the external system can see which usernames it may submit. The original
     * message is returned unchanged when no eligible users are found (or the account is unknown).
     * Embeds the field name in the error so it appears in the JSON response.
     */
    public static String withMemberAcceptorAllowedValues(String baseMessage, Id accountId) {
        List<String> eligibleUsernames = getEligibleMemberAcceptorUsernames(accountId);
        if (eligibleUsernames.isEmpty()) {
            return baseMessage;
        }
        return '###FieldName:MemberAcceptorUsername###' + baseMessage + ' Allowed values:\n' + buildNumberedList(eligibleUsernames);
    }

    /**
     * Returns the usernames eligible to be a Member Acceptor for the given Channel Partner account:
     * active (or license-reclaimed) users who have an active Partner Node User Mapping for the account
     * and hold an External Activity Submitter permission set.
     */
    private static List<String> getEligibleMemberAcceptorUsernames(Id accountId) {
        List<String> usernames = new List<String>();
        if (accountId == null) {
            return usernames;
        }

        // Match picklist endpoint logic exactly - filter by account, active mapping, and Partner Community User type
        Set<Id> userIds = new Set<Id>();
        for (Core_MDF_Partner_Node_User_Mapping__c pnum : [
            SELECT Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c
            WHERE Core_MDF_Account__c = :accountId 
              AND Core_MDF_Active_Ind__c = true 
              AND Core_MDF_User__c != null
              AND Core_MDF_User__r.IsActive = true
              AND Core_MDF_User__r.UserType = 'PowerPartner'
        ]) {
            userIds.add(pnum.Core_MDF_User__c);
        }
        if (userIds.isEmpty()) {
            return usernames;
        }

        String pSetSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter');
        String pSetEefSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_EEF_Activity_Submitter');
        Set<Id> permittedUserIds = new Set<Id>();
        for (PermissionSetAssignment psa : [
            SELECT AssigneeId FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds AND (PermissionSet.Name = :pSetSubmitter OR PermissionSet.Name = :pSetEefSubmitter)
        ]) {
            permittedUserIds.add(psa.AssigneeId);
        }
        if (permittedUserIds.isEmpty()) {
            return usernames;
        }

        for (User u : [
            SELECT Username FROM User
            WHERE Id IN :permittedUserIds
            ORDER BY Username
        ]) {
            if (String.isNotBlank(u.Username)) {
                usernames.add(u.Username);
            }
        }
        return usernames;
    }

    /**
     * @description Validates Intel Approver user eligibility - must be active and match campaign regions.
     * Returns error message if validation fails, blank string if validation passes.
     */
    public static String validateIntelApproverEligibility(Id userId, Campaign campaignRecord) {
        if (userId == null || campaignRecord == null) {
            return 'Intel approver user and campaign must be provided for eligibility check';
        }

        try {
            // Check if user is active
            List<User> users = [
                SELECT Id, IsActive, UserType 
                FROM User 
                WHERE Id = :userId LIMIT 1
            ];
            if (users.isEmpty()) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9054_INTEL_NOT_ACTIVE,
                    new List<String>{});
            }
            if (!users[0].IsActive) {
                return Core_MDF_PFR_RestAPI_Constants.formatError(
                    Core_MDF_PFR_RestAPI_Constants.ERR_9054_INTEL_NOT_ACTIVE,
                    new List<String>{});
            }

            return ''; // All checks passed
        } catch (Exception e) {
            return Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9055_INTEL_VALIDATION_ERR,
                new List<String>{ e.getMessage() });
        }
    }

    /**
     * Appends the list of eligible Intel Approver usernames for the campaign to an intel approver
     * error, so the external system can see which usernames it may submit.
     */
    public static String withIntelApproverAllowedValues(String baseMessage, Campaign campaignRecord) {
        List<String> eligibleUsernames = getEligibleIntelApproverUsernames(campaignRecord);
        if (eligibleUsernames.isEmpty()) {
            return baseMessage;
        }
        return '###FieldName:IntelApproverUsername###' + baseMessage + ' Allowed values:\n' + buildNumberedList(eligibleUsernames);
    }

    /**
     * Returns eligible Intel Approver usernames based on campaign region.
     * Queries from Core_MDF_Int_Users_Partner_Geo_Mapping__c matching campaign regions.
     */
    private static List<String> getEligibleIntelApproverUsernames(Campaign campaignRecord) {
        List<String> usernames = new List<String>();
        if (campaignRecord == null) {
            return usernames;
        }

        // Get campaign countries from Core_MDF_Market__c field
        String campaignMarkets = campaignRecord.Core_MDF_Market__c;
        if (String.isBlank(campaignMarkets)) {
            return usernames;
        }

        // Parse semicolon-delimited country list
        List<String> campaignCountries = new List<String>();
        for (String country : campaignMarkets.split(';')) {
            String trimmed = country.trim();
            if (String.isNotBlank(trimmed)) {
                campaignCountries.add(trimmed);
            }
        }
        if (campaignCountries.isEmpty()) {
            return usernames;
        }

        // Convert countries to regional codes using metadata mapping
        Set<String> regionSet = getRegionsForCountries(campaignCountries);
        if (regionSet.isEmpty()) {
            return usernames;
        }

        // Query Intel users matching campaign regions
        Set<Id> userIds = new Set<Id>();
        try {
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c geoMapping : [
                SELECT Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                WHERE Core_MDF_User_id__c != null
                  AND Core_MDF_Region_Sub_Region_nm__c IN :regionSet
                  AND Core_MDF_Active_Ind__c = true
            ]) {
                userIds.add(geoMapping.Core_MDF_User_id__c);
            }
        } catch (Exception e) {
            // Silently fail - return empty list
            return usernames;
        }

        if (userIds.isEmpty()) {
            return usernames;
        }

        // Get usernames for active users
        for (User u : [
            SELECT Username FROM User
            WHERE Id IN :userIds AND IsActive = true
            ORDER BY Username
        ]) {
            if (String.isNotBlank(u.Username)) {
                usernames.add(u.Username);
            }
        }
        return usernames;
    }

    /**
     * Maps countries to their regional codes using custom metadata
     */
    private static Set<String> getRegionsForCountries(List<String> countries) {
        Set<String> regions = new Set<String>();
        if (countries == null || countries.isEmpty()) {
            return regions;
        }

        try {
            // Query the metadata to get region mappings for the given countries
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> mappings = [
                SELECT Core_MDF_Geo__c
                FROM Core_MDF_CCP_Country_Geo_Mapping__mdt
                WHERE Label IN :countries
                WITH USER_MODE
            ];

            for (Core_MDF_CCP_Country_Geo_Mapping__mdt mapping : mappings) {
                if (String.isNotBlank(mapping.Core_MDF_Geo__c)) {
                    regions.add(mapping.Core_MDF_Geo__c);
                }
            }
        } catch (Exception e) {
            // Silently fail - return empty set (no filtering applied)
        }

        return regions;
    }

    /**
     * @description Validates Reimbursement Rate against active campaign budget reimbursement rates.
     * Returns validation error with allowed values when an invalid rate is submitted.
     */
    private static List<String> validateReimbursementRate(PartnerFundRequest pfr, Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap) {
        List<String> errors = new List<String>();
        String budgetType = pfr.Core_MDF_Budget_Type_nm__c;
        
        // Validate that ReimbursementAmt should be blank for budget types other than MDF or MDF+ (but allow zero)
        
        
        if (String.isBlank(pfr.Core_MDF_Reimbursement_Rate_txt__c)) {
            return errors; // Empty values are handled by required field validation
        }
        
        String submittedRate = pfr.Core_MDF_Reimbursement_Rate_txt__c.trim();
        // Normalize the submitted value for comparison by removing any trailing percent sign.
        String normalizedRate = submittedRate.endsWith('%')
            ? submittedRate.substring(0, submittedRate.length() - 1).trim()
            : submittedRate;

        try {
            normalizedRate = formatRateValue(Decimal.valueOf(normalizedRate));
        } catch (Exception e) {
            normalizedRate = submittedRate;
        }

        Set<String> allowedRates = getActiveBudgetReimbursementRates(pfr, campaignBudgetsMap);

        if (allowedRates.isEmpty()) {
            return errors;
        }
        
        if (!allowedRates.contains(normalizedRate)) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9039_BUDGET_REIMBURSEMENT_RATE_MISMATCH,
                new List<String>{ formatAllowedValues(allowedRates) }
            ));
        }
        
        return errors;
    }

    private static Set<String> getActiveBudgetReimbursementRates(PartnerFundRequest pfr, Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap) {
        Set<String> allowedRates = new Set<String>();

        if (pfr == null || pfr.CampaignId == null || pfr.BudgetId == null || campaignBudgetsMap == null || !campaignBudgetsMap.containsKey(pfr.CampaignId)) {
            return allowedRates;
        }

        for (Core_MDF_Campaign_Budgets__c campaignBudget : campaignBudgetsMap.get(pfr.CampaignId)) {
            if (campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c == null) {
                continue;
            }

            if (campaignBudget.Core_MDF_Budget_Name_Id__c != pfr.BudgetId) {
                continue;
            }

            allowedRates.add(formatRateValue(campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c));
        }

        return allowedRates;
    }

    private static String formatRateValue(Decimal rate) {
        if (rate == null) {
            return null;
        }

        Decimal cleanedRate = rate.stripTrailingZeros();
        return cleanedRate.scale() <= 0
            ? String.valueOf(cleanedRate.setScale(0))
            : String.valueOf(cleanedRate.setScale(cleanedRate.scale()));
    }

    private static String formatRateValue(String rate) {
        if (String.isBlank(rate)) {
            return null;
        }

        String normalizedRate = rate.trim();
        normalizedRate = normalizedRate.endsWith('%')
            ? normalizedRate.substring(0, normalizedRate.length() - 1).trim()
            : normalizedRate;

        try {
            return formatRateValue(Decimal.valueOf(normalizedRate));
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return normalizedRate;
        }
    }
    
    /**
     * @description Keeps ReimbursementAmt blank so Intel Contribution formula uses RequestedAmount and ReimbursementRate.
     */
    public static void calculateReimbursementValues(PartnerFundRequest pfr, PartnerFundRequest effectivePfr) {
        pfr.Core_MDF_MDFReimbursement_Amt__c = null;
    }

    /**
     * @description Normalizes Reimbursement Rate - appends % symbol if needed
     */
    public static void normalizeReimbursementRate(PartnerFundRequest pfr) {
        if (String.isNotBlank(pfr.Core_MDF_Reimbursement_Rate_txt__c)) {
            String rate = pfr.Core_MDF_Reimbursement_Rate_txt__c.trim();
            // If the value doesn't already end with %, append it
            if (!rate.endsWith('%')) {
                pfr.Core_MDF_Reimbursement_Rate_txt__c = rate + '%';
            }
        }
    }

    /**
     * @description Validates Budget - ensures submitted budget is available for the CCF/DCF Campaign
     * Checks if budget is active, belongs to the Campaign, matches Budget Type and overlapping dates
     */
    public static List<String> validateBudgetLinkedToCampaign(PartnerFundRequest pfr, String recType, Map<Id, List<Core_MDF_Campaign_Budgets__c>> campaignBudgetsMap) {
        List<String> errors = new List<String>();
        
        // Skip validation if no budget is provided
        if (String.isBlank(pfr.BudgetId)) {
            return errors;
        }
        
        // Skip validation if no campaign or channel partner is provided
        if (String.isBlank(pfr.CampaignId) || String.isBlank(pfr.ChannelPartnerId)) {
            return errors;
        }
        
        // CCF/DCF Programs: Validate Budget is active, belongs to Campaign, matches Budget Type and overlapping dates
        Boolean isBudgetValid = false;
        if (campaignBudgetsMap.containsKey(pfr.CampaignId)) {
            for (Core_MDF_Campaign_Budgets__c cb : campaignBudgetsMap.get(pfr.CampaignId)) {
                if (cb.Core_MDF_Budget_Name_Id__c == pfr.BudgetId &&
                    cb.Core_MDF_Budget_Type_Nm__c == pfr.Core_MDF_Budget_Type_nm__c &&
                    cb.Core_MDF_Start_Date_Dt__c <= pfr.Core_MDF_Start_Date__c &&
                    cb.Core_MDF_End_Date_Dt__c >= pfr.Core_MDF_End_Date__c) {
                    isBudgetValid = true;
                    break;
                }
            }
        }
        if (!isBudgetValid) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9060_BUDGET_NOT_AVAIL);
        }
        
        return errors;
    }

    /**
     * Validates that the requested activity amount does not exceed the matching allocation's claim available amount.
     * Only applies to MDF and MDF+ budget types. Returns empty error list for other budget types.
     */
    public static List<String> validateClaimAvailableAmount(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        
        // Only validate for MDF and MDF+ budget types
        if (pfr == null) {
            return errors;
        }

        String budgetType = String.isBlank(pfr.Core_MDF_Budget_Type_nm__c) ? '' : pfr.Core_MDF_Budget_Type_nm__c.trim().toUpperCase();
        if (budgetType != 'MDF' && budgetType != 'MDF+') {
            return errors;
        }
        
        // Skip validation if required fields are missing
        if (pfr.BudgetId == null || pfr.ChannelPartnerId == null || pfr.Core_MDF_Budget_Amount_Local_amt__c == null) {
            return errors;
        }

        List<PartnerFundAllocation> allocations = [
            SELECT Id, Core_MDF_Available_Activity_Alloc_Amt__c
            FROM PartnerFundAllocation
            WHERE BudgetId = :pfr.BudgetId
            AND ChannelPartnerId = :pfr.ChannelPartnerId
            LIMIT 1
        ];

        if (allocations.isEmpty()) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9062_CLAIM_AVAILABLE_AMOUNT_EXCEEDED,
                null
            ));
            return errors;
        }

        Decimal claimAvailableAmount = allocations[0].Core_MDF_Available_Activity_Alloc_Amt__c == null
            ? 0
            : allocations[0].Core_MDF_Available_Activity_Alloc_Amt__c;
            
        if (pfr.Core_MDF_Budget_Amount_Local_amt__c > claimAvailableAmount) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                Core_MDF_PFR_RestAPI_Constants.ERR_9062_CLAIM_AVAILABLE_AMOUNT_EXCEEDED,
                null
            ));
        }

        return errors;
    }

    /**
     * Validates Activity Sub Type when dependent picklist values exist for the selected Activity Type.
     * For CCF/DCF: Required when Activity Type has sub-type dependencies and none are selected.
     */
    private static List<String> validateActivitySubType(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        String category = pfr.Core_MDF_ActivityCategory__c;
        String activityType = pfr.Core_MDF_Activity_Types__c;
        String activitySubType = pfr.Core_MDF_Activity_SubType_nm__c;

        if (String.isBlank(activityType)) {
            return errors;
        }

        // Get dependent picklist values for Activity Type → Activity Sub Type
        Map<Object, List<Map<String, String>>> dependentValues = 
            getFieldDependenciesMaps(PFR_OBJECT_NAME, ACTIVITY_TYPE_FIELD, 'Core_MDF_Activity_SubType_nm__c');

        // Aura parity: Sub Type is shown/mandatory only on pre-2025 category paths.
        Boolean isPre2025Category = isPre2025ActivityCategory(category);

        // If this Activity Type has sub-type dependencies, sub-type is mandatory for pre-2025 categories.
        if (dependentValues.containsKey(activityType)) {
            List<Map<String, String>> subTypeValues = dependentValues.get(activityType);
            if (isPre2025Category && !subTypeValues.isEmpty() && String.isBlank(activitySubType)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9095_ACTIVITY_SUBTYPE_REQUIRED);
                return errors;
            }
            
            // If sub-type is provided, validate it's in the allowed list
            if (String.isNotBlank(activitySubType)) {
                Set<String> allowedSubTypes = new Set<String>();
                for (Map<String, String> valueMap : subTypeValues) {
                    if (valueMap.containsKey('label')) {
                        allowedSubTypes.add(valueMap.get('label'));
                    }
                }
                
                // Handle multi-select: split by semicolon and validate each
                List<String> selectedValues = activitySubType.split(';');
                for (String selectedValue : selectedValues) {
                    String trimmedValue = selectedValue.trim();
                    if (String.isNotBlank(trimmedValue) && !allowedSubTypes.contains(trimmedValue)) {
                        errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
                            Core_MDF_PFR_RestAPI_Constants.ERR_9096_INVALID_ACTIVITY_SUBTYPE,
                            new List<String>{ trimmedValue, formatAllowedValues(allowedSubTypes) }
                        ));
                        break;
                    }
                }
            }
        }

        return errors;
    }

    /**
     * Matches Aura latest-category behavior for subtype mandatory checks.
     * Latest (post-2025) categories are not subtype-mandatory; pre-2025 categories are.
     */
    private static Boolean isPre2025ActivityCategory(String category) {
        return String.isNotBlank(category) && category.contains('(Pre-2025)');
    }

    /**
     * Validates that activity Start Date is not before today.
     */
    private static List<String> validatePastDatedActivityReason(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        Date startDate = pfr.Core_MDF_Start_Date__c;

        if (startDate == null) {
            return errors;
        }

        if (startDate < Date.today()) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9128_START_DATE_PRIOR_TO_TODAY, null));
        }

        return errors;
    }

    /**
     * Validates event activities requiring 60-day advance submission.
    * If Budget Type = MDF/MDF+/OEM CMP/SP CMP, Activity Category = event,
    * and ActivitySpendingLimitLocal >= 50k, the start date must be >= 60 days from today.
     * @param pfr The PartnerFundRequest record to validate
     * @return List of error messages, empty if validation passes
     */
    private static List<String> validateEventActivityAdvanceSubmission(PartnerFundRequest pfr) {
        List<String> errors = new List<String>();
        
        // Check all conditions
        String budgetType = pfr.Core_MDF_Budget_Type_nm__c;
        String activityCategory = pfr.Core_MDF_ActivityCategory__c;
        //Decimal spendingLimit = pfr.Core_MDF_Budget_Amount_Local_amt__c;
        Date startDate = pfr.Core_MDF_Start_Date__c;

        String normalizedBudgetType = String.isBlank(budgetType) ? '' : budgetType.replaceAll('\\s+', '').toUpperCase();
        Set<String> qualifyingBudgetTypes = new Set<String>{ 'MDF', 'MDF+', 'OEMCMP', 'ServiceProviderCMP' };
        Decimal intelContribution = calculateIntelContributionAmount(pfr);
        // All conditions must be met for validation to apply
        if (String.isNotBlank(budgetType) &&
            qualifyingBudgetTypes.contains(normalizedBudgetType) &&
            String.isNotBlank(activityCategory) && 
            EVENT_NAME.equalsIgnoreCase(activityCategory) &&
            intelContribution != null && 
            intelContribution >= 50000 &&
            startDate != null) {
            
            // Calculate 60 days from today
            Date requiredSubmissionDate = Date.today().addDays(60);
            
            // If start date is less than 60 days from today, it's an error
            if (startDate < requiredSubmissionDate) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9199_INVALID_REASON_PAST_DATED);
            }
        }

        return errors;
    }

    /**
    * Validates file upload requirement for OEM CMP activities with high-value Intel contribution.
     * @param pfr PartnerFundRequest record to validate
     * @param hasFileUpload Boolean indicating whether files were provided in the request
     * @return List of validation errors (empty if validation passes)
     */
    private static List<String> validateDigitalEcosystemPartnerFileUpload(PartnerFundRequest pfr, Boolean hasFileUpload) {
        List<String> errors = new List<String>();

        String budgetType = pfr.Core_MDF_Budget_Type_nm__c;
        Decimal intelContribution = calculateIntelContributionAmount(pfr);
        String activityCategory = pfr.Core_MDF_ActivityCategory__c;
        String activityType = pfr.Core_MDF_Activity_Types__c;
        String domainType = pfr.Core_MDF_Domain_Type_nm__c;

        // Normalize values from payload/system to avoid formatting mismatches.
        String normalizedBudgetType = String.isBlank(budgetType) ? '' : budgetType.replaceAll('\\s+', '').toLowerCase();
        String normalizedDomainType = String.isBlank(domainType) ? '' : domainType.replaceAll('\\s+', '').toLowerCase();

        Boolean isOemCmpBudgetType = normalizedBudgetType == 'oemcmp';
        Boolean isHighValueIntelContribution = intelContribution != null && intelContribution > 50000;
        Boolean isHighValueEventActivity = isOemCmpBudgetType &&
            isHighValueIntelContribution &&
            isEventCategory(activityCategory);
        Boolean isDigitalEcosystemPartnerActivity = isOemCmpBudgetType &&
            isHighValueIntelContribution &&
            (isEventCategory(activityCategory) || ACTIVITYTYPE_DIGITAL.equalsIgnoreCase(activityCategory)) &&
            normalizedDomainType == ECOSYSTEMPARTNER;

        if (!isHighValueEventActivity && !isDigitalEcosystemPartnerActivity) {
            return errors;
        }

        // If all conditions met and no file uploaded, add error
        if (!hasFileUpload) {
            errors.add(Core_MDF_PFR_RestAPI_Constants.ERR_9027_DIGITAL_PARTNER_FILE_REQUIRED);
        }

        return errors;
    }

    private static Decimal calculateIntelContributionAmount(PartnerFundRequest pfr) {
        if (pfr == null) {
            return null;
        }

        return calculateIntelContributionAmount(pfr.Core_MDF_Budget_Amount_Local_amt__c, pfr.Core_MDF_Reimbursement_Rate_txt__c);
    }

    private static Decimal calculateIntelContributionAmount(Decimal activitySpendingLimit, String reimbursementRateValue) {
        Decimal reimbursementRate = parseReimbursementRate(reimbursementRateValue);

        if (activitySpendingLimit == null || activitySpendingLimit <= 0 || reimbursementRate == null) {
            return null;
        }

        return ((activitySpendingLimit * reimbursementRate) / 100).setScale(2, System.RoundingMode.HALF_UP);
    }

    private static Decimal parseReimbursementRate(String reimbursementRate) {
        if (String.isBlank(reimbursementRate)) {
            return null;
        }

        String normalizedRate = reimbursementRate.trim();
        normalizedRate = normalizedRate.endsWith('%')
            ? normalizedRate.substring(0, normalizedRate.length() - 1).trim()
            : normalizedRate;

        try {
            return Decimal.valueOf(normalizedRate);
        } catch (Exception e) {
            return null;
        }
    }
    
    public class PicklistDetails {
        public string active { get; set; }
        public string defaultValue { get; set; }
        public string label { get; set; }
        public string value { get; set; }
        public string validFor { get; set; }
        public PicklistDetails() { }
    }
     public static Map<Object, List<Map<String,String>>> getFieldDependenciesMaps(String objectName, String controllingField, String dependentField) {

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            return new Map<Object, List<Map<String,String>>>();
        }
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();

        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return new Map<Object, List<Map<String,String>>>();
        }
        List<Schema.PicklistEntry> controllingValues = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        return getFieldDependenciesMaps(dependentValues, controllingValues);
    }

    private static Map<Object, List<Map<String,String>>> getFieldDependenciesMaps(List<Schema.PicklistEntry> dependentValues, List<Schema.PicklistEntry> controllingValues) {
        Map<Object, List<Map<String,String>>> controllingInfo = new Map<Object, List<Map<String,String>>>();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new List<Map<String,String>>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {

            String jsonString = JSON.serialize(currDependentValue);
            PicklistDetails info = (PicklistDetails) JSON.deserialize(jsonString, PicklistDetails.class);
            if(info.validFor == null) {
                continue;
            }
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                }
                else {
                    val = curr - 48;
                }
                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                baseCount += 4;
            }
        }
        return controllingInfo;
    }
    /**
 * Calculates RequestedAmount and Exchange Rate during activity creation.
 */
private static List<String> calculateRequestedAmountAndExchangeRate(PartnerFundRequest pfr) {
    List<String> errors = new List<String>();
    if (pfr.Core_MDF_Budget_Currency_cd__c == null || pfr.Core_MDF_Budget_Amount_Local_amt__c == null || pfr.Core_MDF_Budget_Amount_Local_amt__c <= 0) {
        return errors;
    }

    if (pfr.Core_MDF_Budget_Currency_cd__c == 'USD') {
        pfr.Core_MDF_Exchange_Rate_ptc__c = 1;
        pfr.RequestedAmount = pfr.Core_MDF_Budget_Amount_Local_amt__c.setScale(2, RoundingMode.HALF_UP);
        return errors;
    }

    Datetime dt = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).addHours(12);
    String week = String.valueOf(Integer.valueOf(dt.formatGmt('w')));
    while (week.length() < 2) week = '0' + week;

    String inputUniqueKey = pfr.Core_MDF_Budget_Currency_cd__c + 'WW' + week + dt.formatGmt('YYYY');
    List<Core_MDF_Currency_Exchange_Rates__c> exchangeRates = [
        SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c
        FROM Core_MDF_Currency_Exchange_Rates__c
        WHERE Core_MDF_Unique_Key__c = :inputUniqueKey
    ];

    if (!exchangeRates.isEmpty() && exchangeRates[0].Core_MDF_Exchange_Rate__c != NULL) {
        pfr.Core_MDF_Exchange_Rate_ptc__c = exchangeRates[0].Core_MDF_Exchange_Rate__c;
        pfr.RequestedAmount = (pfr.Core_MDF_Budget_Amount_Local_amt__c * pfr.Core_MDF_Exchange_Rate_ptc__c).setScale(2, RoundingMode.HALF_UP);
        return errors;
    }

    errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(
        Core_MDF_PFR_RestAPI_Constants.ERR_9061_EXCHANGE_RATE_NOT_FOUND,
        new List<String>{ pfr.Core_MDF_Budget_Currency_cd__c, inputUniqueKey }
    ));
    return errors;
}
    
    // ===== MULTI-SEGMENT SPIF VALIDATION - APPENDED =====
    /**
     * Main entry point for Multi-Segment SPIF validation
     * Validates segment structure and data
     * @param segments - List of segment maps
     * @param accountId - Account ID
     * @param program - Program name
     * @param campaignId - Campaign ID
     * @param budgetId - Budget ID
     * @param channelPartnerId - Channel Partner ID
     * @return Map with validation results
     */
    public static Map<String, Object> validateSPIFSegments(
        List<Map<String, Object>> segments,
        String accountId,
        String program,
        String campaignId,
        String budgetId,
        String channelPartnerId
    ) {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> validSegments = new List<Map<String, Object>>();
        List<Map<String, Object>> invalidSegments = new List<Map<String, Object>>();
        
        try {
            Core_MDF_RestAPI_Logger.info('Starting Multi-Segment SPIF Validation. Account: ' + accountId);
            
            // Validate segment count
            if (segments == null || segments.isEmpty()) {
                result.put('isSuccess', false);
                result.put('message', Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9239_MISSING_SEGMENTS, null));
                return result;
            }
            
            if (segments.size() > Core_MDF_PFR_RestAPI_Constants.MAX_SEGMENTS_PER_REQUEST) {
                result.put('isSuccess', false);
                result.put('message', Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9240_INVALID_SEGMENT_COUNT, null));
                return result;
            }
            
            // Track duplicate segment names
            Set<String> seenSegmentNames = new Set<String>();
            Integer validCount = 0;
            Integer invalidCount = 0;
            
            // Validate each segment
            for (Integer i = 0; i < segments.size(); i++) {
                Map<String, Object> segmentMap = segments.get(i);
                Map<String, Object> segmentResult = validateSPIFSegment(
                    segmentMap,
                    i,
                    accountId,
                    program
                );
                
                String segmentName = String.valueOf(segmentMap.get('SegmentName'));
                Boolean isValid = (Boolean) segmentResult.get('isValid');
                
                // Check for duplicate segments
                if (seenSegmentNames.contains(segmentName)) {
                    isValid = false;
                    List<String> errors = (List<String>) segmentResult.get('errors');
                    errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9224_DUPLICATE_SEGMENT_NAME, new List<String>{ segmentName }));
                    segmentResult.put('isValid', false);
                }
                seenSegmentNames.add(segmentName);
                
                if (isValid) {
                    validSegments.add(segmentResult);
                    validCount++;
                    Core_MDF_RestAPI_Logger.logSegmentInfo(segmentName, 'Validation passed');
                } else {
                    invalidSegments.add(segmentResult);
                    invalidCount++;
                    Core_MDF_RestAPI_Logger.logSegmentError(segmentName, 'Validation failed');
                }
            }
            
            // Build response
            Boolean overallSuccess = invalidCount == 0;
            result.put('isSuccess', overallSuccess);
            result.put('validSegmentCount', validCount);
            result.put('invalidSegmentCount', invalidCount);
            result.put('validSegments', validSegments);
            result.put('invalidSegments', invalidSegments);
            result.put('message', Core_MDF_PFR_RestAPI_Constants.formatError(
                overallSuccess ? Core_MDF_PFR_RestAPI_Constants.ERR_9241_ALL_SEGMENTS_VALIDATED : Core_MDF_PFR_RestAPI_Constants.ERR_9242_SOME_SEGMENTS_FAILED,
                null
            ));
            result.put('timestamp', System.currentTimeMillis());
            
            Core_MDF_RestAPI_Logger.logMultiSegmentSPIF(accountId, program, segments.size(), overallSuccess);
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            Core_MDF_RestAPI_Logger.error('Multi-Segment SPIF validation error: ' + e.getMessage());
            result.put('isSuccess', false);
            result.put('message', Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9243_SEGMENTS_VALIDATION_ERROR, new List<String>{ e.getMessage() }));
        }
        
        return result;
    }
    
    /**
     * Validate single SPIF segment
     * @param segmentMap - Segment data map
     * @param index - Segment index
     * @param accountId - Account ID
     * @param program - Program name
     * @return Validation result map
     */
    private static Map<String, Object> validateSPIFSegment(
        Map<String, Object> segmentMap,
        Integer index,
        String accountId,
        String program
    ) {
        Map<String, Object> result = new Map<String, Object>();
        List<String> errors = new List<String>();
        Boolean isValid = true;
        
        try {
            // Extract segment fields
            String segmentName = convertToString(segmentMap.get('SegmentName'));
            Decimal minimumForecastVolume = convertToDecimal(segmentMap.get('MinimumForecastVolume'));
            Decimal incentiveAmountPerUnit = convertToDecimal(segmentMap.get('IncentiveAmountPerUnit'));
            Object productIdsObj = segmentMap.get('ProductIds');
            
            // Validate segment name
            if (String.isBlank(segmentName)) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9225_SEGMENT_NAME_REQUIRED, null));
                isValid = false;
            }
            
            // Validate minimum forecast volume
            if (minimumForecastVolume == null) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9226_MIN_FORECAST_VOLUME_REQUIRED, null));
                isValid = false;
            } else if (minimumForecastVolume <= 0) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9227_MIN_FORECAST_VOLUME_GT_ZERO, null));
                isValid = false;
            }
            
            // Validate incentive amount
            if (incentiveAmountPerUnit == null) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9228_INCENTIVE_AMOUNT_REQUIRED, null));
                isValid = false;
            } else if (incentiveAmountPerUnit <= 0) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9229_INCENTIVE_AMOUNT_GT_ZERO, null));
                isValid = false;
            }
            
            // Validate and extract product IDs
            List<String> productIds = new List<String>();
            if (productIdsObj instanceof List<Object>) {
                List<Object> prodList = (List<Object>) productIdsObj;
                Set<String> seenProducts = new Set<String>();
                
                if (prodList.isEmpty()) {
                    errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9230_PRODUCT_ID_REQUIRED, null));
                    isValid = false;
                } else {
                    for (Integer i = 0; i < prodList.size(); i++) {
                        String prodId = prodList.get(i) != null ? String.valueOf(prodList.get(i)).trim() : null;
                        
                        if (String.isBlank(prodId)) {
                            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9231_PRODUCT_ID_BLANK_AT_POSITION, new List<String>{ String.valueOf(i) }));
                            continue;
                        }
                        
                        if (seenProducts.contains(prodId)) {
                            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9232_DUPLICATE_PRODUCT_ID, new List<String>{ prodId }));
                            continue;
                        }
                        
                        seenProducts.add(prodId);
                        productIds.add(prodId);
                    }
                    
                    if (productIds.isEmpty()) {
                        errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9233_NO_VALID_PRODUCT_IDS, null));
                        isValid = false;
                    }
                }
            } else if (productIdsObj != null) {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9234_PRODUCT_IDS_MUST_BE_ARRAY, null));
                isValid = false;
            } else {
                errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9235_PRODUCT_IDS_ARRAY_REQUIRED, null));
                isValid = false;
            }
            
            result.put('segmentName', segmentName);
            result.put('isValid', isValid);
            result.put('errors', errors);
            result.put('productIds', productIds);
            result.put('minimumForecastVolume', minimumForecastVolume);
            result.put('incentiveAmountPerUnit', incentiveAmountPerUnit);
            
        } catch (Exception e) {
            Core_MDF_RestAPI_Logger.error('Error validating segment ' + index + ': ' + e.getMessage());
            errors.add(Core_MDF_PFR_RestAPI_Constants.formatError(Core_MDF_PFR_RestAPI_Constants.ERR_9236_SEGMENT_VALIDATION_ERROR, new List<String>{ e.getMessage() }));
            result.put('isValid', false);
            result.put('errors', errors);
        }
        
        return result;
    }

    /**
     * Convert Object to String safely
     * @param value - Value to convert
     * @return String value or null
     */
    private static String convertToString(Object value) {
        if (value == null) {
            return null;
        }
        return String.valueOf(value).trim();
    }

    /**
     * Convert Object to Decimal safely with multiple type support
     * @param value - Value to convert
     * @return Decimal value or null
     */
    public static Decimal convertToDecimal(Object value) {
        if (value == null) {
            return null;
        }
        try {
            if (value instanceof Decimal) {
                return (Decimal) value;
            }
            if (value instanceof Integer) {
                return Decimal.valueOf((Integer) value);
            }
            if (value instanceof Double) {
                return Decimal.valueOf((Double) value);
            }
            if (value instanceof String) {
                String strValue = ((String) value).trim();
                if (String.isNotBlank(strValue)) {
                    return Decimal.valueOf(strValue);
                }
            }
        } catch (Exception e) {
            Core_MDF_RestAPI_Logger.warning('Error converting to Decimal: ' + e.getMessage());
        }
        return null;
    }

}