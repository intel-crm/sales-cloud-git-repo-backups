/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opportunity_KPI_Delete_Batch
Version     : 1.0 
Created Date: 03/12/2020
Function    : Batch class to delete all the Opportunity KPI. Will only be used in case of emergency refresh.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda           03/12/2020             Original Version developed US604686: KPI : Update and fix KPI sync with IAH
*******************************************************************************************************************************************************************/
global class Core_Opportunity_KPI_Delete_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Core_Opp_KPI_Opportunity__c FROM Core_Opportunity_KPI__c'; 
        return Database.getQuerylocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Opportunity_KPI__c> scope) {
        Set<Id> opptyIdSet = new Set<Id>();
        for(Core_Opportunity_KPI__c oppKPI : scope){
            opptyIdSet.add(oppKPI.Core_Opp_KPI_Opportunity__c);
        }
        delete scope;
        System.debug('**OpptyID SET - '+opptyIdSet);
        List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
        kpiHistoryList = [SELECT id FROM Core_Opp_KPI_History__c WHERE Core_Opp_KPI_Opportunity_Name__c IN :opptyIdSet];
        System.debug('**KPI History - '+kpiHistoryList);        
        delete kpiHistoryList;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}