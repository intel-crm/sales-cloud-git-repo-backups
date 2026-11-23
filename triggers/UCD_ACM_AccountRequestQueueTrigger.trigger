trigger UCD_ACM_AccountRequestQueueTrigger on Account_Create_Request__c (before update,after update,before insert) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            UCD_ACM_AccountReqQueueTriggerHandler.checkForDuplicate(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            if(Test.isRunningTest() || (mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c)){
                UCD_ACM_AccountReqQueueTriggerHandler.processAccountRequestQueueAfterUpdate(Trigger.new,Trigger.oldMap);
           }

           //TWC729-6912 : non ipa inbound Start
           //PRM_AccountChangeEventSubscriber.opidAssociationForNonIpaIntelAccount(Trigger.new,Trigger.oldMap);
           //TWC729-6912 : non ipa inbound End
        }
    }
}