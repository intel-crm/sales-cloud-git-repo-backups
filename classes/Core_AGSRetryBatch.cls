/**************************************************************************************
Apex Class Name : Core_AGSRetryBatch
Version     : 1.0 
Created Date: 6th Nov 2026
Description : Retry Batch for AGS Integration stuck in-progress contacts
*************************************************************************************/
global class Core_AGSRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    private Integer retryWindowMinutes;
    private Integer maxRetryCount;
    
    public Core_AGSRetryBatch() {        
        AGS_Integration_Settings__mdt config =
            AGS_Integration_Settings__mdt.getInstance('Default');        
        if (config != null &&
            config.Retry_Window_Minutes__c != null) {                
                retryWindowMinutes =
                    Integer.valueOf(config.Retry_Window_Minutes__c);                
            }        
        if (config != null &&
            config.Maximum_Retry_Count__c != null) {                
                maxRetryCount =
                    Integer.valueOf(config.Maximum_Retry_Count__c);               
            }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        Datetime thresholdTime =
            System.now().addMinutes(-retryWindowMinutes);        
        return Database.getQueryLocator([
            SELECT Id,
            Core_AGS_Integration_Status__c,
            Core_AGS_Status_Change_Date_Time__c,
            Core_AGS_Retry_Count__c,
            Core_Republish_OBM_s__c
            FROM Contact
            WHERE Core_AGS_Integration_Status__c = 'In-Progress'
            AND Core_Republish_OBM_s__c = FALSE
            AND (
                Core_AGS_Retry_Count__c = NULL
                OR Core_AGS_Retry_Count__c < :maxRetryCount
            )
            AND Core_AGS_Status_Change_Date_Time__c <= :thresholdTime
            AND Core_AGS_Status_Change_Date_Time__c >= YESTERDAY
            AND Core_ERPM_Integration_Status__c ='Successful'
        ]);
    }    
    global void execute(Database.BatchableContext bc,List<Contact> scope) {        
        List<Contact> contactsToUpdate =
            new List<Contact>();        
        for (Contact con : scope) {            
            con.Core_Republish_OBM_s__c = true;            
            if (con.Core_AGS_Retry_Count__c == null) {                
                con.Core_AGS_Retry_Count__c = 0;                
            } else {                
                con.Core_AGS_Retry_Count__c =
                    Integer.valueOf(
                        con.Core_AGS_Retry_Count__c
                    ) + 1;
            }            
            contactsToUpdate.add(con);
        }        
        if (!contactsToUpdate.isEmpty()) {
            System.enqueueJob(new Core_AGSRetryQueueable(contactsToUpdate));
        }
    }   
    global void finish(Database.BatchableContext bc) {       
    }
}