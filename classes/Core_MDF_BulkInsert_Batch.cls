public without sharing class Core_MDF_BulkInsert_Batch implements Database.Batchable<sObject>{
    
    Public Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    Public List<sObject> sObjectList = new List<sObject>();
    
    public Core_MDF_BulkInsert_Batch(List<sObject> objList){
		this.sObjectList = objList;
    }  
    
    public Iterable<sObject> start(Database.BatchableContext batchableContext){
        return sObjectList;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> sObjectList){
        List<string> dmlErrorList = new List<string>();
        if(!sObjectList.isEmpty()){
            try{
                Database.SaveResult[] saveList = Database.insert(sObjectList,false); 
                for (Database.SaveResult sr : saveList) {
                    if (sr.isSuccess()) {} else {for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage(); dmlErrorList.add(errorMsg);}
                    } 
                }
            }catch(Exception ex){ 
                dmlErrorList.add(ex.getMessage());
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
            if(dmlErrorList != null && !dmlErrorList.isEmpty()){Map<String, String> coreLogMap = new Map<String, String>();coreLogMap.put('Core_Origin__c','Core_MDF_BulkDML_Batch');coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);coreLogMap.put('Core_Severity__c','Critical');coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');Integer strLength = JSON.serialize(dmlErrorList).length();string details;coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(dmlErrorList));details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(dmlErrorList) : JSON.serialize(dmlErrorList).substring(0,LONG_TEXT_AREA_LIMIT);coreLogMap.put('Core_Details__c',details);string logRecordId = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
                }
        }
    }
    
    public void finish(Database.BatchableContext batchableContext){
    }
}