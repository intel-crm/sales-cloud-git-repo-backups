public class UCD_ACM_UpdateContactQueueable implements Queueable {
    private Contact contactToUpdate;
    private Id accountId;

    public UCD_ACM_UpdateContactQueueable(Contact contact, Id accountId) {
        this.contactToUpdate = contact;
        this.accountId = accountId;
    }

    public void execute(QueueableContext context) {
        //Contact contactToUpdate = [SELECT Id, AccountId, Core_ERPM_Integration_Status__c FROM Contact WHERE Id = :contactId];

        contactToUpdate.AccountId = accountId;
        contactToUpdate.Core_ERPM_Integration_Status__c = 'PENDING';
        Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;
        update contactToUpdate;
    }
}