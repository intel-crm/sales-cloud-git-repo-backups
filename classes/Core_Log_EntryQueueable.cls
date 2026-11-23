public class Core_Log_EntryQueueable implements Queueable {
    public List<Core_Log_Entry__c> logEntries;
    
    public Core_Log_EntryQueueable(List<Core_Log_Entry__c> logEntries) {
        this.logEntries = logEntries;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> existingLogIds = new Set<Id>();
        List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();
        for (Core_Log_Entry__c log : logEntries) {
            if (!existingLogIds.contains(log.Core_XID__c)) {
                existingLogIds.add(log.Core_XID__c);
                logsToInsert.add(log);
            }
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }


}