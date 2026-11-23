//Roshan - TWC3117-19133
trigger Core_MDF_SuperClaimStatusSync on Core_MDF_SuperClaim_Status_Sync__e (after insert) {
    Core_MDF_ProcessCCP_Claim.processSuperClaimStatusSyncEvents(Trigger.new);
}