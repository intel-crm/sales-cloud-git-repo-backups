public without sharing class Core_ACM_ERPMAPIBatchProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private static final Integer RETRY_DELAY_MINUTES = 3;
    private String processType;
    Map<Id,Core_ACM_Integration_Queue__c> failedRecords = new Map<Id,Core_ACM_Integration_Queue__c>();
    Set<Id> recordIdsToProcess = new Set<Id>();
    private Integer retryCount;

    public Core_ACM_ERPMAPIBatchProcessor() {
        this.processType = Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE);
        this.retryCount = 0;
    }

    public Core_ACM_ERPMAPIBatchProcessor(String processType) {
        this.processType = String.isBlank(processType)
            ? Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE)
            : processType;
        this.retryCount = 0;
    }

    public Core_ACM_ERPMAPIBatchProcessor(Set<Id> failedRecordsId, Integer retryCount) {
        this.recordIdsToProcess = failedRecordsId;
        this.retryCount = retryCount + 1;
    }

    public Core_ACM_ERPMAPIBatchProcessor(Set<Id> queueRecordIds, String processType) {
        this.recordIdsToProcess = queueRecordIds;
        this.processType = String.isBlank(processType)
            ? Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE)
            : processType;
        this.retryCount = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = Core_ACM_QueryFactory.getQuery(recordIdsToProcess, processType);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Core_ACM_Integration_Queue__c> scope) {
        List<Core_ACM_Integration_Queue__c> recordsToUpdate = new List<Core_ACM_Integration_Queue__c>();
        List<Core_Integration_Inbound_Message__c> integrationInboundMsgToInsert = new List<Core_Integration_Inbound_Message__c>();

        for (Core_ACM_Integration_Queue__c queueRecord : scope) {
            String responseBodyJson;
            Core_ACM_PayloadWrapper.ResponseWrapper responseBody;
            try {
                responseBodyJson = Core_ACM_CalloutService.executeAPICall(queueRecord, Core_ACM_Constants.SOURCE_ERPM);
                System.debug('API Response Body Json@: ' + responseBodyJson);
                if (responseBodyJson != null) {
                    responseBody = (Core_ACM_PayloadWrapper.ResponseWrapper) System.Json.deserialize(responseBodyJson, Core_ACM_PayloadWrapper.ResponseWrapper.class);
                }
                System.debug('API Response Body12: ' + responseBody);
                if (responseBody != null) {
                    System.debug('API Response Body: ' + responseBody);
                    if (responseBody.Status == Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.SUCCESS_STATUS)) {
                        integrationInboundMsgToInsert.add(createSuccessMessage(responseBodyJson));
                        queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.SUCCESS_STATUS);
                        queueRecord.Core_Retry_Count__c = retryCount;
                    } else {
                        if (isFinalRetry()) {
                            integrationInboundMsgToInsert.add(createFailureMessage(responseBody, responseBodyJson));
                        }
                        queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
                        queueRecord.Core_Retry_Count__c = retryCount;
                        failedRecords.put(queueRecord.Id, queueRecord);
                    }
                } else {
                    queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
                    queueRecord.Core_Retry_Count__c = retryCount;
                    failedRecords.put(queueRecord.Id, queueRecord);
                }
            } catch (Exception e) {
                queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS);
                queueRecord.Core_Retry_Count__c = retryCount;
                failedRecords.put(queueRecord.Id, queueRecord);
                if (isFinalRetry() && responseBodyJson != null) {
                    integrationInboundMsgToInsert.add(createFailureMessage(responseBody, responseBodyJson));
                }
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

    private Boolean isFinalRetry() {
        return retryCount >= Core_ACM_Constants.API_MAX_RETRY;
    }

    public void finish(Database.BatchableContext context) {
        if (!failedRecords.isEmpty()) {
            if (retryCount < Core_ACM_Constants.API_MAX_RETRY) {
                Core_ACM_ERPMAPIBatchProcessor batchProcessor = new Core_ACM_ERPMAPIBatchProcessor(failedRecords.keySet(), retryCount);
                String jobName = 'Core_ACM_ERPM_Retry_' + String.valueOf(System.now().getTime());
                System.scheduleBatch(batchProcessor, jobName, RETRY_DELAY_MINUTES, Core_ACM_Constants.API_RETRY_BATCH_SIZE);
            } else {
                updateContactsAsFailed();
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_BATCH_PROCESSOR, 'finish',
                    'Retry attempts exhausted after ' + retryCount + ' retries. Remaining failed records count: ' + failedRecords.size(), NULL);
            }
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

    private static Core_Integration_Inbound_Message__c createSuccessMessage(String responseJson) {
        Core_Integration_Inbound_Message__c inboundMsg = new Core_Integration_Inbound_Message__c();
        inboundMsg.Core_Source_System__c = Core_ACM_Constants.SOURCE_ERPM;
        inboundMsg.Core_Processing_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.PENDING_STATUS);
        inboundMsg.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX;
        inboundMsg.Core_Payload__c = responseJson;
        return inboundMsg;
    }

    private static Core_Integration_Inbound_Message__c createFailureMessage(Core_ACM_PayloadWrapper.ResponseWrapper response, String responseJson) {
        Core_Integration_Inbound_Message__c inboundMsg = new Core_Integration_Inbound_Message__c();
        inboundMsg.Core_Payload__c = responseJson;
        inboundMsg.Core_Processing_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.PENDING_STATUS);
        inboundMsg.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX;
        if (response != null) {
            inboundMsg.Core_Error_Code__c = response.ErrorCode;
            inboundMsg.Core_Error_Description__c = response.ErrorDetails;
        }
        inboundMsg.Core_Source_System__c = Core_ACM_Constants.SOURCE_ERPM;
        return inboundMsg;
    }

    private void updateContactsAsFailed() {
        Set<Id> contactIds = new Set<Id>();

        for (Core_ACM_Integration_Queue__c queueRec : failedRecords.values()) {
            if (queueRec.Core_Contact__c!= null) {
                contactIds.add(queueRec.Core_Contact__c);
            }
        }

        if (contactIds.isEmpty()) {
            return;
        }

        List<Contact> contactsToUpdate = [
            SELECT Id, Core_ERPM_Integration_Status__c
            FROM Contact
            WHERE Id IN :contactIds
        ];

        for (Contact con : contactsToUpdate) {
            con.Core_ERPM_Integration_Status__c = 'Failed';
        }

        update contactsToUpdate;
    }
}