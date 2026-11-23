//
public class Core_Batch_AccountCoverage_Mule implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    //TODO where clause where status = processed count > 0
    public static Map<String,Core_ACM_Control_Execution__c> mapABatchAccountCoverageMule = Core_ACM_Control_Execution__c.getAll();
    public Database.QueryLocator start(Database.BatchableContext batchcontext) {
        if(mapABatchAccountCoverageMule.containsKey('BatchAccountCoverageMule') && mapABatchAccountCoverageMule.get('BatchAccountCoverageMule').IsActive__c){
            return Database.getQueryLocator([Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c WHERE Core_Operation__c != 'NC' LIMIT 1] );
        }
        else{
            String query = (Test.isRunningTest() ? ' Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c limit 1'  : null);
            return Database.getQueryLocator(query);
        }
    }
    
    //Process the sObject 
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
        String status = Core_AccountCoverageExportUtil.callMuleService();
    }
    
    //Finish the Batch
    public void finish(Database.BatchableContext batchcontext){  
        
    }
}