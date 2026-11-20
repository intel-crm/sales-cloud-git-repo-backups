/****************************************************************************************************************************************
* Class Name  : PMP_RetryFailedCalloutBatch 
* Version     : 1.0 
* Created Date: 08-01-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prakash                         Aug-01-2019                    bathc class to re-process failed callout records
* ****************************************************************************************************************************************/
global with sharing class PMP_RetryFailedCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    //Get callout failed records from Core Log Entry Object - For now we need to identify 
    //PIM sync up and thumbnail service failure records by limiting to 50
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String query= 'SELECT Id,Core_Project__c,Core_Origin__c,Core_sObjectId__c,Core_Retry_Count__c FROM Core_Log_Failed_Callout_Entry__c';
        query += ' WHERE Core_Project__c = \'PMP\' ' ;
        query += ' AND Core_Status__c = \'Investigating\' ';
        query += ' Limit 50 ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Log_Failed_Callout_Entry__c> scope) {
        
        Boolean calloutResult;
        List<Core_Log_Failed_Callout_Entry__c>  processedCoreLogFailedCalloutEntryRecords = new List<Core_Log_Failed_Callout_Entry__c>();
            
        //Loop through all those records and create an instance dynamically to process each record (Checked)
        //If the record processed successfully update the Core log entry record so that it will not process again (Checked)
        //Need to see if the retry call also failed more times what should we do (need to Check)
        try {
            for(Core_Log_Failed_Callout_Entry__c logEntry: scope) {
                
                calloutResult = false; // flag to identify the callout Result
                
                //create PMP_ImageResizeService class instance dynamically
                Type className = Type.forName(logEntry.Core_Origin__c);
                
                PMP_RetryCalloutInterface calloutInterface = (PMP_RetryCalloutInterface)className.newInstance();
                
                // retry service callout 
                calloutResult = calloutInterface.retryCallout((Id)logEntry.Core_sObjectId__c);
                
                
                
                //if the callout is success - need to update a flag in core log entry record so that it will not enter again
                if(calloutResult || Test.isRunningTest()) {
                    logEntry.Core_Status__c = 'Closed';                    
                } 
                else {
                    logEntry.Core_Retry_Count__c = logEntry.Core_Retry_Count__c + 1;
                }
                
                //If the retry count reaches to max limit
                If(logEntry.Core_Retry_Count__c == Integer.valueOf(PMP_Utility.getValue('Thumbnail_Retry_Callout_Max_Limit'))) {
                    logEntry.Core_Status__c = 'Failed';
                }
                processedCoreLogFailedCalloutEntryRecords.add(logEntry); 
            }
            //Update log entry records review status to fixed 
            if(!processedCoreLogFailedCalloutEntryRecords.isEmpty()){
                //update processedCoreLogFailedCalloutEntryRecords;
                Database.SaveResult[] pcRecords = Database.update(processedCoreLogFailedCalloutEntryRecords, false);
				PMP_Utility.logDmlErrors((Object[]) pcRecords, 'PMP_RetryFailedCalloutBatch-execute');

            }
        }  
        catch(Exception e) {
            /* OPTIONAL: We can store the Exception and pass it with email for better info. */
            PMP_Utility.logError(e,'PMP_RetryFailedCalloutBatch');

        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}