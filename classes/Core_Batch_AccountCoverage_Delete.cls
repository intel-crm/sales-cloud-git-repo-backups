/**************************************************************************************
Apex Class Name: Core_Batch_AccountCoverage_Delete
Version     : 1.0 
Created Date: 08 Dec 2016
Description    : This class deletes All the records from Account Coverage Export Object based on the custom Setting LoadType Values
*************************************************************************************/
public class Core_Batch_AccountCoverage_Delete implements Database.Batchable<sObject>{
    
    private String query = 'SELECT Id FROM Core_AccountCoverage_Export__c Where Core_Status__c = \'Delete\' AND Core_Operation__c = \'DEL\'';    
    
    //By default false, if it is false run the job on all the records 
    private Boolean deleteAll = false;
    public Core_Batch_AccountCoverage_Delete(){}
    
    //WARNING : Passing true will delete all the Records from the Account Coverage export object
    public Core_Batch_AccountCoverage_Delete(boolean deleteAllRecords){
        deleteAll = deleteAllRecords;
        query = (deleteAll == true ? 'SELECT Id FROM Core_AccountCoverage_Export__c ': query);
    }
    
    //Returns the query locator
    public Database.QueryLocator  start(Database.BatchableContext batchcontext) {
        System.debug(' Core_Batch_AccountCoverage_Export_Delete STARTED >> Query '+query);
        return Database.getQueryLocator(query);
    }
    
    //Cleans All the Account coverage Records before running the actual jobs
    public void execute(Database.BatchableContext BC, list<sObject> sobjlist){
        System.debug(' Core_Batch_AccountCoverage_Export_Delete Execute Method Invoked   ');
        delete sobjlist;
        DataBase.emptyRecycleBin(sobjlist); 
    }
    
    //Finish invokes once batch finishes
    public void finish(Database.BatchableContext batchcontext){
        System.debug(' Core_Batch_AccountCoverage_Export_Delete FINISHED   ');
        
        //Reset All the Custom Settings Before Running and the status will  
        //be udpated back to 'Completed' after batch finishes
        //Core_AccountCoverageExportUtil.setCustomSettings('All', '');
        
        //Trigger the Account coverage Export Batch        
        Database.executeBatch(new Core_Batch_AccountShare(),1500);
    }
}