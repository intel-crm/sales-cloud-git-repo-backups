public class Core_MDF_Batch_ActInProgressUpdate implements Database.Batchable<sObject>, Database.Stateful {

   public Set<Id> pfrIdSet;
 
   public Core_MDF_Batch_ActInProgressUpdate(Set<Id> pfrIdSet){
        this.pfrIdSet = pfrIdSet;    
    }
 
   public Database.QueryLocator start(Database.BatchableContext BC){
		List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
       
       String query = 'Select Id, Core_MDF_Fund_Request_Status__c From PartnerFundRequest where Id in :pfrIdSet';
       return Database.getQueryLocator(String.escapeSingleQuotes(query)); 
       
   }
 
   public void execute(Database.BatchableContext BC, List<PartnerFundRequest> pfrToBeUpdated){
       
       System.debug('Inside batch execute');
       for(PartnerFundRequest pfr :pfrToBeUpdated)
       {
           pfr.Core_MDF_Fund_Request_Status__c = Label.Core_MDF_pfrInprogress;
          // pfrToBeUpdated.add(pfr);
       }
       if(pfrToBeUpdated != NULL && pfrToBeUpdated.size() > 0){
            Database.update(pfrToBeUpdated);
        }
       
       
   }
 
   public void finish(Database.BatchableContext BC){
   }

}