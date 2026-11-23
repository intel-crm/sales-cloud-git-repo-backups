/**************************************************************************************************************
Version     : 1.0 
Created Date: 21 April 2020
Function    : Batch class to delete Integration Outbound Message records 
Modification Log :
* Developer             		 Date              Description
* ----------------------------------------------------------------------------                 
* Manikanta Polamada             08/04/2020        Initial version
***************************************************************************************************************/

global without sharing class Core_Batch_Del_Old_Outbnd_Msgs implements Database.Batchable<sObject>, Database.Stateful {
    global Integer nCount = 0;
	global DateTime dtWhen;
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        dtWhen = system.now();
        //Query to fetch records that are older than system.label.Core_Batch_Del_Old_Outbnd_Msgs_Days_To_Retain days
        String query = 'SELECT Id FROM Core_Integration_Outbound_Message__c '+
                       'WHERE CreatedDate < LAST_N_DAYS: '+
                        system.label.Core_Batch_Del_Old_Outbnd_Msgs_Days_To_Retain;
            System.debug('in start --> '+query);
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {  
        system.debug('in execute method'+ scope);
        try {
            Database.DeleteResult[] lstDr = Database.delete(scope, false);
            // Deleting from recycle bin
        	DataBase.emptyRecycleBin(scope);
            for(Database.DeleteResult dr : lstDr) {
                if (dr.isSuccess()) {
                    nCount++;
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
        String strOrigin = 'Batch class: Core_Batch_Del_Old_Outbnd_Msgs';
        String strSeverity = 'Info';
        String strProject = 'Integration Projects';
        String strAssignScope = 'Record deletion';
        String strsObjectType = 'Core_Integration_Outbound_Message__c';
        
        Core_Log_Entry__c logEntry = new Core_Log_Entry__c ();
        
        logEntry.Core_Origin__c = strOrigin;
        logEntry.Core_Project__c = strProject;
        logEntry.Core_Scope__c = strAssignScope;
        logEntry.Core_Severity__c = strSeverity;
        logEntry.Core_Message__c = strAssignMessage;
        logEntry.Core_When__c = dtWhen;
        logEntry.Core_sObjectType__c = strsObjectType;
        logEntry.Core_Details__c = 'Duration: ' + duration + ' seconds\r\n ' +'Records deleted: ' + nCount;
        
        insert logEntry;
    }

}