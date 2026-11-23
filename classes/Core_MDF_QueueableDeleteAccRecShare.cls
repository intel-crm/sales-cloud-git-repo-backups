public class Core_MDF_QueueableDeleteAccRecShare implements Queueable {
    
    List<AccountShare> acctShareListToBeDeleted = new List<AccountShare>();
    public Core_MDF_QueueableDeleteAccRecShare(List<AccountShare> accountShareListToBeDeleted){
        this.acctShareListToBeDeleted = accountShareListToBeDeleted;
    }
    
    public void execute(QueueableContext qc){
        Database.delete(acctShareListToBeDeleted);
    }
}