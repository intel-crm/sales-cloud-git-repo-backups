/****************************************************************************************************************************************
* Class Name  : Core_MDF_CDB_Utility 
* Version     : 1.0   
* Created Date: 03-01-2026 
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         02-27-2026                 Created Core_MDF_CDB_Utility for Common Utility Methods    
*****************************************************************************************************************************************/
public class Core_MDF_CDB_Utility {

public static Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT; //Citrus Audit    

/***********************************************************************************************************
    Method Name:        sendCDBPayload
    Description:        To send the payload to CDB system
    @Added By:          Sinduja - 02-27-2025
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
    Added By:          Sinduja  - 02-27-2025
    Modified By:        Date:       Changes:
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
            coreLogMap.put('Core_Project__c', 'Consolidated Co-Marketing Program (CCP)');
            coreLogMap.put('Core_Message__c', baseMessageByRecordKeyMap != null ? baseMessageByRecordKeyMap.get(recordIdentifier) : null);
            
            String serialized = JSON.serialize(errorMsgs);
            Integer strLength = serialized.length();
            String details = strLength < LONG_TEXT_AREA_LIMIT ? serialized : serialized.substring(0, LONG_TEXT_AREA_LIMIT);
            coreLogMap.put('Core_Details__c', details);
            coreLogMaps.add(coreLogMap);
        }
        if (!coreLogMaps.isEmpty()) {
           Core_MDF_CCP_UtilityClass.createLogEntries(coreLogMaps);
        }
    }
/***********************************************************************************************************
    Method Name:       createCDBLogInstance
    Description:       Method to create CDB Log Records
    Added By:          Sinduja - 02-27-2025
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
       return logrec;
           
     }
/***********************************************************************************************************
    Method Name:       upsertCDBIntegrationLogList
    Description:       Method to create CDB Log Records
    Added By:          Sinduja - 02-27-2025
    Modified By:        Date:       Changes:
**********************************************************************************************************/
     public static void upsertCDBIntegrationLogList(List<Core_CDB_Integration_Log__c> cdbLogList) {   
    	// Upsert log records if we have any
         Database.UpsertResult[] upsertResultList = Database.upsert(cdbLogList, Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
         
         // Process upsert errors with consolidated logging
         Map<String, List<Database.Error>> recIdKeyToUpsertErrorsMap = new Map<String, List<Database.Error>>();
         Map<String, String> recIdKeyToBaseMessageMap = new Map<String, String>();
         for (Integer i = 0; i < upsertResultList.size(); i++) {
             Database.UpsertResult upsertResult = upsertResultList[i];
             if (!upsertResult.isSuccess()) {
                 String recIdKeyForError = cdbLogList[i].Core_Record_Id__c;
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
    Added By:          Sinduja - 02-27-2025
    Modified By:        Date:       Changes:
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
        Core_MDF_CDB_Utility.collectAndLogDbErrors(keyToUpdateErrors, keyToBaseMessage, objectName);
    }
}
   
}