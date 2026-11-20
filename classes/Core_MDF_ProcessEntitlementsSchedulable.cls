public without sharing class Core_MDF_ProcessEntitlementsSchedulable implements Schedulable{
    public void execute(SchedulableContext sc)
    {
        Map<String,Core_Trigger_Executions__c> customSettingsMap = Core_Trigger_Executions__c.getAll();
        
        if(customSettingsMap.containsKey('Core_MDF_ProcessEntitlementsFlag') && 
           customSettingsMap.get('Core_MDF_ProcessEntitlementsFlag').Core_Active__c){
            Core_MDF_ProcessEntitlements batch = new Core_MDF_ProcessEntitlements();
            Database.executeBatch(batch, 100);
        }
    }
}