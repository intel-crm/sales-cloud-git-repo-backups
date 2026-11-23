trigger complianceWatchListTrigger on Core_Account_Compliance_Watch_List__c (after insert,after update) {
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){
        UCD_ACM_CompWatchListTriggerHandler.triggerPlatformEventOnInsert(Trigger.operationType, Trigger.new,Trigger.oldMap);
       }
    
    if(mapFunctionalityNameTriggerExecution.containsKey('CompListAcct') && 
        mapFunctionalityNameTriggerExecution.get('CompListAcct').Core_Active__c){
            UCD_ACM_CompWatchListTriggerHandler.updateCompWatchListOnAcc(Trigger.new);
        }
}