trigger Core_MDF_Claim_OffsetTrigger on Core_MDF_Claim_Offset__c (before insert,before update,after insert,after update) {
    Core_MDF_Claim_OffsetTriggerHandler handlerObject = new Core_MDF_Claim_OffsetTriggerHandler();
    handlerObject.run(); 
}