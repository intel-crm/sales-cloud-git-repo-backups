public without sharing class Core_MDF_AllocationIdCleanupBatch implements Database.batchable<Sobject>{
    
	public Database.QueryLocator start(Database.batchableContext bc){ 
        String closedStatus = 'Cancelled';
        String closedActivityClaims = 'Select id,BudgetId, AllocationId FROM PartnerFundRequest WHERE Core_MDF_Proposal_Based_Ind__c = TRUE AND Core_MDF_IsCloned_Ind__c =  TRUE AND Core_MDF_Fund_Request_Status__c =:closedStatus AND Allocationid!=null';
        //Custom Label or Custom Setting    
        system.debug('@@query --> '+closedActivityClaims);     
        return database.getQueryLocator(closedActivityClaims);
    }
    public void execute(Database.batchableContext bc, List<PartnerFundRequest> closedActivityClaims){
        List<PartnerFundRequest> claimsToClosed = new List<PartnerFundRequest>();
        system.debug('**size11**'+closedActivityClaims.size());
        if(!closedActivityClaims.isEmpty()){
            system.debug('**size**'+closedActivityClaims.size());
            for(PartnerFundRequest pfr: closedActivityClaims){                
                pfr.AllocationId = null;
                //pfr.BudgetId='';
                claimsToClosed.add(pfr);                
            }
        }
        if(!claimsToClosed.isEmpty())
            Database.update(claimsToClosed);
    }
    public void finish(Database.batchableContext bc){
        
    }
    
}