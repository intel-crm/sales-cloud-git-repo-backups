public with sharing class uCD_ACM_AccountChangeReviewController {
    @AuraEnabled(Cacheable = true)
    public static List<Account> getAccounts(String strNewUnifiedId) {
        List<Account> accountList = [SELECT  Id, Name, Core_Business_Party_Id__c FROM Account WHERE Core_Business_Party_Id__c =: strNewUnifiedId];
       System.debug('accountList'+accountList);
        return accountList; 
    }
}