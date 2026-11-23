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
        return Database.getQueryLocator([select Id from Opportunity where Core_Approval_Status__c = 'Submitted' and Core_Opportunity_Coverage_Nm__c <> 'Partner-Led Opportunity' and Core_Coverage_Type_Nm__c <> 'Deal Registration' and LastModifiedDate >= YESTERDAY]);
    }
    
    // Unlock them
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        Approval.UnlockResult[] urList = Approval.unlock(scope, false);
        
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}