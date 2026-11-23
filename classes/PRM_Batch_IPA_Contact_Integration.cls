public without sharing  class PRM_Batch_IPA_Contact_Integration implements Database.Batchable<sObject>, Database.Stateful  {
    public Integer recordsProcessed = 0;
    
    //IPA2.0 - TWC727-2862 - Start
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_Batch_IPA_Contact_Integration';
    public static final String LOG_ENTRY_PROJECT  = 'IPA';
    public static final String LOG_ENTRY_SCOPE    = 'Batch class failures - IPA';
    public static final String LOG_ENTRY_SEVERITY = 'Exception';
    public String strTags;
    String logEntryMsgString='';
    //IPA2.0 - TWC727-2862 - End
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String pendingLabel = Label.IPA_Integration_Status_Pending;
		id idd='003KR000002KkYrYAK';
       // string inactiveAccounts='Inactive_Account';
       /* Id account_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Inactive_Account')
        .getRecordTypeId();*/
        if(Label.EnableIPAIntegrationBatchMode == 'true') {
            return Database.getQueryLocator('SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel   and id =:idd ORDER BY LastModifiedDate ASC LIMIT '+Label.IPAIntegrationAccountBatchLimit);
        }
        else {
            //System.debug('Inside if data==='+Database.getQueryLocator('SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel '));
            //String query = 'SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel';
            return Database.getQueryLocator('SELECT Id FROM Contact Where PRM_IPA_Integration_Status__c =:pendingLabel ');  
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
        } 
        catch(Exception ex){
			logEntryMsgString+='\n\nException occurred:'+ex.getMessage() + '-' + ex.getStackTraceString();
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT ,LOG_ENTRY_SCOPE , LOG_ENTRY_SEVERITY , strTags); 
            //IPA2.0 - TWC727-2862 - Added log entry for failure tracking
		}
	}
    public void finish(Database.BatchableContext bc){
		/*AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
		                    JobItemsProcessed,
		                    TotalJobItems, CreatedBy.Email
		                    FROM AsyncApexJob
							WHERE Id = :bc.getJobId()];
		System.debug('Contact Payload generation batch completed - Status : '+job);*/
	}
}