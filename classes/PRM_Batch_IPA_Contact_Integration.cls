public without sharing  class PRM_Batch_IPA_Contact_Integration implements Database.Batchable<sObject>, Database.Stateful  {
    public Integer recordsProcessed = 0;
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String pendingLabel = Label.IPA_Integration_Status_Pending;
        if(Label.EnableIPAIntegrationBatchMode == 'true') {
            return Database.getQueryLocator('SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationContactBatchLimit);
        }
        else {
            //String query = 'SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel';
            return Database.getQueryLocator('SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel');  
        }
	}
	public void execute(Database.BatchableContext bc, List<Contact> scope){
		// process each batch of records
		try {
			if(scope.size() > 0) {               
				Set<Id> iPAContactIds = new Set<Id>();
				for (Contact cont : scope) {
					iPAContactIds.add(cont.Id);
				}
				PRM_SalesCloud_Integration.GenerateContactOBM(iPAContactIds);
			}
		} catch (Exception ex) {
			system.debug('Error occured from class PRM_Batch_IPA_Contact_Integration execute method due to '+ ex.getCause());
		}
	}
    public void finish(Database.BatchableContext bc){
		/*AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
		                    JobItemsProcessed,
		                    TotalJobItems, CreatedBy.Email
		                    FROM AsyncApexJob
							WHERE Id = :bc.getJobId()];*/
	}
}