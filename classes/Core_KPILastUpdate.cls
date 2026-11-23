public class Core_KPILastUpdate implements Queueable {    
    private List<Opportunity> OppList = new List<Opportunity>();   
    List<String> oppId = new List<String>();
    public Core_KPILastUpdate(List<Opportunity> recordstoInsert,List<String> oppids) {
        OppList = recordstoInsert;
        oppId = oppids;
    }
    
    public void execute(QueueableContext queCont) {
        update OppList; 
        System.enqueueJob(new Core_OpportunityJSON(oppId));
    } 
}