/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_InactiveKPIDelete 
Version     : 1.0 
Created Date: 12 AUG 2021
Function    : Batch to Delete the Inactive KPI
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             08/12/2021              Original Version

*****************************************************************************************************************************************************************************************************/

global class Core_Batch_InactiveKPIDelete implements Database.Batchable<sObject>{
    
    List<Core_KPI_Staging__c> NewFullRecBatch = new List<Core_KPI_Staging__c>();
    String batchIDbatch;
    List<id> ids = new List<id>();
    List<id> kpis = new List<id>();
    List<id> kpid = new List<id>();
    List<Core_Oppty_KPI_New__c> kpinew = new List<Core_Oppty_KPI_New__c>();
    List<Core_Oppty_KPI_New__c> kpinewList = new List<Core_Oppty_KPI_New__c>();
    String batchq='';
    String batche='';
    String result='';
    String resultfinal = '';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator([select id from Core_Oppty_KPI_New__c where Core_IsActive__c = false ]);
    }
    global void execute(Database.BatchableContext bc, List<Core_Oppty_KPI_New__c> scope){
        system.debug('to be deleted size'+scope.size());
        system.debug('to be deleted'+scope);
        try{
            database.delete(scope,false);
            
            Set<Id> opptyIdSet = new Set<Id>();
            for(Core_Oppty_KPI_New__c oppKPI : scope){
                opptyIdSet.add(oppKPI.Core_KPI_Opportunity__c);
            }
            List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
            kpiHistoryList = [SELECT id FROM Core_Opp_KPI_History__c WHERE Core_New_Opportunity_KPI__c IN :opptyIdSet];    
            delete kpiHistoryList;
        }
        catch(exception e){
            system.debug('**exception** -->'+ e.getStackTraceString());
            system.debug('**exception line** -->'+e.getMessage());
            Core_Exceptions__c excep = new Core_Exceptions__c();
            excep.Core_Class_Name__c ='Core_Batch_OpportunityKPIDelete';
            excep.Core_Exception__c = e.getStackTraceString();
            excep.Core_IPS_Object_Name__c = 'Core_Oppty_KPI_New__c';
            insert excep;
        }
    }
    public void finish(Database.BatchableContext batchcontext){
        System.debug(' Core_Batch_InactiveKPIDelete FINISHED   ');
        
    }
}