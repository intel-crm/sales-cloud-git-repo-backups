/***************************************************************************************************************************************
Apex Class Name     : PRM_DeleteTestRegistrationRequestsBatch 
Version             : 1.0
Created Date        : August 2026
Function            : Delete Test Registrations
Maximum Batch Size  : 100
Modification Log    : 
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                       August-2026                     Start Method returns the test registrations **********************************************/
global class PRM_DeleteTestRegistrationRequestsBatch implements Database.Batchable<SObject>, Database.Stateful {
    public static String logEntryMsgString;
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_DeleteTestRegistrationRequestsBatch';
    public static final String LOG_ENTRY_PROJECT  = 'IPA';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_DeleteTestRegistrationRequestsBatch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> conditions = new List<String>();
        List<PRM_Test_Registration_Domain__mdt> domainConfigs = [SELECT PRM_Domain__c,PRM_Active__c FROM PRM_Test_Registration_Domain__mdt WHERE PRM_Active__c = TRUE AND PRM_Domain__c != NULL];
        Datetime dt = Datetime.valueOfGmt(Label.PRM_EntitlementDQBatchPickupDate.replace('T', ' ').replace('Z', ''));

        if (domainConfigs.isEmpty()) {
            return Database.getQueryLocator('SELECT Id,PRM_Email_ID__c,PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c WHERE Id = NULL');
        }
        for (PRM_Test_Registration_Domain__mdt config : domainConfigs) {
            String domain = config.PRM_Domain__c.trim().toLowerCase();
            if (String.isBlank(domain)) {
                continue;
            }
            domain = String.escapeSingleQuotes(domain);
            conditions.add('PRM_Email_ID__c LIKE \'%@' + domain + '\'');
        }
        if (conditions.isEmpty()) {
            return Database.getQueryLocator(
                'SELECT Id,PRM_Email_ID__c,PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c WHERE Id = NULL'
            );
        }
        String query =
        'SELECT Id, PRM_Email_ID__c, PRM_Channel_Program_Level_txt__c ' +
        'FROM PRM_Registration_Request__c ' +
        'WHERE (' + String.join(conditions, ' OR ') + ') ' +
        'AND PRM_Channel_Program_Level_txt__c = \'Intel Partner Alliance\''+
        'AND CreatedDate >:dt';
        logEntryMsgString+='Inside start method '+query;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<PRM_Registration_Request__c> scope) 
    {
        logEntryMsgString+='Inside execute method '+scope;
        
        try{
            if (!scope.isEmpty()) {
                Database.Delete(scope,false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[Failed to delete Registration Request ] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }
    global void finish(Database.BatchableContext bc) {
    }
    public static void createLogEntry(String logEntryMsgString){
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }
        }
    }
}