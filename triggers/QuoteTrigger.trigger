trigger QuoteTrigger on SBQQ__Quote__c (before insert,after insert, after update, before update) {
   new QuoteTriggerHandler().run();
   
  /*  if(Trigger.isAfter)
   {
       if(Trigger.isUpdate)
       {
           Core_updateRiskStatusApprover.psgquoteline(Trigger.new);
       }
   }*/
}