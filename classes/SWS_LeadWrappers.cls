/**
 * Apex Class Name: SWS_LeadWrappers
 * Version: 1.0
 * Created Date: 2026-03-11
 * Description: Centralized wrapper/data transfer types extracted from Core_LeadHandler to address long parameter list issues.
 * Notes:
 *  - This class is a container for wrapper/DTO types only. No business logic, SOQL, or DML.
 *  - Moving these types out enables reuse and shorter method signatures across classes.
 */
public with sharing class SWS_LeadWrappers {
    // Ensure this class is properly recognized by the compiler
    // This class contains wrapper classes used by Core_PartnerLeadHandler

    /**
     * ConversionContext
     * Purpose: Holds state and collections used throughout lead conversion deduplication processing.
     * This is a pure data container; initialization of fields is left to the caller where business logic resides.
     */
    public class ConversionContext {
        public Map<Id, Id> mapLeadIdAccountId = new Map<Id, Id>();
        public Map<Id, Id> mapLeadIdContactId = new Map<Id, Id>();
        public Map<Id, Id> mapContactIdLeadId = new Map<Id, Id>();
        public Map<Id, Id> mapAccountIdLeadId = new Map<Id, Id>();
        public List<Lead> lstConvertedLeads = new List<Lead>();
        public List<String> lstWriteableFields = new List<String>();
        public List<Account> lstAccounts = new List<Account>();
        public List<Contact> lstContacts = new List<Contact>();
        public Set<String> setAddressDetails = new Set<String>();
        public Map<String, List<Account>> mapEmailAccounts = new Map<String, List<Account>>();
        public Map<Id, Account> mapAccountIdAccount = new Map<Id, Account>();
        public Map<Id, Contact> mapContactIdContact = new Map<Id, Contact>();
        public Set<String> setEmailIds = new Set<String>();
        public Map<String, Contact> mapEmailContactslist = new Map<String, Contact>();
        public List<Contact> lstUpdateContacts = new List<Contact>();
        public List<Id> lstDeleteRecords = new List<Id>();
        public List<Id> lstUpdateAccounts = new List<Id>();
        public List<AccountContactRole> lstAccountContactRole = new List<AccountContactRole>();
        public List<OpportunityContactRole> lstOpportunityContactRole = new List<OpportunityContactRole>();
        public Map<Id, Id> mapConvertedOpportunityIdAccountId = new Map<Id, Id>();
        public Map<Id, Id> mapExistingAccountIdConvertedAccountId = new Map<Id, Id>();
        public Map<Id, Id> mapExistingContactIdConvertedContactId = new Map<Id, Id>();
        public List<Id> lstContactUpdateIds = new List<Id>();
    }

    /**
     * AccountDedupParams
     * Purpose: Fluent parameter object to carry commonly used parameters across dedup routines.
     */
    public class AccountDedupParams {
        public SWS_LeadWrappers.ConversionContext ctx;
        public Lead leadInstance;
        public Account accountInstance;
        public Map<Id, Lead> mapNewIdLeads;

        public AccountDedupParams setContext(SWS_LeadWrappers.ConversionContext ctx) {
            this.ctx = ctx;
            return this;
        }

        public AccountDedupParams setLead(Lead leadInstance) {
            this.leadInstance = leadInstance;
            return this;
        }

        public AccountDedupParams setAccount(Account accountInstance) {
            this.accountInstance = accountInstance;
            return this;
        }

        public AccountDedupParams setLeadMap(Map<Id, Lead> mapNewIdLeads) {
            this.mapNewIdLeads = mapNewIdLeads;
            return this;
        }
    }

    /**
     * DmlContext
     * Purpose: Aggregates collections/maps for post-processing DML blocks.
     */
    public class DmlContext {
        public List<Contact> lstUpdateContacts;
        public List<AccountContactRole> lstAccountContactRole;
        public List<OpportunityContactRole> lstOpportunityContactRole;
        public Map<Id, Id> mapConvertedOpportunityIdAccountId;
        public Map<Id, Id> mapExistingContactIdConvertedContactId;
        public Map<Id, Id> mapContactIdLeadId;
        public Map<Id, Id> mapExistingAccountIdConvertedAccountId;
        public Map<Id, Id> mapAccountIdLeadId;
        public Map<Id, Lead> mapNewIdLeads;

        public DmlContext(SWS_LeadWrappers.ConversionContext ctx, Map<Id, Lead> mapNewIdLeads) {
            this.lstUpdateContacts = ctx.lstUpdateContacts;
            this.lstAccountContactRole = ctx.lstAccountContactRole;
            this.lstOpportunityContactRole = ctx.lstOpportunityContactRole;
             System.debug('DmlContext fn --->'+ ctx.mapConvertedOpportunityIdAccountId);
            this.mapConvertedOpportunityIdAccountId = ctx.mapConvertedOpportunityIdAccountId;
            System.debug('DmlContext fn');
            this.mapExistingContactIdConvertedContactId = ctx.mapExistingContactIdConvertedContactId;
            this.mapContactIdLeadId = ctx.mapContactIdLeadId;
            this.mapExistingAccountIdConvertedAccountId = ctx.mapExistingAccountIdConvertedAccountId;
            this.mapAccountIdLeadId = ctx.mapAccountIdLeadId;
            this.mapNewIdLeads = mapNewIdLeads;
        }
    }

    /**
     * ErrorContext
     * Purpose: Parameter object for centralized DML error handling.
     */
    public class ErrorContext {
        public Database.SaveResult[] srList;
        public List<SObject> records;
        public Map<Id, Id> mapId1Id2;
        public Map<Id, Id> mapId2LeadId;
        public Map<Id, Lead> mapNewIdLeads;

        public ErrorContext setSaveResults(Database.SaveResult[] srList) {
            this.srList = srList;
            return this;
        }

        public ErrorContext setRecords(List<SObject> records) {
            this.records = records;
            return this;
        }

        public ErrorContext setIdMapping(Map<Id, Id> mapId1Id2) {
            this.mapId1Id2 = mapId1Id2;
            return this;
        }

        public ErrorContext setLeadMapping(Map<Id, Id> mapId2LeadId) {
            this.mapId2LeadId = mapId2LeadId;
            return this;
        }

        public ErrorContext setLeadMap(Map<Id, Lead> mapNewIdLeads) {
            this.mapNewIdLeads = mapNewIdLeads;
            return this;
        }
    }

    /**
     * LeadConvertRequest
     * Purpose: DTO for Invocable action parameters when converting lead to an existing contact.
     */
    public class LeadConvertRequest {
        @InvocableVariable(required=true)
        public Id leadId;

        @InvocableVariable(required=true)
        public Id contactId;
    }

    // ============================================
    // Wrappers/DTOs extracted from Core_PartnerLeadHandler
    // ============================================

    // Parameter-bag to reduce parameter list for processLeads
    public class ProcessLeadsCtx {
        public List<Lead> finalLeadList;
        public Map<String, List<Lead>> marketingProfileLeadsMap;
        public Map<String, List<Lead>> partnerNameLeadsMap;
    }

    // Context for assigning MPI to leads based on OPID mappings
    public class AssignMpiCtx {
        public Map<String, Set<Lead>> opidLeadSetMap;
        public Map<String, String> opidPartnerNameFromQueueMapping;
        public Map<String, List<Lead>> partnerNameLeadsMap;
        public Map<String, Core_Partner_Queue_Mapping__c> partnerNameQueueMap;
        public Set<String> availableOpidFromMpiJunction;
    }

    // Grouping context used during partner lead routing
    public class GroupLeadsCtx {
        public Map<String, List<Lead>> allMpiLeadsMap;
        public Map<String, List<Lead>> offeringRelatedMpiLeadsMap;
        public List<Lead> finalLeadList;
    }

    // Parameter-bag for OLR (OPID Lead Relationship) processing
    public class ProcessOlrCtx {
        public Map<Id, Core_Partner_Queue_Mapping__c> newQueueMap;
        public Map<String, Lead> finalLeadMap;
        public Map<String, Lead> finalLeadPlclMap;
        public Map<String, List<String>> finalGroupsNLeadsMap;
    }

    // DTO for group-wise email preparation (simple list email)
    public class PrepareEmailCtx {
        public Boolean isReminder;
        public String userId;
        public List<Lead> leadList;
        public List<Messaging.SingleEmailMessage> emailList;
    }

    // DTO for displayable leads in email content
    public class DisplayLeadsCtx { 
        public String baseUrl; 
        public String listViewUrl; 
        public List<Lead> leadList; 
        public Boolean isReminder; 

        public DisplayLeadsCtx(String baseUrl, String listViewUrl, List<Lead> leadList, Boolean isReminder) {
            this.baseUrl = baseUrl;
            this.listViewUrl = listViewUrl;
            this.leadList = leadList;
            this.isReminder = isReminder;
        }
    }

    // Helper for reminder email day-bucketing
    public class ReminderParams {
        public Date leadCreationDate; 
        public Date reminderDate; 
        public Lead led;
        
        public ReminderParams(Date leadCreationDate, Date reminderDate, Lead led) {
            this.leadCreationDate = leadCreationDate;
            this.reminderDate = reminderDate;
            this.led = led;
        }
    }

    // DTO for template-based emails
    public class PrepareTemplEmailCtx { 
        public String userId; 
        public Id leadId; 
        public Id emailTemplateId; 
        public List<Messaging.SingleEmailMessage> emailList;
    }

    // DTO for populating account sets for Ruby-team changes
    public class PopulateAccountSetsCtx { 
        public Set<String> userIdSet; 
        public Id intelAccRecTypeId; 
        public Set<Id> opidAccSet; 
        public Set<Id> accIdSet; 
    }
}