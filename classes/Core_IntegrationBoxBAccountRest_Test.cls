@isTest
private class Core_IntegrationBoxBAccountRest_Test {
    
    private static testmethod void testIntegrationBoxBAccountRest() {
        Account testAccount = createTestAccount();
        insert new Core_ACM_Control_Execution__c(Name='IntegrationBoxBAccountRest',IsActive__c = true);
        Test.startTest();

            RestResponse res = new RestResponse();
            RestRequest req = new RestRequest(); 

			req.params.put('accountId', testAccount.Id);			
			
            req.httpMethod = 'Get';
            req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated 
            req.requestURI = '/services/apexrest/BoxB/Account' ;  
            RestContext.request = req;
            RestContext.response = res;

			Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper results = Core_IntegrationBoxBAccountRest.generateBoxBAccountOutboundMessage(); 
			
		Test.stopTest();
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
        
        insert acctObj;
        
        return acctObj;
    }
}