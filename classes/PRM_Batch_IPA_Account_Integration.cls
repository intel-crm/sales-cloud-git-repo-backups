public without sharing class PRM_Batch_IPA_Account_Integration implements Database.Batchable<sObject>, Database.Stateful {
	// instance member to retain state across transactions
    public Integer recordsProcessed = 0;
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String pendingLabel = Label.IPA_Integration_Status_Pending;
		String idd ='001D300000t9B16IAE';
        if(Label.EnableIPAIntegrationBatchMode == 'true') {
          System.debug('Inside if data==='+Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationAccountBatchLimit));
		  return Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationAccountBatchLimit);
         // return Database.getQueryLocator('SELECT Id FROM Account Where id =: idd ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationAccountBatchLimit);
        }
        else {
            System.debug('Inside else==='+Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel'));
            //String query = 'SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel';
            return Database.getQueryLocator('SELECT Id FROM Account Where PRM_IPA_Integration_Status__c =:pendingLabel');
        }

	}
	public void execute(Database.BatchableContext bc, List<Account> scope){
         System.debug('Inside execute method');
		// process each batch of records
		try {
            system.debug('Scope - '+scope.size());
			if(scope.size() > 0) {               
				Set<Id> iPAAccountIds = new Set<Id>();
				for (Account a : scope) {
					iPAAccountIds.add(a.Id);
				}
                System.debug('Before PRM_SalesCloud_Integration=== '+iPAAccountIds);
				PRM_SalesCloud_Integration.GenerateAccountOBM(iPAAccountIds);
			}
		} catch (Exception ex) {
		}
	}
	public void finish(Database.BatchableContext bc){
		/*AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
		                    JobItemsProcessed,
		                    TotalJobItems, CreatedBy.Email
		                    FROM AsyncApexJob
							WHERE Id = :bc.getJobId()];
		System.debug('Account Payload generation batch completed - Status : '+job);*/
	}
}