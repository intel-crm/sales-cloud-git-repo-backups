trigger Core_CIM_Stage on Core_CIM_Staging__c (after Insert) {

    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter){
        if(trigger.isInsert){
            if(mapFunctionalityNameTriggerExecution.containsKey('xmlAttachNParse') && mapFunctionalityNameTriggerExecution.get('xmlAttachNParse').Core_Active__c){
                Core_CIMIntegrationHandler.xmlAttachNParse(trigger.new[0]);
            }
            
        }
    }
}