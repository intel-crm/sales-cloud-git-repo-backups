/**************************************************************************************
Apex Class Name:  Core_LeadHandler
Version     : 1.0 
Created Date: 13 NOV 2014
Function    : methods to handle Lead Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             11/13/2014              Original Version
* Harshith M L              11/13/2014              Lead Conversion logic
* Kunal Mehta               11/18/2014              Sales Segment logic
* Venu Karumuru             05/15/2016              Added Method to assign Partner Leads to correct Partner Queues
* Venu Karumuru             09/13/2016              Deleted the use of Sales Segment field, replaced it with Sales Group
*************************************************************************************/
public without sharing class Core_LeadHandler{
    
    
    //Ensures that the trigger is running only once for Sales Group Mapping  
    public static boolean bSalesGroupMapping = true;
    
    //Ensures that the trigger is running only once for Account Team Member Population functionality  
    public static boolean bLeadConverted = true;
    
    /*
    * Method name  : leadObjectBeforeHandler
    * Description  : Matches the Billing state in the accounts and populates Geo/Sub Geo fields 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap,MAP Trigger.oldmap,Country field of Sobject
    */
    public static void leadObjectBeforeHandler(List<Lead> listNewLead,Map<Id,Lead> mapOldsObject)
    {
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        Core_Utility.sObjectGeoMappingField(listNewLead, mapOldsObject, new list<String>{'Country', 'CountryCode'}, 
                                            new list<String>{'State', 'StateCode'}, 'Core_Geo__c','Core_Sub_Geo__c');
    }
    
    /*
    * Method name  : leadObjectSalesGroup
    * Description  : To copy the Sales Group information from Leads page to Account Sales Group 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap,MAP Trigger.oldmap
    */
    
    public static void leadObjectSalesGroup(List<Lead> listNewLead)
    {   
        if(isSalesGroupMapped())
        {
            //To copy the Sales Group information from Leads page to Account Sales Group
            for(Lead leadSalesGroup : listNewLead)
            {
                leadSalesGroup.Core_System_Account_Sales_Group__c = leadSalesGroup.Core_Sales_Group__c;
            }
        }
        
    }
    

    
    /*
    * Method name  : deleteUpdateContactRecords
    * Description  : Future method to update/delete Account & Contact records after lead conversion
    * Return Type  : Void
    * Parameter    : List<Id>, List<Id>,List<Id>
    */
    @future 
    public static void deleteUpdateContactRecords(List<Id> lstDeleteRecords,List<Id> lstUpdateContacts,List<Id> lstUpdateAccounts) 
    {
        if(!lstUpdateContacts.isEmpty())
        {
            List<Contact> lstContacts = new List<Contact>();
            
            // Unchecking the flag on contact and updating the contact list 
            for(Id contactId : lstUpdateContacts)
            {
                Contact contactInstance = new Contact(Id=contactId, Core_Lead_Conversion_Flag__c = false);
                lstContacts.add(contactInstance);
            }
            
            
            Database.SaveResult[] srList = Database.update(lstContacts, false);
        }
        
        if(!lstUpdateAccounts.isEmpty())
        {
            List<Account> lstAccounts = new List<Account>();
            
            // Unchecking the flag on contact and updating the contact list 
            for(Id accountId : lstUpdateAccounts)
            {
                Account accountInstance  = new Account(Id=accountId, Core_Lead_Conversion_Flag__c = false);
                lstAccounts.add(accountInstance);
            }
            
            
            Database.SaveResult[] srList = Database.update(lstAccounts, false);
        }
        
        if(!lstDeleteRecords.isEmpty())
        {  
            // Deleting the list of Contact and Account records
            Database.DeleteResult[] deletedRecords = Database.delete(lstDeleteRecords, false);            
        }
    }
    
    /*
    * Method name  : isLeadConverted
    * Description  : Ensures that the trigger is running only once during "Lead Conversion"
    * Return Type  : boolean
    * Parameter    : NONE
    */
    public static boolean isLeadConverted() {
        // Set the bolean to TRUE once the trigger is RUN
        if (bLeadConverted) {
            return true;
        } else {
            return bLeadConverted;
        }
    }
    
    /*
    * Method name  : isSalesGroupMapped
    * Description  : Ensures that the trigger is running only once during "Sales Group Mapping"
    * Return Type  : boolean
    * Parameter    : NONE
    */
    public static boolean isSalesGroupMapped() {
        // Set the bolean to TRUE once the trigger is RUN
        if (bSalesGroupMapping ) {
            bSalesGroupMapping = false;
            return true;
        } else {
            return bSalesGroupMapping ;
        }
    }
    
    
    
    /*
    * Method name  : LoadPartnerToQueueIdMapping
    * Description  : Helper method to create mappings between partner names and their queue ids using data in Core_Partner_Queue_Mapping__c custom object
    * Return Type  : Map<String, Id>
    * Parameter    : None
    */
    public static Map<String, Id> LoadPartnerToQueueIdMapping() {
        
        // Structures to store initial data
        Map<String, String> mapPartnerNameQueueName = new Map<String, String>();
        Map<String, Id> mapQueueNameQueueId = new Map<String, Id>();
        // Structure to store final data
        Map<String, Id> mapPartnerNameQueueId = new Map<String, Id>();
        
        // Get all the Active records from Partner to Queue Mapping Object
        List<Core_Partner_Queue_Mapping__c> lstParterQueue = [SELECT Core_Partner_Name__c, Core_Queue_Name__c, Core_Active__c FROM Core_Partner_Queue_Mapping__c WHERE Core_Active__c = true];
        
        // Store the mappings between Partner Name and Queue Name
        for (Core_Partner_Queue_Mapping__c record :lstParterQueue) {
            mapPartnerNameQueueName.put(record.Core_Partner_Name__c.touppercase(), record.Core_Queue_Name__c);
        }
        
        // Get and store the Queue Ids using the Queue Names
        List<QueueSobject> lstQueues = [SELECT QueueId, Queue.DeveloperName FROM QueueSobject WHERE SobjectType = 'Lead' AND Queue.DeveloperName IN :mapPartnerNameQueueName.values()];
        for (QueueSobject queue :lstQueues) {
            mapQueueNameQueueId.put(queue.Queue.DeveloperName, queue.QueueId);
        }
        
        // Create the mapping between Partner Name and Queue Id
        for (String sPartnerName :mapPartnerNameQueueName.keySet()) {
            if (sPartnerName != null) {
                String sQueueName = mapPartnerNameQueueName.get(sPartnerName);
                Id idQueue = mapQueueNameQueueId.get(sQueueName);
                if (sQueueName != null && idQueue != null) {
                    mapPartnerNameQueueId.put(sPartnerName, idQueue);
                }
            }
        }
        
        return mapPartnerNameQueueId;
    }
    
    
  public static void AssignLeadsToPartnerQueues(Lead[] newLeads) {
    if (!arePartnerQueueLabelsSet()) return;

    Set<Id> partnerLeadIds = getPartnerLeadIds(newLeads);
    if (partnerLeadIds.isEmpty()) return;

        Map<String, Id> partnerNameToQueueId = LoadPartnerToQueueIdMapping();
        List<Lead> partnerLeads = getPartnerLeadsByIds(partnerLeadIds);

        assignOwnersToPartnerLeads(partnerLeads, partnerNameToQueueId);

        if (!partnerLeads.isEmpty()) {
            update partnerLeads;
        }
    }

    private static Boolean arePartnerQueueLabelsSet() {
        return System.Label.Core_Partner_Global_Queue_Id != null &&
               System.Label.Core_Partner_Invalid_Queue_Id != null &&
               System.Label.Core_Partner_Lead_Record_Id != null;
    }
    
    private static Set<Id> getPartnerLeadIds(Lead[] leads) {
        Set<Id> ids = new Set<Id>();
        for (Lead lead : leads) {
            if (isPartnerLeadForGlobalQueue(lead)) {
                ids.add(lead.Id);
            }
        }
        return ids;
    }
    
    private static Boolean isPartnerLeadForGlobalQueue(Lead lead) {
        return lead.RecordTypeId == System.Label.Core_Partner_Lead_Record_Id &&
               lead.Core_Partner_Name__c != null &&
               lead.OwnerId == System.Label.Core_Partner_Global_Queue_Id;
    }
    
    private static List<Lead> getPartnerLeadsByIds(Set<Id> ids) {
        if (ids.isEmpty()) return new List<Lead>();
        return [SELECT Id, Core_Partner_Name__c FROM Lead WHERE Id IN :ids];
    }
    
    private static void assignOwnersToPartnerLeads(List<Lead> leads, Map<String, Id> partnerNameToQueueId) {
        for (Lead lead : leads) {
            Id queueId = partnerNameToQueueId.get(lead.Core_Partner_Name__c != null ? lead.Core_Partner_Name__c.touppercase() : null);
            lead.OwnerId = (queueId != null) ? queueId : System.Label.Core_Partner_Invalid_Queue_Id;
        }
    }
      
    public static void leadConversionDeduplication(Map<Id, Lead> mapNewIdLeads, Map<Id, Lead> mapOldIdLeads) {
        if (!isLeadConverted()) return;
    
        // Step 1: Gather converted leads and build key maps
        SWS_LeadWrappers.ConversionContext ctx = buildConversionContext(mapNewIdLeads, mapOldIdLeads);
        if (ctx.lstConvertedLeads.isEmpty()) return;
        bLeadConverted = false;
    
        // Step 2: Query related data
        ctx.lstAccounts = getAccounts(ctx.mapLeadIdAccountId);
        ctx.lstContacts = getContacts(ctx.mapLeadIdContactId, ctx.lstWriteableFields);
        ctx.setAddressDetails = getAccountAddresses(ctx.lstAccounts);
        ctx.mapAccountIdAccount = new Map<Id, Account>(ctx.lstAccounts);
        ctx.mapContactIdContact = new Map<Id, Contact>(ctx.lstContacts);
    
        // Step 3: Find duplicate accounts and contacts
        ctx.mapEmailAccounts = getDuplicateAccounts(ctx.setAddressDetails, ctx.mapLeadIdAccountId);
        ctx.setEmailIds = getContactEmails(ctx.lstContacts);
        ctx.mapEmailContactslist = getDuplicateContacts(ctx.setEmailIds, ctx.mapLeadIdContactId, ctx.lstWriteableFields);
    
        // Step 4: Deduplication logic
        processLeadDeduplication(ctx, mapNewIdLeads);
    
        // Step 5: DML and error handling
        performDedupDml(ctx, mapNewIdLeads);
    
        // Step 6: Cleanup
        deleteUpdateContactRecords(ctx.lstDeleteRecords, ctx.lstContactUpdateIds, ctx.lstUpdateAccounts);
    }
    
    // --- Helper Classes and Methods ---
    
    private static SWS_LeadWrappers.ConversionContext buildConversionContext(Map<Id, Lead> mapNewIdLeads, Map<Id, Lead> mapOldIdLeads) {
        SWS_LeadWrappers.ConversionContext ctx = new SWS_LeadWrappers.ConversionContext();
        // populate writable fields in this class (not in wrappers container)
        ctx.lstWriteableFields = getContactWriteableFields();
        for (Lead leadInstance : mapNewIdLeads.values()) {
            if (leadInstance.IsConverted && !mapOldIdLeads.get(leadInstance.id).IsConverted) {
                if (leadInstance.ConvertedAccountId != null) {
                    ctx.mapLeadIdAccountId.put(leadInstance.Id, leadInstance.ConvertedAccountId);
                    ctx.mapAccountIdLeadId.put(leadInstance.ConvertedAccountId, leadInstance.Id);
                }
                if (leadInstance.ConvertedContactId != null) {
                    ctx.mapLeadIdContactId.put(leadInstance.Id, leadInstance.ConvertedContactId);
                    ctx.mapContactIdLeadId.put(leadInstance.ConvertedContactId, leadInstance.Id);
                }
                ctx.lstConvertedLeads.add(leadInstance);
            }
        }
        return ctx;
    }
    
    private static List<Account> getAccounts(Map<Id, Id> mapLeadIdAccountId) {
        if (mapLeadIdAccountId.isEmpty()) return new List<Account>();
        return [SELECT Id, Name, Core_Address_Details__c, CreatedDate FROM Account WHERE Id IN :mapLeadIdAccountId.values()];
    }
    
    private static List<Contact> getContacts(Map<Id, Id> mapLeadIdContactId, List<String> lstWriteableFields) {
        if (mapLeadIdContactId.isEmpty() || lstWriteableFields.isEmpty()) return new List<Contact>();
        String sQueryContacts = Core_Utility.buildQuery('Contact', lstWriteableFields);
        sQueryContacts += ' WHERE Id IN (';
        for (String sContactId : mapLeadIdContactId.values()) {
            sQueryContacts += '\'' + sContactId + '\', ';
        }
        sQueryContacts = sQueryContacts.substring(0, sQueryContacts.length() - 2) + ')';
        return Database.query(sQueryContacts);
    }
    
    private static Set<String> getAccountAddresses(List<Account> accounts) {
        Set<String> addresses = new Set<String>();
        for (Account acct : accounts) {
            if (acct.Core_Address_Details__c != null) {
                addresses.add(acct.Core_Address_Details__c);
            }
        }
        return addresses;
    }
    
    private static Map<String, List<Account>> getDuplicateAccounts(Set<String> setAddressDetails, Map<Id, Id> mapLeadIdAccountId) {
        Map<String, List<Account>> mapEmailAccounts = new Map<String, List<Account>>();
        if (setAddressDetails.isEmpty()) return mapEmailAccounts;
        List<Account> lstAccountsEmail = [
            SELECT Id, Name, Core_Address_Details__c
            FROM Account
            WHERE Core_Address_Details__c IN :setAddressDetails
            AND Id NOT IN :mapLeadIdAccountId.values()
            AND Core_Address_Details__c != null
        ];
        for (Account acct : lstAccountsEmail) {
            if (!mapEmailAccounts.containsKey(acct.Core_Address_Details__c)) {
                mapEmailAccounts.put(acct.Core_Address_Details__c, new List<Account>());
            }
            mapEmailAccounts.get(acct.Core_Address_Details__c).add(acct);
        }
        return mapEmailAccounts;
    }
    
    private static Set<String> getContactEmails(List<Contact> contacts) {
        Set<String> emails = new Set<String>();
        for (Contact c : contacts) {
            if (c.Email != null && c.Email != '') {
                emails.add(c.Email);
            }
        }
        return emails;
    }
    
    private static Map<String, Contact> getDuplicateContacts(Set<String> setEmailIds, Map<Id, Id> mapLeadIdContactId, List<String> lstWriteableFields) {
        Map<String, Contact> mapEmailContactslist = new Map<String, Contact>();
        if (setEmailIds.isEmpty() || lstWriteableFields.isEmpty()) return mapEmailContactslist;
        String sQueryDuplicates = Core_Utility.buildQuery('Contact', lstWriteableFields);
        sQueryDuplicates += ' WHERE Email IN :setEmailIds';
        if (!mapLeadIdContactId.isEmpty()) {
            sQueryDuplicates += ' AND Id NOT IN (';
            for (String sContactId : mapLeadIdContactId.values()) {
                sQueryDuplicates += '\'' + sContactId + '\', ';
            }
            sQueryDuplicates = sQueryDuplicates.substring(0, sQueryDuplicates.length() - 2) + ')';
        }
        List<Contact> lstDuplicates = Database.query(sQueryDuplicates);
        for (Contact contactInstance : lstDuplicates) {
            mapEmailContactslist.put(contactInstance.Email, contactInstance);
        }
        return mapEmailContactslist;
    }
    
    private static void processLeadDeduplication(SWS_LeadWrappers.ConversionContext ctx, Map<Id, Lead> mapNewIdLeads) {
        for (Lead leadInstance : ctx.lstConvertedLeads) {
            if (!ctx.mapAccountIdAccount.containsKey(leadInstance.ConvertedAccountId)) continue;
            Account accountInstance = ctx.mapAccountIdAccount.get(leadInstance.ConvertedAccountId);
            
            // Using fluent interface pattern for inner classes
            SWS_LeadWrappers.AccountDedupParams params = new SWS_LeadWrappers.AccountDedupParams()
                .setContext(ctx)
                .setLead(leadInstance)
                .setAccount(accountInstance)
                .setLeadMap(mapNewIdLeads);
                
            if (accountInstance.CreatedDate > System.Now().addMinutes(-1)) {
                processNewAccountDedup(params);
            } else {
                processExistingAccountDedup(params);
            }
        }
        ctx.lstContactUpdateIds = getContactUpdateIds(ctx.lstConvertedLeads, ctx.lstDeleteRecords, ctx.lstUpdateContacts);
    }
    
    private static void processNewAccountDedup(SWS_LeadWrappers.AccountDedupParams params) {
        Boolean bDuplicateAccount = false;
        Account existingAccount;
        if (params.ctx.mapEmailAccounts.containsKey(params.accountInstance.Core_Address_Details__c)) {
            for (Account dupAccountInstance : params.ctx.mapEmailAccounts.get(params.accountInstance.Core_Address_Details__c)) {
                if (dupAccountInstance.Name.equalsIgnoreCase(params.leadInstance.Company)) {
                    bDuplicateAccount = true;
                    existingAccount = dupAccountInstance;
                    break;
                }
            }
        }
        if (bDuplicateAccount) {
            // Using fluent interface for new parameters
            SWS_LeadWrappers.AccountDedupParams duplicateParams = new SWS_LeadWrappers.AccountDedupParams()
                .setContext(params.ctx)
                .setLead(params.leadInstance)
                .setAccount(existingAccount)
                .setLeadMap(params.mapNewIdLeads);
            handleDuplicateAccount(duplicateParams);
        } else {
            handleNewAccount(params);
        }
    }
    
    private static void processExistingAccountDedup(SWS_LeadWrappers.AccountDedupParams params) {
        params.ctx.lstUpdateAccounts.add(params.leadInstance.ConvertedAccountId);
        params.ctx.mapExistingAccountIdConvertedAccountId.put(params.leadInstance.ConvertedAccountId, params.leadInstance.ConvertedAccountId);
        handleContactDedup(params);
    }
    
    private static void handleDuplicateAccount(SWS_LeadWrappers.AccountDedupParams params) {
        params.ctx.lstDeleteRecords.add(params.leadInstance.ConvertedAccountId);
        if (params.leadInstance.ConvertedOpportunityId != null) {
            params.ctx.mapConvertedOpportunityIdAccountId.put(params.leadInstance.ConvertedOpportunityId, params.accountInstance.Id);
        }
        params.ctx.mapExistingAccountIdConvertedAccountId.put(params.accountInstance.Id, params.leadInstance.ConvertedAccountId);
        handleContactDedup(params);
    }
    
    private static void handleNewAccount(SWS_LeadWrappers.AccountDedupParams params) {
        params.ctx.lstUpdateAccounts.add(params.leadInstance.ConvertedAccountId);
        params.ctx.mapExistingAccountIdConvertedAccountId.put(params.leadInstance.ConvertedAccountId, params.leadInstance.ConvertedAccountId);
        handleContactDedup(params);
    }
    
    private static void handleContactDedup(SWS_LeadWrappers.AccountDedupParams params) {
        Contact newContact = params.ctx.mapContactIdContact.get(params.leadInstance.ConvertedContactId);
        if (newContact == null) {
            return;
        }
        Contact oldContact = params.ctx.mapEmailContactslist.get(newContact.Email);
        if (oldContact != null && oldContact.AccountId == params.accountInstance.Id) {
            params.ctx.mapExistingContactIdConvertedContactId.put(oldContact.Id, newContact.Id);
            mergeContactFields(oldContact, newContact, params.ctx.lstWriteableFields);
            params.ctx.lstUpdateContacts.add(oldContact);
            params.ctx.lstDeleteRecords.add(params.leadInstance.ConvertedContactId);
        } else if (oldContact != null) {
            AccountContactRole acr = new AccountContactRole();
            acr.AccountId = params.accountInstance.Id;
            acr.ContactId = oldContact.Id;
            acr.Role = System.Label.Core_Account_Role;
            params.ctx.lstAccountContactRole.add(acr);
            params.ctx.lstDeleteRecords.add(params.leadInstance.ConvertedContactId);
        } else {
            params.ctx.lstUpdateContacts.add(new Contact(Id = params.leadInstance.ConvertedContactId, AccountId = params.accountInstance.Id));
            params.ctx.mapExistingContactIdConvertedContactId.put(params.leadInstance.ConvertedContactId, params.leadInstance.ConvertedContactId);
        }
    }
    
    private static void mergeContactFields(Contact oldContact, Contact newContact, List<String> lstWriteableFields) {
        for (String sFieldName : lstWriteableFields) {
            if (oldContact.get(sFieldName) == null && newContact.get(sFieldName) != null) {
                oldContact.put(sFieldName, newContact.get(sFieldName));
            }
        }
    }
    
    private static List<Id> getContactUpdateIds(List<Lead> lstConvertedLeads, List<Id> lstDeleteRecords, List<Contact> lstUpdateContacts) {
        Set<Id> contactFlagCheckOff = new Set<Id>();
        Set<Id> sContactRecordsDelete = new Set<Id>(lstDeleteRecords);
        for (Lead leadInstance : lstConvertedLeads) {
            if (!sContactRecordsDelete.contains(leadInstance.ConvertedContactId) && leadInstance.ConvertedContactId != null) {
                contactFlagCheckOff.add(leadInstance.ConvertedContactId);
            }
        }
        for (Contact contactInstance : lstUpdateContacts) {
            contactFlagCheckOff.add(contactInstance.Id);
        }
        return new List<Id>(contactFlagCheckOff);
    }
    
    private static void performDedupDml(SWS_LeadWrappers.ConversionContext ctx, Map<Id, Lead> mapNewIdLeads) {
        SWS_LeadWrappers.DmlContext dmlCtx = new SWS_LeadWrappers.DmlContext(ctx, mapNewIdLeads);
        
        updateContacts(dmlCtx);
        insertAccountContactRoles(dmlCtx);
        insertOpportunityContactRoles(dmlCtx);
        updateOpportunities(dmlCtx);
    }
    
    private static void updateContacts(SWS_LeadWrappers.DmlContext dmlCtx) {
        if (dmlCtx.lstUpdateContacts.isEmpty()) {
            return;
        }
        for (Contact contactInstance : dmlCtx.lstUpdateContacts) {
            contactInstance.Core_Lead_Conversion_Flag__c = true;
        }
        Database.SaveResult[] srList = Database.update(dmlCtx.lstUpdateContacts, false);
        
        // Using fluent interface pattern for inner classes
        SWS_LeadWrappers.ErrorContext errorCtx = new SWS_LeadWrappers.ErrorContext()
            .setSaveResults(srList)
            .setRecords(dmlCtx.lstUpdateContacts)
            .setIdMapping(dmlCtx.mapExistingContactIdConvertedContactId)
            .setLeadMapping(dmlCtx.mapContactIdLeadId)
            .setLeadMap(dmlCtx.mapNewIdLeads);
        handleDmlErrors(errorCtx);
    }
    
    private static void insertAccountContactRoles(SWS_LeadWrappers.DmlContext dmlCtx) {
        if (dmlCtx.lstAccountContactRole.isEmpty()) return;
        List<AccountContactRole> lstExistingAccountContactRole = [SELECT AccountId, ContactId FROM AccountContactRole WHERE AccountId IN :dmlCtx.mapExistingAccountIdConvertedAccountId.keySet()];
        Set<String> setAccountContact = new Set<String>();
        for (AccountContactRole acr : lstExistingAccountContactRole) {
            setAccountContact.add(acr.AccountId + '#' + acr.ContactId);
        }
        List<AccountContactRole> lstToInsert = new List<AccountContactRole>();
        for (AccountContactRole acr : dmlCtx.lstAccountContactRole) {
            String key = acr.AccountId + '#' + acr.ContactId;
            if (!setAccountContact.contains(key)) lstToInsert.add(acr);
        }
        Database.SaveResult[] srList = Database.insert(lstToInsert, false);
        
        // Using fluent interface pattern for inner classes
        SWS_LeadWrappers.ErrorContext errorCtx = new SWS_LeadWrappers.ErrorContext()
            .setSaveResults(srList)
            .setRecords(dmlCtx.lstAccountContactRole)
            .setIdMapping(dmlCtx.mapExistingAccountIdConvertedAccountId)
            .setLeadMapping(dmlCtx.mapAccountIdLeadId)
            .setLeadMap(dmlCtx.mapNewIdLeads);
        handleDmlErrors(errorCtx);
    }
    
    private static void insertOpportunityContactRoles(SWS_LeadWrappers.DmlContext dmlCtx) {
        if (dmlCtx.lstOpportunityContactRole.isEmpty()) {
            return;
        }
        Database.SaveResult[] srList = Database.insert(dmlCtx.lstOpportunityContactRole, false);
        
        // Using fluent interface pattern for inner classes
        SWS_LeadWrappers.ErrorContext errorCtx = new SWS_LeadWrappers.ErrorContext()
            .setSaveResults(srList)
            .setRecords(dmlCtx.lstOpportunityContactRole)
            .setIdMapping(dmlCtx.mapExistingContactIdConvertedContactId)
            .setLeadMapping(dmlCtx.mapContactIdLeadId)
            .setLeadMap(dmlCtx.mapNewIdLeads);
        handleDmlErrors(errorCtx);
    }
    
    private static void updateOpportunities(SWS_LeadWrappers.DmlContext dmlCtx) {
        if (dmlCtx.mapConvertedOpportunityIdAccountId.isEmpty()) return;
	
        List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
        for (Id OpportunityId : dmlCtx.mapConvertedOpportunityIdAccountId.keySet()) {
            Id accountId = dmlCtx.mapConvertedOpportunityIdAccountId.get(OpportunityId);
            lstOpportunityUpdate.add(new Opportunity(Id = OpportunityId, AccountId = accountId, Core_Lead_Conversion_Flag__c = true));
        }
        Database.SaveResult[] srList = Database.update(lstOpportunityUpdate, false);
        
        // Using fluent interface pattern for inner classes
        SWS_LeadWrappers.ErrorContext errorCtx = new SWS_LeadWrappers.ErrorContext()
            .setSaveResults(srList)
            .setRecords(lstOpportunityUpdate)
            .setIdMapping(dmlCtx.mapExistingAccountIdConvertedAccountId)
            .setLeadMapping(dmlCtx.mapAccountIdLeadId)
            .setLeadMap(dmlCtx.mapNewIdLeads);
        handleDmlErrors(errorCtx);
    }
    
    private static void handleDmlErrors(SWS_LeadWrappers.ErrorContext errorCtx) {
        Integer idx = 0;
        for (Database.SaveResult sr : errorCtx.srList) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    Id id1 = errorCtx.mapId1Id2.get(errorCtx.records[idx].Id);
                    Id leadId = errorCtx.mapId2LeadId.get(id1);
                    Lead errorLead = errorCtx.mapNewIdLeads.get(leadId);
                    if (errorLead != null) {
                        errorLead.addError(err.getMessage());
                    }
                }
            }
            idx++;
        }
    }
    
    private static List<String> getContactWriteableFields() {
        Map<String, Schema.SObjectField> mapObjectNameObjectFields = Core_Utility.getAllFields('Contact');
        List<String> lstWriteableFields = new List<String>();
        for (Schema.SObjectField sObjectFieldInstance : mapObjectNameObjectFields.values()) {
            try {
                if (sObjectFieldInstance.getDescribe().isAccessible() && sObjectFieldInstance.getDescribe().isUpdateable())
                    lstWriteableFields.add(sObjectFieldInstance.getDescribe().getName());
            } catch (Exception e) {
                continue;
            }
        }
        return lstWriteableFields;
    }
    
    @InvocableMethod(label='Auto Convert Lead' description='Converts a lead into an existing contact without creating opportunity or account')
    public static void convertLead(List<SWS_LeadWrappers.LeadConvertRequest> requests) {
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();

        // Capture Lead Notes per Lead to carry over to the Task comment after conversion
        Set<Id> leadIds = new Set<Id>();
        for (SWS_LeadWrappers.LeadConvertRequest req : requests) {
            leadIds.add(req.leadId);
        }
        Map<Id, Lead> mapLeadIdLead = new Map<Id, Lead>(
            [SELECT Id, Core_Lead_Notes__c FROM Lead WHERE Id IN :leadIds]
        );

        for (SWS_LeadWrappers.LeadConvertRequest req : requests) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(req.leadId);
            lc.setContactId(req.contactId);           
            lc.setDoNotCreateOpportunity(true);      // No Opportunity
          //lc.setOverwriteLeadSource(false);        
            lc.setConvertedStatus('Sales Qualified Lead');      
            
            // Use existing Contact's Account if it exists
            Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :req.contactId LIMIT 1];
            if (c.AccountId != null) {
                lc.setAccountId(c.AccountId);
            } else {
               system.debug('Account ID is empty');
            }
            
            conversions.add(lc);
        }

        List<Database.LeadConvertResult> results = Database.convertLead(conversions, false);

        List<Task> lstTasksToInsert = new List<Task>();
        for (Database.LeadConvertResult res : results) {
            if (!res.isSuccess()) {
                for (Database.Error err : res.getErrors()) {
                    System.debug('Lead conversion failed: ' + err.getMessage());
                }
                continue;
            }

            Lead convertedLead = mapLeadIdLead.get(res.getLeadId());
            // TaskSubtype 'Call' surfaces this record as a logged call in the Contact Activity tab
            lstTasksToInsert.add(new Task(
                Subject = 'Lead Conversion Note',
                TaskSubtype = 'Call',
                Status = 'Completed',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId(),
                WhoId = res.getContactId(),
                WhatId = res.getAccountId(),
                Description = (convertedLead != null) ? convertedLead.Core_Lead_Notes__c : null
            ));
        }

        if (!lstTasksToInsert.isEmpty()) {
            Database.SaveResult[] taskResults = Database.insert(lstTasksToInsert, false);
            for (Database.SaveResult sr : taskResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Task creation failed: ' + err.getMessage());
                    }
                }
            }
        }
    }      
}