public with sharing class PRM_CimDupErrorUtility {
    
    public static boolean isFirstRunCheck = true;
    
    public static void dupCheck(List<PRM_Registration_Request__c> regReqList,Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        Set<Id> accIdSet = new Set<Id>();
        string oldStatus = '';
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c> ();
        //Map<Id,PRM_Registration_Request__c> regMapOld = new Map<Id,PRM_Registration_Request__c>();
        For(PRM_Registration_Request__c req : regReqList){
            if(oldRegReqMap!=null && oldRegReqMap.size()>0){
                PRM_Registration_Request__c regListOld;
                regListOld = (PRM_Registration_Request__c) oldRegReqMap.get(req.id) ;
                oldStatus = regListOld.PRM_Dup_Status__c;}
            if((oldRegReqMap==null && req.PRM_Dup_Status__c == 'ERROR') || (oldRegReqMap != null && req.PRM_Dup_Status__c != oldStatus ) ) {
                regList.add(req);
                accIdSet.add(req.PRM_Salesforce_ID__c);
            }
        }        
        if(!regList.IsEmpty()){
        PRM_CimDupErrorUtility.cimDupStatusUpdate(regList,oldRegReqMap);         
        }
    }
    public static void cimDupStatusUpdate(List<PRM_Registration_Request__c> regReqList,Map<Id,PRM_Registration_Request__c> oldMap)
    {
        /*List<PRM_Registration_Request__c> cimCheckList = new List<PRM_Registration_Request__c>() ;
        Map<id,PRM_Registration_Request__c> regMap = new Map<id,PRM_Registration_Request__c>() ;
        Map<id,PRM_Registration_Request__c> regMapOld = new Map<id,PRM_Registration_Request__c>() ;
        Map<id,PRM_Registration_Request__c> RegMapInsertMonitorNew = new Map<id,PRM_Registration_Request__c>() ;
        Map<id,PRM_Registration_Request__c> RegMapError = new Map<id,PRM_Registration_Request__c>() ;
        Map<id,PRM_Registration_Request__c> RegMapNoError = new Map<id,PRM_Registration_Request__c>() ;*/
        set<string> regIds = new set<string>();
        Map<id,Monitor_Log__c> regFromMonitor = new Map<id,Monitor_Log__c>();
        List<Monitor_Log__c> listToUpsertMonitor = new List<Monitor_Log__c>() ;   
        string oldStatus = '' ;
        set<id> accIdSet = new set<id>();      
        for(PRM_Registration_Request__c regList:regReqList) {
            regIds.add(regList.id);
            accIdSet.add(regList.PRM_Salesforce_ID__c);
        }
        if(!regIds.IsEmpty()){
            for(Monitor_Log__c log : [select id, Name, Account_ID__c, Integration_Type__c,New_Registration__c from Monitor_Log__c where New_Registration__c in: regIds and Integration_Type__c = 'CIM Dup Failure' ]){
                regFromMonitor.put(log.New_Registration__c,log); 
            }
        }
        for(PRM_Registration_Request__c regList:regReqList) {
            PRM_Registration_Request__c regListOld ; //getting old values from map
            if(oldMap!=null && oldMap.size()>0){
                regListOld = (PRM_Registration_Request__c) oldMap.get(regList.id) ;
                oldStatus = regListOld.PRM_Dup_Status__c;}
            if((oldMap==null && regList.PRM_Dup_Status__c == 'ERROR') || (oldMap != null && regList.PRM_Dup_Status__c != oldStatus && regList.PRM_Dup_Status__c == 'ERROR')){
                
                if(!regFromMonitor.containskey(regList.id)  ){
                    Monitor_Log__c log = new  Monitor_Log__c() ;
                    log.Account_ID__c = regList.PRM_Salesforce_ID__c;
                    log.Integration_Type__c = 'CIM Dup Failure';
                    log.Status__c  = 'Completed' ;
                    log.Error_Message__c  = 'Error in CIM Dup' ;                    
                    log.New_Registration__c = regList.Id ;
                    listToUpsertMonitor.add(log);
                }
            }
            if(oldMap != null && regList.PRM_Dup_Status__c != oldStatus  && regList.PRM_Dup_Status__c != 'ERROR'){
                if(regFromMonitor.containskey(regList.id) ){
                    Monitor_Log__c log = new  Monitor_Log__c() ;
                    log.id = regFromMonitor.get(regList.id).id;
                    log.Account_ID__c = regList.PRM_Salesforce_ID__c;
                    log.Integration_Type__c = 'CIM Dup Failure';
                    log.Status__c  = 'Reprocessed' ;
                    log.Error_Message__c  = ' ' ;                    
                    log.New_Registration__c = regList.Id ;
                    listToUpsertMonitor.add(log);
                }
            }            
        }
        if(!listToUpsertMonitor.IsEmpty()){
            upsert listToUpsertMonitor;
        }
    }        
}