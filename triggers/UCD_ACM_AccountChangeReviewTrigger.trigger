trigger UCD_ACM_AccountChangeReviewTrigger on ACM_Account_Change_Review__e (after insert) {
    UCD_AccountChangeReviewTriggerHandler.createAccountChangeReviewRecords(trigger.new);   
}