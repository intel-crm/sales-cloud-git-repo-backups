global class DeleteRecordsInboundStagingBatch implements Database.Batchable<SObject>,Schedulable {
    // Get the age threshold from a custom label
    Integer ageThreshold = Integer.valueOf(Label.DeleteStagingRecordsAgeThreshold);
    
     public void execute(SchedulableContext ctx) {
        Database.executeBatch(new DeleteRecordsInboundStagingBatch());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString='SELECT Id FROM Product_Inbound_Staging__c WHERE CreatedDate < LAST_N_DAYS:  ' + ageThreshold;
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Delete the records in the current batch
        Database.delete(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        DeleteRecordsStagingBatch batch = new DeleteRecordsStagingBatch();
        Database.executeBatch(batch);
    }
}