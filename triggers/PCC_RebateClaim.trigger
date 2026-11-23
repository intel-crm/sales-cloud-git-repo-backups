trigger PCC_RebateClaim on PCC_Rebate_Claim__c (before insert, before update, after insert, after update) {
    new PCC_RebateClaimHelper().run();
}