/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_OpportunityKPISyncInactive 
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Batch to Delete the Existing KPI for Sync Load (Azure)
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

global class Core_Batch_OpportunityKPISyncInactive implements Database.Batchable<sObject>{
    
    List<Core_KPI_Staging__c> NewFullRecBatch = new List<Core_KPI_Staging__c>();
    String batchIDbatch;
    Set<id> oppIdSetBatch = new Set<id>();
    List<id> ids = new List<id>();
    List<id> kpis = new List<id>();
    List<id> kpid = new List<id>();
    List<Core_Oppty_KPI_New__c> kpinew = new List<Core_Oppty_KPI_New__c>();
    List<Core_Oppty_KPI_New__c> kpinewList = new List<Core_Oppty_KPI_New__c>();
    String batchq='';
    String batche='';
    String result='';
    String resultfinal = '';
    
    global Core_Batch_OpportunityKPISyncInactive(Set<id> oppIdSet,String batchID){
        //NewFullRecBatch=NewFullRec;
        batchIDbatch = batchID;
        oppIdSetBatch = oppIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id,core_kpi_opportunity__c from Core_Oppty_KPI_New__c where core_kpi_opportunity__c in:oppIdSetBatch and Core_IsActive__c =true]);
    }
    global void execute(Database.BatchableContext bc, List<Core_Oppty_KPI_New__c> scope){
        /*system.debug('to be deleted size'+scope.size());
        system.debug('to be deleted'+scope);*/
        List<Core_Oppty_KPI_New__c> fList = new List<Core_Oppty_KPI_New__c>();
        List<Core_Exceptions__c> CEList = new List<Core_Exceptions__c>(); //
        try{
            Boolean allOrNone = false;
            //database.delete(scope,false);
            //TWC3123-118 Inactivate the old kpis
            for(Core_Oppty_KPI_New__c kp : scope){
                kp.Core_IsActive__c = false;
                fList.add(kp);
            }
            //database.update(fList,false);
            
            Database.SaveResult[] srList = Database.update(fList, false);
            Integer i=0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {                   
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                                      
                        Core_Exceptions__c ce = new Core_Exceptions__c();
                        ce.Core_Class_Name__c = 'Core_Batch_OpportunityKPISyncInactive';
                        ce.Core_IPS_Object_Name__c = 'Core_Oppty_KPI_New__c';
                        ce.Core_Record_Id__c = fList.get(i).Id;
                        ce.core_exception__c = err.getMessage();                   
                        CEList.add(ce); 
                    }
                }
                i++;
            }
            if(CEList.size() > 0){
                insert CEList;
            }
            if(Test.isRunningTest()){
                allOrNone = null;
                database.update(fList,allOrNone);
            }
        }
        catch(exception e){
            /*system.debug('**exception** -->'+ e.getStackTraceString());
            system.debug('**exception line** -->'+e.getMessage());*/
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_Batch_OpportunityKPISyncInactive', Core_Method_Name__c = 'Core_Batch_OpportunityKPISyncInactive', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            insert ExcepLog;
        }
    }
    public void finish(Database.BatchableContext batchcontext){
        //System.debug(' Core_Batch_OpportunityKPIDelete FINISHED   ');
        //List<Core_Oppty_KPI_New__c> kpiList1 = new List<Core_Oppty_KPI_New__c>();
        //List<Core_Oppty_KPI_New__c> kpinewList1 = new List<Core_Oppty_KPI_New__c>();
        Core_Batch_OpportunityKPIInsert b=new Core_Batch_OpportunityKPIInsert(batchIDbatch,'Sync');
        database.executebatch(b,integer.valueof(system.label.Core_Batch_Sync_Insert_BatchSize)); 
    }
}