trigger PMP_OfferingTrigger on PMP_Partner_Offering__c (before insert,before update,after update, after insert) {
    new PMP_OfferingTriggerHandler().run();
}