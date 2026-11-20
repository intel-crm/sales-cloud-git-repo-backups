trigger Core_Master_Issue_Category on Core_IPS_Master_Issue_Category__c (after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_Master_Issue_Category_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_Master_Issue_Category_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}