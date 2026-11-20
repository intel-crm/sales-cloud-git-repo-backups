trigger Core_IPS_CaseOwnerGroupTrigger on Core_IPS_Case_Owner_Group__c (before insert, before update, before delete) {
    
    if(trigger.isBefore){
        Core_IPS_CaseOwnerGroup_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    
}