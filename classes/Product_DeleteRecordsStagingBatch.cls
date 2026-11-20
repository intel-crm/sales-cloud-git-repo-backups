global with sharing class Product_DeleteRecordsStagingBatch implements Database.Batchable<SObject> {
    // Get the age threshold from a custom label
    Integer ageThreshold = Integer.valueOf(Label.Product_DeleteStagingRecordsAgeThreshold);
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString='SELECT Id FROM Core_Products_Staging__c WHERE CreatedDate < LAST_N_DAYS: ' + ageThreshold;
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Delete the records in the current batch
        Database.delete(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        // Batch job finished
    }
}