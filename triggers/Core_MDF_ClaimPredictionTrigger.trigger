trigger Core_MDF_ClaimPredictionTrigger on Core_MDF_Claim_Prediction__c (before insert, before update, after insert, after update) {
        new Core_MDF_ClaimPredictionTriggerHandler().run();
}