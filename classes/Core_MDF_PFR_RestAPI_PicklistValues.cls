/**
 * @description REST API endpoint for external systems to fetch all allowed picklist values
 * for Activity (PartnerFundRequest) fields. Returns metadata only – no records are created or modified.
 */
@RestResource(urlMapping='/v1.0/partnercenter/activitymetadata/picklist-values')
global without sharing class Core_MDF_PFR_RestAPI_PicklistValues {

    private static final String CLIENT_COMARKETING_PROGRAM = 'Client CoMarketing Fund';
    private static final String DATA_CENTER_COMARKETING_PROGRAM = 'Data Center CoMarketing Fund';
    @TestVisible
    private static final Set<String> SUPPORTED_COMARKETING_PROGRAMS = new Set<String>{
        CLIENT_COMARKETING_PROGRAM,
        DATA_CENTER_COMARKETING_PROGRAM
    };
    private static final String PARTNER_COMMUNITY_USER_TYPE = 'PowerPartner';
    private static final String EXTERNAL_SUBMITTER_PERMISSION_SET = 'Core_MDF_CCP_External_Activity_Submitter';
    private static final String ERR_CAMPAIGN_NOT_FOUND = '7007';
    private static final String ERR_CAMPAIGN_ACCESS_DENIED = '7008';
    private static final Set<String> INTEL_APPROVER_ROLES = new Set<String>{
        'Core_MDF_CCP_Internal_CCF_Acct_Mgr',
        'Core_MDF_CCP_Internal_DCF_Acct_Mgr',
        'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr',
        'Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr'
    };
    private static final String GLOBAL_APPROVER_REGION = 'WW';
    private static final String PFR_OBJECT_NAME = 'PartnerFundRequest';
    private static final String CUSTOM_PICKLIST_OBJECT_NAME = 'Core_MDF_PFRCustomPicklist__c';
    private static final String CAMPAIGN_OBJECT_NAME = 'Campaign';
    private static final Set<String> CAMPAIGN_DEFAULT_DISPLAY_FIELDS = new Set<String>{
        'Id',
        'Name',
        'Core_MDF_Account__c',
        'Core_MDF_Program__c',
        'Core_MDF_Activity_Category__c',
        'Core_MDF_Activity_Type__c',
        'Core_MDF_Priority__c',
        'Core_MDF_Priority_2_nm__c',
        'Core_MDF_Priority_3_nm__c',
        'Core_MDF_Audience__c',
        'Core_MDF_Market__c',
        'Core_MDF_Brand__c',
        'Core_MDF_Product_Type__c',
        'Core_MDF_Industry_Nm__c',
        'Core_MDF_Opal_Budget_Type_Txt__c'
    };
    
    // All 15 standard PFR fields we need to process
    private static final Map<String, String> FIELD_LABELS = new Map<String, String>{
        'Core_MDF_ActivityCategory__c' => 'Activity Category',
        'Core_MDF_Activity_Types__c' => 'Activity Type',
        'Core_MDF_Event_Name_nm__c' => 'Event Name',
        'Core_MDF_Domain_Type_nm__c' => 'Domain Type',
        'Core_MDF_Priorities__c' => 'Priority',
        'Core_MDF_TargetAudience__c' => 'Target Audience',
        'Core_MDF_Country_nm__c' => 'Country',
        'Core_MDF_Brand_nm__c' => 'Brand',
        'Core_MDF_ProductType__c' => 'Product Type',
        'Core_MDF_Industry_Multi_nm__c' => 'Industry',
        'Core_MDF_Opal_Budget_Type_Txt__c' => 'Budget Type',
        'Core_MDF_Budget_Currency_cd__c' => 'Currency',
        'Core_MDF_Activity_SubType_nm__c' => 'Sub Type'
    };

    // Campaign to PFR field mappings
    private static final Map<String, String> CAMPAIGN_TO_PFR_FIELDS = new Map<String, String>{
        'Core_MDF_Activity_Category__c' => 'Core_MDF_ActivityCategory__c',
        'Core_MDF_Activity_Type__c' => 'Core_MDF_Activity_Types__c',
        'Core_MDF_Audience__c' => 'Core_MDF_TargetAudience__c',
        'Core_MDF_Market__c' => 'Core_MDF_Country_nm__c',
        'Core_MDF_Brand__c' => 'Core_MDF_Brand_nm__c',
        'Core_MDF_Product_Type__c' => 'Core_MDF_ProductType__c',
        'Core_MDF_Industry_Nm__c' => 'Core_MDF_Industry_Multi_nm__c',
        'Core_MDF_Opal_Budget_Type_Txt__c' => 'Core_MDF_Opal_Budget_Type_Txt__c'  // Same field name
    };

    // Dependent field relationships
    private static final Map<String, Map<String, String>> DEPENDENT_FIELDS = new Map<String, Map<String, String>>{
        'Core_MDF_Activity_Types__c' => new Map<String, String>{'dependentOn' => 'Activity Category', 'controllingField' => 'Core_MDF_ActivityCategory__c'},
        'Core_MDF_Event_Name_nm__c' => new Map<String, String>{'dependentOn' => 'Activity Type', 'controllingField' => 'Core_MDF_Activity_Types__c'},
        'Core_MDF_Domain_Type_nm__c' => new Map<String, String>{'dependentOn' => 'Activity Category', 'controllingField' => 'Core_MDF_ActivityCategory__c'},
        'Core_MDF_ProductType__c' => new Map<String, String>{'dependentOn' => 'Target Audience', 'controllingField' => 'Core_MDF_TargetAudience__c'},
        'Core_MDF_Activity_SubType_nm__c' => new Map<String, String>{'dependentOn' => 'Activity Type', 'controllingField' => 'Core_MDF_Activity_Types__c'}
    };

    @HttpGet
    global static void doGet() {
        PicklistValuesResponse response = new PicklistValuesResponse();
        
        try {
            // Get PFR object field map
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(PFR_OBJECT_NAME);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            // Get campaign ID and retrieve campaign record
            String campaignId = RestContext.request.params.get('campaignId');
            Campaign campaignRecord = null;
            
            if (String.isNotBlank(campaignId)) {
                try {
                    campaignRecord = getFilteredCampaign(campaignId);
                } catch (Core_MDF_CCP_RestAPI_Utility.AccessDeniedException e) {
                    Integer statusCode = applyConfiguredError(response, ERR_CAMPAIGN_ACCESS_DENIED, '403', 'User does not have permission to view this campaign', null);
                    sendResponse(statusCode, response);
                    return;
                }
                if (campaignRecord == null) {
                    Integer statusCode = applyConfiguredError(response, ERR_CAMPAIGN_NOT_FOUND, '404', 'Campaign not found for campaignId: ' + campaignId, new List<String>{campaignId});
                    sendResponse(statusCode, response);
                    return;
                }
                response.campaignId = campaignRecord.Id;
                response.campaignName = campaignRecord.Name;
                response.CampaignNo = getCampaignNumber(campaignRecord.Id);
            }

            // Process each standard field
            for (String pfrFieldName : FIELD_LABELS.keySet()) {
                PicklistFieldValues fieldValues = processField(fieldMap, pfrFieldName, campaignRecord);
                
                
                // Add dependent values if applicable
                addDependentValues(fieldValues, pfrFieldName, fieldMap, campaignRecord);
                
                response.fields.add(fieldValues);
            }

            // Add Allowed Budgets structured data - NEW FUNCTIONALITY
            response.Budgets = getAllowedBudgetsStructured(campaignRecord);

            // Add Ecosystem Partner field
            PicklistFieldValues ecosystemField = new PicklistFieldValues();
            ecosystemField.fieldLabel = 'Ecosystem Partner';
            ecosystemField.values = getCampaignCountryValues(campaignRecord);
            ecosystemField.dependentOn = 'Country';
            ecosystemField.dependentValues = getEcosystemPartnerValuesByCountry(campaignRecord);
            response.fields.add(ecosystemField);

            response.ReimbursementRate = getReimbursementRateValues(campaignRecord);
            response.SegmentProduct = getSegmentProductValues(campaignRecord);
            response.AccountDetails = getAccountDetails(campaignRecord);
            response.MemberAcceptorUserDetailsStructured = getMemberAcceptorUsersStructured(campaignRecord);

             Account requestedAccount = null;
            Boolean includeChildAccounts = false;  // Default: don't include child accounts
            
            String accountName = RestContext.request.params.get('acct-name');
            if (String.isNotBlank(accountName)) {
                List<Account> matchingAccounts = queryAccountsByName(accountName);
                if (!matchingAccounts.isEmpty()) {
                    response.IntelApproverUserDetails = getIntelApproverUsers(matchingAccounts, campaignRecord);
                }
            } else if (campaignRecord != null && String.isNotBlank(campaignRecord.Core_MDF_Account__c)) {
                try {
                    String campaignAccountId = campaignRecord.Core_MDF_Account__c;
                    List<Account> campaignAccounts = [
                        SELECT Id, Name, ParentId, Parent.Name,
                               Core_MDF_CoMarketing_Ultimate_Account__c,
                               Core_MDF_CoMarketing_Ultimate_Account__r.Name
                        FROM Account
                        WHERE Id = :campaignAccountId
                        LIMIT 1
                    ];
                    if (!campaignAccounts.isEmpty()) {
                        requestedAccount = campaignAccounts[0];
                        // When campaign account is used, query that account AND all its child accounts
                        includeChildAccounts = true;
                    }
                } catch (Exception e) {
                    System.debug('Exception=='+e.getLineNumber());
                }
            }
            if (String.isBlank(accountName) && requestedAccount != null) {
                //response.MemberAcceptorUserDetails = memberAcceptorUsersDetails(campaignRecord);
                String ultimateAccount = resolveUltimateAccount(requestedAccount);
                response.IntelApproverUserDetails = getIntelApproverUsers(ultimateAccount, campaignRecord);
            }
            response.isSuccess = true;
            response.code = '200';
            response.message = 'Picklist values retrieved successfully.';
            sendResponse(200, response);

        } catch (Exception e) {
            response.isSuccess = false;
            response.code = '500';
            response.message = 'An unexpected error occurred: ' + e.getMessage();
            sendResponse(500, response);
        }
    }

    /**
     * Queries account by name
     */
    private static List<Account> queryAccountsByName(String accountName) {
        String normalizedAccountName = normalizeAccountNameParam(accountName);
        if (String.isBlank(normalizedAccountName)) {
            return new List<Account>();
        }
        try {
            return [
                SELECT Id, Name, ParentId, Parent.Name, Core_MDF_CoMarketing_Ultimate_Account__c,
                       Core_MDF_CoMarketing_Ultimate_Account__r.Name
                FROM Account
                WHERE Name = :normalizedAccountName
                AND Core_MDF_Active_Ind__c = true
            ];
        } catch (Exception e) {
            return new List<Account>();
        }
    }

    @TestVisible
    private static String normalizeAccountNameParam(String accountName) {
        if (String.isBlank(accountName)) {
            return null;
        }
        String normalizedAccountName = accountName.trim();
        while (normalizedAccountName.length() >= 2 &&
            ((normalizedAccountName.startsWith('\'') && normalizedAccountName.endsWith('\'')) ||
             (normalizedAccountName.startsWith('"') && normalizedAccountName.endsWith('"')))) {
            normalizedAccountName = normalizedAccountName.substring(1, normalizedAccountName.length() - 1).trim();
        }
        return normalizedAccountName;
    }

    /**
     * Loads campaign values through the shared filtered-record utility and maps them to the fields
     * this metadata endpoint needs for filtering picklist values and user lookups.
     */
    private static Campaign getFilteredCampaign(String campaignId) {
        Map<String, Object> campaignValues = Core_MDF_CCP_RestAPI_Utility.getFilteredRecord(
            CAMPAIGN_OBJECT_NAME,
            campaignId,
            CAMPAIGN_DEFAULT_DISPLAY_FIELDS
        );
        if (campaignValues == null || campaignValues.isEmpty()) {
            return queryCampaignById(campaignId);
        }

        Campaign campaignRecord = new Campaign();
        campaignRecord.Id = (Id) campaignId;
        campaignRecord.Name = getFilteredString(campaignValues, 'Name');
        campaignRecord.Core_MDF_Account__c = getFilteredId(campaignValues, 'Core_MDF_Account__c');
        campaignRecord.Core_MDF_Program__c = getFirstFilteredString(campaignValues, new List<String>{'Core_MDF_Program__c', 'Core_MDF_Channel_Program__r.Name'});
        campaignRecord.Core_MDF_Activity_Category__c = getFilteredString(campaignValues, 'Core_MDF_Activity_Category__c');
        campaignRecord.Core_MDF_Activity_Type__c = getFilteredString(campaignValues, 'Core_MDF_Activity_Type__c');
        campaignRecord.Core_MDF_Priority__c = getFilteredString(campaignValues, 'Core_MDF_Priority__c');
        campaignRecord.Core_MDF_Priority_2_nm__c = getFilteredString(campaignValues, 'Core_MDF_Priority_2_nm__c');
        campaignRecord.Core_MDF_Priority_3_nm__c = getFilteredString(campaignValues, 'Core_MDF_Priority_3_nm__c');
        campaignRecord.Core_MDF_Audience__c = getFilteredString(campaignValues, 'Core_MDF_Audience__c');
        campaignRecord.Core_MDF_Market__c = getFilteredString(campaignValues, 'Core_MDF_Market__c');
        campaignRecord.Core_MDF_Brand__c = getFilteredString(campaignValues, 'Core_MDF_Brand__c');
        campaignRecord.Core_MDF_Product_Type__c = getFilteredString(campaignValues, 'Core_MDF_Product_Type__c');
        campaignRecord.Core_MDF_Industry_Nm__c = getFilteredString(campaignValues, 'Core_MDF_Industry_Nm__c');
        campaignRecord.Core_MDF_Opal_Budget_Type_Txt__c = getFilteredString(campaignValues, 'Core_MDF_Opal_Budget_Type_Txt__c');
        populateBackendCampaignFields(campaignRecord);
        enforceCampaignUltimateAccountAccess(campaignRecord);
        return campaignRecord;
    }

    private static Campaign queryCampaignById(String campaignId) {
        try {
            List<Campaign> campaigns = [
                SELECT Id, Name, Core_MDF_Account__c, Core_MDF_Program__c,
                       Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c,
                       Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c, Core_MDF_Priority_3_nm__c,
                       Core_MDF_Audience__c, Core_MDF_Market__c, Core_MDF_Brand__c,
                       Core_MDF_Product_Type__c, Core_MDF_Industry_Nm__c,
                       Core_MDF_Opal_Budget_Type_Txt__c
                FROM Campaign
                WHERE Id = :campaignId
                LIMIT 1
            ];
            if (campaigns.isEmpty()) {
                return null;
            }
            //enforceCampaignUltimateAccountAccess(campaigns[0]);
            return campaigns[0];
        } catch (Exception e) {
            if (e instanceof Core_MDF_CCP_RestAPI_Utility.AccessDeniedException) {
                throw e;
            }
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }

    private static void enforceCampaignUltimateAccountAccess(Campaign campaignRecord) {
        if (!currentUserHasCampaignUltimateAccountGroupAccess(campaignRecord)) {
            throw new Core_MDF_CCP_RestAPI_Utility.AccessDeniedException('You do not have access to Campaign.');
        }
    }

    @TestVisible
    public static Boolean currentUserHasCampaignUltimateAccountGroupAccess(Campaign campaignRecord) {
        Id loggedInUserAccountId = getUserAccountId();
        Id ultimateAccountId = getCampaignUltimateAccountId(campaignRecord);
        if (ultimateAccountId == null) {
            return false;
        }
        if (loggedInUserAccountId == null || loggedInUserAccountId != ultimateAccountId) {
            return false;
        }
        return true;
    }

    private static Id getUserAccountId() {
        Id currentUserId = UserInfo.getUserId();
        List<User> users = [
            SELECT AccountId
            FROM User
            WHERE Id = :currentUserId
            LIMIT 1
        ];
        if (users.isEmpty()) {
            return null;
        }
        return users[0].AccountId;
    }

    private static Id getCampaignUltimateAccountId(Campaign campaignRecord) {
        if (campaignRecord == null || campaignRecord.Core_MDF_Account__c == null) {
            return null;
        }

        List<Account> campaignAccounts = [
            SELECT Id, ParentId, Core_MDF_CoMarketing_Ultimate_Account__c
            FROM Account
            WHERE Id = :campaignRecord.Core_MDF_Account__c
            LIMIT 1
        ];
        if (campaignAccounts.isEmpty()) {
            return null;
        }

        Account campaignAccount = campaignAccounts[0];
        if (campaignAccount.Core_MDF_CoMarketing_Ultimate_Account__c != null) {
            return campaignAccount.Core_MDF_CoMarketing_Ultimate_Account__c;
        }

        Id currentAccountId = campaignAccount.Id;
        Id parentAccountId = campaignAccount.ParentId;
        Integer depth = 0;
        while (parentAccountId != null && depth < 10) {
            List<Account> parentAccounts = [
                SELECT Id, ParentId
                FROM Account
                WHERE Id = :parentAccountId
                LIMIT 1
            ];
            if (parentAccounts.isEmpty()) {
                break;
            }
            currentAccountId = parentAccounts[0].Id;
            parentAccountId = parentAccounts[0].ParentId;
            depth++;
        }
        return currentAccountId;
    }

    private static String getCampaignNumber(Id campaignId) {
        if (campaignId == null) {
            return null;
        }
        try {
            List<Campaign> campaigns = [
                SELECT Core_MDF_Campaign_Reference_Number__c
                FROM Campaign
                WHERE Id = :campaignId
                LIMIT 1
            ];
            return campaigns.isEmpty() ? null : campaigns[0].Core_MDF_Campaign_Reference_Number__c;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }

    private static void populateBackendCampaignFields(Campaign campaignRecord) {
        if (campaignRecord == null || campaignRecord.Id == null) {
            return;
        }

        try {
            Campaign backendCampaign = [
                SELECT Name, Core_MDF_Account__c, Core_MDF_Program__c,
                       Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c,
                       Core_MDF_Market__c
                FROM Campaign
                WHERE Id = :campaignRecord.Id
                LIMIT 1
            ];

            if (String.isBlank(campaignRecord.Name)) {
                campaignRecord.Name = backendCampaign.Name;
            }
            if (String.isBlank(campaignRecord.Core_MDF_Account__c)) {
                campaignRecord.Core_MDF_Account__c = backendCampaign.Core_MDF_Account__c;
            }
            if (String.isBlank(campaignRecord.Core_MDF_Program__c) || !SUPPORTED_COMARKETING_PROGRAMS.contains(campaignRecord.Core_MDF_Program__c)) {
                campaignRecord.Core_MDF_Program__c = backendCampaign.Core_MDF_Program__c;
            }
            if (String.isBlank(campaignRecord.Core_MDF_Activity_Category__c)) {
                campaignRecord.Core_MDF_Activity_Category__c = backendCampaign.Core_MDF_Activity_Category__c;
            }
            if (String.isBlank(campaignRecord.Core_MDF_Activity_Type__c)) {
                campaignRecord.Core_MDF_Activity_Type__c = backendCampaign.Core_MDF_Activity_Type__c;
            }
            if (String.isBlank(campaignRecord.Core_MDF_Market__c)) {
                campaignRecord.Core_MDF_Market__c = backendCampaign.Core_MDF_Market__c;
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    private static String getFirstFilteredString(Map<String, Object> filteredValues, List<String> fieldApiNames) {
        if (fieldApiNames == null) {
            return null;
        }
        for (String fieldApiName : fieldApiNames) {
            String value = getFilteredString(filteredValues, fieldApiName);
            if (String.isNotBlank(value)) {
                return value;
            }
        }
        return null;
    }

    private static String getFilteredString(Map<String, Object> filteredValues, String fieldApiName) {
        Object value = getFilteredValue(filteredValues, fieldApiName);
        return value == null ? null : String.valueOf(value);
    }

    private static Id getFilteredId(Map<String, Object> filteredValues, String fieldApiName) {
        String value = getFilteredString(filteredValues, fieldApiName);
        if (String.isBlank(value)) {
            return null;
        }
        try {
            return Id.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }

    private static Object getFilteredValue(Map<String, Object> filteredValues, String fieldApiName) {
        if (filteredValues == null || String.isBlank(fieldApiName)) {
            return null;
        }
        if (filteredValues.containsKey(fieldApiName)) {
            return filteredValues.get(fieldApiName);
        }
        String fieldLabel = getCampaignFieldLabel(fieldApiName);
        return String.isNotBlank(fieldLabel) && filteredValues.containsKey(fieldLabel)
            ? filteredValues.get(fieldLabel)
            : null;
    }

    private static String getCampaignFieldLabel(String fieldApiName) {
        Schema.SObjectField fieldToken = Schema.SObjectType.Campaign.fields.getMap().get(fieldApiName);
        return fieldToken == null ? null : fieldToken.getDescribe().getLabel();
    }

    private static Integer applyConfiguredError(PicklistValuesResponse response, String errorCode, String fallbackHttpStatusCode, String fallbackMessage, List<String> messageArgs) {
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting errorConfig = getErrorConfigDetails(errorCode, fallbackHttpStatusCode);
        String configuredMessage = errorConfig == null ? null : formatConfiguredMessage(errorConfig.message, messageArgs);

        response.isSuccess = false;
        response.code = errorConfig != null && String.isNotBlank(errorConfig.code) ? errorConfig.code : errorCode;
        response.message = String.isNotBlank(configuredMessage) ? configuredMessage : fallbackMessage;
        return parseHttpStatusCode(errorConfig != null ? errorConfig.httpStatusCode : null, fallbackHttpStatusCode);
    }

    private static Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting getErrorConfigDetails(String errorCode, String fallbackHttpStatusCode) {
        return Core_MDF_PFR_RestAPI_Utility.getResponseCodeSetting(errorCode, fallbackHttpStatusCode, null);
    }

    private static String formatConfiguredMessage(String message, List<String> messageArgs) {
        if (String.isBlank(message) || messageArgs == null || messageArgs.isEmpty()) {
            return message;
        }
        try {
            return String.format(message, messageArgs);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return message;
        }
    }

    private static Integer parseHttpStatusCode(String configuredHttpStatusCode, String fallbackHttpStatusCode) {
        String statusCode = String.isNotBlank(configuredHttpStatusCode) ? configuredHttpStatusCode : fallbackHttpStatusCode;
        try {
            return Integer.valueOf(statusCode);
        } catch (Exception e) {
            return 500;
        }
    }

    /**
     * Queries the account associated with a campaign
     * Note: Campaign object does not have standard AccountId field
     */
    private static Account queryCampaignAccount(Id campaignId) {
        return null;
    }

    /**
     * Resolves the ultimate account by traversing the hierarchy
     */
    private static String resolveUltimateAccount(Account requestedAccount) {
        if (requestedAccount == null) {
            return null;
        }
        
        List<Account> lstAccount =[SELECT Id,Name,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id=: requestedAccount.id];
        Id utlimateAcId = requestedAccount.id;
        if(!lstAccount.isEmpty()) utlimateAcId = lstAccount[0].Core_MDF_CoMarketing_Ultimate_Account__c != null ? lstAccount[0].Core_MDF_CoMarketing_Ultimate_Account__c : lstAccount[0].id;
        
        return utlimateAcId;
    }
    
    /**
     * Gets Member Acceptor users in structured format grouped by Account Name (similar to SegmentProduct)
     * Returns List of maps with structure: {"Account Name": "...", "allowed values": [{userId, name}, ...]}
     */
    private static List<Map<String, Object>> getMemberAcceptorUsersStructured(Campaign campaignDetail) {
        List<Map<String, Object>> structuredUsers = new List<Map<String, Object>>();
        if (campaignDetail == null) {
            return structuredUsers;
        }

        String submitterPermissionSetName = Core_MDF_CustomLabelConfig.getTextValues(EXTERNAL_SUBMITTER_PERMISSION_SET);
        if (String.isBlank(submitterPermissionSetName)) {
            submitterPermissionSetName = EXTERNAL_SUBMITTER_PERMISSION_SET;
        }

        try {
            Set<Id> accountIds = new Set<Id>();
            String utlimateAcid ='';
            if (String.isNotBlank(campaignDetail.Core_MDF_Account__c)) {
                accountIds.add(campaignDetail.Core_MDF_Account__c);
                utlimateAcid =campaignDetail.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c ;
            }
            Campaign objCmp =[select id,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c from campaign where id=:campaignDetail.id limit 1];
            // Include direct child and related accounts tied to the campaign account.
            // This ensures only accounts with member acceptor mappings are returned,
            // while skipping accounts that do not have a mapping.
            List<Account> relatedAccounts = [
                SELECT id
                    FROM Account
                    WHERE Core_MDF_CoMarketing_Ultimate_Account__c = : objCmp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c //'0012i00000Ke2jfAAB' //campaignDetail.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
                    AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: campaignDetail.Core_MDF_Program__c
                    AND Core_MDF_Active_Ind__c =: true
                    LIMIT 500
            ];

            for (Account relatedAccount : relatedAccounts) {
                if (relatedAccount.Id != null) {
                    accountIds.add(relatedAccount.Id);
                }
            }

            if (accountIds.isEmpty()) {
                return structuredUsers;
            }

            List<Core_MDF_Partner_Node_User_Mapping__c> memberAcceptorMappings = [
                SELECT Core_MDF_Account__c,
                       Core_MDF_Account__r.Name,
                       Core_MDF_User__c,
                       Core_MDF_User__r.Name
                FROM Core_MDF_Partner_Node_User_Mapping__c
                WHERE Core_MDF_Account__c IN :accountIds
                  AND Core_MDF_Active_Ind__c = true
                  AND Core_MDF_User__c != null
                  AND Core_MDF_User__r.IsActive = true
                  AND Core_MDF_User__r.UserType = :PARTNER_COMMUNITY_USER_TYPE
            ];

            if (memberAcceptorMappings.isEmpty()) {
                return structuredUsers;
            }

            Set<Id> userIdsForPermissionCheck = new Set<Id>();
            for (Core_MDF_Partner_Node_User_Mapping__c memberMapping : memberAcceptorMappings) {
                if (memberMapping.Core_MDF_User__c != null) {
                    userIdsForPermissionCheck.add(memberMapping.Core_MDF_User__c);
                }
            }

            Set<Id> permittedUserIds = new Set<Id>();
            try {
                for (PermissionSetAssignment psa : [
                    SELECT AssigneeId
                    FROM PermissionSetAssignment
                    WHERE AssigneeId IN :userIdsForPermissionCheck
                      AND PermissionSet.Name = :submitterPermissionSetName
                ]) {
                    permittedUserIds.add(psa.AssigneeId);
                }
            } catch (QueryException e) {
                // PermissionSetAssignment not queryable in this context; return mapped users anyway.
            }

            Map<String, List<Map<String, String>>> usersByAccountName = new Map<String, List<Map<String, String>>>();
            for (Core_MDF_Partner_Node_User_Mapping__c memberMapping : memberAcceptorMappings) {
                if (memberMapping.Core_MDF_User__c == null || memberMapping.Core_MDF_Account__r == null || String.isBlank(memberMapping.Core_MDF_Account__r.Name)) {
                    continue;
                }

                if (!permittedUserIds.isEmpty() && !permittedUserIds.contains(memberMapping.Core_MDF_User__c)) {
                    continue;
                }

                String accountName = memberMapping.Core_MDF_Account__r.Name;
                if (!usersByAccountName.containsKey(accountName)) {
                    usersByAccountName.put(accountName, new List<Map<String, String>>());
                }

                usersByAccountName.get(accountName).add(new Map<String, String>{
                    'userId' => String.valueOf(memberMapping.Core_MDF_User__c),
                    'name' => memberMapping.Core_MDF_User__r.Name
                });
            }

            List<String> sortedAccountNames = new List<String>(usersByAccountName.keySet());
            sortedAccountNames.sort();

            for (String accountName : sortedAccountNames) {
                structuredUsers.add(new Map<String, Object>{
                    'Account Name' => accountName,
                    'allowed values' => usersByAccountName.get(accountName)
                });
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return structuredUsers;
    }

    private static List<UserDetail> getIntelApproverUsers(Id ultimateAccountId) {
        return getIntelApproverUsers(ultimateAccountId, null);
    }

    public static List<UserDetail> getIntelApproverUsers(Campaign campaignRecord) {
        if (campaignRecord == null || campaignRecord.Core_MDF_Account__c == null) {
            return new List<UserDetail>();
        }

        try {
            List<Account> campaignAccounts = [
                SELECT Id, Name, ParentId, Parent.Name,
                       Core_MDF_CoMarketing_Ultimate_Account__c,
                       Core_MDF_CoMarketing_Ultimate_Account__r.Name
                FROM Account
                WHERE Id = :campaignRecord.Core_MDF_Account__c
                LIMIT 1
            ];
            if (campaignAccounts.isEmpty()) {
                return new List<UserDetail>();
            }

            String ultimateAccount = resolveUltimateAccount(campaignAccounts[0]);
            return ultimateAccount == null ? new List<UserDetail>() : getIntelApproverUsers(ultimateAccount, campaignRecord);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return new List<UserDetail>();
        }
    }

    /**
     * Gets Intel Approver users for the ultimate account, optionally filtered by campaign country regions
     * @param ultimateAccountId The ultimate account ID
     * @param campaignRecord Optional campaign record to filter by country-mapped regions
     * @return List of Intel Approver users, filtered by region if campaign is provided
     */
    private static List<UserDetail> getIntelApproverUsers(Id ultimateAccountId, Campaign campaignRecord) {
        List<UserDetail> userDetails = new List<UserDetail>();
        if (ultimateAccountId == null) {
            return userDetails;
        }

        // Get allowed regions based on campaign countries
        Set<String> allowedRegions = new Set<String>();
        if (campaignRecord != null && String.isNotBlank(campaignRecord.Core_MDF_Market__c)) {
            List<String> campaignCountries = new List<String>();
            for (String country : campaignRecord.Core_MDF_Market__c.split(';')) {
                String trimmedCountry = country.trim();
                if (String.isNotBlank(trimmedCountry)) {
                    campaignCountries.add(trimmedCountry);
                }
            }
            
            if (!campaignCountries.isEmpty()) {
                allowedRegions = getRegionsForCountries(campaignCountries);
            }
        }

        try {
                        String campaignProgram = campaignRecord == null ? null : campaignRecord.Core_MDF_Program__c;
            Set<Id> addedUserIds = new Set<Id>();
                        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> mappings = String.isBlank(campaignProgram)
                                ? [
                                        SELECT Id, Name, Core_MDF_Role_nm__c, Core_MDF_User_id__c, Core_MDF_User_id__r.Name,
                                                     Core_MDF_Region_Sub_Region_nm__c, Core_MDF_User_id__r.Username
                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                        WHERE Core_MDF_Account_id__c = :ultimateAccountId
                                            AND Core_MDF_Active_Ind__c = true
                                            AND Core_MDF_is_User_Active_ind__c = true
                                            AND Core_MDF_Role_nm__c IN :INTEL_APPROVER_ROLES
                                            AND Core_MDF_User_id__c != null
                                        ORDER BY Core_MDF_User_id__r.Username
                                ]
                                : [
                                        SELECT Id, Name, Core_MDF_Role_nm__c, Core_MDF_User_id__c, Core_MDF_User_id__r.Name,
                                                     Core_MDF_Region_Sub_Region_nm__c, Core_MDF_User_id__r.Username
                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                        WHERE Core_MDF_Account_id__c = :ultimateAccountId
                                            AND Core_MDF_Active_Ind__c = true
                                            AND Core_MDF_is_User_Active_ind__c = true
                                            AND Core_MDF_Program_nm__c = :campaignProgram
                                            AND Core_MDF_Role_nm__c IN :INTEL_APPROVER_ROLES
                                            AND Core_MDF_User_id__c != null
                                        ORDER BY Core_MDF_User_id__r.Username
                                ];
                        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c mapping : mappings) {
                // Filter by region if campaign country restrictions exist
                if (allowedRegions.isEmpty() || mapping.Core_MDF_Region_Sub_Region_nm__c == GLOBAL_APPROVER_REGION || allowedRegions.contains(mapping.Core_MDF_Region_Sub_Region_nm__c)) {
                    if (addedUserIds.add(mapping.Core_MDF_User_id__c)) {
                        userDetails.add(new UserDetail(
                            mapping.Core_MDF_User_id__c,
                            mapping.Core_MDF_User_id__r.Name,
                            mapping.Core_MDF_Region_Sub_Region_nm__c
                        ));
                    }
                }
            }
        } catch (Exception e) {
            // Silently fail - return empty list
        }
        return userDetails;
    }

    private static List<UserDetail> getIntelApproverUsers(List<Account> accounts, Campaign campaignRecord) {
        List<UserDetail> userDetails = new List<UserDetail>();
        Set<Id> addedUserIds = new Set<Id>();
        if (accounts == null || accounts.isEmpty()) {
            return userDetails;
        }

        for (Account accountRecord : accounts) {
            String ultimateAccount = resolveUltimateAccount(accountRecord);
            if (ultimateAccount == null) {
                continue;
            }
            for (UserDetail userDetail : getIntelApproverUsers(ultimateAccount, campaignRecord)) {
                if (addedUserIds.add(userDetail.userId)) {
                    userDetails.add(userDetail);
                }
            }
        }
        return userDetails;
    }

    /**
     * Queries the country-to-region mapping metadata and returns regions for given countries
     * @param countries List of country names from campaign
     * @return Set of region names that map to the given countries
     */
    private static Set<String> getRegionsForCountries(List<String> countries) {
        Set<String> regions = new Set<String>();
        if (countries == null || countries.isEmpty()) {
            return regions;
        }

        try {
            // Query the metadata to get region mappings for the given countries
            // The query uses dynamic SOQL to handle the metadata query
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
     * Builds the response values for one requested PFR field, honoring campaign-level restrictions.
     */
    private static PicklistFieldValues processField(Map<String, Schema.SObjectField> fieldMap, String pfrFieldName, Campaign campaignRecord) {
        PicklistFieldValues fieldValues = new PicklistFieldValues();
        fieldValues.fieldLabel = FIELD_LABELS.get(pfrFieldName);
        fieldValues.values = new List<String>();

        if (isCampaignLevelActivityField(pfrFieldName)) {
            populateCampaignLevelValues(fieldValues, fieldMap, pfrFieldName, campaignRecord);
            return fieldValues;
        }
        
        // Special handling for Budget Type - check Campaign object picklist instead of PFR
        if (pfrFieldName == 'Core_MDF_Opal_Budget_Type_Txt__c') {
            // Get active picklist values from Campaign object instead of PFR
            Set<String> activeCampaignValues = getActiveCampaignPicklistValues('Core_MDF_Opal_Budget_Type_Txt__c');
            // Get campaign values for this field
            List<String> campaignValues = getCampaignFieldValues(campaignRecord, pfrFieldName);
            if (campaignValues != null) {
                // Use campaign values, but only if they're active in Campaign picklist
                for (String campaignValue : campaignValues) {
                    if (activeCampaignValues.contains(campaignValue)) {
                        fieldValues.values.add(campaignValue);
                    }
                }
            } else {
                // No campaign restriction - use all active Campaign picklist values
                fieldValues.values.addAll(activeCampaignValues);
            }
            return fieldValues;
        }
        
        // Special handling for Priority - return campaign level Priority value directly
        if (pfrFieldName == 'Core_MDF_Priorities__c') {
            List<String> campaignValues = getCampaignFieldValues(campaignRecord, pfrFieldName);
            if (campaignValues != null) {
                // Return the campaign priority value(s) directly without filtering
                fieldValues.values.addAll(campaignValues);
            }
            // If no campaign priority is set, return empty list (don't fallback to all active values)
            return fieldValues;
        }

        if (pfrFieldName == 'Core_MDF_Reimbursement_Rate_txt__c') {
            Set<String> campaignRates = getCampaignReimbursementRateValues(campaignRecord);
            if (!campaignRates.isEmpty()) {
                fieldValues.values.addAll(campaignRates);
                fieldValues.values.sort();
                return fieldValues;
            }
        }
        
        // Get active picklist values from PFR field, filtered by program type
        String programType = getProgramTypeFromCampaign(campaignRecord);
        Set<String> activePfrValues = getActivePfrPicklistValues(fieldMap, pfrFieldName, programType);
        
        // Get campaign values for this field
        List<String> campaignValues = getCampaignFieldValues(campaignRecord, pfrFieldName);
        
        if (campaignValues != null) {
            // Use campaign values, but only if they're active in PFR
            for (String campaignValue : campaignValues) {
                if (activePfrValues.contains(campaignValue)) {
                    fieldValues.values.add(campaignValue);
                }
            }
        } else {
            // No campaign restriction - use all active PFR values
            fieldValues.values.addAll(activePfrValues);
        }
        
        return fieldValues;
    }

    /**
     * Adds dependent picklist value mappings for fields that are controlled by another field.
     * All dependent fields (including Event Name) use buildDependentValuesFor with program-type filtering.
     */
    private static void addDependentValues(PicklistFieldValues fieldValues, String pfrFieldName, Map<String, Schema.SObjectField> fieldMap, Campaign campaignRecord) {
        if (DEPENDENT_FIELDS.containsKey(pfrFieldName)) {
            Map<String, String> depInfo = DEPENDENT_FIELDS.get(pfrFieldName);
            fieldValues.dependentOn = depInfo.get('dependentOn');
            
            String controllingField = depInfo.get('controllingField');
            List<String> controllingAllowed = getCampaignFieldValues(campaignRecord, controllingField);
            
            // Pass program type so dependent values can be filtered by program
            String programType = getProgramTypeFromCampaign(campaignRecord);
            
            // Use buildDependentValuesFor for all fields - it queries Core_MDF_PFRCustomPicklist__c
            // and filters by program type and only returns active values
            fieldValues.dependentValues = buildDependentValuesFor(controllingField, pfrFieldName, controllingAllowed, programType);
            if (isCampaignLevelActivityField(pfrFieldName)) {
                filterDependentValuesToFieldValues(fieldValues);
            }
            if (pfrFieldName == 'Core_MDF_Activity_Types__c' || pfrFieldName == 'Core_MDF_Event_Name_nm__c' || pfrFieldName == 'Core_MDF_Activity_SubType_nm__c') {
                fieldValues.values = new List<String>();
            }
        }
    }

    private static Boolean isCampaignLevelActivityField(String pfrFieldName) {
        return pfrFieldName == 'Core_MDF_ActivityCategory__c' || pfrFieldName == 'Core_MDF_Activity_Types__c';
    }

    private static void populateCampaignLevelValues(PicklistFieldValues fieldValues, Map<String, Schema.SObjectField> fieldMap, String pfrFieldName, Campaign campaignRecord) {
        List<String> campaignValues;
        try {
            campaignValues = getCampaignFieldValues(campaignRecord, pfrFieldName);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return;
        }
        if (campaignValues == null || campaignValues.isEmpty()) {
            return;
        }

        Set<String> activeValues = new Set<String>();
        try {
            activeValues = getActivePfrPicklistValues(fieldMap, pfrFieldName, getProgramTypeFromCampaign(campaignRecord));
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }

        Set<String> addedValues = new Set<String>();
        for (String campaignValue : campaignValues) {
            if (String.isBlank(campaignValue)) {
                continue;
            }
            String trimmedValue = campaignValue.trim();
            if (!activeValues.isEmpty() && !activeValues.contains(trimmedValue)) {
                continue;
            }
            if (addedValues.add(trimmedValue)) {
                fieldValues.values.add(trimmedValue);
            }
        }
    }

    private static void filterDependentValuesToFieldValues(PicklistFieldValues fieldValues) {
        if (fieldValues == null || fieldValues.values == null || fieldValues.values.isEmpty() || fieldValues.dependentValues == null) {
            return;
        }
        Set<String> allowedValues = new Set<String>(fieldValues.values);
        for (String controllingValue : fieldValues.dependentValues.keySet()) {
            List<String> filteredValues = new List<String>();
            for (String dependentValue : fieldValues.dependentValues.get(controllingValue)) {
                if (allowedValues.contains(dependentValue)) {
                    filteredValues.add(dependentValue);
                }
            }
            fieldValues.dependentValues.put(controllingValue, filteredValues);
        }
    }

    

    /**
     * Returns the program type (CCF or DCF) from the campaign record.
     * Maps: "Client Co-Marketing Fund" → CCF, "Data Center Co-Marketing Fund" → DCF
     * Used to filter active picklist values based on program type.
     */
    private static String getProgramTypeFromCampaign(Campaign campaignRecord) {
        if (campaignRecord == null || String.isBlank(campaignRecord.Core_MDF_Program__c)) {
            return null;
        }
        
        String program = campaignRecord.Core_MDF_Program__c.toLowerCase();
        if (program.contains('client')) {
            return 'CCF'; // Client Co-Marketing Fund
        } else if (program.contains('data center') || program.contains('datacenter')) {
            return 'DCF'; // Data Center Co-Marketing Fund
        }
        
        return null;
    }

    // Get active picklist values from PFR field
    private static Set<String> getActivePfrPicklistValues(Map<String, Schema.SObjectField> fieldMap, String fieldName) {
        return getActivePfrPicklistValues(fieldMap, fieldName, null);
    }

    /**
     * Get active picklist values from Core_MDF_PFRCustomPicklist__c, filtered by program type.
     * First checks Core_MDF_PFRCustomPicklist__c for active values. Falls back to PartnerFundRequest
     * if the custom object is unavailable.
     * 
     * @param fieldMap PartnerFundRequest field map (fallback)
     * @param fieldName Field API name
     * @param programType Program type: 'CCF' (Client) or 'DCF' (Data Center), or null for all
     * @return Set of active picklist values filtered by program type
     */
    private static Set<String> getActivePfrPicklistValues(Map<String, Schema.SObjectField> fieldMap, String fieldName, String programType) {
        Set<String> activeValues = new Set<String>();
        
        try {
            // First, try to get active values from Core_MDF_PFRCustomPicklist__c
            Schema.SObjectType customPicklistType = Schema.getGlobalDescribe().get('Core_MDF_PFRCustomPicklist__c');
            if (customPicklistType != null) {
                Map<String, Schema.SObjectField> customFieldMap = customPicklistType.getDescribe().fields.getMap();
                if (customFieldMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDescribe = customFieldMap.get(fieldName).getDescribe();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        if (entry.isActive()) {
                            activeValues.add(entry.getValue());
                        }
                    }
                    return activeValues;
                }
            }
        } catch (Exception e) {
            // Fall through to PartnerFundRequest fallback
        }
        
        // Fallback: Get active picklist values from PartnerFundRequest field
        if (fieldMap.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    activeValues.add(entry.getValue());
                }
            }
        }
        
        return activeValues;
    }

    // Get active picklist values from Campaign object
    private static Set<String> getActiveCampaignPicklistValues(String fieldName) {
        Set<String> activeValues = new Set<String>();
        
        try {
            Schema.SObjectType campaignType = Schema.getGlobalDescribe().get('Campaign');
            Map<String, Schema.SObjectField> campaignFieldMap = campaignType.getDescribe().fields.getMap();
            
            if (campaignFieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldDescribe = campaignFieldMap.get(fieldName).getDescribe();
                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    if (entry.isActive()) {
                        activeValues.add(entry.getValue());
                    }
                }
            }
        } catch (Exception e) {
            return activeValues;
        }
        
        return activeValues;
    }

    /**
     * Returns allowed budgets in a structured format with budgetNo, startDate, and endDate.
     * Each budget includes the reference number, budget type, start date, and end date.
     * @param campaignRecord Campaign record to get associated budgets
     * @return List of maps containing budget details
     */
    private static List<Map<String, Object>> getAllowedBudgetsStructured(Campaign campaignRecord) {
        List<Map<String, Object>> budgetList = new List<Map<String, Object>>();
        
        if (campaignRecord == null || String.isBlank(campaignRecord.Id)) {
            System.debug('getAllowedBudgetsStructured: Campaign is null or blank');
            return budgetList;
        }
        
        try {
            System.debug('getAllowedBudgetsStructured: Querying budgets for campaignId=' + campaignRecord.Id);
            // Execute the SOQL query - Fixed field references
            // NOTE: Removed WITH USER_MODE to allow system-level access (bypasses FLS for API users)
            List<Core_MDF_Campaign_Budgets__c> campaignBudgets = [
                SELECT Core_MDF_Campaign_Id__c, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Type_Nm__c, 
                       Core_MDF_Start_Date_Dt__c, Core_MDF_End_Date_Dt__c, 
                       Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c
                FROM Core_MDF_Campaign_Budgets__c 
                WHERE Core_MDF_Campaign_Id__c = :campaignRecord.Id
                AND Core_MDF_Budget_Name_Id__r.TotalAllocatedAmount > 0 
                AND Core_MDF_Active_ind__c = true
                ORDER BY Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c, Core_MDF_Start_Date_Dt__c
            ];

            System.debug('getAllowedBudgetsStructured: Found ' + campaignBudgets.size() + ' budgets');
            
            // Build structured budget list
            Set<String> addedBudgets = new Set<String>();
            for (Core_MDF_Campaign_Budgets__c budget : campaignBudgets) {
                String budgetNo = budget.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c;
                
                if (String.isBlank(budgetNo)) {
                    System.debug('getAllowedBudgetsStructured: Skipping budget with blank budgetNo');
                    continue;
                }
                
                // Create unique key to avoid duplicates
                String budgetKey = budgetNo + '|' + String.valueOf(budget.Core_MDF_Start_Date_Dt__c) + '|' + String.valueOf(budget.Core_MDF_End_Date_Dt__c);
                if (addedBudgets.contains(budgetKey)) {
                    System.debug('getAllowedBudgetsStructured: Skipping duplicate budget=' + budgetNo);
                    continue;
                }
                addedBudgets.add(budgetKey);

                Map<String, Object> budgetMap = new Map<String, Object>();
                budgetMap.put('budgetNo', budgetNo);
                budgetMap.put('budgetType', budget.Core_MDF_Budget_Type_Nm__c);
                budgetMap.put('startDate', budget.Core_MDF_Start_Date_Dt__c != null ? budget.Core_MDF_Start_Date_Dt__c.format() : null);
                budgetMap.put('endDate', budget.Core_MDF_End_Date_Dt__c != null ? budget.Core_MDF_End_Date_Dt__c.format() : null);
                budgetMap.put('budgetId', budget.Core_MDF_Budget_Name_Id__c);
                
                System.debug('getAllowedBudgetsStructured: Added budget=' + budgetNo);
                budgetList.add(budgetMap);
            }
            System.debug('getAllowedBudgetsStructured: Returning ' + budgetList.size() + ' budgets');
        } catch (Exception e) {
            System.debug('getAllowedBudgetsStructured: Exception=' + e.getMessage() + ', StackTrace=' + e.getStackTraceString());
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
        return budgetList;
    }

    /**
     * Returns allowed budgets in a list of strings (legacy method for backward compatibility).
     * Combines budgetType, budgetNo, startDate, and endDate into a single string.
     * @param campaignRecord Campaign record to get associated budgets
     * @return List of budget strings
     */
    private static List<String> getAllowedBudgetValues(Campaign campaignRecord) {
        List<String> allowedBudgets = new List<String>();
        
        if (campaignRecord == null) {
            return allowedBudgets;
        }
        if (!Core_MDF_Campaign_Budgets__c.SObjectType.getDescribe().isAccessible()) {
            return allowedBudgets;
        }
        
        try {
            // Create campaign map for the SOQL query
            Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
            campaignMap.put(campaignRecord.Id, campaignRecord);

            // Execute the SOQL query - Fixed field references
            List<Core_MDF_Campaign_Budgets__c> campaignBudgets = [
                SELECT Core_MDF_Campaign_Id__c, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Type_Nm__c, 
                       Core_MDF_Start_Date_Dt__c, Core_MDF_End_Date_Dt__c,Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c
                FROM Core_MDF_Campaign_Budgets__c 
                WHERE Core_MDF_Campaign_Id__c IN :campaignMap.keySet() 
                AND Core_MDF_Budget_Name_Id__r.TotalAllocatedAmount > 0 
                AND Core_MDF_Active_ind__c = true
                WITH USER_MODE
            ];

            // Extract budget names/types
            Set<String> uniqueBudgets = new Set<String>();
            for (Core_MDF_Campaign_Budgets__c budget : campaignBudgets) {
                // Use Budget Type field since Name field doesn't exist on PartnerMarketingBudget
                if (String.isNotBlank(budget.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c)) {
                    uniqueBudgets.add(budget.Core_MDF_Budget_Type_Nm__c + ' '+budget.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c + ' '+ budget.Core_MDF_Start_Date_Dt__c + ' '+ budget.Core_MDF_End_Date_Dt__c);
                }
            }

            allowedBudgets.addAll(uniqueBudgets);
        } catch (Exception e) {
            return allowedBudgets;
        }
        
        return allowedBudgets;
    }

    private static Map<String, List<String>> getReimbursementRateValuesByBudget(Campaign campaignRecord) {
        Map<String, Set<String>> rateSetsByBudget = new Map<String, Set<String>>();
        Map<String, List<String>> ratesByBudget = new Map<String, List<String>>();

        if (campaignRecord == null || campaignRecord.Id == null) {
            return ratesByBudget;
        }

        try {
            for (Core_MDF_Campaign_Budgets__c campaignBudget : [
                SELECT Core_MDF_Budget_Name_Id__c,
                       Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c,
                       Core_MDF_Reimbursement_Rate_Pct__c
                FROM Core_MDF_Campaign_Budgets__c
                WHERE Core_MDF_Campaign_Id__c = :campaignRecord.Id
                AND Core_MDF_Active_ind__c = true
            ]) {
                String rate = formatReimbursementRateValue(campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c);
                if (String.isBlank(rate)) {
                    continue;
                }
                String budgetReference = campaignBudget.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c;
                if (String.isBlank(budgetReference)) {
                    budgetReference = String.valueOf(campaignBudget.Core_MDF_Budget_Name_Id__c);
                }
                if (!rateSetsByBudget.containsKey(budgetReference)) {
                    rateSetsByBudget.put(budgetReference, new Set<String>());
                }
                rateSetsByBudget.get(budgetReference).add(rate);
            }

            for (String budgetReference : rateSetsByBudget.keySet()) {
                List<String> rates = new List<String>();
                rates.addAll(rateSetsByBudget.get(budgetReference));
                rates.sort();
                ratesByBudget.put(budgetReference, rates);
            }
        } catch (Exception e) {
            return ratesByBudget;
        }

        return ratesByBudget;
    }

    private static List<Map<String, String>> getReimbursementRateValues(Campaign campaignRecord) {
        List<Map<String, String>> reimbursementRates = new List<Map<String, String>>();
        Map<String, List<String>> ratesByBudget = getReimbursementRateValuesByBudget(campaignRecord);
        List<String> budgetReferences = new List<String>();
        budgetReferences.addAll(ratesByBudget.keySet());
        budgetReferences.sort();

        for (String budgetReference : budgetReferences) {
            for (String rate : ratesByBudget.get(budgetReference)) {
                reimbursementRates.add(new Map<String, String>{
                    'BudgetNo' => budgetReference,
                    'Allowed Value' => rate
                });
            }
        }
        return reimbursementRates;
    }

    private static Set<String> getCampaignReimbursementRateValues(Campaign campaignRecord) {
        Set<String> rates = new Set<String>();
        Map<String, List<String>> ratesByBudget = getReimbursementRateValuesByBudget(campaignRecord);
        for (List<String> budgetRates : ratesByBudget.values()) {
            rates.addAll(budgetRates);
        }
        return rates;
    }

    private static String formatReimbursementRateValue(String rateValue) {
        if (String.isBlank(rateValue)) {
            return null;
        }
        String normalizedRate = rateValue.trim();
        normalizedRate = normalizedRate.endsWith('%')
            ? normalizedRate.substring(0, normalizedRate.length() - 1).trim()
            : normalizedRate;

        try {
            Decimal numericRate = Decimal.valueOf(normalizedRate).stripTrailingZeros();
            return numericRate.scale() <= 0
                ? String.valueOf(numericRate.setScale(0))
                : String.valueOf(numericRate.setScale(numericRate.scale()));
        } catch (Exception e) {
            return normalizedRate;
        }
    }

    private static List<Map<String, Object>> getSegmentProductValues(Campaign campaignRecord) {
        List<Map<String, Object>> segmentProducts = new List<Map<String, Object>>();
        if (campaignRecord == null || String.isBlank(campaignRecord.Core_MDF_Account__c)) {
            return segmentProducts;
        }

        List<String> segments = getActivitySegmentValues();
        if (segments.isEmpty()) {
            return segmentProducts;
        }

        // String program = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(campaignRecord.Core_MDF_Program__c);
        String program = campaignRecord.Core_MDF_Program__c;
        Core_MDF_ActivitySegmentMapping.SystemOperations sysOp = new Core_MDF_ActivitySegmentMapping.SystemOperations();
        String accountId = sysOp.getUltimateAccountId(campaignRecord.Core_MDF_Account__c);
        if (String.isBlank(accountId)) {
            accountId = campaignRecord.Core_MDF_Account__c;
        }

        Set<String> processedSegments = new Set<String>();
        for (String segment : segments) {
            if (String.isBlank(segment) || processedSegments.contains(segment.toLowerCase())) {
                continue;
            }
            processedSegments.add(segment.toLowerCase());

            /*Map<Id, String> productNamesById = new Map<Id, String>();
            try {
                List<Core_MDF_Account_Product_Mapping__c> apmList = sysOp.getAccountProductMappings(segment, accountId, program);
                for (Core_MDF_Account_Product_Mapping__c apm : apmList) {
                    if (apm.Core_MDF_Product__c != null && apm.Core_MDF_Product__r != null && String.isNotBlank(apm.Core_MDF_Product__r.Name)) {
                        productNamesById.put(apm.Core_MDF_Product__c, apm.Core_MDF_Product__r.Name);
                    }
                }
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }*/
            Map<Id, String> productNamesById = new Map<Id, String>();
            
            try {
                List<Product2> products =
                    Core_MDF_ActivitySegmentMapping.getProductMappingForSegment(
                        segment,
                        accountId,
                        program
                    );
            
                if (products != null) {
                    for (Product2 product : products) {
                        if (
                            product.Id != null &&
                            String.isNotBlank(product.Name)
                        ) {
                            productNamesById.put(product.Id, product.Name);
                        }
                    }
                }
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }

            List<String> productSortKeys = new List<String>();
            for (Id productId : productNamesById.keySet()) {
                productSortKeys.add(productNamesById.get(productId) + '|' + String.valueOf(productId));
            }
            productSortKeys.sort();

            List<Map<String, String>> allowedValues = new List<Map<String, String>>();
            for (String productSortKey : productSortKeys) {
                List<String> productParts = productSortKey.split('\\|', 2);
                allowedValues.add(new Map<String, String>{
                    'Name' => productParts[0],
                    'ID' => productParts[1]
                });
            }
            segmentProducts.add(new Map<String, Object>{
                'Segment' => segment,
                'allowed values' => allowedValues
            });
        }

        return segmentProducts;
    }

    private static List<String> getActivitySegmentValues() {
        List<String> segments = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = Core_MDF_Activity_Segment_Mapping__c.Core_MDF_Segment_Name_nm__c.getDescribe();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.isActive() && String.isNotBlank(entry.getValue())) {
                    segments.add(entry.getValue());
                }
            }
            segments.sort();
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return segments;
    }

    private static List<Map<String, Object>> getAccountDetails(Campaign campaignRecord) {
        List<Map<String, Object>> accountDetails = new List<Map<String, Object>>();
        List<Map<String, String>> allowedValues = new List<Map<String, String>>();
        if (campaignRecord == null || campaignRecord.Core_MDF_Account__c == null || String.isBlank(campaignRecord.Core_MDF_Program__c)) {
            accountDetails.add(new Map<String, Object>{
                'AllowedValues' => allowedValues
            });
            return accountDetails;
        }

        try {
            List<Account> accounts = [
                SELECT Id, Name,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Virtual_Corp_Account_Id__r.name
                FROM Account
                WHERE Core_MDF_Virtual_Corp_Account_Id__c = :campaignRecord.Core_MDF_Account__c
                AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :campaignRecord.Core_MDF_Program__c
                AND Core_MDF_Active_Ind__c = true
                ORDER BY Name
                LIMIT 500
            ];

            Set<Id> addedAccountIds = new Set<Id>();
            for (Account accountRecord : accounts) {
                if(accountRecord.Core_MDF_Virtual_Corp_Account_Id__c != null && addedAccountIds.add(accountRecord.Core_MDF_Virtual_Corp_Account_Id__c)) {
                    allowedValues.add(new Map<String, String>{
                        'Name' => accountRecord.Core_MDF_Virtual_Corp_Account_Id__r.Name,
                        'ID'   => String.valueOf(
                                    accountRecord.Core_MDF_Virtual_Corp_Account_Id__c
                                  )
                    });
                    // Add to Set to Avoid Duplicate
                    addedAccountIds.add(accountRecord.Core_MDF_Virtual_Corp_Account_Id__c);
                }
                if (addedAccountIds.add(accountRecord.Id)) {
                    allowedValues.add(new Map<String, String>{
                        'Name' => accountRecord.Name,
                        'ID' => String.valueOf(accountRecord.Id)
                    });
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        accountDetails.add(new Map<String, Object>{
            'AllowedValues' => allowedValues
        });
        return accountDetails;
    }

    // Get campaign field values - split by semicolon and return as list
    private static List<String> getCampaignFieldValues(Campaign campaignRecord, String pfrFieldName) {
        if (campaignRecord == null) return null;
        
        // Special handling for Priority - map PFR field to campaign field and include all 3 priority levels
        if (pfrFieldName == 'Core_MDF_Priorities__c') {
            List<String> values = new List<String>();
            List<String> priorityFields = new List<String>{'Core_MDF_Priority__c', 'Core_MDF_Priority_2_nm__c', 'Core_MDF_Priority_3_nm__c'};
            
            for (String field : priorityFields) {
                String fieldValue = (String) campaignRecord.get(field);
                if (String.isNotBlank(fieldValue)) {
                    for (String val : fieldValue.split(';')) {
                        String trimmed = val.trim();
                        if (String.isNotBlank(trimmed)) {
                            values.add(trimmed);
                        }
                    }
                }
            }
            return values.isEmpty() ? null : values;
        }
        
        // For Budget Type, use the same field name (no mapping needed)
        if (pfrFieldName == 'Core_MDF_Opal_Budget_Type_Txt__c') {
            String fieldValue = (String) campaignRecord.get('Core_MDF_Opal_Budget_Type_Txt__c');
            
            if (String.isBlank(fieldValue)) return null;
            
            List<String> values = new List<String>();
            for (String val : fieldValue.split(';')) {
                String trimmed = val.trim();
                if (String.isNotBlank(trimmed)) {
                    values.add(trimmed);
                }
            }
            return values.isEmpty() ? null : values;
        }
        
        // Find corresponding campaign field for other fields
        String campaignFieldName = null;
        for (String campField : CAMPAIGN_TO_PFR_FIELDS.keySet()) {
            if (CAMPAIGN_TO_PFR_FIELDS.get(campField) == pfrFieldName) {
                campaignFieldName = campField;
                break;
            }
        }
        
        if (campaignFieldName == null) return null;
        
        String fieldValue = (String) campaignRecord.get(campaignFieldName);
        if (String.isBlank(fieldValue)) return null;
        
        // Split by semicolon and add to list
        List<String> values = new List<String>();
        for (String val : fieldValue.split(';')) {
            String trimmed = val.trim();
            if (String.isNotBlank(trimmed)) {
                values.add(trimmed);
            }
        }
        
        return values.isEmpty() ? null : values;
    }

    // Special handling for Priority field (3 separate campaign fields)
  /*  private static List<String> getCampaignPriorityValues(Campaign campaignRecord) {
        List<String> priorities = new List<String>();
        List<String> priorityFields = new List<String>{'Core_MDF_Priority__c', 'Core_MDF_Priority_2_nm__c', 'Core_MDF_Priority_3_nm__c'};
        
        for (String field : priorityFields) {
            String value = (String) campaignRecord.get(field);
            if (String.isNotBlank(value)) {
                for (String val : value.split(';')) {
                    String trimmed = val.trim();
                    if (String.isNotBlank(trimmed)) {
                        priorities.add(trimmed);
                    }
                }
            }
        }
        
        return priorities.isEmpty() ? null : priorities;
    }   */

    private static List<String> getCampaignCountryValues(Campaign campaignRecord) {
        List<String> countries = new List<String>();
        if (campaignRecord != null && String.isNotBlank(campaignRecord.Core_MDF_Market__c)) {
            for (String country : campaignRecord.Core_MDF_Market__c.split(';')) {
                String trimmedCountry = country.trim();
                if (String.isNotBlank(trimmedCountry)) {
                    countries.add(trimmedCountry);
                }
            }
        }
        return countries;
    }

    /**
     * Returns active ecosystem partners grouped by campaign country.
     */
    private static Map<String, List<String>> getEcosystemPartnerValuesByCountry(Campaign campaignRecord) {
        Map<String, List<String>> countryToPartners = new Map<String, List<String>>();
        Map<String, Set<String>> addedPartnersByCountry = new Map<String, Set<String>>();

        List<String> countries = getCampaignCountryValues(campaignRecord);
        for (String country : countries) {
            countryToPartners.put(country, new List<String>{'None'});
            addedPartnersByCountry.put(country, new Set<String>{'None'});
        }

        if (countries.isEmpty()) {
            return countryToPartners;
        }

        String programFilterToken = getProgramFilterToken(campaignRecord);
        for (Core_MDF_CP_Countries__c metaRecord : [
            SELECT Core_MDF_CP_Name__c, Core_MDF_CP_Country__c, Core_MDF_Program_Name__c,
                   Core_MDF_All_Countries__c, Core_MDF_Is_Applicable_All_Programs_Ind__c
            FROM Core_MDF_CP_Countries__c
            WHERE Core_MDF_Is_Active__c = true
            AND (Core_MDF_All_Countries__c = true OR Core_MDF_CP_Country__c IN :countries)
            ORDER BY Core_MDF_CP_Name__c
        ]) {
            if (!isEcosystemProgramMatch(metaRecord, programFilterToken)) {
                continue;
            }
            if (String.isBlank(metaRecord.Core_MDF_CP_Name__c)) {
                continue;
            }

            if (metaRecord.Core_MDF_All_Countries__c == true) {
                for (String country : countries) {
                    addEcosystemPartnerValue(countryToPartners, addedPartnersByCountry, country, metaRecord.Core_MDF_CP_Name__c);
                }
            } else {
                addEcosystemPartnerValue(countryToPartners, addedPartnersByCountry, metaRecord.Core_MDF_CP_Country__c, metaRecord.Core_MDF_CP_Name__c);
            }
        }

        for (String country : countries) {
            addEcosystemPartnerValue(countryToPartners, addedPartnersByCountry, country, 'Others');
        }

        return countryToPartners;
    }

    private static void addEcosystemPartnerValue(Map<String, List<String>> countryToPartners, Map<String, Set<String>> addedPartnersByCountry, String country, String partnerName) {
        if (String.isBlank(country) || String.isBlank(partnerName) || !countryToPartners.containsKey(country)) {
            return;
        }
        if (addedPartnersByCountry.get(country).add(partnerName)) {
            countryToPartners.get(country).add(partnerName);
        }
    }

    private static String getProgramFilterToken(Campaign campaignRecord) {
        if (campaignRecord == null || String.isBlank(campaignRecord.Core_MDF_Program__c)) {
            return null;
        }
        String normalized = campaignRecord.Core_MDF_Program__c.toLowerCase();
        String normalizedCompact = normalized.replace(' ', '');
        if (normalized.contains('client') || normalized.contains('ccf')) {
            return 'Client';
        }
        if (normalizedCompact.contains('datacenter') || normalized.contains('dcf')) {
            return 'Data%Center';
        }
        return null;
    }

    private static Boolean isEcosystemProgramMatch(Core_MDF_CP_Countries__c metaRecord, String programFilterToken) {
        if (metaRecord.Core_MDF_Is_Applicable_All_Programs_Ind__c == true) {
            return true;
        }
        if (String.isBlank(programFilterToken)) {
            return true;
        }
        if (String.isBlank(metaRecord.Core_MDF_Program_Name__c)) {
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
     * Builds controlling-to-dependent value mappings used by clients to render dependent picklists.
     * ALWAYS filters out inactive values from Core_MDF_PFRCustomPicklist__c to ensure only active
     * dependent values are returned. Never includes inactive values even if custom object lookup fails.
     */
    private static Map<String, List<String>> buildDependentValuesFor(String controllingField, String dependentField, List<String> allowedControllingValues, String programType) {
        Map<String, List<String>> controllingToDependent = new Map<String, List<String>>();
        
        try {
            // Get the set of active dependent field values from Core_MDF_PFRCustomPicklist__c
            // Filter by program type (CCF or DCF) for program-specific active values
            Set<String> activeDependentValues = getActivePicklistValuesFromCustomObject(dependentField, programType);
            
            Map<Object, List<Map<String, String>>> dependentValues = Core_MDF_PFR_RestAPI_Utility.getFieldDependenciesMaps(CUSTOM_PICKLIST_OBJECT_NAME, controllingField, dependentField);
            Set<String> allowedSet = allowedControllingValues != null ? new Set<String>(allowedControllingValues) : null;

            for (Object controllingValue : dependentValues.keySet()) {
                String controllingStr = String.valueOf(controllingValue);
                if (allowedSet != null && !allowedSet.contains(controllingStr)) continue;
                
                List<String> depValues = new List<String>();
                
                for (Map<String, String> entry : dependentValues.get(controllingValue)) {
                    String value = entry.get('value');
                    if (String.isNotBlank(value)) {
                        String trimmedValue = value.trim();
                        
                        // ALWAYS filter: only include if active in Core_MDF_PFRCustomPicklist__c for this program
                        // Do NOT include inactive values, even if custom object is unavailable
                        if (activeDependentValues.contains(trimmedValue)) {
                            depValues.add(trimmedValue);
                        }
                    }
                }
                
                if (!depValues.isEmpty()) {
                    controllingToDependent.put(controllingStr, depValues);
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
        return controllingToDependent;
    }

    // Overload for backward compatibility (no program type specified)
    private static Map<String, List<String>> buildDependentValuesFor(String controllingField, String dependentField, List<String> allowedControllingValues) {
        return buildDependentValuesFor(controllingField, dependentField, allowedControllingValues, null);
    }

    /**
     * Returns active picklist values for a field from Core_MDF_PFRCustomPicklist__c.
     * Used to filter dependent picklist values and ensure only active values are included.
     * This is the SOURCE OF TRUTH - if field not found, returns empty set (strict filtering).
     */
    private static Set<String> getActivePicklistValuesFromCustomObject(String fieldName) {
        return getActivePicklistValuesFromCustomObject(fieldName, null);
    }

    /**
     * Returns active picklist values for a field from Core_MDF_PFRCustomPicklist__c, filtered by program type.
     * For program-specific filtering of dependent picklist values (e.g., "Offer - Rewards" inactive for CCF).
     * This is the SOURCE OF TRUTH - if field not found, returns empty set (strict filtering).
     * 
     * @param fieldName API name of the field on Core_MDF_PFRCustomPicklist__c
     * @param programType Program type ('CCF', 'DCF', or null for no program filtering)
     * @return Set of active picklist values for the specified program type
     */
    private static Set<String> getActivePicklistValuesFromCustomObject(String fieldName, String programType) {
        Set<String> activeValues = new Set<String>();
        
        try {
            // Get the Core_MDF_PFRCustomPicklist__c object
            Schema.SObjectType customPicklistType = Schema.getGlobalDescribe().get(CUSTOM_PICKLIST_OBJECT_NAME);
            
            if (customPicklistType == null) {
                return activeValues;
            }
            
            Map<String, Schema.SObjectField> customFieldMap = customPicklistType.getDescribe().fields.getMap();
            
            // Normalize field name to lowercase for comparison
            String lowerFieldName = fieldName.toLowerCase();
            
            // Try exact match first
            Schema.SObjectField targetField = customFieldMap.get(fieldName);
            
            // If exact match not found, try case-insensitive search
            if (targetField == null) {
                for (String fieldKey : customFieldMap.keySet()) {
                    if (fieldKey.toLowerCase() == lowerFieldName) {
                        targetField = customFieldMap.get(fieldKey);
                        break;
                    }
                }
            }
            
            // If field still not found, log and return empty (strict: don't fall back)
            if (targetField == null) {
                return activeValues;
            }
            
            // Get picklist entries and filter for active ones
            Schema.DescribeFieldResult fieldDescribe = targetField.getDescribe();
            
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    activeValues.add(entry.getValue());
                }
            }
            
            // If program type specified, apply program-level filtering
            if (String.isNotBlank(programType)) {
                activeValues = filterPicklistValuesByProgram(fieldName, activeValues, programType);
            }
            
        } catch (Exception e) {
            // Log the error but return empty set (strict filtering - no inactive values slip through)
        }
        
        return activeValues;
    }
    private static Set<String> filterPicklistValuesByProgram(String fieldName, Set<String> allActiveValues, String programType) {
        Set<String> programActiveValues = allActiveValues;
        
        try {
            if (!Core_MDF_PFRCustomPicklist__c.SObjectType.getDescribe().isAccessible()) {
                return programActiveValues;
            }
            
            // Query Core_MDF_PFRCustomPicklist__c records for this program to get field value
            String programLabel = programType == 'CCF' ? 'Client Co-Marketing Fund' : 
                                  programType == 'DCF' ? 'Data Center Co-Marketing Fund' : null;
            
            if (String.isBlank(programLabel)) {
                return programActiveValues;
            }
            
            List<Core_MDF_PFRCustomPicklist__c> records = [
                SELECT Id
                FROM Core_MDF_PFRCustomPicklist__c
                WHERE Core_MDF_Program__c = :programLabel
                WITH USER_MODE
                LIMIT 1
            ];
            
            // If no record found for this program, return only schema-active values
            // (strict filtering - better to exclude values than include them incorrectly)
            if (records.isEmpty()) {
                return programActiveValues;
            }
            
        } catch (Exception e) {
            // Return schema-active values on error (safe fallback)
        }
        
        return programActiveValues;
    }

    /**
     * Indicates whether the campaign categories include any pre-2025 variants.
     */
    private static Boolean campaignHasPre2025Category(Campaign campaignRecord) {
        if (campaignRecord == null || String.isBlank(campaignRecord.Core_MDF_Activity_Category__c)) return true;
        for (String cat : campaignRecord.Core_MDF_Activity_Category__c.split(';')) {
            if (cat.trim().contains('(Pre-2025)')) return true;
        }
        return false;
    }

    private static void sendResponse(Integer statusCode, PicklistValuesResponse response) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(serializeResponse(response));
    }

    private static String serializeResponse(PicklistValuesResponse response) {
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        writeNullableObjectField(generator, 'Message', response.message);
        writeNullableObjectField(generator, 'Code', response.code);
        if (response != null && response.code == ERR_CAMPAIGN_ACCESS_DENIED) {
            generator.writeEndObject();
            return generator.getAsString();
        }
        writeNullableObjectField(generator, 'Campaign Number', response.CampaignNo);
        writeNullableObjectField(generator, 'Campaign Name', response.campaignName);
        writeNullableObjectField(generator, 'CampaignId', response.campaignId);
        writeNullableObjectField(generator, 'IsSuccess', response.isSuccess);
        writeNullableObjectField(generator, 'Fields', response.fields);
        writeNullableObjectField(generator, 'Budgets', response.Budgets);
        writeNullableObjectField(generator, 'Reimbursement Rate', response.ReimbursementRate);
        writeNullableObjectField(generator, 'SegmentProduct', response.SegmentProduct);
        writeNullableObjectField(generator, 'AccountDetails', response.AccountDetails);
        writeNullableObjectField(generator, 'MemberAcceptor UserDetails', response.MemberAcceptorUserDetailsStructured);
        writeNullableObjectField(generator, 'IntelApprover UserDetails', response.IntelApproverUserDetails);
        generator.writeEndObject();
        return generator.getAsString();
    }

    private static void writeNullableObjectField(JSONGenerator generator, String fieldName, Object fieldValue) {
        if (fieldValue == null) {
            generator.writeNullField(fieldName);
        } else {
            generator.writeObjectField(fieldName, fieldValue);
        }
    }

    // Response classes
    global class PicklistValuesResponse {
        public String message = '';
        public String code = '500';
        public String CampaignNo;
        public String campaignName;
        public String campaignId;
        public Boolean isSuccess = false;
        public List<PicklistFieldValues> fields = new List<PicklistFieldValues>();
        public List<Map<String, Object>> Budgets = new List<Map<String, Object>>();
        public List<Map<String, String>> ReimbursementRate { get; set; }
        public List<Map<String, Object>> SegmentProduct { get; set; }
        public List<Map<String, Object>> AccountDetails { get; set; }
        public List<MemberAcceptorUserDetail> MemberAcceptorUserDetails { get; set; }
        public List<Map<String, Object>> MemberAcceptorUserDetailsStructured { get; set; }
        public List<UserDetail> IntelApproverUserDetails { get; set; }

        public PicklistValuesResponse() {
            fields = new List<PicklistFieldValues>();
            Budgets = new List<Map<String, Object>>();
            ReimbursementRate = new List<Map<String, String>>();
            SegmentProduct = new List<Map<String, Object>>();
            AccountDetails = new List<Map<String, Object>>();
            MemberAcceptorUserDetails = new List<MemberAcceptorUserDetail>();
            MemberAcceptorUserDetailsStructured = new List<Map<String, Object>>();
            IntelApproverUserDetails = new List<UserDetail>();
        }
    }

    global class PicklistFieldValues {
        public String fieldLabel;
        public List<String> values;
        public String dependentOn;
        public Map<String, List<String>> dependentValues;
    }

    /**
     * Member Acceptor User Detail wrapper - no Region field
     */
    global class MemberAcceptorUserDetail {
        public Id userId { get; set; }
        public String name { get; set; }
        public String accName { get; set; }
        public MemberAcceptorUserDetail(Id userId, String name,String accname) {
            this.userId = userId;
            this.name = name;
            this.accName = accName;
        }
    }

    /**
     * Intel Approver User Detail wrapper - includes Region
     */
    global class UserDetail {
        public Id userId { get; set; }
        public String name { get; set; }
        public String Region { get; set; }

        public UserDetail(Id userId, String name, String Region) {
            this.userId = userId;
            this.name = name;
            this.Region = Region;
        }
    }

    // ===== MULTI-SEGMENT PRODUCT VALIDATION - APPEND =====
    /**
     * Get products for specific segment (uses Core_MDF_AccountProductMappingController)
     * SOURCE: Core_MDF_Activity_Segment_Mapping - getProductsForSegment
     * @param segment - Segment name
     * @return List of Product2 records mapped to segment
     */
    public static List<Product2> getProductsForSegment(String segment) {
        List<Product2> productList = new List<Product2>();
        try {
            // Calls existing AccountProductMappingController method
            productList = Core_MDF_AccountProductMappingController.retrieveProductsUsingDynamicQuery(segment);
            //Core_MDF_RestAPI_Logger.info('Retrieved ' + productList.size() + ' products for segment: ' + segment);
        } catch (Exception e) {
            //Core_MDF_RestAPI_Logger.error('Error fetching products for segment: ' + e.getMessage());
        }
        return productList;
    }
    
    /**
     * Validate if product is mapped to segment
     * Reuses Core_MDF_ActivitySegmentMapping segment validation
     * @param segment - Segment name
     * @param productId - Product ID to validate
     * @return true if product is valid for segment
     */
    public static Boolean isProductValidForSegment(String segment, String productId) {
        if (String.isBlank(segment) || String.isBlank(productId)) {
            return false;
        }
        try {
            List<Product2> validProducts = getProductsForSegment(segment);
            for (Product2 prod : validProducts) {
                if (prod.Id == Id.valueOf(productId)) {
                    return true;
                }
            }
        } catch (Exception e) {
            //Core_MDF_RestAPI_Logger.error('Error validating product for segment: ' + e.getMessage());
        }
        return false;
    }
    
    /**
     * Validate multiple products for segment
     * Batch validation reusing getProductsForSegment
     * @param segment - Segment name
     * @param productIds - List of product IDs
     * @return true if all products valid for segment
     */
    public static Boolean areProductsValidForSegment(String segment, List<String> productIds) {
        if (String.isBlank(segment) || productIds == null || productIds.isEmpty()) {
            return false;
        }
        try {
            List<Product2> validProducts = getProductsForSegment(segment);
            Set<Id> validProductIdSet = new Set<Id>();
            
            for (Product2 prod : validProducts) {
                validProductIdSet.add(prod.Id);
            }
            
            for (String productId : productIds) {
                try {
                    if (!validProductIdSet.contains(Id.valueOf(productId))) {
                        return false;
                    }
                } catch (Exception e) {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
           // Core_MDF_RestAPI_Logger.error('Error validating products for segment: ' + e.getMessage());
        }
        return false;
    }
}