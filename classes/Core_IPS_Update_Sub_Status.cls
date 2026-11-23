global class Core_IPS_Update_Sub_Status implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Status,Core_Sub_Status__c,RecordType.Name FROM Case WHERE Status = \'Closed\' AND Core_Sub_Status__c = \'Investigating\' AND RecordType.Name = \'IPS Closed Case\''; 
        return Database.getQueryLocator(query);

    }
     
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        
        for(Case cs : caseList) {        
            cs.Core_Sub_Status__c = 'Closed';
        }
        try {
            update caseList;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
    }
}