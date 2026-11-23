@isTest Public class Core_Integration_RDC_AccountRest_Test{
    
    // TEST SETUP 
    @testsetup private static void setupRDCAccountTestData() {
        
        Core_Country_Code_Mapping__c mapping = new Core_Country_Code_Mapping__c(Name='USA',Country_Code__c='US',ISO_Code__c='USA');
        insert mapping;
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingCountry = 'USA'; 
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_B2B_Entitlement__c = true;
        acctObj.Core_CNDA_Number__c = '23456';
        acctObj.Core_Geo__c = 'ASMO';
        acctObj.Core_Sub_Geo__c = 'NAR';
        acctObj.Core_Sales_Groups__c='CCG Sales Group';
        insert acctObj;        
    }
    
    //Retrieve Accounts 
    private static testmethod void testRDCAccounts(){
        Account testAccount = [SELECT Name,Id, Core_Business_ID__c,
        Core_CIM_ID__c,Core_Account_Legal_Name__c,Core_English_Only_Name__c,
                               BillingCountry,Core_Account_Country__c,Core_Sub_Geo__c,Core_Geo__c,Core_CNDA_Number__c
                               FROM Account WHERE Core_B2B_Entitlement__c = true and Core_CNDA_Number__c!= null limit 50000];
        Test.startTest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest(); 
        req.params.put('accountId', testAccount.Id);      
        req.httpMethod = 'Get';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestURI = '/services/apexrest/RDC/Accounts';  
        RestContext.request = req;
        RestContext.response = res; 
        Core_Integration_RDC_AccountRest.getRDCAccounts();  
        Test.stopTest();
    }

    //Add negative test case
    //Assertions
    
}