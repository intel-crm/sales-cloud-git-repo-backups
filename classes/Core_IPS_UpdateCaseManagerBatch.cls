public class Core_IPS_UpdateCaseManagerBatch implements Database.Batchable<sObject>{

    public List<Core_IPS_User_Manager_Tracker__c> start(Database.BatchableContext BC) {
        //return Database.getQueryLocator(query);
        Map<String, Core_IPS_User_Manager_Tracker__c> mapManagerTracker = Core_IPS_User_Manager_Tracker__c.getAll();
        if(mapManagerTracker!=null && mapManagerTracker.size()>0)
            return mapManagerTracker.values();
        else return null;
    }
    
    public void execute(Database.BatchableContext BC, List<Core_IPS_User_Manager_Tracker__c> scope) {
        
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
    
}