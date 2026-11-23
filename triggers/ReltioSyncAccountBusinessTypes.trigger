trigger ReltioSyncAccountBusinessTypes on Account_Business_Types__c (after delete, after insert, after update, before delete, before insert, before update)  
{ 
    //rtsync.TriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_EnableReltioSync') && 
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_EnableReltioSync').Core_Active__c){
            UCD_ACM_AccountBusinessTypeHandler.triggerReltioSync(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    
}