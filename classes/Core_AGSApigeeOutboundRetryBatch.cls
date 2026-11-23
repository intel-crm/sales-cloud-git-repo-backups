public class Core_AGSApigeeOutboundRetryBatch implements Database.Batchable<sObject> {
public DateTime dtWhen;
    public Core_AGSApigeeOutboundRetryBatch(){
        dtWhen = system.now();
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String strQuery = 'SELECT Id,Core_MessageType__c,Core_Retry_Number__c,Core_Status__c,Core_Payload__c FROM Core_Integration_Outbound_Message__c WHERE Core_Status__c = \'Failed\' '+ 'AND Core_Retry_Number__c >= 1';
        return Database.getQueryLocator(strQuery);
    }
    public void execute(Database.BatchableContext bc, List<Core_Integration_Outbound_Message__c> scope){
        try
        {           
            Schema.SObjectType obIom = Schema.Core_Integration_Outbound_Message__c.getSObjectType();
            if(scope.size() > 0 ){
                system.enqueueJob(new ContactERPMIntegrationStatusHandler(scope,obIom));
            } 
        }
        catch(exception ex)
        {
            //Core_Log_Entry.logEntryWithException('SFDC', 'Entitlement', 'AGS_Apigee_Outbound_Integration', 'Error',
                                                 //'Error sending AGS Apigee outbound message', '', scope.Id, 'Core_Integration_Outbound_Message__c', '', ex);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }
    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        // Create Assign log Entry
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'Core_AGSApigeeOutboundRetryBatch/Batch for Retry Logic when Apigee is down';
        addLogEntry.Core_Project__c = 'DRACO';
        addLogEntry.Core_Scope__c = 'Ags Apigee Outbound Retry Logic';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for Retry Logic when apigee is down';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch';
        lstLogEntry.add(addLogEntry);        
        return(lstLogEntry);
    }
}