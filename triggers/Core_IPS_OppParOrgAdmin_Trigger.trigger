trigger Core_IPS_OppParOrgAdmin_Trigger on Core_IPS_Opppar_SuppOrgAdmin__c(before insert, before update, before delete, after insert, after update, after delete) {
   
    if(trigger.isAfter && trigger.isInsert){
       Core_IPS_OppOrgAdmin_Trigger_Dispatcher.afterMethod(trigger.new, trigger.oldMap);
    }

}