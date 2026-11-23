@isTest(SeeAllData=false)
private class PBI_Embed_Class_Test {
    @isTest
    static void checkAccessTest(){
        boolean result;
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = new Account(Name ='Test Account',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR');
        Database.insert(acc);
        result = PBI_Embed_Class.checkAccess(acc.id);
        System.assert(result==false);
    }
}