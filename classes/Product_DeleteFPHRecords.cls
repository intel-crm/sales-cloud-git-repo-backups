public with sharing class Product_DeleteFPHRecords implements Database.Batchable<sObject> {
    
    public string ipaasLoadId;
    public Product_DeleteFPHRecords(string ipaasId){
        this.ipaasLoadId = ipaasId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr = 'SELECT Id FROM Core_Flat_Product_Hierarchy__c WHERE Core_iPaaS_Load_ID__c != :ipaasLoadId';
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Core_Flat_Product_Hierarchy__c> fphRecordsToDelete){
        try{
            if (!fphRecordsToDelete.isEmpty()) {
                Database.delete(fphRecordsToDelete,false);
               
            }
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasLoadId,'Product_DeleteFPHRecords',null,null);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new Product_DeactivationAndLogEntry(ipaasLoadId),2000);
    }
}