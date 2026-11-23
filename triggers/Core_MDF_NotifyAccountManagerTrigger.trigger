trigger Core_MDF_NotifyAccountManagerTrigger on Core_MDF_Notify_Account_Manager__e (after insert) {
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_EscalationErrorsNotification') &&
       mapFunctionalityNameTriggerExecution.get('Core_MDF_EscalationErrorsNotification').Core_Active__c){
    		Core_MDF_SendEmailHelper.sendEmail(Trigger.New);       
       }
    
}