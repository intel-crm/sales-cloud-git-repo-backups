/********************************************************************************************************************************************************************
Apex Class Name:  Core_CommissionableTransactions_Batch
Version     : 1.0 
Created Date: 03/05/2023  
Function    : Process the pending Opportunity KPI

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Biswa               		03/05/2023               Original Version
*******************************************************************************************************************************************************************/
global without sharing class Core_CommissionableTransactions_Batch implements Database.Batchable<sObject> {
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        //Query all KPI records which are not processed
        String query = 'SELECT ID, Core_KPI_Opportunity__c, NAME, CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C,CORE_KPI_TOTAL_PRICE__C,Core_IsActive__c,Core_KPI_Achieved__c,Core_IsKPI_Processed__c FROM Core_Oppty_KPI_New__c WHERE Core_IsKPI_Processed__c = FALSE ORDER BY Core_KPI_Opportunity__c desc,CreatedDate desc';
        try{            
            return Database.getQueryLocator(query);
        }catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Message__c = e.getMessage(), Core_Severity__c = 'Info', Core_Origin__c='Core_CommissionableTransactions_Batch', Core_When__c = System.now(), Core_Project__c = 'Sales'));     
            insert captureQueryErr;         
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set < ID > oppIdSetToProcess = new Set < ID > ();
        Map < ID, String > oppWithLatestTimeStamp = new Map < ID, String > ();
        List < CORE_OPPTY_KPI_NEW__C > KPIDtlsToProcess = NEW List < CORE_OPPTY_KPI_NEW__C >();
        List < CORE_OPPTY_KPI_NEW__C > KPIDtlsNotProcessed = NEW List < CORE_OPPTY_KPI_NEW__C >();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        try {
            for (sObject record : scope) {
                oppIdSetToProcess.add((Id)record.get('Core_KPI_Opportunity__c'));                
            }
            
            for (Opportunity latestOppKPI: [SELECT id,(select id,Core_Batch_Time__c from KPI_Opportunity__r where Core_Batch_Time__c <> null order by createdDate DESC,Core_Batch_Time__c DESC LIMIT 1) 
                                              from Opportunity where id IN: oppIdSetToProcess
                                             ]) {
                                                if(!oppWithLatestTimeStamp.containsKey(latestOppKPI.Id)){
                                                   oppWithLatestTimeStamp.put(latestOppKPI.Id, String.valueOf(latestOppKPI.KPI_Opportunity__r[0].Core_Batch_Time__c)); 
                                                }
                                             }
            List < CORE_OPPTY_KPI_NEW__C > KPIToProcess = [SELECT ID, Core_KPI_Opportunity__c, NAME, CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C,
                                                      CORE_KPI_TOTAL_PRICE__C,Core_IsActive__c,Core_KPI_Achieved__c,Core_IsKPI_Processed__c,Core_Batch_Time__c,Core_KPI_Quantity__c FROM Core_Oppty_KPI_New__c 
                                                      WHERE Core_KPI_Opportunity__c IN: oppIdSetToProcess AND Core_IsKPI_Processed__c = FALSE AND Core_Batch_Time__c <> null ORDER BY Core_KPI_Opportunity__c DESC,createdDate DESC,Core_Batch_Time__c DESC];
            //system.debug('###oppWithLatestTimeStamp: '+oppWithLatestTimeStamp);
            //system.debug('###KPIToProcess: '+KPIToProcess.size());
            for(CORE_OPPTY_KPI_NEW__C kpiDtl: KPIToProcess){
                String latestTimeStamp = String.valueOf(kpiDtl.Core_Batch_Time__c);
                if(oppWithLatestTimeStamp.get(kpiDtl.Core_KPI_Opportunity__c).contains(latestTimeStamp)){
                    KPIDtlsToProcess.add(kpiDtl);
                }
                else{
                    KPIDtlsNotProcessed.add(kpiDtl);
                }
            }
            //system.debug('###KPIDtlsToProcess: '+KPIDtlsToProcess.size());
            //system.debug('###KPIDtlsNotProcessed: '+KPIDtlsNotProcessed.size());
            if(KPIDtlsToProcess.size() > 0){
                srList = Core_CommissionableTransactions.addCommissionableTransactionsFromKPI(null,KPIDtlsToProcess,true,false);
            }
            if(!srList.isEmpty()){
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess() || Test.isRunningTest()){
                        String errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Core_CommissionableTransactions_Batch_Insert_Error', Core_Severity__c = 'Info', Core_Origin__c='Core_CommissionableTransactions_Batch', Core_When__c = System.now()));   
                    }
                }
                if(!captureQueryErr.isEmpty()){
                    insert captureQueryErr;
                }
            }
            if(KPIDtlsNotProcessed.size()>0){
                Core_CommissionableTransactions.updateKPIProcessFlag(KPIDtlsNotProcessed);
            }
        }Catch(Exception ex) {
            Core_Log_Entry__c log = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'CommissionCreation', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:'+ex.getLineNumber()+', Stack trace: '+ex.getStackTraceString());
			insert log;
        }        
    }
    
    global void finish(database.BatchableContext bc) {
        
    }
}