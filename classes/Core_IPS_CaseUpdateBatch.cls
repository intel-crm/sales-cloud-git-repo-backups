/***************************************************************************************************
* Class Name          : Core_IPS_CaseUpdateBatch
* Version             : 1.0 
*Description          : Batch Class to Mass Update Cases
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Amritesh                    10/19/2018              Created US194563
****************************************************************************************************/       
global class Core_IPS_CaseUpdateBatch implements Database.Batchable<sObject> {
    
    global enum batchMode{
        ManagerUpdate  //update owner manager on cases based on change in user record
    }
    global batchMode mode;
    
    global Core_IPS_CaseUpdateBatch(batchMode mode){
        this.mode = mode;        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        if(mode==batchMode.ManagerUpdate) {
            
            Map<String, Core_IPS_User_Manager_Tracker__c> mapManagerTracker = Core_IPS_User_Manager_Tracker__c.getAll();
            if(mapManagerTracker==null) mapManagerTracker = new Map<String, Core_IPS_User_Manager_Tracker__c>();
            
            Set<String> setUserId = new Set<String>();
            
            for(Core_IPS_User_Manager_Tracker__c objUMT : mapManagerTracker.values()) {
                setUserId.add(objUMT.Name);
            }
            
            Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,ManagerId,Manager.ManagerId FROM User WHERE Id IN :setUserId OR ManagerId IN :setUserId]);            
            Set<Id> setUser = mapUser.keySet();
            query = 'SELECT Id,OwnerId,Core_IPS_Owner_Manager__c,Core_IPS_Owner_2nd_Manager__c FROM Case WHERE RecordType.Name LIKE \'IPS%\' AND OwnerId IN :setUser AND Status IN (\'New\',\'Open\') ORDER BY OwnerId';
        }
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> lstCase2Update = new List<Case>();
        
        //update the owner's manager in cases if user manager are changed
        if(mode==batchMode.ManagerUpdate) {
        
            Set<String> setUserId = new Set<String>();
            for(Case objCase : scope) {
                setUserId.add(objCase.OwnerId);
            }            
            Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,ManagerId,Manager.ManagerId FROM User WHERE Id IN :setUserId]);            
            
            for(Case objCase : scope) {
                if(!mapUser.containsKey(objCase.OwnerId)) continue;
                Boolean doAdd = false;
                if(objCase.Core_IPS_Owner_Manager__c != mapUser.get(objCase.OwnerId).ManagerId) {
                    objCase.Core_IPS_Owner_Manager__c = mapUser.get(objCase.OwnerId).ManagerId;
                    doAdd = true;
                }
                if(objCase.Core_IPS_Owner_2nd_Manager__c != mapUser.get(objCase.OwnerId).Manager.ManagerId) {
                    objCase.Core_IPS_Owner_2nd_Manager__c = mapUser.get(objCase.OwnerId).Manager.ManagerId;
                    doAdd = true;
                }
                if(doAdd) lstCase2Update.add(objCase);
            }
            if(lstCase2Update.size()>0) {
                Core_CaseTrigger_Dispatcher.recursivetrigger1 = false; // case trigger will not be executed
                Database.SaveResult[] lstSaveResult = Database.update(lstCase2Update, false);
                
                Set<Id> successId = new Set<Id>();
                Set<Id> failedId = new Set<Id>();
                for(Database.SaveResult objSR : lstSaveResult) {
                    if(objSR.isSuccess()) successId.add(objSR.getId());
                    else failedId.add(objSR.getId());
                }

                Map<Id,Case> mapCase = new Map<Id,Case>(lstCase2Update);
                Set<String> successOwnerId = new Set<String>();
                Set<String> failedOwnerId = new Set<String>();
                for(Case objCase : lstCase2Update) {
                    if(successId.contains(objCase.Id)) successOwnerId.add(objCase.OwnerId);
                    else if(failedId.contains(objCase.Id)) failedOwnerId.add(objCase.OwnerId);
                }
                successOwnerId.removeAll(failedOwnerId);
                Map<String, Core_IPS_User_Manager_Tracker__c> mapManagerTracker = Core_IPS_User_Manager_Tracker__c.getAll();
                if(mapManagerTracker!=null && mapManagerTracker.size()>0) {
                    List<Core_IPS_User_Manager_Tracker__c> lst2Delete = new List<Core_IPS_User_Manager_Tracker__c>();
                    for(Core_IPS_User_Manager_Tracker__c objUMT : mapManagerTracker.values()) {
                        if(successOwnerId.contains(objUMT.Name))
                            lst2Delete.add(objUMT);
                    }
                    if(lst2Delete.size()>0) Database.delete(lst2Delete,false);
                }
            }
        }
        /*else {
            if(lstCase2Update.size()>0) {
                Core_CaseTrigger_Dispatcher.recursivetrigger1=false; // case trigger will not be executed
                Database.update(lstCase2Update, false);
            }
        }*/
        
    }    
    
    global void finish(Database.BatchableContext BC){
        //Delete 15 days old logs
        Map<String, Core_IPS_User_Manager_Tracker__c> mapManagerTracker = Core_IPS_User_Manager_Tracker__c.getAll();
        if(mapManagerTracker!=null && mapManagerTracker.size()>0) {
            List<Core_IPS_User_Manager_Tracker__c> lst2Delete = new List<Core_IPS_User_Manager_Tracker__c>();
            for(Core_IPS_User_Manager_Tracker__c objUMT : mapManagerTracker.values()) {
                if(objUMT.CreatedDate < Date.Today().addDays(-16))
                    lst2Delete.add(objUMT);
            }
            if(lst2Delete.size()>0) Database.delete(lst2Delete,false);
        }
        
    }
    
}