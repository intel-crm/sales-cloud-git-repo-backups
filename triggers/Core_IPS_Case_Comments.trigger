trigger Core_IPS_Case_Comments on Core_IPS_Case_Comments__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){
        Core_IPS_Case_Comments_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Case_Comments_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }

}