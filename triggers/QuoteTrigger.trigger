trigger QuoteTrigger on SBQQ__Quote__c (before insert,after insert, after update, before update) {
   
   new QuoteTriggerHandler().run();
 
}