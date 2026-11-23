/**************************************************************************************************************
Apex Class Name:  Core_Batch_Unlock_Opportunities
Version     : 1.0 
Created Date: 31 MAR 2016
Function    : Batch class to unlock "Submitted" opportunities that have been last modified since yesterday
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             03/31/2016        Initial version
***************************************************************************************************************/
global class Core_Batch_Unlock_Opportunities implements Database.Batchable<sObject> {
    
    // Get the opportunities to unlock
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select Id from Opportunity where Core_Approval_Status__c = 'Submitted' and LastModifiedDate >= YESTERDAY]);
    }
    
    // Unlock them
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        Approval.UnlockResult[] urList = Approval.unlock(scope, false);
        
        // Iterate through each returned result
        for(Approval.UnlockResult ur : urList) {
            if (ur.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully unlocked opportunity with ID: ' + ur.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : ur.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}