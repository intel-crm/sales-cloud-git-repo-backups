global class Core_IPS_BES_UpdateCaseBatch implements Database.Batchable<sObject> {
    public List<Case> caseData;
    public Core_IPS_BES_UpdateCaseBatch(List<Case> Data) {
        caseData = Data;
        system.debug('Chiru Batch Data: + ' + Data);
        system.debug('Chiru Batch size: + ' + Data.size());
    }

    global List<case> start(Database.BatchableContext BC ) {
        return caseData;
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        try{
            update scope;
        }
        catch (Exception ex) {
         System.debug('Unexpected Error: ' + ex.getMessage());
     }  

    }

    global void finish(Database.BatchableContext BC) {
       
    }
}