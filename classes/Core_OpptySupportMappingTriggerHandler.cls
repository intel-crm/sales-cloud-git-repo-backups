public without sharing class Core_OpptySupportMappingTriggerHandler extends TriggerHandler {
    //Implemented switch logic as part of TWC4767-4953
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void beforeInsert() { 
        if(mapFunctionalityNameTriggerExecution.containsKey('checkDuplicateOSM') && mapFunctionalityNameTriggerExecution.get('checkDuplicateOSM').Core_Active__c){
            Core_OpptyMappingSupportServiceHandler.determinecountofAprovers(Trigger.new);
        }   
    } 
    public override void beforeUpdate() { 
        if(mapFunctionalityNameTriggerExecution.containsKey('checkDuplicateOSM') && mapFunctionalityNameTriggerExecution.get('checkDuplicateOSM').Core_Active__c){
            Core_OpptyMappingSupportServiceHandler.determinecountofAprovers(Trigger.new);
        }     
    }  
}