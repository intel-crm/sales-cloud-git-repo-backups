/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateDWInactveQuote
Version         : 1.0 
Created Date    : 4/26/2021
Function        : This class updates Inactive Design win Quote in Bacthes
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykanth                 4/26/2021                Created
*****************************************************************************************************/
@isTest
global class PSG_BatchUpdateDWInactveQuote {
    /*implements Database.Batchable < sObject > , Database.Stateful {
    public DateTime dtWhen;
    global integer resursiveCounter;
    public PSG_BatchUpdateDWInactveQuote() {
        dtWhen = System.now();
    }
    public Database.querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, core_cpq_dollar_change_flag_cb__c
            FROM SBQQ__QuoteLine__c WHERE core_cpq_parent_quote__r.core_cpq_active_cb__c = false
            AND core_cpq_parent_quote__r.core_cpq_quote_type_nm__c = 'Design Win'
        ]);
    }
    public void execute(Database.BatchableContext bc, List < sObject > scope) {
        try {
            for (SBQQ__QuoteLine__c quoteLine: (List < SBQQ__QuoteLine__c > ) scope) {
                quoteLine.core_cpq_dollar_change_flag_cb__c = true;
            }
            if (!scope.isEmpty()) {
                update scope;
            }
        } catch (exception ex) {
            PSG_Utility.logError(ex);
        }
    }
    public void finish(Database.BatchableContext bc) {
        List < Core_Log_Entry__c > lstLogEntryRecords = createLogEntryRecords();
        List < Database.SaveResult > resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }
    private List < Core_Log_Entry__c > createLogEntryRecords() {
        List < Core_Log_Entry__c > lstLogEntry = new List < Core_Log_Entry__c > ();
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime()) / 1000) - ((dtWhen.getTime()) / 1000);

        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c();
        addLogEntry.Core_Origin__c = 'PSG_BatchUpdatePRIDQuoteLines/Batch for Processing PRID Updates';
        addLogEntry.Core_Project__c = 'PSG Quote Request (PSG)';
        addLogEntry.Core_Scope__c = 'PSG Inbound Processing';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for Processing PRID Updates';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration + ' for processing batch';

        lstLogEntry.add(addLogEntry);
        return (lstLogEntry);
    }*/
}