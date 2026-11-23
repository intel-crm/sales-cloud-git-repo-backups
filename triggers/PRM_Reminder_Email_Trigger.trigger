trigger PRM_Reminder_Email_Trigger on PRM_Reminder_Email__c (Before insert,after update) {
system.debug('PRM_Reminder_Email_Trigger entry');
    new PRM_Reminder_Email_TriggerHandler().run();
}