global class Core_IPS_BES_UpdateCaseBatch implements Database.Batchable<sObject> {
    public List<Case> caseData;
    public Core_IPS_BES_UpdateCaseBatch(List<Case> Data) {
        caseData = Data;
    }

    global List<case> start(Database.BatchableContext BC ) {
        return caseData;
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        // TWC745-9175 - Exceptional Handling - Phani Adding try catch
        try{ 
            update scope;
        }
        catch (Exception ex) {
            System.debug('Unexpected Error: ' + ex.getMessage());
        }
        // TWC745-9175 - Exceptional Handling - Phani End
    }

    global void finish(Database.BatchableContext BC) {
       
    }
}