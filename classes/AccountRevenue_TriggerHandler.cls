public class AccountRevenue_TriggerHandler extends TriggerHandler {
    
    /*@description : Method to execute the actions in after insert context of AccountRevenue_Trigger*/
    public override void afterInsert(){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('EnableAccount360SharingForAccountRev') &&  mapFunctionalityNameTriggerExecution.get('EnableAccount360SharingForAccountRev').Core_Active__c){
           
        AccountRevenue_ServiceHandler.account360Sharing((List<Account_Revenue__c>) Trigger.NEW);
        }
    }

}