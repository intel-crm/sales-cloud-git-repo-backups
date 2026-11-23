public with sharing class ACM_MoveContactWithCases_Controller {
    @AuraEnabled(cacheable=true)
    public static Contact getCurrentContact(Id contactId) {
        return [
            SELECT Id, Name, AccountId, Account.Name 
            FROM Contact 
            WHERE Id = :contactId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name FROM Account];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccount(Id accountId) {
        return [SELECT Id, Name FROM Contact WHERE AccountId = :accountId];
    }

    @AuraEnabled
    public static void updateCasesOnSave(Id targetAccountId, Id targetContactId) {
        // Validate inputs
        if (targetAccountId == null || targetContactId == null) {
            throw new AuraHandledException('Target Account and Contact must be selected.');
        }

        // Query cases associated with the current contact
        Id currentContactId = UserInfo.getUserId(); // Replace with the actual current contact ID logic
        List<Case> casesToUpdate = [
            SELECT Id, ContactId, AccountId
            FROM Case
            WHERE ContactId = :currentContactId
        ];

        if (casesToUpdate.isEmpty()) {
            throw new AuraHandledException('No cases found for the current contact.');
        }

        // Update cases to the new contact and account
        for (Case caseRecord : casesToUpdate) {
            caseRecord.ContactId = targetContactId;
            caseRecord.AccountId = targetAccountId;
        }

        try {
            update casesToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to update cases: ' + e.getMessage());
        }
    }
}