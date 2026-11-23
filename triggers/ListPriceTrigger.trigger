trigger ListPriceTrigger on core_cpq_list_price__c (before insert,after insert, after update, before update) {
    new ListPriceTriggerHandler().run();
}