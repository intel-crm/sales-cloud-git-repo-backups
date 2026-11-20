trigger Core_IPS_OrgAdmin_Trigger on Core_IPS_Product_Organization_Admin__c (before insert, before update, before delete, after insert, after update, after delete) {
   
    if(trigger.isAfter && trigger.isUpdate){
       Core_IPS_OrgAdminTrigger_Dispatcher.afterMethod(trigger.new, trigger.oldMap);
    }

}