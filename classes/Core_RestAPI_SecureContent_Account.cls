/******************************************************************************************************************************************
Class Name  : Core_RestAPI_SecureContent_Account
Version     : 1.0 
Created Date: 29 May 2018
Function    : Apex class to get the list of Accounts for a given user WWID. The Accounts where the User is owner OR is Account Team member are in the output.
Nothing is returned if the user's profile is not listed in Core_AccountCoverage_Profiles__c
/services/apexrest/SecureContent/Accounts?wwid=10560180

Modification Log
* Developer             Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venu Karumuru         05/29/2018              Initial Version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/SecureContent/Accounts')
global class Core_RestAPI_SecureContent_Account {  

    // Class to store the list of all Accounts
    global class AccountWrapperList {
        public String Error = null;
        global List<AccountWrapper> BUS_ACCOUNTS;
    }

    // Class to store details of an Account
    global class AccountWrapper {
        public String ACCT_ID = '';
        public String PROF_ORG_TY_CD = '';
        public String GEO_NM = '';
        public String CNDA_NBR = '';
        public String ACCT_NM = '';
        public String ACCT_ENG_NM = '';
    }

    @HttpGet
    // Main Method to retrieve Accounts for a given user
    global static AccountWrapperList GetAccounts() { 

        // Create object to store the list of accounts
        AccountWrapperList accountWrapperList = new AccountWrapperList();
        accountWrapperList.BUS_ACCOUNTS = new List<AccountWrapper>();

        String sMessage = null;
        Boolean bError = false; 
        Integer nTotalCount = 0; 
        Exception objException = null;

        // Get the WWID from the input parameter
        String sWWID = RestContext.request.params.get('wwid');
        System.Debug('Info: Passed in WWID: ' + sWWID);

        // Check if there is a wwid
        if (sWWID == null || sWWID == '') {

            sMessage = 'Fail: Passed in WWID is empty';
            System.Debug(sMessage);

            // Return error
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            accountWrapperList.Error = sMessage;
            return accountWrapperList;
        }


        // Get the list of valid profiles
        Set<String> setProfileName = new Set<String>();
        for (Core_AccountCoverage_Profiles__c record: [SELECT Id, Core_Profiles__c FROM Core_AccountCoverage_Profiles__c]) {
            setProfileName.Add(record.Core_Profiles__c);
        }

        System.Debug('Info: List of Valid Profiles: ' + setProfileName);

        // Get the user id
        Id idUser = null;
        for (User record: [SELECT Id FROM User WHERE Core_WWID__c = :sWWID AND IsActive = true AND Profile.Name IN :setProfileName LIMIT 1]) {
            idUser = record.Id;
        }

        System.Debug('Info: User Id: ' + idUser);

        // Check if the user is found
        if (idUser == null) {
            sMessage = 'Fail: User not found OR is Inactive OR does not have a valid profile defined in Core_AccountCoverage_Profiles__c';
            System.Debug(sMessage);

            // Return error
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            accountWrapperList.Error = sMessage;
            return accountWrapperList;
        }

        // Store the list of Account Ids
        Set<Id> setAccountId = new Set<Id>();

        // Get the list of Accounts where the user is Owner
        for (Account record: [SELECT Id FROM Account WHERE OwnerId = :idUser]) {
            setAccountId.Add(record.Id);
        }

        // Get the list of Accounts where the user has Access
        for (Account record: [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = :idUser)]) {
            setAccountId.Add(record.Id);
        }

        System.Debug('Info: List of Account Ids: ' + setAccountId);

        // Get the details of all Accounts for which user is Owner or has Read or Write Access
        try { 

            for (Account record: [SELECT Id, Core_Geo__c, Core_CNDA_Number__c, Name, Core_English_Only_Name__c FROM Account
                                    WHERE Id IN :setAccountId
                                    ORDER BY Name]) {   

                // Increment the total count of Accounts for tracking in log Entry
                nTotalCount += 1;

                AccountWrapper accountWrapper = new AccountWrapper();
                accountWrapper.ACCT_ID = record.Id;
                accountWrapper.PROF_ORG_TY_CD = 'EXTRNORG';
                accountWrapper.GEO_NM = record.Core_Geo__c;
                accountWrapper.CNDA_NBR = record.Core_CNDA_Number__c;
                accountWrapper.ACCT_NM = record.Name;
                accountWrapper.ACCT_ENG_NM = record.Core_English_Only_Name__c; 

                accountWrapperList.BUS_ACCOUNTS.add(accountWrapper);
            } 

            System.Debug('Info: Total Accounts Returned: ' + String.valueOf(nTotalCount));

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
            accountWrapperList.Error = sMessage;
            return accountWrapperList;
        }

        finally {
            // Create log entry
            Core_Log_Entry__c objLogEntry = new Core_Log_Entry__c();

            objLogEntry.Core_When__c = system.now();
            objLogEntry.Core_Project__c = 'Entitlement';
            objLogEntry.Core_Origin__c = 'Secure Content Rest API';
            objLogEntry.Core_Scope__c = '/SecureContent/Accounts';
            objLogEntry.Core_Severity__c = ( bError == true ?  'Error' : 'Info' );
            objLogEntry.Core_Message__c = 'Input WWID: ' + sWWID + '. ' + 'Total Accounts Returned: ' + String.valueOf(nTotalCount);
            if (objException != null)
                objLogEntry.Core_Details__c = objException.getMessage();

            insert objLogEntry;
            System.debug('Info: Log ID: '+ objLogEntry.Id);
        } 

        return accountWrapperList;  
    }
}