public with sharing class PCC_ChangeRequestPostApprovalQeueable implements Queueable {
    Id quoteId;
    Boolean rollbackMode = false;
    public PCC_ChangeRequestPostApprovalQeueable(Id quoteId, Boolean rollbackMode) {
        this.quoteId = quoteId;
        this.rollbackMode = rollbackMode;
    }
    
    public void execute(QueueableContext qc){
        PCC_ChangeRequestPostApproval.changeRequestPostApproval(quoteId);
    }
}