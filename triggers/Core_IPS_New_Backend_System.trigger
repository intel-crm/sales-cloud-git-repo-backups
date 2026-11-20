trigger Core_IPS_New_Backend_System on Core_IPS_Backend_System2__c ( after update) {
    if(Core_IPS_BES_IPASSTriggerHandler.runOnce()){
        if(Trigger.isafter && Trigger.isUpdate){
          Core_IPS_New_Backend_System_Handler.afterUpdate(trigger.new, trigger.oldmap);    
        }    
    }
}