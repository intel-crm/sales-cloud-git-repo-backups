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
public class Core_LeadHandler{
    
   
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
    
    public static void leadObjectSalesGroup(List<Lead> listNewLead,Map<Id,Lead> mapNewsObject,Map<Id,Lead> mapOldsObject)
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
     * Method name  : leadConversionDeduplication
     * Description  : Deduplication for Lead Conversion
     * Return Type  : Void
     * Parameter    : Map<Id,Lead>, Map<Id,Lead>
    */
    public static void leadConversionDeduplication(Map<Id, Lead> mapNewIdLeads, Map<Id, Lead> mapOldIdLeads) {

        // Run deDuplication logic only once 
        if (isLeadConverted()) {
        
            // Map to store the lead Id and converted Account Id
            Map<Id, Id> mapLeadIdAccountId = new Map<Id, Id>();
    
            // Map to store the lead Id and converted Contact Id
            Map<Id, Id> mapLeadIdContactId = new Map<Id, Id>();
    
            // To Store list of the record Ids which needs to be deleted
            List<Id> lstDeleteRecords = new List<Id>();
    
            // To store list of Converted leads
            List<lead> lstConvertedLeads = new List<Lead>();
    
            // Map to store Contact and related Lead Id
            Map<Id, Id> mapContactIdLeadId = new Map<Id, Id>();
    
            // Map to store Account and related Lead Id
            Map<Id, Id> mapAccountIdLeadId = new Map<Id, Id>();
    
    
            // Map to store object name and fields
            Map<String, Schema.SObjectField> mapObjectNameObjectFields = new Map<String, Schema.SObjectField>();
    
            // List to store the fields of objects which are updateable
            List<String> lstWriteableFields = new List<String>();
    
            for (Lead leadInstance: mapNewIdLeads.values()) {
                // Checking if the lead is converted
                if (leadInstance.IsConverted && !mapOldIdLeads.get(leadInstance.id).IsConverted) {
                    if (leadInstance.ConvertedAccountId != null) {
                        mapLeadIdAccountId.put(leadInstance.Id, leadInstance.ConvertedAccountId);
                        mapAccountIdLeadId.put(leadInstance.ConvertedAccountId, leadInstance.Id);
                    }
    
                    if (leadInstance.ConvertedContactId != null) {
                        mapLeadIdContactId.put(leadInstance.Id, leadInstance.ConvertedContactId);
                        mapContactIdLeadId.put(leadInstance.ConvertedContactId, leadInstance.Id);
                    }
    
                    lstConvertedLeads.add(leadInstance);
                }
            }
    
    
            // Getting all the fields of 'Contact' object
            mapObjectNameObjectFields = Core_Utility.getAllFields('Contact');
    
            // Fetching all the fields which are updateable
            for (Schema.SObjectField sObjectFieldInstance: mapObjectNameObjectFields.values()) {
                try {
                    if (sObjectFieldInstance.getDescribe().isAccessible() && sObjectFieldInstance.getDescribe().isUpdateable())
                        lstWriteableFields.add(sObjectFieldInstance.getDescribe().getName());
                }
                catch (Exception e) {
                    continue;
                }
            }
    
    
            if (!lstConvertedLeads.isEmpty()) {
                bLeadConverted = false;
    
                // To store list of account details
                List<Account> lstAccounts = new List<Account>();
    
                // Map to store the contact's email and list of contacts
                Map<String, Contact> mapEmailContactslist = new Map<String, Contact>();
    
                // To store the list of contact details
                List<Contact> lstContacts = new List<Contact>();
    
                // String to build the contact query
                String sQueryContacts = '';
    
                // List to store the contact which needs to be updated
                List<Contact> lstUpdateContacts = new List<Contact>();
    
                // List to store the Account Ids which needs to be updated
                List<Id> lstUpdateAccounts = new List<Id>();
    
                // List of AccountContactRole which needs to be inserted
                List<AccountContactRole> lstAccountContactRole = new List<AccountContactRole>();
    
                // List of OpportunityContactRole which needs to be inserted
                List<OpportunityContactRole> lstOpportunityContactRole = new List<OpportunityContactRole>();
    
                // To store Account Instance
                Account accountInstance;
    
                // Set to store the email ids of contacts
                Set<String> setEmailIds = new Set<String>();
    
                // List to store the duplicate contacts
                List<Contact> lstDuplicates = new List<Contact>();
    
                // Set to store the address details of contacts
                Set<String> setAddressDetails = new Set<String>();
    
                // Fetching the account details 
                lstAccounts = [SELECT Id, Name, Core_Address_Details__c, CreatedDate FROM ACCOUNT WHERE ID IN: mapLeadIdAccountId.values()];
    
                // Building the contact query                
                sQueryContacts = Core_Utility.buildQuery('Contact', lstWriteableFields);
    
                // Map to store Converted Opportunity Id and existing Account Id
                Map<Id, Id> mapConvertedOpportunityIdAccountId = new Map<Id, Id>();
    
                //Map to store Existing Account Id and Converted Account Id
                Map<Id, Id> mapExistingAccountIdConvertedAccountId = new Map<Id, Id>();
    
                //Map to store Existing Contact Id and Converted Account Id
                Map<Id, Id> mapExistingContactIdConvertedContactId = new Map<Id, Id>();
    
                if (!mapLeadIdContactId.isEmpty()) {
                    sQueryContacts += ' Where Id IN (';
                    for (String sContactIds: mapLeadIdContactId.values())
                        sQueryContacts += '\'' + sContactIds + '\'' + ', ';
    
                    sQueryContacts = sQueryContacts.subString(0, sQueryContacts.length() - 2);
                    sQueryContacts += ')';
                }
    
                lstContacts = Database.query(sQueryContacts);
    
                // Adding the address details of account to the set
                for (Account acctInstance: lstAccounts) {
                    setAddressDetails.add(acctInstance.Core_Address_Details__c);
                }
    
                // To store duplicate account details 
                List<Account> lstAccountsEmail = new List<Account>();
    
                lstAccountsEmail = [SELECT Id, Name, Core_Address_Details__c FROM ACCOUNT WHERE Core_Address_Details__c IN: setAddressDetails
                    AND ID NOT IN: mapLeadIdAccountId.values()
                ];
    
                // Map to store account address detail and account details 
                Map<String, List<Account>> mapEmailAccounts = new Map<String, List<Account>>();
    
                for (Account acctInstance: lstAccountsEmail) {
                    // Checking whether address is already present in map
                    if (mapEmailAccounts.containsKey(acctInstance.Core_Address_Details__c)) {
                        mapEmailAccounts.get(acctInstance.Core_Address_Details__c).add(acctInstance);
                    } else {
                        mapEmailAccounts.put(acctInstance.Core_Address_Details__c, new List<Account> {
                            acctInstance
                        });
                    }
                }
    
                // Map to store account id and account details
                Map<Id, Account> mapAccountIdAccount = new Map<Id, Account> (lstAccounts);
    
                // Map to store contact id and contact details
                Map<Id, Contact> mapContactIdContact = new Map<Id, Contact> (lstContacts);
    
                for (Contact contactInstance: lstContacts) {
                    if (contactInstance.Email != NULL && contactInstance.Email != '')
                        setEmailIds.add(contactInstance.Email);
                }
    
                if (!setEmailIds.isEmpty()) {
                    // To build the query
                    String sQueryDuplicates = '';
    
                    // Building the contact query dynamically
                    sQueryDuplicates = Core_Utility.buildQuery('Contact', lstWriteableFields);
    
                    sQueryDuplicates += ' Where email IN :setEmailIds ';
    
                    if (!mapLeadIdContactId.isEmpty()) {
                        sQueryDuplicates += ' AND Id NOT IN (';
                        for (String sContactIds: mapLeadIdContactId.values())
                            sQueryDuplicates += '\'' + sContactIds + '\'' + ', ';
    
                        sQueryDuplicates = sQueryDuplicates.subString(0, sQueryDuplicates.length() - 2);
                        sQueryDuplicates += ')';
                    }
    
                    lstDuplicates = Database.query(sQueryDuplicates);
    
                    for (Contact contactInstance: lstDuplicates) {
                        mapEmailContactslist.put(contactInstance.email, contactInstance);
                    }
    
                }
    
                // To store duplicate accounts.
                List<Account> lstDupAccounts = new List<Account>();
    
                for (Lead leadInstance: lstConvertedLeads) {
                    // Checking whether the account id is present
                    if (mapAccountIdAccount.containsKey(leadInstance.convertedAccountId)) {
                        accountInstance = mapAccountIdAccount.get(leadInstance.convertedAccountId);
    
                        // Checking whether account was created 
                        if (accountInstance.createdDate> System.Now().addMinutes(-1)) {
    
                            if (mapAccountIdAccount.containsKey(leadInstance.convertedAccountId)) {
                                Boolean bDuplicateAccount = false;
    
                                Account existingAccount;
    
                                if (mapEmailAccounts.containsKey(mapAccountIdAccount.get(leadInstance.convertedAccountId).Core_Address_Details__c)) {
    
                                    lstDupAccounts = mapEmailAccounts.get(mapAccountIdAccount.get(leadInstance.convertedAccountId).Core_Address_Details__c);
    
                                    for (Account dupAccountInstance: lstDupAccounts) {
                                        if (dupAccountInstance.name.equalsIgnoreCase(leadInstance.company)) {
                                            bDuplicateAccount = true;
                                            existingAccount = dupAccountInstance;
                                            break;
                                        }
                                    }
    
                                }
    
                                if (bDuplicateAccount) {
                                    // Getting the list of Accounts based on address details of lead
    
                                    Id accountId = leadInstance.convertedAccountId;
    
                                    lstDeleteRecords.add(leadInstance.convertedAccountId);
    
                                    if (leadInstance.convertedOpportunityId != NULL)
                                        mapConvertedOpportunityIdAccountId.put(leadInstance.convertedOpportunityId, existingAccount.Id);
    
                                    mapExistingAccountIdConvertedAccountId.put(ExistingAccount.Id, leadInstance.convertedAccountId);
    
    
                                    if (!mapEmailContactsList.isEmpty() && !lstContacts.isEmpty()) {
                                        // Checking whether contact email id is present
                                        if (mapEmailContactsList.containsKey(mapContactIdContact.get(leadInstance.convertedContactId).Email)) {
                                            // If the contact email id is present same different account
                                            if (mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email).
                                                AccountId == existingAccount.Id) {
                                                
                                                // Fetching the contact with same email id which was already 
                                                Contact oldContact = mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email);
    
                                                // Fetching the new contact with same email id
                                                Contact newContact = mapContactIdContact.get(leadInstance.convertedContactId);
    
                                                mapExistingContactIdConvertedContactId.put(oldContact.Id, newContact.Id);
    
                                                for (String sFieldName: lstWriteableFields) {
                                                    // Checking fields of old contact with new contact
                                                    if (oldContact.get(sFieldName) == NULL && newContact.get(sFieldName) != NULL) {
                                                        oldContact.put(sFieldName, newContact.get(sFieldName));
                                                    }
                                                }
    
    
                                                // Adding old contact to the list of contacts which needs to be updated
                                                lstUpdateContacts.add(oldContact);
    
                                                // Adding contact id the list of contacts which needs to be deleted
                                                lstDeleteRecords.add(leadInstance.convertedContactId);
                                            } else {
                                                // Creating an AccountContactRole to be inserted
                                                AccountContactRole accountContactRoleInstance = new AccountContactRole();
                                                accountContactRoleInstance.accountId = ExistingAccount.Id;
                                                accountContactRoleInstance.contactId = mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId)
                                                                                       .Email).Id;
                                                accountContactRoleInstance.Role = System.Label.Core_Account_Role;
                                                lstAccountContactRole.add(accountContactRoleInstance);
    
    
                                                // Adding the contact id to the list to be deleted
                                                lstDeleteRecords.add(leadInstance.convertedContactId);
                                            }
                                        } else {
                                            lstUpdateContacts.add(new Contact(Id = leadInstance.convertedContactId, AccountId = existingAccount.Id));
                                            mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
                                        }
    
                                    } else {
                                        lstUpdateContacts.add(new Contact(Id = leadInstance.convertedContactId, AccountId = existingAccount.Id));
                                        mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
                                    }
    
                                } else {
                                    // New Account exists 
    
                                    lstUpdateAccounts.add(leadInstance.convertedAccountId);
    
                                    mapExistingAccountIdConvertedAccountId.put(leadInstance.convertedAccountId, leadInstance.convertedAccountId);
    
                                    if (!mapEmailContactsList.isEmpty() && !lstContacts.isEmpty()) {
                                        // Checking whether contact email id is present
                                        if (mapEmailContactsList.containsKey(mapContactIdContact.get(leadInstance.convertedContactId).Email)) {
                                            // If the contact email id is present with different account
                                            if (mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email).AccountId 
                                                != leadInstance.convertedAccountId) {
                                                
                                                // Fetching the contact with same email id which was already 
                                                Contact oldContact = mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email);
    
                                                // Fetching the new contact with same email id
                                                Contact newContact = mapContactIdContact.get(leadInstance.convertedContactId);
    
                                                mapExistingContactIdConvertedContactId.put(oldContact.Id, newContact.Id);
    
                                                if (leadInstance.convertedOpportunityId != NULL) {
                                                    OpportunityContactRole opportunityContactRoleInstance = new OpportunityContactRole();
                                                    opportunityContactRoleInstance.contactId = oldContact.Id;
                                                    opportunityContactRoleInstance.IsPrimary = true;
                                                    opportunityContactRoleInstance.opportunityId = leadInstance.convertedOpportunityId;
                                                    lstOpportunityContactRole.add(opportunityContactRoleInstance);
                                                }
    
                                                for (String sFieldName: lstWriteableFields) {
                                                    // Checking fields of old contact with new contact
                                                    if (oldContact.get(sFieldName) == NULL && newContact.get(sFieldName) != NULL) {
                                                        oldContact.put(sFieldName, newContact.get(sFieldName));
                                                    }
                                                }
    
                                                // Creating an AccountContactRole to be inserted
                                                AccountContactRole accountContactRoleInstance = new AccountContactRole();
                                                accountContactRoleInstance.accountId = leadInstance.convertedAccountId;
                                                accountContactRoleInstance.contactId = oldContact.Id;
                                                accountContactRoleInstance.Role = System.Label.Core_Account_Role;
                                                lstAccountContactRole.add(accountContactRoleInstance);
    
    
                                                lstUpdateContacts.add(oldContact);
                                            }
    
                                            lstDeleteRecords.add(leadInstance.convertedContactId);
                                        } else {
                                            mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
    
                                        }
    
                                    } else {
                                        mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
    
                                    }
    
                                }
                            }
    
    
                        } else {
                            lstUpdateAccounts.add(leadInstance.convertedAccountId);
    
                            mapExistingAccountIdConvertedAccountId.put(leadInstance.convertedAccountId, leadInstance.convertedAccountId);
    
                            if (!mapEmailContactsList.isEmpty() && !lstContacts.isEmpty()) {
                                // Checking whether contact email id is present
                                if (mapEmailContactsList.containsKey(mapContactIdContact.get(leadInstance.convertedContactId).Email)) {
                                    // If the contact email id is present same different account
                                    if (mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email).AccountId 
                                        == leadInstance.convertedAccountId) {
                                        
                                        // Fetching the contact with same email id which was already 
                                        Contact oldContact = mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).Email);
    
                                        // Fetching the new contact with same email id
                                        Contact newContact = mapContactIdContact.get(leadInstance.convertedContactId);
    
                                        mapExistingContactIdConvertedContactId.put(oldContact.Id, newContact.Id);
    
    
                                        for (String sFieldName: lstWriteableFields) {
                                            // Checking fields of old contact with new contact
                                            if (oldContact.get(sFieldName) == NULL && newContact.get(sFieldName) != NULL) {
                                                oldContact.put(sFieldName, newContact.get(sFieldName));
                                            }
                                        }
    
                                        // Adding old contact to the list of contacts which needs to be updated
                                        lstUpdateContacts.add(oldContact);
    
                                        // Adding contact id the list of contacts which needs to be deleted
                                        lstDeleteRecords.add(leadInstance.convertedContactId);
                                    } else {
                                        // Creating an AccountContactRole to be inserted
                                        AccountContactRole accountContactRoleInstance = new AccountContactRole();
                                        accountContactRoleInstance.accountId = mapAccountIdAccount.get(leadInstance.convertedAccountId).Id;
                                        accountContactRoleInstance.contactId = mapEmailContactsList.get(mapContactIdContact.get(leadInstance.convertedContactId).
                                                                               Email).Id;
                                        accountContactRoleInstance.Role = System.Label.Core_Account_Role;
                                        lstAccountContactRole.add(accountContactRoleInstance);
    
                                        mapExistingAccountIdConvertedAccountId.put(leadInstance.convertedAccountId, leadInstance.convertedAccountId);
    
                                        // Adding the contact id to the list to be deleted
                                        lstDeleteRecords.add(leadInstance.convertedContactId);
                                    }
                                } else {
                                    mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
                                }
    
                            } else {
                                mapExistingContactIdConvertedContactId.put(leadInstance.convertedContactId, leadInstance.convertedContactId);
                            }
    
                        }
                    }
    
                }
    
                if (!lstUpdateContacts.isEmpty()) {
                    // Updating the flag of the contact which allows update of contact even with duplicate contact present
                    for (Contact contactInstance: lstUpdateContacts) {
                        contactInstance.Core_Lead_Conversion_Flag__c = true;
                    }

                    // Updating the list of contacts 
                    Database.SaveResult[] srList = Database.update(lstUpdateContacts, false);
                    Integer databaseUpdateIndex = 0;
                    // Capturing the logs for error records
                    for (Database.SaveResult sr: srList) {
    
                        if (!sr.isSuccess()) {
                            for (Database.Error err: sr.getErrors()) {
                                
                                Id contactId = mapExistingContactIdConvertedContactId.get(lstUpdateContacts.get(databaseUpdateIndex).Id);
    
                                Id LeadId = mapContactIdLeadId.get(contactId);
    
                                Lead errorLead = mapNewIdLeads.get(LeadId);
    
                                errorLead.addError(err.getMessage());
    
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Lead fields that affected this error: ' + err.getFields());
                            }
                        }
                        databaseUpdateIndex++;
                    }
                }
    
                if (!lstAccountContactRole.isEmpty()) {
                    List<AccountContactRole> lstExistingAccountContactRole = new List<AccountContactRole>();
    
                    lstExistingAccountContactRole = [SELECT AccountId, ContactId FROM AccountCOntactROle
                        Where AccountId IN: mapExistingAccountIdConvertedAccountId.keySet()
                    ];
    
                    SET<String> setAccountContact = new Set<String>();
    
                    for (AccountContactRole accountContactRoleInstance: lstExistingAccountContactRole) {
                        setAccountContact.add(accountContactRoleInstance.AccountId + '#' + accountContactRoleInstance.contactId);
                    }
    
                    List<AccountContactRole> lstToInsertAccountContactRole = new List<AccountContactRole>();
    
                    String sAccountContact;
    
                    for (AccountContactRole accountContactRoleInstance: lstAccountContactRole) {
                        sAccountContact = accountContactRoleInstance.AccountId + '#' + accountContactRoleInstance.contactId;
    
                        if (!setAccountContact.contains(sAccountContact))
                            lstToInsertAccountContactRole.add(accountContactRoleInstance);
                    }
    
                    // Inserting the list of account role
                    Database.SaveResult[] srList = Database.insert(lstToInsertAccountContactRole, false);
                    Integer databaseUpdateIndex = 0;
                    // Capturing the logs for error records
                    for (Database.SaveResult sr: srList) {
    
                        if (!sr.isSuccess()) {
                            for (Database.Error err: sr.getErrors()) {
                                
                                Id AccountId = mapExistingAccountIdConvertedAccountId.get(lstAccountContactRole.get(databaseUpdateIndex).AccountId);
    
                                Id LeadId = mapAccountIdLeadId.get(AccountId);
    
                                Lead errorLead = mapNewIdLeads.get(LeadId);
    
                                errorLead.addError(err.getMessage());
    
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Lead fields that affected this error: ' + err.getFields());
                            }
                        }
                        databaseUpdateIndex++;
                    }
                }
    
    
    
                if (!lstOpportunityContactRole.isEmpty()) {
                    // Inserting the list of contact role
                    Database.SaveResult[] srList = Database.insert(lstOpportunityContactRole, false);
                    Integer databaseUpdateIndex = 0;
    
                    // Capturing the logs for error records
                    for (Database.SaveResult sr: srList) {
    
                        if (!sr.isSuccess()) {
                            for (Database.Error err: sr.getErrors()) {
    
                                Id contactId = mapExistingContactIdConvertedContactId.get(lstOpportunityContactRole.get(databaseUpdateIndex).ContactId);
    
                                Id LeadId = mapContactIdLeadId.get(contactId);
    
                                Lead errorLead = mapNewIdLeads.get(LeadId);
    
                                errorLead.addError(err.getMessage());
    
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Lead fields that affected this error: ' + err.getFields());
                            }
                        }
                        databaseUpdateIndex++;
                    }
                }
    
                if (!mapConvertedOpportunityIdAccountId.isEmpty()) {
    
                    List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
    
                    Opportunity opportunityInstance;
    
                    Id accountId;
    
                    for (Id OpportunityId: mapConvertedOpportunityIdAccountId.keyset()) {
                        accountId = mapConvertedOpportunityIdAccountId.get(OpportunityId);
                        opportunityInstance = new Opportunity(Id = OpportunityId, AccountId = accountId, Core_Lead_Conversion_Flag__c = true);
                        lstOpportunityUpdate.add(opportunityInstance);
                    }
    
                    // Inserting the list of account role
                    Database.SaveResult[] srList = Database.update(lstOpportunityUpdate, false);
                    Integer databaseUpdateIndex = 0;
                    // Capturing the logs for error records
                    for (Database.SaveResult sr: srList) {
    
                        if (!sr.isSuccess()) {
                            for (Database.Error err: sr.getErrors()) {
                                
                                Id IdAccountrelatedToOpportunity = mapExistingAccountIdConvertedAccountId.get(lstOpportunityUpdate.get(databaseUpdateIndex).AccountId);
                                Id LeadId = mapAccountIdLeadId.get(IdAccountrelatedToOpportunity);
                                Lead errorLead = mapNewIdLeads.get(LeadId);
                                errorLead.addError(err.getMessage());
    
    
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Lead fields that affected this error: ' + err.getFields());
                            }
                        }
                        databaseUpdateIndex++;
                    }
                }
    
                // To store set of contact ids which needs to be updated
                Set<Id> lstContactFlagCheckOff = new Set<Id>();
    
    
                // Adding the contact ids which needs to be updated   
                if (!lstDeleteRecords.isEmpty()) {
                    if (!lstConvertedLeads.isEmpty()) {
                        SET<Id> sContactRecordsDelete = new SET<Id>();
                        sContactRecordsDelete.addAll(lstDeleteRecords);
    
                        for (Lead leadInstance: lstConvertedLeads) {
                            if (!sContactRecordsDelete.contains(leadInstance.ConvertedContactId)) {
                                lstContactFlagCheckOff.add(leadInstance.ConvertedContactId);
                            }
                        }
                    }
                }
    
    
                // Adding the contact ids which needs to be updated
                if (lstDeleteRecords.isEmpty()) {
                    for (Lead leadInstance: lstConvertedLeads) {
                        if (leadInstance.ConvertedContactId != NULL) {
                            lstContactFlagCheckOff.add(leadInstance.ConvertedContactId);
                        }
                    }
                }
    
                // Adding the contact ids which needs to be updated    
                for (Contact contactInstance: lstUpdateContacts) {
                    lstContactFlagCheckOff.add(contactInstance.Id);
                }
    
                // Adding the contact ids which needs to be updated
                List<Id> lstContactUpdateIds = new List<Id>();
                lstContactUpdateIds.addAll(lstContactFlagCheckOff);
    
                deleteUpdateContactRecords(lstDeleteRecords, lstContactUpdateIds, lstUpdateAccounts);
    
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
             
             // Capturing the logs for error records
             for (Database.SaveResult sr : srList) 
             {
                
                if (!sr.isSuccess()) 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        
                        
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Lead fields that affected this error: ' + err.getFields());
                    }
                }
              
              }
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
             
             // Capturing the logs for error records
             for (Database.SaveResult sr : srList) 
             {
                
                if (!sr.isSuccess()) 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        
                        
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Lead fields that affected this error: ' + err.getFields());
                    }
                }
              
              }
         }
         
        if(!lstDeleteRecords.isEmpty())
        {  
            // Deleting the list of Contact and Account records
            Database.DeleteResult[] deletedRecords = Database.delete(lstDeleteRecords, false);
            
            // Capturing the logs for error records
             for (Database.DeleteResult sr : deletedRecords) 
             {
                
                if (!sr.isSuccess()) 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Lead fields that affected this error: ' + err.getFields());
                    }
                }
                
              }
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
        List<Core_Partner_Queue_Mapping__c> lstParterQueue = new List<Core_Partner_Queue_Mapping__c>();
        lstParterQueue = [SELECT Core_Partner_Name__c, Core_Queue_Name__c, Core_Active__c FROM Core_Partner_Queue_Mapping__c WHERE Core_Active__c = true];
                
        // Store the mappings between Partner Name and Queue Name
        for (Core_Partner_Queue_Mapping__c record :lstParterQueue) {
            mapPartnerNameQueueName.put(record.Core_Partner_Name__c.touppercase(), record.Core_Queue_Name__c);
        }

        // Log the list of Partner Names and their corresponding Queue Names
        for (String sPartnerName :mapPartnerNameQueueName.keySet()) {
            System.debug('### LoadPartnerToQueueMapping() 01 ### Partner Name - Queue Name: ' + sPartnerName + ' - ' + mapPartnerNameQueueName.get(sPartnerName));
        }
             
        // Get and store the Queue Ids using the Queue Names
        List<QueueSobject> lstQueues = [SELECT QueueId, Queue.DeveloperName FROM QueueSobject WHERE SobjectType = 'Lead' AND Queue.DeveloperName IN :mapPartnerNameQueueName.values()];
        for (QueueSobject queue :lstQueues) {
            mapQueueNameQueueId.put(queue.Queue.DeveloperName, queue.QueueId);
        }
            
        // Log the list of Queue names and their corresponding Queue Ids
        for (String sQueueName :mapQueueNameQueueId.keySet()) {
            System.debug('### LoadPartnerToQueueMapping() 02 ### Queue Name - Queue Id: ' + sQueueName + ' - ' + mapQueueNameQueueId.get(sQueueName));
        }
               
        // Create the mapping between Partner Name and Queue Id
        for (String sPartnerName :mapPartnerNameQueueName.keySet()) {
            if (sPartnerName != null) {
                String sQueueName = mapPartnerNameQueueName.get(sPartnerName);
                Id idQueue = mapQueueNameQueueId.get(sQueueName);
                if (sQueueName != null && idQueue != null)
                    mapPartnerNameQueueId.put(sPartnerName, idQueue);
            }
        }

        // Log the list of Partner Names and their corresponding Queue Ids
        for (String sPartnerName :mapPartnerNameQueueId.keySet()) {
            System.debug('### LoadPartnerToQueueMapping() 03 ### Partner Name - Queue Id: ' + sPartnerName + ' - ' + mapPartnerNameQueueId.get(sPartnerName));
        }
    
        return mapPartnerNameQueueId;
     }

     
    /*
     * Method name  : AssignLeadsToPartnerQueues
     * Description  : Method to assign Partner Leads to correct Partner Queues using the Partner Name
     * Return Type  : void
     * Parameter    : Lead[]
     */
    public static void AssignLeadsToPartnerQueues(Lead[] newLeads)
    {
        // Check if Global Partner Queue and Invalid Partner Queue Ids are setup
        if (System.Label.Core_Partner_Global_Queue_Id == null || System.Label.Core_Partner_Invalid_Queue_Id == null)
            return;

        // Get the list of Partner Lead Ids that belong to Global Partner Queue
        Set<Id> setParterLeadIds = new Set<Id>();
        for (Lead lead: newLeads) {
            if (lead.RecordTypeId == System.Label.Core_Partner_Lead_Record_Id && lead.Core_Partner_Name__c != null && lead.OwnerId == System.Label.Core_Partner_Global_Queue_Id)
                setParterLeadIds.add(lead.Id);
        }

        System.debug('### AssignLeadsToPartnerQueues() 01 ### Number of Partner Leads: ' + setParterLeadIds.size());

        // No Partner Leads to process
        if (setParterLeadIds.size() == 0)
            return;

        // Load the Partner Name to Queue Id mappings
        Map<String, Id> mapPartnerNameQueueId = LoadPartnerToQueueIdMapping();

        // Get the list of Partner Leads that belong to Global Partner Queue
        List<Lead> lstPartnerLeads = new List<Lead>();
        lstPartnerLeads = [SELECT Id, Core_Partner_Name__c FROM Lead WHERE Id IN :setParterLeadIds];

        // Process each Partner Lead and update the Owner to the correct Partner Queue
        for (Lead partnerLead :lstPartnerLeads) {

            Id idPartnerQueue = mapPartnerNameQueueId.get(partnerLead.Core_Partner_Name__c.touppercase());
            if (idPartnerQueue != null)
                partnerLead.OwnerId = idPartnerQueue;
            else
                partnerLead.OwnerId = System.Label.Core_Partner_Invalid_Queue_Id;

            System.debug('### AssignLeadsToPartnerQueues() 02 ### Lead Id - Partner Name - Queue Id: ' + partnerLead.Id + ' - ' + partnerLead.Core_Partner_Name__c + ' - ' + partnerLead.OwnerId);
        }

        if (!lstPartnerLeads.isEmpty())
               update lstPartnerLeads;        
    }
}