@isTest
private class ER_SearchAccounts_Test {

    static testMethod void callConstructor()
    {
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        Test.startTest();
        ER_SearchAccounts s_acc = new ER_SearchAccounts (acc.id,acc.Core_CIM_ID__c, acc, 5);
        //ER_SearchAccounts searchAccount = ER_SearchAccounts();
        //s_acc.compareTo(searchAccount);
        Test.stopTest();
        
        
    }
    static testMethod void callCompareTo()
    {
         Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
       
        ER_SearchAccounts s_acc = new ER_SearchAccounts (acc.id,acc.Core_CIM_ID__c, acc, 5);
        System.assertEquals(acc != null, true, 'account detail is null');
        Test.startTest();
        //ER_SearchAccounts searchAccount = ER_SearchAccounts(s_acc);
        s_acc.compareTo(s_acc);
        Test.stopTest();
    }
}