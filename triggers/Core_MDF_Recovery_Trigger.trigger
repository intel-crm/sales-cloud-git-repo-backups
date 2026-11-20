trigger Core_MDF_Recovery_Trigger on Core_MDF_Recovery__c (before insert, after insert) {
new Core_MDF_ClaimRecovery_TriggerHandler().run();
}