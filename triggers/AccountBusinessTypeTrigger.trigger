trigger AccountBusinessTypeTrigger on Account_Business_Types__c (after insert,after update) {
//     Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
//     if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
//        mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){
//             UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnInsert(Trigger.operationType,Trigger.new,Trigger.oldMap);
//             //UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnUpdate(Trigger.operationType,Trigger.new,Trigger.oldMap);
//             //UCD_ACM_AccountBusinessTypeHandler.triggerAccountCPECheck(Trigger.operationType,Trigger.new,Trigger.oldMap);
//             //UCD_ACM_AccountBusinessTypeHandler.addCpeOnInsert(Trigger.operationType,Trigger.new);
//        }
}