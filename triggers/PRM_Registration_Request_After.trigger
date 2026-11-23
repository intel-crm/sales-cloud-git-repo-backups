trigger PRM_Registration_Request_After on PRM_Registration_Request__c (after insert, after update) {
    PRMRegistrationRequestTriggerHandler.handleAfter(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
}