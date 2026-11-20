public class Core_MDF_Batch_ShareRecordInsert implements Database.Batchable<sObject> {
    List<sObject> shareRecList = new List<sObject>();
    public Core_MDF_Batch_ShareRecordInsert(List<sObject> shareRecList){
        this.shareRecList = shareRecList;
    }
    
    public  Iterable<sObject> start(Database.BatchableContext bContext) {
        
        return shareRecList;
    }
    
    public void execute(Database.BatchableContext bContext, List<sObject> shareRecords) {//log entries
        database.insert(shareRecords);
    }
    
    public void finish(Database.BatchableContext bContext) {
        
    }

}