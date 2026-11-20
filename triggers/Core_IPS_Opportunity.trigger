trigger Core_IPS_Opportunity on Core_IPS_Opportunity__c (after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_IPS_Opportunity_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Opportunity_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}