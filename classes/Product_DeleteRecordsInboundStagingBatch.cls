global with sharing class Product_DeleteRecordsInboundStagingBatch implements Database.Batchable<SObject>,Schedulable {
    // Get the age threshold from a custom label
    Integer ageThreshold = Integer.valueOf(Label.Product_DeleteStagingRecordsAgeThreshold);
    
     public void execute(SchedulableContext ctx) {
        Database.executeBatch(new Product_DeleteRecordsInboundStagingBatch());
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
        Product_DeleteRecordsStagingBatch batch = new Product_DeleteRecordsStagingBatch();
        Database.executeBatch(batch);
    }
}