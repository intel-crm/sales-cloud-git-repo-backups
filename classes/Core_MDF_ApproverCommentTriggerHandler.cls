public class Core_MDF_ApproverCommentTriggerHandler extends TriggerHandler{
    
    public override void afterInsert() {
        
    	Core_MDF_ApproverCommentServiceHandler.updateApproverComment(Trigger.New);    
    } 

}