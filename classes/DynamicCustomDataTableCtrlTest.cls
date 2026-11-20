@isTest
private class DynamicCustomDataTableCtrlTest {
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
		
        List<Contact> conList = new List<Contact>();
        
        Contact con = new Contact();
        con.FirstName = 'test first';
        con.LastName = 'test last';
        con.AccountId = acc.Id;
        con.Email = 'testsend@mail.com';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.FirstName = 'test first1';
        con1.LastName = 'test last1';
        con1.AccountId = acc.Id;
        con1.Email = 'testsend1@mail.com';
        conList.add(con1);
        
        insert conList;

    }

    @isTest static void dynamicCustomDataTableTest() {
        List<Contact> cons = [SELECT Id FROM Contact];
        Test.startTest();
        DynamicCustomDataTableCtrl.getFieldsetFields('Contact', 'DynamicDataTableFieldSet', true);
        Object ob =  new List<Object>{ new Map<String, Object> {'LastName' => 'test last1','Id' => cons[0].Id,'LastName' => '','Id' => cons[1].Id}};
        DynamicCustomDataTableCtrl.updateRecords(ob, 'Contact');
        Test.stopTest();
    }
}