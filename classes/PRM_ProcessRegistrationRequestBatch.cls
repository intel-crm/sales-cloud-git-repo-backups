global without sharing class PRM_ProcessRegistrationRequestBatch implements Database.Batchable<Sobject>, Database.stateful {
    public List<Sobject> sobjectToUpsert = new List<Sobject>();
    
     public PRM_ProcessRegistrationRequestBatch(List<Sobject> sobjectList){           
        sobjectToUpsert.addAll(sobjectList); 
         
    }
    
    
    public Iterable<Sobject> start(Database.BatchableContext bc){
        return sobjectToUpsert;
    }

    public void execute(Database.BatchableContext bc, List<Sobject> sobjectList){
        PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(sobjectList);
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}