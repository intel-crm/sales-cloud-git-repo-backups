trigger PRIDTrigger on price_prid__c (before insert,after insert, after update, before update) {
    new PRIDTriggerHandler().run();
}