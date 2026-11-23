/****************************************************************************************************
Apex Class Name : SWS_Stale_Lead_Notification_Batch
Version         : 1.0
Created Date    : 2026-11-09
Function        : Identify Leads that WILL be auto-terminated by flow "Stale_Lead_Disposition" within
                   the upcoming notification window (configurable via SWS_Core_CRM_Labels__c), group
                   them by Lead Owner, and send ONE consolidated email per owner - sorted by soonest
                   to terminate first. Reuses the exact eligibility logic/filters used by the flow so
                   the notified set always matches what will actually be terminated.
Created By      : Naveen Muthuramalingam
Test Class      : SWS_Stale_Lead_Notification_BatchTest
Labels Used     : SWS_Lead_Created_Days, SWS_Lead_Modified_Days (existing),
                  SWS_Notification_Window_Days, SWS_Stale_Lead_Notification_Subject (new)
*****************************************************************************************************/
global without sharing class SWS_Stale_Lead_Notification_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private static final String LOG_ENTRY_ORIGIN   = 'Stale lead notification';
    private static final String LOG_ENTRY_SEVERITY = 'High';
    private static final String QUEUE_PREFIX       = '00G';
    private static final Integer EMAIL_CHUNK_SIZE   = 150;
    private static final String DEFAULT_SUBJECT     = 'Action Required: Lead Scheduled for Inactivity Disposition in 7 Days';

    // Window boundaries - computed once in start(), reused in execute()
    global Date windowStart;
    global Date windowEnd;

    // Accumulated across all execute() transactions. Keep light (ids + primitives only).
    global Map<Id, List<LeadWrapper>> ownerToLeads = new Map<Id, List<LeadWrapper>>();

    /************************************************************************************************************
    * Inner Class  : LeadWrapper
    * Description  : Lightweight carrier for the data needed to render one Lead row in the owner email.
    ************************************************************************************************************/
    global class LeadWrapper implements Comparable {
        global Id leadId;
        global String leadName;
        global Date terminationDate;
        global Integer daysToTerminate;

        global Integer compareTo(Object compareTo) {
            LeadWrapper other = (LeadWrapper) compareTo;
            return this.daysToTerminate - other.daysToTerminate;
        }
    }

    /************************************************************************************************************
    *Method Name : start
    *Description : Builds the notification window and returns a broad, sargable pre-filter of Leads that
    *              could possibly fall inside the window, mirroring the flow's Get_Leads filters.
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer createdDays  = getLabelAsInteger('SWS_Lead_Created_Days', 0);
        Integer modifiedDays = getLabelAsInteger('SWS_Lead_Modified_Days', 0);
        Integer windowDays   = getLabelAsInteger('SWS_Notification_Window_Days', 6);

        windowStart = Date.today().addDays(1);
        windowEnd   = Date.today().addDays(windowDays);

        DateTime createdBoundary  = DateTime.newInstance(windowEnd.addDays(-createdDays), Time.newInstance(23, 59, 59, 0));
        DateTime modifiedBoundary = DateTime.newInstance(windowEnd.addDays(-modifiedDays), Time.newInstance(23, 59, 59, 0));

        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId, CreatedDate,
                   SWS_Last_Modified_Date_By_Non_Sys_User__c,
                   Core_Lead_State__c, Core_Lead_Status__c,
                   RecordType.Name
            FROM Lead
            WHERE IsConverted = false
              AND Core_Lead_State__c != 'Terminated'
              AND Core_Lead_Status__c != 'Disqualified'
              AND RecordType.Name IN ('Sales Lead', 'Lead')
              AND CreatedDate <= :createdBoundary
              AND SWS_Last_Modified_Date_By_Non_Sys_User__c <= :modifiedBoundary
        ]);
    }

    /************************************************************************************************************
    *Method Name : execute
    *Description : For each Lead in scope, compute its exact termination date and bucket it under its
    *              owner if it falls within this week's notification window.
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        Integer createdDays  = getLabelAsInteger('SWS_Lead_Created_Days', 0);
        Integer modifiedDays = getLabelAsInteger('SWS_Lead_Modified_Days', 0);

        for (SObject so : scope) {
            processSingleLead((Lead) so, createdDays, modifiedDays);
        }
    }

    /************************************************************************************************************
    *Method Name : processSingleLead
    *Description : Isolated single-lead logic kept separate to limit cyclomatic complexity of execute().
    ************************************************************************************************************/
    private void processSingleLead(Lead ld, Integer createdDays, Integer modifiedDays) {
        Date terminationDate = calculateTerminationDate(ld, createdDays, modifiedDays);

        if (!isEligibleForNotification(ld, terminationDate)) {
            return;
        }

        LeadWrapper w = buildLeadWrapper(ld, terminationDate);
        addToOwnerMap(ld.OwnerId, w);
    }

    /************************************************************************************************************
    *Method Name : calculateTerminationDate
    *Description : Same math as the flow's two formulas (LeadCreatedDate / LeadLastModifiedDate), combined:
    *              termination happens on the LATER of the two thresholds being crossed.
    ************************************************************************************************************/
    private Date calculateTerminationDate(Lead ld, Integer createdDays, Integer modifiedDays) {
        if (ld.CreatedDate == null || ld.SWS_Last_Modified_Date_By_Non_Sys_User__c == null) {
            return null;
        }
        Date createdEligible  = ld.CreatedDate.date().addDays(createdDays);
        Date modifiedEligible = ld.SWS_Last_Modified_Date_By_Non_Sys_User__c.date().addDays(modifiedDays);
        return createdEligible > modifiedEligible ? createdEligible : modifiedEligible;
    }

    /************************************************************************************************************
    *Method Name : isEligibleForNotification
    *Description : True only when termination date falls inside this week's window and the owner is a User.
    ************************************************************************************************************/
    private Boolean isEligibleForNotification(Lead ld, Date terminationDate) {
        if (terminationDate == null) {
            return false;
        }
        if (terminationDate < windowStart || terminationDate > windowEnd) {
            return false;
        }
        if (ld.OwnerId == null || String.valueOf(ld.OwnerId).startsWith(QUEUE_PREFIX)) {
            return false;
        }
        return true;
    }

    /************************************************************************************************************
    *Method Name : buildLeadWrapper
    *Description : Maps a Lead + its termination date into the lightweight wrapper used for stateful storage.
    ************************************************************************************************************/
    private LeadWrapper buildLeadWrapper(Lead ld, Date terminationDate) {
        LeadWrapper w = new LeadWrapper();
        w.leadId = ld.Id;
        w.leadName = ld.Name;
        w.terminationDate = terminationDate;
        w.daysToTerminate = Date.today().daysBetween(terminationDate);
        return w;
    }

    /************************************************************************************************************
    *Method Name : addToOwnerMap
    *Description : Appends a wrapper to the owner's list, lazily creating the list if needed.
    ************************************************************************************************************/
    private void addToOwnerMap(Id ownerId, LeadWrapper w) {
        if (!ownerToLeads.containsKey(ownerId)) {
            ownerToLeads.put(ownerId, new List<LeadWrapper>());
        }
        ownerToLeads.get(ownerId).add(w);
    }

    /************************************************************************************************************
    *Method Name : finish
    *Description : Builds and sends one consolidated email per Lead Owner, chunked to stay within
    *              Messaging.sendEmail() governor limits, then logs any failures.
    ************************************************************************************************************/
    global void finish(Database.BatchableContext bc) {
        if (ownerToLeads.isEmpty()) {
            return;
        }

        Map<Id, User> ownerMap = getOwnerMap();
        List<Messaging.SingleEmailMessage> allMessages = buildAllMessages(ownerMap);
        sendInChunks(allMessages);
    }

    /************************************************************************************************************
    *Method Name : getOwnerMap
    *Description : Single bulk query for all distinct Lead Owners accumulated during execute().
    ************************************************************************************************************/
    private Map<Id, User> getOwnerMap() {
        return new Map<Id, User>([
            SELECT Id, Name FROM User WHERE Id IN :ownerToLeads.keySet()
        ]);
    }

    /************************************************************************************************************
    *Method Name : buildAllMessages
    *Description : Iterates owners, sorts each owner's leads by soonest-to-terminate, and builds one
    *              email message per owner.
    ************************************************************************************************************/
    private List<Messaging.SingleEmailMessage> buildAllMessages(Map<Id, User> ownerMap) {
        List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
        for (Id ownerId : ownerToLeads.keySet()) {
            List<LeadWrapper> leads = ownerToLeads.get(ownerId);
            leads.sort();
            allMessages.add(buildEmail(ownerId, ownerMap.get(ownerId), leads));
        }
        return allMessages;
    }

    /************************************************************************************************************
    *Method Name : buildEmail
    *Description : Builds the full HTML body + subject (from custom setting) for a single owner's email.
    ************************************************************************************************************/
    private Messaging.SingleEmailMessage buildEmail(Id ownerId, User owner, List<LeadWrapper> leads) {
        String body = buildEmailBody(leads);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(ownerId);
        mail.setSaveAsActivity(false);
        mail.setSubject(getLabelAsString('SWS_Stale_Lead_Notification_Subject', DEFAULT_SUBJECT));
        mail.setHtmlBody(body);
        return mail;
    }

    /************************************************************************************************************
    *Method Name : buildEmailBody
    *Description : Builds the complete HTML email body in Apex. Renders one block per Lead in the format:
    *              "Lead: <Name>", "Disposition Date: <Date>", "Action: <static guidance text>" -
    *              blocks are already in soonest-to-terminate-first order because leads were pre-sorted.
    ************************************************************************************************************/
    private String buildEmailBody(List<LeadWrapper> leads) {
        String leadBlocks = buildLeadBlocksHtml(leads);

        String body = '<html><body style="font-family:Arial,sans-serif;">';
        body += '<p>The following MQL' + (leads.size() > 1 ? 's are' : ' is') + ' scheduled for automated '
              +  'inactivity disposition within the next 7 days.</p>';
        body += leadBlocks;
        body += '<p style="font-size:11px;color:#777;">This is an automated notification from the Stale Lead Disposition process.</p>';
        body += '</body></html>';
        return body;
    }

    /************************************************************************************************************
    *Method Name : buildLeadBlocksHtml
    *Description : Builds one HTML block per Lead with Lead / Disposition Date / Action lines, isolated
    *              to keep buildEmailBody() simple and limit cyclomatic complexity.
    ************************************************************************************************************/
    private String buildLeadBlocksHtml(List<LeadWrapper> leads) {
        String blocks = '';
        for (LeadWrapper w : leads) {
            blocks += buildSingleLeadBlock(w);
        }
        return blocks;
    }

    /************************************************************************************************************
    *Method Name : buildSingleLeadBlock
    *Description : Builds the HTML block for exactly one Lead.
    ************************************************************************************************************/
    private String buildSingleLeadBlock(LeadWrapper w) {
        String block = '<div style="margin:0 0 16px 0;padding:10px 0;border-bottom:1px solid #e0e0e0;">';
        block += '<p style="margin:0;"><b>Lead:</b> ' + escapeForHtml(w.leadName) + '</p>';
        block += '<p style="margin:0;"><b>Disposition Date:</b> ' + formatDispositionDate(w.terminationDate) + '</p>';
        block += '<p style="margin:0;"><b>Action:</b> Please review the Lead and complete the required '
              +  'qualifying activity before the disposition date.</p>';
        block += '</div>';
        return block;
    }

    /************************************************************************************************************
    *Method Name : formatDispositionDate
    *Description : Formats the termination date as "Month Day" (e.g. "November 20"), matching the
    *              requested email copy format.
    ************************************************************************************************************/
    private String formatDispositionDate(Date terminationDate) {
        return DateTime.newInstance(terminationDate, Time.newInstance(0, 0, 0, 0)).format('MMMM d');
    }

    /************************************************************************************************************
    *Method Name : escapeForHtml
    *Description : Safely HTML-escapes a string for embedding in the email body. escapeHtml4() is an
    *              INSTANCE method on String (e.g. myString.escapeHtml4()), not a static utility, so this
    *              wrapper also guards against null input before calling it.
    ************************************************************************************************************/
    private String escapeForHtml(String value) {
        return String.isBlank(value) ? '' : value.escapeHtml4();
    }

    /************************************************************************************************************
    *Method Name : sendInChunks
    *Description : Sends messages in chunks of EMAIL_CHUNK_SIZE to remain within per-call/transaction limits.
    ************************************************************************************************************/
    private void sendInChunks(List<Messaging.SingleEmailMessage> allMessages) {
        List<Messaging.SendEmailResult> allResults = new List<Messaging.SendEmailResult>();
        Integer total = allMessages.size();

        for (Integer i = 0; i < total; i += EMAIL_CHUNK_SIZE) {
            List<Messaging.SingleEmailMessage> chunk = getChunk(allMessages, i, total);
            allResults.addAll(Messaging.sendEmail(chunk, false));
        }
        logFailures(allResults);
    }

    /************************************************************************************************************
    *Method Name : getChunk
    *Description : Extracts a sub-list of messages for a single Messaging.sendEmail() call.
    ************************************************************************************************************/
    private List<Messaging.SingleEmailMessage> getChunk(List<Messaging.SingleEmailMessage> allMessages, Integer startIndex, Integer total) {
        List<Messaging.SingleEmailMessage> chunk = new List<Messaging.SingleEmailMessage>();
        Integer upper = Math.min(startIndex + EMAIL_CHUNK_SIZE, total);
        for (Integer j = startIndex; j < upper; j++) {
            chunk.add(allMessages[j]);
        }
        return chunk;
    }

    /************************************************************************************************************
    *Method Name : logFailures
    *Description : Writes a Core_Log_Entry__c for every failed send, consistent with the flow's fault handling.
    ************************************************************************************************************/
    private void logFailures(List<Messaging.SendEmailResult> results) {
        List<Core_Log_Entry__c> logs = new List<Core_Log_Entry__c>();
        for (Messaging.SendEmailResult r : results) {
            if (!r.isSuccess()) {
                logs.add(buildLogEntry(r));
            }
        }
        if (!logs.isEmpty()) {
            insert logs;
        }
    }

    /************************************************************************************************************
    *Method Name : buildLogEntry
    *Description : Builds a single Core_Log_Entry__c record for a failed email result.
    ************************************************************************************************************/
    private Core_Log_Entry__c buildLogEntry(Messaging.SendEmailResult r) {
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        log.Core_Origin__c = LOG_ENTRY_ORIGIN;
        log.Core_Details__c = r.getErrors().isEmpty() ? 'Unknown error' : r.getErrors()[0].getMessage();
        log.Core_sObjectType__c = 'Lead';
        log.Core_When__c = DateTime.now();
        log.Core_Severity__c = LOG_ENTRY_SEVERITY;
        return log;
    }

    /************************************************************************************************************
    *Method Name : getLabelAsInteger
    *Description : Reads an Integer value from SWS_Core_CRM_Labels__c by key, with a safe default fallback.
    ************************************************************************************************************/
    private Integer getLabelAsInteger(String labelKey, Integer defaultValue) {
        String raw = getLabelAsString(labelKey, null);
        return String.isBlank(raw) ? defaultValue : Integer.valueOf(raw.trim());
    }

    /************************************************************************************************************
    *Method Name : getLabelAsString
    *Description : Reads a String value from SWS_Core_CRM_Labels__c by key, with a safe default fallback.
    ************************************************************************************************************/
    private String getLabelAsString(String labelKey, String defaultValue) {
        SWS_Core_CRM_Labels__c setting = SWS_Core_CRM_Labels__c.getValues(labelKey);
        return (setting != null && String.isNotBlank(setting.SWS_Value__c)) ? setting.SWS_Value__c : defaultValue;
    }
}