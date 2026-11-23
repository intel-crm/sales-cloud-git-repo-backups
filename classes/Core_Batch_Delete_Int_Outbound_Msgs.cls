/**************************************************************************************************************
Version     : 1.0 
Created Date: 08 April 2020
Function    : Batch class to delete Integration Outbound Message records 
Modification Log :
* Developer             		 Date              Description
* ----------------------------------------------------------------------------                 
* Manikanta Polamada             08/04/2020        Initial version
***************************************************************************************************************/

global without sharing class Core_Batch_Delete_Int_Outbound_Msgs implements Database.Batchable<sObject>, Database.Stateful {
    global Integer count = 0;
	global DateTime dtWhen;
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('in start -->');
        dtWhen = system.now();
        String query = 'SELECT Id FROM Core_Integration_Outbound_Message__c '+
                       'WHERE CreatedDate < LAST_N_DAYS: '+
                        system.label.Core_No_of_Days_of_Entries_In_Integration_Outbound_Message;
            System.debug('in start --> '+query);
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {  
        system.debug('in execute method'+ scope);
        try {
            Database.DeleteResult[] lstDr = Database.delete(scope, false);
        	DataBase.emptyRecycleBin(scope);
            for(Database.DeleteResult dr : lstDr) {
                if (dr.isSuccess()) {
                    System.debug('Successfully deleted with ID: ' + dr.getId());
                    count++;
                }
                else {
                    // Operation failed, get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        catch (exception e) {
            System.debug('Error Message'+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    	system.debug('in finish method');
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        //Log Entry Fields              
        String strAssignMessage = 'Batch for deleting Integration Outbound Message records';
        String strOrigin = 'A&E Batch for deleting Integration Outbound Message records';
        String strSeverity = 'Information';
        String strProject = 'A&E';
        String strAssignScope = 'Record deleation';
        String strsObjectID = 'Core_Integration_Outbound_Message__c';
        
        Core_Log_Entry__c logEntry = new Core_Log_Entry__c ();
        
        logEntry.Core_Origin__c = strOrigin;
        logEntry.Core_Project__c = strProject;
        logEntry.Core_Scope__c = strAssignScope;
        logEntry.Core_Severity__c = strSeverity;
        logEntry.Core_Message__c = strAssignMessage;
        logEntry.Core_When__c = dtWhen;
        logEntry.Core_sObjectId__c = strsObjectID;
        logEntry.Core_Details__c = 'Duration: ' + duration + ' seconds\r\n ' +'Records deleted :' + count;
        
        insert logEntry;
    }

}