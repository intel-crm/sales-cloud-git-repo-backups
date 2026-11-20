/****************************************************************************************************************************************************
 * Class Name      : Core_MDF_Batch_RetryAICDBOutbound
 * Version               : 1.0
 * Created Date          : 11-19-2025
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sham                11-19-2025        Batch class for CDB Outbound Integartion Retry for MDF AI PIC Process.
 ******************************************************************************************************************************************************/
global without sharing class Core_MDF_Batch_RetryAICDBOutbound implements Database.Batchable<SObject>, Database.AllowsCallouts,Database.Stateful,Core_MDF_BatchSchedulerInterface {//audit change Database.Stateful

    // Initialize two static defaults (overridden by metadata in start)
    private static Integer PERIOD_DAYS = 7;
    private static Integer MAX_RETRIES = 3;

    private static final String CONFIG_CATEGORY = 'MDF AI PIC Review';
    private static final String SUBKEY_PERIOD = 'CDB Log Period';
    private static final String SUBKEY_MAX_RETRY = 'CDB Retry Counter';
    
   
    private Set<Id> caseIdsForAuditBatch = new Set<Id>();
    private Map<String,Integer> cdbAIAuditLogsMap = new Map<String,Integer>();
    public String queryString;
    public String executionContext;
    
    public Core_MDF_Batch_RetryAICDBOutbound(){}
    
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
        if(classSignature == 'Core_MDF_Batch_RetryAICDBOutbound(String executionContext)'){
            
			String executionContext = String.valueOf(parmValueMap.get('executionContext'));
            des_Obj = new Core_MDF_Batch_RetryAICDBOutbound(executionContext);
        }
        return des_Obj;
    }
    
 // Parameterized constructor to accept execution context
 public Core_MDF_Batch_RetryAICDBOutbound(String executionContext) {
      
     Datetime fromDt = System.now().addDays(-PERIOD_DAYS);
     
      String convertFromDte = fromDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
     
     this.executionContext = executionContext;
    
      queryString = 'SELECT Id, Core_Record_Id__c, Core_Retry_Number_Nbr__c, Core_Log_Status_Nm__c, CreatedDate, Core_Integration_Type__c ' +
        'FROM Core_CDB_Integration_Log__c ' +
        'WHERE CreatedDate >= ' + convertFromDte + ' ' +
        'AND Core_Retry_Number_Nbr__c >= 0 ' +
        'AND Core_Retry_Number_Nbr__c < ' + MAX_RETRIES + ' ' +
        'AND Core_Log_Status_Nm__c = \'Failed\' ';
        
    if(executionContext == 'MDF AI PIC Review'){
        queryString += 'AND Core_Integration_Type__c = \'MDF AI PIC Review\' ';
    }
    else if(executionContext == 'MDF AI Audit'){
        queryString += 'AND Core_Integration_Type__c = \'MDF AI Audit\' ';
    }
    
    queryString += 'ORDER BY CreatedDate DESC';
}
    
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
        String soql = queryString; 
            
        return Database.getQueryLocator(soql);
            
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

            if(executionContext == 'MDF AI PIC Review'){
            	Core_MDF_AI_Integration_Outbound.fetchCDBLogRecordsForRetry(cdbLogs);
            }
            else if(executionContext == 'MDF AI Audit'){
                for(Core_CDB_Integration_Log__c cdbLogRec:cdbLogs){
                	//If CDB Integration Type is Audit add the caseIds and populate a map with Case Id and Retry Number to be passed to Audit Batch
                    caseIdsForAuditBatch.add(cdbLogRec.Core_Record_Id__c);
                    cdbAIAuditLogsMap.put(cdbLogRec.Core_Record_Id__c,Integer.valueOf(cdbLogRec.Core_Retry_Number_Nbr__c));
            	}
          	}
            
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }

    global void finish(Database.BatchableContext context) {
        	//Invoke Audit AI Batch
            If(executionContext == 'MDF AI Audit'){
                Core_MDF_Audit_AI_Integration auditAIIntegrationBatch = new Core_MDF_Audit_AI_Integration(caseIdsForAuditBatch,cdbAIAuditLogsMap);
                Database.executeBatch(auditAIIntegrationBatch);    
            } 
    }
}