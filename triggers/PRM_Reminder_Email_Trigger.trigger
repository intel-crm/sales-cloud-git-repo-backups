trigger PRM_Reminder_Email_Trigger on PRM_Reminder_Email__c (Before insert,after update) {
    system.debug('PRM_Reminder_Email_Trigger entry');
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_Reminder_Email_TriggerHandler().run();
    }
}