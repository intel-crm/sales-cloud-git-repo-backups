trigger ReltioSyncAccount on Account (after delete, after insert, after update, before delete, before insert, before update)  { 
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_EnableReltioSync') && 
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_EnableReltioSync').Core_Active__c) {
        //rtsync.TriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        Core_AccountTriggerHandlerController.triggerReltioSync(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}