trigger AccountplanTrigger on Account_Plan__c (after insert,after update) {
    
    map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    if((Trigger.isInsert || Trigger.isUpdate)&&(mapFunctionalityNameTriggerExecution.containsKey('AccountPlanShareBUExecutive') &&
            mapFunctionalityNameTriggerExecution.get('AccountPlanShareBUExecutive').Core_Active__c) ){
        Core_AccountPlanHandler.AccountPlanShareToBuExecutives(Trigger.new);
    }
}