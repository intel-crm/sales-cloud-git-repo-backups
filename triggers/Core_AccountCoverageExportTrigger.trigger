trigger Core_AccountCoverageExportTrigger on Core_AccountCoverage_Export__c (before update, after update, before insert) {
  
  // ************************************************* BEFORE UPDATE TRIGGER START************************************************* //
  if (Trigger.IsBefore && Trigger.IsUpdate) {
        // system.debug('updating');
        Core_AccountCoverageExportTriggerHandler.updateOperation(Trigger.new, Trigger.oldMap ); // Update Operation field on Core_AccountCoverage_Export__c record 
   }
   // ************************************************* BEFORE INSERT TRIGGER START************************************************* //
  if (Trigger.IsBefore && Trigger.IsInsert) {
        // system.debug('inserting');
        Core_AccountCoverageExportTriggerHandler.updateInsertOperation(Trigger.new ); // Update Operation/status field on Core_AccountCoverage_Export__c record on insert
   }
  
 
}