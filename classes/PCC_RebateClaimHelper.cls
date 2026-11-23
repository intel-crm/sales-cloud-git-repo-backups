public class PCC_RebateClaimHelper extends TriggerHandler {
    map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public override void beforeInsert(){ 
        //PCC_RebateClaimHandler
    }
    
    public override void beforeUpdate(){
        if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaimupdatePaymentstatus') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaimupdatePaymentstatus').Core_Active__c){
        //PCC_RebateClaimHandler_2.UpdatePaymentProcessedStatus(Trigger.New);  
        }
    }
    
    public override void afterInsert(){
       //PCC_RebateClaimHandler
    }
    
    public override void afterUpdate(){
      	//PCC_RebateClaimHandler
      	 if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaimAddToQueue') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaimAddToQueue').Core_Active__c){       
            //PCC_RebateClaimHandler_2.AddRebateClaimToApprovalQueue(Trigger.New,(Map<Id,PCC_Rebate_Claim__c>)Trigger.OldMap);
        }
        if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaimPaymentProcessed') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaimPaymentProcessed').Core_Active__c){       
              // PCC_RebateClaimHandler_2.SendPaymentProcessedEmailNoty(Trigger.New,(Map<Id,PCC_Rebate_Claim__c>)Trigger.OldMap);
		}
        if (mapFunctionalityNameTriggerExecution.containsKey('PCC_RebateClaim_TPT_Tracker') && mapFunctionalityNameTriggerExecution.get('PCC_RebateClaim_TPT_Tracker').Core_Active__c){       
            TPT_Tracker.updateTPTTracker(Trigger.new, (Map<Id,PCC_Rebate_Claim__c>)Trigger.oldMap);
        }
    }
}