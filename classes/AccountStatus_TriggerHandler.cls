public class AccountStatus_TriggerHandler extends TriggerHandler {
    
    /*@description : Method to execute the actions in after insert context of AccountStatus_Trigger*/
    public override void afterInsert(){
         Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('EnableAcc360SharingForAccountStatus') &&  mapFunctionalityNameTriggerExecution.get('EnableAcc360SharingForAccountStatus').Core_Active__c)
        {   
        	AccountStatus_ServiceHandler.account360Sharing((List<Account_Status__c>) Trigger.NEW);
        }
    }

}