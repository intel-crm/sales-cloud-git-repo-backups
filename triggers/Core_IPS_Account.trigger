trigger Core_IPS_Account on Core_IPS_Account__c (after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_IPS_Account_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Account_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}