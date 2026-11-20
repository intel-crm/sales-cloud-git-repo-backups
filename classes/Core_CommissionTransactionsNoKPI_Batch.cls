/********************************************************************************************************************************************************************
Apex Class Name:  Core_CommissionTransactionsNoKPI_Batch
Version     : 1.0 
Created Date: 03/05/2023  
Function    : Process the pending Opportunity KPI

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Biswa               		07/27/2023               Original Version
*******************************************************************************************************************************************************************/
global without sharing class Core_CommissionTransactionsNoKPI_Batch implements Database.Batchable<sObject> {
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        String dt = System.Label.Core_Commission_No_KPI_Batch_Date;
        String query = 'SELECT Id FROM Opportunity WHERE Id NOT IN (SELECT Core_KPI_Opportunity__c FROM Core_Oppty_KPI_New__c) AND (LastModifiedDate = '+ dt+' OR LastModifiedDate = TODAY) ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set < ID > oppIdSet = new Set < ID > ();
        Set < ID > oppIdSetToProcess = new Set < ID > ();
        try {
            for (sObject record : scope) {
                oppIdSet.add((Id)record.get('Id'));                
            }
            //system.debug('###oppIdSet: '+ oppIdSet);
            for (Core_Commissionable_Transaction__c oppWithComm: [SELECT Core_Opportunity__c FROM Core_Commissionable_Transaction__c where Core_Transaction_Timestamp__c > 2023-01-29T00:00:00.000+0000 and Core_Opportunity__c IN: oppIdSet]) {
                oppIdSetToProcess.add(oppWithComm.Core_Opportunity__c);
            }
            //system.debug('###KPIDtlsToProcess: '+oppIdSetToProcess.size());
            if(oppIdSetToProcess.size() > 0){
                Core_CommissionableTransactions.processOpportunityWithNoKPI(oppIdSetToProcess);
            }
        } Catch(Exception ex) {
            Core_Log_Entry__c log = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'Core_CommissionTransactionsNoKPI_Batch', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:'+ex.getLineNumber()+', Stack trace: '+ex.getStackTraceString());
			insert log;
        } 
    }
    
    global void finish(database.BatchableContext bc) { }
}