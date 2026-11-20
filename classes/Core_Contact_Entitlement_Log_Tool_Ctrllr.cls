/******************************************************************************************************************************************
Class Name  : Core_Contact_Entitlement_Log_Tool_Ctrllr
Version     : 1.0
Created Date: 30 JAN 2017
Function    : Admin diagnostics tool to quickly see what's happening with Contact Entitlement
			  across various objects and log entries.

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 01/30/2017              Original version
* Ankita Roy				04/27/2020				US667275 - DEVELOPMENT ONLY : Security Scan Fixes - 3
*****************************************************************************************************************************************/
public without sharing class Core_Contact_Entitlement_Log_Tool_Ctrllr {
    
    private static final Integer RECORD_LIMIT = 50;  // Limit used in SOQL queries
    public Integer getRecordLimit(){ return RECORD_LIMIT; }
    
    // UI flags
    public Boolean showResults { get; set; }
    public Boolean showContacts { get; set; }
    public Boolean showContactEntitlements { get; set; }
    public Boolean showOutboundMessages { get; set; }
    public Boolean showInboundMessages { get; set; }
    public Boolean showMessageHistory { get; set; }
    public Boolean showLogEntries { get; set; }
    public Boolean showNoRecordsFound { get; set; }
    
    // Contact/user identifiers
    public String contactId { get; set; }
    public String erpmPersonId { get; set; }
    public String enterpriseId { get; set; }
    public String emailAddr { get; set; }
    
    // Time bounds
    public DateTime startDateTime { get; set; }
    public DateTime endDateTime { get; set; }
    
    // Message/log entry IDs
    public String inboundMessageId { get; set; }
    public String outboundMessageId { get; set; }
    public String logEntryId { get; set; }
    
    // Message types
    public String messageTypes { get; set; }
    
    public List<SelectOption> getMessageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('ERPM','ERPM'));
        options.add(new SelectOption('ERPM Contact','ERPM Contact'));
        options.add(new SelectOption('ERPM Account','ERPM Account'));
        options.add(new SelectOption('ERPM Blackbox','ERPM Blackbox'));
        options.add(new SelectOption('AGS','AGS'));
        return options;
    }
    
    // Status values
    public String statusValue { get; set; }
    public String inboundProcessingStatus;
    
    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Successful','Successful'));
        options.add(new SelectOption('Failed','Failed'));
        return options;
    }
    
    // Lists for displaying tables of records
    public List<Contact> contacts { get; set; }
    public List<Core_Contact_Entitlement__c> contactEntitlements { get; set; }
    public List<Core_Integration_Outbound_Message__c> outboundMessages { get; set; }
    public List<Core_Integration_Inbound_Message__c> inboundMessages { get; set; }
    public List<SortableObject> messageHistory { get; set; }
    public List<Core_Log_Entry__c> logEntries { get; set; }
    
    // SOQL statements
    public String contactSoql { get; set; }
    public String contactEntitlementSoql { get; set; }
    public String outboundMessageSoql { get; set; }
    public String inboundMessageSoql { get; set; }
    public String logEntrySoql { get; set; }

    public Core_Contact_Entitlement_Log_Tool_Ctrllr() {
        
        // Don't show results until the user clicks Search
        showResults = false;
        showContacts = false;
        showContactEntitlements = false;
        showOutboundMessages = false;
        showInboundMessages = false;
        showLogEntries = false;
        showMessageHistory = false;
        showNoRecordsFound = false;
        
        // Initialize all of our search vars
        contactId = '';
        erpmPersonId = '';
        enterpriseId = '';
        emailAddr = '';
        
        startDateTime = DateTime.now();
        endDateTime = DateTime.now();
        
        inboundMessageId = '';
        outboundMessageId = '';
        logEntryId = '';
    }
    
    public PageReference init() {
        return null;
    }
    
    public PageReference search() {
        
        // Reset the UI
        resetUiFlags();
        
        // Trim whitespace
        trimSearchInputs();
        
        Boolean searchMessagesLogsById = hasMessageOrLogId();
        
        // ================================== SEARCH CONTACTS =======================================
        contacts = Database.query(buildContactSoql());
        if (contacts.size() > 0) showContacts = true;
        
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contacts) contactIds.add(c.Id);
        
        // ================================== SEARCH CONTACT ENTITLEMENTS ==================================
        contactEntitlements = Database.query(buildContactEntitlementSoql(contactIds));
        if (contactEntitlements.size() > 0) showContactEntitlements = true;
        
        // ================================== SEARCH OUTBOUND MESSAGES ==================================
        outboundMessages = Database.query(buildOutboundMessageSoql(searchMessagesLogsById));
        if (outboundMessages.size() > 0) showOutboundMessages = true;
        
        // ================================== SEARCH INBOUND MESSAGES ==================================
        inboundMessages = Database.query(buildInboundMessageSoql(searchMessagesLogsById));
        if (inboundMessages.size() > 0) showInboundMessages = true;
        
        // ================================== SEARCH LOG ENTRIES ==================================
        logEntries = Database.query(buildLogEntrySoql(searchMessagesLogsById));
        if (logEntries.size() > 0) showLogEntries = true;

        // ================================== CONSOLIDATE RESULTS AND DISPLAY ==================================
        consolidateInboundOutboundMessages();
        //debugSearchResults();
        
        showResults = true;
        
        if (!(showContacts || showContactEntitlements || showOutboundMessages || showInboundMessages || showLogEntries))
            showNoRecordsFound = true;
        
        return null;
    }
    
    private String soqlFormat(DateTime theDateTime) {
        return theDateTime.formatGmt('yyyy-MM-dd') + 'T' + theDateTime.formatGmt('HH:mm:ss') + 'z';
    }
    
    // Helper: reset UI flags
    private void resetUiFlags() {
        showContacts = false;
        showContactEntitlements = false;
        showOutboundMessages = false;
        showInboundMessages = false;
        showLogEntries = false;
        showMessageHistory = false;
        showNoRecordsFound = false;
    }
    
    // Helper: trim inputs safely
    private void trimSearchInputs() {
        if (contactId != null) contactId = contactId.trim();
        else contactId = '';
        if (erpmPersonId != null) erpmPersonId = erpmPersonId.trim();
        else erpmPersonId = '';
        if (enterpriseId != null) enterpriseId = enterpriseId.trim();
        else enterpriseId = '';
        if (emailAddr != null) emailAddr = emailAddr.trim();
        else emailAddr = '';
        if (inboundMessageId != null) inboundMessageId = inboundMessageId.trim();
        else inboundMessageId = '';
        if (outboundMessageId != null) outboundMessageId = outboundMessageId.trim();
        else outboundMessageId = '';
        if (logEntryId != null) logEntryId = logEntryId.trim();
        else logEntryId = '';
    }
    
    // Helper: detect if search should be by message/log Id
    private Boolean hasMessageOrLogId() {
        return (inboundMessageId != '' || outboundMessageId != '' || logEntryId != '');
    }
    
    // Build contact SOQL string
    private String buildContactSoql() {
        String soql = 'select Id, Name, Email, Core_ERPM_Person_Id__c, Core_Enterprise_Id__c, Core_Login_Id__c, ' +
                'Core_Login_Status__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, ' +
                'Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c, LastModifiedDate ' +
            'from Contact ' +
            'where Id != null ';
        if (contactId != '')
            soql += ' and Id = \'' + String.escapeSingleQuotes( contactId ) + '\'';
        if (emailAddr != '')
            soql += ' and Email = \'' + String.escapeSingleQuotes( emailAddr ) + '\'';
        if (erpmPersonId != '')
            soql += ' and Core_ERPM_Person_Id__c = \'' + String.escapeSingleQuotes( erpmPersonId ) + '\'';
        if (enterpriseId != '')
            soql += ' and Core_Enterprise_Id__c = \'' + String.escapeSingleQuotes( enterpriseId ) + '\'';
        soql += ' limit ' + String.valueOf( RECORD_LIMIT );
        contactSoql = soql;
        return soql;
    }
    
    // Build contact entitlement SOQL
    private String buildContactEntitlementSoql(Set<Id> contactIds) {
        String soql = 'select Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Selected__c, Core_From_Source__c, Core_Type__c, ' +
                'Core_Contact_Id__r.Name, ' +
                'Core_Entitlement_Id__r.Core_Display_Name__c, ' +
                'Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c, ' +
                'Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Name, ' +
                'Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, ' +
                'Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Name__c, ' +
                'Core_Entitlement_Id__r.Core_AGS_Role_Id__c, ' +
                'Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Name, ' +
                'Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c ' +
            'from Core_Contact_Entitlement__c ' +
            'where Core_Contact_Id__c in :contactIds ';
        soql += ' limit ' + String.valueOf( RECORD_LIMIT ) ;
        contactEntitlementSoql = soql;
        return soql;
    }
    
    // Build outbound message SOQL
    private String buildOutboundMessageSoql(Boolean searchMessagesLogsById) {
        String soql = 'select Id, LastModifiedDate, Core_MessageType__c, Core_Payload__c ' +
                'from Core_Integration_Outbound_Message__c ' +
                'where ';
        if (searchMessagesLogsById) {
            soql += ' Id = \'' + String.escapeSingleQuotes( outboundMessageId ) + '\' ';
        }
        else {
            String outboundMessageTypes = 
                (messageTypes == 'All') ? '\'ERPM Contact Entitlement\', \'AGS Contact Entitlement\'' :
                    (messageTypes == 'ERPM') ? '\'ERPM Contact Entitlement\'' :
                        (messageTypes == 'ERPM Contact') ? '\'ERPM Contact Entitlement\'' :
                            (messageTypes == 'AGS') ? '\'AGS Contact Entitlement\'' : '\'XXXXXXXXXX\'';
            
            soql += ' LastModifiedDate >= ' + soqlFormat(Date.valueOf( startDateTime ) ) +
                    ' and LastModifiedDate < ' + soqlFormat(Date.valueOf( endDateTime) ) +
                    ' and Core_MessageType__c in (' + String.valueOf( outboundMessageTypes ) + ') ';
            
            if (contactId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( contactId ) + '%\' ';
            if (emailAddr != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( emailAddr ) + '%\' ';
            if (erpmPersonId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( erpmPersonId ) + '%\' ';
            if (enterpriseId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( enterpriseId ) + '%\' ';
        }
        soql += ' limit ' + String.valueOf( RECORD_LIMIT );
        outboundMessageSoql = soql;
        return soql;
    }
    
    // Build inbound message SOQL
    private String buildInboundMessageSoql(Boolean searchMessagesLogsById) {
        String soql = 'select Id, LastModifiedDate, Core_Source_System__c, Core_Message_Type__c, Core_Processing_Status__c, Core_Payload__c, ' +
            'Core_Exception_Message__c, Core_Log_Entry__c ' +
            'from Core_Integration_Inbound_Message__c ' +
            'where ';
        if (searchMessagesLogsById) {
            soql += ' Id = \'' + String.escapeSingleQuotes( inboundMessageId ) + '\' ';
        }
        else {
            String inboundMessageTypes = 
                (messageTypes == 'All') ? '\'Contact\', \'Account\', \'Blackbox\', \'Role\'' :
                    (messageTypes == 'ERPM') ? '\'Contact\', \'Account\', \'Blackbox\'' :
                        (messageTypes == 'ERPM Contact') ? '\'Contact\'' :
                            (messageTypes == 'ERPM Account') ? '\'Account\'' :
                                (messageTypes == 'ERPM Blackbox') ? '\'Blackbox\'' :
                                    (messageTypes == 'AGS') ? '\'Role\'' : '\'XXXXXXXXXX\'';
            
            // Use controller field inboundProcessingStatus (ensure it's set)
            if (statusValue != null) {
                inboundProcessingStatus = (statusValue == 'All') ? '\'Successful\', \'Failed\'' : '\'' + String.escapeSingleQuotes(statusValue) + '\'';
            } else {
                inboundProcessingStatus = '\'Successful\', \'Failed\'';
            }
            
            soql += ' LastModifiedDate >= ' + soqlFormat( Date.valueOf ( startDateTime ) ) +
                ' and LastModifiedDate < ' + soqlFormat(  Date.valueOf ( endDateTime ) ) +
                ' and Core_Message_Type__c in (' + String.valueOf ( inboundMessageTypes ) + ') ' +
                ' and Core_Processing_Status__c in (' +  String.valueOf ( inboundProcessingStatus ) + ') ';
            
            if (contactId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( contactId ) + '%\' ';
            if (emailAddr != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( emailAddr ) + '%\' ';
            if (erpmPersonId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( erpmPersonId ) + '%\' ';
            if (enterpriseId != '')
                soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( enterpriseId ) + '%\' ';
        }
        soql += ' limit ' + String.valueOf( RECORD_LIMIT ) ;
        inboundMessageSoql = soql;
        return soql;
    }
    
    // Build log entry SOQL
    private String buildLogEntrySoql(Boolean searchMessagesLogsById) {
        String soql = 'select Id, LastModifiedDate, Core_Severity__c, Core_Message__c, Core_Details__c, ' +
            	'Core_sObjectType__c, Core_sObjectId__c, Core_Tags__c ' +
            'from Core_Log_Entry__c ' +
            'where ';
        if (searchMessagesLogsById) {
            soql += ' (Id != null ';
            if (logEntryId != '')
               soql += ' and Id = \'' + String.escapeSingleQuotes( logEntryId ) + '\' ';
            if (inboundMessageId != '')
               soql += ' and Core_sObjectId__c = \'' + String.escapeSingleQuotes( inboundMessageId ) + '\' ';
            if (outboundMessageId != '')
               soql += ' and Core_sObjectId__c = \'' + String.escapeSingleQuotes( outboundMessageId ) + '\' ';
            soql += ') ';
        }
        else if ((contactId != '') || (erpmPersonId != '') || (enterpriseId != '') || (emailAddr != '')) {
            soql += ' (Id != null ';
            if (contactId != '')
               soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( contactId ) + '%\' ';
            if (emailAddr != '')
               soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( emailAddr ) + '%\' ';
            if (erpmPersonId != '')
               soql += ' and Core_Tags__c like \'%' + String.escapeSingleQuotes( erpmPersonId ) + '%\' ';
            if (enterpriseId != '')
               soql += ' and Core_Tags__c like \'%' +  String.escapeSingleQuotes( enterpriseId ) + '%\' ';
            soql += ') ';
            soql += ' and LastModifiedDate >= ' + soqlFormat( Date.valueOf ( startDateTime) ) +
                 ' and LastModifiedDate < ' + soqlFormat( Date.valueOf ( endDateTime) );
        }
        else {
             soql += ' LastModifiedDate >= ' + soqlFormat( Date.valueOf ( startDateTime) ) +
                ' and LastModifiedDate < ' + soqlFormat( Date.valueOf ( endDateTime ) ) ;
        }
        soql += ' and Core_sObjectType__c in (\'Core_Integration_Inbound_Message__c\',\'Core_Integration_Outbound_Message__c\') ';
        soql += ' limit ' + String.valueOf( RECORD_LIMIT ) ;
        logEntrySoql = soql;
        return soql;
    }
    
    private void consolidateInboundOutboundMessages() {
        
        messageHistory = new List<SortableObject>();
        
        for (Core_Integration_Outbound_Message__c msg : outboundMessages)
            messageHistory.add(new SortableObject(msg));
        
        for (Core_Integration_Inbound_Message__c msg : inboundMessages)
            messageHistory.add(new SortableObject(msg));
        
        messageHistory.sort();
        
        if (messageHistory.size() > 0)
            showMessageHistory = true;
    }
    
    /*private void debugSearchResults() {
        for (Contact c : contacts)
            System.debug('====> Contact: ' + c);
        for (Core_Contact_Entitlement__c ce : contactEntitlements)
            System.debug('====> Contact Entitlement: ' + ce);
        for (Core_Integration_Outbound_Message__c msg : outboundMessages)
            System.debug('====> Outbound Messages: ' + msg);
        for (Core_Integration_Inbound_Message__c msg : inboundMessages)
            System.debug('====> Inbound Messages: ' + msg);
        for (SortableObject msg : messageHistory)
            System.debug('====> ' + msg.objectType + ': ' + msg.record);
        for (Core_Log_Entry__c logEntry : logEntries)
            System.debug('====> Log Entry: ' + logEntry);
    }*/

    // Generic object wrapper that will let us put everything in chronological order across different object types
    public class SortableObject implements Comparable {
        
        private sObject record;
        
        public Id recordId { get; set; }
        public DateTime lastModifiedDate { get; set; }
        public String objectType { get; set; }
        public String status { get; set; }
        public String title { get; set; }
        public String details { get; set; }
        public Id objectId { get; set; }
        public String tags { get; set; }
        
        public SortableObject(sObject rec) {
            record = rec;
            recordId = (Id) rec.get('Id');
            lastModifiedDate = (DateTime) rec.get('LastModifiedDate');
            
            if (rec.getSObjectType() == Schema.Core_Integration_Inbound_Message__c.getSObjectType()) {
                objectType = 'Inbound';
                status = (String) rec.get('Core_Processing_Status__c');
                title = (String) rec.get('Core_Source_System__c') + ' ' + rec.get('Core_Message_Type__c');
                details = (String) rec.get('Core_Payload__c');
                objectId = null;
                tags = '';
            }
            else if (rec.getSObjectType() == Schema.Core_Integration_Outbound_Message__c.getSObjectType()) {
                objectType = 'Outbound';
                status = '';
                title = (String) rec.get('Core_MessageType__c');
                details = (String) rec.get('Core_Payload__c');
                objectId = null;
                tags = '';
            }
            /*else if (rec.getSObjectType() == Schema.Core_Log_Entry__c.getSObjectType()) {
                objectType = 'Log Entry';
                status = (String) rec.get('Core_Severity__c');
                title = (String) rec.get('Core_Message__c');
                details = (String) rec.get('Core_Details__c');
                objectId = (Id) rec.get('Core_sObjectId__c');
                tags = (String) rec.get('Core_Tags__c');
            }*/
        }
        
        public Integer compareTo(Object compareTo) {
            SortableObject compareToOppy = (SortableObject)compareTo;
            Integer returnValue = 0; // 0 = indicates that both elements are equal
            if ((DateTime) record.get('LastModifiedDate') > (DateTime) compareToOppy.record.get('LastModifiedDate')) {
                returnValue = 1;
            } else if ((DateTime) record.get('LastModifiedDate') < (DateTime) compareToOppy.record.get('LastModifiedDate')) {
                returnValue = -1;
            }
            return returnValue;
        }
    }
}