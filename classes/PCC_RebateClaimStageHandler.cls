public with sharing class PCC_RebateClaimStageHandler extends TriggerHandler {
    map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public override void afterInsert(){
        if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaim_TPT_Tracker') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaim_TPT_Tracker').Core_Active__c){       
            TPT_Tracker.CreateUpdateTPTTracker(Trigger.new);
        }
    }
    public override void beforeInsert(){
        //PCC_RebateClaimHandler
    }
    
    public override void beforeUpdate(){
        //PCC_RebateClaimHandler
    }
    
    public override void afterUpdate(){
        if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaim_TPT_Tracker') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaim_TPT_Tracker').Core_Active__c){       
            PCC_RebateClaimStageHelper.updateTPTRecords(Trigger.new,(Map<Id,PCC_Rebate_Claim_Stage__c>)Trigger.oldMap);
        }
    }
}