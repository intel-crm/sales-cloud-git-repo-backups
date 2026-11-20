global class Core_IPS_RemovePSO_Batch implements Database.Batchable<sObject> {
    public set<id>caseids ;
    // public list<case>lstcases ;
    public Core_IPS_RemovePSO_Batch(set<id> caseids) {
         // this.lstcases = cslst;
            this.caseids = caseids;
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select id,Core_IPS_Partner_Sup_Owner__c,Status from case WHERE ID IN :caseids');
       
       
    }
    global void execute(Database.BatchableContext BC, List<case> scope) {
    
        list<case> caseListToUpdate = new list <case>();
       // scope = [select id,Core_IPS_Partner_Sup_Owner__c from case where id=:caseids];
        for(case cs : scope){
            if(cs.Core_IPS_Partner_Sup_Owner__c!=null){
                cs.Core_IPS_Partner_Sup_Owner__c=null;
               caseListToUpdate.add(cs);
            }
        }
    Update caseListToUpdate;
    }        
    global void finish(Database.BatchableContext BC){
    
    }
}