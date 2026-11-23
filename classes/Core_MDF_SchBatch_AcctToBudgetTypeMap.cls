global without sharing class Core_MDF_SchBatch_AcctToBudgetTypeMap implements Schedulable {

    global void execute(SchedulableContext sc) 
    {
        //omarketing recordvtype with last modified as 3 days or acctbenfit modified
        string query ='select Id,Core_MDF_CoMarketing_Ultimate_Account__c from Account';  
        system.debug('query' + query);
        Core_MDF_Batch_AcctToBudgetTypeMap batch = new Core_MDF_Batch_AcctToBudgetTypeMap();
        batch.queryActive = query;
        Database.executeBatch(batch, 200);
     }
}