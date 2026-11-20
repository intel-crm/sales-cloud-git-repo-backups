trigger Core_CustomAccountTeamTrigger on Core_Account_Team__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){
        Core_IPS_CustomAccountTeam_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_CustomAccountTeam_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}