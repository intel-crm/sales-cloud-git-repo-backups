@isTest
public class PRM_AdminRegistration_Test {
    
    @testSetup
    static void createTestRecords() {
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();

        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        insert a;

        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        insert c;
    }
    
    @isTest static void fetchStateCountryValues_test(){
        PRM_AdminRegistration.picklistValues picklist_values = new PRM_AdminRegistration.picklistValues();
        test.starttest();
        Contact c = [Select Id,Email from Contact Limit 1];
        picklist_values = PRM_AdminRegistration.getPicklistValues();
        PRM_AdminRegistration.fetchAccountDetails(c.Email);
        test.stopTest();
        
        System.assertEquals(c.Email, 'testrequest@mailinator.com', 'Value does not match');

    }
    
}