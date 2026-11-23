public with sharing class ER_AccountAssociationService {
    
    public static void createAssociations(String bagId, Map<String, Account> accountsByDirectId) {
        Set<Id> existingAssociatedAccountIds = getExistingAssociatedAccountIds(bagId);
        
        List<ER_Account_Business_Partner__c> newAssociations = new List<ER_Account_Business_Partner__c>();
        for (Account acc : accountsByDirectId.values()) {
            if (acc.Id != null && !existingAssociatedAccountIds.contains(acc.Id)) {
                newAssociations.add(new ER_Account_Business_Partner__c(
                    ER_Account__c = acc.Id,
                    ER_Customer_Master_File_Grouping__c = bagId,
                    ER_Active__c = true
                ));
            }
        }
        
        if (!newAssociations.isEmpty()) {
            insert newAssociations;
        }
    }
    
    private static Set<Id> getExistingAssociatedAccountIds(String bagId) {
        Set<Id> accountIds = new Set<Id>();
        for (ER_Account_Business_Partner__c assoc : [
            SELECT ER_Account__c FROM ER_Account_Business_Partner__c 
            WHERE ER_Customer_Master_File_Grouping__c = :bagId AND ER_Active__c = TRUE
        ]) {
            accountIds.add(assoc.ER_Account__c);
        }
        return accountIds;
    }
}