trigger Core_TopicAssignmentTrigger on TopicAssignment (before insert,before update,after update, after insert,after Delete) {
    // new Core_TopicAssignmentHandler().run(); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
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
    if (Trigger.isDelete && Trigger.isAfter) {
        System.debug('After Delete Trigger');
    }
}