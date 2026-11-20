/******************************************************************************************************************************************
Class Name  : Core_RestAPI_SecureContent_Contact_Test 
Version     : 1.0 
Created Date: 30 May 2018
Function    : Apex class to get the list of B2B Contacts for a given list of Account Ids
/services/apexrest/SecureContent/Contacts?accountIds=0012D000002S3G9,0012D000002S3G4

        Modification Log
* Developer             Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venu Karumuru         05/30/2018              Initial Version
*****************************************************************************************************************************************/

@isTest
public class Core_RestAPI_SecureContent_Contact_Test {

    public static Id accountId = null;

    // Method to test normal flow
    private static testmethod void Test1_Normal_Flow() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/Contacts';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';        
        req.params.put('accountIds', accountId);

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_Contact.GetContacts(); 
        Test.stopTest();
    }


    // Method to test exception - Force the exception
    private static testmethod void Test2_Exception_Flow() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/Contacts';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.params.put('accountIds', accountId);
        req.params.put('createException', '1');

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_Contact.GetContacts(); 
        Test.stopTest();
    }


    // Method to test exception - No Parameter is passed to the service method
    private static testmethod void Test3_No_Parameter() {
        createTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SecureContent/Contacts';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';        

        RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
       	Core_RestAPI_SecureContent_Contact.GetContacts(); 
        Test.stopTest();
    }


    // Method to create test data
    private static void createTestData() {

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
        testAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();       
        insert testAccount;

        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test Contact1';
        testContact.LastName = 'Test Contact1';
        testContact.Email = 'Test_Contact1@tester.com';
        testContact.Core_Job_Function__c = 'Information Technology';
        testContact.MailingCountry='IND';
        testContact.Core_Contact_B2B_Indicator__c = true;
        testContact.AccountId = testAccount.Id;        
        insert testContact;

        // Save the Account Id
        accountId = testAccount.id;
    }
}