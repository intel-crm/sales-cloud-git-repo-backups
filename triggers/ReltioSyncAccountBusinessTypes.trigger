trigger ReltioSyncAccountBusinessTypes on Account_Business_Types__c (after delete, after insert, after update, before delete, before insert, before update)  
{ 

    //rtsync.TriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_EnableReltioSync') && 
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_EnableReltioSync').Core_Active__c){
            UCD_ACM_AccountBusinessTypeHandler.triggerReltioSync(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){
            UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnInsert(Trigger.operationType,Trigger.new,Trigger.oldMap);
            //UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnUpdate(Trigger.operationType,Trigger.new,Trigger.oldMap);
            //UCD_ACM_AccountBusinessTypeHandler.triggerAccountCPECheck(Trigger.operationType,Trigger.new,Trigger.oldMap);
            //UCD_ACM_AccountBusinessTypeHandler.addCpeOnInsert(Trigger.operationType,Trigger.new);
        }
    }


}