trigger Product_InboundStagingTrigger on Product_Inbound_Staging__c (before insert, before update) {
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if (trigger.isInsert && trigger.isBefore) {
        if (mapFunctionalityNameTriggerExecution.containsKey('PopulateMMattributesFields') && mapFunctionalityNameTriggerExecution.get('PopulateMMattributesFields').Core_Active__c) {
            Product_InboundStagingTriggerHelper.populateMMattributesFields(trigger.new);
        }    
    }
}