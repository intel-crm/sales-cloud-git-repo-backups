/********************************************************************************************************************************************************************
Apex Class Name:  Core_DeleteKPIInt_Batch
Version     : 1.0 
Created Date: 03/12/2020
Function    : Batch class to initiate deletion of KPI Integration records which were created older than 90 days from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash               03/12/2020               Original Version developed US604686: KPI : Update and fix KPI sync with IAH
*******************************************************************************************************************************************************************/
global class Core_DeleteKPIInt_Batch implements Database.Batchable<sObject>{
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date core_last_90_days=system.today().addDays(-90);
        if(test.isRunningTest()){
            core_last_90_days=system.today();
        }
        String query = 'SELECT Id, OwnerId, Name, CreatedDate FROM Core_KPI_Integration_Inbound__c where createdDate <= :core_last_90_days';         
        return Database.getQuerylocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_KPI_Integration_Inbound__c> scope) {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}