trigger Core_IPS_Core_QuestionTrigger on Core_IPS_Question__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(trigger.isBefore){
        Core_IPS_Core_Question_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Core_Question_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}