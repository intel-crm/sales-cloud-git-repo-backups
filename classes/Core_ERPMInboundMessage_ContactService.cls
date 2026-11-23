/******************************************************************************************************************************************
Class Name  : Core_ERPMInboundMessage_ContactService
Created Date : O7 July 2022
Function    : Business logic for processing Inbound ERPM messages
******************************************************************************************************************************************/

public without sharing class Core_ERPMInboundMessage_ContactService {
    
    private static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    private static final String LOG_ENTRY_PROJECT  = 'Entitlement';
    private static final String LOG_ENTRY_SCOPE    = 'IntegrationInboundMessageERPM';
    private static final String LOG_ENTRY_ERROR    = 'error';
    private static final String LOG_ENTRY_INFO     = 'info';
    private static final String LOG_ENTRY_OBJECT   = 'Core_Integration_Inbound_Message__c';
    private static final String UPDATE_REASON_ERPM = 'ERPM';
    private static final List<String> PRM_ENGGS = string.isNotBlank(Label.PRM_IPA_Engagements) ? Label.PRM_IPA_Engagements.split(',') : new List<String>();
    private static final List<String> SUBSCRIPTION_ALLOWED_PROGRAMS = string.isNotBlank(Label.SubscriptionAllowedPrograms) ? Label.SubscriptionAllowedPrograms.split(',') : new List<String>();
    private static final List<String> IPA_SUBSCRIPTION_CHANGEAGENTS=string.isNotBlank(Label.IPAChangeAgentForSubscriptions) ? Label.IPAChangeAgentForSubscriptions.split(',') : new List<String>();
    private static final boolean STOP_ERPM_SLSCLD_IPA_INTEG = (!Test.isRunningtest() ? Boolean.valueOf(Label.StopERPMSalesCloudIPAInteg):false);
    private static Core_InboundContactSelectorContracts.IContactQuerySelector contactQuerySelectorInstance =  Core_InboundContactQuerySelector.getInstance();
    private static Boolean hasIPAEnggsForMailingAddress=false;
    private static Boolean isRDCSelfRegistration=false;
    
    public class CustomException extends Exception {}

    /*
    * description : Main method for processing ERPM Contact (Person) messages
    * params : Core_Integration_Inbound_Message__c contactMessage
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void processContactMessages(Core_Integration_Inbound_Message__c contactMessage) {
        Core_IntegrationUtility.ERPM_Person person = new Core_IntegrationUtility.ERPM_Person();
        String processingStatus = 'Successful'; 
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        Set<String> erpmAccountCIMIds = new Set<String>();
        Set<String> erpmAccountSFIds = new Set<String>();
        Set<String> erpmAccountNumbers = new Set<String>();
        Map<Id, Contact> allSuccessfulContactMap = new Map<Id, Contact>();
        Map<Id, Contact> updateContactSet1Map=new Map<Id, Contact>();
        Map<String,Account> matchingAccountMap = new Map<String,Account>();
        Set<String> matchingAccountSFId = new Set<String>();
        Contact newContact = new Contact();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Account> accountsToInsert = new List<Account>();
        Set<Id> ContactPartnerDisable=new Set<Id>(); 
        List<Id> ContactPartnerDisableList=new List<Id>();
        List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelations = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap = new Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> >();
        Id contactId = null;
        Id sfAcctId = null;
        Set<Id> allAccountIds = new Set<Id>();
        String tags = '';
        String eRPMChangeAgentId = '';

        string fullPayload = Core_IntegrationUtility.getFullPayload(contactMessage);
        if ((contactMessage.Core_Processing_Status__c == 'Pending') && (fullPayload!= null)) {
            try {
                // Parse the payload into an object.
                person = Core_IntegrationInboundMessageParsing.parsePerson(fullPayload);
                eRPMChangeAgentId = person.changeAgentId;
                //Validation of the email attached in ERPM(Person) message
                personEmailValidation(person);
                //Building up tags used for log entries
                appendTagsERPMPerson(person,tags);
                //Setting ERPM Engagement from PersonAccount and PersonAccountEngagements
                setEnggCollectionsByPerson(person,tags,erpmAccountSFIds,erpmAccountCIMIds,erpmAccountNumbers);

                if(!person.personAccounts.isEmpty()) {
                    //Getting Matching Account SalsesforceId
                    getMatchingAccountSFIdAndSFIdFromCIMd(erpmAccountSFIds,person,erpmAccountCIMIds,erpmAccountNumbers,matchingAccountMap,matchingAccountSFId,tags);
                }
                //Adding ErpmSubscription into the collection eRPM_Subscriptions from Person Message
                setERPMSubscription(person,eRPM_Subscriptions);
            }
            catch (Exception ex) {
                String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                processingStatus = 'Failed';
                processingMessage += ', Read Message: ' + exceptionMessage;
                logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                    'Error reading ERPM Person message', '', contactMessage.Id, LOG_ENTRY_OBJECT, '', ex);
            }
        }
        try {
            if ((String.isBlank(person.erpmPersonId)) && (String.isBlank(person.email))) {
                throw new CustomException('ERPM Person message must contain a Person ID or Email address.');
            }
            String queryFields = 'Id, AccountId, Email, Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,'+'Account.PRM_Count_IPA_Terms_And_Conditions__c,' + //DRACO Change- Shreyash Agrawal
                'Core_ERPM_Integration_Publish_Timestamp__c,Core_English_Only_First_Name__c, Core_Deletion_Reason__c,Core_English_Only_Last_Name__c,Core_IPA_PartnerRole__c, Core_Personal_Email_Indicator__c' + ',' + '(SELECT id,name,Core_Entitlement_Nm__c,Core_Status__c, Core_Selected__c,Core_Entitlement_Id__r.Id FROM contact_entitlements__r)'; //DRACO Change - Shteyash Agrawal
            
            Contact matchingContact = contactQuerySelectorInstance.getContact(person.erpmPersonId,person.email,queryFields);
            System.debug('@@ Matching Contact '+matchingContact);
            Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap    =  new Map<Id,List<Core_Contact_Entitlement__c> >();
            Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap     =  new Map<Id,List<Core_Contact_Entitlement__c> >();
            List<Core_Contact_Entitlement__c> ceList = null;
            if (matchingContact!=null) {
                //Returning Contact Map by processing contact info and setting the contact attribute.
                updateContactSet1Map = setMatchingContactAttributes(person, matchingContact);
                //Associate Inbound Message to the Contact
                setContactInboundMessage(matchingContact, contactMessage);
                //Pulling the ContactEntitlement record
                getContactEntitlement(matchingContactEntitlementAllMap,matchingContactEntitlementEnggMap,ceList,matchingContact);

                if(!matchingAccountSFId.IsEmpty() && !matchingAccountSFId.contains(matchingContact.AccountId)) {
                    person.ignoreMessage = true;
                    person.ignoreReason = 'Contact is part of different account in Salesforce, hence ignoring message';
                    sfAcctId=matchingContact.AccountId;
                    contactId=matchingContact.Id;
                    Core_IntegrationOptimization.SendEmail(person.email,'Multiple_Accounts');
                    if(!STOP_ERPM_SLSCLD_IPA_INTEG){
                        if(Core_ERPMInboundMessage_IPAContact.erpmAcctEnggCodes.Contains(system.label.ERPM_EngagementCode)) {
                            Core_ERPMInboundMessage_IPAContact.IPA_SetErpmAccount(person);
                        }
                    }
                }
            }

            if(!STOP_ERPM_SLSCLD_IPA_INTEG){
                Core_ERPMInboundMessage_IPAContact.IPA_SetAllAccountId(person,matchingContact,allAccountIds,matchingAccountMap);
            }
            
            if (!person.ignoreMessage) {
                if (matchingContact!=null) {
                    //validating Erpm Person(Message) for maatching contact.
                    validatePersonMessage(matchingContact,person);
                    if (!person.ignoreMessage) {
                        matchingContact.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
                        //As an Ops I want contact record to be tokenized when contact is removed (hard delete) from eRPM.
                        if(person.isDeleteIndicator =='Y' && person.inactIndicator =='Y' ) {
                            matchingContact.Core_Tokenized__c = true;
                            matchingContact.Core_Login_Status__c ='Disabled';
                            contactsToUpdate.add(matchingContact);
                            ContactPartnerDisable.add(matchingContact.Id);
                        }
                        // Added logic for soft delete Contact : As an ops I want to remove login id, enterprise id of a contact if it is soft deleted from eRPM
                        else if(person.changeAgentId != 'SalesCloud' && ((person.isDeleteIndicator =='Y' && person.inactIndicator =='N') ||
                                                                            (!String.isEmpty(matchingContact.Core_Login_Status__c)&& (person.enterpriseId == '') &&(person.erpmPersonId == matchingContact.Core_ERPM_Person_Id__c) &&(person.email == matchingContact.Email) &&(!String.isBlank(matchingContact.Core_Enterprise_Id__c) || !String.isBlank(matchingContact.Core_Login_Id__c))))) {
                                                                                System.debug('##### Soft deletion, so blanking out some fields');
                                                                                matchingContact.Core_Tokenized__c =false;
                                                                                contactsToUpdate.add(matchingContact);
                                                                                ContactPartnerDisable.add(matchingContact.Id);
                        }
                        // Otherwise it's just a normal contact update.
                        else {
                            System.debug('##### Not ERPM deleted, disabled, or soft deleted, so updating the record');
                            if ((matchingContact.Core_eRPM_Person_Id__c == null) || (matchingContact.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
                                // Method to set the contact attribute for matching contact.
                                setMatchingContactAttributes(matchingContact,person,allAccountIds,contactsToUpdate,matchingAccountMap,acctIdRelationshipsMap);
                                System.debug('@@Contact to update'+contactsToUpdate);                         
                            }
                        }
                    }
                }
                // Did not find matching Contact so this the new contact insertion.
                else {
                    if (!person.personAccounts.isEmpty()) {
                        //Insertion of contact if matching Contact is not found
                        createContact(person,matchingAccountMap,newContact,allAccountIds,acctIdRelationshipsMap,contactId,sfAcctId,queryFields);
                        System.debug('newContact $$$@1 '+newContact);
                    }
                    else {
                        person.ignoreMessage = true;
                        person.ignoreReason = 'No account in the message';
                    }
                }
            }
            
            List<Contact> finalContactUpdateList = new List<Contact>();
            Map<Id, Contact> contactsToUpdateSet2Map = new Map<Id, Contact>();
            if (!contactsToUpdate.isEmpty()) { 
                
                for(Contact cUpdate : contactsToUpdate){
                    contactsToUpdateSet2Map.put(cUpdate.id, cUpdate);
                }
                contactId = contactsToUpdate[0].Id;
                sfAcctId = contactsToUpdate[0].AccountId;
            }
            
            for(contact contactSet2: contactsToUpdateSet2Map.values()){
                if(!updateContactSet1Map.isEmpty() && 
                    updateContactSet1Map.containsKey(contactSet2.Id)){
                        Contact cDeltaChange  = updateContactSet1Map.get(contactSet2.Id);
                        contactSet2.Core_Login_Id__c = cDeltaChange.Core_Login_Id__c;
                        contactSet2.Core_Enterprise_Id__c = cDeltaChange.Core_Enterprise_Id__c;
                        finalContactUpdateList.add(contactSet2);
                        
                    }
            }            
            for(Contact contactSet1: updateContactSet1Map.values()){
                if(!contactsToUpdateSet2Map.containsKey(contactSet1.Id)){
                    finalContactUpdateList.add(contactSet1);
                }
            }
            
            
            if(!finalContactUpdateList.isEmpty()){
                if(Schema.sObjectType.Contact.fields.Core_ERPM_Integration_Publish_Timestamp__c.isUpdateable() &&
                //Schema.sObjectType.Contact.fields.Core_Tokenized__c.isUpdateable() &&
                Schema.sObjectType.Contact.fields.Core_Login_Status__c.isUpdateable() &&
                Schema.sObjectType.Contact.fields.Core_Login_Id__c.isUpdateable() &&
                Schema.sObjectType.Contact.fields.Core_Enterprise_Id__c.isUpdateable() &&
                Schema.sObjectType.Contact.fields.Core_Deletion_Reason__c.isUpdateable() &&
                //Schema.sObjectType.Contact.fields.External_User_State__c.isUpdateable()&&
                //Schema.sObjectType.Contact.fields.External_User_State_Change_Date_Times__c.isUpdateable() &&
                Schema.sObjectType.Contact.fields.Core_eRPM_Person_Id__c.isUpdateable() ){
                    update finalContactUpdateList;
                }
            }
            if(!ContactPartnerDisable.isEmpty()) {
                ContactPartnerDisableList.addAll(ContactPartnerDisable);
                DisablePartnerPortalUser(ContactPartnerDisableList);
            }
            //processing Erpm Subscription
            processContactOnErpmSubscription(updateContactSet1Map,eRPM_Subscriptions,eRPMChangeAgentId,contactId);
            
            if(!STOP_ERPM_SLSCLD_IPA_INTEG)
            {
                Core_ERPMInboundMessage_IPAContact.IPA_SetRelationshipByChnlMembership(sfAcctId, contactId, eRPMChangeAgentId, acctIdRelationshipsMap);       
            }
            
            Map<String,Contact> allContactsMap = new Map<String,Contact>();
            Map<String,Contact> insertedContactsMap = new Map<String,Contact>();
            for (Contact conUpdate : contactsToUpdate) {
                allContactsMap.put(conUpdate.Core_eRPM_Person_Id__c, conUpdate);
                tags += Core_IntegrationUtility.addTag(conUpdate.Id);
            }

            if(newContact!=null){
                allContactsMap.put(newContact.Core_eRPM_Person_Id__c, newContact);
                insertedContactsMap.put(newContact.Core_eRPM_Person_Id__c, newContact);
                tags += Core_IntegrationUtility.addTag(newContact.Id);
            }
            //Method to process Contact Entitlement and Entitlement record.
            processContactEntitlement(person,allContactsMap,matchingContactEntitlementEnggMap,matchingContactEntitlementAllMap,ceList,insertedContactsMap);

            Set<Id> allSuccessfulContactIds = new Set<Id>();
            if(newContact!=null){
                allSuccessfulContactIds.add(newContact.Id);
            }
            
            for (Contact successConUpdate : contactsToUpdate){
                allSuccessfulContactIds.add(successConUpdate.Id);
            }
            
            allSuccessfulContactMap= contactQuerySelectorInstance.getContactsById(allSuccessfulContactIds ,queryFields);
            if(allSuccessfulContactMap != null){
                List<Contact> contactsToUpdateERPMIntegrationStatus = new List<Contact>();
                contactsToUpdateERPMIntegrationStatus =allSuccessfulContactMap.values();
                for (Contact conToUpdateERPM : contactsToUpdateERPMIntegrationStatus) {
                    conToUpdateERPM.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.successfulInboundMessage(contactMessage.Id);
                }
                if (!contactsToUpdateERPMIntegrationStatus.isEmpty()){
                    if(Schema.sObjectType.Contact.fields.Core_ERPM_Integration_Message__c.isUpdateable()){ 
                        update contactsToUpdateERPMIntegrationStatus;
                    }
                }
            }
            
            String successMessage = '';
            String successDetails = '';
            if (person.ignoreMessage) {
                successMessage = 'Ignored ERPM Person message';
                successDetails = 'Ignored message based on business rules. '+(person.ignoreReason != '' ? ' ' + person.ignoreReason + '.':'');
            }
            if (successMessage == '') {
                successMessage = 'Successfully processed ERPM Person message';
                successDetails = 'Success!';
            }
            
            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                            successMessage, successDetails, contactMessage.Id, LOG_ENTRY_OBJECT, tags);
        }
        catch(Exception ex) {
            System.debug('@@@ Caught Exception');
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            processingStatus = 'Failed';
            processingMessage += ', Further Processing: ' + exceptionMessage;
            //Updating the failed contact status
            updateFailedContact(person,tags,contactMessage,ex);
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                'Error processing ERPM Person message', '', contactMessage.Id, LOG_ENTRY_OBJECT, tags, ex);
        }
        finally{
            System.debug('@@@ finally');
            if(contactMessage != null){
                //Setting status of Inbound Message.
                setInboundMessageStatus(contactMessage.Id,processingStatus,processingMessage,logEntryId,tags,person);
            }
        }
    }
    
    /*
    * description : Validating the email attached in ERPM(Person) message.
    * params : Core_IntegrationUtility.ERPM_Person person
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void personEmailValidation(Core_IntegrationUtility.ERPM_Person person){

        if (person.email.containsIgnoreCase('.duplicate') && (person.email.indexOf('.duplicate') < person.email.indexOf('@'))) {
            person.ignoreMessage = true;
            person.ignoreReason = 'Email address has ".duplicate" ahead of the @ sign';
        }
    }

    /*
    * description : Build up tags used for log entries.
    * params : Core_IntegrationUtility.ERPM_Person person,String tags
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void appendTagsERPMPerson(Core_IntegrationUtility.ERPM_Person person, String tags){
        if (!String.isBlank(person.erpmPersonId)) {
            tags += Core_IntegrationUtility.addTag(person.erpmPersonId);
        }
        if (!String.isBlank(person.enterpriseId)){
            tags += Core_IntegrationUtility.addTag(person.enterpriseId);
        }
        if (!String.isBlank(person.loginId)){
            tags += Core_IntegrationUtility.addTag(person.loginId);
        }
        if (!String.isBlank(person.email)) {
            tags += Core_IntegrationUtility.addTag(person.email);
        }
    }

    /*
    * description : Setting ERPM Engagement from PersonAccount and PersonAccountEngagements and also setting the value for IPAEngagementforMailingaddress.
    * params : Core_IntegrationUtility.ERPM_Person person, String tags, Set<String> erpmAccountSFIds, Set<String> erpmAccountCIMIds, Set<String> erpmAccountNumbers.
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setEnggCollectionsByPerson(Core_IntegrationUtility.ERPM_Person person, String tags, Set<String> erpmAccountSFIds, Set<String> erpmAccountCIMIds, Set<String> erpmAccountNumbers){
        Set<String> erpmEnggCodes = new Set<String>();
        List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs = new List<Core_IntegrationUtility.ERPM_Engagement>();
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            //Iterating through the PersonAccountEngagements and setting the engagement values.
            for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements) {
                if (engg.engagementCode == Label.Core_RDC_Engagement_Code) {
                    isRDCSelfRegistration=true;
                }
                erpmEnggs.add(engg);
                erpmEnggCodes.add(engg.engagementCode);
                if(!STOP_ERPM_SLSCLD_IPA_INTEG && !hasIPAEnggsForMailingAddress){
                    hasIPAEnggsForMailingAddress=Label.IPAEnggsForMailingAddress.split(',').Contains(engg.engagementCode);
                }
                System.debug('@@@@ '+hasIPAEnggsForMailingAddress);
            }
            //Iterating through the PersonAccountRelation and setting value
            for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                if(!ePAR.inactiveIndicator && PRM_ENGGS.Contains(ePAR.engagementCode)){
                    Core_ERPMInboundMessage_IPAContact.erpmAcctEnggCodes.add(ePAR.engagementCode);
                }
            }
            tags += Core_IntegrationUtility.addTag(acct.cimId) + Core_IntegrationUtility.addTag(acct.erpmAccountNumber);
            //Setting ERPM Account Salesforce Id and CIM Id from Person Message.
            setErpmAccountSfIdAndCimId(person,erpmAccountSFIds,erpmAccountCIMIds,erpmAccountNumbers);
        }
        //Iterating through the PersonEngagements and setting the engagements value.
        for (Core_IntegrationUtility.ERPM_Engagement engg : person.personEngagements) {
            erpmEnggs.add(engg);
            erpmEnggCodes.add(engg.engagementCode);
            System.debug('@@@@ '+hasIPAEnggsForMailingAddress);
            if(!STOP_ERPM_SLSCLD_IPA_INTEG && !hasIPAEnggsForMailingAddress){
                hasIPAEnggsForMailingAddress=Label.IPAEnggsForMailingAddress.split(',').Contains(engg.engagementCode);
            }
        }
        //ENTITLEMENT & ERPM ENGAGEMENT RECORD POTENTIAL INSERTS
        Core_IntegrationUtility.insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);
    }

    /*
    * description : Based on condition setting ERPM Subscription from Message.
    * params : Core_IntegrationUtility.ERPM_Person person,List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setERPMSubscription(Core_IntegrationUtility.ERPM_Person person, List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions){
        if(!person.eRPM_Subscriptions.isEmpty()){
            for(Core_IntegrationUtility.eRPM_Subscription subs: person.eRPM_Subscriptions) {
                if(PRM_ENGGS.contains(subs.eRPM_EngagementCode)|| (!SUBSCRIPTION_ALLOWED_PROGRAMS.isEmpty() && SUBSCRIPTION_ALLOWED_PROGRAMS.contains(subs.eRPM_EngagementCode))){
                    eRPM_Subscriptions.add(subs);
                }
            }
        }
    }

    /*
    * description : Getting ERPM Account Salesforce Id and CIM Id from Message.
    * params : Core_IntegrationUtility.ERPM_Person person,Set<String> erpmAccountSFIds,Set<String> erpmAccountCIMIds,Set<String> erpmAccountNumbers
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setErpmAccountSfIdAndCimId(Core_IntegrationUtility.ERPM_Person person, Set<String> erpmAccountSFIds, Set<String> erpmAccountCIMIds, Set<String> erpmAccountNumbers){
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            if(!String.isBlank(acct.acctSalesCloudID)) {
                erpmAccountSFIds.add(acct.acctSalesCloudID);
            }
            else if(!String.isBlank(acct.cimId)) {
                erpmAccountCIMIds.add(acct.cimId);
            }
            erpmAccountNumbers.add(acct.erpmAccountNumber);
        }
    }

    /*
    * description : Setting value to the Matching contact attribute and returning it to update further.
    * params : Core_IntegrationUtility.ERPM_Person person,Contact matchingContact.
    * return : Map<Id,Contact>
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com, hafeezax.shaik@intel.com
    */
    private static Map<Id,Contact> setMatchingContactAttributes(Core_IntegrationUtility.ERPM_Person person, Contact matchingContact){
        Map<Id,Contact> mContactToUpdate = new Map<Id,Contact>();
        if(matchingContact.Core_eRPM_Person_Id__c==person.erpmPersonId || matchingContact.Email==person.email){
            if(person.changeAgentId != 'SalesCloud' && (String.isEmpty(person.loginId) && String.isEmpty(person.enterpriseId) && matchingContact.Core_Login_Status__c!='Deleted' 
                && person.identityStatus=='R' && !String.isBlank(person.deleteStatusReason) && (!String.isBlank(matchingContact.Core_Enterprise_Id__c) || !String.isBlank(matchingContact.Core_Login_Id__c)))){
                   matchingContact.Core_Login_Status__c = 'Deleted';
                   matchingContact.Core_Deletion_Reason__c = person.deleteStatusReason;
                   person.isDeleteIndicator ='Y';
            }

            matchingContact.Core_eRPM_Person_Id__c = !String.isEmpty(person.erpmPersonId) ? person.erpmPersonId : null;
            if(person.changeAgentId != 'SalesCloud' || (!String.isEmpty(person.loginId))) {
                if(person.identityStatus == 'U' || person.identityStatus == 'R'){                
                    matchingContact.Core_Login_Id__c  = null;
                    matchingContact.Core_Enterprise_Id__c = null;
                    matchingContact.External_User_State__c = null;
                    matchingContact.External_User_State_Change_Date_Times__c = null;
                }
                else if(person.identityStatus == 'A' || person.identityStatus == 'D' || person.identityStatus == 'X'){
                    if(!string.isEmpty(matchingContact.Core_Login_Id__c) && !string.isEmpty(matchingContact.Core_Enterprise_Id__c)){
                    	matchingContact.Core_Login_Id__c  = matchingContact.Core_Login_Id__c != person.loginId ? person.loginId : matchingContact.Core_Login_Id__c;
                    	matchingContact.Core_Enterprise_Id__c = matchingContact.Core_Enterprise_Id__c != person.enterpriseId ? person.enterpriseId : matchingContact.Core_Enterprise_Id__c;
            }
                }                               
            }
            if(person.identityStatus == 'U' && !String.isBlank(person.deleteStatusReason) && person.changeAgentId != 'SalesCloud' && !String.isEmpty(person.enterpriseId)
                && matchingContact.Core_Login_Status__c != 'Downgrade to B2C'){
                matchingContact.Core_Login_Status__c   = 'Downgrade to B2C';
                matchingContact.Core_Deletion_Reason__c = person.deleteStatusReason;
                person.isDeleteIndicator ='Y';
            }
            mContactToUpdate.put(matchingContact.Id, matchingContact);
        }
        return mContactToUpdate;
    }

    /*
    * description : Attaching Inbound Message to the Contact.
    * params : Contact matchingContact, Core_Integration_Inbound_Message__c contactMessage
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setContactInboundMessage(Contact matchingContact, Core_Integration_Inbound_Message__c contactMessage){
        Contact_Message__c ContactMsg = new Contact_Message__c(Contact__c = matchingContact.Id, Inbound_Message__c = contactMessage.Id);
        if(//Schema.sObjectType.Contact_Message__c.fields.Inbound_Message__c.isCreateable() &&
        Schema.sObjectType.Contact_Message__c.fields.Contact__c.isCreateable()){
                insert ContactMsg;
            }
    }

    /*
    * description : Getting ContactEntitlement for the Matching Contact.
    * params : Map<Id,List<Core_Contact_Entitlement__c>> matchingContactEntitlementAllMap,Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap,List<Core_Contact_Entitlement__c> ceList,Contact matchingcontact
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void getContactEntitlement(Map<Id,List<Core_Contact_Entitlement__c>> matchingContactEntitlementAllMap, Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap, List<Core_Contact_Entitlement__c> ceList, Contact matchingcontact){
        Map<Id, Core_Contact_Entitlement__c> contactEntitlementMap = new Map<Id, Core_Contact_Entitlement__c>();
        String queryConEntitlementFields = 'Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Engagement_Tier__c, Core_Selected__c, Core_From_Source__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, Core_ERPM_Account_Data__c,'+
        'Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Entitlement_Id__r.Name, Core_Type__c, Core_Update_Reason__c';
    
        contactEntitlementMap = contactQuerySelectorInstance.getContactEntitlements(matchingContact.Id,queryConEntitlementFields);
        if(contactEntitlementMap!=null && contactEntitlementMap.size()>0){
            for(Core_Contact_Entitlement__c ce : contactEntitlementMap.values()){
                ceList = null;
                if (matchingContactEntitlementAllMap.containsKey(ce.Core_Contact_Id__c)){
                    ceList = matchingContactEntitlementAllMap.get(ce.Core_Contact_Id__c);
                }
                else{
                    ceList = new List<Core_Contact_Entitlement__c>();
                }
                ceList.add(ce);
                matchingContactEntitlementAllMap.put(ce.Core_Contact_Id__c, ceList);
                if(''.equalsIgnoreCase(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c) || null == ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c) {
                    ceList = null;
                    if (matchingContactEntitlementEnggMap.containsKey(ce.Core_Contact_Id__c)){
                        ceList = matchingContactEntitlementEnggMap.get(ce.Core_Contact_Id__c);
                    }
                    else{
                        ceList = new List<Core_Contact_Entitlement__c>();
                    }
                    ceList.add(ce);
                    matchingContactEntitlementEnggMap.put(ce.Core_Contact_Id__c, ceList);                   
                }
            }
        }
    }

    /*
    * description : Based on condition Getting Matching Account SalsesforceId.
    * params : Set<String> erpmAccountSFIds,Core_IntegrationUtility.ERPM_Person person,Set<String> erpmAccountCIMIds,Set<String> erpmAccountNumbers,Map<String,Account> matchingAccountMap,Set<String> matchingAccountSFId,String tags
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void getMatchingAccountSFIdAndSFIdFromCIMd(Set<String> erpmAccountSFIds,Core_IntegrationUtility.ERPM_Person person,Set<String> erpmAccountCIMIds,Set<String> erpmAccountNumbers,Map<String,Account> matchingAccountMap,Set<String> matchingAccountSFId,String tags){
        String salesforceId = '';
        if(erpmAccountSFIds.size() > 1) {
            person.ignoreMessage = true;
            person.ignoreReason = 'Contact is part of multiple accounts in eRPM';
            Core_IntegrationOptimization.SendEmail(person.email,'Multiple_Accounts');
        }
        else if(erpmAccountSFIds.size() == 1) {
            salesforceId = new List<String>(erpmAccountSFIds)[0];
            system.debug('salesforceId '+salesforceId);
        }
        else if (erpmAccountSFIds.size() == 0 && !erpmAccountCIMIds.isEmpty()) {
            salesforceId = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(erpmAccountCIMIds,erpmAccountNumbers);
        }
        if(String.isNotBlank(salesforceId)) {
            String queryAccount = 'Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c, Core_CNDA_Number__c';
            Account account = contactQuerySelectorInstance.getAccount(salesforceId,queryAccount);
            if(account!=null && (!matchingAccountMap.containsKey(account.Core_CIM_ID__c))){
                matchingAccountMap.put(account.Core_CIM_ID__c, account);
                matchingAccountSFId.add(account.Id);
                tags += Core_IntegrationUtility.addTag(account.Id);
            }
        }
    }

    /*
    * description : Validating ERPM (Person) Message for matching Contact.
    * params : Contact matchingContact,Core_IntegrationUtility.ERPM_Person person
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void validatePersonMessage(Contact matchingContact,Core_IntegrationUtility.ERPM_Person person){
        if ((matchingContact.Core_eRPM_Person_Id__c != null) && (matchingContact.Core_eRPM_Person_Id__c != person.erpmPersonId)) {
            person.ignoreMessage = true;
            person.ignoreReason = 'Contact was found based on email address, but ERPM Person Id doesn\'t match the message';
        }
        else if (person.publishTimestamp < matchingContact.Core_ERPM_Integration_Publish_Timestamp__c) {
            person.ignoreMessage = true;
            person.ignoreReason = 'Person message was published *before* the last one successfully processed';
        }
    }

    /*
    * description : Setting value to the Matching contact attribute and adding to the collection contactsToUpdate to update the contact record further.
    * params : Contact matchingContact,Core_IntegrationUtility.ERPM_Person person,Set<Id> allAccountIds,List<Contact> contactsToUpdate,Map<String,Account> matchingAccountMap,Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setMatchingContactAttributes(Contact matchingContact, Core_IntegrationUtility.ERPM_Person person, Set<Id> allAccountIds, List<Contact> contactsToUpdate, Map<String,Account> matchingAccountMap, Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap){
        setContactFieldsFromPerson(matchingContact, person);
       /* if(!STOP_ERPM_SLSCLD_IPA_INTEG)
        {
            if(Core_ERPMInboundMessage_IPAContact.erpmAcctEnggCodes.size() > 1 || String.isBlank(matchingContact.Core_IPA_PartnerRole__c)) {
                Core_ERPMInboundMessage_IPAContact.IPA_AddPartnerRole(matchingContact,allAccountIds);
            }
        }*/

        contactsToUpdate.add(matchingContact);

        if(!STOP_ERPM_SLSCLD_IPA_INTEG)
        {
            Core_ERPMInboundMessage_IPAContact.IPA_Subscription(person, matchingAccountMap, acctIdRelationshipsMap,PRM_ENGGS);
        } 
    }

    /*
    * description : Setting attributes of new contact and inserting it.
    * params : Core_IntegrationUtility.ERPM_Person person,Map<String,Account> matchingAccountMap,Contact newContact,Set<Id> allAccountIds,Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap,Id contactId,Id sfAcctId,String queryFields.
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void createContact(Core_IntegrationUtility.ERPM_Person person,Map<String,Account> matchingAccountMap,Contact newContact,Set<Id> allAccountIds,Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation> > acctIdRelationshipsMap,Id contactId,Id sfAcctId,String queryFields){
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            if (matchingAccountMap.containsKey(acct.cimId)) {
                System.debug('##### Found the account based on CIM ID: ' + acct.cimId);
                Id sfAccountId = matchingAccountMap.get(acct.cimId).Id;
                newContact.AccountId = sfAccountId;
                newContact.Core_eRPM_Person_Id__c = person.erpmPersonId;
                newContact.Core_Login_Id__c  = person.loginId;
                newContact.Core_Enterprise_Id__c = person.enterpriseId;  
                setContactFieldsFromPerson(newContact, person);
                if(!STOP_ERPM_SLSCLD_IPA_INTEG)
                {
                    //Core_ERPMInboundMessage_IPAContact.IPA_AddPartnerRole(newContact,sfAccountId, allAccountIds);   
                    Core_ERPMInboundMessage_IPAContact.IPA_AddAcctRelationships(acct, PRM_ENGGS, acctIdRelationshipsMap, matchingAccountMap);  
                }
                break;
            }
            else {
                person.ignoreMessage = true;
                person.ignoreReason = 'Did not find the account based on CIM ID';
            }
        }
        if(String.isNotBlank(newContact.AccountId) && String.isNotBlank(newContact.Core_eRPM_Person_Id__c)){
            if(Schema.sObjectType.Contact.fields.AccountId.isCreateable() &&
            Schema.sObjectType.Contact.fields.Core_eRPM_Person_Id__c.isCreateable() &&
            Schema.sObjectType.Contact.fields.Core_Login_Id__c.isCreateable() &&
            Schema.sObjectType.Contact.fields.Core_Enterprise_Id__c.isCreateable()
            ){

                insert newContact;
            }
            System.debug('@@ Inser Contact'+newContact);
            contactId = newContact.Id;
            sfAcctId = newContact.AccountId;
            newContact = contactQuerySelectorInstance.getContactById(newContact.Id ,queryFields);
            System.debug('newContact $$$@1 '+newContact);
        }
    }

    /*
    * description : Based on RDC Self Registration Check Preparing Contact entitlement to insert.
    * params : Core_IntegrationUtility.ERPM_Person person,Map<String,Contact> insertedContactsMap,List<Core_Contact_Entitlement__c> contactEntitlementsToInsert
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setRDCEntitlement(Core_IntegrationUtility.ERPM_Person person,Map<String,Contact> insertedContactsMap,List<Core_Contact_Entitlement__c> contactEntitlementsToInsert){
        if (Core_ContactEntitlementValidation.validateCNDANum(Label.Core_Entitlement_RDC_Secure_Content_Id,
                                                                          insertedContactsMap.get(person.erpmPersonId)) &&
                        Core_ContactEntitlementValidation.validatePersonalEmailIndicator(Label.Core_Entitlement_RDC_Secure_Content_Id,
                                                                                         insertedContactsMap.get(person.erpmPersonId)))
                    {
                        String erpmAccountData = '';
                        if (!person.personAccounts.isEmpty()) {
                            erpmAccountData = 'ERPM Account Number: ' + person.personAccounts[0].erpmAccountNumber +
                                ', CIM ID: ' + person.personAccounts[0].cimId +
                                ', Account Name: ' + person.personAccounts[0].accountName;
                        }
                        Core_Contact_Entitlement__c ce =
                            new Core_Contact_Entitlement__c(Core_Contact_Id__c=insertedContactsMap.get(person.erpmPersonId).Id, Core_From_Source__c=false, Core_Selected__c=true,
                                                            Core_Entitlement_Id__c=Label.Core_Entitlement_RDC_Secure_Content_Id,
                                                            Core_ERPM_Account_Data__c=erpmAccountData, Core_Data_Loaded__c = true,
                                                            Core_Update_Reason__c = UPDATE_REASON_ERPM);
                        ce.Core_Status__c ='Pending';
                        contactEntitlementsToInsert.add(ce);
                        
                    }
                    else {
                        System.debug('##### RDC validations did not pass, so NOT automatically adding the RDC entitlement record.');
                    }
    }

    /*
    * description : Updating ERPM Integration status of the failed contact.
    * params : Core_IntegrationUtility.ERPM_Person person, String tags, Core_Integration_Inbound_Message__c contactMessage, Exception ex
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void updateFailedContact(Core_IntegrationUtility.ERPM_Person person, String tags, Core_Integration_Inbound_Message__c contactMessage, Exception ex){
            
        String queryfailedContact = 'Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c';
        Contact failedContact = contactQuerySelectorInstance.getContact(person.erpmPersonId,person.email,queryfailedContact);

        if(failedContact != null){
            failedContact.Core_ERPM_Integration_Status__c = 'Failed';
            failedContact.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.failedInboundMessage(contactMessage.Id, ex);
            tags += Core_IntegrationUtility.addTag(failedContact.Id);
            System.debug('##### Updating these contacts to failed: ' + failedContact);

            if(Schema.sObjectType.Contact.fields.Core_ERPM_Integration_Status__c.isUpdateable() &&
            Schema.sObjectType.Contact.fields.Core_ERPM_Integration_Message__c.isUpdateable() ){ 
                update failedContact;
            }
        }
    }

    /*
    * description : Helper method to update our Contact Entitlement collections based on records that need to be inserted or updated.
    * params : List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate,Core_IntegrationUtility.ERPM_Person person,
        Core_IntegrationUtility.ERPM_Engagement engg,Contact c,Set<String> existingContactEngagementCodes,
        Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,
        Map<String,Id> engagementCodeEntitlementIdMap
    */
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
        if (!person.personAccounts.isEmpty()) {
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
        else if (matchingEngagementCodeEntitlementListMap.containsKey(engg.engagementCode)) {
            System.debug('##### Checking this engagement code to see if contact entitlements need to be updated: ' + engg.engagementCode);
            
            for (Core_Contact_Entitlement__c ce : matchingEngagementCodeEntitlementListMap.get(engg.engagementCode)) {
                System.debug('##### Checking this contact entitlement record to see if it needs to be updated: ' + ce);
                
                if ((ce.Core_Engagement_Tier__c != engg.effectiveTierCode) || (ce.Core_Selected__c == false) || (ce.Core_ERPM_Account_Data__c != erpmAccountData))
                {
                    
                    ce.Core_Engagement_Tier__c = engg.effectiveTierCode;
                    ce.Core_ERPM_Account_Data__c = erpmAccountData;
                    
                    if (ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c == null){
                        ce.Core_Selected__c = true;
                    }
                    
                    if(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null && ce.Core_Type__c == 'Entitlement' && Label.ERPMInteg_Entitlements_Allow.split(',').Contains(ce.Core_Entitlement_Id__r.Name)){
                        ce.Core_Selected__c = true;  
                    }
                    contactEntitlementsToUpdate.add(ce);
                }
            }
        }
    }
    
    /*
    * description : Use the Salutation to PersonTitle mapping configuration to determine correct salutation.
    * params : String PersonTitle.
    */
    private static String getSalutation(String PersonTitle) {
        Core_Entitlement_Salutation_PrsTitle_Map__c[] SalutationMap;
        String Result = '';
        if(SalutationMap == null) {
            SalutationMap = Core_Entitlement_Salutation_PrsTitle_Map__c.getall().values();
        }
        if(!SalutationMap.isEmpty()){
            for(Core_Entitlement_Salutation_PrsTitle_Map__c entitSal : SalutationMap){
                if(entitSal.PersonTitle__c == PersonTitle) {
                    Result = entitSal.Salutation__c; break;
                }
            }
        }
        return Result;
    }
    
    /*
    * description : Setting Contact record attribute from ERPM Person.
    * params : Contact c, Core_IntegrationUtility.ERPM_Person person.
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setContactFieldsFromPerson(Contact c, Core_IntegrationUtility.ERPM_Person person) {

        if ((c.Core_eRPM_Person_Id__c == null) || (c.Core_eRPM_Person_Id__c == person.erpmPersonId)) {
            c.Core_Identity_Status__c   = person.identityStatus;
            if(!String.isBlank(c.Core_Enterprise_Id__c) || !String.isBlank(c.Core_Login_Id__c))
            {
                c.Core_Login_Status__c = (person.identityStatus == 'A' ? 'Active' :
                                    person.identityStatus == 'D' ? 'Disabled' :
                                            person.identityStatus == 'X' ? 'Expired' : 
                                    person.identityStatus == 'R' ? 'Deleted' :
                                            person.identityStatus == 'U' ? 'Downgrade to B2C' : '');
            }
            if(!String.isBlank(person.enterpriseId) && String.isBlank(person.deleteStatusReason) && person.identityStatus == 'A' && (c.Core_Login_Status__c == 'Deleted' || c.Core_Login_Status__c == 'Downgrade to B2C')
               && (String.isBlank(c.Core_Enterprise_Id__c)) && (!String.isBlank(c.Core_Deletion_Reason__c)))
            {
                c.Core_Enterprise_Id__c = person.enterpriseId;
                c.Core_Login_Id__c = person.loginId;
                c.Core_Login_Status__c = 'Active';
            }
            c.Core_Deletion_Reason__c = person.deleteStatusReason;
            c.Salutation                = getSalutation(person.title);
            c.FirstName                 = person.firstName;
            c.LastName                  = person.lastName;
            c.Email                     = person.email;
            c.MailingCountryCode        = person.mailingCountry;
            c.MailingStateCode          = person.mailingState;
            c.Core_Preferred_Language__c= person.erpmLanguageCode;
            c.Core_Job_Function_Code__c = person.jobFunctionCode;
            c.Core_Profession__c=person.Profession.Professioncode;
            c.Core_Do_Not_Contact__c    = (person.marketingDoNotContactDate)!=Null ? True: False; 
            c.Core_Marketing_Do_Not_Contact_Dtm__c = (person.marketingDoNotContactDate)!=Null ? person.marketingDoNotContactDate: Null;
            
            c.Core_Sales_Do_Not_Contact_Ind__c    = (person.salesDoNotContactDate)!=Null ? True: False; 
            c.Core_Do_Not_Contact_Dtm__c = (person.salesDoNotContactDate)!=Null ? person.salesDoNotContactDate: Null;
            c.Phone                     = person.phone;
            c.MobilePhone               = person.mobilePhone;
            c.Fax                       = person.fax;
            c.External_User_State_Change_Date_Times__c = person.externalStateChange;
            c.External_User_State__c        = person.externalUserState;
            c.Core_English_Only_First_Name__c =!String.isEmpty(person.englishFirstName) ? person.englishFirstName : c.Core_English_Only_First_Name__c ;
            c.Core_English_Only_Last_Name__c = !String.isEmpty(person.englishLastName) ? person.englishLastName : c.Core_English_Only_Last_Name__c ;
            c.Core_ERPM_Integration_Publish_Timestamp__c = person.publishTimestamp;
            c.Core_IPA_Intel_Last_Login_Date__c = String.isNotBlank(person.lastLoginDate) ?
                Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(person.lastLoginDate) : null;
            c.Core_IPA_Email_Verification_Date__c = String.isNotBlank(person.emailVerificationDate) ?
                Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(person.emailVerificationDate) : null;
            c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.ERPM_Intel_Contact).getRecordTypeId();
            
            if(!STOP_ERPM_SLSCLD_IPA_INTEG && hasIPAEnggsForMailingAddress)
            {
                c.MailingCountry = person.mailingCountry;
            }
        }
    }

    /*
    * description : logic to ignore updating the subscriptions when the Login id and Enterprise Id are null or else update the subscription.
    * params : Map<Id, Contact> updateContactSet1Map,List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions,string eRPMChangeAgentId,Id contactId
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void processContactOnErpmSubscription(Map<Id, Contact> updateContactSet1Map,List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions,string eRPMChangeAgentId,Id contactId){
        Boolean SoftInd = false;
        if(!updateContactSet1Map.IsEmpty()  && !eRPM_Subscriptions.isEmpty()){
            for (Contact Cont :updateContactSet1Map.values()) {
                system.debug('Javo-List on contacts are'+Cont);
                if(Cont.Core_Login_Id__c == null && cont.Core_Enterprise_Id__c == null){
                    SoftInd = true;
                }
            }
        }
        if(!eRPM_Subscriptions.isEmpty()) {
            system.debug('******* Before Insert/Update Subscriptions *******');
            System.enqueueJob(new Core_Integration_Additional_Attributes(null, contactId, null, null, null, eRPM_Subscriptions, null,eRPMChangeAgentId,null));
            system.debug('******** Insert/Update Subscriptions is/are successful ********');
        }
    }

    /*
    * description : Main Method to process Contact Entitltment.
    * params : Core_IntegrationUtility.ERPM_Person person,Map<String,Contact> allContactsMap,Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap,Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap,List<Core_Contact_Entitlement__c> ceList,Map<String,Contact> insertedContactsMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void processContactEntitlement(Core_IntegrationUtility.ERPM_Person person, Map<String,Contact> allContactsMap, Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap, Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap, List<Core_Contact_Entitlement__c> ceList, Map<String,Contact> insertedContactsMap){
        Map<String,Id> engagementCodeEntitlementIdMap = getEntitlement();
        List<Core_Contact_Entitlement__c> contactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate = new List<Core_Contact_Entitlement__c>();
        if (!person.ignoreMessage){
            List<Core_Contact_Entitlement__c> existingContactEntitlements=new List<Core_Contact_Entitlement__c>();
            List<Core_Contact_Entitlement__c> existingContactEntitlementsAll=new List<Core_Contact_Entitlement__c>();
            Contact contactToLookUpEnt = allContactsMap.get(person.erpmPersonId);
            //Preparing contact entitlement to insert and update.
            setContactEntitlement(contactToLookUpEnt,allContactsMap,matchingContactEntitlementEnggMap,existingContactEntitlements,existingContactEntitlementsAll,matchingContactEntitlementAllMap);
            if (person.isDeleteIndicator == 'Y'){
                //if ERPM Soft Delete Add it to collection to update
                getErpmSoftDelContEntitlement(existingContactEntitlementsAll,contactEntitlementsToUpdate);
            }
            else{
                Set<String> existingContactEngagementCodes = new Set<String>();        
                Map<String,Core_Contact_Entitlement__c> matchingEngagementCodeEntitlementMap = new Map<String,Core_Contact_Entitlement__c>();
                Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap = new Map<String,List<Core_Contact_Entitlement__c> >();
                Set<String> erpmEngagements = new Set<String>();
                //Build up a set of all existing ERPM Engagement Codes and a map of ERPM Engagement Code to the Contact Entitlement record corresponding to it.
                setExistContEnggAndMatchEnggCode(existingContactEntitlements,existingContactEngagementCodes,matchingEngagementCodeEntitlementMap);
                //Building up map of ERPM Engagement Code to a list of ALL Contact Entitlement records corresponding to it, with & without roles. 
                setMatchEnggCodeEntitlement(existingContactEntitlementsAll,matchingEngagementCodeEntitlementListMap,ceList);
                for (Core_IntegrationUtility.ERPM_Engagement engg : person.personEngagements) {
                    if(String.IsBlank(engg.effEndEngagmentDate) && engg.engagementStatusCode=='ENGSTSAPRD'){
                        erpmEngagements.add(engg.engagementCode);
                        insertUpdateContactEntitlementLists(contactEntitlementsToInsert, contactEntitlementsToUpdate, person, engg,
                                                            contactToLookUpEnt, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,
                                                            engagementCodeEntitlementIdMap);
                    }
                }
                //Determing the dml operation for the Contact entitlement record
                setInsertUpdateContEnt(person,erpmEngagements,contactEntitlementsToInsert, contactEntitlementsToUpdate,contactToLookUpEnt, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,engagementCodeEntitlementIdMap);
                //Check to see if any engagements were removed and need to be "deselected".
                deSelectContenggRecord(existingContactEngagementCodes,erpmEngagements,ceList,matchingEngagementCodeEntitlementListMap,contactEntitlementsToUpdate);
            }
            if(isRDCSelfRegistration && (insertedContactsMap.get(person.erpmPersonId) != null)) {
                //Based on RDC registration preparing contact entitlement record to insert.
                setRDCEntitlement(person,insertedContactsMap,contactEntitlementsToInsert);
            }
        }
        //Perform DML INSERTs and UPDATEs for Contact Entitlements.
        insertAndUpdateContEnt(contactEntitlementsToInsert,contactEntitlementsToUpdate);
    }

    /*
    * description : Create a new map of all ERPM Engagements to Entitlement IDs in the system.
    * params : NA
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static Map<String,Id> getEntitlement(){
        Map<String,Id> engagementCodeEntitlementIdMap = new Map<String,Id>();
        Map<Id, Core_Entitlement__c> entitlementsMap = new Map<Id, Core_Entitlement__c>();
        String queryEntitlement = 'Id, Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c';
        String andClauseEntitlement = 'Core_ERPM_Engagement_Id__c != null'; 
                
        entitlementsMap = contactQuerySelectorInstance.getEntitlements(queryEntitlement,andClauseEntitlement);
        if(entitlementsMap != null){
            for (Core_Entitlement__c e : entitlementsMap.values())
            {
                engagementCodeEntitlementIdMap.put(e.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, e.Id);
                        
            }
        }
        return engagementCodeEntitlementIdMap;
    }

    /*
    * description : Building up Contact Entitlement to insert and update.
    * params : Contact contactToLookUpEnt,Map<String,Contact> allContactsMap,Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap,List<Core_Contact_Entitlement__c> existingContactEntitlements,List<Core_Contact_Entitlement__c> existingContactEntitlementsAll,Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setContactEntitlement(Contact contactToLookUpEnt, Map<String,Contact> allContactsMap, Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementEnggMap, List<Core_Contact_Entitlement__c> existingContactEntitlements, List<Core_Contact_Entitlement__c> existingContactEntitlementsAll, Map<Id,List<Core_Contact_Entitlement__c> > matchingContactEntitlementAllMap){
        
        if (contactToLookUpEnt == null){
            contactToLookUpEnt = allContactsMap.get(null);
        }
        
        if (contactToLookUpEnt != null && matchingContactEntitlementEnggMap != null && matchingContactEntitlementEnggMap.containsKey(contactToLookUpEnt.Id) &&
            (matchingContactEntitlementEnggMap.get(contactToLookUpEnt.Id) != null)) {
                existingContactEntitlements.addAll(matchingContactEntitlementEnggMap.get(contactToLookUpEnt.Id));
                existingContactEntitlementsAll.addAll(matchingContactEntitlementAllMap.get(contactToLookUpEnt.Id));
        }

    }

    /*
    * description : If ERPM soft delete add in DML collection for UPDATE to "deselected".
    * params : List<Core_Contact_Entitlement__c> existingContactEntitlementsAll,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void getErpmSoftDelContEntitlement(List<Core_Contact_Entitlement__c> existingContactEntitlementsAll,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate){
        if (existingContactEntitlementsAll != null) {
            System.debug('##### ERPM soft delete, so updating contact entitlements to deselected');
            for (Core_Contact_Entitlement__c ce : existingContactEntitlementsAll) {
                ce.Core_Selected__c = false;
                if(ce.Core_From_Source__c == false){
                    ce.Core_Update_Reason__c = UPDATE_REASON_ERPM;
                    ce.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                }
            }
            contactEntitlementsToUpdate.addAll(existingContactEntitlementsAll);
        }
    }

    /*
    * description : Build up a set of all existing ERPM Engagement Codes for this user in the DB already, and a map of ERPM Engagement Code to the Contact Entitlement record corresponding to it.
    * params : List<Core_Contact_Entitlement__c> existingContactEntitlements,Set<String> existingContactEngagementCodes,Map<String,Core_Contact_Entitlement__c> matchingEngagementCodeEntitlementMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setExistContEnggAndMatchEnggCode(List<Core_Contact_Entitlement__c> existingContactEntitlements,Set<String> existingContactEngagementCodes,Map<String,Core_Contact_Entitlement__c> matchingEngagementCodeEntitlementMap){
        if (existingContactEntitlements != null) {
            for (Core_Contact_Entitlement__c ce : existingContactEntitlements) {
                String engagementCode = ce.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                existingContactEngagementCodes.add(engagementCode);
                matchingEngagementCodeEntitlementMap.put(engagementCode, ce);
            }
        }
    }

    /*
    *description : Continue building our set of all existing ERPM Engagement Codes for this user in the DB already, and a map of ERPM Engagement Code to a list of ALL Contact Entitlement records corresponding to it, with & without roles.
    * params : List<Core_Contact_Entitlement__c> existingContactEntitlementsAll,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,List<Core_Contact_Entitlement__c> ceList
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setMatchEnggCodeEntitlement(List<Core_Contact_Entitlement__c> existingContactEntitlementsAll,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,List<Core_Contact_Entitlement__c> ceList){
        if (existingContactEntitlementsAll != null){
            for (Core_Contact_Entitlement__c ce : existingContactEntitlementsAll) {
                                
                String engagementCode = ce.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                
                if (matchingEngagementCodeEntitlementListMap.containsKey(engagementCode)){
                    ceList = matchingEngagementCodeEntitlementListMap.get(engagementCode);
                }
                else{
                    ceList = new List<Core_Contact_Entitlement__c>();
                }
                ceList.add(ce);
                matchingEngagementCodeEntitlementListMap.put(engagementCode, ceList);
            }
        }
    }

    /*
    *description : Determine whether Insert or update needed and placed in DML collection.
    * params : Core_IntegrationUtility.ERPM_Person person,Set<String> erpmEngagements,List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate,Contact contactToLookUpEnt,
                Set<String> existingContactEngagementCodes,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,Map<String,Id> engagementCodeEntitlementIdMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setInsertUpdateContEnt(Core_IntegrationUtility.ERPM_Person person,Set<String> erpmEngagements,List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate,Contact contactToLookUpEnt,
                                               Set<String> existingContactEngagementCodes,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,Map<String,Id> engagementCodeEntitlementIdMap){
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            for (Core_IntegrationUtility.ERPM_Person_Account_Relation relation : acct.personAccountRelations) {
                System.debug('##### Checking this ERPM person account relation engg code to see if insert/update needed: ' + relation.engagementCode);
                
                if (!erpmEngagements.contains(relation.engagementCode) && !relation.inactiveIndicator && relation.engagementStatusCode=='ENGSTSAPRD') {
                    
                    erpmEngagements.add(relation.engagementCode);
                    
                    Core_IntegrationUtility.ERPM_Engagement engg = new Core_IntegrationUtility.ERPM_Engagement();
                    engg.engagementCode = relation.engagementCode;
                    engg.engagementName = relation.engagementName;
                    engg.engagementStatusCode = relation.engagementStatusCode;
                    engg.effectiveTierCode = relation.effectiveTierCode;
                    
                    insertUpdateContactEntitlementLists(contactEntitlementsToInsert, contactEntitlementsToUpdate, person, engg,
                                                        contactToLookUpEnt, existingContactEngagementCodes, matchingEngagementCodeEntitlementListMap,
                                                        engagementCodeEntitlementIdMap);
                }
            }
        }
    }

    /*
    *description : Check to see if any engagements were removed and need to be "deselected".
    * params : Set<String> existingContactEngagementCodes,Set<String> erpmEngagements,List<Core_Contact_Entitlement__c> ceList,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void deSelectContenggRecord(Set<String> existingContactEngagementCodes,Set<String> erpmEngagements,List<Core_Contact_Entitlement__c> ceList,Map<String,List<Core_Contact_Entitlement__c> > matchingEngagementCodeEntitlementListMap,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate){
        for (String existingContactEngagementCode : existingContactEngagementCodes) {
            if (!erpmEngagements.contains(existingContactEngagementCode)) {
                ceList = matchingEngagementCodeEntitlementListMap.get(existingContactEngagementCode);
                for (Core_Contact_Entitlement__c ce : ceList) {
                    if (ce.Core_From_Source__c) {
                        ce.Core_Selected__c = false;
                        contactEntitlementsToUpdate.add(ce);
                        System.debug('##### Deselecting contact engagement record: ' + ce);
                    }
                }
            }
        }
    }

    /*
    *description : Perform DML INSERTs and UPDATEs for Contact Entitlements.
    * params : List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void insertAndUpdateContEnt(List<Core_Contact_Entitlement__c> contactEntitlementsToInsert,List<Core_Contact_Entitlement__c> contactEntitlementsToUpdate){
        List<Database.SaveResult> lstErrorsFromPartialProcessing = new List<Database.SaveResult>();    
        SavePoint sp = Database.setSavepoint();
        boolean isRollBack = false;
        if (!contactEntitlementsToInsert.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(contactEntitlementsToInsert, false);
            System.debug('Zay - SaveResult List - ' + srList);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()) {
                        lstErrorsFromPartialProcessing.add(sr);
                        for(Database.Error er : sr.getErrors()) {
                            if(er.getMessage().contains('duplicate value found: Core_Unique_Id__c duplicates value on record with id')) {
                            } 
                            else {
                                Database.rollback(sp);
                                isRollBack = true;
                            }
                        }
                    }
                }
            if(isRollBack) {
                insert contactEntitlementsToInsert;
            }
        }
        if (!contactEntitlementsToUpdate.isEmpty()) {
            update contactEntitlementsToUpdate;
        }
    }

    /*
    *description : Setting Inbound Message status.
    * params : String contactMessageId,String processingStatus, String processingMessage,Id logEntryId,String tags,Core_IntegrationUtility.ERPM_Person person
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    private static void setInboundMessageStatus(String contactMessageId,String processingStatus, String processingMessage,Id logEntryId,String tags,Core_IntegrationUtility.ERPM_Person person){
        String queryInboundMsg = 'Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c, Core_Publish_Timestamp__c';
        Core_Integration_Inbound_Message__c inboundMsg = contactQuerySelectorInstance.getInboundMsg(contactMessageId,queryInboundMsg);
        if(inboundMsg != null){
            inboundMsg.Core_Processing_Status__c = processingStatus;
            inboundMsg.Core_Exception_Message__c = processingMessage;
            inboundMsg.Core_Log_Entry__c = logEntryId;
            inboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
            inboundMsg.Core_Publish_Timestamp__c = person.publishTimestamp;
            if(Schema.sObjectType.Core_Integration_Inbound_Message__c.fields.Core_Processing_Status__c.isUpdateable() &&
            Schema.sObjectType.Core_Integration_Inbound_Message__c.fields.Core_Exception_Message__c.isUpdateable() &&
            Schema.sObjectType.Core_Integration_Inbound_Message__c.fields.Core_Log_Entry__c.isUpdateable() &&
            //Schema.sObjectType.Core_Integration_Inbound_Message__c.fields.Core_Tags__c.isUpdateable() && 
            Schema.sObjectType.Core_Integration_Inbound_Message__c.fields.Core_Publish_Timestamp__c.isUpdateable()){
                update inboundMsg;
            }
        }
    }

    /*
    * Description  : This Method is used to disable the Partner user for Soft and Hard delete operation based on ERPM Message.
    * Return Type  : void
    * Parameter    : List<String> PartnerContactId
    * This future Method is used to do avoid the Mixed DML operations setup and non setup Object.
    */
    @future
    public static void DisablePartnerPortalUser(List<String> PartnerContactId){
        list<user> Partneruserlist=new list <user>();
        list<user> PartneruserlistUpdate=new list <user>();
        Boolean CustomsettingEnable=false;
        Partneruserlist=[select id,IsPortalEnabled,ContactId,contact.Core_Tokenized__c,contact.Core_Login_Status__c,IsActive from user where ContactId in: PartnerContactId];
        if(Partneruserlist != null && !(Partneruserlist.isEmpty())) {
            try{
                Core_IPS_Run_Rules_Exception_Cust_Partne__c IPSOrgId= Core_IPS_Run_Rules_Exception_Cust_Partne__c.getOrgDefaults();  
                if(Core_IPS_Run_Rules_Exception_Cust_Partne__c.getOrgDefaults().Run_Validation_Rule__c) {   
                    IPSOrgId.Run_Validation_Rule__c=false; 
                    Update IPSOrgId;
                    CustomsettingEnable=true;
                }
                for(user us:Partneruserlist) {
                    if(us.contact.Core_Tokenized__c==True && us.contact.Core_Login_Status__c=='Disabled' && us.IsPortalEnabled==True) { 
                        us.IsPortalEnabled=false;
                        us.IsActive=false;
                        PartneruserlistUpdate.add(us);
                    }
                    if(us.contact.Core_Tokenized__c==False && us.contact.Core_Login_Status__c=='Deleted' && us.IsActive==True) { 
                        
                        PartneruserlistUpdate.add(us);
                    }
                }
                if(PartneruserlistUpdate != null && !(PartneruserlistUpdate.isEmpty())) {
                    update PartneruserlistUpdate;
                    if(CustomsettingEnable) {
                        IPSOrgId.Run_Validation_Rule__c=true; 
                            Update IPSOrgId;
                        
                    }
                }
            }catch(Exception e) {
            }
        }
    }
}