/********************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_KPIStageDelete
Version     : 1.0 
Created Date: 04/02/2021
Function    : Batch class to initiate deletion of KPI Integration records which were created older than days provided in custom label from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan              04/02/2021               
*******************************************************************************************************************************************************************/
global class Core_Batch_KPIStageDelete implements Database.Batchable<sObject>{
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date core_last_N_days=system.today().addDays(integer.valueOf(System.Label.Core_KPI_Stage_Delete_Days));
        if(test.isRunningTest()){
            core_last_N_days=system.today();
        }
        String query = 'SELECT Id, OwnerId, Name, CreatedDate FROM Core_KPI_Staging__c where createdDate <= :core_last_N_days';         
        return Database.getQuerylocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_KPI_Staging__c> scope) {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}