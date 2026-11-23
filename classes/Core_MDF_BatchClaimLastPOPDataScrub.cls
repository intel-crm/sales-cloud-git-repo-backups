public without sharing class Core_MDF_BatchClaimLastPOPDataScrub implements Database.Batchable<sObject> ,database.stateful {

	public Set<Id> failedClaimIdsSet = new Set<Id>();
	public Set<Id> updatedClaimIdsSet = new Set<Id>();
	public Database.QueryLocator start(Database.BatchableContext bc) 
    {
		String query = 'Select id,Core_MDF_RMF_Last_POP_Submission_Dt__c,CreatedDate,Core_MDF_Claim_Review_Case__c from PartnerFundClaim where Core_MDF_RMF_Last_POP_Submission_Dt__c == NULL AND Core_MDF_Claim_Review_Case__c == NULL';
		return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<PartnerfundClaim> claimList)
	{
		for(PartnerfundClaim pfc : claimList){
			pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = (pfc.createdDate).date();
		}
		try
		{
			if(claimList != NULL && claimList.size() > 0){
				Database.SaveResult[] srList = Database.update(claimList,false);
				for(Integer i=0; i < srList.size(); i++) {
					if(srList.get(i).isSuccess()) {
                        System.debug('Records are updated Successfully');
                        updatedClaimIdsSet.add(srList.get(i).Id);
					}
					else{
                        Database.Error errors =  srList.get(i).getErrors().get(0);
                        System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                        failedClaimIdsSet.add(srList.get(i).Id);
					}
				}
			}
        }
		catch(Exception e)
		{
			Core_MDF_CCP_UtilityClass.logError(e);
		}
	}
	public void finish(Database.BatchableContext bc)
	{
		system.debug('All fails Ids===' +failedClaimIdsSet);
        system.debug('All success Id---' +updatedClaimIdsSet);
	}
}