global without sharing class Core_MDF_Batch_RetryAICDBOutbound implements Database.Batchable<SObject>, Database.AllowsCallouts {

    // Initialize two static defaults (overridden by metadata in start)
    private static Integer PERIOD_DAYS = 7;
    private static Integer MAX_RETRIES = 3;

    private static final String CONFIG_CATEGORY = 'MDF AI PIC Review';
    private static final String SUBKEY_PERIOD = 'CDB Log Period';
    private static final String SUBKEY_MAX_RETRY = 'CDB Retry Counter';

    // Read metadata, override static PERIOD_DAYS and MAX_RETRIES, then return QueryLocator with filters
    global Database.QueryLocator start(Database.BatchableContext context) {
        try {
            // Fetch 2 values once
            for (Core_MDF_CCP_Custom_Metadata_Utility__c rec :
                 [SELECT Core_MDF_Sub_Category__c, Core_MDF_Value__c
                  FROM Core_MDF_CCP_Custom_Metadata_Utility__c
                  WHERE Core_MDF_Category__c = :CONFIG_CATEGORY]) {
                if (rec.Core_MDF_Sub_Category__c == SUBKEY_PERIOD) {
                    Integer configDays = Integer.valueOf(rec.Core_MDF_Value__c);
                    PERIOD_DAYS = (configDays != null) ? configDays : PERIOD_DAYS;
                } else if (rec.Core_MDF_Sub_Category__c == SUBKEY_MAX_RETRY) {
                    Integer configMaxRetry = Integer.valueOf(rec.Core_MDF_Value__c);
                    MAX_RETRIES = (configMaxRetry != null) ? configMaxRetry : MAX_RETRIES;
                }
            }

        Datetime fromDt = System.now().addDays(-PERIOD_DAYS);
        String convertFromDte = fromDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String soql =
            'SELECT Id, Core_Record_Id__c, Core_Retry_Number_Nbr__c, Core_Log_Status_Nm__c, CreatedDate ' +
            'FROM Core_CDB_Integration_Log__c ' +
            'WHERE CreatedDate >= ' + convertFromDte + ' ' +
            'AND Core_Retry_Number_Nbr__c >= 0 ' +
            'AND Core_Retry_Number_Nbr__c < ' + MAX_RETRIES + ' ' +
            'AND Core_Log_Status_Nm__c = \'Failed\' ' +
            'ORDER BY CreatedDate DESC';

        return Database.getQueryLocator(soql);//add catch block
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            return Database.getQueryLocator('SELECT Id FROM Core_CDB_Integration_Log__c WHERE Id = NULL');

        }
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Core_CDB_Integration_Log__c> cdbLogs = (scope == null || scope.isEmpty())
            ? new List<Core_CDB_Integration_Log__c>()
            : (List<Core_CDB_Integration_Log__c>) (List<SObject>) scope;

        if (cdbLogs.isEmpty()) {
            return;
        }
        try {
            Core_MDF_AI_Integration_Outbound.fetchCDBLogRecordsForRetry(cdbLogs);
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }

    global void finish(Database.BatchableContext context) {
        
    }
}