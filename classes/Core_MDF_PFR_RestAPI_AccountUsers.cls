/**
 * @description REST endpoint that returns allowed Member Acceptor and Intel Approver usernames for an account name.
 */
@RestResource(urlMapping='/v1.0/partnercenter/account-users/*')
global without sharing class Core_MDF_PFR_RestAPI_AccountUsers {
    private static final String CLIENT_COMARKETING_PROGRAM = 'Client CoMarketing Fund';
    private static final String PARTNER_COMMUNITY_USER_TYPE = 'PowerPartner';
    private static final String EXTERNAL_SUBMITTER_PERMISSION_SET = 'Core_MDF_CCP_External_Activity_Submitter';
    private static List<String> warnings = new List<String>();
    private static final Set<String> INTEL_APPROVER_ROLES = new Set<String>{
        'Core_MDF_CCP_Internal_CCF_Acct_Mgr',
        'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr'
    };

    @HttpGet
    global static void doGet() {
        AccountUsersResponse response = new AccountUsersResponse();
        warnings = new List<String>();

        try {
            String accountName = getAccountNameFromRequest();
            if (String.isBlank(accountName)) {
                response.isSuccess = false;
                response.code = '400';
                response.message = 'Account name is required in the URL path or accountName query parameter.';
                sendResponse(400, response);
                return;
            }

            List<Account> matchingAccounts = queryAccountsByName(accountName);
            if (matchingAccounts.isEmpty()) {
                response.isSuccess = false;
                response.code = '404';
                response.message = 'Account not found for accountName "' + accountName + '".';
                sendResponse(404, response);
                return;
            }
            if (matchingAccounts.size() > 1) {
                response.isSuccess = false;
                response.code = '400';
                response.message = 'Multiple accounts found for accountName "' + accountName + '".';
                sendResponse(400, response);
                return;
            }

            Account requestedAccount = matchingAccounts[0];
            Account ultimateAccount = resolveUltimateAccount(requestedAccount);

            response.accountDetails = new AccountDetail(requestedAccount, ultimateAccount);
            response.MemberAcceptorUserDetails = getMemberAcceptorUsers(requestedAccount.Id);
            response.IntelApproverUserDetails = getIntelApproverUsers(ultimateAccount.Id);
            response.warnings = warnings;
            response.isSuccess = true;
            response.code = '200';
            response.message = 'Account user details retrieved successfully.';
            sendResponse(200, response);
        } catch (Exception e) {
            response.isSuccess = false;
            response.code = '500';
            response.message = 'An unexpected error occurred: ' + e.getMessage();
            sendResponse(500, response);
        }
    }

    @TestVisible
    private static String getAccountNameFromRequest() {
        if (RestContext.request == null) {
            return null;
        }

        String accountName = RestContext.request.params.get('accountName');
        if (String.isNotBlank(accountName)) {
            return accountName.trim();
        }

        String requestUri = RestContext.request.requestURI;
        if (String.isBlank(requestUri)) {
            return null;
        }

        String marker = '/account-users/';
        Integer markerIndex = requestUri.toLowerCase().indexOf(marker);
        if (markerIndex < 0) {
            return null;
        }

        String rawAccountName = requestUri.substring(markerIndex + marker.length());
        Integer queryIndex = rawAccountName.indexOf('?');
        if (queryIndex >= 0) {
            rawAccountName = rawAccountName.substring(0, queryIndex);
        }
        return String.isBlank(rawAccountName) ? null : EncodingUtil.urlDecode(rawAccountName, 'UTF-8').trim();
    }

    private static List<Account> queryAccountsByName(String accountName) {
        return [
            SELECT Id, Name, ParentId, Parent.Name, Core_MDF_CoMarketing_Ultimate_Account__c,
                   Core_MDF_CoMarketing_Ultimate_Account__r.Name
            FROM Account
            WHERE Name = :accountName
            LIMIT 2
        ];
    }

    private static Account resolveUltimateAccount(Account requestedAccount) {
        if (requestedAccount.Core_MDF_CoMarketing_Ultimate_Account__c != null) {
            return new Account(
                Id = requestedAccount.Core_MDF_CoMarketing_Ultimate_Account__c,
                Name = requestedAccount.Core_MDF_CoMarketing_Ultimate_Account__r.Name
            );
        }

        Id currentAccountId = requestedAccount.Id;
        Account currentAccount = requestedAccount;
        Integer depth = 0;
        while (currentAccount.ParentId != null && depth < 10) {
            currentAccount = [SELECT Id, Name, ParentId FROM Account WHERE Id = :currentAccount.ParentId LIMIT 1];
            currentAccountId = currentAccount.Id;
            depth++;
        }
        return currentAccountId == requestedAccount.Id ? requestedAccount : currentAccount;
    }
    //Member Acceptor Details
    private static List<MemberAcceptorUserDetail> getMemberAcceptorUsers(Id accountId) {
        List<MemberAcceptorUserDetail> userDetails = new List<MemberAcceptorUserDetail>();
        if (accountId == null) {
            return userDetails;
        }

        String submitterPermissionSetName = Core_MDF_CustomLabelConfig.getTextValues(EXTERNAL_SUBMITTER_PERMISSION_SET);
        if (String.isBlank(submitterPermissionSetName)) {
            submitterPermissionSetName = EXTERNAL_SUBMITTER_PERMISSION_SET;
        }
        list<ID> lstActiveUsers = new List<ID>();
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> accountUsersById = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([
            SELECT Id, Core_MDF_User__r.name,Core_MDF_User__c
            FROM Core_MDF_Partner_Node_User_Mapping__c
              WHERE Core_MDF_User__r.IsActive = true 
              AND Core_MDF_Active_Ind__c =true
              AND Core_MDF_Account__c =: accountId
              AND Core_MDF_User__r.UserType=:PARTNER_COMMUNITY_USER_TYPE
        ]);
        if (accountUsersById.isEmpty()) {
            return userDetails;
        }
        for(Core_MDF_Partner_Node_User_Mapping__c objUsers: accountUsersById.values()) {
           lstActiveUsers.add(objUsers.Core_MDF_User__c);
        }
        System.debug('-0-0-0-0-0-0-0-'+accountUsersById);
        System.debug('-0-0-0-0-0-0-0-'+submitterPermissionSetName);
        Set<Id> permittedUserIds = new Set<Id>();
        try {
            list<User> lstPNmUSer=[SELECT  Id,Name,Username,(SELECT Id,AssigneeId from PermissionSetAssignments where PermissionSet.Name = :submitterPermissionSetName)FROM User WHERE Id IN :accountUsersById.keySet()];
            System.debug('============'+lstPNmUSer);
            for (User userDetail : [SELECT  Id,Name,Username,
                (
                    SELECT 
                        Id,
                        PermissionSetId,
                        PermissionSet.Name,
                        AssigneeId
                    FROM PermissionSetAssignments 
                    WHERE PermissionSet.Name = 'Core_MDF_CCP_External_Activity_Submitter'
                )
            FROM User 
            WHERE Id IN :lstActiveUsers])
            {
            
            for(PermissionSetAssignment psa : userDetail.PermissionSetAssignments) {
                permittedUserIds.add(psa.AssigneeId);
                System.debug('============'+permittedUserIds);
            }
        }
        } catch (QueryException e) {
            warnings.add('MemberAcceptorUsername could not be filtered because PermissionSetAssignment is not queryable in this runtime context: ' + e.getMessage());
            return userDetails;
        }
        System.debug('--=-=-=-=-=-=-=-'+accountUsersById.values());
        for (Core_MDF_Partner_Node_User_Mapping__c userRecord : accountUsersById.values()) {
            if (permittedUserIds.contains(userRecord.Core_MDF_User__c)) {
                userDetails.add(new MemberAcceptorUserDetail(userRecord.Core_MDF_User__c, userRecord.Core_MDF_User__r.name));
            }
        }System.debug('member--=-=-=-=-=-=-=-'+userDetails);
        return userDetails;
    }
    //Intel Approver Details
    private static List<UserDetail> getIntelApproverUsers(Id ultimateAccountId) {
        List<UserDetail> userDetails = new List<UserDetail>();
        if (ultimateAccountId == null) {
            return userDetails;
        }

        Set<Id> addedUserIds = new Set<Id>();
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c mapping : [
            SELECT Id, Name, Core_MDF_Role_nm__c, Core_MDF_User_id__c, Core_MDF_User_id__r.Name,Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_User_id__r.Username
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_Account_id__c = :ultimateAccountId
              AND Core_MDF_Active_Ind__c = true
              AND Core_MDF_is_User_Active_ind__c = true
              AND Core_MDF_Program_nm__c = :CLIENT_COMARKETING_PROGRAM
              AND Core_MDF_Role_nm__c IN :INTEL_APPROVER_ROLES
              AND Core_MDF_User_id__c != null
            ORDER BY Core_MDF_User_id__r.Username
        ]) {
            if (addedUserIds.add(mapping.Core_MDF_User_id__c)) {
                userDetails.add(new UserDetail(
                    mapping.Core_MDF_User_id__c,
                    mapping.Core_MDF_User_id__r.Name,
                    mapping.Core_MDF_Region_Sub_Region_nm__c
                ));
            }
        }
        return userDetails;
    }

    private static List<String> extractUsernames(List<UserDetail> userDetails) {
        List<String> usernames = new List<String>();
        for (UserDetail detail : userDetails) {
            if (String.isNotBlank(detail.name)) {
                usernames.add(detail.name);
            }
        }
        return usernames;
    }

    private static void sendResponse(Integer statusCode, AccountUsersResponse response) {
        if (RestContext.response != null) {
            RestContext.response.statusCode = statusCode;
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
        }
    }

    global class AccountUsersResponse {
        public Boolean isSuccess { get; set; }
        public String code { get; set; }
        public String message { get; set; }
        public AccountDetail accountDetails { get; set; }
        public List<MemberAcceptorUserDetail> MemberAcceptorUserDetails { get; set; }
        public List<UserDetail> IntelApproverUserDetails { get; set; }
        public List<String> warnings { get; set; }

        public AccountUsersResponse() {
            isSuccess = false;
            MemberAcceptorUserDetails = new List<MemberAcceptorUserDetail>();
            IntelApproverUserDetails = new List<UserDetail>();
            warnings = new List<String>();
        }
    }

    global class AccountDetail {
        public Id accountId { get; set; }
        public String accountName { get; set; }
        public Id ultimateAccountId { get; set; }
        public String ultimateAccountName { get; set; }

        public AccountDetail(Account accountRecord, Account ultimateAccount) {
            accountId = accountRecord.Id;
            accountName = accountRecord.Name;
            ultimateAccountId = ultimateAccount.Id;
            ultimateAccountName = ultimateAccount.Name;
        }
    }

    global class MemberAcceptorUserDetail {
        public Id userId { get; set; }
        public String name { get; set; }

        public MemberAcceptorUserDetail(Id userId, String name) {
            this.userId = userId;
            this.name = name;
        }
    }

    global class UserDetail {
        public Id userId { get; set; }
        public String name { get; set; }
        public String Region{ get; set; }
        
        public UserDetail(Id userId, String name) {
            this.userId = userId;
            this.name = name;
        }
        public UserDetail(Id userId, String name,string Region) {
            this.userId = userId;
            this.name = name;
            this.Region= Region;
        }
    }
}