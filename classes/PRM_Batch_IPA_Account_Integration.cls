public without sharing class PRM_Batch_IPA_Account_Integration implements Database.Batchable<sObject>, Database.Stateful {
	// instance member to retain state across transactions
    public Integer recordsProcessed = 0;
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String pendingLabel = Label.IPA_Integration_Status_Pending;
        if(Label.EnableIPAIntegrationBatchMode == 'true') {
            return Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationAccountBatchLimit);
        }
        else {
            //String query = 'SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel';
            return Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel');
        }

	}
	public void execute(Database.BatchableContext bc, List<Account> scope){
		// process each batch of records
		try {
			if(scope.size() > 0) {               
				Set<Id> iPAAccountIds = new Set<Id>();
				for (Account a : scope) {
					iPAAccountIds.add(a.Id);
				}
				PRM_SalesCloud_Integration.GenerateAccountOBM(iPAAccountIds);
			}
		} catch (Exception ex) {
			system.debug('Error occured from class PRM_Batch_IPA_Account_Integration execute method due to '+ ex.getCause());
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