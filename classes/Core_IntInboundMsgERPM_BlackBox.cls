/******************************************************************************************************************************************
* Class Name  : Core_IntInboundMsgERPM_BlackBox
* Version     : 1.0
* Created Date: 30 May 2017
* Function    : Business logic for processing inbound ERPM messages
*
* Modification Log :
* Developer                 Date          Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016    Original version
* Team: popcorn Apps        30/05/2017    New class created from Core_IntegrationInboundMsgERPM with a single method processBlackboxMessages
*                                         Changes: Code clean up and reorganize
* Aran Wongsaprome          8/29/2017     Associate inbound message to applicable contact. Cleanup.
*****************************************************************************************************************************************/
public class Core_IntInboundMsgERPM_BlackBox{
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
    
    // Main method for processing ERPM Blackbox messages
    public static void processBlackboxMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        // Note: currently we have a single status for the whole batch, which all records will be set to. This is fine
        // for now, since iPaaS won't be sending batches. But goal state should be to have separate status per message. 
        String processingStatus = 'Successful';
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        Set<Id> msgIds = new Set<Id>();
        
        List<Core_IntegrationUtility.ERPM_Blackbox_Response> bbResponses =  new List<Core_IntegrationUtility.ERPM_Blackbox_Response>();
        Set<String> erpmPersonIds = new Set<String>();
        Set<String> erpmEmails = new Set<String>();
        
        Map<Id, Core_IntegrationUtility.ERPM_Blackbox_Response> ibMsgRespErrorMap = new Map<Id, Core_IntegrationUtility.ERPM_Blackbox_Response>();
        // Build up "tags" to add to log entry/inbound message
        String tags = '';
        Set<Id> matchingContactIds = new Set<Id>();
        Map<String,Contact> matchingContactERPMIdMap = new Map<String,Contact>();
        Map<String,Contact> matchingContactEmailMap = new Map<String,Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = new List<Core_Integration_Inbound_Message__c>();
      
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET PERSON ID/EMAIL VALUES FOR FUTURE CONTACT LOOKUP
        
        for (Core_Integration_Inbound_Message__c msg : newList) {
            
            // Only process messages inserted/updated as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (Core_IntegrationUtility.getFullPayload(msg) != null)) {      // Used to concatinate All Payload fields method 
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of blackbox responses
                    Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse = Core_IntegrationInboundMessageParsing.parseBlackboxResponse(Core_IntegrationUtility.getFullPayload(msg));
         
                    System.debug('##### ERPM Blackbox response message parsed into an object: ' + bbResponse);
                    
                    bbResponses.add(bbResponse);
                    
                    if (!String.isblank(bbResponse.PersonID)) {
                        erpmPersonIds.add(bbResponse.PersonID);
                        tags += Core_IntegrationUtility.addTag(bbResponse.PersonID);
                    }
                    if (!String.isblank(bbResponse.EnterpriseID)) {
                        tags += Core_IntegrationUtility.addTag(bbResponse.EnterpriseID);
                    }
                    if (!String.isblank(bbResponse.LoginID)) {
                        tags += Core_IntegrationUtility.addTag(bbResponse.LoginID);
                    }
                    if (!String.isblank(bbResponse.EmailID)) {
                        erpmEmails.add(bbResponse.EmailID);
                        tags += Core_IntegrationUtility.addTag(bbResponse.EmailID);
                    }
                    if (bbResponse.Accounts != null) {
                        for (Core_IntegrationUtility.ERPM_Blackbox_Account bbAccount : bbResponse.Accounts) {
                            tags += Core_IntegrationUtility.addTag(bbAccount.AccountNumber) + Core_IntegrationUtility.addTag(bbAccount.CIMID) + Core_IntegrationUtility.addTag(bbAccount.SalesCloudID);
                        }
                    }
                    ibMsgRespErrorMap.put(msg.Id, bbResponse);
                }
                catch(Exception ex) {
                    processingStatus = 'Failed';
                    processingMessage += ', ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
                    
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
            for (Contact c : [select Id, Email, Core_eRPM_Person_Id__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, Core_Enterprise_Id__c from Contact where Core_eRPM_Person_Id__c in :erpmPersonIds or Email in :erpmEmails]) {
                matchingContactIds.add(c.Id);
                matchingContactERPMIdMap.put(c.Core_eRPM_Person_Id__c, c);
                matchingContactEmailMap.put(c.Email, c);
                tags += Core_IntegrationUtility.addTag(c.Id);
            }
            
            // Associate the inbound messages to the contacts
            List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
            for(Id mid : ibMsgRespErrorMap.keySet()) {
                Core_IntegrationUtility.ERPM_Blackbox_Response r = ibMsgRespErrorMap.get(mid);
                Contact c = matchingContactERPMIdMap.get(r.PersonID); 
                if(c == null) c = matchingContactEmailMap.get(r.EmailID);
                if(c != null) ContactMsg.add(new Contact_Message__c(Contact__c = c.id, Inbound_Message__c = mid));
            }
            insert ContactMsg;
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD UPDATES
            
            // Loop through the Blackbox responses we're processing
            for (Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse : bbResponses) {
                
                System.debug('##### Operating on this blackbox response message to check for contact record updates: ' + bbResponse);
                
                if (matchingContactERPMIdMap.containsKey(bbResponse.PersonID) || matchingContactEmailMap.containsKey(bbResponse.EmailID)) {
                    
                    // Get Contact that corresponds to this Blackbox response, by Person ID if possible, otherwise Email
                    Contact c = matchingContactERPMIdMap.containsKey(bbResponse.PersonId) ? matchingContactERPMIdMap.get(bbResponse.PersonId) : matchingContactEmailMap.get(bbResponse.EmailID);
                    
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
            processingStatus = 'Failed';
            processingMessage += ', ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
            
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Blackbox message', '', newList[0].Id, LOG_ENTRY_OBJECT, tags, ex);
        }
        
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
           
        
        for (Core_Integration_Inbound_Message__c msg : [select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c
            from Core_Integration_Inbound_Message__c where Id in :msgIds]) {
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
            messagesToUpdate.add(msg);
        }
        if(messagesToUpdate.size()>0){
            update messagesToUpdate;    
        }
        
    }
     
 }