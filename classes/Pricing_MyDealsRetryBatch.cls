global without sharing class Pricing_MyDealsRetryBatch extends TriggerHandler implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public DateTime dtWhen;
    public Pricing_MyDealsRetryBatch(){
        dtWhen = system.now();
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return (TriggerHandler.isActive('Pricing_MyDealsRetryBatch'))?
            Database.getQueryLocator([SELECT Id,Name,Pricing_Retry_Number__c,Pricing_Status__c,Pricing_SObject__c,
                                         Pricing_SObjectId__c,Pricing_Payload__c FROM Pricing_Integration_Staging__c 
                                         WHERE Pricing_Status__c = 'Failed' AND Pricing_Retry_Number__c >= 3]):null;
    }
    public void execute(Database.BatchableContext bc, List<Pricing_Integration_Staging__c> scope){
        try
        {
            if(scope.size() > 0 ){
                system.enqueueJob(new Pricing_MyDeals_RetryIntegration(scope));
            }
        }
        catch(exception ex)
        {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        Database.insert(lstLogEntryRecords, false);
    }
    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        // Create Assign log Entry
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'Pricing_MyDealsRetryBatch/Batch for Retry Logic when MyDeals is down';
        addLogEntry.Core_Project__c = 'Intel Quote Request (IQR)';
        addLogEntry.Core_Scope__c = 'IQR MyDeals Retry Logic';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for Retry Logic when MyDeals is down';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch';
        lstLogEntry.add(addLogEntry);
        return(lstLogEntry);
    }
}