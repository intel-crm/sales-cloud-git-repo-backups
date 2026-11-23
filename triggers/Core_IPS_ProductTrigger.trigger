trigger Core_IPS_ProductTrigger on Core_IPS_Product__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){
        Core_IPS_ProductTrigger_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_ProductTrigger_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}