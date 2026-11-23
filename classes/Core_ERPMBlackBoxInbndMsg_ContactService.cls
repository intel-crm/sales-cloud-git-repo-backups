public class Core_ERPMBlackBoxInbndMsg_ContactService {
    
    private static final String LOG_ENTRY_ORIGIN = 'SFDC';
    private static final String LOG_ENTRY_PROJECT = 'Entitlement';
    private static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageERPM';
    private static final String LOG_ENTRY_ERROR = 'error';
    private static final String LOG_ENTRY_INFO = 'info';
    private static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    private static Core_InboundContactSelectorContracts.IContactQuerySelector contactQuerySelectorInstance =  Core_InboundContactQuerySelector.getInstance();
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}

    public static void processBlackboxMessages(Core_Integration_Inbound_Message__c blackBoxMessage) {
        Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse =  new Core_IntegrationUtility.ERPM_Blackbox_Response();
        String processingStatus = 'Successful';
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        String tags = '';

        String fullPayload = Core_IntegrationUtility.getFullPayload(blackBoxMessage);
        if((blackBoxMessage.Core_Processing_Status__c == 'Pending') && (fullPayload != null)){
            try {
                bbResponse = Core_IntegrationInboundMessageParsing.parseBlackboxResponse(fullPayload);
                appendTagsBlackBoxResponse(bbResponse,tags);
            }
            catch(Exception ex) {
                processingStatus = 'Failed';
                processingMessage += ', ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);    
                logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error reading ERPM Blackbox message', '', blackBoxMessage.Id, LOG_ENTRY_OBJECT, '', ex);
            }
        }
        try {
            if ((String.isBlank(bbResponse.PersonID)) && (String.isBlank(bbResponse.EmailID))) {
                throw new CustomException('Blackbox response message must contain an ERPM Person ID or Email address.');
            }
            String queryFields = 'Id, Email, Core_eRPM_Person_Id__c, Core_ERPM_Integration_Queue_txt__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, Core_Login_Id__c, Core_Enterprise_Id__c';
            Contact matchingContact = contactQuerySelectorInstance.getContact(bbResponse.PersonID,bbResponse.EmailID,queryFields);
            if(matchingContact != null){
                setContactInboundMessage(matchingContact, blackBoxMessage);
                if (bbResponse.Status == 'Success') {
                    matchingContact.Core_ERPM_Integration_Status__c = 'Successful';
                    matchingContact.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.successfulInboundMessage(blackBoxMessage.Id);
                    matchingContact.Core_Enterprise_Id__c = String.isEmpty(matchingContact.Core_Enterprise_Id__c) ? bbResponse.EnterpriseID : matchingContact.Core_Enterprise_Id__c;
                    matchingContact.Core_Login_Id__c = String.isEmpty(matchingContact.Core_Login_Id__c) ? bbResponse.LoginID : matchingContact.Core_Login_Id__c;
                    matchingContact.Core_eRPM_Person_Id__c = String.isEmpty(matchingContact.Core_eRPM_Person_Id__c) ? bbResponse.PersonID : matchingContact.Core_eRPM_Person_Id__c;
                }
                else if (bbResponse.Status == 'Failure') {
                    matchingContact.Core_ERPM_Integration_Status__c = 'Failed';
                    matchingContact.Core_ERPM_Integration_Message__c = Core_IntegrationUtility.failedInboundMessage(
                    blackBoxMessage.Id, bbResponse.ErrorCode, bbResponse.ErrorText, bbResponse.ErrorDetails);
                }

                if (matchingContact.Core_ERPM_Integration_Queue_txt__c == 'Full') {
                    matchingContact.Core_ERPM_Integration_Queue_txt__c = 'Empty';
                    matchingContact.Core_ERPM_Integration_Status__c = 'Pending';
                }
                update matchingContact;
                logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                                'Successfully processed ERPM Blackbox message',
                                                                'Success!', blackBoxMessage.Id, LOG_ENTRY_OBJECT, tags);
            }
        }
        catch(Exception ex) {
            processingStatus = 'Failed';
            processingMessage += ', ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
            'Error processing ERPM Blackbox message', '', blackBoxMessage.Id, LOG_ENTRY_OBJECT, tags, ex);
        }
        finally {
            if(blackBoxMessage!=null){
                setInboundMessageStatus(blackBoxMessage.Id,processingStatus,processingMessage,logEntryId,tags,bbResponse);
            }
        }
    }

    private static void appendTagsBlackBoxResponse(Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse, String tags){
        if (!String.isblank(bbResponse.PersonID)) {
            //erpmPersonIds.add(bbResponse.PersonID);
            tags += Core_IntegrationUtility.addTag(bbResponse.PersonID);
        }
        if (!String.isblank(bbResponse.EnterpriseID)) {
            tags += Core_IntegrationUtility.addTag(bbResponse.EnterpriseID);
        }
        if (!String.isblank(bbResponse.LoginID)) {
            tags += Core_IntegrationUtility.addTag(bbResponse.LoginID);
        }
        if (!String.isblank(bbResponse.EmailID)) {
            //erpmEmails.add(bbResponse.EmailID);
            tags += Core_IntegrationUtility.addTag(bbResponse.EmailID);
        }
        if (bbResponse.Accounts != null) {
            for (Core_IntegrationUtility.ERPM_Blackbox_Account bbAccount : bbResponse.Accounts) {
                tags += Core_IntegrationUtility.addTag(bbAccount.AccountNumber) + Core_IntegrationUtility.addTag(bbAccount.CIMID) + Core_IntegrationUtility.addTag(bbAccount.SalesCloudID);
            }
        }
    }
    private static void setContactInboundMessage(Contact matchingContact, Core_Integration_Inbound_Message__c blackBoxMessage){
        Contact_Message__c ContactMsg = new Contact_Message__c(Contact__c = matchingContact.Id, Inbound_Message__c = blackBoxMessage.Id);
        insert ContactMsg;
    }
    private static void setInboundMessageStatus(String blackBoxMessageId,String processingStatus, String processingMessage,Id logEntryId,String tags,Core_IntegrationUtility.ERPM_Blackbox_Response bbResponse){
        String queryInboundMsg = 'Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c';
        Core_Integration_Inbound_Message__c inboundMsg = contactQuerySelectorInstance.getInboundMsg(blackBoxMessageId,queryInboundMsg);
        if(inboundMsg!=null){
            inboundMsg.Core_Processing_Status__c = processingStatus;
            inboundMsg.Core_Exception_Message__c = processingMessage;
            inboundMsg.Core_Log_Entry__c = logEntryId;
            inboundMsg.Core_Tags__c = tags;
            if(bbResponse != null && String.isNotBlank(bbResponse.ErrorCode)){
                inboundMsg.Core_Error_Code__c = bbResponse.ErrorCode;
                String codeWithErrorDesc = bbResponse.ErrorText + ' Details : '+bbResponse.ErrorDetails;
                codeWithErrorDesc = ( String.isNotBlank(codeWithErrorDesc) &&  codeWithErrorDesc.length() > 254 ) ? codeWithErrorDesc.substring(0, 254) : codeWithErrorDesc;
                inboundMsg.Core_Error_Description__c = codeWithErrorDesc;
            }
            update inboundMsg;
        }
    }
}