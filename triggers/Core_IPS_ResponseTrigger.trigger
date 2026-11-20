trigger Core_IPS_ResponseTrigger on Core_IPS_Response__c (after insert, after delete, after undelete, after update, before delete, before insert, before update) {

	if(trigger.isBefore){
        Core_IPS_Response_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Response_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }     
}