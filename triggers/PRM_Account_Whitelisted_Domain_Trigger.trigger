trigger PRM_Account_Whitelisted_Domain_Trigger on Core_Account_Whitelisted_Domains__c (before insert, before update,after insert, after update) {
    new PRM_Whitelisted_Domain_TriggerHandler().run();
}