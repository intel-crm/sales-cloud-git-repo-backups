trigger Core_ProductAccess_Product on Core_IPS_MAP_Product__c (after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_ProductAccess_Product_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_ProductAccess_Product_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }   
}