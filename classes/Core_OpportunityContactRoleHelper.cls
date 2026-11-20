public class Core_OpportunityContactRoleHelper extends TriggerHandler {
    map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void beforeInsert(){
        //For PCC Oppty, Lock the Opportunity when related Quote's any Quote Line Item is in PFIR status - TWC3123-5659- Devashish
        if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') &&
            mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c)
        {
            Core_OpportunityContactRoleHandler.checkPCCLockOnOppty(Trigger.new);
        }
        if (mapFunctionalityNameTriggerExecution.containsKey('checkPrimaryContactRole') && mapFunctionalityNameTriggerExecution.get('checkPrimaryContactRole').Core_Active__c) {
            Core_OpportunityContactRoleHandler.checkPrimaryContactRole(Trigger.new,true);
        }
    }
    
    public override void beforeUpdate(){
        //For PCC Oppty, Lock the Opportunity when related Quote's any Quote Line Item is in PFIR status - TWC3123-5659- Devashish
        if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') &&
            mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c)
        {
            Core_OpportunityContactRoleHandler.checkPCCLockOnOppty(Trigger.new);
        }
        if (mapFunctionalityNameTriggerExecution.containsKey('checkPrimaryContactRole') && mapFunctionalityNameTriggerExecution.get('checkPrimaryContactRole').Core_Active__c) {
            Core_OpportunityContactRoleHandler.checkPrimaryContactRole(Trigger.new,false);
        }
    }
}