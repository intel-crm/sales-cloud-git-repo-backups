trigger Core_IPS_Outbound_Message on Core_IPS_BES_Outbound_Message__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore){
        Core_IPS_Outbound_Message_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_IPS_Outbound_Message_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }  
        
}