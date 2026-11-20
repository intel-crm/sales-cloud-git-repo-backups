public class Core_Acct_erpm_eng_TriggerHandler  extends TriggerHandler{
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    Map<Id, Core_Account_ERPM_Engagement__c> newMap = (Map<Id, Core_Account_ERPM_Engagement__c>) Trigger.newMap;         
    Map<Id, Core_Account_ERPM_Engagement__c> oldMap = (Map<Id, Core_Account_ERPM_Engagement__c>) Trigger.oldMap;
    
    public override void afterInsert(){
        if(mapFunctionalityNameTriggerExecution.containsKey('erpm_acc_handler') && 
           mapFunctionalityNameTriggerExecution.get('erpm_acc_handler').Core_Active__c){
               PMP_Acc_ERPM_Eng_TriggerActions.onAfterInsert(Trigger.new, newMap);
           }        
    }
    
    public override void afterUpdate(){
        
        if(mapFunctionalityNameTriggerExecution.containsKey('erpm_acc_handler') && 
           mapFunctionalityNameTriggerExecution.get('erpm_acc_handler').Core_Active__c){
               PMP_Acc_ERPM_Eng_TriggerActions.onAfterUpdate(Trigger.new, newMap);
           }          
    }
    
    public override void afterDelete(){
        if(mapFunctionalityNameTriggerExecution.containsKey('erpm_acc_handler') && 
           mapFunctionalityNameTriggerExecution.get('erpm_acc_handler').Core_Active__c){
               PMP_Acc_ERPM_Eng_TriggerActions.onAfterDelete(Trigger.old, oldMap);
           }        
    }
    
}