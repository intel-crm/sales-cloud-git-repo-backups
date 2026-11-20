trigger Core_PSG_Product_Staging on Core_PIR_Ext_Attributes__c (after insert, after update) {


    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
           // if(mapFunctionalityNameTriggerExecution.containsKey('xmlAttachNParse') && mapFunctionalityNameTriggerExecution.get('xmlAttachNParse').Core_Active__c){
                //Core_PSGProductIntegrationHandler.handleLoad(trigger.new);
           // }
            
        }
    }
}