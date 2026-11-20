/******************************************************************************************************************************************
Class Name  : Core_RestAPI_SecureContent_AcctTeam_Test 
Version     : 1.0 
Created Date: 19 June 2018
Function    : Apex class to get the list of Account Owner and Account Team Members for a given Account Id. Only users that have a profile defined in Core_AccountCoverage_Profiles__c are included.
/services/apexrest/SecureContent/AccountTeam?accountId=0012D000002S3HH

Modification Log
* Developer             Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venu Karumuru         06/19/2018              Initial Version
*****************************************************************************************************************************************/

@isTest
public class Core_RestAPI_SecureContent_AcctTeam_Test {

    public static final String sWWID = '10000001';
    public static Id accountId = null;

    // Method to test normal flow
    private static testmethod void Test1_Normal_Flow() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/AccountTeam';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';        
        req.params.put('accountId', accountId);

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_AcctTeam.GetAccountTeam(); 
        Test.stopTest();
    }


    // Method to test exception - Force the exception
    private static testmethod void Test2_Exception_Flow() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/AccountTeam';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';        
        req.params.put('accountId', accountId);
        req.params.put('createException', '1');

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_AcctTeam.GetAccountTeam(); 
        Test.stopTest();
    }


    // Method to test exception - No Parameter is passed to the service method
    private static testmethod void Test3_No_Parameter() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/AccountTeam';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';        

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_AcctTeam.GetAccountTeam(); 
        Test.stopTest();
    }


    // Method to create test data
    private static void createTestData() {

        // Profile used in the test
        String sProfileName = 'Standard User';

        // Create an entry in Covered Profile list
        Core_AccountCoverage_Profiles__c recordCoveredProfile = new Core_AccountCoverage_Profiles__c();
        recordCoveredProfile.Name = sProfileName;
        recordCoveredProfile.Core_Profiles__c = sProfileName;
        insert recordCoveredProfile;

        // Get the Profile Id
        Id profileId = null;
        // Get the Id of the Standard Profile             
		List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
		if (lstProfiles.size() != 0)
			profileId = lstProfiles[0].Id;

        // Create User
        User testUser = new User();
        testUser.LastName = 'User1';
        testUser.Alias = 'tuser1';
        testUser.Email = 'test.user1@intel.com';
        testUser.Username = 'test.user1@intel.com.crm.testclass';
        testUser.ProfileId = profileId;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Core_WWID__c = sWWID;
		insert testUser;

        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account1';
        testAccount.Core_CNDA_Number__c = '112233445566';
        testAccount.BillingStreet = '1234 Test Street';
        testAccount.BillingCity = 'Test City';
        testAccount.BillingStateCode = 'OR';
        testAccount.BillingCountryCode = 'USA';
        testAccount.BillingPostalCode = '12345';
        testAccount.Phone = '1234567890';
        testAccount.OwnerId = testUser.Id;        
        insert testAccount;

        accountId = testAccount.id;

        // Create Account Team Member
        AccountTeamMember teamMember = new AccountTeamMember();
		teamMember.AccountId = testAccount.id;
		teamMember.UserId = testUser.Id;
		teamMember.TeamMemberRole = 'Team Member (100%)';
        insert teamMember;
    }
}