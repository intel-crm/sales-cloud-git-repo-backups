trigger PCC_RebateClaimStageTrigger on PCC_Rebate_Claim_Stage__c (after insert,after update) {
   new  PCC_RebateClaimStageHandler().run();
}