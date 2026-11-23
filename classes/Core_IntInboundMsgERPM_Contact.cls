/******************************************************************************************************************************************
Class Name  : Core_IntInboundMsgERPM_Contact
Version     : 1.0
Created Date: 03 NOV 2016
Function    : Business logic for processing inbound ERPM messages

Modification Log :
* Developer                 Date            Description
* -------------------------------------------------------------------------------------------
* Dave Hood                 11/03/2016      Original version
* Pooja Khanna              5/26/2016       Removed Box B message creation on successful ERPM response, moved it to process builder
* Team: PopcornApps         6/6/2016        New class created from Core_IntegrationInboundMsgERPM with a single method processContactMessages
Moved addtag, insertMissingEngagementsEntitlements to Utility method Removed unused code and
unused variables Code changes to set ERPM as update reason to newly inserting entitltment and
setting the AGS status to Pending to retrigger AGS
* Team: PopcornApps         6/15/2016       Salutation changes
* Aran Wongsaprome          7/26/2017       Map ERPM PersonTitle to contact salutation
* Aran Wongsaprome          8/18/2017       US77274 Fix exceptions from tag size overflow
* Aran Wongsaprome          8/22/2017       US71628 Related list of messages under contact
* Aran Wongsaprome          8/29/2017       DE30458 Fix do not contact flag
* Rajesh Kumar              6/3/2018         Added logic for Soft and Hard Deletion based on eRPM Message,
US95568-Contacts : As an Ops I want contact record to be tokenized when contact is removed ( hard delete) from eRPM.
US95670-Contact : As an ops I want to remove login id, enterprise id of a contact if it is soft deleted from eRPM
* DRACO                    9/04/2021        commented condition engagement !=null - To inactivate Contact Entitlements for deleted contacts
                                            as part of A&E2.0 
*****************************************************************************************************************************************/

public without sharing class Core_IntInboundMsgERPM_Contact {
    public static final String RDC_ENGAGEMENT_CODE = 'IRDC_Priv'; // Moved to Custom Label
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE    = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_OBJECT   = 'Core_Integration_Inbound_Message__c';
    public static final String UPDATE_REASON_ERPM = 'ERPM';
    public static boolean StopERPMSalesCloudIPAInteg = (!Test.isRunningtest() ? Boolean.valueOf(Label.StopERPMSalesCloudIPAInteg):false);

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
        List<String> IPAEnggsForAddress = new List<String>();
        Set<String>erpmAcctEnggCodes = new Set<String>();
        List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs = new List<Core_IntegrationUtility.ERPM_Engagement>();
        List<Core_IntegrationUtility.ERPM_Person_Account> erpmAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Set<String> erpmEmails = new Set<String>();
        //Map<String,String> erpmEmailToPersonIdMap = new Map<String,String>();
        Set<String> erpmAccountCIMIds = new Set<String>();
        Map<String, String> erpmSFIdCimIdMap = new Map<String, String>();
        Set<String> erpmAccountSFIds = new Set<String>();
        Set<String> erpmAccountNumbers = new Set<String>();
        Map<String,List<String> >cimDedupMap = new Map<String,List<String> >();

        // Build up a list of tags that we'll use for log entries, inbound messages, etc.
        String tags = '';
        string eRPMChangeAgentId = '';
        //Get the list of PRM engagements from Label
        List<String> PRMEngagements = string.isNotBlank(Label.PRM_IPA_Engagements) ? Label.PRM_IPA_Engagements.split(',') : null;
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET RELEVANT ID VALUES

        // Following line temporarily removed to prevent bulk processing of messages
        //for (Core_Integration_Inbound_Message__c msg : newList) {
        Core_Integration_Inbound_Message__c msg = newList[0]; // Temporarily added to only process first message if multiple are inserted
        if (newList.size() > 0) { // Temporarily added
            // Only process messages inserted/updated as "Pending"
            string fullPayload = Core_IntegrationUtility.getFullPayload(msg);//To avoid calling method twice a local string is created
            if ((msg.Core_Processing_Status__c == 'Pending') && (fullPayload!= null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);

                    // Parse the payload into an object, then add it to our collection of erpmPersons
                    Core_IntegrationUtility.ERPM_Person person =
                        Core_IntegrationInboundMessageParsing.parsePerson(fullPayload);
                    System.debug('##### ERPM Person message parsed into an object: ' + person);
                    System.debug('##### ERPM Person message parsed into an object: ' + person.lastLoginDate);
                    erpmPersons.add(person);
                    eRPMChangeAgentId = person.changeAgentId;
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
                        tags += Core_IntegrationUtility.addTag(person.erpmPersonId);
                    }
                    if (!String.isBlank(person.enterpriseId))
                        tags += Core_IntegrationUtility.addTag(person.enterpriseId);
                    if (!String.isBlank(person.loginId))
                        tags += Core_IntegrationUtility.addTag(person.loginId);
                    if (!String.isBlank(person.email)) {
                        erpmEmails.add(person.email);
                        tags += Core_IntegrationUtility.addTag(person.email);
                    }

                    publishTimestamp = person.publishTimestamp;

                    for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                        for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements) {
                            erpmEnggs.add(engg);
                            erpmEnggCodes.add(engg.engagementCode);
                            IPAEnggsForAddress.add(engg.engagementCode);
                        }
                        for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                            if(!ePAR.inactiveIndicator && PRMEngagements.Contains(ePAR.engagementCode))
                                erpmAcctEnggCodes.add(ePAR.engagementCode);
                        }
                        tags += Core_IntegrationUtility.addTag(acct.cimId) + Core_IntegrationUtility.addTag(acct.erpmAccountNumber);
                    }

                    system.debug('erpmAcctEnggCodes '+erpmAcctEnggCodes);

                    for (Core_IntegrationUtility.ERPM_Engagement engg : person.personEngagements) {
                        erpmEnggs.add(engg);
                        erpmEnggCodes.add(engg.engagementCode);
                        IPAEnggsForAddress.add(engg.engagementCode);
                    }

                    if (person.personAccounts.size() > 0) {

                        /*** Commented the below lines and added FOR loop as part of US541510 -
*** To Allow creation of a mutiple contacts (for each account) when ERPM Person is associated
*** with multiple Accounts
*********    */
                        //if (person.personAccounts[0].cimId != '')
                        //erpmAccountCIMIds.add(person.personAccounts[0].cimId);
                        system.debug('Account engagements');
                        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                            //if(!String.isBlank(acct.acctSalesCloudID) && !String.isBlank(acct.cimId)) {
                            //  erpmAccountSFIds.add(acct.acctSalesCloudID);
                            //}
                            if(!String.isBlank(acct.acctSalesCloudID)) {
                                erpmAccountSFIds.add(acct.acctSalesCloudID);
                            }
                            else if(!String.isBlank(acct.cimId)) {
                                erpmAccountCIMIds.add(acct.cimId);
                            }
                            erpmAccountNumbers.add(acct.erpmAccountNumber);
                        }
                        Map<String,Set<String> > params = new Map<String,Set<String> >();

                        //Sending email if contact has multiple SF id in eRPM XML
                        if(erpmAccountSFIds.size() > 1) {
                            person.ignoreMessage = true;
                            person.ignoreReason = 'Contact is part of multiple accounts in eRPM';
                            //send email
                            params.put('MatchSfIds', erpmAccountSFIds);
                            Core_IntegrationOptimization.SendEmail(person.email,'Multiple_Accounts');
                        }

                        // if(cimDedupMap.Size()>1) {
                        //  system.debug('cimdedupMap >1');

                        //  if(itpCimIds.Size() == 1) {
                        //      erpmAccountCIMIds.clear();
                        //      erpmAccountCIMIds.addAll(itpCimIds);
                        //  }
                        //  else if(itpCimIds.Size() > 1) {
                        //      person.ignoreMessage = true;
                        //      person.ignoreReason = 'Duplicate CIMIds with ITP dedup group code';
                        //      //send email
                        //      params.put('MatchCimIds', itpCimIds);
                        //      Core_IntegrationOptimization.SendEmail(person.email, params,'Multiple_ITP_Accounts');
                        //  }
                        // }
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
            System.debug(' erpmPersonIds '+erpmPersonIds);
            System.debug(' erpmEmails '+erpmEmails);

            // We need at least a Person ID or Email. If we don't have one, the next SOQL statement will throw an
            // exception only when run in an actual org, not in our test classes. So let's throw one explicitly instead.
            if ((erpmPersonIds.size() == 0) && (erpmEmails.size() == 0)) {
                throw new CustomException('ERPM Person message must contain a Person ID or Email address.');
            }

            // Contacts
            List<Contact> matchingContacts = [
                select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                Title, FirstName, LastName, Name, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c,Core_Marketing_Do_Not_Contact_Dtm__c,
                Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, /*Core_AGS_Integration_Status__c,*/ Core_Deactivated__c,
                Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_IPA_Email_Verification_Date__c,
                Core_IPA_Intel_Last_Login_Date__c, Core_IPA_PartnerRole__c,Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact_Dtm__c, Core_Do_Not_Contact__c
                from Contact
                where Core_eRPM_Person_Id__c in :erpmPersonIds
                limit 1
            ];            // Limit needs to be removed for true bulkification

            if (matchingContacts.size() == 0) {
                matchingContacts = [
                    select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                    Title, FirstName, LastName, Name, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                    Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                    Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c,Core_Marketing_Do_Not_Contact_Dtm__c,
                    Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, /*Core_AGS_Integration_Status__c,*/ Core_Deactivated__c,
                    Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_IPA_Email_Verification_Date__c,
                    Core_IPA_Intel_Last_Login_Date__c, Core_IPA_PartnerRole__c, Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact_Dtm__c, Core_Do_Not_Contact__c
                    from Contact
                    where Email in :erpmEmails
                    limit 1
                ];            // Limit needs to be removed for true bulkification
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

            //Gireesh:US912533:To process Contact info regradless of account match
            Map<Id, Contact> updateContactSet1Map = new Map<Id, Contact>();
            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                if(matchingContactERPMIdMap.containsKey(person.erpmPersonId) || matchingContactEmailMap.containsKey(person.email)){
                    Contact updateContact;
                    if(matchingContactERPMIdMap.containsKey(person.erpmPersonId)){
                        updateContact = matchingContactERPMIdMap.get(person.erpmPersonId);
                    }
                    else if(matchingContactEmailMap.containsKey(person.email)){
                        updateContact = matchingContactEmailMap.get(person.email);
                    }
                    updateContact.Core_eRPM_Person_Id__c = !String.isEmpty(person.erpmPersonId) ? person.erpmPersonId : null;
                    updateContact.Core_Login_Id__c  = !String.isEmpty(person.loginId) ? person.loginId : null;
                    updateContact.Core_Enterprise_Id__c = !String.isEmpty(person.enterpriseId) ?  person.enterpriseId : null;                
                    updateContactSet1Map.put(updateContact.Id, updateContact);
                }
            }
            /*if(updateContactList!=null && updateContactList.size()>0){
                update updateContactList;
            }*/
            //Gireesh:US912533:End


            // Associate the contact to the inbound message
            List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
            for (Contact c : matchingContacts)
                ContactMsg.add(new Contact_Message__c(Contact__c = c.id, Inbound_Message__c = msg.id));
            insert ContactMsg;

            // Contact Entitlements
            List<Core_Contact_Entitlement__c>         matchingContactEntitlementsEnggs     = new List<Core_Contact_Entitlement__c>();
            List<Core_Contact_Entitlement__c>         matchingContactEntitlementsAll       = new List<Core_Contact_Entitlement__c>();
            Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap    =  new Map<Id,List<Core_Contact_Entitlement__c> >();
            Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap     =  new Map<Id,List<Core_Contact_Entitlement__c> >();
            List<Core_Contact_Entitlement__c> ceList = null;
            if (matchingContactIds.size() > 0) {
                // First pull the Contact Entitlements where AGS role is blank, which represent the ERPM Engagements themselves
                for(Core_Contact_Entitlement__c ce : [SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Engagement_Tier__c, Core_Selected__c, Core_From_Source__c,
                                                      Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, Core_ERPM_Account_Data__c,
                                                      Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Entitlement_Id__r.Name, Core_Type__c, Core_Update_Reason__c
                                                      FROM Core_Contact_Entitlement__c
                                                      WHERE Core_Contact_Id__c in :matchingContactIds])
                                                     //and Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c != null]) //DRACO-commented to inactivate Contact Entitlements for A&E 2.0 for deleted contacts
                {
                    //++++++++++++++    Step 1 : Add to list ++++++++++++++
                    // 1.1 Next pull all Contact Entitlements *including ones with AGS roles*
                    matchingContactEntitlementsAll.add(ce);
                    // 1.2 First pull the Contact Entitlements where AGS role is blank, which represent the ERPM Engagements themselves
                    if(''.equalsIgnoreCase(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c) || null == ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c)
                        matchingContactEntitlementsEnggs.add(ce);


                    //++++++++++++++    Step 2 : Add to Map ++++++++++++++
                    //++++++2.1
                    ceList = null;
                    if (matchingContactEntitlementAllMap.containsKey(ce.Core_Contact_Id__c))
                        ceList = matchingContactEntitlementAllMap.get(ce.Core_Contact_Id__c);
                    else
                        ceList = new List<Core_Contact_Entitlement__c>();
                    ceList.add(ce);
                    matchingContactEntitlementAllMap.put(ce.Core_Contact_Id__c, ceList);

                    //+++++2.2
                    if(''.equalsIgnoreCase(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c) || null == ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c) {
                        ceList = null;
                        if (matchingContactEntitlementEnggMap.containsKey(ce.Core_Contact_Id__c))
                            ceList = matchingContactEntitlementEnggMap.get(ce.Core_Contact_Id__c);
                        else
                            ceList = new List<Core_Contact_Entitlement__c>();
                        ceList.add(ce);

                        matchingContactEntitlementEnggMap.put(ce.Core_Contact_Id__c, ceList);
                    }
                }
                System.debug(' #111 matchingContactEntitlementEnggMap-----  '+matchingContactEntitlementEnggMap);
                System.debug(' #111  matchingContactEntitlementAllMap-----  '+matchingContactEntitlementAllMap);

            }

            // Accounts
            //List<Account> matchingAccounts = new List<Account>();
            Map<String,Account> matchingAccountMap = new Map<String,Account>();
            Set<String> matchingAccountSFId = new Set<String>();
            Boolean enttlAssignFlag = false;
            String salesforceId = '';
            if(erpmAccountSFIds.size() == 1) {
                salesforceId = new List<String>(erpmAccountSFIds)[0];
                system.debug('salesforceId '+salesforceId);
            }
            //Call optimization only if there is no account alignment
            else if (erpmAccountSFIds.size() == 0 && erpmAccountCIMIds.size() > 0) {
                salesforceId = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(erpmAccountCIMIds,erpmAccountNumbers);
                system.debug('salesforceId '+salesforceId);
            }
            if(String.isNotBlank(salesforceId)) {
                Account a =[SELECT Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c, Core_CNDA_Number__c
                            FROM Account WHERE Id =: salesforceId];
                if (!matchingAccountMap.containsKey(a.Core_CIM_ID__c)) {
                    matchingAccountMap.put(a.Core_CIM_ID__c, a);
                    matchingAccountSFId.add(a.Id);
                    tags += Core_IntegrationUtility.addTag(a.Id);
                }
            }

            // Collections for Contact & Account INSERTs and UPDATEs
            List<Contact> contactsToInsert = new List<Contact>();
            List<Contact> contactsToUpdate = new List<Contact>();
            //  Set<Id> contactIdsToUpdateAgain = new Set<Id>(); // For the 2nd update we need to perform for ERPM deletes & soft deletes
            List<Account> accountsToInsert = new List<Account>();
            Set<Id> ContactPartnerDisable=new Set<Id>(); // To disable the partner portal,if the contact is partner user//
            List<Id> ContactPartnerDisableList=new List<Id>();
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD INSERTS & UPDATES (AND POTENTIALLY ACCOUNTS)

            // ----------- #REGION :: eRPM Code Changes :: START ------------- //
            List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
            List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelations = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
            Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap = new Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> >();
            system.debug(':::::::: PRMEngagements ::::::: ' + PRMEngagements);
            system.debug(':::::::: Label.PRM_IPA_Engagements ::::::: ' + Label.PRM_IPA_Engagements);
            Id contactId = null;
            Id sfAcctId = null;
            //boolean IsContactEntitlementUpdated = false;
            // ----------- #REGION :: eRPM Code Changes :: END   ------------- //

            //PMD Issue Fix starts
            Map<Id,Account> accountPartnerSpecsMap = new Map<Id,Account>();
            Set<Id> allAccountIds = new Set<Id>();
            Set<String> allPartnerSpecs = new Set<String>();
            Map<String,String> eRPMSFMappingsByPartnerSpecs = new Map<String,String>();
            List<ERPM_SF_MAPPING_SETTING__mdt> eRPMSFMappingsByEnggCodes = [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c
                                                                            FROM ERPM_SF_MAPPING_SETTING__mdt
                                                                            WHERE Mappting_Type__c =: Label.PRM_Partner_Role
                                                                            AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes];

            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                if (!person.ignoreMessage) {
                    if (matchingContactERPMIdMap.containsKey(person.erpmPersonId) || matchingContactEmailMap.containsKey(person.email)) {
                        // Get Contact by ERPM Person ID if possible, otherwise by Email
                        allAccountIds.add(matchingContactERPMIdMap.containsKey(person.erpmPersonId) ? matchingContactERPMIdMap.get(person.erpmPersonId).AccountId :  matchingContactEmailMap.get(person.email).AccountId);
                    }else if (person.personAccounts.size() > 0) {
                        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                            if (matchingAccountMap.containsKey(acct.cimId)) {
                                allAccountIds.add(matchingAccountMap.get(acct.cimId).Id);
                            }
                        }

                    }
                }
            }
            if(allAccountIds.size() > 0) {
                accountPartnerSpecsMap = new Map<Id,Account>([SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id IN: allAccountIds]);
                for(Id AccountId : accountPartnerSpecsMap.keySet()) {
                    if(!String.isEmpty(accountPartnerSpecsMap.get(AccountId).Core_IPA_Partner_Speciality__c)) {
                        allPartnerSpecs.addAll(accountPartnerSpecsMap.get(AccountId).Core_IPA_Partner_Speciality__c.split(';'));
                    }
                }
                if(allPartnerSpecs.size() > 0) {
                    for(ERPM_SF_MAPPING_SETTING__mdt mdt : [SELECT eRPM_KeyValue__c,SF_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt
                                                            WHERE Mappting_Type__c =: Label.PRM_IPA_Partner_Specialty AND
                                                            SF_KeyValue__c IN: allPartnerSpecs]) {
                                                                eRPMSFMappingsByPartnerSpecs.put(mdt.SF_KeyValue__c, mdt.eRPM_KeyValue__c);
                                                            }
                }
            }


            //PMD Issue Fix###
            //Loop through collection of erpmPersons...
            for (Core_IntegrationUtility.ERPM_Person person : erpmPersons) {
                system.debug('person.ignoreMessage: '+person.ignoreMessage);

                // Get Contact by ERPM Person ID if possible, otherwise by Email
                Contact c = matchingContactERPMIdMap.containsKey(person.erpmPersonId) ?
                    matchingContactERPMIdMap.get(person.erpmPersonId) :  matchingContactEmailMap.get(person.email);

                if(c != null && matchingAccountSFId.size() >0 && !matchingAccountSFId.contains(c.AccountId)) {
                    person.ignoreMessage = true;
                    person.ignoreReason = 'Contact is part of different account in Salesforce, hence ignoring message';
                    sfAcctId=c.AccountId;
                    contactId=c.Id;
                    //send email
                    //params.put('MatchSfIds', erpmAccountSFIds);
                    //TO DO send email
                    Core_IntegrationOptimization.SendEmail(person.email,'Multiple_Accounts');
                    system.debug('******** Contact message is ignored. ********');
                    if(erpmAcctEnggCodes.Contains(system.label.ERPM_EngagementCode)) {
                        enttlAssignFlag= true;
                        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                            system.debug('******** Assigning entitlements ******** ' + person.email);
                            system.debug('person.personAccounts-->' + person.personAccounts);
                            erpmAccounts.add(acct);
                            System.debug('erpmAccounts-->'+erpmAccounts);
                        }
                    }
                }

                if (!person.ignoreMessage) {

                    System.debug('##### Operating on this person message to check for contact inserts & updates: ' + person);

                    // For each, check Contact records from collections to see if a Contact needs to be INSERTed or UPDATEed,
                    // and add to DML collections accordingly. First check by ERPM Person ID, then by Email.
                    if (matchingContactERPMIdMap.containsKey(person.erpmPersonId) || matchingContactEmailMap.containsKey(person.email)) {

                        System.debug('##### Found the contact, so this may be an update');



                        // If ERPM Person Id isn't NULL and doesn't match, it means we found the Contact on Email address.
                        // Per US49540, we need to ignore such messages.
                        if ((c.Core_eRPM_Person_Id__c != null) && (c.Core_eRPM_Person_Id__c != person.erpmPersonId)) {
                            System.debug('##### Contact was found based on email address, but ERPM Person Id ' + 'doesn\'t match the message, so ignoring this message');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'Contact was found based on email address, but ERPM Person Id doesn\'t match the message';
                        }
                        // US64227: ignore messages published *before* the last timestamp on the Contact record
                        else if (person.publishTimestamp < c.Core_ERPM_Integration_Publish_Timestamp__c) {
                            System.debug('##### Person message publish-timestamp (' + person.publishTimestamp + ') is before ' + 'last timestamp on the Contact record (' + c.Core_ERPM_Integration_Publish_Timestamp__c + ')');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'Person message was published *before* the last one successfully processed';
                        }
                        else {
                            // Always set the Publish Timestamp on the Contact record to what's in the message
                            c.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
                            System.debug('person.isDeleteIndicator====>'+person.isDeleteIndicator);
                            System.debug('person.inactIndicator=======>'+person.inactIndicator);
                            System.debug('personAccounts.size=========>'+person.personAccounts.size());
                            System.debug('c.Core_Login_Status__c======>'+c.Core_Login_Status__c);
                            System.debug('person.enterpriseId======>'+person.enterpriseId);
                            System.debug('person.erpmPersonId======>'+person.erpmPersonId);
                            System.debug('c.Core_ERPM_Person_Id__c======>'+c.Core_ERPM_Person_Id__c);
                            System.debug('person.email======>'+person.email);
                            System.debug('c.Email======>'+c.Email);
                            System.debug('c.Core_Enterprise_Id__c======>'+c.Core_Enterprise_Id__c);
                            System.debug('c.Core_Login_Id__c======>'+c.Core_Login_Id__c);
                            System.debug('person.changeAgentId======>'+person.changeAgentId);
                            //Added logic for Hard delete -US95568 Contacts : As an Ops I want contact record to be tokenized when contact is removed ( hard delete) from eRPM---Rajesh //
                            if(person.isDeleteIndicator =='Y' && person.inactIndicator =='Y' ) {
                                System.debug('##### Hard deletion, so blanking out some fields');
                                c.Core_Tokenized__c = true;
                                //c.Core_Login_Id__c = null; //Gireesh:US912533: Updating this attribute above
                                c.Core_Login_Status__c ='Disabled';
                                contactsToUpdate.add(c);
                                ContactPartnerDisable.add(c.Id);
                            }
                            // Added logic for soft delete-US95670-Contact : As an ops I want to remove login id, enterprise id of a contact if it is soft deleted from eRPM--Rajesh//
                            else if(person.changeAgentId != 'SalesCloud' && ((person.isDeleteIndicator =='Y' && person.inactIndicator =='N') ||
                                    (!String.isEmpty(c.Core_Login_Status__c)&& (person.enterpriseId == '') &&(person.erpmPersonId == c.Core_ERPM_Person_Id__c) &&(person.email == c.Email) &&(!String.isBlank(c.Core_Enterprise_Id__c) || !String.isBlank(c.Core_Login_Id__c))))) {
                                        System.debug('##### Soft deletion, so blanking out some fields');
                                        //c.Core_Login_Id__c = null; //Gireesh:US912533: Updating this attribute above
                                        c.Core_Tokenized__c =false;
                                        //c.Core_Login_Status__c ='Deleted';//Gireesh:DE114250:Updating this attribute below
                                        //c.Core_Enterprise_Id__c = null; //Gireesh:US912533: Updating this attribute above
                                        contactsToUpdate.add(c);
                                        ContactPartnerDisable.add(c.Id);
                                        //person.isDeleteIndicator = 'Y';         // Set this so we can easily use it to execute Contact Entitlement removal below//Gireesh:added this logic down
                                    }
                            // Commented as the below existing  logic are added to above hard and soft delete(US95568 &US95670) --Rajesh  //
                            /*
// Check for "Deleted"
if (person.isDeleteIndicator == 'Y') {
System.debug('##### ERPM deletion, so blanking out some fields');
c.Core_Login_Status__c = 'Deleted';
//c.Core_Tokenized__c = true; // Added for US61328
contactsToUpdate.add(c);

contactIdsToUpdateAgain.add(c.Id);
}
else if(person.inactIndicator =='Y'){
System.debug('##### ERPM disabled, so blanking out some fields');
c.Core_Login_Status__c ='Disabled';
contactsToUpdate.add(c);
}
// Check for "Soft Delete" -- keeping this separate in case we need to handle it differently later
else if ((person.enterpriseId == '') &&
(person.erpmPersonId == c.Core_ERPM_Person_Id__c) &&
(person.email == c.Email) &&
(!String.isBlank(c.Core_Enterprise_Id__c) || !String.isBlank(c.Core_Login_Id__c))){
System.debug('##### ERPM soft delete, so blanking out some fields');
c.Core_Login_Status__c = 'Deleted';
contactsToUpdate.add(c);
contactIdsToUpdateAgain.add(c.Id);
person.isDeleteIndicator = 'Y'; // Set this so we can easily use it to execute Contact Entitlement removal below
}
*/
                            // Otherwise it's just a normal contact update
                            else {
                                // Prepare to update the fields needed
                                System.debug('##### Not ERPM deleted, disabled, or soft deleted, so updating the record');
                                // Yet another safeguard added here to prevent updating a non-NULL ERPM Person Id where it doesn't match the message
                                if ((c.Core_eRPM_Person_Id__c == null) || (c.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
                                    setContactFieldsFromPerson(c, person,IPAEnggsForAddress);
                                    if(!StopERPMSalesCloudIPAInteg)
                                    {
                                        //Add partner role based on account engagements and patner speciality of account
                                        if(erpmAcctEnggCodes.size() > 1 || String.isBlank(c.Core_IPA_PartnerRole__c)) {
                                            List<String> acctBenefits = new List<String>();
                                            system.debug('beforePspl');
                                            //PMD Issue Fix
                                            //String partnerSpeciality = [SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id =: c.AccountId].Core_IPA_Partner_Speciality__c;
                                            String partnerSpeciality = accountPartnerSpecsMap.containsKey(c.AccountId) ? accountPartnerSpecsMap.get(c.AccountId).Core_IPA_Partner_Speciality__c : null;
                                            if(!String.isEmpty(partnerSpeciality)) {
                                                List<String> partnerSplList = partnerSpeciality.split(';');

                                                for(String partnerSpl : partnerSplList ) {
                                                    if(eRPMSFMappingsByPartnerSpecs.containsKey(partnerSpl)) {
                                                        acctBenefits.add(eRPMSFMappingsByPartnerSpecs.get(partnerSpl));
                                                    }
                                                }
                                                /*
for(ERPM_SF_MAPPING_SETTING__mdt mdt : [SELECT eRPM_KeyValue__c
FROM ERPM_SF_MAPPING_SETTING__mdt
WHERE Mappting_Type__c =: Label.PRM_IPA_Partner_Specialty
AND SF_KeyValue__c IN: partnerSplList]){
acctBenefits.add(mdt.eRPM_KeyValue__c);
}
*/
                                                system.debug('acctBenefits-update'+acctBenefits);
                                            }
                                            //No Partner Role setup through integration as part of Multi-select to single select change
                                            List<String> partnerRoles = new List<String>();
                                            map<string, List<string> > customSettingmap = new map<string, List<string> >();
                                            /*
for( ERPM_SF_MAPPING_SETTING__mdt customSettings : [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c
FROM ERPM_SF_MAPPING_SETTING__mdt
WHERE Mappting_Type__c =: Label.PRM_Partner_Role
AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes]){
*/
                                            for( ERPM_SF_MAPPING_SETTING__mdt customSettings : eRPMSFMappingsByEnggCodes) {
                                                system.debug('customSettings.SF_KeyValue__c'+ customSettings.SF_KeyValue__c);
                                                if ((!customSettingmap.containsKey(customSettings.eRPM_EngagementCodes__c)) ) {
                                                    if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                                                        customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                                                    }
                                                    else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                                                            || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode) {
                                                                customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                                                            }
                                                }
                                                else {
                                                    if(!customSettingmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                                                        if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                                                            customSettingmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                                                        }
                                                    }
                                                }
                                            }
                                            if(customSettingmap.values().size() > 0) {
                                                for(List<String> roles : customSettingmap.values()) {
                                                    partnerRoles.addAll(roles);
                                                }

                                                if(String.isNotBlank(c.Core_IPA_PartnerRole__c))
                                                    partnerRoles.addAll(c.Core_IPA_PartnerRole__c.split(';'));
                                                //Commented as part of US708851
                                                /*
if(partnerRoles.size() >0){
c.Core_IPA_PartnerRole__c = Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(partnerRoles)));
system.Debug('c.Core_IPA_PartnerRole__c' +c.Core_IPA_PartnerRole__c);
} */
                                            }
                                        }
                                    }

                                    contactsToUpdate.add(c);

                                    // ----------- #REGION :: eRPM Code Changes :: START   ------------- //
                                    system.debug('******* person.eRPM_Subscriptions ******* ' + person.eRPM_Subscriptions);
                                    if(person.eRPM_Subscriptions != null && person.eRPM_Subscriptions.size() > 0)
                                    {
                                        for(Core_IntegrationUtility.eRPM_Subscription subs: person.eRPM_Subscriptions) {
                                            if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(subs.eRPM_EngagementCode)) {
                                                eRPM_Subscriptions.addall(person.eRPM_Subscriptions);
                                            }
                                        }
                                    }
                                    system.debug('******** eRPM_Subscriptions ********' + eRPM_Subscriptions);

                                    //Add/Update the account person subscription for an existing user
                                    if(!StopERPMSalesCloudIPAInteg)
                                    {
                                        Set<String> emailCimIds = new Set<String>();
                                        Map<String,Set<String> > params = new Map<String,Set<String> >();
                                        if (person.personAccounts.size() > 0) {
                                            for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                                                if (matchingAccountMap.containsKey(acct.cimId)) {
                                                    system.debug('******** matchingAccountMap.containsKey the CIM Id ********' + acct.cimId);
                                                    List<Core_IntegrationUtility.ERPM_Person_Account_Relation> relationships = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
                                                    if(acct.personAccountRelations != null && acct.personAccountRelations.size() > 0) {
                                                        //Add the account contact relationships to a local variable only for the PRM engagements.
                                                        //TODO::REVISIT :: PRM engagements conditions should be lifted, make generic.
                                                        system.debug('******** PRMEngagements *******' + PRMEngagements);
                                                        system.debug('******** acct.personAccountRelations *******' + acct.personAccountRelations);
                                                        for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                                                            if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(ePAR.engagementCode)) {
                                                                relationships.add(ePAR);
                                                            }
                                                        }

                                                        system.debug('******** eRPM Relationships ********' + relationships);
                                                        //Add to account id relationships map only when erpm person account relationship contains PRM enagements (CSPx2, ITP, ISA)
                                                        if(relationships.size() >0) {
                                                            if(!acctIdRelationshipsMap.ContainsKey(matchingAccountMap.get(acct.cimId).Id))
                                                                acctIdRelationshipsMap.put(matchingAccountMap.get(acct.cimId).Id, relationships);
                                                            else
                                                                acctIdRelationshipsMap.get(matchingAccountMap.get(acct.cimId).Id).addAll(relationships);
                                                        }
                                                        //eRPM_PersonAccountRelations.addall(acct.personAccountRelations);
                                                    }
                                                    system.debug('******** acctIdRelationshipsMap ********' + acctIdRelationshipsMap);
                                                    system.debug('person.personAccounts-->' + person.personAccounts);
                                                    /*Team Ruby changes - start*/
                                                    erpmAccounts.add(acct);
                                                    System.debug('erpmAccounts-->'+erpmAccounts);
                                                    /*Team Ruby changes - end*/
                                                }
                                                //else {
                                                //  emailCimIds.add(acct.cimId);

                                                //}
                                            }
                                        }
                                    }
                                    //if(emailCimIds.Size() > 0) {
                                    //  params.put('ConatctName', new Set<String> {c.Name});
                                    //  params.put('CurrAcctName', new Set<String> {c.Account.Name});
                                    //  params.put('MatchCimIds', new Set<String> {c.Account.Core_CIM_ID__c});
                                    //  params.put('DestCimIds', matchingAccountMap.KeySet());
                                    //  Core_IntegrationOptimization.SendEmail(person.email, params, 'Contact_Diff_Account');
                                    //}

                                    // ----------- #REGION :: eRPM Code Changes :: END   ------------- //

                                }
                            }
                        }
                    }
                    else {
                        System.debug('##### Did not find the contact, so this may be an insert');
                        // ----------- #REGION :: eRPM Code Changes :: START   ------------- //
                        system.debug('******** person.eRPM_Subscriptions ********' + person.eRPM_Subscriptions);
                        if(person.eRPM_Subscriptions != null && person.eRPM_Subscriptions.size() > 0)
                        {
                            for(Core_IntegrationUtility.eRPM_Subscription subs: person.eRPM_Subscriptions) {
                                if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(subs.eRPM_EngagementCode)) {
                                    eRPM_Subscriptions.addall(person.eRPM_Subscriptions);
                                }
                            }
                        }
                        system.debug('******** eRPM_Subscriptions ********' + eRPM_Subscriptions);
                        System.debug('person.personAccounts-->'+person.personAccounts);
                        if (person.personAccounts.size() > 0) {
                            System.debug('##### Checking the account in the message');
                            System.debug('person.personAccounts-->'+person.personAccounts);
                            for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                                if (matchingAccountMap.containsKey(acct.cimId)) {
                                    System.debug('##### Found the account based on CIM ID: ' + acct.cimId);
                                    // Prepare to insert a new contact
                                    Id sfAccountId = matchingAccountMap.get(acct.cimId).Id;
                                    Contact newc = new Contact(AccountId = sfAccountId);
                                    setContactFieldsFromPerson(newc, person,IPAEnggsForAddress);
                                    //PMD Issue Fix
                                    //List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Id =: sfAccountId];
                                    if(!StopERPMSalesCloudIPAInteg)
                                    {
                                        //Add partner role based on account engagements and patner speciality of account
                                        List<String> acctBenefits = new List<String>();

                                        //PMD Issue Fix
                                        //String partnerSpeciality = [SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id =: sfAccountId].Core_IPA_Partner_Speciality__c;
                                        String partnerSpeciality = accountPartnerSpecsMap.containsKey(sfAccountId) ? accountPartnerSpecsMap.get(sfAccountId).Core_IPA_Partner_Speciality__c : null;
                                        if(!String.isEmpty(partnerSpeciality)) {
                                            List<String> partnerSplList = partnerSpeciality.split(';');
                                            for(String partnerSpl : partnerSplList ) {
                                                if(eRPMSFMappingsByPartnerSpecs.containsKey(partnerSpl)) {
                                                    acctBenefits.add(eRPMSFMappingsByPartnerSpecs.get(partnerSpl));
                                                }
                                            }
                                            /*
for(ERPM_SF_MAPPING_SETTING__mdt mdt : [SELECT eRPM_KeyValue__c
FROM ERPM_SF_MAPPING_SETTING__mdt
WHERE Mappting_Type__c =: Label.PRM_IPA_Partner_Specialty
AND SF_KeyValue__c IN: partnerSplList]){
acctBenefits.add(mdt.eRPM_KeyValue__c);
}
*/
                                            system.debug('acctBenefits'+acctBenefits);
                                        }
                                        List<String> partnerRoles = new List<String>();
                                        map<string, List<string> > customSettingmap = new map<string, List<string> >();
                                        /*
for( ERPM_SF_MAPPING_SETTING__mdt customSettings : [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c
FROM ERPM_SF_MAPPING_SETTING__mdt
WHERE Mappting_Type__c =: Label.PRM_Partner_Role
AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes]){
*/
                                        for( ERPM_SF_MAPPING_SETTING__mdt customSettings : eRPMSFMappingsByEnggCodes) {
                                            system.debug('customSettings.SF_KeyValue__c'+ customSettings.SF_KeyValue__c);
                                            if ((!customSettingmap.containsKey(customSettings.eRPM_EngagementCodes__c)) ) {
                                                if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                                                    customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                                                }
                                                else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                                                        || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode) {
                                                            customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                                                        }
                                            }
                                            else {
                                                if(!customSettingmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                                                    if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                                                        customSettingmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                                                    }
                                                }
                                            }
                                        }
                                        if(customSettingmap.values().size() > 0) {
                                            for(List<String> roles : customSettingmap.values()) {
                                                partnerRoles.addAll(roles);
                                            }

                                            //Label.AllowedPRMEngagenents label also used in Core_IntInboundMsgERPM_Account for ITP filter logic
                                            // Added below check to include ITP only account and has ODM-LOEM benefit. As there is no Partner speciality for ODM-LOEM benefit
                                            /*if((erpmAcctEnggCodes.size() == 1 && erpmAcctEnggCodes.contains(Label.AllowedPRMEngagenents)) && !partnerRoles.contains(Label.ITP_No_Specialty_Partner_Roles)) {
for(PRM_AccountChannelMembership__c acm : [SELECT Id, PRM_Partner_Role__c FROM PRM_AccountChannelMembership__c
WHERE PRM_Partner_Role__c =: Label.ITP_No_Specialty_Partner_Roles AND PRM_Account_Id__c =: sfAccountId
AND PRM_Status_Nm__c =: Label.PRM_Engagement_Status_Approved]){
partnerRoles.add(acm.PRM_Partner_Role__c);
}
}*/

                                            if(partnerRoles.size() >0)
                                                newc.Core_IPA_PartnerRole__c = Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(partnerRoles)));
                                            system.Debug('c.Core_IPA_PartnerRole__c' +newc.Core_IPA_PartnerRole__c);

                                        }
                                    }
                                    contactsToInsert.add(newc);

                                    system.debug('******** matchingAccountMap.containsKey the CIM Id ********' + acct.cimId);
                                    if(!StopERPMSalesCloudIPAInteg)
                                    {
                                        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> relationships = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();

                                        if(acct.personAccountRelations != null && acct.personAccountRelations.size() > 0) {
                                            //Add the account contact relationships to a local variable only for the PRM engagements.
                                            //TODO::REVISIT :: PRM engagements conditions should be lifted, make generic.
                                            for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                                                if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(ePAR.engagementCode)) {
                                                    relationships.add(ePAR);
                                                }
                                            }

                                            system.debug('******** eRPM Relationships ********' + relationships);
                                            //Add to account id relationships map only when erpm person account relationship contains PRM enagements (CSPx2, ITP, ISA)
                                            if(relationships.size() >0)
                                                acctIdRelationshipsMap.put(matchingAccountMap.get(acct.cimId).Id, relationships);
                                            //eRPM_PersonAccountRelations.addall(acct.personAccountRelations);
                                        }
                                        /*Team Ruby changes - Start*/
                                        erpmAccounts.add(acct);
                                        System.debug('erpmAccounts-->'+erpmAccounts);
                                        /*Team Ruby changes - end*/
                                        System.debug('acct-->'+acct);
                                        system.debug('******** acctIdRelationshipsMap ********' + acctIdRelationshipsMap);
                                        System.debug('##### Attempting to add contact record: ' + newc);
                                    }
                                }

                                else {
                                    System.debug('##### Did not find the account based on CIM ID, so ignoring this message');
                                    person.ignoreMessage = true;
                                    person.ignoreReason = 'Did not find the account based on CIM ID';
                                }
                            }

                        }
                        else {
                            System.debug('##### No account in the message, so ignoring this message');
                            person.ignoreMessage = true;
                            person.ignoreReason = 'No account in the message';
                        }
                        // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
                    }
                }
            }

            // Perform DML INSERTs and UPDATEs for Contacts (IDs from inserts will be needed for next step)
            System.debug('##### contactsToUpdate: ' + contactsToUpdate);
            List<Contact> finalContactUpdateList = new List<Contact>();
            Map<Id, Contact> contactsToUpdateSet2Map = new Map<Id, Contact>();
            if (contactsToUpdate.size() > 0) { 
                
                for(Contact c : contactsToUpdate){
                    contactsToUpdateSet2Map.put(c.id, c);
                }
                contactId = contactsToUpdate[0].Id;
                sfAcctId = contactsToUpdate[0].AccountId;
                //update contactsToUpdate;
            }
             
            //Gireesh:Adding other contact update changes to same list
            for(contact contactSet2: contactsToUpdateSet2Map.values()){
                    if(updateContactSet1Map!=null && updateContactSet1Map.size()>0 && 
                       updateContactSet1Map.containsKey(contactSet2.Id)){
                        Contact cDeltaChange  = updateContactSet1Map.get(contactSet2.Id);
                        contactSet2.Core_Login_Id__c = cDeltaChange.Core_Login_Id__c;
                        contactSet2.Core_Enterprise_Id__c = cDeltaChange.Core_Enterprise_Id__c;
                        finalContactUpdateList.add(contactSet2);
                        
                    }/*else{
                        finalContactUpdateList.add(contactSet2);
                    }*/
            }            
            for(Contact contactSet1: updateContactSet1Map.values()){
                if(!contactsToUpdateSet2Map.containsKey(contactSet1.Id)){
                    finalContactUpdateList.add(contactSet1);
                }
            }
            
            
             if(finalContactUpdateList!=null && finalContactUpdateList.size()>0){
                update finalContactUpdateList;
            }
            
            
            /*
Commented the below soft and hard delete codes are added to single Update  --Rajesh
// For deletes/soft deletes, we need to perform a second update
if (contactIdsToUpdateAgain.size() > 0) {
contactsToUpdate = [select Id, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c
from Contact where Id in :contactIdsToUpdateAgain];
List<Contact> contactsToUpdateAgain = new List<Contact>();
for (Contact c : contactsToUpdate) {
//c.Core_Login_Id__c = null; //Gireesh:US912533: Updating this attribute above
c.Core_Login_Status__c = null;
//c.Core_Enterprise_Id__c = null; //Gireesh:US912533: Updating this attribute above
contactsToUpdateAgain.add(c);
}
System.debug('##### contactsToUpdateAgain: ' + contactsToUpdateAgain);
if (contactsToUpdateAgain.size() > 0)
update contactsToUpdateAgain;
}
*/
            //US95568 and US95670 -If contact is a partner user need to call Method the DisablePartnerPortalUser added by Rajesh  //
            if(!ContactPartnerDisable.isEmpty()) {
                ContactPartnerDisableList.addAll(ContactPartnerDisable);
                DisablePartnerPortalUser(ContactPartnerDisableList);
            }
            System.debug('##### contactsToInsert: ' + contactsToInsert);

            if (contactsToInsert.size() > 0) {
                insert contactsToInsert;


                // For our RDC self-reg checks below, we need to re-pull some additional information from our freshly inserted contacts
                Set<Id> contactIdsInserted = new Set<Id>();
                for (Contact c : contactsToInsert)
                    contactIdsInserted.add(c.Id);

                contactId = contactsToInsert[0].Id;
                sfAcctId = contactsToInsert[0].AccountId;

                contactsToInsert = [
                    select Id, AccountId, Account.Core_CIM_ID__c, Account.Core_B2B_Entitlement__c, Account.Name, Account.Core_CNDA_Number__c,
                    Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, CreatedDate, LastModifiedDate,
                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Personal_Email_Indicator__c,
                    Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                    Core_eRPM_Language_Code__c, Core_Job_Function__c, Core_Job_Function_Code__c,
                    Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Publish_Timestamp__c, /*Core_AGS_Integration_Status__c,*/ Core_Deactivated__c,
                    Core_Contact_B2B_Indicator__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c
                    from Contact
                    where Id in :contactIdsInserted
                ];
            }

            //TODO :: REVISIT :: contactsToUpdate[0].Id LOGIC
            //TODO :: REVISIT :: update/create needs to be done only to CSPx2 (CIP) engagement for PI2
            //TODO :: REVISIT :: 'CSPx2' will be moved to Label later and map eRPM engagement to Channel Program

            Set<String> partnerRoles = new Set<String>();
            //get partner roles for input engagement
            for(ERPM_SF_MAPPING_SETTING__mdt mpr : [SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt
                                                    WHERE Mappting_Type__c =: Label.PRM_Partner_Role
                                                    AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes ]) {
                                                        partnerRoles.add(mpr.eRPM_KeyValue__c);
                                                    }

            if(eRPM_Subscriptions.size() >0 && string.isNotBlank(erpmPersons[0].LoginId)) {
                system.debug('******* Before Insert/Update Subscriptions *******');
                System.enqueueJob(new Core_Integration_Additional_Attributes(null, contactId, null, null, null, eRPM_Subscriptions, null,eRPMChangeAgentId,null));
                //new Core_Integration_Additional_Attributes(null, contactId , null).SetSubscriptions(eRPM_Subscriptions);
                system.debug('******** Insert/Update Subscriptions is/are successful ********');
            }

            if(!StopERPMSalesCloudIPAInteg)
            {
                //Get account channle memberships for account
                List<PRM_AccountChannelMembership__c> accountChannelMemberships = [SELECT Id FROM PRM_AccountChannelMembership__c
                                                                                   WHERE PRM_Account_Id__c =: sfAcctId
                                                                                   AND PRM_Partner_Role__c IN: partnerRoles
                                                                                   AND PRM_Status_Nm__c =: Label.PRM_Engagement_Status_Approved];
                System.debug('erpmAccountCIMIds'+erpmAccountCIMIds);
                System.debug('accountChannelMemberships'+accountChannelMemberships);
                System.debug('acctIdRelationshipsMap'+acctIdRelationshipsMap);
                //Subs and relationship will get assigned only if account has account channel membershp
                if(accountChannelMemberships != null && accountChannelMemberships.size() > 0) {
                    System.debug('accountChannelMemberships inside if');
                    System.debug('acctIdRelationshipsMap before if'+'contactId : '+contactId+'erpmAccounts : '+erpmAccounts);
                    System.debug('erpmAccounts-->'+erpmAccounts);
                    if(enttlAssignFlag == true) {
                        //IsContactEntitlementUpdated = new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement,null,null,null,null).SetContactEntitlements(acctIdRelationshipsMap.get(acctId));
                        System.enqueueJob(new Core_Integration_Additional_Attributes(null, contactId, Label.PRM_IPAEngagement, null, null,null, null, eRPMChangeAgentId,erpmAccounts));      // Team ruby changes - added extra parameter erpmAccounts.
                        system.debug('******** Insert/Update SetContactEntitlements is/are successful ********');
                    } else {
                        if((acctIdRelationshipsMap.size()>0) && string.isNotBlank(contactId) && (erpmAccounts != null && !erpmAccounts.IsEmpty()))// Team ruby changes - added extra parameter erpmAccounts.
                        {
                            for(Id acctId : acctIdRelationshipsMap.keyset()) {
                                system.debug('******** Before Insert/Update  ********* acctId :: ' + acctId  + ' *********  acctIdRelationshipsMap ::   ' + acctIdRelationshipsMap.get(acctId));
                                system.debug('RelationshipQueue before enqueue');
                                Id jobId = System.enqueueJob(new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement, null, acctIdRelationshipsMap.get(acctId),null, null, eRPMChangeAgentId,erpmAccounts));
                                system.debug('RelationshipQueue JobId '+jobId); // Team ruby changes - added extra parameter erpmAccounts.
                                //new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement).SetPersonAccountRelationships(acctIdRelationshipsMap.get(acctId));
                                system.debug('******** Insert/Update PersonAccountRelations is/are successful ********');

                                system.debug('******** Before Insert/Update  ********* contactId :: ' + contactId  + '********* acctId :: ' + acctId  + ' *********  acctIdRelationshipsMap ::   ' + acctIdRelationshipsMap.get(acctId));
                                //IsContactEntitlementUpdated = new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement,null,null,null,null).SetContactEntitlements(acctIdRelationshipsMap.get(acctId));
                                System.enqueueJob(new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement, null, null,null, acctIdRelationshipsMap.get(acctId), eRPMChangeAgentId,erpmAccounts)); // Team ruby changes - added extra parameter erpmAccounts.
                                system.debug('******** Insert/Update SetContactEntitlements is/are successful ********');
                            }
                        }
                    }
                }
            }

            Map<String,Contact> allContactsMap = new Map<String,Contact>();
            Map<String,Contact> insertedContactsMap = new Map<String,Contact>();
            for (Contact c : contactsToUpdate) {
                allContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                tags += Core_IntegrationUtility.addTag(c.Id);
            }
            for (Contact c : contactsToInsert) {
                allContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                insertedContactsMap.put(c.Core_eRPM_Person_Id__c, c);
                tags += Core_IntegrationUtility.addTag(c.Id);
            }

            //--------------------------------------------------------------------------------------------------
            // ENTITLEMENT & ERPM ENGAGEMENT RECORD POTENTIAL INSERTS

            Core_IntegrationUtility.insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);

            // Create a new map of all ERPM Engagements to Entitlement IDs in the system
            Map<String,Id> engagementCodeEntitlementIdMap = new Map<String,Id>();

            for (Core_Entitlement__c e : [SELECT Id, Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
                                          FROM Core_Entitlement__c where Core_AGS_Role_Id__c = '' and Core_ERPM_Engagement_Id__c != null])
            {
                engagementCodeEntitlementIdMap.put(e.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, e.Id);

            }

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
                            for (Core_Contact_Entitlement__c ce : existingContactEntitlementsAll) {
                                ce.Core_Selected__c = false;
                                if(ce.Core_From_Source__c == false)
                                    ce.Core_Update_Reason__c = UPDATE_REASON_ERPM;
                            }

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

                        Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap =
                            new Map<String,List<Core_Contact_Entitlement__c> >();

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
                            //Added by Team Quest If effective end date is set for person engagement uncheck the enagagement in SF.
                            System.debug('Engagement End Check'+engg.effEndEngagmentDate);
                            if(String.IsBlank(engg.effEndEngagmentDate)){
                                erpmEngagements.add(engg.engagementCode);


                                insertUpdateContactEntitlementLists(contactEntitlementsToInsert, contactEntitlementsToUpdate, person, engg,
                                                                    c, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,
                                                                    engagementCodeEntitlementIdMap);
                            }
                        }

                        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                            for (Core_IntegrationUtility.ERPM_Person_Account_Relation relation : acct.personAccountRelations) {
                                System.debug('##### Checking this ERPM person account relation engg code to see if insert/update needed: ' + relation.engagementCode);

                                if (!erpmEngagements.contains(relation.engagementCode) && !relation.inactiveIndicator) {

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
                        system.debug('atb existingContactEngagementCodes- '+existingContactEngagementCodes);
                        system.debug('atb erpmEngagements- '+erpmEngagements);
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
                    System.debug(' SK >>  person -- '+person);
                    System.debug(' SK >>  insertedContactsMap -- '+insertedContactsMap);
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
                                                                Core_ERPM_Account_Data__c=erpmAccountData, Core_Data_Loaded__c = true,
                                                                Core_Update_Reason__c = UPDATE_REASON_ERPM);
                            ce.Core_Status__c ='Pending';
                            contactEntitlementsToInsert.add(ce);

                            //Changes the status to Pending
                            //Contact tmp = insertedContactsMap.get(person.erpmPersonId);
                            //tmp.Core_AGS_Integration_Status__c = 'Pending'; //TODO Reviews
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
            boolean isRollBack = false;
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
                                isRollBack = true;
                                //PMD Issue fix - commented - moved out of Loop
                                //insert contactEntitlementsToInsert;
                            }
                        }
                    }
                    //else
                    // IsContactEntitlementUpdated = true;
                }
                //PMD Issue Fix - brought the code outside the loop
                if(isRollBack) {
                    insert contactEntitlementsToInsert;
                }
            }
            System.debug('##### contactEntitlementsToUpdate: ' + contactEntitlementsToUpdate);
            if (contactEntitlementsToUpdate.size() > 0) {
                update contactEntitlementsToUpdate;
                //IsContactEntitlementUpdated = true;
            }

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
                select Id, Core_ERPM_Integration_Status__c,/*Core_AGS_Integration_Status__c,*/ Core_ERPM_Integration_Message__c, Core_Enterprise_Id__c,
                Core_Login_Id__c, AccountId, FirstName, LastName, Email, Phone, MailingCountry, Core_Job_Function__c,
                Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Deactivated__c, CreatedDate,
                LastModifiedDate, Account.Core_CIM_ID__c, Account.Name, Core_Contact_B2B_Indicator__c
                from Contact where Id in :allSuccessfulContactIds
            ];
            system.debug('--contactsToUpdateERPMIntegrationStatus-- ' + contactsToUpdateERPMIntegrationStatus);
            system.debug('--contactsToUpdateERPMIntegrationStatus.size()-- ' + contactsToUpdateERPMIntegrationStatus.size());
            for (Contact c : contactsToUpdateERPMIntegrationStatus) {
                // Change the Contact ERPM Integration Status to 'Successful'. This will trigger the AGS outbound message
                // via Zay's trigger code
                // This is as part of Contact Entitlement mapping for ISA - eRPM Team has done
                //if(IsContactEntitlementUpdated && [Select Active__c from Trigger_Execution__mdt where DeveloperName = 'IsAGSIntegrationFlagTobeSet' limit 1].Active__c)
                //    c.Core_AGS_Integration_Status__c ='Pending';

                //Below code is commented as per US930418.ERPM Inbound Contact Message will not update integration status to successful.
                //If Identites are not created, AGS will create identity and ERPM email functionalities will not work.
              //  c.Core_ERPM_Integration_Status__c = 'Successful';    //Commented by Draco
                c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.successfulInboundMessage(newList[0].Id);
            }

            // Perform DML UPDATE for Contacts
            System.debug('##### contactsToUpdateERPMIntegrationStatus: ' + contactsToUpdateERPMIntegrationStatus);
            if (contactsToUpdateERPMIntegrationStatus.size() > 0)
                update contactsToUpdateERPMIntegrationStatus;

            List<Core_Integration_Outbound_Message__c> outboundMessages = new List<Core_Integration_Outbound_Message__c>();

            // Now send the Box B Contact outbound messages based on all that were successful
            // System.debug('##### Checking to see if we should send a Box B Contact message....');
            //for (Contact c : contactsToUpdateERPMIntegrationStatus) {
            //System.debug('##### B2B Indicator = ' + c.Core_Contact_B2B_Indicator__c + ', Enterprise ID = ' + c.Core_Enterprise_Id__c);
            // Send the message if it's a B2B contact with an Enterprise ID
            //if ((c.Core_Contact_B2B_Indicator__c == true) && (!String.isBlank(c.Core_Enterprise_Id__c))) {
            //outboundMessages.add(createBoxBContactMessage(c));
            //}
            //}*/

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
            List<Contact> failedContacts = [SELECT Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                                            from Contact where Core_eRPM_Person_Id__c in :erpmPersonIds];

            if (failedContacts.size() == 0) {
                failedContacts = [SELECT Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                                  from Contact where Email in :erpmEmails];
            }

            for (Contact c : failedContacts) {
                c.Core_ERPM_Integration_Status__c = 'Failed';
                c.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.failedInboundMessage(newList[0].Id, ex);
                tags += Core_IntegrationUtility.addTag(c.Id);
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
            from Core_Integration_Inbound_Message__c where Id in :msgIds
        ];

        for (Core_Integration_Inbound_Message__c m : messagesToUpdate) {
            // Note: if we need to start bulk processing messages, with different processing status for each, this will need to change
            m.Core_Processing_Status__c = processingStatus;
            m.Core_Exception_Message__c = processingMessage;
            m.Core_Log_Entry__c = logEntryId;
            m.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
            m.Core_Publish_Timestamp__c = publishTimestamp;
        }

        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        update messagesToUpdate;
    }


    // Public helper method to return a Box B Contact message from a Contact record. Also called from Contact trigger code.
    /* Pooja removed Box B message creation on ERPM inbound and moved it to process builder.*/

    // Helper method to update our Contact Entitlement collections based on records that need to be inserted or updated
    private static void insertUpdateContactEntitlementLists(
        List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,
        List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate,
        Core_IntegrationUtility.ERPM_Person person,
        Core_IntegrationUtility.ERPM_Engagement engg,
        Contact c,
        Set<String> existingContactEngagementCodes,
        Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,
        Map<String,Id> engagementCodeEntitlementIdMap)
    {
        String erpmAccountData = '';
        if (person.personAccounts.size() > 0) {
            erpmAccountData = 'ERPM Account Number: ' + person.personAccounts[0].erpmAccountNumber +
                ', CIM ID: ' + person.personAccounts[0].cimId +
                ', Account Name: ' + person.personAccounts[0].accountName;
        }
        System.debug('##### ERPM Account Data: ' + erpmAccountData);
        System.debug('##### ERPM existingContactEngagementCodes: ' + existingContactEngagementCodes);
        System.debug('##### ERPM engg.engagementCode: ' + engg.engagementCode);

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

                if ((ce.Core_Engagement_Tier__c != engg.effectiveTierCode) || (ce.Core_Selected__c == false) || (ce.Core_ERPM_Account_Data__c != erpmAccountData))
                {

                    ce.Core_Engagement_Tier__c = engg.effectiveTierCode;
                    ce.Core_ERPM_Account_Data__c = erpmAccountData;

                    // DH 1/19/17: changed this to *only* update selected to true if it's the no-role entitlement record that represents the engagement itself
                    if (ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c == null)
                        ce.Core_Selected__c = true;

                    //Team Quest - Adding these changes as part of UIOLI return journey users (== 'Partner Portal')
                    if(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null && ce.Core_Type__c == 'Entitlement' && Label.ERPMInteg_Entitlements_Allow.split(',').Contains(ce.Core_Entitlement_Id__r.Name))
                        ce.Core_Selected__c = true;

                    System.debug('##### Attempting to update this contact entitlement record to: ' + ce);
                    contactEntitlementsToUpdate.add(ce);
                }
            }
        }
    }


    // Use the Salutation to PersonTitle mapping configuration to determine correct salutation
    public static Core_Entitlement_Salutation_PrsTitle_Map__c[] SalutationMap;
    public static String getSalutation(String PersonTitle) {
        if(SalutationMap == null) SalutationMap = Core_Entitlement_Salutation_PrsTitle_Map__c.getall().values();
        String Result = '';
        if(!SalutationMap.isEmpty())
            for(Core_Entitlement_Salutation_PrsTitle_Map__c M : SalutationMap)
            if(M.PersonTitle__c == PersonTitle) {
                Result = M.Salutation__c; break;
            }
        return Result;
    }


    // Copy information from an ERPM Person record into a Contact record
    private static void setContactFieldsFromPerson(Contact c, Core_IntegrationUtility.ERPM_Person person,List<String> IPAEnggsForAddress) {

        // Additional safeguards added here to ensure 100% we don't overwrite anything if ERPM Person ID is non-NULL and doesn't match message
        if ((c.Core_eRPM_Person_Id__c == null) || (c.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
            if (c.Core_eRPM_Person_Id__c == null) {
                //c.Core_eRPM_Person_Id__c    = person.erpmPersonId; //Gireesh:US912533: Updating this attribute above
                system.debug('c.Core_eRPM_Person_Id__c ='+c.Core_eRPM_Person_Id__c);
            }
            //Added as part of WW22 release
            if((person.isDeleteIndicator !='Y' && person.inactIndicator =='N')) {
                //c.Core_Login_Id__c          = !String.isEmpty(person.loginId) ? person.loginId : c.Core_Login_Id__c ; //Gireesh:US912533: Updating this attribute above
                //c.Core_Enterprise_Id__c     = !String.isEmpty(person.enterpriseId) ?  person.enterpriseId : c.Core_Enterprise_Id__c; //Gireesh:US912533: Updating this attribute above
            }else {
                //c.Core_Login_Id__c          = person.loginId; //Gireesh:US912533: Updating this attribute above
                //c.Core_Enterprise_Id__c     = person.enterpriseId; //Gireesh:US912533: Updating this attribute above
            }
            //c.Core_Login_Id__c          = person.loginId;
            //c.Core_Enterprise_Id__c     = person.enterpriseId;
            c.Core_Identity_Status__c   = person.identityStatus;
            c.Core_Login_Status__c      = (person.identityStatus == 'A' ? 'Active' :
                                           person.identityStatus == 'D' ? 'Disabled' :
                                           person.identityStatus == 'X' ? 'Expired' : ''); // OPEN: waiting on logic from Jordan for Deleted
            c.Salutation                = getSalutation(person.title);
            c.FirstName                 = person.firstName;
            c.LastName                  = person.lastName;
            c.Email                     = person.email;
            c.Core_Preferred_Language__c= person.erpmLanguageCode;
            c.Core_Job_Function_Code__c = person.jobFunctionCode;
            c.Core_Profession__c=person.Profession.Professioncode;
            //System.debug('person.doNotContact : '+person.doNotContact);
            //c.Core_Do_Not_Contact__c    = !String.isblank(person.doNotContact);//Gireesh:US942207//using below code
            c.Core_Do_Not_Contact__c    = (person.marketingDoNotContactDate)!=Null ? True: False; //Gireesh:US959755:MarketingDNC
            c.Core_Sales_Do_Not_Contact_Ind__c    = (person.salesDoNotContactDate)!=Null ? True: False; //Gireesh:US942207
            //To avoid recursive update of datetime added null check
            if(c.Core_Marketing_Do_Not_Contact_Dtm__c == Null)
                c.Core_Marketing_Do_Not_Contact_Dtm__c = (person.marketingDoNotContactDate)!=Null ? person.marketingDoNotContactDate: Null;//Gireesh:US959755:MarketingDNC
            
            if(c.Core_Do_Not_Contact_Dtm__c == Null)
                c.Core_Do_Not_Contact_Dtm__c = (person.salesDoNotContactDate)!=Null ? person.salesDoNotContactDate: Null;//Gireesh:US942207
            
            c.Phone                     = person.phone;
            c.MobilePhone               = person.mobilePhone;
            c.Fax                       = person.fax;
            c.Core_English_Only_First_Name__c =!String.isEmpty(person.englishFirstName) ? person.englishFirstName : c.Core_English_Only_First_Name__c ;
            c.Core_English_Only_Last_Name__c = !String.isEmpty(person.englishLastName) ? person.englishLastName : c.Core_English_Only_Last_Name__c ;
            c.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
            // ----------- #REGION :: eRPM Code Changes :: START ------------- //
            c.Core_IPA_Intel_Last_Login_Date__c = String.isNotBlank(person.lastLoginDate) ?
                Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(person.lastLoginDate) : null;
            c.Core_IPA_Email_Verification_Date__c = String.isNotBlank(person.emailVerificationDate) ?
                Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(person.emailVerificationDate) : null;
            //Setting record type as Intel Contact
           //if(c.Core_Sales_Do_Not_Contact_Ind__c)//Gireesh:US942207
            /*if(c.Core_Do_Not_Contact__c)//Gireesh: Commented as per defect
            {
                c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.DNC_recordType).getRecordTypeId();
            }
            else
            {*/
                c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.ERPM_Intel_Contact).getRecordTypeId();

            //}

            if(!StopERPMSalesCloudIPAInteg)
            {
                for(String engg : IPAEnggsForAddress)
                {
                    System.debug('engg' +engg);
                    if(Label.IPAEnggsForMailingAddress.split(',').Contains(engg))
                    {
                        System.debug('engg inside if' +engg);
                        /*c.MailingStreet        = person.mailingStreet1;
                            c.MailingStreet        = c.MailingStreet + (person.mailingStreet2.trim() != '' ? (' ' + person.mailingStreet2) : '');
                            c.MailingStreet        = c.MailingStreet + (person.mailingStreet3.trim() != '' ? (' ' + person.mailingStreet3) : '');
                            c.MailingStreet        = c.MailingStreet + (person.mailingStreet4.trim() != '' ? (' ' + person.mailingStreet4) : '');
                            c.MailingCity          = person.mailingCity;
                            c.MailingState         = person.mailingState;
                            c.MailingPostalCode    = person.mailingPostalCode;*/
                        c.MailingCountry       = person.mailingCountry;
                    }
                }
            }
            
            //Gireesh:DE114250: Adding Core_Login_Status__c='Deleted'
            //if(person.changeAgentId != 'SalesCloud' && String.isEmpty(person.loginId) && String.isEmpty(person.enterpriseId) && c.Core_Login_Status__c!='Deleted'){
            if(String.isEmpty(person.loginId) && String.isEmpty(person.enterpriseId) && (person.erpmPersonId == c.Core_ERPM_Person_Id__c) &&
(person.email == c.Email) &&(!String.isBlank(c.Core_Enterprise_Id__c) || !String.isBlank(c.Core_Login_Id__c))&& c.Core_Login_Status__c!='Deleted'){
                c.Core_Login_Status__c = 'Deleted';
                person.isDeleteIndicator ='Y';
            }


            // ----------- #REGION :: eRPM Code Changes :: END ------------- //
        }
    }



    // Helper method to determine, based on an ERPM Person record, whether or not it's RDC self-registration
    private static Boolean isRDCSelfRegistration(Core_IntegrationUtility.ERPM_Person person) {
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements)
                if (engg.engagementCode == Label.Core_RDC_Engagement_Code) //if (engg.engagementCode == RDC_ENGAGEMENT_CODE)
                return true;
        }
        return false;
    }
    /*
* Method name  : DisablePartnerPortalUser
* Description  :US95568 and US95670 - This Method is used to disable the Partner user for Soft and Hard delete operation based on ERPM Message.
* Return Type  : void
* Parameter    : List<String> PartnerContactId
* This future Method is used to do avoid the Mixed DML operations setup and non setup Object.
*/
    @future
    public static void DisablePartnerPortalUser(List<String> PartnerContactId){
        System.debug('DisablePartnerPortalUser**');
        list<user> Partneruserlist=new list <user>();
        list<user> PartneruserlistUpdate=new list <user>();
        Boolean CustomsettingEnable=false;
        Partneruserlist=[select id,IsPortalEnabled,ContactId,contact.Core_Tokenized__c,contact.Core_Login_Status__c,IsActive from user where ContactId in: PartnerContactId];
        if(Partneruserlist != null && !(Partneruserlist.isEmpty())) {
            try{
                Core_IPS_Run_Rules_Exception_Cust_Partne__c IPSOrgId= Core_IPS_Run_Rules_Exception_Cust_Partne__c.getOrgDefaults();  // If the custom setting is ON it is not allowing  to disable the partner portal on User //
                if(Core_IPS_Run_Rules_Exception_Cust_Partne__c.getOrgDefaults().Run_Validation_Rule__c) {    // Chekcing the condition for validation rule is Turn ON or Not //
                    IPSOrgId.Run_Validation_Rule__c=false; //By pass validation rule //
                    Update IPSOrgId;
                    CustomsettingEnable=true;
                    System.debug('Customsetting IPS**');
                }
                for(user us:Partneruserlist) {
                    if(us.contact.Core_Tokenized__c==True && us.contact.Core_Login_Status__c=='Disabled' && us.IsPortalEnabled==True) { // If the contact Tokenized is True and Login Stauts is Disabled it will  considering as 'Hard Delete'.//
                        us.IsPortalEnabled=false; //If the contact is Hard Delete to disable only PartnerportalFlag set to False.//
                        us.IsActive=false;
                        PartneruserlistUpdate.add(us);
                    }
                    if(us.contact.Core_Tokenized__c==False && us.contact.Core_Login_Status__c=='Deleted' && us.IsActive==True) { //If the contact Tokenized is False and Login Stauts is Deleted it will  considering as 'Soft Delete'.
                        // us.IsActive=false; // If the contact is Soft Delete ,IsActive Flag set to False //
                        PartneruserlistUpdate.add(us);
                    }
                }
                if(PartneruserlistUpdate != null && !(PartneruserlistUpdate.isEmpty())) {
                    update PartneruserlistUpdate;
                    if(CustomsettingEnable) {
                        IPSOrgId.Run_Validation_Rule__c=true; // Turn it ON after disable partner portal user//
                        Update IPSOrgId;
                    }
                    System.debug('PartneruserlistUpdate==============>'+PartneruserlistUpdate);
                }
            }catch(Exception e) {
                System.debug('Partner Portal Disable Exception===> '+e.getMessage());
            }
        }

    }
}