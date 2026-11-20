@isTest(SeeAllData=false)
private class PBI_Embed_Class_Test {
    @isTest
    static void checkAccessTest(){
        boolean result;
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'GM';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = pro.Id;
        us.LanguageLocaleKey = 'en_US';
        us.Core_WWID__c = '00000';
        
        insert us;
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = new Account(Name ='Test Account',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR');
        Database.insert(acc);
        System.runAs(us) {
            result = PBI_Embed_Class.checkAccess(acc.id);
        }
        
        System.assert(result==false);
    }
}