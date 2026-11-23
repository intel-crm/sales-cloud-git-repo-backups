public without sharing class PRM_PartnerDealRegHandler {
    
   /* @AuraEnabled(cacheable=true)
    public static List<PRM_Partner_Deal_Product__c> searchDealProducts(String searchKey) {
        return [SELECT Id, Name FROM PRM_Partner_Deal_Product__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPartnerAccountId() {
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (u.ContactId == null || u.Contact.AccountId == null) {
            return 'Contact or Account not present';
        }
        return u.Contact.AccountId;
    }*/
}