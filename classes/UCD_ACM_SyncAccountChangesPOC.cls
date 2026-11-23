public with sharing class UCD_ACM_SyncAccountChangesPOC {
    
    @AuraEnabled
    public static Account syncAccountChanges(Id accountId){

        System.debug('Account Id : '+accountId);
        Account accountRecord = [SELECT ID, Core_Data_Simplified_Account_Nm__c, Core_Data_Simplified_Local_Language_Nm__c, Core_Business_Partner_Id__c, New_Simplified_Account_Name__c, New_Simplified_Local_Language_Name__c, New_Business_Partner_Id__c  FROM Account WHERE Id =: accountId LIMIT 1];
        accountRecord.Core_Data_Simplified_Account_Nm__c = accountRecord.New_Simplified_Account_Name__c;
        accountRecord.Core_Data_Simplified_Local_Language_Nm__c = accountRecord.New_Simplified_Local_Language_Name__c;
        accountRecord.Core_Business_Partner_Id__c = accountRecord.New_Business_Partner_Id__c;

        System.debug('Account record: '+accountRecord);
        update accountRecord;

        return accountRecord;
    }
}