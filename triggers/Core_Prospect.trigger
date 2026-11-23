trigger Core_Prospect on Core_Prospect__c (before insert,before update) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            if (mapFunctionalityNameTriggerExecution.containsKey('prospectObjectBeforeHandler') &&
                mapFunctionalityNameTriggerExecution.get('prospectObjectBeforeHandler').Core_Active__c){
                    Core_ProspectHandler.prospectObjectBeforeHandler(Trigger.new, Trigger.oldmap);
                }
        }
    }
}