public class Sales_ProcessDML_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private Map<Id, String> failedrecordMap;
    private List<sObject> records;
    private String className;
    private String methodName;
    private String errorLogMsg;
    
    
    public Sales_ProcessDML_Batch(List<sObject> records,String className, String methodName, String errorLogMsg) {
        this.records = records;     
        this.className = className;
        this.methodName = methodName;
        this.errorLogMsg = errorLogMsg;
        this.failedrecordMap = new Map<Id, String>();
    }
    
    
    public Iterable<sObject> start(Database.BatchableContext BC) {     
        return records;
    }
    
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (!scope.isEmpty()) {            
            try {
                List<Database.SaveResult> result = Database.update(scope, false);  
                for (Integer i = 0; i < result.size(); i++) {
                    Database.SaveResult sr = result[i];
                    if (!sr.isSuccess()) {
                        String msg = PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                        failedrecordMap.put(sr.getId(), msg);
                    }
                }
            } catch (Exception ex) {                
                PSG_Utility.createCoreLogEntry(className, methodName, errorLogMsg, ex.getMessage(), '', 'High', '');
            }
        }
    }
    
    
    public void finish(Database.BatchableContext BC) {
        if (!failedrecordMap.isEmpty()) {
            PSG_Utility.createCoreLogEntry(className, methodName, errorLogMsg, '' + failedrecordMap, '', 'Medium', '');
        }
    }
}