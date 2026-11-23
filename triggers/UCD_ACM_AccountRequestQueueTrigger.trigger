trigger UCD_ACM_AccountRequestQueueTrigger on Account_Create_Request__c (after update) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    System.debug('arq trigger strt');
    /*if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c){*/
        UCD_ACM_AccountReqQueueTriggerHandler.triggerPlatformEventOnUpdate(Trigger.new,Trigger.oldMap);
            System.debug('arq trigger handler calling');
      // }

}