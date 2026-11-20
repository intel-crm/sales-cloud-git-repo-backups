trigger Core_Product_Access  on Core_IPS_MAP_PAR__c(after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_Product_Access_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_Product_Access_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}