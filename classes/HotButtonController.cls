public with sharing class HotButtonController {
    @AuraEnabled(cacheable=true)
    public static List<Account_Hot_Button__c> getHotButtons(Id accountPlanId) {
        // Fetch the related Account ID from the Account Plan
        Id accountId = [SELECT AccountId FROM AccountPlan WHERE Id = :accountPlanId].AccountId;

        // Query Hot Buttons related to the Account
        return [
            SELECT Id, Name, Description__c, Owner.Name
            FROM Account_Hot_Button__c
            WHERE Account_Lookup__c = :accountId
        ];
    }

    /**
     * Adds a new Hot Button for the Account associated with the given Account Plan.
     *
     * @param accountPlanId The ID of the Account Plan record.
     * @param name The name of the Hot Button.
     * @param description The description of the Hot Button.
     * @param ownerId The ID of the user who owns the Hot Button.
     */
    @AuraEnabled
    public static void addHotButton(Id accountPlanId, String name, String description, Id ownerId) {
        // Fetch the related Account ID from the Account Plan
        Id accountId = [SELECT AccountId FROM AccountPlan WHERE Id = :accountPlanId].AccountId;

        // Create and insert the new Hot Button record
        Account_Hot_Button__c hotButton = new Account_Hot_Button__c(
            Account_Lookup__c = accountId,
            Name = name,
            Description__c = description,
            OwnerId = ownerId
        );
        insert hotButton;
    }
}