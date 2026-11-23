/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMessageERPM
Version     : 1.0
Created Date: 03 NOV 2016
Function    : Business logic for processing inbound ERPM messages

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016              Original version
* Pooja Khanna              5/26/2016               Removed Box B message creation on successful ERPM response, moved it to process builder
                                                    Added 3 new payload (Core_payload1/2/3__c) fields for the long message processing
*****************************************************************************************************************************************/
public class Core_IntegrationInboundMessageERPM {
    
    public static final String RDC_ENGAGEMENT_CODE = 'IRDC_Priv';
    public static final String RDC_ACCOUNT_INDUSTRY = 'Others';            // TO DO: finalize this with Jordan
    public static final String RDC_ACCOUNT_TYPE = 'Other';                 // TO DO: finalize this with Jordan
    public static final String RDC_ACCOUNT_SALES_GROUP = 'Regional Sales'; // TO DO: finalize this with Jordan
    public static final String B2B_DEDUP_GROUP_CODE = 'DEDUPB2B';
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
    
    // Main method for processing ERPM Contact (Person) messages
    public static void processContactMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        // Note: currently we have a single status for the whole batch, which all records will be set to. This is fine
        // for now, since iPaaS won't be sending batches. But goal state should be to have separate status per message.
        
        String processingStatus = 'Successful'; // Exception handling will set this to Failed if applicable
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        Set<Id> msgIds = new Set<Id>();
        Datetime publishTimestamp = null;
        
        // List of all of the messages we're processing
        List<Core_IntegrationUtility.ERPM_Person> erpmPersons = new List<Core_IntegrationUtility.ERPM_Person>();
        
        // Collections for IDs, codes, strings, etc. we'll need after parsing the messages
        Set<String> erpmPersonIds = new Set<String>();
        Set<String> erpmEnggCodes = new Set<String>();
        List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs = new List<Core_IntegrationUtility.ERPM_Engagement>();
        Set<String> erpmEmails = new Set<String>();
        //Map<String,String> erpmEmailToPersonIdMap = new Map<String,String>();
        Set<String> erpmAccountCIMIds = new Set<String>();
        
        // Build up a list of tags that we'll use for log entries, inbound messages, etc.
        String tags = '';
        
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET RELEVANT ID VALUES
        
        // Following line temporarily removed to prevent bulk processing of messages
        //for (Core_Integration_Inbound_Message__c msg : newList) {
        if (newList.size() > 0) { // Temporarily added
            Core_Integration_Inbound_Message__c msg = newList[0]; // Temporarily added to only process first message if multiple are inserted
            
            // Only process messages inserted/updated as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (getFullPayload(msg)!= null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of erpmPersons
                    Core_IntegrationUtility.ERPM_Person person =
                        Core_IntegrationInboundMessageParsing.parsePerson(getFullPayload(msg));
                    System.debug('##### ERPM Person message parsed into an object: ' + person);
                    erpmPersons.add(person);
                    
                    // If the message has ".duplicate" in the email address, ahead of the @ sign, per US49540, we need to ignore it
                    if (person.email.containsIgnoreCase('.duplicate') && (person.email.indexOf('.duplicate') < person.email.indexOf('@'))) {
                        System.debug('##### ERPM Person message has ".duplicate" in email address, so ignoring it');
                        person.ignoreMessage = true;
                        person.ignoreReason = 'Email address has ".duplicate" ahead of the @ sign';
                    }
                    
                    // Save the necessary ID values into collections that we'll need in upcoming SELECT statements.
                    // Also, build up our tag list while we're at it.
                    if (!String.isBlank(person.erpmPersonId)) {
                        erpmPersonIds.add(person.erpmPersonId);
                        tags += addTag(person.erpmPersonId);
                    }
                    if (!String.isBlank(person.enterpriseId))
                        tags += addTag(person.enterpriseId);
                    if (!String.isBlank(person.loginId))
                        tags += addTag(person.loginId);
                    if (!String.isBlank(person.email)) {
                        erpmEmails.add(person.email);
                        tags += addTag(person.email);
                    }
                    
                    publishTimestamp = person.publishTimestamp;
                    
                    for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                        for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements) {
                            erpmEnggs.add(engg);
                            erpmEnggCodes.add(engg.engagementCode);
                        }
                        tags += addTag(acct.cimId) + addTag(acct.erpmAccountNumber);
                    }
                    
                    for (Core_IntegrationUtility.ERPM_Engagement engg : person.personEngagements) {
                        erpmEnggs.add(engg);
                        erpmEnggCodes.add(engg.engagementCode);
                    }
                    
                    if (person.personAccounts.size() > 0) {
                        if (person.personAccounts[0].cimId != '')
                            erpmAccountCIMIds.add(person.personAccounts[0].cimId);
                    }
                }
                catch (Exception ex) {
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                    System.debug('##### Exception: ' + exceptionMessage);
                    processingStatus = 'Failed';
                    processingMessage += ', Read Message: ' + exceptionMessage;
                    
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error reading ERPM Person message', '', msg.Id, LOG_ENTRY_OBJECT, '', ex);
                }
            }
        }
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL RECORDS WE'LL NEED FOR FURTHER PROCESSING --
        //
        // Pull all records related to the messages passed in - all fields needed from Contact, Contact
        // Entitlement, Entitlement, ERPM Engagement, Account, and place in List, Maps, and Sets
        //     SELECT Contact records where ERPM Person Id or Email matches values in inbound messages
        //     SELECT Contact Entitlement records where Id in (Contact Ids from prev step)
        //     SELECT ERPM Engagement records where Engg Code in (Engg Codes in inbound messages)
        //     SELECT Entitlement records where Id in (ERPM Engg Ids from prev step)
        //     SELECT Account records where CIM ID was passed in
        
        try {
            
            // We need at least a Person ID or Email. If we don't have one, the next SOQL statement will throw an
            // exception only when run in an actual org, not in our test classes. So let's throw one explicitly instead.
            if ((erpmPersonIds.size() == 0) && (erpmEmails.size() == 0)) {
                throw new CustomException('ERPM Person message must contain a Person ID or Email address.');
            }
            // Contacts
            List<Contact> matchingContacts = [
                select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c, Core_Do_Not_Contact__c,
                Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, Core_AGS_Integration_Status__c, Core_Deactivated__c,
                Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c
                from Contact
                where Core_eRPM_Person_Id__c in :erpmPersonIds
                limit 1]; // Limit needs to be removed for true bulkification
            
            if (matchingContacts.size() == 0) {
                matchingContacts = [
                    select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                    Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                    Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                    Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c, Core_Do_Not_Contact__c,
                    Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, Core_AGS_Integration_Status__c, Core_Deactivated__c,
                    Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c
                    from Contact
                    where Email in :erpmEmails
                    limit 1]; // Limit needs to be removed for true bulkification
            }
            System.debug('##### matchingContacts: ' + matchingContacts);
            
            Set<Id> matchingContactIds = new Set<Id>();
            Map<String,Contact> matchingContactERPMIdMap = new Map<String,Contact>();
            Map<String,Contact> matchingContactEmailMap = new Map<String,Contact>();
            
            for (Contact c : matchingContacts) {
                matchingContactIds.add(c.Id);
                matchingContactERPMIdMap.put(c.Core_eRPM_Person_Id__c, c);
                matchingContactEmailMap.put(c.Email, c);
            }
            
            // Contact Entitlements
            List<Core_Contact_Entitlement__c> matchingContactEntitlementsEnggs = new List<Core_Contact_Entitlement__c>();
            List<Core_Contact_Entitlement__c> matchingContactEntitlementsAll = new List<Core_Contact_Entitlement__c>();
            Map<Id,List<Core_Contact_Entitlement__c>> matchingContactEntitlementEnggMap =
                new Map<Id,List<Core_Contact_Entitlement__c>>();
            Map<Id,List<Core_Contact_Entitlement__c>> matchingContactEntitlementAllMap =
                new Map<Id,List<Core_Contact_Entitlement__c>>();
            
            if (matchingContactIds.size() > 0) {
                
                // First pull the Contact Entitlements where AGS role is blank, which represent the ERPM Engagements themselves
                matchingContactEntitlementsEnggs = [
                    select Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Engagement_Tier__c, Core_Selected__c, Core_From_Source__c,
                    Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, Core_ERPM_Account_Data__c,
                    Core_Entitlement_Id__r.Core_AGS_Role_Id__c
                    from Core_Contact_Entitlement__c
                    where Core_Contact_Id__c in :matchingContactIds and
                    Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c != null and
                    Core_Entitlement_Id__r.Core_AGS_Role_Id__c = ''];
                
                // Next pull all Contact Entitlements *including ones with AGS roles*
                matchingContactEntitlementsAll = [
                    select Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Engagement_Tier__c, Core_Selected__c, Core_From_Source__c,
                    Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, Core_ERPM_Account_Data__c,
                    Core_Entitlement_Id__r.Core_AGS_Role_Id__c
                    from Core_Contact_Entitlement__c
                    where Core_Contact_Id__c in :matchingContactIds and
                    Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c != null];
            }
            // Place these Contact Entitlement lists into maps of Contact ID to Contact Entitlement list
            List<Core_Contact_Entitlement__c> ceList;
            for (Core_Contact_Entitlement__c ce : matchingContactEntitlementsEnggs) {
                if (matchingContactEntitlementEnggMap.containsKey(ce.Core_Contact_Id__c))
                    ceList = matchingContactEntitlementEnggMap.get(ce.Core_Contact_Id__c);
                else
                    ceList = new List<Core_Contact_Entitlement__c>();
                ceList.add(ce);
                matchingContactEntitlementEnggMap.put(ce.Core_Contact_Id__c, ceList);
            }
            for (Core_Contact_Entitlement__c ce : matchingContactEntitlementsAll) {
                if (matchingContactEntitlementAllMap.containsKey(ce.Core_Contact_Id__c))
                    ceList = matchingContactEntitlementAllMap.get(ce.Core_Contact_Id__c);
                else
                    ceList = new List<Core_Contact_Entitlement__c>();
                ceList.add(ce);
                matchingContactEntitlementAllMap.put(ce.Core_Contact_Id__c, ceList);
            }
            
            // ERPM Engagements
            List<Core_ERPM_Engagement__c> matchingERPMEngagements = new List<Core_ERPM_Engagement__c>();
            Set<Id> matchingERPMEngagementIds = new Set<Id>();
            
            if (matchingContactEntitlementsEnggs.size() > 0) {
                
                matchingERPMEngagements = [
                    select Id, Name, Core_Technical_Name__c, Core_Description__c, Core_Technical_Engagement_Code__c
                    from Core_ERPM_Engagement__c
                    where Core_Technical_Engagement_Code__c in :erpmEnggCodes]; // may need to select more fields
                
                for (Core_ERPM_Engagement__c engg : matchingERPMEngagements)
                    matchingERPMEngagementIds.add(engg.Id);
            }
            
            // Entitlements
            List<Core_Entitlement__c> matchingEntitlements = new List<Core_Entitlement__c>();
            
            if (matchingERPMEngagements.size() > 0) {
                
                matchingEntitlements = [
                    select Id, Name, Core_ERPM_Engagement_Id__c, Core_Display_Name__c, Core_Description__c
                    from Core_Entitlement__c
                    where Core_ERPM_Engagement_Id__c in :matchingERPMEngagementIds and Core_AGS_Role_Id__c = ''];
            }
            
            // Accounts
            List<Account> matchingAccounts = new List<Account>();
            Map<String,Account> matchingAccountMap = new Map<String,Account>();
            
            if (erpmAccountCIMIds.size() > 0) {
                
                // Get accounts, ordered by CIM ID, then created date, earliest first, so we can just take the first if multiple
                matchingAccounts = [
                    select Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c, Core_CNDA_Number__c
                    from Account
                    where Core_CIM_ID__c in :erpmAccountCIMIds
                    order by Core_CIM_ID__c, CreatedDate asc];
                
                System.debug('##### matchingAccounts: ' + matchingAccounts);
                
                for (Account a : matchingAccounts) {
                    if (!matchingAccountMap.containsKey(a.Core_CIM_ID__c)) {
                        matchingAccountMap.put(a.Core_CIM_ID__c, a);
                        tags += addTag(a.Id);
                    }
                }
            }
            
            // Collections for Contact & Account INSERTs and UPDATEs
            List<Contact> contactsToInsert = new List<Contact>();
            List<Contact> contactsToUpdate = new List<Contact>();
            Set<Id> contactIdsToUpdateAgain = new Set<Id>(); // For the 2nd update we need to perform for ERPM deletes & soft deletes
            List<Account> accountsToInsert = new List<Account>();
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD INSERTS & UPDATES (AND POTENTIALLY ACCOUNTS)
            
            // DH 2/7: This entire section was commented out since we no longer need to create RDC accounts. Per Jordan,
            // we will always get a Person message with a CIM ID that already exists in SFDC after it's created in CIM.
            // And there are no other current use cases where we need to create accounts.
            /*
// Loop through collection of erpmPersons...
for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {

System.debug('##### Operating on this person message to check for account inserts & updates: ' + person);

// For each, check to see if an Account needs to be INSERTed
if (!matchingContactERPMIdMap.containsKey(person.erpmPersonId) && !matchingContactEmailMap.containsKey(person.email)) {
if (person.personAccounts.size() > 0) {

String messageCIMId = person.personAccounts[0].cimId;
System.debug('##### Checking to see if this CIM ID exists: ' + messageCIMId);

// If the account doesn't exist, based on CIM ID...
if (!matchingAccountMap.containsKey(messageCIMId)) {
System.debug('##### CIM ID does not exist, may need to create account');

// If this was RDC self-registration, create an account
if (isRDCSelfRegistration(person)) {
Account a = getAccountFromERPMPerson(person);
accountsToInsert.add(a);
System.debug('##### This person message looks like RDC self-reg, attempting to add account: ' + a);
}
// If not RDC self-registration, ignore all further processing of the message
else {
person.ignoreMessage = true;
System.debug('##### This person message does NOT look like RDC self-reg, dropping it');
}
}
}
else {
// If we don't have an account in the message, ignore all further processing in the message
person.ignoreMessage = true;
System.debug('##### Cannot find an account in the message, dropping it');
}
}
}

// Perform DML INSERTs for Accounts (IDs from inserts will be needed if a Contact needs to be inserted)
System.debug('##### accountsToInsert: ' + accountsToInsert);
if (accountsToInsert.size() > 0)
insert accountsToInsert;

for (Account a : accountsToInsert) {
matchingAccountMap.put(a.Core_CIM_ID__c, a);
}*/
            
            // Loop through collection of erpmPersons...
            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                if (!person.ignoreMessage) {
                    
                    System.debug('##### Operating on this person message to check for contact inserts & updates: ' + person);
                    
                    // For each, check Contact records from collections to see if a Contact needs to be INSERTed or UPDATEed,
                    // and add to DML collections accordingly. First check by ERPM Person ID, then by Email.
                    if (matchingContactERPMIdMap.containsKey(person.erpmPersonId) || matchingContactEmailMap.containsKey(person.email)) {
                        
                        System.debug('##### Found the contact, so this may be an update');
                        
                        // Get Contact by ERPM Person ID if possible, otherwise by Email
                        Contact c = matchingContactERPMIdMap.containsKey(person.erpmPersonId) ?
                            matchingContactERPMIdMap.get(person.erpmPersonId) :
                        matchingContactEmailMap.get(person.email);
                        
                        // If ERPM Person Id isn't NULL and doesn't match, it means we found the Contact on Email address.
                        // Per US49540, we need to ignore such messages.
                        if ((c.Core_eRPM_Person_Id__c != null) && (c.Core_eRPM_Person_Id__c != person.erpmPersonId)) {
                            System.debug('##### Contact was found based on email address, but ERPM Person Id ' +
                                         'doesn\'t match the message, so ignoring this message');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'Contact was found based on email address, but ERPM Person Id doesn\'t match the message';
                        }
                        // US64227: ignore messages published *before* the last timestamp on the Contact record
                        else if (person.publishTimestamp < c.Core_ERPM_Integration_Publish_Timestamp__c) {
                            System.debug('##### Person message publish-timestamp (' + person.publishTimestamp + ') is before ' +
                                         'last timestamp on the Contact record (' + c.Core_ERPM_Integration_Publish_Timestamp__c + ')');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'Person message was published *before* the last one successfully processed';
                        }
                        else {
                            // Always set the Publish Timestamp on the Contact record to what's in the message
                            c.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
                            
                            // Check for "Deleted"
                            if (person.isDeleteIndicator == 'Y') {
                                System.debug('##### ERPM deletion, so blanking out some fields');
                                c.Core_Login_Status__c = 'Deleted';
                                //c.Core_Tokenized__c = true; // Added for US61328
                                contactsToUpdate.add(c);
                                
                                contactIdsToUpdateAgain.add(c.Id);
                            }
                            // Check for "Disabled"
                            else if (person.inactIndicator == 'Y') {
                                System.debug('##### ERPM disabled, so blanking out some fields');
                                c.Core_Login_Status__c = 'Disabled';
                                contactsToUpdate.add(c);
                            }
                            // Check for "Soft Delete" -- keeping this separate in case we need to handle it differently later
                            else if ((person.enterpriseId == '') &&
                                     (person.erpmPersonId == c.Core_ERPM_Person_Id__c) &&
                                     (person.email == c.Email) &&
                                     (!String.isBlank(c.Core_Enterprise_Id__c) || !String.isBlank(c.Core_Login_Id__c))) {
                                         
                                         System.debug('##### ERPM soft delete, so blanking out some fields');
                                         c.Core_Login_Status__c = 'Deleted';
                                         contactsToUpdate.add(c);
                                         
                                         contactIdsToUpdateAgain.add(c.Id);
                                         
                                         person.isDeleteIndicator = 'Y'; // Set this so we can easily use it to execute Contact Entitlement removal below
                                     }
                            // Otherwise it's just a normal contact update
                            else {
                                // Prepare to update the fields needed
                                System.debug('##### Not ERPM deleted, disabled, or soft deleted, so updating the record');
                                
                                // Yet another safeguard added here to prevent updating a non-NULL ERPM Person Id where it doesn't match the message
                                if ((c.Core_eRPM_Person_Id__c == null) || (c.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
                                    setContactFieldsFromPerson(c, person);
                                    contactsToUpdate.add(c);
                                }
                            }
                        }
                    }
                    else {
                        System.debug('##### Did not find the contact, so this may be an insert');
                        
                        if ((person.personAccounts.size() > 0) && (!String.isBlank(person.personAccounts[0].cimId))) {
                            
                            System.debug('##### Checking the account in the message');
                            String messageCIMId = person.personAccounts[0].cimId;
                            
                            // Now, in most cases, we should have an account
                            if (matchingAccountMap.containsKey(messageCIMId)) {
                                
                                System.debug('##### Found the account based on CIM ID: ' + messageCIMId);
                                
                                // Prepare to insert a new contact
                                Contact c = new Contact(AccountId = matchingAccountMap.get(messageCIMId).Id);
                                setContactFieldsFromPerson(c, person);
                                contactsToInsert.add(c);
                                System.debug('##### Attempting to add contact record: ' + c);
                            }
                            else {
                                System.debug('##### Did not find the account based on CIM ID, so ignoring this message');
                                person.ignoreMessage = true;
                                person.ignoreReason = 'Did not find the account based on CIM ID';
                            }
                        }
                        else {
                            System.debug('##### No account in the message, so ignoring this message');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'No account in the message';
                        }
                    }
                }
            }
            
            // Perform DML INSERTs and UPDATEs for Contacts (IDs from inserts will be needed for next step)
            System.debug('##### contactsToUpdate: ' + contactsToUpdate);
            if (contactsToUpdate.size() > 0)
                update contactsToUpdate;
            
            // For deletes/soft deletes, we need to perform a second update
            if (contactIdsToUpdateAgain.size() > 0) {
                contactsToUpdate = [select Id, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c
                                    from Contact where Id in :contactIdsToUpdateAgain];
                List<Contact> contactsToUpdateAgain = new List<Contact>();
                for (Contact c : contactsToUpdate) {
                    c.Core_Login_Id__c = null;
                    c.Core_Login_Status__c = null;
                    c.Core_Enterprise_Id__c = null;
                    contactsToUpdateAgain.add(c);
                }
                System.debug('##### contactsToUpdateAgain: ' + contactsToUpdateAgain);
                if (contactsToUpdateAgain.size() > 0)
                    update contactsToUpdateAgain;
            }
            
            System.debug('##### contactsToInsert: ' + contactsToInsert);
            if (contactsToInsert.size() > 0) {
                insert contactsToInsert;
                
                // For our RDC self-reg checks below, we need to re-pull some additional information from our freshly inserted contacts
                Set<Id> contactIdsInserted = new Set<Id>();
                for (Contact c : contactsToInsert)
                    contactIdsInserted.add(c.Id);
                
                contactsToInsert = [
                    select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                    Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                    Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                    Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c, Core_Do_Not_Contact__c,
                    Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, Core_AGS_Integration_Status__c, Core_Deactivated__c,
                    Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c
                    from Contact
                    where Id in :contactIdsInserted];
            }
            
            Map<String,Contact> allContactsMap = new Map<String,Contact>();
            Map<String,Contact> insertedContactsMap = new Map<String,Contact>();
            for (Contact c : contactsToUpdate) {
                allContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                tags += addTag(c.Id);
            }
            for (Contact c : contactsToInsert) {
                allContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                insertedContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                tags += addTag(c.Id);
            }
            
            //--------------------------------------------------------------------------------------------------
            // ENTITLEMENT & ERPM ENGAGEMENT RECORD POTENTIAL INSERTS
            
            insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);
            
            // Create a new map of all ERPM Engagements to Entitlement IDs in the system
            List<Core_Entitlement__c> fullSetEntitlements = [
                select Id, Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
                from Core_Entitlement__c where Core_AGS_Role_Id__c = '' and Core_ERPM_Engagement_Id__c != null];
            Map<String,Id> engagementCodeEntitlementIdMap = new Map<String,Id>();
            
            for (Core_Entitlement__c e : fullSetEntitlements)
                engagementCodeEntitlementIdMap.put(e.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, e.Id);
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT ENTITLEMENT RECORD INSERTS & UPDATES
            
            // For upcoming inserts & updates
            List<Core_Contact_Entitlement__c> contactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
            List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate = new List<Core_Contact_Entitlement__c>();
            
            // Loop through collection of erpmPersons...
            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                if (!person.ignoreMessage) {
                    
                    System.debug('##### Operating on this person message to check for contact entitlement record inserts & updates: ' + person);
                    
                    List<Core_Contact_Entitlement__c> existingContactEntitlements;
                    List<Core_Contact_Entitlement__c> existingContactEntitlementsAll;
                    
                    // Use Contact IDs from previous steps to look up Contact Entitlements, if any
                    Contact c = allContactsMap.get(person.erpmPersonId);
                    if (c == null)
                        c = allContactsMap.get(null);
                    
                    if (c != null && matchingContactEntitlementEnggMap != null && matchingContactEntitlementEnggMap.containsKey(c.Id) &&
                        (matchingContactEntitlementEnggMap.get(c.Id) != null)) {
                            existingContactEntitlements = matchingContactEntitlementEnggMap.get(c.Id);
                            existingContactEntitlementsAll = matchingContactEntitlementAllMap.get(c.Id);
                        }
                    
                    // If this was an ERPM "soft delete", place them in DML collection for UPDATE to "deselected"
                    if (person.isDeleteIndicator == 'Y') {
                        if (existingContactEntitlementsAll != null) {
                            System.debug('##### ERPM soft delete, so updating contact entitlements to deselected');
                            for (Core_Contact_Entitlement__c ce : existingContactEntitlementsAll)
                                ce.Core_Selected__c = false;
                            contactEntitlementsToUpdate.addAll(existingContactEntitlementsAll);
                        }
                    }
                    // If it wasn't a soft delete...
                    else {
                        Set<String> existingContactEngagementCodes = new Set<String>();
                        
                        Map<String,Core_Contact_Entitlement__c> matchingEngagementCodeEntitlementMap = new Map<String,Core_Contact_Entitlement__c>();
                        
                        // Build up a set of all existing ERPM Engagement Codes for this user in the DB already, and
                        // a map of ERPM Engagement Code to the Contact Entitlement record corresponding to it (the one record
                        // that truly represents the ERPM Engagement as inactive no-role Entitlement)
                        if (existingContactEntitlements != null) {
                            for (Core_Contact_Entitlement__c ce : existingContactEntitlements) {
                                
                                String engagementCode = ce.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                                existingContactEngagementCodes.add(engagementCode);
                                matchingEngagementCodeEntitlementMap.put(engagementCode, ce);
                            }
                        }
                        
                        Map<String,List<Core_Contact_Entitlement__c>> matchingEngagementCodeEntitlementListMap =
                            new Map<String,List<Core_Contact_Entitlement__c>>();
                        
                        // Continue building our set of all existing ERPM Engagement Codes for this user in the DB already, and
                        // a map of ERPM Engagement Code to a list of ALL Contact Entitlement records corresponding to it, with & without roles
                        if (existingContactEntitlementsAll != null) {
                            for (Core_Contact_Entitlement__c ce : existingContactEntitlementsAll) {
                                
                                String engagementCode = ce.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                                
                                // DH 1/11/17: commented this line out since it seemed to be throwing off subsequent logic. May need to add it back in later...
                                //existingContactEngagementCodes.add(engagementCode);
                                
                                if (matchingEngagementCodeEntitlementListMap.containsKey(engagementCode))
                                    ceList = matchingEngagementCodeEntitlementListMap.get(engagementCode);
                                else
                                    ceList = new List<Core_Contact_Entitlement__c>();
                                ceList.add(ce);
                                matchingEngagementCodeEntitlementListMap.put(engagementCode, ceList);
                            }
                        }
                        
                        // Keep track of the full list of ERPM engagements
                        Set<String> erpmEngagements = new Set<String>();
                        
                        // Loop through the Person Engagements for the erpmPerson, and for each,
                        // determine whether an INSERT or UPDATE is needed. Place in DML collections.
                        
                        for (Core_IntegrationUtility.ERPM_Engagement engg : person.personEngagements) {
                            System.debug('##### Checking this ERPM person engagement code to see if insert/update is needed: ' + engg.engagementCode);
                            
                            erpmEngagements.add(engg.engagementCode);
                            
                            insertUpdateContactEntitlementLists(contactEntitlementsToInsert, contactEntitlementsToUpdate, person, engg,
                                                                c, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,
                                                                engagementCodeEntitlementIdMap);
                        }
                        
                        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                            for (Core_IntegrationUtility.ERPM_Person_Account_Relation relation : acct.personAccountRelations) {
                                System.debug('##### Checking this ERPM person account relation engg code to see if insert/update needed: ' + relation.engagementCode);
                                
                                if (!erpmEngagements.contains(relation.engagementCode)) {
                                    
                                    erpmEngagements.add(relation.engagementCode);
                                    
                                    Core_IntegrationUtility.ERPM_Engagement engg = new Core_IntegrationUtility.ERPM_Engagement();
                                    engg.engagementCode = relation.engagementCode;
                                    engg.engagementName = relation.engagementName;
                                    engg.engagementStatusCode = relation.engagementStatusCode;
                                    engg.effectiveTierCode = relation.effectiveTierCode;
                                    
                                    insertUpdateContactEntitlementLists(contactEntitlementsToInsert, contactEntitlementsToUpdate, person, engg,
                                                                        c, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,
                                                                        engagementCodeEntitlementIdMap);
                                }
                            }
                        }
                        
                        // Check to see if any engagements were removed and need to be "deselected"
                        // 
                        // DH 4/17/17: After Phoenix Go-Live (discussion with Thirumala, Subbaro, Troy A), this was commented out
                        // so nothing ever gets removed based on the ERPM message.
                        // 
                        // DH 5/4/17: Since we addressed other issues (out-of-order messages), removal of engagements (but not
                        // entitlements) was added back in.
                        // 
                        for (String existingContactEngagementCode : existingContactEngagementCodes) {
                            if (!erpmEngagements.contains(existingContactEngagementCode)) {
                                ceList = matchingEngagementCodeEntitlementListMap.get(existingContactEngagementCode);
                                for (Core_Contact_Entitlement__c ce : ceList) {
                                    // Only deselect *engagements*, not entitlements
                                    if (ce.Core_From_Source__c) {
                                        ce.Core_Selected__c = false;
                                        contactEntitlementsToUpdate.add(ce);
                                        System.debug('##### Deselecting contact engagement record: ' + ce);
                                    }
                                }
                            }
                        }
                    }
                    
                    // RDC Self Registration insert contact - insertedContactsMap
                    // 
                    // DH 4/19/17: this section commented out based on conversation with Thirumala & Troy A
                    // DH 4/24/17: (US64328) section added back in & updated to allow adding of RDC entitlement
                    // if CNDA number is in place (CIM ID check already happens above)
                    if(isRDCSelfRegistration(person) && (insertedContactsMap.get(person.erpmPersonId) != null)) {
                        
                        System.debug('##### This is RDC self-registration, and we found the account by CIM ID... ' +
                                     'checking validations...');
                        
                        System.debug('##### Label.Core_Entitlement_RDC_Secure_Content_Id: ' + Label.Core_Entitlement_RDC_Secure_Content_Id);
                        System.debug('##### insertedContactsMap.get(person.erpmPersonId): ' + insertedContactsMap.get(person.erpmPersonId));
                        System.debug('##### insertedContactsMap.get(person.erpmPersonId).Account.Core_CNDA_Number__c: ' + insertedContactsMap.get(person.erpmPersonId).Account.Core_CNDA_Number__c);
                        
                        if (Core_ContactEntitlementValidation.validateCNDANum(Label.Core_Entitlement_RDC_Secure_Content_Id,
                                                                              insertedContactsMap.get(person.erpmPersonId)) &&
                            Core_ContactEntitlementValidation.validatePersonalEmailIndicator(Label.Core_Entitlement_RDC_Secure_Content_Id,
                                                                                             insertedContactsMap.get(person.erpmPersonId)))
                        {                                                                 
                            System.debug('##### RDC validations passed, so automatically adding the RDC entitlement record.');
                            
                            String erpmAccountData = '';
                            if (person.personAccounts.size() > 0) {
                                erpmAccountData = 'ERPM Account Number: ' + person.personAccounts[0].erpmAccountNumber +
                                    ', CIM ID: ' + person.personAccounts[0].cimId +
                                    ', Account Name: ' + person.personAccounts[0].accountName;
                            }
                            System.debug('##### ERPM Account Data: ' + erpmAccountData);
                            Core_Contact_Entitlement__c ce =
                                new Core_Contact_Entitlement__c(Core_Contact_Id__c=insertedContactsMap.get(person.erpmPersonId).Id, Core_From_Source__c=false, Core_Selected__c=true,
                                                                Core_Entitlement_Id__c=Label.Core_Entitlement_RDC_Secure_Content_Id, // Resource and Design Center for Secure Content Id
                                                                Core_ERPM_Account_Data__c=erpmAccountData, Core_Data_Loaded__c = true);
                            
                            contactEntitlementsToInsert.add(ce);
                        }
                        else {
                            System.debug('##### RDC validations did not pass, so NOT automatically adding the RDC entitlement record.');
                        }
                    }
                }
            }
            
            // Perform DML INSERTs and UPDATEs for Contact Entitlements
            List<Database.SaveResult> lstErrorsFromPartialProcessing = new List<Database.SaveResult>();
            
            SavePoint sp = Database.setSavepoint();
            
            System.debug('##### contactEntitlementsToInsert: ' + contactEntitlementsToInsert);
            if (contactEntitlementsToInsert.size() > 0) {
                //insert contactEntitlementsToInsert;
                Database.SaveResult[] srList = Database.insert(contactEntitlementsToInsert, false);
                System.debug('Zay - SaveResult List - ' + srList);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()) {
                        lstErrorsFromPartialProcessing.add(sr);
                        for(Database.Error er : sr.getErrors()) {
                            System.debug('Zay - SaveResult - Uncaught Error due to Partial Processing - ' + er.getMessage() + ' - Fields with Errors - ' + er.getFields());
                            System.debug('Zay - SaveResult Error - ' + er);
                            System.debug('Zay - SaveResult - ' + er.getMessage().contains('Core_Unique_Id__c') + ' - ' + er.getStatusCode());
                            
                            if(er.getMessage().contains('duplicate value found: Core_Unique_Id__c duplicates value on record with id')) {
                                System.debug('Zay - SaveResult - Found Duplicate Core Unique Id');
                            } else {
                                Database.rollback(sp);
                                System.debug('Zay - SaveResult - RollingBack');
                                insert contactEntitlementsToInsert;
                            }
                        }
                    }
                }
            }
            System.debug('##### contactEntitlementsToUpdate: ' + contactEntitlementsToUpdate);
            if (contactEntitlementsToUpdate.size() > 0)
                update contactEntitlementsToUpdate;
            
            // Get all of the IDs we inserted or updated
            Set<Id> allSuccessfulContactIds = new Set<Id>();
            for (Contact c : contactsToInsert)
                allSuccessfulContactIds.add(c.Id);
            for (Contact c : contactsToUpdate)
                allSuccessfulContactIds.add(c.Id);
            
            List<Contact> contactsToUpdateERPMIntegrationStatus = new List<Contact>();
            
            // Re-pull Contact records before updating Integration Status, so we have any updated values (e.g. English Only fields),
            // including anything we'll also need for sending the Box B Contact OBM below
            contactsToUpdateERPMIntegrationStatus = [
                select Id, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, Core_Enterprise_Id__c,
                Core_Login_Id__c, AccountId, FirstName, LastName, Email, Phone, MailingCountry, Core_Job_Function__c,
                Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Deactivated__c, CreatedDate,
                LastModifiedDate, Account.Core_CIM_ID__c, Account.Name, Core_Contact_B2B_Indicator__c
                from Contact where Id in :allSuccessfulContactIds];
            
            for (Contact c : contactsToUpdateERPMIntegrationStatus) {
                // Change the Contact ERPM Integration Status to 'Successful'. This will trigger the AGS outbound message
                // via Zay's trigger code
                c.Core_ERPM_Integration_Status__c = 'Successful';
                c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.successfulInboundMessage(newList[0].Id);
            }
            
            // Perform DML UPDATE for Contacts
            System.debug('##### contactsToUpdateERPMIntegrationStatus: ' + contactsToUpdateERPMIntegrationStatus);
            if (contactsToUpdateERPMIntegrationStatus.size() > 0)
                update contactsToUpdateERPMIntegrationStatus;
            
            List<Core_Integration_Outbound_Message__c> outboundMessages = new List<Core_Integration_Outbound_Message__c>();
            
            // Now send the Box B Contact outbound messages based on all that were successful
            /* System.debug('##### Checking to see if we should send a Box B Contact message....');
for (Contact c : contactsToUpdateERPMIntegrationStatus) {
System.debug('##### B2B Indicator = ' + c.Core_Contact_B2B_Indicator__c + ', Enterprise ID = ' + c.Core_Enterprise_Id__c);
// Send the message if it's a B2B contact with an Enterprise ID
if ((c.Core_Contact_B2B_Indicator__c == true) && (!String.isBlank(c.Core_Enterprise_Id__c))) {
outboundMessages.add(createBoxBContactMessage(c));
}
}*/
            
            // Perform DML INSERT for Box B Contact outbound messages
            System.debug('##### outboundMessages: ' + outboundMessages);
            if (outboundMessages.size() > 0)
                insert outboundMessages;
            
            // Create a log entry
            String successMessage = '';
            String successDetails = '';
            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                // If we ignored any messages, that's what we put in the log entry
                if ((successMessage == '') && (person.ignoreMessage)) {
                    successMessage = 'Ignored ERPM Person message';
                    successDetails = 'Ignored message based on business rules.';
                    if (person.ignoreReason != '') {
                        successDetails += ' ' + person.ignoreReason + '.';
                    }
                }
            }
            if (successMessage == '') {
                successMessage = 'Successfully processed ERPM Person message';
                successDetails = 'Success!';
            }
            
            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                            successMessage, successDetails, newList[0].Id, LOG_ENTRY_OBJECT, tags);
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);
            
            // Inbound Message Process Status = Failed
            processingStatus = 'Failed';
            processingMessage += ', Further Processing: ' + exceptionMessage;
            
            // Also update all contact records to Failed
            List<Contact> failedContacts = [
                select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                from Contact where Core_eRPM_Person_Id__c in :erpmPersonIds];
            
            if (failedContacts.size() == 0) {
                failedContacts = [
                    select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                    from Contact where Email in :erpmEmails];
            }
            
            for (Contact c : failedContacts) {
                c.Core_ERPM_Integration_Status__c = 'Failed';
                c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.failedInboundMessage(newList[0].Id, ex);
                tags += addTag(c.Id);
            }
            System.debug('##### Updating these contacts to failed: ' + failedContacts);
            if (failedContacts.size() > 0)
                update failedContacts;
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Person message', '', newList[0].Id, LOG_ENTRY_OBJECT, tags, ex);
        }
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
        
        // Update Processing Status to "Successful" or "Failed" depending on above
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = [
            select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c, Core_Publish_Timestamp__c
            from Core_Integration_Inbound_Message__c where Id in :msgIds];
        
        for (Core_Integration_Inbound_Message__c msg : messagesToUpdate) {
            // Note: if we need to start bulk processing messages, with different processing status for each, this will need to change
            msg.Core_Processing_Status__c = processingStatus;
            msg.Core_Exception_Message__c = processingMessage;
            msg.Core_Log_Entry__c = logEntryId;
            msg.Core_Tags__c = tags;
            msg.Core_Publish_Timestamp__c = publishTimestamp;
        }
        
        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        update messagesToUpdate;
    }
    
    
    // Public helper method to return a Box B Contact message from a Contact record. Also called from Contact trigger code.
    /* Pooja removed Box B message creation on ERPM inbound and moved it to process builder.
public static Core_Integration_Outbound_Message__c createBoxBContactMessage(Contact c) {
String tags = '';
// Build up tags for log entry
if (!String.isBlank(c.Core_eRPM_Person_Id__c))
tags += addTag(c.Core_eRPM_Person_Id__c);           
if (!String.isBlank(c.Core_Enterprise_Id__c))
tags += addTag(c.Core_Enterprise_Id__c);
if (!String.isBlank(c.Core_Login_Id__c))
tags += addTag(c.Core_Login_Id__c);           
if (!String.isBlank(c.Email))
tags += addTag(c.Email);
if (!String.isBlank(c.Id))
tags += addTag(c.Id);

Core_IntegrationUtility.BoxB_ContactWrapper b = new Core_IntegrationUtility.BoxB_ContactWrapper();
b.CST_ID            = c.Core_Enterprise_Id__c;
b.INTRNL_LGN_ID     = '';
b.EXTRN_LGN_ID      = c.Core_Login_Id__c;
b.ACCT_ID           = c.AccountId;
b.FRST_NM           = c.FirstName;
b.LST_NM            = c.LastName;
b.ENG_FRST_NM       = c.Core_English_Only_First_Name__c;
b.ENG_LST_NM        = c.Core_English_Only_Last_Name__c;
b.EMAIL_ADDR_TXT    = c.Email;
b.PHN_ADDR_TXT      = c.Phone;
b.EXTRN_ORG_NM      = c.Account.Name;
b.CTRY_NM           = Core_Entitlement_Outbound_Integrations.getISO2CountryCode(c.MailingCountry);
b.USR_ACCT_SUSP_DTM = '';
b.PRI_OCCP_TTL_CD   = c.Core_Job_Function__c;
b.EBUS_AGT_STS_CD   = (c.Core_Deactivated__c ? 'inactive' : 'active'); // TO DO: Validate this logic with Jordan
b.CREATE_DT         = c.CreatedDate.date();
b.CHANGE_DTM        = c.LastModifiedDate;
b.CIMID             = c.Account.Core_CIM_ID__c;
b.ACCT_NM           = c.Account.Name;

String payload = JSON.serialize(b);
System.debug('##### Box B Contact message: ' + payload);

Core_Integration_Outbound_Message__c obm = new Core_Integration_Outbound_Message__c(
Core_Tags__c = tags,
Core_MessageType__c = 'Box B Contact',
Core_Payload__c = '<![CDATA[' + payload + ']]>');
return obm;
}*/
    
    // Helper method to update our Contact Entitlement collections based on records that need to be inserted or updated
    private static void insertUpdateContactEntitlementLists(
        List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,
        List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate,
        Core_IntegrationUtility.ERPM_Person person,
        Core_IntegrationUtility.ERPM_Engagement engg,
        Contact c,
        Set<String> existingContactEngagementCodes,
        Map<String,List<Core_Contact_Entitlement__c>> matchingEngagementCodeEntitlementListMap,
        Map<String,Id> engagementCodeEntitlementIdMap)
    {
        String erpmAccountData = '';
        if (person.personAccounts.size() > 0) {
            erpmAccountData = 'ERPM Account Number: ' + person.personAccounts[0].erpmAccountNumber +
                ', CIM ID: ' + person.personAccounts[0].cimId +
                ', Account Name: ' + person.personAccounts[0].accountName;
        }
        System.debug('##### ERPM Account Data: ' + erpmAccountData);
        
        if (!existingContactEngagementCodes.contains(engg.engagementCode)) {
            System.debug('##### This engagement code does not exist, attempting to add a contact entitlement for it: ' + engg.engagementCode);
            Core_Contact_Entitlement__c ce =
                new Core_Contact_Entitlement__c(Core_Contact_Id__c=c.Id, Core_From_Source__c=true, Core_Selected__c=true,
                                                Core_Entitlement_Id__c=engagementCodeEntitlementIdMap.get(engg.engagementCode),
                                                Core_Engagement_Tier__c=engg.effectiveTierCode,
                                                Core_ERPM_Account_Data__c=erpmAccountData);
            
            contactEntitlementsToInsert.add(ce);
            existingContactEngagementCodes.add(engg.engagementCode);
        }
        // Check to see if "selected" needs to be updated, or the Tier has changed & needs updating
        else if (matchingEngagementCodeEntitlementListMap.containsKey(engg.engagementCode)) {
            System.debug('##### Checking this engagement code to see if contact entitlements need to be updated: ' + engg.engagementCode);
            
            for (Core_Contact_Entitlement__c ce : matchingEngagementCodeEntitlementListMap.get(engg.engagementCode)) {
                System.debug('##### Checking this contact entitlement record to see if it needs to be updated: ' + ce);
                
                if ((ce.Core_Engagement_Tier__c != engg.effectiveTierCode) || (ce.Core_Selected__c == false) ||
                    (ce.Core_ERPM_Account_Data__c != erpmAccountData)) {
                        
                        ce.Core_Engagement_Tier__c = engg.effectiveTierCode;
                        ce.Core_ERPM_Account_Data__c = erpmAccountData;
                        
                        // DH 1/19/17: changed this to *only* update selected to true if it's the no-role entitlement record that represents the engagement itself
                        if (ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c == null)
                            ce.Core_Selected__c = true;
                        
                        System.debug('##### Attempting to update this contact entitlement record to: ' + ce);
                        contactEntitlementsToUpdate.add(ce);
                    }
            }
        }
    }
    
    // Helper method to insert any missing ERPM Engagement & Entitlement records from a list of inbound engagement codes
    // Note: per our current data model, this means there must be an Entitlement record with blank AGS role
    private static void insertMissingEngagementsEntitlements(List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs,
                                                             Set<String> erpmEnggCodes) {
                                                                 
                                                                 // For upcoming inserts
                                                                 List<Core_ERPM_Engagement__c> erpmEngagementsToInsert = new List<Core_ERPM_Engagement__c>();
                                                                 List<Core_Entitlement__c> entitlementsToInsert = new List<Core_Entitlement__c>();
                                                                 
                                                                 // Pull 2 sets of ERPM Engagement records:
                                                                 // - ALL that exist in the system
                                                                 // - All that also have an inactive Entitlement record w/blank AGS role
                                                                 // ...so we can see if we need to insert new inbound ones in both ERPM Engagement + Entitlement, or just Entitlement
                                                                 List<Core_ERPM_Engagement__c> fullSetERPMEngagements = [
                                                                     select Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
                                                                 List<Core_ERPM_Engagement__c> erpmEngagementsWithBlankRoleEntitlement = [
                                                                     select Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c
                                                                     where Id in (select Core_ERPM_Engagement_Id__c from Core_Entitlement__c where Core_AGS_Role_Id__c = '')];
                                                                 
                                                                 Set<String> fullSetERPMEngagementCodes = new Set<String>();
                                                                 Set<String> erpmEngagementCodesWithBlankRoleEntitlement = new Set<String>();
                                                                 
                                                                 for (Core_ERPM_Engagement__c engg : fullSetERPMEngagements)
                                                                     fullSetERPMEngagementCodes.add(engg.Core_Technical_Engagement_Code__c);
                                                                 for (Core_ERPM_Engagement__c engg : erpmEngagementsWithBlankRoleEntitlement)
                                                                     erpmEngagementCodesWithBlankRoleEntitlement.add(engg.Core_Technical_Engagement_Code__c);
                                                                 
                                                                 System.debug('##### fullSetERPMEngagementCodes: ' + fullSetERPMEngagementCodes);
                                                                 System.debug('##### erpmEngagementCodesWithBlankRoleEntitlement: ' + erpmEngagementCodesWithBlankRoleEntitlement);
                                                                 
                                                                 // Only execute the rest of the method if we don't have all of the inbound codes already in the Entitlement table with blank roles
                                                                 if (!erpmEngagementCodesWithBlankRoleEntitlement.containsAll(erpmEnggCodes)) {
                                                                     
                                                                     // Run through the Engagements, and add to our insert collection if needed
                                                                     for (Core_IntegrationUtility.ERPM_Engagement engg : erpmEnggs) {
                                                                         if (!fullSetERPMEngagementCodes.contains(engg.engagementCode)) {
                                                                             
                                                                             if ((engg.engagementName == null) || (engg.engagementName == ''))
                                                                                 engg.engagementName = engg.engagementCode;
                                                                             
                                                                             Core_ERPM_Engagement__c newEngg =
                                                                                 new Core_ERPM_Engagement__c(Name=engg.engagementName, Core_Technical_Name__c=engg.engagementName,
                                                                                                             Core_Technical_Engagement_Code__c=engg.engagementCode, Core_IsActive__c=false);
                                                                             erpmEngagementsToInsert.add(newEngg);
                                                                             fullSetERPMEngagementCodes.add(engg.engagementCode); // Add it to our "full set" so we don't try to add it again
                                                                         }
                                                                     }
                                                                     
                                                                     // Perform DML INSERTs for ERPM Engagements & Entitlements
                                                                     System.debug('##### erpmEngagementsToInsert: ' + erpmEngagementsToInsert);
                                                                     if (erpmEngagementsToInsert.size() > 0)
                                                                         insert erpmEngagementsToInsert;
                                                                     
                                                                     // Re-pull our full set of ERPM Engagements now, and build a map of Engg Code to ID
                                                                     fullSetERPMEngagements = [select Id, Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
                                                                     Map<String,Id> fullSetERPMEngagementCodeIdMap = new Map<String,Id>();
                                                                     for (Core_ERPM_Engagement__c erpmEngagement : fullSetERPMEngagements)
                                                                         fullSetERPMEngagementCodeIdMap.put(erpmEngagement.Core_Technical_Engagement_Code__c, erpmEngagement.Id);
                                                                     
                                                                     // Now add Entitlement records for all ERPM Engagements that don't have a blank role Entitlement
                                                                     for (Core_IntegrationUtility.ERPM_Engagement engg : erpmEnggs) {
                                                                         if (!erpmEngagementCodesWithBlankRoleEntitlement.contains(engg.engagementCode)) {
                                                                             
                                                                             if ((engg.engagementName == null) || (engg.engagementName == ''))
                                                                                 engg.engagementName = engg.engagementCode;
                                                                             
                                                                             Core_Entitlement__c newEnt = new
                                                                                 Core_Entitlement__c(Core_ERPM_Engagement_Id__c=fullSetERPMEngagementCodeIdMap.get(engg.engagementCode),
                                                                                                     Name=engg.engagementName, Core_IsActive__c=false, Core_Display_Name__c=engg.engagementName);
                                                                             entitlementsToInsert.add(newEnt);
                                                                         }
                                                                     }
                                                                     
                                                                     System.debug('##### entitlementsToInsert: ' + entitlementsToInsert);
                                                                     if (entitlementsToInsert.size() > 0)
                                                                         insert entitlementsToInsert;
                                                                 }
                                                             }
    
    // Copy information from an ERPM Person record into a Contact record
    private static void setContactFieldsFromPerson(Contact c, Core_IntegrationUtility.ERPM_Person person) {
        
        // Additional safeguards added here to ensure 100% we don't overwrite anything if ERPM Person ID is non-NULL and doesn't match message
        if ((c.Core_eRPM_Person_Id__c == null) || (c.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
            if (c.Core_eRPM_Person_Id__c == null) {
                c.Core_eRPM_Person_Id__c    = person.erpmPersonId;
            }
            c.Core_Login_Id__c          = person.loginId;
            c.Core_Enterprise_Id__c     = person.enterpriseId;
            c.Core_Identity_Status__c   = person.identityStatus;
            c.Core_Login_Status__c      = (person.identityStatus == 'A' ? 'Active' :
                                           person.identityStatus == 'D' ? 'Disabled' :
                                           person.identityStatus == 'X' ? 'Expired' : ''); // OPEN: waiting on logic from Jordan for Deleted
            c.Title                     = person.title;
            c.FirstName                 = person.firstName;
            c.LastName                  = person.lastName;
            c.Email                     = person.email;
            c.Core_eRPM_Language_Code__c= person.erpmLanguageCode;
            c.Core_Job_Function_Code__c = person.jobFunctionCode;
            c.Core_Do_Not_Contact__c    = (person.doNotContact == 'Y' ? true : false);
            c.Phone                     = person.phone;
            c.MobilePhone               = person.mobilePhone;
            c.Fax                       = person.fax;
            //c.MailingStreet             = person.mailingStreet1;
            //c.MailingStreet             += (person.mailingStreet2.trim() != '' ? (' ' + person.mailingStreet2) : '');
            //c.MailingStreet             += (person.mailingStreet3.trim() != '' ? (' ' + person.mailingStreet3) : '');
            //c.MailingStreet             += (person.mailingStreet4.trim() != '' ? (' ' + person.mailingStreet4) : '');
            //c.MailingCity               = person.mailingCity;
            //c.MailingState              = person.mailingState;
            //c.MailingPostalCode         = person.mailingPostalCode;
            //c.MailingCountry            = person.mailingCountry;
            c.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
        }
    }
    
    // Copy info from an ERPM Person record into an Account record (for RDC self-registration)
    /*private static Account getAccountFromERPMPerson(Core_IntegrationUtility.ERPM_Person person) {

Account a              = new Account();
a.Name                 = person.personAccounts[0].accountName;
a.Core_CIM_ID__c       = person.personAccounts[0].cimId;
a.BillingStreet        = person.mailingStreet1;
a.BillingStreet        = a.BillingStreet + (person.mailingStreet2.trim() != '' ? (' ' + person.mailingStreet2) : '');
a.BillingStreet        = a.BillingStreet + (person.mailingStreet3.trim() != '' ? (' ' + person.mailingStreet3) : '');
a.BillingStreet        = a.BillingStreet + (person.mailingStreet4.trim() != '' ? (' ' + person.mailingStreet4) : '');
a.BillingCity          = person.mailingCity;
a.BillingState         = person.mailingState;
a.BillingPostalCode    = person.mailingPostalCode;
a.BillingCountry       = person.mailingCountry;
a.Industry             = RDC_ACCOUNT_INDUSTRY;
a.Core_Account_Type__c = RDC_ACCOUNT_TYPE;
a.Core_Sales_Group__c  = RDC_ACCOUNT_SALES_GROUP;

return a;
}*/
    
    // Copy info from an ERPM Account record into an Account (for RDC self-registration)
    private static Account getAccountFromERPMAccount(Core_IntegrationUtility.ERPM_Account acct) {
        
        Account a              = new Account();
        a.Name                 = acct.name;
        a.Core_CIM_ID__c       = acct.cimId;
        a.BillingStreet        = acct.primaryStreet1;
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet2.trim() != '' ? (' ' + acct.primaryStreet2) : '');
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet3.trim() != '' ? (' ' + acct.primaryStreet3) : '');
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet4.trim() != '' ? (' ' + acct.primaryStreet4) : '');
        a.BillingCity          = acct.primaryCity;
        a.BillingState         = acct.primaryState;
        a.BillingPostalCode    = acct.primaryPostalCode;
        a.BillingCountry       = acct.primaryCountry;
        a.Industry             = RDC_ACCOUNT_INDUSTRY;
        a.Core_Account_Type__c = RDC_ACCOUNT_TYPE;
        a.Core_Sales_Group__c  = RDC_ACCOUNT_SALES_GROUP;
        
        return a;
    }
    
    // Helper method to determine, based on an ERPM Person record, whether or not it's RDC self-registration
    private static Boolean isRDCSelfRegistration(Core_IntegrationUtility.ERPM_Person person) {
        
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements)
                if (engg.engagementCode == RDC_ENGAGEMENT_CODE)
                return true;
        }
        return false;
    }
    
    // Helper method to determine, based on an ERPM Account record, whether or not it's RDC self-registration
    private static Boolean isRDCSelfRegistration(Core_IntegrationUtility.ERPM_Account acct) {
        
        for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
            if (engg.engagementCode == RDC_ENGAGEMENT_CODE)
                return true;
        }
        return false;
    }
    
    // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
            }
    
    
    // Main method for processing ERPM Account messages
    public static void processAccountMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        // Note: currently we have a single status for the whole batch, which all records will be set to. This is fine
        // for now, since iPaaS won't be sending batches. But goal state should be to have separate status per message.
        String processingStatus = 'Successful';
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        Set<Id> msgIds = new Set<Id>();
        
        List<Core_IntegrationUtility.ERPM_Account> erpmAccounts = new List<Core_IntegrationUtility.ERPM_Account>();
        
        Set<Id> erpmAccountIds = new Set<Id>();
        Set<String> erpmCIMIDs = new Set<String>();
        List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs = new List<Core_IntegrationUtility.ERPM_Engagement>();
        Set<String> erpmEnggCodes = new Set<String>();
        
        // Build up "tags" for log entry/inbound message below
        String tags = '';
        
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET RELEVANT ID VALUES
        
        for (Core_Integration_Inbound_Message__c msg : newList) {
            
            // Only process messages inserted as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (getFullPayload(msg) != null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of erpmPersons
                    Core_IntegrationUtility.ERPM_Account acct =
                        Core_IntegrationInboundMessageParsing.parseAccount(getFullPayload(msg));
                    System.debug('##### ERPM Account message parsed into an object: ' + acct);
                    
                    erpmAccounts.add(acct);
                    
                    // Save the necessary ID values into collections that we'll need in upcoming SELECT statements
                    if ((acct.sfdcId != null) && (acct.sfdcId != '')) {
                        erpmAccountIds.add(acct.sfdcId);
                        tags += addTag(acct.sfdcId);
                    }
                    if ((acct.cimId != null) && (acct.cimId != '')) {
                        erpmCIMIds.add(acct.cimId);
                        tags += addTag(acct.cimId);
                    }
                    if ((acct.erpmAccountNumber != null) && (acct.erpmAccountNumber != '')) {
                        tags += addTag(acct.erpmAccountNumber);
                    }
                    
                    for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
                        erpmEnggs.add(engg);
                        erpmEnggCodes.add(engg.engagementCode);
                    }
                }
                catch(Exception ex) {
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                    System.debug('##### Exception: ' + exceptionMessage);
                    processingStatus = 'Failed';
                    processingMessage += ', Message 3: ' + exceptionMessage;
                    
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error reading ERPM Account message', '', msg.Id, LOG_ENTRY_OBJECT, '', ex);
                }
            }
        }
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL RECORDS WE'LL NEED FOR FURTHER PROCESSING
        
        try {
            // Accounts
            List<Account> matchingAccounts = new List<Account>();
            Set<Id> matchingAccountIds = new Set<Id>();
            Map<Id,Account> matchingAccountIdMap = new Map<Id,Account>();
            Map<String,Account> matchingAccountCIMIdMap = new Map<String,Account>();
            
            // Pull by SFDC IDs if we have them. Pull by CIM IDs if we don't. (Ideally this should handle a mix,
            // but I'm keeping the code simple at this point, since we won't get a mix.)
            if (erpmAccountIds.size() > 0) {
                
                matchingAccounts = [select Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c
                                    from Account where Id in :erpmAccountIds];
            }
            else if (erpmCIMIds.size() > 0) {
                
                // Order this list by created date, earliest first, so we can just take the first if multiple
                matchingAccounts = [
                    select Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c
                    from Account
                    where Core_CIM_ID__c in :erpmCIMIds
                    order by Core_CIM_ID__c, CreatedDate asc];
            }
            System.debug('##### matchingAccounts: ' + matchingAccounts);
            
            for (Account a : matchingAccounts) {
                matchingAccountIds.add(a.Id);
                matchingAccountIdMap.put(a.Id, a);
                if (!matchingAccountCIMIdMap.containsKey(a.Core_CIM_ID__c)) {
                    matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
                }
            }
            
            // Account ERPM Engagements
            List<Core_Account_ERPM_Engagement__c> matchingAccountERPMEngagements = new List<Core_Account_ERPM_Engagement__c>();
            Map<Id,List<Core_Account_ERPM_Engagement__c>> matchingAccountERPMEngagementMap =
                new Map<Id,List<Core_Account_ERPM_Engagement__c>>();
            
            if (matchingAccountIds.size() > 0) {
                
                matchingAccountERPMEngagements = [
                    select Id, Core_Account_Id__c, Core_ERPM_Engagement_Id__c, Core_ERPM_Business_Attributes__c,
                    Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
                    from Core_Account_ERPM_Engagement__c
                    where Core_Account_Id__c in :matchingAccountIds];
            }
            for (Core_Account_ERPM_Engagement__c aee : matchingAccountERPMEngagements) {
                
                List<Core_Account_ERPM_Engagement__c> aeeList;
                
                if (matchingAccountERPMEngagementMap.containsKey(aee.Core_Account_Id__c))
                    aeeList = matchingAccountERPMEngagementMap.get(aee.Core_Account_Id__c);
                else
                    aeeList = new List<Core_Account_ERPM_Engagement__c>();
                
                aeeList.add(aee);
                matchingAccountERPMEngagementMap.put(aee.Core_Account_Id__c, aeeList);
            }
            
            // ERPM Engagements
            List<Core_ERPM_Engagement__c> matchingERPMEngagements = new List<Core_ERPM_Engagement__c>();
            Set<Id> matchingERPMEngagementIds = new Set<Id>();
            
            if (matchingAccountERPMEngagements.size() > 0) {
                
                matchingERPMEngagements = [
                    select Id, Name, Core_Technical_Name__c, Core_Description__c, Core_Technical_Engagement_Code__c
                    from Core_ERPM_Engagement__c
                    where Core_Technical_Engagement_Code__c in :erpmEnggCodes];
                
                for (Core_ERPM_Engagement__c engg : matchingERPMEngagements)
                    matchingERPMEngagementIds.add(engg.Id);
            }
            
            // Entitlements
            List<Core_Entitlement__c> matchingEntitlements = new List<Core_Entitlement__c>();
            
            if (matchingERPMEngagements.size() > 0) {
                
                matchingEntitlements = [
                    select Id, Name, Core_ERPM_Engagement_Id__c, Core_Display_Name__c, Core_Description__c
                    from Core_Entitlement__c
                    where Core_ERPM_Engagement_Id__c in :matchingERPMEngagementIds and Core_AGS_Role_Id__c = ''];
            }
            
            // Collections for Account INSERTs and UPDATEs
            List<Account> accountsToInsert = new List<Account>();
            List<Account> accountsToUpdate = new List<Account>();
            
            //--------------------------------------------------------------------------------------------------
            // ACCOUNT RECORD INSERTS & UPDATES
            
            // Loop through collection of erpmAccounts...
            for (Core_IntegrationUtility.ERPM_Account acct : erpmAccounts) {
                
                System.debug('##### Operating on this account message to check for account inserts & updates: ' + acct);
                
                if (acct.sfdcId == '')
                    acct.sfdcId = null;
                
                // For each, check to see if an Account needs to be INSERTed
                if (!matchingAccountIds.contains(acct.sfdcId) && !matchingAccountCIMIdMap.containsKey(acct.cimId)) {
                    System.debug('##### SFDC ID and CIM ID do not exist, may need to create account');
                    
                    // If this was RDC self-registration, create an account
                    if (isRDCSelfRegistration(acct)) {
                        Account a = getAccountFromERPMAccount(acct);
                        
                        if (acct.enggDedupGroupCode == B2B_DEDUP_GROUP_CODE)
                            a.Core_B2B_ERPM_Account_Number__c = acct.erpmAccountNumber;
                        
                        accountsToInsert.add(a);
                        System.debug('##### This account message looks like RDC self-reg, attempting to add account: ' + a);
                    }
                    // If not RDC self-registration, ignore all further processing of the message
                    else {
                        acct.ignoreMessage = true;
                        System.debug('##### This account message does NOT look like RDC self-reg, dropping it');
                    }
                }
                else {
                    System.debug('##### Found the account based on SFDC ID or CIM ID');
                    
                    // The only scenario where we need to update anything on the account right now is
                    // if the ERPM message has the B2B dedup group code
                    if (acct.enggDedupGroupCode == B2B_DEDUP_GROUP_CODE) {
                        Account accountToUpdate = matchingAccountIdMap.containsKey(acct.sfdcId) ?
                            matchingAccountIdMap.get(acct.sfdcId) : matchingAccountCIMIdMap.get(acct.cimId);
                        
                        accountToUpdate.Core_B2B_ERPM_Account_Number__c = acct.erpmAccountNumber;
                        accountsToUpdate.add(accountToUpdate);
                        System.debug('##### Attempting to update this account: ' + accountToUpdate);
                    }
                }
            }
            
            // Perform DML INSERTs and UPDATEs for Accounts
            System.debug('##### accountsToUpdate: ' + accountsToUpdate);
            if (accountsToUpdate.size() > 0)
                update accountsToUpdate;
            
            System.debug('##### accountsToInsert: ' + accountsToInsert);
            if (accountsToInsert.size() > 0)
                insert accountsToInsert;
            
            for (Account a : accountsToInsert) {
                matchingAccountIdMap.put(a.Id, a);
                matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
            }
            
            //--------------------------------------------------------------------------------------------------
            // ENTITLEMENT & ERPM ENGAGEMENT RECORD POTENTIAL INSERTS
            
            insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);
            
            // Create a new map of all ERPM Engagement Codes to Engagement IDs in the system
            List<Core_ERPM_Engagement__c> fullSetEngagements = [
                select Id, Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
            Map<String,Id> engagementCodeEngagementIdMap = new Map<String,Id>();
            
            for (Core_ERPM_Engagement__c ee : fullSetEngagements)
                engagementCodeEngagementIdMap.put(ee.Core_Technical_Engagement_Code__c, ee.Id);
            
            //--------------------------------------------------------------------------------------------------
            // ACCOUNT ERPM ENGAGEMENT RECORD INSERTS & UPDATES
            
            // For upcoming inserts & updates
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToInsert = new List<Core_Account_ERPM_Engagement__c>();
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToUpdate = new List<Core_Account_ERPM_Engagement__c>();
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToDelete = new List<Core_Account_ERPM_Engagement__c>();
            
            // Loop through collection of erpmAccounts...
            for (Core_IntegrationUtility.ERPM_Account erpmAcct : erpmAccounts) {
                if (!erpmAcct.ignoreMessage) {
                    
                    System.debug('##### Operating on this account message to check for account ERPM engagement inserts & updates: ' + erpmAcct);
                    
                    Account acct;
                    
                    // Use Account IDs from previous steps to look up Account ERPM Engagements, if any
                    if (matchingAccountIdMap.containsKey(erpmAcct.sfdcId))
                        acct = matchingAccountIdMap.get(erpmAcct.sfdcId);
                    else if (matchingAccountCIMIdMap.containsKey(erpmAcct.cimId))
                        acct = matchingAccountCIMIdMap.get(erpmAcct.cimId);
                    
                    List<Core_Account_ERPM_Engagement__c> existingAEEs = matchingAccountERPMEngagementMap.get(acct.Id);
                    
                    Set<String> existingAccountEngagementCodes = new Set<String>();
                    Map<String,Core_Account_ERPM_Engagement__c> matchingEngagementCodeAEEMap = new Map<String,Core_Account_ERPM_Engagement__c>();
                    
                    if (existingAEEs != null) {
                        for (Core_Account_ERPM_Engagement__c aee : existingAEEs) {
                            existingAccountEngagementCodes.add(aee.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
                            matchingEngagementCodeAEEMap.put(aee.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, aee);
                        }
                    }
                    Set<String> erpmEngagements = new Set<String>();
                    
                    for (Core_IntegrationUtility.ERPM_Engagement engg : erpmAcct.accountEngagements) {
                        System.debug('##### Checking this ERPM account engagement code to see if insert/update is needed: ' + engg.engagementCode);
                        
                        erpmEngagements.add(engg.engagementCode);
                        
                        if (!existingAccountEngagementCodes.contains(engg.engagementCode)) {
                            Core_Account_ERPM_Engagement__c aee =
                                new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=acct.Id, Core_ERPM_Account_Number__c = erpmAcct.erpmAccountNumber,
                                                                    Core_ERPM_Engagement_Id__c=engagementCodeEngagementIdMap.get(engg.engagementCode),
                                                                    Core_ERPM_Business_Attributes__c=engg.effectiveTierCode
                                                                   );
                            accountERPMEngagementsToInsert.add(aee);
                            existingAccountEngagementCodes.add(engg.engagementCode);
                            System.debug('##### Attempting to add account ERPM engagement code: ' + aee);
                        }
                        // Check to see if "selected" needs to be updated, or the Tier has changed & needs updating
                        else if (matchingEngagementCodeAEEMap.get(engg.engagementCode).Core_ERPM_Business_Attributes__c != engg.effectiveTierCode) {
                            Core_Account_ERPM_Engagement__c aee = matchingEngagementCodeAEEMap.get(engg.engagementCode);
                            aee.Core_ERPM_Business_Attributes__c = engg.effectiveTierCode;
                            aee.Core_ERPM_Account_Number__c = erpmAcct.erpmAccountNumber;
                            accountERPMEngagementsToUpdate.add(aee);
                            System.debug('##### Attempting to update account ERPM engagement code: ' + aee);
                        }
                    }
                    
                    // Check to see if any engagements were removed and need to be deleted
                    for (String existingAccountEngagementCode : existingAccountEngagementCodes) {
                        if (!erpmEngagements.contains(existingAccountEngagementCode)) {
                            Core_Account_ERPM_Engagement__c aee = matchingEngagementCodeAEEMap.get(existingAccountEngagementCode);
                            accountERPMEngagementsToDelete.add(aee);
                            System.debug('##### Attempting to delete account ERPM engagement code: ' + aee);
                        }
                    }
                }
            }
            
            // Perform DML INSERTs, UPDATEs, DELETEs for Account ERPM Engagements
            System.debug('##### accountERPMEngagementsToInsert: ' + accountERPMEngagementsToInsert);
            if (accountERPMEngagementsToInsert.size() > 0)
                insert accountERPMEngagementsToInsert;
            
            System.debug('##### accountERPMEngagementsToUpdate: ' + accountERPMEngagementsToUpdate);
            if (accountERPMEngagementsToUpdate.size() > 0)
                update accountERPMEngagementsToUpdate;
            
            // TO DO: resolve this open. For now, we won't be deleting or inactivating Account Engagements.
            //System.debug('##### accountERPMEngagementsToDelete: ' + accountERPMEngagementsToDelete);
            //if (accountERPMEngagementsToDelete.size() > 0)
            //    delete accountERPMEngagementsToDelete;
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                            'Successfully processed ERPM Account message',
                                                            'Success!', newList[0].Id, LOG_ENTRY_OBJECT, tags);
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);
            processingStatus = 'Failed';
            processingMessage += ', Message 4: ' + exceptionMessage;
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Account message', '', newList[0].Id,
                                                              LOG_ENTRY_OBJECT, tags, ex);
        }
        
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
        
        // Update Processing Status to "Successful" or "Failed" depending on above
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = [
            select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c
            from Core_Integration_Inbound_Message__c where Id in :msgIds];
        
        for (Core_Integration_Inbound_Message__c msg : messagesToUpdate) {
            msg.Core_Processing_Status__c = processingStatus;
            msg.Core_Exception_Message__c = processingMessage;
            msg.Core_Log_Entry__c = logEntryId;
            msg.Core_Tags__c = tags;
        }
        
        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        update messagesToUpdate;
    }
    
    
    // Main method for processing ERPM Blackbox messages
    public static void processBlackboxMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        // Note: currently we have a single status for the whole batch, which all records will be set to. This is fine
        // for now, since iPaaS won't be sending batches. But goal state should be to have separate status per message.
        String processingStatus = 'Successful';
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        Set<Id> msgIds = new Set<Id>();
        
        List<Core_IntegrationUtility.ERPM_Blackbox_Response> bbResponses =
            new List<Core_IntegrationUtility.ERPM_Blackbox_Response>();
        
        Set<String> erpmPersonIds = new Set<String>();
        Set<String> erpmEmails = new Set<String>();
        Map<String,Core_IntegrationUtility.ERPM_Blackbox_Response> erpmPersonIdResponseMap =
            new Map<String,Core_IntegrationUtility.ERPM_Blackbox_Response>();
        Map<String,Core_IntegrationUtility.ERPM_Blackbox_Response> erpmEmailResponseMap =
            new Map<String,Core_IntegrationUtility.ERPM_Blackbox_Response>();
        
        Map<Id, Core_IntegrationUtility.ERPM_Blackbox_Response> ibMsgRespErrorMap = new Map<Id, Core_IntegrationUtility.ERPM_Blackbox_Response>();
        // Build up "tags" to add to log entry/inbound message
        String tags = '';
        
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET PERSON ID/EMAIL VALUES FOR FUTURE CONTACT LOOKUP
        
        for (Core_Integration_Inbound_Message__c msg : newList) {
            
            // Only process messages inserted/updated as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (msg.Core_Payload__c != null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of blackbox responses
                    Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse =
                        Core_IntegrationInboundMessageParsing.parseBlackboxResponse(msg.Core_Payload__c);
                    System.debug('##### ERPM Blackbox response message parsed into an object: ' + bbResponse);
                    
                    bbResponses.add(bbResponse);
                    
                    if ((bbResponse.PersonID != null) && (bbResponse.PersonID != '')) {
                        erpmPersonIds.add(bbResponse.PersonID);
                        erpmPersonIdResponseMap.put(bbResponse.PersonID, bbResponse);
                        tags += addTag(bbResponse.PersonID);
                    }
                    if ((bbResponse.EnterpriseID != null) && (bbResponse.EnterpriseID != '')) {
                        tags += addTag(bbResponse.EnterpriseID);
                    }
                    if ((bbResponse.LoginID != null) && (bbResponse.LoginID != '')) {
                        tags += addTag(bbResponse.LoginID);
                    }
                    if ((bbResponse.EmailID != null) && (bbResponse.EmailID != '')) {
                        erpmEmails.add(bbResponse.EmailID);
                        erpmEmailResponseMap.put(bbResponse.EmailID, bbResponse);
                        tags += addTag(bbResponse.EmailID);
                    }
                    if (bbResponse.Accounts != null) {
                        for (Core_IntegrationUtility.ERPM_Blackbox_Account bbAccount : bbResponse.Accounts) {
                            tags += addTag(bbAccount.AccountNumber) + addTag(bbAccount.CIMID) + addTag(bbAccount.SalesCloudID);
                        }
                    }
                    
                    Core_IntegrationUtility.ERPM_Blackbox_Response forReUpdate = new Core_IntegrationUtility.ERPM_Blackbox_Response();
                    forReUpdate.ErrorCode = bbResponse.ErrorCode;
                    forReUpdate.ErrorText = bbResponse.ErrorText;
                    forReUpdate.ErrorDetails = bbResponse.ErrorDetails;
                    ibMsgRespErrorMap.put(msg.Id, forReUpdate);
                    
                }
                catch(Exception ex) {
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                    System.debug('##### processBlackboxMessages Exception: ' + exceptionMessage);
                    processingStatus = 'Failed';
                    processingMessage += ', ' + exceptionMessage;
                    
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error reading ERPM Blackbox message', '', msg.Id, LOG_ENTRY_OBJECT, '', ex);
                }
            }
        }
        System.debug('##### erpmPersonIds: ' + erpmPersonIds);
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL MATCHING CONTACT RECORDS, TO UPDATE
        
        try {
            // We need at least a Person ID or Email. If we don't have one, the next SOQL statement will throw an
            // exception only when run in an actual org, not in our test classes. So let's throw one explicitly instead.
            if ((erpmPersonIds.size() == 0) && (erpmEmails.size() == 0)) {
                throw new CustomException('Blackbox response message must contain an ERPM Person ID or Email address.');
            }
            
            // Pull all matching Contacts, by ERPM Person ID and/or Email
            List<Contact> matchingContacts = [
                select Id, Email, Core_eRPM_Person_Id__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c,
                Core_Enterprise_Id__c
                from Contact where Core_eRPM_Person_Id__c in :erpmPersonIds or Email in :erpmEmails];
            System.debug('##### matchingContacts: ' + matchingContacts);
            
            Set<Id> matchingContactIds = new Set<Id>();
            Map<String,Contact> matchingContactERPMIdMap = new Map<String,Contact>();
            Map<String,Contact> matchingContactEmailMap = new Map<String,Contact>();
            
            for (Contact c : matchingContacts) {
                matchingContactIds.add(c.Id);
                matchingContactERPMIdMap.put(c.Core_eRPM_Person_Id__c, c);
                matchingContactEmailMap.put(c.Email, c);
                tags += addTag(c.Id);
            }
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD UPDATES
            
            List<Contact> contactsToUpdate = new List<Contact>();
            
            // Loop through the Blackbox responses we're processing
            for (Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse : bbResponses) {
                
                System.debug('##### Operating on this blackbox response message to check for contact record updates: ' + bbResponse);
                
                if (matchingContactERPMIdMap.containsKey(bbResponse.PersonID) || matchingContactEmailMap.containsKey(bbResponse.EmailID)) {
                    
                    // Get Contact that corresponds to this Blackbox response, by Person ID if possible, otherwise Email
                    Contact c = matchingContactERPMIdMap.containsKey(bbResponse.PersonId) ?
                        matchingContactERPMIdMap.get(bbResponse.PersonId) :
                    matchingContactEmailMap.get(bbResponse.EmailID);
                    
                    // Depending on success/failure, update status/message accordingly
                    if (bbResponse.Status == 'Success') {
                        c.Core_ERPM_Integration_Status__c = 'Successful';
                        c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.successfulInboundMessage(newList[0].Id);
                        c.Core_Enterprise_Id__c = bbResponse.EnterpriseID;
                        c.Core_Login_Id__c = bbResponse.LoginID;
                    }
                    else if (bbResponse.Status == 'Failure') {
                        c.Core_ERPM_Integration_Status__c = 'Failed';
                        c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.failedInboundMessage(
                            newList[0].Id, bbResponse.ErrorCode, bbResponse.ErrorText, bbResponse.ErrorDetails);
                    }
                    contactsToUpdate.add(c);
                    System.debug('##### Attempting to update this contact: ' + c);
                }
            }
            // Perform DML UPDATE for Contacts
            System.debug('##### contactsToUpdate: ' + contactsToUpdate);
            if (contactsToUpdate.size() > 0)
                update contactsToUpdate;
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                            'Successfully processed ERPM Blackbox message',
                                                            'Success!', newList[0].Id, LOG_ENTRY_OBJECT, tags);
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);
            processingStatus = 'Failed';
            processingMessage += ', ' + ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Blackbox message', '', newList[0].Id, LOG_ENTRY_OBJECT, tags, ex);
        }
        
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
        
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = [
            select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c
            from Core_Integration_Inbound_Message__c where Id in :msgIds];
        
        for (Core_Integration_Inbound_Message__c msg : messagesToUpdate) {
            msg.Core_Processing_Status__c = processingStatus;
            msg.Core_Exception_Message__c = processingMessage;
            msg.Core_Log_Entry__c = logEntryId;
            msg.Core_Tags__c = tags;
            Core_IntegrationUtility.ERPM_Blackbox_Response resp = ibMsgRespErrorMap.get(msg.Id);
            if(resp != null && String.isNotBlank(resp.ErrorCode)){
                msg.Core_Error_Code__c = resp.ErrorCode;
                String codeWithErrorDesc = resp.ErrorText + ' Details : '+resp.ErrorDetails;
                codeWithErrorDesc = ( String.isNotBlank(codeWithErrorDesc) &&  codeWithErrorDesc.length() > 254 ) ? codeWithErrorDesc.substring(0, 254) : codeWithErrorDesc;
                msg.Core_Error_Description__c = codeWithErrorDesc;
            }
        }
        
        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        update messagesToUpdate;
    }
    
    
    //Concatenating 4 Payload fields to Parse
    private static String getFullPayload(Core_Integration_Inbound_Message__c msg){
        String fullPayload= '';           
        
        if(msg.Core_Payload__c!= null){
            fullPayload = fullPayload+msg.Core_Payload__c;
        }
        if(msg.Core_Payload1__c!= null){
            fullPayload = fullPayload+msg.Core_Payload1__c;
        }
        System.debug('Concatenate1'+fullPayload);
        if(msg.Core_Payload2__c!= null){
            fullPayload = fullPayload+msg.Core_Payload2__c;
        }
        System.debug('Concatenate2'+fullPayload);
        if(msg.Core_Payload3__c!= null){
            fullPayload = fullPayload+msg.Core_Payload3__c;
        }
        System.debug('Concatenate3'+fullPayload);       
        return fullPayload;        
    }
}