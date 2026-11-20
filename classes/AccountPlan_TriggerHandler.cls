public class AccountPlan_TriggerHandler extends TriggerHandler {
    
    /*@description : Method to execute the actions in after insert context of AccountPlan_Trigger*/
    public override void afterInsert(){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('EnableAccount360SharingForAccountPlan') &&  mapFunctionalityNameTriggerExecution.get('EnableAccount360SharingForAccountPlan').Core_Active__c){
		   
        AccountPlan_ServiceHandler.account360Sharing((List<Account_Plan__c>) Trigger.NEW);
        }
    }
}