trigger PMP_Offering_Resouce_Trigger on PMP_Partner_Offering_Resource__c (after insert,after update,after delete) {

    new PMP_OfferingResourceTriggerHandler().run();
    
}