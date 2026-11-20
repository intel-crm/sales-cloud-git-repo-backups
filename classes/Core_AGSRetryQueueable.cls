/**************************************************************************************
Apex Class Name : Core_AGSRetryQueueable
Version     : 1.0 
Created Date: 6th Nov 2026
Description : Retry Queueable for AGS Integration stuck in-progress contacts
*************************************************************************************/
public class Core_AGSRetryQueueable implements Queueable, Database.AllowsCallouts{
    private List<Contact> contactsToUpdate;
    
    // Constructor to pass the batch chunk record IDs
    public Core_AGSRetryQueueable(List<Contact> contactsToUpdate) {
        this.contactsToUpdate = contactsToUpdate;
    }
    
    public void execute(QueueableContext context) {
        List<Database.SaveResult> results =
            Database.update(contactsToUpdate, false);
        for (Database.SaveResult sr : results) {                
            if (!sr.isSuccess()) {
                System.debug('Failure occured in Core_AGSRetryQueueable'+sr.getErrors());
            }
        }
    }
}