/**************************************************************************************************************
Apex Class Name:  Core_Batch_Delete_Old_Log_Entries
Version     : 1.0 
Created Date: 28 July 2016
Function    : Batch class to delete Log Entry records older than 90 days
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             07/28/2016        Initial version
* Ashwin Dash           11/24/2017        Added code for performing hard delete on log entries.(US87446)
* Chintha Nikitha       11/05/2025    Adding the comment to test the PMD setup
***************************************************************************************************************/
global class Core_Batch_Delete_Old_Log_Entries implements Database.Batchable<sObject> {
    
    // Get the entries to delete
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (Test.isRunningTest())
            return Database.getQueryLocator([select Id from Core_Log_Entry__c limit 10]);
        else
            return Database.getQueryLocator([select Id from Core_Log_Entry__c where CreatedDate < LAST_90_DAYS]);
    }
    
    // Delete them
    global void execute(Database.BatchableContext bc, List<sObject> scope) {        
        delete scope;
        //US87446 Added code for performing hard delete on log entries. -- Ashwin
        DataBase.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext bc) {
    }

}