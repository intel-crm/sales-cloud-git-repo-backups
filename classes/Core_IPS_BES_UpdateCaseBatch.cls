global class Core_IPS_BES_UpdateCaseBatch implements Database.Batchable<sObject> {
    public List<Case> caseData;
    public Core_IPS_BES_UpdateCaseBatch(List<Case> Data) {
        caseData = Data;
     }

    global List<case> start(Database.BatchableContext BC ) {
        return caseData;
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        update scope;
     }

    global void finish(Database.BatchableContext BC) {
       
    }
}