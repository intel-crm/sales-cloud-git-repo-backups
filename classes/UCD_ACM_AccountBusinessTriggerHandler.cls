public without sharing class UCD_ACM_AccountBusinessTriggerHandler extends TriggerHandler{
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public override void afterInsert(){
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
       mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){
            UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnInsert(Trigger.operationType,(List<Account_Business_Types__c>)Trigger.new,(Map<Id,Account_Business_Types__c>)Trigger.oldMap);
            UCD_ACM_AccountBusinessTypeHandler.triggerAccountCPECheckonInsert(Trigger.new);
       }
    }
    public override void afterUpdate(){
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
       mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){
            UCD_ACM_AccountBusinessTypeHandler.triggerPlatformEventOnInsert(Trigger.operationType,(List<Account_Business_Types__c>)Trigger.new,(Map<Id,Account_Business_Types__c>)Trigger.oldMap);
       }
    }
}