/****************************************************************************************************************************************************
 * Class Name      : Pricing_Batch_RetryAICDBOutbound
 * Version               : 1.0
 * Created Date          : 05-06-2026
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sinduja                05-06-2026       Batch class for CDB Outbound Integartion Retry for AI Pricing Process
 ******************************************************************************************************************************************************/
global without sharing class Pricing_Batch_RetryAICDBOutbound implements Database.Batchable<SObject>, Database.AllowsCallouts	 {

    // Initialize two static defaults 
    private static Integer PERIOD_DAYS = Integer.valueOf(Label.Pricing_CDB_Log_Period_Days);
    private static Integer MAX_RETRIES = Integer.valueOf(Label.Pricing_CDB_Max_Retry_Counter);
    
    public String queryString;
    public String executionContext;
    
    public Pricing_Batch_RetryAICDBOutbound(){}
    
 // Parameterized constructor to accept execution context
 public Pricing_Batch_RetryAICDBOutbound(String executionContext) {
      
     Datetime fromDt = System.now().addDays(-PERIOD_DAYS);
     
      String convertFromDte = fromDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
     
     this.executionContext = executionContext;
    
      queryString = 'SELECT Id, Core_Record_Id__c, Core_Retry_Number_Nbr__c, Core_Log_Status_Nm__c, CreatedDate, Core_Integration_Type__c ' +
        'FROM Core_CDB_Integration_Log__c ' +
        'WHERE CreatedDate >= ' + convertFromDte + ' ' +
        'AND Core_Retry_Number_Nbr__c >= 0 ' +
        'AND Core_Retry_Number_Nbr__c < ' + MAX_RETRIES + ' ' +
        'AND Core_Log_Status_Nm__c = \'Failed\' ';
        
    if(executionContext == 'Pricing Application Agent'){
        queryString += 'AND Core_Integration_Type__c = \'Pricing Application Agent\' ';
    }
    
    queryString += 'ORDER BY CreatedDate DESC';
}
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        try {
            
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
        Map<String,Integer> cdbLogMap= new Map<String,Integer>();
        List<Id> quoteLineIds = new List<Id>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Id> pricingAgentQuoteLineIds = new List<Id>();
        
         try {
        List<Core_CDB_Integration_Log__c> cdbLogs = (scope == null || scope.isEmpty())
            ? new List<Core_CDB_Integration_Log__c>()
            : (List<Core_CDB_Integration_Log__c>) (List<SObject>) scope;
        
        if (cdbLogs.isEmpty()) {
            return;
        }
        
        for(Core_CDB_Integration_Log__c logRec:cdbLogs){
            cdbLogMap.put(logRec.Core_Record_Id__c,Integer.valueOf(logRec.Core_Retry_Number_Nbr__c));
            quoteLineIds.add(logRec.Core_Record_Id__c);
        }
        quoteLineList = [SELECT Id,Pricing_Integration_Status_Nm__c,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id IN:quoteLineIds];
             if(quoteLineList.size()>0){
                 for(SBQQ__QuoteLine__c qlRecord:quoteLineList){
                     if(qlRecord.Pricing_Status_Nm__c == 'Pending Further Intel Review' && String.isBlank(qlRecord.Pricing_Integration_Status_Nm__c)){
                        pricingAgentQuoteLineIds.add(qlRecord.Id);
                     }
                 }
             }
            
            if(pricingAgentQuoteLineIds.size()>0){
            	Pricing_Application_Agent_AI_Integration.populateJSON(pricingAgentQuoteLineIds,cdbLogMap);
            }
            
        } catch (Exception exp) {
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error', Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_Batch_RetryAICDBOutbound', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');
            insert logEntry;
        }
    }

    global void finish(Database.BatchableContext context) {
    }
}