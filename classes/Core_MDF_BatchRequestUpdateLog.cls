public without sharing class Core_MDF_BatchRequestUpdateLog implements Database.Batchable<sObject>, Database.Stateful {
    
    Id recordTypeId;
    String recordTypeDevName;
    String action;
    Integer queryLimit;
    List<Id> logRecordIds;
    String objectApiName;
    String transactionUUID;
    String combinedErrorMsg = '';
    
    Integer successCount = 0;
    Integer errorCount = 0;
    List<String> errorMessages = new List<String>();

    public static Map<String, Map<String, Schema.SObjectField>> describeFieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();
    
    public Core_MDF_BatchRequestUpdateLog(List<Id> logRecordIds, Id recordTypeId, String objectApiName, String action, Integer queryLimit) {
        this.logRecordIds = logRecordIds;
        this.recordTypeId = recordTypeId;
        this.objectApiName = objectApiName;
        this.transactionUUID = String.valueOf(UUID.randomUUID()); // generate random UUID for current transaction
        this.action = action;
        this.queryLimit = queryLimit;
    }
    public Core_MDF_BatchRequestUpdateLog(String recordTypeDevName, String objectApiName, String action, Integer queryLimit) {
        this.recordTypeDevName = recordTypeDevName;
        this.objectApiName = objectApiName;
        this.action = action;
        this.queryLimit = queryLimit;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {String query = 'SELECT Id, Core_MDF_JSON_String_txt__c, Core_MDF_Object_apiName_nm__c, Core_MDF_Action_txt__c FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Core_MDF_Status__c = \'Pending\' ';
        if (logRecordIds != null && !logRecordIds.isEmpty()) {
            query += 'AND Id IN :logRecordIds ';
        }
        query += (action != null) ? 'AND Core_MDF_Action_txt__c = :action ' : 'AND Core_MDF_Action_txt__c = null ';
        if (recordTypeDevName != null) {
            query += 'AND RecordType.DeveloperName =:recordTypeDevName ';
        }else if (recordTypeId != null) {
            query += 'AND RecordTypeId =:recordTypeId ';
        }
        if (queryLimit != null && queryLimit > 0) {
        	query += 'LIMIT ' + queryLimit;
    	}                                                              
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Core_MDF_Batch_Request_and_Update_Log__c> scope) {
        
        List<Core_MDF_Batch_Request_and_Update_Log__c> logsToUpdate = new List<Core_MDF_Batch_Request_and_Update_Log__c>();
        Map<Id, Core_MDF_Batch_Request_and_Update_Log__c> logMap = new Map<Id, Core_MDF_Batch_Request_and_Update_Log__c>();
        List<SObject> recordsToUpdate = new List<SObject>();
        Map<Id, List<SObject>> insertRecordsMap = new Map<Id, List<SObject>>();
        Map<Id, Core_MDF_Batch_Request_and_Update_Log__c> insertLogsMap = new Map<Id, Core_MDF_Batch_Request_and_Update_Log__c>();
        List<Core_MDF_Batch_Request_and_Update_Log__c> insertLogs = new List<Core_MDF_Batch_Request_and_Update_Log__c>();
        Map<String, Id> requestKeyToLogMap = new Map<String, Id>();

        Map<String, Schema.SObjectType> objectTypeMap = Schema.getGlobalDescribe();

        for (Core_MDF_Batch_Request_and_Update_Log__c logRecord : scope) {
            logRecord.Core_MDF_Status__c = 'In Progress';
            logsToUpdate.add(logRecord);
        }
        update logsToUpdate;
        
        for (Core_MDF_Batch_Request_and_Update_Log__c logRecord : scope) {
            String sObjectName = logRecord.Core_MDF_Object_apiName_nm__c;
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(logRecord.Core_MDF_JSON_String_txt__c);
            if (action == 'Insert') {
                List<SObject> sObjectList = new List<SObject>();
                if (objectTypeMap.containsKey(sObjectName) && parsedJson.containsKey(sObjectName)) {
                    Schema.SObjectType sObjType = objectTypeMap.get(sObjectName);
                    List<Object> recordsList = (List<Object>) parsedJson.get(sObjectName);

                    for (Object recordData : recordsList) {
                        Map<String, Object> fieldMap = (Map<String, Object>) recordData;
                        SObject sObj = sObjType.newSObject(); 
                        for (String fieldName : fieldMap.keySet()) {
                            sObj.put(fieldName, fieldMap.get(fieldName));
                        }
                        sObjectList.add(sObj);
                        requestKeyToLogMap.put(safeKey(sObj), logRecord.Id);
                    }
                    insertRecordsMap.put(logRecord.Id, sObjectList);
                    insertLogsMap.put(logRecord.Id, logRecord);
                }
            } else {
                Id recordId = (Id) parsedJson.get('Id');
                SObject sObj = objectTypeMap.get(sObjectName).newSObject(recordId);

                for (String key : parsedJson.keySet()) {
                    if (key == 'Id') continue;
                    sObj.put(key, parsedJson.get(key));  // Id = 0RBDz0000009S8fOAE, OwnerId = 0051J000006CtIJQA0
                }
                recordsToUpdate.add(sObj);
                logMap.put(recordId, logRecord);  // key = claim id; related log record object as value where status will be inprogress 
            }            
        }
        
        // Update Logic
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(recordsToUpdate, false);
            List<Core_MDF_Batch_Request_and_Update_Log__c> postUpdateLogs = new List<Core_MDF_Batch_Request_and_Update_Log__c>();
            
            for (Integer i = 0; i < results.size(); i++) {
                Id recId = recordsToUpdate[i].Id;  // claim id
                Core_MDF_Batch_Request_and_Update_Log__c logRec = logMap.get(recId);  // log object related to the claim record
                
                if (results[i].isSuccess()) {
                    successCount++;
                    logRec.Core_MDF_Status__c = 'Completed';
                } else {
                    errorCount++;
                    logRec.Core_MDF_Status__c = 'Failed';
                    String errMsg = 'Error updating record: ' + recId + ': ';
                    for (Database.Error err : results[i].getErrors()) {
                        errMsg += err.getMessage() + '; ';
                        logRec.Core_MDF_Error_Message_txt__c = err.getMessage();
                    }
                    errorMessages.add(errMsg);
                    combinedErrorMsg += errMsg;  // yet to test 
                }
                postUpdateLogs.add(logRec);
            }
            update postUpdateLogs;
            
            if (errorCount > 0) {
                system.debug('combinedErrorMsg@@@' + combinedErrorMsg);
                //ATHR Avoid long parameter lists BY Anjali US- 15023
            // Create a map to hold all parameters
    Map<String, Object> parameterMap = new Map<String, Object>();
    
    // Add all parameters to the map
    parameterMap.put('exception', new DmlException(combinedErrorMsg));
    parameterMap.put('severity', 'Critical');
    parameterMap.put('projectName', 'CCP');
    parameterMap.put('objectName', 'objectApiName');
    parameterMap.put('operation', 'transactionUUID');
    parameterMap.put('additionalInfo', null);
    
    // Call the method with the parameter map
    Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(parameterMap);

            
           // Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',projectName,objectName,'Mass Access Ownership Transfer',null); 
     //END ATHR Avoid long Parameters  
                //Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(new DmlException(combinedErrorMsg), 'Critical', 'CCP', objectApiName, transactionUUID, null);
            }
        }
        
        // Insert Logic
        if (!insertRecordsMap.isEmpty()) {
            List<SObject> allRecords = new List<SObject>();
            for (List<SObject> sharelist : insertRecordsMap.values()) {
                allRecords.addAll(sharelist);
            }
            
            Set<String> insertedKeysSet = new Set<String>();
            Map<Id, String> logErrors = new Map<Id, String>();
            List<Database.SaveResult> insertResults = Database.insert(allRecords, false);
            
            for (Integer i = 0; i < insertResults.size(); i++) {
                SObject insertedRec = allRecords[i];
                String uniqueKey = safeKey(insertedRec);
                
                Id logId = requestKeyToLogMap.containsKey(uniqueKey) ? requestKeyToLogMap.get(uniqueKey) : null;
                
                if (insertResults[i].isSuccess()) {
                    insertedKeysSet.add(uniqueKey);
                } else {
                    String fullErrorMsg = 'Failed Insert for Key: ' + uniqueKey + ' => ';
                    for (Database.Error err : insertResults[i].getErrors()) {
                        fullErrorMsg += err.getMessage() + '; ';                        
                    }
                    if (logId != null) {
                        logErrors.put(logId, logErrors.containsKey(logId) ? logErrors.get(logId) + fullErrorMsg : fullErrorMsg);
                    }
                }
            }

            for (Id logId : insertRecordsMap.keySet()) {
                Core_MDF_Batch_Request_and_Update_Log__c logRecord = insertLogsMap.get(logId);
                Boolean isFailed = false;                
                for (SObject sr : insertRecordsMap.get(logId)) {
                    if (!insertedKeysSet.contains(safeKey(sr))) {
                        isFailed = true;
                        break;
                    }
                }
                logRecord.Core_MDF_Status__c = isFailed ? 'Failed' : 'Completed';
                if (isFailed && logErrors.containsKey(logId)) {
                    logRecord.Core_MDF_Error_Message_txt__c = logErrors.get(logId);
                }
                insertLogs.add(logRecord);
            }
            update insertLogs;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        if (action == 'Update') {
            String subject = 'Mass Owner Update Batch Completion for ' + objectApiName;
            String emailBody = 'Dear Requester,\n\n';
            emailBody += 'Your request for Mass Owner Update is completed with the following results:\n\n';
            emailBody += 'Successful Updates: ' + successCount + '\n';
            emailBody += 'Failed Updates: ' + errorCount + '\n\n';
            if (!errorMessages.isEmpty()) {
                emailBody += 'Error tag: ' + transactionUUID + '\n\n';
            }
            emailBody += 'Please check the logs for complete details.\n\nThanks,\n';
            emailBody += Label.Core_MDF_Email_Signature;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
            email.setSubject(subject);
            email.setPlainTextBody(emailBody);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }
    
    // Dynamic safeKey based on common fields
    public static String safeKey(SObject record) {
        String sObjName = String.valueOf(record.getSObjectType());
        if (!describeFieldMapCache.containsKey(sObjName)) {
            describeFieldMapCache.put(sObjName, record.getSObjectType().getDescribe().fields.getMap());
        }
        Map<String, Schema.SObjectField> fieldMap = describeFieldMapCache.get(sObjName);
        
        String parentId      = fieldMap.containsKey('ParentId') && record.get('ParentId') != null ? String.valueOf(record.get('ParentId')) : 'null';
        String userOrGroupId = fieldMap.containsKey('UserOrGroupId') && record.get('UserOrGroupId') != null ? String.valueOf(record.get('UserOrGroupId')) : 'null';
        String rowCause      = fieldMap.containsKey('RowCause') && record.get('RowCause') != null ? String.valueOf(record.get('RowCause')) : 'null';
        String accessLevel   = fieldMap.containsKey('AccessLevel') && record.get('AccessLevel') != null ? String.valueOf(record.get('AccessLevel')) : 'null';
        
        return parentId + '-' + userOrGroupId + '-' + rowCause + '-' + accessLevel;
    }
}