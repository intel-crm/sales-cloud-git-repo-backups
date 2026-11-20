/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opportunity_KPI_Delete_Batch
Version     : 1.0 
Created Date: 03/12/2020
Function    : Batch class to delete all the Opportunity KPI. Will only be used in case of emergency refresh.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda           03/12/2020             Original Version developed US604686: KPI : Update and fix KPI sync with IAH
* Sougata Sarkar			 05/28/2021				Changed old kpi object with new kpi object(Core_Oppty_KPI_New__c)
*******************************************************************************************************************************************************************/
global class Core_Opportunity_KPI_Delete_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Core_KPI_Opportunity__c FROM Core_Oppty_KPI_New__c'; 
        return Database.getQuerylocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Oppty_KPI_New__c> scope) {
        Set<Id> opptyIdSet = new Set<Id>();
        for(Core_Oppty_KPI_New__c oppKPI : scope){
            opptyIdSet.add(oppKPI.Core_KPI_Opportunity__c);
        }
        delete scope;
       
        List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
        kpiHistoryList = [SELECT id FROM Core_Opp_KPI_History__c WHERE Core_Opp_KPI_Opportunity_Name__c IN :opptyIdSet];
       
        delete kpiHistoryList;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}