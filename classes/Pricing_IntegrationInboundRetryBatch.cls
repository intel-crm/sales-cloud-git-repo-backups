public without sharing class Pricing_IntegrationInboundRetryBatch implements Database.Batchable<sObject>, Database.Stateful {

    Map<Id,String> inboundRecordMap = new Map<Id,String>();
    Map<String,String> successMap = new Map<String,String>();
    Map<String,Id> successSObjectNameToRecordIdMap = new Map<String,Id>();
    Map<String,String> errorMap = new Map<String,String>();
    Map<String,Id> errorSObjectNameToRecordIdMap = new Map<String,Id>();
    List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
    
    // Core_Integration_Inbound_Message__c records with Failed status which are created today
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        Integer retryCounter = Integer.valueOf(Label.Integration_Inbound_Retry_Counter);
        Integer dateCounter = Integer.valueOf(Label.Integration_Inbound_Date_Counter);

        String query = 'SELECT Id,Name,Core_Retry_Counter__c,Core_Processing_Status__c ' + 
                       'FROM Core_Integration_Inbound_Message__c ' + 
                       'WHERE Core_Message_Type__c = \'' + 'Tender' + '\'AND Core_Processing_Status__c = \'' + 'Failed' + '\'AND Core_Retry_Counter__c >= :retryCounter AND CreatedDate = LAST_N_DAYS: '+ dateCounter;

        return (TriggerHandler.isActive('Pricing_Integration_Inbound_Retry_Batch'))? Database.getQueryLocator(query): null;
    }

    // Updating the Core Retry Counter to 0 and Status to Pending
    public void execute(Database.BatchableContext bc, List<Core_Integration_Inbound_Message__c> scope)
    {
        String statusMessage;
        try {
            for(Core_Integration_Inbound_Message__c integrationInboundRecord : scope) {
                System.debug('integrationInboundRecord -> ' + integrationInboundRecord); 
                integrationInboundRecord.Core_Retry_Counter__c = 0;
                integrationInboundRecord.Core_Processing_Status__c = 'Pending';
                inboundRecordMap.put(integrationInboundRecord.Id ,integrationInboundRecord.Name);
            } 
            Database.saveResult[] results = Database.update(scope,false);

            for(Database.SaveResult res : results) {
                if(res.isSuccess()){
                    statusMessage = 'Record: '+inboundRecordMap.get(res.getId())+' has been processed successfully.';
                    successMap.put(inboundRecordMap.get(res.getId()),statusMessage);
                    successSObjectNameToRecordIdMap.put(inboundRecordMap.get(res.getId()),res.getId());                    
                }
                else {
                    statusMessage = 'Record: '+inboundRecordMap.get(res.getId())+' is processed with an error.';
                    errorMap.put(inboundRecordMap.get(res.getId()),statusMessage);
                    errorSObjectNameToRecordIdMap.put(inboundRecordMap.get(res.getId()),res.getId());                     
                }
            }
        }
        catch(exception ex)
        {
            Pricing_Tender_Utility.logError(ex);
        }
    }

    // Core_Log_Entry__c records for failed records and successfully updated records
    public void finish(Database.BatchableContext bc)
    {
        if(successMap.size()>0 && successSObjectNameToRecordIdMap.size()>0){
            logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(successMap,successSObjectNameToRecordIdMap,'Low'));
        }
        if(errorMap.size()>0 && errorSObjectNameToRecordIdMap.size()>0){
            logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(errorMap,errorSObjectNameToRecordIdMap,'Critical'));
        }
        if(logEntryList.size() > 0){
            insert logEntryList;    
        }
    }

}