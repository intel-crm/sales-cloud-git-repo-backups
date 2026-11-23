trigger DistributorMarginTrigger on core_cpq_distributor_margin__c (before insert,after insert, after update, before update) {
    new DistributorMarginTriggerHandler().run();
}