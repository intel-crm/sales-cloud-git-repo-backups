trigger Core_IPS_Environment_Variables on Core_IPS_Environment_Variables__c(after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_Environment_Variables_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_Environment_Variables_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}