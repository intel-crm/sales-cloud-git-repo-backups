/****************************************************************************************************************************************
* Class Name  : Pricing_QuoteAgentic_Utility 
* Version     : 1.0   
* Created Date: 04-17-2026
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         Sinduja - 04-17-2026              Created Pricing_QuoteAgentic_Utility for Common Utility Methods   
*****************************************************************************************************************************************/
public class Pricing_QuoteAgentic_Utility {
    public static Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT; 

/***********************************************************************************************************
    Method Name:        sendCDBPayload
    Description:        To send the payload to CDB system
    @Added By:          Sinduja - 04-17-2026
    Modified By:        Date:       Changes:
************************************************************************************************************/
    public static HttpResponse sendCDBPayload(String payload, String namedCredential) {      
       try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:'+ namedCredential);
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(payload);
            HttpResponse resp = new Http().send(req);
            return resp;
        }catch(Exception exp){
            // Return an HttpResponse with Exception message and status code
            HttpResponse errResp = new HttpResponse();
            errResp.setStatusCode(503);
            errResp.setStatus('APEX_EXCEPTION');
            String expnMsg = 'Unhandled CDB callout Apex exception: ' + (exp.getMessage() != null ? exp.getMessage() : '');//always prepend 
            errResp.setBody(expnMsg);
            return errResp;
        }
    }
/***********************************************************************************************************
    Method Name:       collectAndLogDbErrors
    Description:       Method to log database errors from both Insert and Upert operations
    Added By:          Sinduja - 04-17-2026
    Modified By:       Date:       Changes:
**********************************************************************************************************/

     public static void collectAndLogDbErrors( Map<String, List<Database.Error>> errorsByRecordKeyMap,Map<String, String> baseMessageByRecordKeyMap, String sObjectApiName ) {
        if (errorsByRecordKeyMap == null || errorsByRecordKeyMap.isEmpty()) {
            return;
        }
        List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
        for (String recordIdentifier : errorsByRecordKeyMap.keySet()) {
            List<Database.Error> errors = errorsByRecordKeyMap.get(recordIdentifier);
            if (errors == null || errors.isEmpty()) {
                continue;
            }
            List<String> errorMessages = new List<String>();
            for (Database.Error err : errors) {
                String errorMessage = String.valueOf(err.getStatusCode()) + ': ' +
                    String.valueOf(err.getFields()) + ': ' +
                    String.valueOf(err.getMessage());
                errorMessages.add(errorMessage);
            }
            if (errorMessages.isEmpty()) {
                continue;
            }
            List<String> errorMsgs = new List<String>{
                'Record ' + recordIdentifier + ' | ' + String.join(errorMessages, ' | ')
            };
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Origin__c', 'Core_MDF_Audit_AI_Integration');
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_sObjectType__c', sObjectApiName);
            coreLogMap.put('Core_Project__c', 'IQR');
            coreLogMap.put('Core_Message__c', baseMessageByRecordKeyMap != null ? baseMessageByRecordKeyMap.get(recordIdentifier) : null);
            
            String serialized = JSON.serialize(errorMsgs);
            Integer strLength = serialized.length();
            String details = strLength < LONG_TEXT_AREA_LIMIT ? serialized : serialized.substring(0, LONG_TEXT_AREA_LIMIT);
            coreLogMap.put('Core_Details__c', details);
            coreLogMaps.add(coreLogMap);
        }
        if (!coreLogMaps.isEmpty()) {
           	createLogEntries(coreLogMaps);
        }
    }
/***********************************************************************************************************
    Method Name:       createCDBLogInstance
    Description:       Method to create CDB Log Records
    Added By:          Sinduja - 04-17-2026
    Modified By:        Date:       Changes:
**********************************************************************************************************/
     public static Core_CDB_Integration_Log__c createCDBLogInstance(String integrationType,String recId,HttpResponse res,Boolean isSuccess,Integer newRetryCounter) {    
       Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
       logRec.Core_Integration_Type__c = integrationType;
       logRec.Core_Record_Id__c = recId;
       logRec.Core_Log_Status_Nm__c = isSuccess ? 'Successful' : 'Failed';
       logRec.Core_Retry_Number_Nbr__c = newRetryCounter;
       logRec.Core_Status_Code__c = (res != null) ? String.valueOf(res.getStatusCode()) : '';
       logRec.Core_Status_Message__c = (res != null) ? res.getStatus() : '';
       logrec.Core_Integration_Direction_Nm__c ='Outbound';
       system.debug('INSIDE CREATE CDB LOG METHOD:'+logrec);
       return logrec;
           
     }
/***********************************************************************************************************
    Method Name:       upsertCDBIntegrationLogList
    Description:       Method to create CDB Log Records
    Added By:          Sinduja - 04-17-2026
    Modified By:       Date:       Changes:
**********************************************************************************************************/
     public static void upsertCDBIntegrationLogList(List<Core_CDB_Integration_Log__c> cdbLogList) {   
    	// Upsert log records if we have any
    	 system.debug('INSIDE UPSERT CDB METHOD:'+cdbLogList);
         Database.UpsertResult[] upsertResultList = Database.upsert(cdbLogList, Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
         system.debug('UPSERT LIST'+upsertResultList);
         // Process upsert errors with consolidated logging
         Map<String, List<Database.Error>> recIdKeyToUpsertErrorsMap = new Map<String, List<Database.Error>>();
         Map<String, String> recIdKeyToBaseMessageMap = new Map<String, String>();
         for (Integer i = 0; i < upsertResultList.size(); i++) {
             Database.UpsertResult upsertResult = upsertResultList[i];
             if (!upsertResult.isSuccess()) {
                 String recIdKeyForError = cdbLogList[i].Core_Record_Id__c;
                 system.debug('INSIDE UPSERT CDB METHOD ERROR'+recIdKeyForError);
                 List<Database.Error> erros = recIdKeyToUpsertErrorsMap.containsKey(recIdKeyForError) ? recIdKeyToUpsertErrorsMap.get(recIdKeyForError) : new List<Database.Error>();
                 erros.addAll(upsertResult.getErrors());
                 recIdKeyToUpsertErrorsMap.put(recIdKeyForError, erros);
                 recIdKeyToBaseMessageMap.put(recIdKeyForError, 'CDB Integration Log upsert failed for record: ' + recIdKeyForError);
             }
         }
         if (!recIdKeyToUpsertErrorsMap.isEmpty()) {
             collectAndLogDbErrors( recIdKeyToUpsertErrorsMap, recIdKeyToBaseMessageMap,'Core_CDB_Integration_Log__c');
         }
     }
/***********************************************************************************************************
    Method Name:       updateRecordsList
    Description:       Method to update Records
    Added By:          Sinduja - 04-17-2026
    Modified By:       Date:       Changes:
**********************************************************************************************************/
    
public static void updateRecordsList(List<sObject> recordsList, String keyField, String baseErrorMessage, String objectName) {
    if (recordsList == null || recordsList.isEmpty()) {
        return;
    }
    
    Database.SaveResult[] updateResults = Database.update(recordsList, false);
     
    Map<String, List<Database.Error>> keyToUpdateErrors = new Map<String, List<Database.Error>>();
    Map<String, String> keyToBaseMessage = new Map<String, String>();
    
    for (Integer i = 0; i < updateResults.size(); i++) {
        Database.SaveResult updateResult = updateResults[i];
        if (!updateResult.isSuccess()) {
            String keyForError;
            
            // Get the key based on the field specified
            if (keyField == 'Id') {
                keyForError = String.valueOf(recordsList[i].Id);
            } else {
                keyForError = String.valueOf(recordsList[i].get(keyField));
            }
            
            List<Database.Error> updateErrors = keyToUpdateErrors.containsKey(keyForError) ? keyToUpdateErrors.get(keyForError) : new List<Database.Error>();
            updateErrors.addAll(updateResult.getErrors());
            keyToUpdateErrors.put(keyForError, updateErrors);
            keyToBaseMessage.put(keyForError, baseErrorMessage + keyForError);
        }
    }
    
    if (!keyToUpdateErrors.isEmpty()) {
         	collectAndLogDbErrors(keyToUpdateErrors, keyToBaseMessage, objectName);
    }
}
/***********************************************************************************************************
Method Name:        createLogEntries
Description:        Method to create log entries (Bulkified version of createLogEntry)
Added By:           Sinduja - 04-17-2026
Modified By:        Date:       Changes:
**********************************************************************************************************/
    public static void createLogEntries(List<Map<String, String>> coreLogMaps){
       // List<Id> createdIds = new List<Id>();
        try {
            if (coreLogMaps == null || coreLogMaps.isEmpty()) {
                return;
            }
            List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();
            DateTime dtWhen = System.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            
            for (Map<String, String> coreLogMap : coreLogMaps) {
                if (coreLogMap == null || coreLogMap.isEmpty()) continue;
                Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
                for (String key : coreLogMap.keySet()) {
                    if (logFields.containsKey(key)) {
                        Schema.DescribeFieldResult field = logFields.get(key).getDescribe();
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));
                        objCLE.put(key, value != null ? value.left(length) : null);
                    }
                }
                objCLE.put('Core_When__c', dtWhen);
                logsToInsert.add(objCLE);
            }
            if (!logsToInsert.isEmpty()) {
                Database.insert(logsToInsert, false);
            }
        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
 /***********************************************************************************************************
    Method Name:       createBulkCDBLogs
    Description:       Method to create multiple CDB Log Records in bulk
    Added By:          Sinduja - 04-17-2026
    Modified By:        Date:       Changes:
**********************************************************************************************************/
    public static List<Core_CDB_Integration_Log__c> createBulkCDBLogs(String integrationType, List<Id> recordIds, HttpResponse res, Boolean isSuccess, Map<Id,Integer> retryCounterMap) {
        List<Core_CDB_Integration_Log__c> logs = new List<Core_CDB_Integration_Log__c>();
        
        if(recordIds == null || recordIds.isEmpty()) {
            return logs;
        }
        
        // Common values for all logs
        String statusCode = (res != null) ? String.valueOf(res.getStatusCode()) : '';
        String statusMessage = (res != null) ? res.getStatus() : '';
        String logStatus = isSuccess ? 'Successful' : 'Failed';
        
        for(Id recordId : recordIds) {
            Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
            logRec.Core_Integration_Type__c = integrationType;
            logRec.Core_Record_Id__c = String.valueOf(recordId);
            logRec.Core_Log_Status_Nm__c = logStatus;
            logRec.Core_Retry_Number_Nbr__c = retryCounterMap.get(recordId);
            logRec.Core_Status_Code__c = statusCode;
            logRec.Core_Status_Message__c = statusMessage;
            logRec.Core_Integration_Direction_Nm__c = 'Outbound';
            logs.add(logRec);
        }
        
        system.debug('INSIDE CREATE BULK CDB LOG METHOD: ' + logs.size() + ' logs created');
        return logs;
    }

}