trigger PMP_Offering_Resouce_Trigger on PMP_Partner_Offering_Resource__c (after insert,after update,after delete) {

    //new PMP_OfferingResourceTriggerHandler().run();
    if (Trigger.isInsert && Trigger.isAfter) {
        System.debug('After Insert Trigger');
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('After Update Trigger');
    }
    if (Trigger.isDelete && Trigger.isAfter) {
        System.debug('After Delete Trigger');
    }
    
}