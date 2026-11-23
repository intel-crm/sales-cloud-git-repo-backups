/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMsgERPM_Account
Version     : 1.0
Created Date: 31 May 2017
Function    : Business logic for processing inbound ERPM messages

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016              Original version
* Team: popcorn Apps        31/05/2017              New class created from Core_IntegrationInboundMsgERPM with a single method processAccountMessages
                                                    Changes: Code clean up and reorganize

*****************************************************************************************************************************************/
public class Core_IntInboundMsgERPM_Account{
    
    //public static final String B2B_DEDUP_GROUP_CODE = 'DEDUPB2B';Moved to Custom Label
    //public static final String RDC_ACCOUNT_INDUSTRY = 'Others';Moved to Custom Label            // TO DO: finalize this with Jordan
    //public static final String RDC_ACCOUNT_TYPE = 'Other';Moved to Custom Label                 // TO DO: finalize this with Jordan
   // public static final String RDC_ACCOUNT_SALES_GROUP = 'Regional Sales';Moved to Custom Label // TO DO: finalize this with Jordan
    //public static final String RDC_ENGAGEMENT_CODE = 'IRDC_Priv';Moved to Custom Label
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
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
            if ((msg.Core_Processing_Status__c == 'Pending') && (Core_IntegrationUtility.getFullPayload(msg)!= null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of erpmPersons
                    Core_IntegrationUtility.ERPM_Account acct =
                        Core_IntegrationInboundMessageParsing.parseAccount(Core_IntegrationUtility.getFullPayload(msg));
                    System.debug('##### ERPM Account message parsed into an object: ' + acct);
                    
                    erpmAccounts.add(acct);
                    
                    // Save the necessary ID values into collections that we'll need in upcoming SELECT statements
                    if (!String.isBlank(acct.sfdcId)) {
                        erpmAccountIds.add(acct.sfdcId);
                        tags += Core_IntegrationUtility.addTag(acct.sfdcId);
                    }
                    if (!String.isBlank(acct.cimId)) {
                        erpmCIMIds.add(acct.cimId);
                        tags += Core_IntegrationUtility.addTag(acct.cimId);
                    }
                    if (!String.isBlank(acct.erpmAccountNumber)) {
                        tags += Core_IntegrationUtility.addTag(acct.erpmAccountNumber);
                    }
                    
                    for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
                        erpmEnggs.add(engg);
                        erpmEnggCodes.add(engg.engagementCode);
                    }
                }
                catch(Exception ex) {
                    
                    processingStatus = 'Failed';
                    processingMessage += ', Message 3: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
                    
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
                        
                        if (acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE)
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
                    if (acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE) {
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
            
            Core_IntegrationUtility.insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);
            
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
            processingStatus = 'Failed';
            processingMessage += ', Message 4: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Account message', '', newList[0].Id,
                                                              LOG_ENTRY_OBJECT, tags, ex);
        }
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
     
        // Update Processing Status to "Successful" or "Failed" depending on above
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = new List<Core_Integration_Inbound_Message__c>();
        
        for (Core_Integration_Inbound_Message__c msg : [select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c
            from Core_Integration_Inbound_Message__c where Id in :msgIds]) {
            msg.Core_Processing_Status__c = processingStatus;
            msg.Core_Exception_Message__c = processingMessage;
            msg.Core_Log_Entry__c = logEntryId;
            msg.Core_Tags__c = tags;
            messagesToUpdate.add(msg);
        }
        
        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        if(messagesToUpdate.size()>0){
            update messagesToUpdate;
        }
    }    
         // Copy info from an ERPM Account record into an Account (for RDC self-registration)
      public static Account getAccountFromERPMAccount(Core_IntegrationUtility.ERPM_Account acct) {
        
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
        a.Industry             = Label.Core_RDC_ACCOUNT_INDUSTRY;
        a.Core_Account_Type__c = Label.Core_RDC_ACCOUNT_TYPE;
        a.Core_Sales_Group__c  = Label.Core_RDC_ACCOUNT_SALES_GROUP;
        system.debug('a Ref========>'+a);
        return a;
    }
    // Helper method to determine, based on an ERPM Account record, whether or not it's RDC self-registration
    private static Boolean isRDCSelfRegistration(Core_IntegrationUtility.ERPM_Account acct) {
        
        for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
            system.debug('####engg.engagementCode:'+engg.engagementCode);
            if (engg.engagementCode == Label.Core_RDC_Engagement_Code)//if (engg.engagementCode == RDC_ENGAGEMENT_CODE)
                return true;
        }
        return false;
    }
    
   }