trigger Core_IPS_Opportunity_PAR_Trigger on Core_IPS_Opportunity_PAR__c(before insert, before update, after insert, after update) {
   
    if(trigger.isbefore && Trigger.isUpdate){  
            Core_IPS_Opportunity_PAR_Dispatcher.beforeMethod(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
    }
    if(trigger.isafter && Trigger.isUpdate){  
            Core_IPS_Opportunity_PAR_Dispatcher.afterMethod(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
    }
}