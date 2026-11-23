/**************************************************************************************
Apex Class Name:  Core_Batch_AccountCoverage_Summary
Version     : 1.0 
Created Date: 10 Dec 2016
Description    : This Batch updates the status and operation fields based on the LoadType Custom settings and Makes a REST API Mule service to update the completion status
*************************************************************************************/
public class Core_Batch_AccountCoverage_Summary implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    private String loadType  = '';//FULL or DELTA
    private String query = '';
    
    public Core_Batch_AccountCoverage_Summary(){
        //Read the custom setting from Core_AccountCoverage_LoadType__c
        Map<String, Core_AccountCoverage_LoadType__c> mapCodes = Core_AccountCoverage_LoadType__c.getAll();
        Core_AccountCoverage_LoadType__c cl = [Select Name, Core_LoadType__c FROM Core_AccountCoverage_LoadType__c];
        if(cl != null && null != cl.Core_LoadType__c)
            loadType = cl.Core_LoadType__c;
        
        System.debug('+++++++++++++++++ Core_Batch_AccountCoverage_Summary STARTED  -----------------LoadType '+LoadType);
        //Do Not Run the Summary Batch if LoadType Flag is Blank
        if(String.isNotBlank(loadType)){
            query = 'Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ' + ('DELTA'.equalsIgnoreCase(loadType) ? ' Where Core_Status__c  IN (\'Processed\',\'New\')' : '') ; 
        }
    }
    
    public Database.QueryLocator  start(Database.BatchableContext batchcontext) {
        
        // Limit to 1 for Testing.
        query = (Test.isRunningTest() ? ' Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c '  : query);
        System.debug(' Core_Batch_AccountCoverage_Summary Running >>'+query);
        return Database.getQueryLocator(query );
    }
    
    //Process the Core_AccountCoverage_Export__c records 
    public void execute(Database.BatchableContext BC, list<Core_AccountCoverage_Export__c> scope){
        system.debug(' +++++++++++++++++ Core_Batch_AccountCoverage_Summary Execute Method Invoked '+scope.size());
        
        for(Core_AccountCoverage_Export__c ac : scope){
            system.debug(' loadType '+loadType);
            if('FULL'.equalsIgnoreCase(loadType)){
                if('Processed'.equalsIgnoreCase(ac.Core_Status__c)){
                    ac.Core_Status__c = 'Delete';
                    ac.Core_Operation__c = 'DEL';
                    
                }else if('New'.equalsIgnoreCase(ac.Core_Status__c)){
                    ac.Core_Status__c = 'Processed';
                    ac.Core_Operation__c = 'LOAD';
                }
            }else if('DELTA'.equalsIgnoreCase(loadType)){
                if('New'.equalsIgnoreCase(ac.Core_Status__c)){
                    ac.Core_Status__c = 'Processed';
                    //ac.Core_Operation__c = 'LOAD';
                }else{
                    ac.Core_Status__c = 'Delete';
                    ac.Core_Operation__c = 'DEL';
                }
            }
        }
        system.debug(' Modified Records Before Upserting '+scope);
        
        update scope;
        
        /* START Throwing Exception fro testing.  
          This below line of code for just throwing exception from batch */
        /*      DmlException dml=new DmlException();
                throw dml;*/
        /* END */  
    }
    
    //Invokes when the batch finish and post processing is to update the custom setting and sending a notification mail
    public void finish(Database.BatchableContext batchcontext){
        System.debug('+++++++++++++++++ Core_Batch_AccountCoverage_Summary FINISHED  -----------------');
        Core_AccountCoverageExportUtil.sendNotification(batchcontext, 'Core_Batch_AccountCoverage_Summary'); 

        //Call the eMule service ..
        Database.executeBatch(new Core_Batch_AccountCoverage_Mule());
        
    }
    
    
}