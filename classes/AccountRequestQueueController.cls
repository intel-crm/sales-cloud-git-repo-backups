public class AccountRequestQueueController {
    @AuraEnabled
    public static void updateAccountRequestField(String accountRequestId) {
        try {
            Account_Create_Request__c acc = [SELECT Id FROM Account_Create_Request__c WHERE Id = :accountRequestId LIMIT 1];
            acc.Address_Standardization_Time__c = System.now();
            update acc;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating Account field: ' + e.getMessage());
        }
    }
}