public without sharing class Core_MDF_Bulkupsert_Batch implements Database.Batchable<sObject>{
    
    Public Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    Public List<sObject> sObjectList = new List<sObject>();
    
    public Core_MDF_Bulkupsert_Batch(List<sObject> objList){
		this.sObjectList = objList;
    }  
    
    public Iterable<sObject> start(Database.BatchableContext batchableContext){
        return sObjectList;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> sObjectList){
        Map<string,List<string>> recordIdToErrorsMap = new Map<string,List<string>>();
        if(!sObjectList.isEmpty()){
            try{
                Database.upsertResult[] saveList = Database.upsert(sObjectList,false); 
                for (Database.upsertResult sr : saveList) {
                    if (sr.isSuccess()) {} else {List<string> errorMsgs = new List<string>();for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage(); errorMsgs.add(errorMsg);recordIdToErrorsMap.put(sr.getId(),errorMsgs);}
                    } 
                }
            }catch(Exception ex){ 
                recordIdToErrorsMap.put('Exception: Core_MDF_BulkDML_Batch',new List<string>{ex.getMessage()});
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
            if(recordIdToErrorsMap != null && !recordIdToErrorsMap.values().isEmpty()){Map<String, String> coreLogMap = new Map<String, String>();coreLogMap.put('Core_Origin__c','Core_MDF_BulkDML_Batch');coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);coreLogMap.put('Core_Severity__c','Critical');coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');Integer strLength = JSON.serialize(recordIdToErrorsMap).length();string details;coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(recordIdToErrorsMap.keySet()));details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(recordIdToErrorsMap) : JSON.serialize(recordIdToErrorsMap).substring(0,LONG_TEXT_AREA_LIMIT);coreLogMap.put('Core_Details__c',details);string logRecordId = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
                }
        }
    }
    
    public void finish(Database.BatchableContext batchableContext){
    }
}