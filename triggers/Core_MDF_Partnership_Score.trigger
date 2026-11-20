trigger Core_MDF_Partnership_Score on Core_MDF_Partnership_Score__c (before insert,before update,after insert,after update) {
new Core_MDF_Partnership_ScoreTriggerHandler().run();
}