public with sharing class Product_DeleteFPHRecords implements Database.Batchable<sObject> {
    
    public string ipaasLoadId;
   	public Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    public Product_DeleteFPHRecords(string ipaasId){
        this.ipaasLoadId = ipaasId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr;
        if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c)){
            queryStr = 'SELECT Id FROM Core_Flat_Product_Hierarchy__c WHERE Core_iPaaS_Load_ID__c != :ipaasLoadId';
        }else{
            queryStr = 'SELECT Id,Core_Unique_ID__c FROM Core_Flat_Product_Hierarchy__c';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Core_Flat_Product_Hierarchy__c> fphRecordsToDelete){
        try{
            if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c)){
                if (!fphRecordsToDelete.isEmpty()) {
                    Database.delete(fphRecordsToDelete,false);
                }
            }else{
                Map<String,Core_Flat_Product_Hierarchy__c> mapL5IdFPH = new Map<String,Core_Flat_Product_Hierarchy__c>();
                List<Core_Flat_Product_Hierarchy__c> listFPHRecordsToDelete = new List<Core_Flat_Product_Hierarchy__c>();
                for(Core_Flat_Product_Hierarchy__c fph : fphRecordsToDelete){
                    mapL5IdFPH.put(fph.Core_Unique_ID__c,fph);
                }
                
                List<product2> listProducts= [SELECT Id,Core_Unique_ID__c FROM Product2 WHERE Core_Unique_ID__c IN :mapL5IdFPH.keySet() AND isActive = FALSE];
                
                // delete fph records which do not have corresponding active product2 records
                if (!listProducts.isEmpty()) {
                    for(product2 prd : listProducts){
                        if(!mapL5IdFPH.isEmpty() && mapL5IdFPH.containsKey(prd.Core_Unique_ID__c)) {
                            if(!listFPHRecordsToDelete.contains(mapL5IdFPH.get(prd.Core_Unique_ID__c))) {
                                listFPHRecordsToDelete.add(mapL5IdFPH.get(prd.Core_Unique_ID__c));
                            }
                        }
                    }
                    if (!listFPHRecordsToDelete.isEmpty()) {
                        Database.delete(listFPHRecordsToDelete,false);
                    }
                }
            }
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasLoadId,'Product_DeleteFPHRecords',null,null);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c)){
            Database.executeBatch(new Product_DeactivationAndLogEntry(ipaasLoadId),2000);
        } else {
            Database.executeBatch(new Product_CreateLogEntriesBatch(ipaasLoadId),2000);
        }
        
    }
}