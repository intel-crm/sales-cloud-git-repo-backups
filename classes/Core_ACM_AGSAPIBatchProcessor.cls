public without sharing class Core_ACM_AGSAPIBatchProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private String processType;
    Map<Id,Core_ACM_Integration_Queue__c> failedRecords = new Map<Id,Core_ACM_Integration_Queue__c>();
    Set<Id> failedRecordsToRetry = new Set<Id>();
    private Integer retryCount;
	string liveprocesstype = 'LIVE';
	string bulkprocesstype = 'BULK';
    string source = 'Role 2.0';

    public Core_ACM_AGSAPIBatchProcessor() {
        this.retryCount = 0;
    }

    public Core_ACM_AGSAPIBatchProcessor(String processType) {
        this.processType = processType;
        this.retryCount = 0;
		this.source = 'Role 2.0';
    }

    public Core_ACM_AGSAPIBatchProcessor(Set<Id> failedRecordsId, Integer retryCount) {
        this.failedRecordsToRetry = failedRecordsId;
        this.retryCount = retryCount + 1;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
	String query;
	if(processType == 'LIVE'){
        query = Core_ACM_QueryFactory.getAGSQuery(failedRecordsToRetry, liveprocesstype, source);
	}
	else{
		query = Core_ACM_QueryFactory.getAGSQuery(failedRecordsToRetry, bulkprocesstype, source);
	}
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Core_ACM_Integration_Queue__c> scope) {
        List<Core_ACM_Integration_Queue__c> recordsToUpdate = new List<Core_ACM_Integration_Queue__c>();
        List<Core_Integration_Inbound_Message__c> integrationInboundMsgToInsert = new List<Core_Integration_Inbound_Message__c>();

        for (Core_ACM_Integration_Queue__c queueRecord : scope) {
            try {
                Core_ACM_PayloadWrapper.ResponseWrapper responseBody = null;
                String responseBodyJson = Core_ACM_CalloutService.executeAPICall(queueRecord, Core_ACM_Constants.SOURCE_AGS);
                if (responseBodyJson != null) {
                    responseBody = (Core_ACM_PayloadWrapper.ResponseWrapper) System.Json.deserialize(responseBodyJson, Core_ACM_PayloadWrapper.ResponseWrapper.class);
                }

                if (responseBody != null) {
                    System.debug('API Response Body: ' + responseBody);
                    if (responseBody.Status == Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.SUCCESS_STATUS)) {
                        integrationInboundMsgToInsert.add(Core_ACM_InboundMessageFactory.createAGSSuccessMessage(responseBodyJson));
                        queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.SUCCESS_STATUS);
                        queueRecord.Core_Retry_Count__c = retryCount;
                    } else {
                        integrationInboundMsgToInsert.add(Core_ACM_InboundMessageFactory.createAGSFailureMessage(responseBody, responseBodyJson));
                        queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
                        queueRecord.Core_Retry_Count__c = retryCount;
                        failedRecords.put(queueRecord.Id, queueRecord);
                    }
                } else {
                    queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
					queueRecord.Core_Retry_Count__c = retryCount;
					failedRecords.put(queueRecord.Id, queueRecord);//new
                }
            } catch (Exception e) {
                queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
                queueRecord.Core_Retry_Count__c = retryCount;
                failedRecords.put(queueRecord.Id, queueRecord);
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'execute',
                    'Error processing queue record ' + queueRecord.Id + ': ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), queueRecord.Id);
            } finally {
                UCD_ACM_Logger.setLogDetails();
            }

            recordsToUpdate.add(queueRecord);
        }

        if (!integrationInboundMsgToInsert.isEmpty()) {
            Database.SaveResult[] inboundResults = Database.insert(integrationInboundMsgToInsert, false);
            handleInboundInsertResults(inboundResults, integrationInboundMsgToInsert);
        }

        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(recordsToUpdate, false);
            handleQueueUpdateResults(updateResults, recordsToUpdate);
        }
    }

    public void finish(Database.BatchableContext context) {
        if (retryCount < Core_ACM_Constants.API_MAX_RETRY && !failedRecords.isEmpty()) {
            Core_ACM_AGSAPIBatchProcessor batchProcessor = new Core_ACM_AGSAPIBatchProcessor(failedRecords.keySet(), retryCount);
            Database.executeBatch(batchProcessor, Core_ACM_Constants.API_RETRY_BATCH_SIZE);
        } else if (retryCount > Core_ACM_Constants.API_MAX_RETRY && !failedRecords.isEmpty()) {
            UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'finish',
                'Retry attempts exhausted after ' + retryCount + ' retries. Remaining failed records count: ' + failedRecords.size(), NULL);
        }
    }

    private static void handleInboundInsertResults(Database.SaveResult[] results, List<Core_Integration_Inbound_Message__c> records) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'handleInboundInsertResults',
                    'Failed to insert inbound message for payload: ' + records[i].Core_Payload__c + '. Error: ' + results[i].getErrors(), NULL);
            }
        }
    }

    private static void handleQueueUpdateResults(Database.SaveResult[] results, List<Core_ACM_Integration_Queue__c> records) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'handleQueueUpdateResults',
                    'Failed to update queue record: ' + records[i].Id + '. Error: ' + results[i].getErrors(), records[i].Id);
            }
        }
    }
}