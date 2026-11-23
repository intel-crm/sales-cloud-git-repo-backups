trigger Core_MDF_Partnership_Score_Detail  on Core_MDF_Partnership_Score_Detail__c (after insert) {
new Core_MDF_PS_Detail_TriggerHandler().run();
}