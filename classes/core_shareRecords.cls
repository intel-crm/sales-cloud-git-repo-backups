public class core_shareRecords implements Queueable {
    
     public List<OpportunityShare> oppshare = new List<OpportunityShare>();
    
    
    public core_shareRecords(List<OpportunityShare> opidshare){
        this.oppshare = opidshare;
    }
    public void execute(QueueableContext context){
        if(oppshare.size() > 0)
            insert oppshare;
    }

}