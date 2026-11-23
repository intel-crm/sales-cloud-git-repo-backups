/**
* @description       : PRM_BenefitMisMatchReport - class to generate Benefit Mismatch report for accounts.
Batch class to generate Benefit Mismatch report for accounts.
* @author            : DINESH 
* @last modified on  : 08-06-2023
* @last modified by  : 
*/
public without Sharing class PRM_BenefitMismatchReportBatch implements Database.Batchable<sObject>, Database.stateful{
    
    public static final String ORIGIN  = 'PRM_BenefitMismatchReportBatch';
    public static final String SEVERITY  = 'Critical';
    public static final String PROJECT  = 'IPA';
    public static Set<String> uniqueValues = new Set<String>();
    /**
* Returns the query locator to retrieve the accounts for generating the report.
* The query selects accounts that meet certain criteria and have related Partner Account Group Members.
* @param BC The batchable context.
* @return The query locator.
*/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, (SELECT Core_Partner_Account_Id__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c = false) FROM Account WHERE Core_Intel_Partner_Alliance_PartnerGroup__c = true AND Core_Deactivated__c = false AND Core_IPA_One_Partner_Id__c <> NULL AND RecordType.DeveloperName IN (\'Mastered_Account\', \'Core_Partner_Account_Group\') LIMIT 49999');
    }
    
    /**
* Executes the batch operation for the specified scope of accounts.
* Adds account IDs and related Partner Account IDs to generate the report.
* @param BC The batchable context.
* @param scope The list of accounts to process.
*/
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        // add try catch block
        List<String> accountIds = new List<String>();
        try{
            for (Account accountRecord : scope) {  
                accountIds.add(accountRecord.Id);
                if (accountRecord.Partner_Account_Group_Members1__r.size() > 0) {
                    accountIds.add(accountRecord.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c);
                }
            }
            generateReport(accountIds);
            
        }catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);throw new AuraHandledException('Eception Occurred :'+ex.getMessage());}
        
    }
    
    /**
* Generates the Benefit Mismatch report for the specified account IDs.
* @param accountIds The list of account IDs to include in the report.
*/
    public void generateReport(List<Id> accountIds) {
        // Get required benefits
        PRM_BnftMatrixWrapper bmw = PRM_BenefitMisMatchReport.getRequiredBenefits();
        
        // Generate report for accounts and benefits
        PRM_BenefitMisMatchReport.getAccountsAndBenefits(accountIds, bmw);
    }
    
    /**
* Performs the finish operation after the batch execution.
* Deletes old records from the PRM_Partner_Report_Matrix__c object.
*/
    public void finish(Database.BatchableContext BC) {
        // Delete old records from matrix
        List<PRM_Partner_Report_Matrix__c> records = new List<PRM_Partner_Report_Matrix__c>();
        for (PRM_Partner_Report_Matrix__c record : [SELECT Id FROM PRM_Partner_Report_Matrix__c WHERE prm_type__c = 'Benefit Mismatch' AND CreatedDate < :System.today()]) {
            records.add(record);
        }
        if(!records.isEmpty())delete records;
    }
}