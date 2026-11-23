/**
* Class Name - PRM_ProfileReponseMismatchReportBatch
* Created By - DINESH
* Created Date - 07-06-2023
* Description - Create Profile Response Mismatch Records in Partner Report Matrix Table for One Partner Accounts
* 				 Batch class to generate a response report for accounts with specific criteria.
*/
public without Sharing class PRM_ProfileReponseMismatchReportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public static final String ORIGIN  = 'PRM_ProfileReponseMismatchReportBatch';
    public static final String SEVERITY  = 'Critical';
    public static final String PROJECT  = 'IPA';
    
    /**
* Start method - provides the query locator for the batch.
* @param BC The batchable context.
* @return The query locator for account records.
*/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query accounts with specific criteria
        return Database.getQueryLocator([
            SELECT Id,
            (SELECT Id
             FROM Channel_Memberships1__r
             WHERE PRM_Status_Nm__c = 'Approved' AND PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance'),
            (SELECT Core_Intel_Account_Id__c, Core_Intel_Account_Id__r.Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Name
             FROM Partner_Account_Group_Members1__r
             WHERE Core_Inactive_Ind__c = false AND Core_Intel_Partner_Alliance_PartnerGroup__c = true)
            FROM Account
            WHERE RecordType.DeveloperName = 'Core_Partner_Account_Group'
            ORDER BY LastModifiedDate DESC
        ]);
    }
    
    /**
* Execute method - processes the batch of accounts.
* @param BC The batchable context.
* @param scope The list of account records to process.
*/
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Id> accountIds = new List<Id>();
        
        // Collect account IDs that have non-empty Channel_Memberships1__r
        //try{
            for (Account accountRecord : scope) {
                if (!accountRecord.Channel_Memberships1__r.isEmpty()) {accountIds.add(accountRecord.Id);
                }
            }
            
            // Call the method to generate the response report
            if (!accountIds.isEmpty()) {getResponseReport(accountIds);
            }
        //}catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);throw new AuraHandledException('Eception Occurred :'+ex.getMessage());}
    }
    
    /**
* Method to generate the response report.
* @param accountIds The list of account IDs.
*/
    public void getResponseReport(List<Id> accountIds) {
        // Call the method from PRM_ProfileReponseMismatchReport class to generate the response report
        PRM_ProfileReponseMismatchReport.getProfileResponse(accountIds);
    }
    
    /**
* Finish method - performs cleanup after batch execution.
* @param BC The batchable context.
*/
    public void finish(Database.BatchableContext BC) {
        // Query and delete old records from matrix
        try{
            List<PRM_Partner_Report_Matrix__c> recordsToDelete = [
                SELECT Id
                FROM PRM_Partner_Report_Matrix__c
                WHERE Prm_Type__c = 'Profile Response Mismatch' AND CreatedDate < :System.today()-1
            ];
            
            // Delete old records if there are any
            if (!recordsToDelete.isEmpty()) {delete recordsToDelete;
            }
        }catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);throw new AuraHandledException('Eception Occurred :'+ex.getMessage());}
    }
}