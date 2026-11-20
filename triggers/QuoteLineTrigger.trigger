trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert,after insert, after update,before update) {
    new QuoteLineTriggerHandler().run();
}