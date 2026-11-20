/********************************************************************************************************************************************************************
Apex Class Name:  Core_IQR_StageDelete
Version     : 1.0 
Created Date: 25/01/2022
Function    : Batch class to initiate deletion of IQR STaging records which were created older than days provided in custom label from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda              25/01/2022              
*******************************************************************************************************************************************************************/
global class Core_IQR_StageDelete implements Database.Batchable<sObject>{
	 global Database.QueryLocator start(Database.BatchableContext BC) {
     	Date core_IQR_last_N_days=system.today().addDays(integer.valueOf(System.Label.Core_IQR_Stage_Delete_Days));
         system.debug('core_IQR_last_N_days---'+core_IQR_last_N_days);
        if(test.isRunningTest()){
            core_IQR_last_N_days=system.today();
        }
        String query = 'SELECT Id, OwnerId, Name, CreatedDate FROM Core_IQR_Products_Staging__c where createdDate <= :core_IQR_last_N_days';         
        return Database.getQuerylocator(query);
     }
    global void execute(Database.BatchableContext BC, List<Core_IQR_Products_Staging__c> scope) {
        system.debug('Scope---'+scope);
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}