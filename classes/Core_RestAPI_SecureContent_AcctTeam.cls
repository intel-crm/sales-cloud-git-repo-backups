/******************************************************************************************************************************************
Class Name  : Core_RestAPI_SecureContent_AcctTeam 
Version     : 1.0 
Created Date: 19 June 2018
Function    : Apex class to get the list of Account Owner and Account Team Members for a given Account Id. Only users that have a profile defined in Core_AccountCoverage_Profiles__c are included.
/services/apexrest/SecureContent/AccountTeam?accountId=0012D000002S3HH

Modification Log
* Developer             Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venu Karumuru         06/19/2018              Initial Version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/SecureContent/AccountTeam')
global class Core_RestAPI_SecureContent_AcctTeam {  

    // Class to store the list of all Account Team Members
    global class AccountMemberWrapperList {
        public String Error = null;
        global List<AccountMemberWrapper> BUS_ACCOUNT_MEMBERS;
    }

    // Class to store details of an Account Team Member
    global class AccountMemberWrapper {
        public String WWID = '';
        public String IDSID = '';
        public String EMAIL_ADDR_TXT = '';
        public String LST_NM = '';
        public String FRST_NM = '';
    }

    @HttpGet
    // Main Method to retrieve Account Team Members for a given Account Id
    global static AccountMemberWrapperList GetAccountTeam() { 

        String sMessage = null;
        Boolean bError = false; 
        Integer nTotalCount = 0; 
        Exception objException = null;

        AccountMemberWrapperList accountMemberWrapperList = new AccountMemberWrapperList();
        accountMemberWrapperList.BUS_ACCOUNT_MEMBERS = new List<AccountMemberWrapper>();

        // Get the list of Account Ids from the input parameter
        String sAccountId = RestContext.request.params.get('accountId');
        System.Debug('Info: Passed in Account Id: ' + sAccountId);

        // Check if there is Account Id
        if (sAccountId == null || sAccountId == '') {

            sMessage = 'Fail: Passed in Account Id is empty';
            System.Debug(sMessage);

            // Return error
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            accountMemberWrapperList.Error = sMessage;
            return accountMemberWrapperList;
        }

        // Get the list of valid profiles
        Set<String> setProfileName = new Set<String>();
        for (Core_AccountCoverage_Profiles__c record: [SELECT Id, Core_Profiles__c FROM Core_AccountCoverage_Profiles__c]) {
            setProfileName.Add(record.Core_Profiles__c);
        }

        System.Debug('Info: List of Valid Profiles: ' + setProfileName);

        // Store the list of User Ids
        Set<Id> setUserId = new Set<Id>();

        // Add the Account Owner to the set
        for (Account record: [SELECT OwnerId FROM Account WHERE Id = :sAccountId]) {
            setUserId.Add(record.OwnerId);
        }

        // Add the team members to the set
        for (AccountTeamMember record: [SELECT UserId FROM AccountTeamMember WHERE AccountId = :sAccountId]) {
            setUserId.Add(record.UserId);
        }

        System.Debug('Info: List of User Ids: ' + setUserId);

        // Get the details of all users that are team members or owner
        try { 

            for (User record: [SELECT Id, Core_WWID__c, Core_Login_Id__c, Email, LastName, FirstName, Profile.Name, IsActive
                                    FROM User WHERE Id IN :setUserId AND IsActive = true AND Profile.Name IN :setProfileName]) {   

                // Increment the total count of Contacts for tracking in log Entry
                nTotalCount += 1;

                AccountMemberWrapper accountMemberWrapper = new AccountMemberWrapper();
                accountMemberWrapper.WWID = record.Core_WWID__c;
                accountMemberWrapper.IDSID = record.Core_Login_Id__c;
                accountMemberWrapper.EMAIL_ADDR_TXT = record.Email;
                accountMemberWrapper.LST_NM = record.LastName;
                accountMemberWrapper.FRST_NM = record.FirstName;

                accountMemberWrapperList.BUS_ACCOUNT_MEMBERS.add(accountMemberWrapper);
            }  

            System.Debug('Info: Total Team Members Returned: ' + String.valueOf(nTotalCount));

            // Throw a fake exception if called from test class with the parameter createException. This is to improve code coverage for exception block.
            if (Test.isRunningTest() && RestContext.request.params.get('createException') == '1')
                Integer a = 100/0; 
        }

        catch (Exception ex) {
            objException = ex; 
            bError = true;

            sMessage = 'Fail: ' + ex;
            System.Debug(sMessage);

            RestResponse res = RestContext.response;
            res.statusCode = 500;
            accountMemberWrapperList.Error = sMessage;
            return accountMemberWrapperList;
        }

        finally {
            // Create log entry
            Core_Log_Entry__c objLogEntry = new Core_Log_Entry__c();

            objLogEntry.Core_When__c = system.now();
            objLogEntry.Core_Project__c = 'Entitlement';
            objLogEntry.Core_Origin__c = 'Secure Content Rest API';
            objLogEntry.Core_Scope__c = '/SecureContent/AccountTeam';
            objLogEntry.Core_Severity__c = ( bError == true ?  'Error' : 'Info' );
            objLogEntry.Core_Message__c = 'Input Account Id: ' + sAccountId + '. ' + 'Total Contacts Returned: ' + String.valueOf(nTotalCount);
            if (objException != null)
                objLogEntry.Core_Details__c = objException.getMessage();

            insert objLogEntry;
            System.debug('Info: Log ID: '+ objLogEntry.Id);
        } 

        return accountMemberWrapperList;  
    }
}