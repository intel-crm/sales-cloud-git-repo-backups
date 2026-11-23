public class Core_MDF_Batch_GenericShare implements Database.Batchable<SObject> {
    public List<SObject> shareRecordList;
    public string dmlMode = 'insert';
    public boolean allOrNone = false;

    public Core_MDF_Batch_GenericShare(List<SObject> shareRecordList) {
        this.shareRecordList = shareRecordList;
    }
    public Core_MDF_Batch_GenericShare(List<SObject> shareRecordList,String dmlMode,boolean allOrNone) {
        this.shareRecordList = shareRecordList;
        this.dmlMode = dmlMode;
        if(!String.isBlank(dmlMode) && !String.isEmpty(dmlMode)){this.dmlMode = dmlMode.toLowercase(); }              
        this.allOrNone = allOrNone;       
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        return shareRecordList;
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordsToInsertList) {
        try {
            switch on this.dmlMode{
                when 'insert'{Database.insert(recordsToInsertList, this.allOrNone);}
                when 'update'{Database.update(recordsToInsertList, this.allOrNone);}
                when 'upsert'{Database.upsert(recordsToInsertList, this.allOrNone);}  
                when else{Database.insert(recordsToInsertList, this.allOrNone);}
            }
        } catch (DmlException e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}