trigger PMP_OfferingTrigger on PMP_Partner_Offering__c (before insert,before update,after update, after insert) {
    
    if (Trigger.isInsert && Trigger.isBefore) {
    System.debug('Before Insert Trigger');
    }
    if (Trigger.isInsert && Trigger.isAfter) {
        System.debug('After Insert Trigger');
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        System.debug('Before Update Trigger');
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('After Update Trigger');
    }
    //new PMP_OfferingTriggerHandler().run();
}