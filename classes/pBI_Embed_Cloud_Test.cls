@isTest(SeeAllData=false)
public class pBI_Embed_Cloud_Test {
    @isTest
    static void checkGetURL(){
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = new Account(Name ='Test Account',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR');
        Database.insert(acc);
        PBI_Embed_Configuration__mdt urlConfig = [select id,Dynamic_filter__c, Filter__c, Filter_and_Value__c, Object__c, Static_Filter__c, URL__c, DeveloperName
                                                      from PBI_Embed_Configuration__mdt where DeveloperName='Test_Class_Record'];
        pBI_Embed_Cloud.getURL(urlConfig.DeveloperName,acc.id);    
    }
}