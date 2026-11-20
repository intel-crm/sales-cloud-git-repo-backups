@isTest
private with sharing class EnhancedEditRelatedRecordsCtrlTest {
    @TestSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'test account';
        acc.BillingCountryCode = 'USA';
        acc.BillingStateCode = 'AL';
        acc.BillingCity = 'Alabama';
        acc.BillingStreet = 'street';
        acc.Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        acc.Core_CIM_ID__c = '129698776';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'test first';
        con.LastName = 'test last';
        con.AccountId = acc.Id;
        con.Email = 'testsend@mail.com'; 
        insert con;

    }

    @isTest static void enhancedEditRelatedRecordTest() {
        List<Contact> cons = [SELECT Id,AccountId FROM Contact];
        Test.startTest();
        EnhancedEditRelatedRecordsCtrl.getFieldsetFields('Contact', 'DynamicDataTableFieldSet');
        EnhancedEditRelatedRecordsCtrl.getRelatedRecords(cons[0].AccountId, 'AccountId', 'Contact', 'LastName', 'LastModifiedDate DESC', 'DynamicDataTableFieldSet');
        Test.stopTest();
    }
}