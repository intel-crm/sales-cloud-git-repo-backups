/********************************************************************************************************************************************************************
Apex Class Name: AlertWatchReminderBatch 
Version: 1.0
Created Date: 11/11/2024
Function: Alert Watch is used to send emails based on Audit Trail data

Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Shijas KM 11/11/2024 Original Version developed
*******************************************************************************************************************************************************************/
global class CRM_AlertwatchReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {    
    
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    global List<SetupAuditTrail> start(Database.BatchableContext BC) {        
        return new List<SetupAuditTrail>();
    }
    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> lstAuditTrail) {
        try
        { 
            
            CRM_Alertwatch.GetAuditTrailData();   
            if(Test.isRunningTest()){
                CRM_Alertwatch.GetAuditTrailData(); 
            }
        }
        catch(Exception e){            
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getStackTraceString() , Core_Origin__c='AlertWatch', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
        }
        finally {}
    }
    
    global void finish(Database.BatchableContext BC) {
        insert logEntries;
    }
}