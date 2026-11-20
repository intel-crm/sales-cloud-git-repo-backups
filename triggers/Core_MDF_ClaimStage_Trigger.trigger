trigger Core_MDF_ClaimStage_Trigger on Core_MDF_Claim_Batch_Stage__c (before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete) 
{                                                                            
    Core_MDF_ClaimStage_TriggerHandler handlerObject = new Core_MDF_ClaimStage_TriggerHandler();
    handlerObject.run();
 
}