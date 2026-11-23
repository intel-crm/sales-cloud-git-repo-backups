public with sharing class AccountTransferLogPocController {
    @AuraEnabled(cacheable=true)
    public static List<Core_MDF_Budget_Transfer_Log__c> getLogs() {
        return [SELECT Id, Name, Core_MDF_Partner_Marketing_Budget__c FROM Core_MDF_Budget_Transfer_Log__c LIMIT 10];
    }
}