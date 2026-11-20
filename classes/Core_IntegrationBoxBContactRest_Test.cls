@isTest
private class Core_IntegrationBoxBContactRest_Test {
     
      private static testmethod void testIntegrationBoxBContactRest() {
        
        Contact testContact = createTestContact();
        insert new Core_ACM_Control_Execution__c(Name='IntegrationBoxBContactRest',IsActive__c = true);
        Test.startTest();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest(); 
        
        req.params.put('contactId', testContact.Id);			
        
        req.httpMethod = 'Get';
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated 
        req.requestURI = '/services/apexrest/BoxB/Contact' ;  
        RestContext.request = req;
        RestContext.response = res;
        
        Core_IntegrationUtility.BoxB_ContactWrapper results = Core_IntegrationBoxBContactRest.generateBoxBContactOutboundMessage(); 
        
        res = new RestResponse();
        req = new RestRequest(); 
        
        req.params.put('enterpriseId', testContact.Core_Enterprise_Id__c);			
        
        req.httpMethod = 'Get';
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated 
        req.requestURI = '/services/apexrest/BoxB/Contact' ;  
        RestContext.request = req;
        RestContext.response = res;
        
        results = Core_IntegrationBoxBContactRest.generateBoxBContactOutboundMessage();
        
        res = new RestResponse();
        req = new RestRequest(); 
        
        req.params.put('enterpriseId', '');			
        
        req.httpMethod = 'Get';
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated 
        req.requestURI = '/services/apexrest/BoxB/Contact' ;  
        RestContext.request = req;
        RestContext.response = res;
        
        results = Core_IntegrationBoxBContactRest.generateBoxBContactOutboundMessage();
        
        Test.stopTest();
    }
    private static Contact createTestContact() {
        
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        conObj.Core_eRPM_Person_Id__c = '3111111';
        conObj.Core_Enterprise_Id__c = '4123456';
        conObj.Core_Login_Id__c = '412355';
        conObj.FirstName = 'Outbound Integrations Tester API';
        conObj.LastName = 'Person API';
        conObj.Email = 'OIAPITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester API';
        conObj.Core_English_Only_Last_Name__c = 'Person API';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'API OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '41234 APITester St';
        conObj.MailingCity = 'APITesting City';
        conObj.MailingStateCode = 'CA';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '42345';
        conObj.Phone = '9934501234';
        conObj.MobilePhone = '';
        conObj.AccountId = acctObj.Id;
        
        insert conObj;
        
        return conObj;
    }
    private static Account createTestAccount() {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        insert acctObj;
        
        return acctObj;
    }
}