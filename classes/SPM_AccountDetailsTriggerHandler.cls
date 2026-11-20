public class SPM_AccountDetailsTriggerHandler extends TriggerHandler{
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void afterInsert(){
        if( mapFunctionalityNameTriggerExecution.containsKey('shareNewAccountDetails') && mapFunctionalityNameTriggerExecution.get('shareNewAccountDetails').Core_Active__c)
            SPM_AccountDetailsTriggerServicehandler.shareAccoutndetails(Trigger.new);
    }
   
}