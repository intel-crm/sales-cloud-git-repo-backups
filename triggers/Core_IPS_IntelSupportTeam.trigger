trigger Core_IPS_IntelSupportTeam on Core_IPS_Intel_Support_Team__c (before insert,after insert,before update,after update,before delete,after delete) {
if(trigger.isBefore){
        Core_IPS_IntelSupportTeam_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_IntelSupportTeam_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }    
}