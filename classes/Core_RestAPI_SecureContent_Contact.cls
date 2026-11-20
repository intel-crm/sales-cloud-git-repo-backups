/******************************************************************************************************************************************
Class Name  : Core_RestAPI_SecureContent_Contact 
Version     : 1.0 
Created Date: 30 May 2018
Function    : Apex class to get the list of B2B Contacts for a given list of Account Ids
/services/apexrest/SecureContent/Contacts?accountIds=0012D000002S3G9,0012D000002S3G4

        Modification Log
* Developer             Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venu Karumuru         05/30/2018              Initial Version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/SecureContent/Contacts')
global without sharing class Core_RestAPI_SecureContent_Contact {  

    // Class to store the list of all Contacts
    global class ContactWrapperList {
        public String Error = null;
        global List<ContactWrapper> BUS_CONTACTS;
    }

    // Class to store details of a Contact
    global class ContactWrapper {
        public String PRI_OCCP_TTL_CD = '';
        public String LST_NM = '';
        public String FRST_NM = '';
        public String EXTRN_LGN_ID = '';
        public String ENG_LST_NM = '';
        public String ENG_FRST_NM = '';
        public String CST_ID = '';
        public String EMAIL_ADDR_TXT = '';
        public String ACCT_ID = '';
    }

    @HttpGet
    // Main Method to retrieve Contacts for a given list of Account Ids
    global static ContactWrapperList GetContacts() { 

        String sMessage = null;
        Boolean bError = false; 
        Integer nTotalCount = 0; 
        Exception objException = null;

        ContactWrapperList contactWrapperList = new ContactWrapperList();
        contactWrapperList.BUS_CONTACTS = new List<ContactWrapper>();

        // Get the list of Account Ids from the input parameter
        String sAccountIds = RestContext.request.params.get('accountIds');
        System.Debug('Info: Passed in Account Ids: ' + sAccountIds);

        // Check if there are Account Ids
        if (sAccountIds == null || sAccountIds == '') {

            sMessage = 'Fail: Passed in Account Id list is empty';
            System.Debug(sMessage);

            // Return error
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            contactWrapperList.Error = sMessage;
            return contactWrapperList;
        }

        // Get the list of Accounts
        List<String> lstAccountIds = sAccountIds.split(',');
        // Trim the spaces
        for (Integer i = 0; i < lstAccountIds.size(); i++)
            lstAccountIds[i] = lstAccountIds[i].trim();

        System.Debug('Info: List of Account Ids: ' + lstAccountIds);

        // Get the details of all the Contacts for the given Account Ids
        try { 

            for (Contact record: [SELECT Id, Core_Job_Function__c, LastName, FirstName, Core_English_Only_Last_Name__c, Core_English_Only_First_Name__c, Core_Enterprise_Id__c, Email, AccountId
                                    FROM Contact WHERE Core_Contact_B2B_Indicator__c = true AND AccountId IN :lstAccountIds]) {   

                // Increment the total count of Contacts for tracking in log Entry
                nTotalCount += 1;

                ContactWrapper contactWrapper = new ContactWrapper();
                contactWrapper.PRI_OCCP_TTL_CD = record.Core_Job_Function__c;
                contactWrapper.LST_NM = record.LastName;
                contactWrapper.FRST_NM = record.FirstName;
                contactWrapper.EXTRN_LGN_ID = '';
                contactWrapper.ENG_LST_NM = record.Core_English_Only_Last_Name__c;
                contactWrapper.ENG_FRST_NM = record.Core_English_Only_First_Name__c; 
                contactWrapper.CST_ID = record.Core_Enterprise_Id__c;
                contactWrapper.EMAIL_ADDR_TXT = record.Email;
                contactWrapper.ACCT_ID = record.AccountId; 

                contactWrapperList.BUS_CONTACTS.add(contactWrapper);
            }  

            System.Debug('Info: Total Contacts Returned: ' + String.valueOf(nTotalCount));

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
            contactWrapperList.Error = sMessage;
            return contactWrapperList;
        }

        finally {
            // Create log entry
            Core_Log_Entry__c objLogEntry = new Core_Log_Entry__c();

            objLogEntry.Core_When__c = system.now();
            objLogEntry.Core_Project__c = 'Entitlement';
            objLogEntry.Core_Origin__c = 'Secure Content Rest API';
            objLogEntry.Core_Scope__c = '/SecureContent/Contacts';
            objLogEntry.Core_Severity__c = ( bError == true ?  'Error' : 'Info' );
            objLogEntry.Core_Message__c = 'Input Account Ids: ' + sAccountIds.abbreviate(200) + '. ' + 'Total Contacts Returned: ' + String.valueOf(nTotalCount);
            if (objException != null)
                objLogEntry.Core_Details__c = objException.getMessage();

            insert objLogEntry;
            System.debug('Info: Log ID: '+ objLogEntry.Id);
        } 

        return contactWrapperList;  
    }
}