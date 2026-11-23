trigger Core_MDF_Scorecard on Core_MDF_Scorecard__c (before update, after update,after insert) {
    new Core_MDF_Scorecard_TriggerHandler().run();
}