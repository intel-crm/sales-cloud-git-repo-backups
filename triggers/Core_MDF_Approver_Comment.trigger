trigger Core_MDF_Approver_Comment on Core_MDF_Approver_Comment__e (after insert) {

      new Core_MDF_ApproverCommentTriggerHandler().run(); 
}