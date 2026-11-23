global without sharing class Core_DracoReprocessFailedInboundBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public static String BatchCompletionResult = '';
    public static String BatchCompletionMessage = '';
    Integer maxRetryAttempt = integer.valueof(system.label.Max_Entitlement_Retry_Attempt);
    List<Core_Integration_Inbound_Message__c> pendingIIM = new List<Core_Integration_Inbound_Message__c>();
    Integer addMins = integer.valueof(System.Label.Core_Reprocess_TimeOffset_Minutes);
	Datetime timeOffset = System.now().addMinutes(-addMins);    
    string failedVal='Failed';
    string roleVal='Role 2.0';
    Integer batchSize = integer.valueof(System.Label.Core_Reprocess_Batch_Size);
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query = 'SELECT Id,Core_Retry_Counter__c,Core_Processing_Status__c, Core_Exception_Message__c FROM Core_Integration_Inbound_Message__c WHERE Core_Processing_Status__c =:failedVal  AND Core_Retry_Counter__c <=: maxRetryAttempt AND Core_Retry_Counter__c != 0 AND Core_Message_Type__c =:roleVal AND LastModifiedDate < '+ + timeOffset.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' LIMIT ' + batchSize;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Core_Integration_Inbound_Message__c> failedIIM ) {
        try {
		if(!failedIIM.isEmpty()){
            for(Core_Integration_Inbound_Message__c IIM : failedIIM){
            IIM.Core_Processing_Status__c = 'Pending';
            IIM.Core_Retry_Counter__c += 1;
            pendingIIM.add(IIM);	
        	} 
		update pendingIIM;   
    	}
        }catch (DmlException e) {
            BatchCompletionMessage = 'Core_DracoReprocessFailedInboundBatch batch Failed.';
            BatchCompletionResult = 'Error in reprocessingIIM. Exception Occured: ' + e.getMessage();
        }
    }


    global void finish(Database.BatchableContext BC){
        String LOG_ENTRY_ORIGIN   = 'SFDC';
        String LOG_ENTRY_PROJECT  = 'Entitlement';
        String LOG_ENTRY_INFO     = 'info';
        String LOG_ENTRY_SCOPE    = 'Reprocess failed inbound';
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            Core_Origin__c = LOG_ENTRY_ORIGIN,
            Core_Project__c = LOG_ENTRY_PROJECT,
            Core_Scope__c = LOG_ENTRY_SCOPE,
            Core_Severity__c = LOG_ENTRY_INFO,
            Core_Message__c = BatchCompletionMessage,
            Core_When__c = system.now(),
            Core_Details__c = BatchCompletionResult,
            Core_sObjectId__c = null,
            Core_sObjectType__c = null,
            Core_Tags__c = null
        );
        insert objCLE;
    }
}