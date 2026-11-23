global without sharing class CRM_AlertwatchReminderBatch implements Database.Batchable<Sobject>, Database.Stateful {
    // Start method to define the query to fetch SetupAuditTrail records+
    public  List<SetupAuditTrail> lst_aw_response= new  List<SetupAuditTrail>();
    global List<SetupAuditTrail> start(Database.BatchableContext BC) {
        
        return CRM_Alertwatch.getAuditTrailReminderData();
    }
    // Execute method to process each batch of SetupAuditTrail records
    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try {
            for (SetupAuditTrail rec : scope) {
                lst_aw_response.add(rec);
            }
        } catch (Exception e) { logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error processing SetupAuditTrail records',Core_Details__c = e.getMessage(),Core_Origin__c = 'CRM_AlertWatchNotificationBatch',Core_Severity__c = 'High',Core_When__c = System.now(),Core_Project__c = 'Alert Watch'));
        } finally {     if (!logEntries.isEmpty()) { insert logEntries;  }        }
    }   // Finish method to perform any final actions after all batches are processed
    global void finish(Database.BatchableContext BC) {    CRM_Alertwatch.sendAuditTrailMail(lst_aw_response);    }
}