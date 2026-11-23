trigger complianceWatchListTrigger on Core_Account_Compliance_Watch_List__c (after insert,after update) {
    if(Label.PerformScreeningFromCWLObject == 'true'){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if((mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c) || Test.isRunningTest()){
            UCD_ACM_CompWatchListTriggerHandler.triggerPlatformEventOnInsert(Trigger.operationType, Trigger.new,Trigger.oldMap);
        }
    }
}