/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMessageAGS
Version     : 1.0
Created Date: 30 NOV 2016
Function    : Business logic for processing inbound AGS messages

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/30/2016              Original version
* Team : PopcornApps        05/25/2016              Re organized the code
* Aran Wongsaprome          09/07/2017              US71628 Related list of messages under contact
*****************************************************************************************************************************************/

public class Core_IntegrationInboundMessageAGS {
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    public static final String AGS_RESPONSE ='AGS Response';
    public static Boolean retryInboundMessageProcessing = false;
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
   
    // Main method for processing AGS messages
    public static void processMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        Id logEntryId = null;
        Map<Id, InBoundMessageWrapper> mIbMsgWrpr = new Map<Id,InBoundMessageWrapper>();
        Set<String> agsEnterpriseIds = new Set<String>();
        Map<String,InBoundMessageWrapper> agsEnterpriseIdResponseMap = new Map<String,InBoundMessageWrapper>();
        
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET ENTERPRISE ID VALUES FOR FUTURE CONTACT LOOKUP
        for (Core_Integration_Inbound_Message__c msg : newList) {
            InBoundMessageWrapper ib = null;
            // Only process messages inserted/updated as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (msg.Core_Payload__c != null)) {
                // Constructor parses the payload into an object, then sets into wrapper class variable
                ib = new InBoundMessageWrapper();
                ib.setMessage(msg);
                agsEnterpriseIdResponseMap.put(ib.enterpriseId, ib);//NOTE - inbound messaege is always getting overwritten, IPASS is not going to send bulk messages
                mIbMsgWrpr.put(msg.id, ib);                    
                    
                System.debug(' +++ mIbMsgWrpr '+mIbMsgWrpr);
            }
        }
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL MATCHING CONTACT RECORDS, TO UPDATE
        try {
            
            agsEnterpriseIds = getEnterpriseIds(mIbMsgWrpr);
            // We need at least a Enterprise ID. If we don't have one, the next SOQL statement will throw an
            // exception only when run in an actual org, not in our test classes. So let's throw one explicitly instead.
            if ((agsEnterpriseIds.size() == 0) || ((agsEnterpriseIds.size() == 1) && (agsEnterpriseIds.contains('')))) 
            {
                throw new CustomException('AGS response message must contain an Enterprise ID.');
            }
            
            // Pull all matching Contacts, by Enterprise ID
            List<Contact> matchingContacts = [ select Id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Email,
                                              Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,  
                                              (select Id, Name, Core_Entitlement_Id__c, Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_AGS_Role_Id__c, 
                                               Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, Core_Status__c, Core_Selected__c FROM  Contact_Entitlements__r)
                                              FROM Contact
                                              where Core_Enterprise_Id__c in :agsEnterpriseIds];
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD UPDATES
            
            //Maps Holds the existing contact entitlements for the contact <Ags RoleName, contact entitlement> 
            Map<String, Core_Contact_Entitlement__c> mCurrSfAgsRole_ContEnt = null;
            Set<Core_Contact_Entitlement__c> sUpdateContEnt = new Set<Core_Contact_Entitlement__c> ();
            
            //For creating the new missing entitlemnets thats existins in AGS
            Map<Contact,Set<String>> mMissingEntitlements = new Map<Contact,Set<String>> ();
            
            //Set of Ags Role Names
            Set<String> sAgsRoleNames = null;
            Map<Id, Contact> mRetriggerContactAGS = new Map<id, Contact>();
            List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();

            for (Contact c : matchingContacts) {
                InBoundMessageWrapper ibMsgWrpr = null;
                //Changes PopcornApps START
                mCurrSfAgsRole_ContEnt = new Map<String, Core_Contact_Entitlement__c>();
                sAgsRoleNames = new Set<String> ();
                Map<Id, ContactEntitlementWrapper> existingContEntWrapper = new Map<Id, ContactEntitlementWrapper>();
                
                for(Core_Contact_Entitlement__c ce : c.Contact_Entitlements__r){
                    mCurrSfAgsRole_ContEnt.put(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, ce);
                    existingContEntWrapper.put(ce.Id, new ContactEntitlementWrapper(false, ce));
                }
                
                System.debug(' +++++++++++++++++++ mCurrSfAgsRole_ContEnt '+mCurrSfAgsRole_ContEnt);
                System.debug(' +++++++++++++++++++ mMissingEntitlements '+mMissingEntitlements);
                //Changes PopcornApps END
                
                if (agsEnterpriseIdResponseMap.containsKey(c.Core_Enterprise_Id__c)) {
                    
                    //Inbound Message object with additional enacapsulated properties
                    ibMsgWrpr = agsEnterpriseIdResponseMap.get(c.Core_Enterprise_Id__c);
                    ContactMsg.add(new Contact_Message__c(Contact__c = c.id, Inbound_Message__c = ibMsgWrpr.message.id));
                    
                    //Append tags to inboundMessage tags
                    ibMsgWrpr.tags += addTag(c.Id)+addTag(c.Core_eRPM_Person_Id__c)+addTag(c.Email);
                    
                    Core_IntegrationUtility.AGS_Response agsResponse = ibMsgWrpr.agsResponse;
                    system.debug(' +++++++++++ agsResponse '+agsResponse);
                    
                    List<Core_IntegrationUtility.AGS_Response_Role> result = agsResponse.result;
                    
                    if (result != null) {
                        
                        for (Core_IntegrationUtility.AGS_Response_Role responseRole : result) {
                            String errorDescription = null;
                            String roleName = responseRole.roleName;
                            Core_IntegrationUtility.AGS_Response_Role_Result roleResult = responseRole.roleResult;
                            
                            ibMsgWrpr.integrationMessage += '\r\nRole: ' + roleName + ' Operation: ' + roleResult.operation + ' Status: ';
                            
                            if (roleResult.status == 'success') {
                                ibMsgWrpr.integrationMessage += 'Success';
                                
                            }else if (roleResult.status == 'failed') {
                                ibMsgWrpr.integrationStatus = 'Failed';
                                ibMsgWrpr.integrationMessage += 'Failed';
                                for (Core_IntegrationUtility.AGS_Response_Error err : roleResult.Errors) {
                                    ibMsgWrpr.integrationMessage += ', Error code: ' + err.code +
                                        ', Description: ' + err.description +
                                        ', System Message: ' + err.sourceSystemMessage + '. ';
                                    errorDescription = err.description;
                                    errorDescription = ( (errorDescription != null && errorDescription.length() > 255) ? errorDescription.substring(0, 255) : errorDescription);
                                    
                                }
                            }
                            
                            // Process the AGS response and updat the contact entitlement status accordinly
                            //Changes PopcornApps START
                            Core_Contact_Entitlement__c ce = mCurrSfAgsRole_ContEnt.get(roleName.trim());
                            Boolean isSuccess = 'success'.equalsIgnoreCase(roleResult.status);
                            Boolean isAssigned =  'complete'.equalsIgnoreCase(roleResult.workflowStatus) && 'assignUserRole'.equalsIgnoreCase(roleResult.operation) ;
                            Boolean isAlreadyAssiged =  ( 'alreadyAssigned'.equalsIgnoreCase(roleResult.workflowStatus) && ''.equalsIgnoreCase(roleResult.operation) ) ;
                            Boolean isRemoved =  'removeUserRole'.equalsIgnoreCase(roleResult.operation) ;//TODO Revist the code to address new workflow status 'APPROVING' 
                            
                            System.debug(' ++++++++++++ Existing Entitlement ce '+ce);
                            System.debug(' ++++++++++++ AGS Role Name '+roleName+ ' AGS Role Status '+roleResult.status);
                            System.debug(' ++++++++++++ isSuccess '+isSuccess+'++++++ isAssigned '+isAssigned+'++++++ isAlreadyAssiged '+isAlreadyAssiged+' ++++++++++++ isRemoved '+isRemoved);
                            
                            //AGS Role found in SF Contact Entitlement 
                            if(ce != null){
                                // AGS roles found in SF, Update the contact entitlement status
                                System.debug(' ++++++++++++ ce.Core_Status__c '+ce.Core_Status__c+'++++++ ce.Core_Selected__c '+ce.Core_Selected__c);
                                if('Pending'.equalsIgnoreCase(ce.Core_Status__c)){
                                    
                                    // IF : Selected is TRUE
                                    // ELSE : Selected is FALSE
                                    if(ce.Core_Selected__c){
                                        //assignUserRole Complete
                                        if(isSuccess && (isAssigned || isAlreadyAssiged ) ){
                                            ce.Core_Status__c = 'Complete';
                                        }else{
                                            //Failed when Not success - Unselect and complete 
                                            ce.Core_Status__c = 'Complete';
                                            ce.Core_Selected__c = false;
                                            ce.Core_Update_Reason__c = errorDescription;
                                        }
                                    }else{
                                        //Not selected in SF
                                        if(isRemoved && isSuccess){
                                            ce.Core_Status__c = 'Complete';
                                        }else if( isAlreadyAssiged && isSuccess){ 
                                            mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));
                                        }else{
                                            //Failed case
                                            ce.Core_Status__c = 'Complete';
                                            ce.Core_Selected__c = false;
                                            ce.Core_Update_Reason__c = errorDescription;
                                        }
                                    }
                                    
                                    //Mark the flag to true as the role exists in AGS
                                    ContactEntitlementWrapper ceWrap = existingContEntWrapper.get(ce.Id);
                                    if(ceWrap!= null){
                                        ceWrap.existInAgs = true;
                                    }
                                    
                                }else if('Complete'.equalsIgnoreCase(ce.Core_Status__c)){
                                    //Is Removed and selected
                                    if(isRemoved && isSuccess && ce.Core_Selected__c){
                                        ce.Core_Selected__c = false;
                                        ce.Core_Update_Reason__c = AGS_RESPONSE;
                                    }else if( isAlreadyAssiged && isSuccess && !ce.Core_Selected__c ){ 
                                        // !ce.Core_Selected__c 
                                        ce.Core_Update_Reason__c = AGS_RESPONSE;
                                        ce.Core_Selected__c = true;
                                    }
                                }
                            } else{
                                // AGS Role Not Found in  SF
                                //AGS retured as Added, So added it to SF as completed
                                if(isSuccess && (isAssigned || isAlreadyAssiged ) ){
                                    sAgsRoleNames.add(roleName.trim());
                                }
                            }
                            //Changes PopcornApps END
                        }
                    }
                    
                    c.Core_AGS_Integration_Status__c = ibMsgWrpr.integrationStatus;
                    c.Core_AGS_Integration_Message__c = ibMsgWrpr.integrationMessage;
                    
                    //-- Changes PopcornApps START
                    //Processing AGS Response role's completed, Now verify which one Does not exist in AGS Response but exists in SF to retrigger
                    for(ContactEntitlementWrapper w : existingContEntWrapper.Values()){
                        //IF  1. Does not Exist in AGS && 2. Not selected  3.  Status Pending 
                        //Else 1. Does not Exist in AGS && 2. selected 3.  Status Pending  >> Retrigger
                        if(!w.existInAgs && 'Pending'.equalsIgnoreCase(w.ent.Core_Status__c)  && !w.ent.Core_Selected__c){
                            w.ent.Core_Status__c = 'Complete';
                            sUpdateContEnt.add(w.ent);
                        }else if(!w.existInAgs && 'Pending'.equalsIgnoreCase(w.ent.Core_Status__c)  && w.ent.Core_Selected__c){
                            mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));  
                        }
                    }
                }
                System.debug(' +++++++++++  ContactEntitlementWrapper ' + existingContEntWrapper);
                mMissingEntitlements.put(C, sAgsRoleNames);
                //-- Changes PopcornApps END
            }
            
            // -------------------------------------Start  DML's for updating contacts and entitlements----------------------------
            // Perform DML UPDATE for Contacts
            // TO DO: add exception handling
            System.debug('##### matchingContacts: ' + matchingContacts);
            if (matchingContacts.size() > 0) {
                update matchingContacts;
                insert ContactMsg;
            }
            
            //--------Changes PopcornApps START
            
            //Update the entilement status to Completed
            System.debug('  ++++++ mCurrSfAgsRole_ContEnt ' +mCurrSfAgsRole_ContEnt);
            if(mCurrSfAgsRole_ContEnt != null && mCurrSfAgsRole_ContEnt.size() > 0)
                update mCurrSfAgsRole_ContEnt.values();
            
            //Contact ReTrigger to make AGS outbound again for the pending entitlements
            System.debug('  ++++++ Contacts for Retrigger ' +mRetriggerContactAGS);
            if(mRetriggerContactAGS != null && mRetriggerContactAGS.size() > 0)
                update mRetriggerContactAGS.values();
            
            //Updating the missing entitlement status for AGS 
            System.debug('  ++++++ sUpdateContEnt ' +sUpdateContEnt);
            if(sUpdateContEnt!= null && sUpdateContEnt.size() > 0)
                update new List<Core_Contact_Entitlement__c>(sUpdateContEnt);
            
            
            //Insert all the missing entitlements. AGS-Not Exist && In SF with selected = False & Status - Pending 
            System.debug('  ++++++ Missing Entilements for inserting '+mMissingEntitlements);
            Core_HttpCallouts_Handler.insertConEntByAGSRoles(mMissingEntitlements, AGS_RESPONSE);
            //--------Changes PopcornApps END
            
            // Create a log entry for the all items in LIst of InBoundMessageWrapper
            for(InBoundMessageWrapper ib : mIbMsgWrpr.Values()){
                ib.logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                                'Successfully processed AGS response message',
                                                                'Success!', ib.message.Id, LOG_ENTRY_OBJECT, ib.tags);
            }
            
            
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('#####>> Exception: ' + exceptionMessage);
            for(InBoundMessageWrapper ib : mIbMsgWrpr.Values()){
                ib.processingStatus = 'Failed';
                ib.processingMessage += ', ' + exceptionMessage;
                // Create a log entry
                ib.logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                     'Error processing AGS response message', '', ib.message.Id,
                                                                     LOG_ENTRY_OBJECT, ib.tags, ex);
            }
        }
        // -------------------------------------END  DML's for updating contacts and entitlements----------------------------
        // 
        //Update processing status and integration
        updateInboundMessageProcessingStatus(mIbMsgWrpr);
        
        
    }
    
    
    private static void updateInboundMessageProcessingStatus(Map<Id,InBoundMessageWrapper> inbMsgMap){
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = [SELECT Id, Core_Processing_Status__c, Core_Exception_Message__c, 
                                                                      Core_Log_Entry__c, Core_Tags__c, Core_Outbound_Message__c 
                                                                      FROM Core_Integration_Inbound_Message__c 
                                                                      WHERE Id IN :inbMsgMap.keySet()];
        
        for (Core_Integration_Inbound_Message__c msg : messagesToUpdate) {
            InBoundMessageWrapper ib = inbMsgMap.get(msg.Id);
            msg.Core_Processing_Status__c = ib.processingStatus;
            msg.Core_Exception_Message__c = ib.processingMessage;
            msg.Core_Log_Entry__c = ib.logEntryId;
            msg.Core_Tags__c = Ib.tags;
            msg.Core_Outbound_Message__c = ( Test.isRunningTest() == true ) ?  null  :  ib.outboundMessageId;
        }
        update messagesToUpdate;
        System.debug(' >>>> List updating messagesToUpdate '+messagesToUpdate);        
    }    
    
    
    // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
    }
    
    //Get all unique enterprise Id's
    private static set<String> getEnterpriseIds(Map<Id,InBoundMessageWrapper> wraprObj){
        Set<String> enterpriseIdSet = new Set<String>();
        if(wraprObj != null && !wraprObj.isEmpty()){
            for(InBoundMessageWrapper ib : wraprObj.values()){
                System.debug(' +++++++ InBoundMessageWrapper '+ib);
                if(String.isNotBlank(ib.enterpriseId))
                    enterpriseIdSet.add(ib.enterpriseId);
            }
        }
        return enterpriseIdSet;
    }
    
    // Wrapper class for tracking the contact entitlements exists in ags and 
    public class ContactEntitlementWrapper{
        public Boolean existInAgs {get; set;}
        public Core_Contact_Entitlement__c ent {get; set;}
        public ContactEntitlementWrapper(Boolean flag, Core_Contact_Entitlement__c ce ){
            existInAgs = flag;
            ent = ce;
        } 
        
    }
    
    
    //Wrapper class for inbound message, which encapsulates the processed messages
    public class InBoundMessageWrapper{
        Core_Integration_Inbound_Message__c message {get; set;}
        Core_IntegrationUtility.AGS_Response agsResponse {get;set;}
        String fullPayload {get; private set;}
        String processingStatus {get;set;}
        String processingMessage {get;set;}
        //String exceptionMessage {get;set;}
        ID outboundMessageId {get;set;}
        Id logEntryId {get;set;}
        String enterpriseId {get; set;}
        String tags{get; set;}
        String integrationStatus {get;set;}
        String integrationMessage {get; set;}
        
        public InBoundMessageWrapper(){
            this.processingStatus = 'Successful'; 
            this.processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
            this.fullPayload = '';
        }
        
        //Parses the message and initializes all other variables
        public void setMessage(Core_Integration_Inbound_Message__c msg){
            System.debug('## InBoundMessageWrapper ###  InBoundMessageWrapper Constructor parsing Message ' + msg);
            this.message = msg;
            this.integrationStatus = 'Successful';
            this.integrationMessage = 'Timestamp: ' + Datetime.now() + ' GMT\r\nInbound Message ID: ' + message.Id;
            try{
                if(msg.Core_Payload__c!= null){
                    fullPayload += msg.Core_Payload__c;
                }
                if(msg.Core_Payload1__c!= null){
                    fullPayload += msg.Core_Payload1__c;
                }
                if(msg.Core_Payload2__c!= null){
                    fullPayload += msg.Core_Payload2__c;
                }
                if(msg.Core_Payload3__c!= null){
                    fullPayload += msg.Core_Payload3__c;
                }
                System.debug(' Full payload'+ fullPayload); 
                this.agsResponse =  Core_IntegrationInboundMessageParsing.parseAGSResponse(fullPayload); 
                this.enterpriseId = agsResponse.enterpriseId;
                this.tags = this.enterpriseId +';'+this.message.Id+ ';';
                this.outboundMessageId = agsResponse.Id;
            }catch(Exception ex){
                this.processingStatus = 'Failed';
                this.processingMessage += ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                this.logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                       'Error reading AGS response message', '', msg.Id, LOG_ENTRY_OBJECT, '', ex);
                
            }
            System.debug('## InBoundMessageWrapper ###  AGS Response after parsing  ' + agsResponse); 
        }
        
    }

    Public static void processFailedInbound(Set<Id> failedMessageIds){
        if(!failedMessageIds.isEmpty()){
            List<Contact> contListToUpdateAGS = new List<Contact>();
            List<Core_Integration_Inbound_Message__c> retryIIMList = new List<Core_Integration_Inbound_Message__c>();
            List<Core_Integration_Inbound_Message__c> failedIIMList = [Select id, Core_Retry_Counter__c,Core_Processing_Status__c, Core_Exception_Message__c from Core_Integration_Inbound_Message__c where Id IN: failedMessageIds];
            List<String> apexErrorList = string.isNotBlank(Label.Core_InbMsgReprocessingApexErrors) ? Label.Core_InbMsgReprocessingApexErrors.split(',') : null;
            Boolean inboundAdded = false;
            // Mark all the contacts with the failed Inbound as Core_AGS_Integration_Status__c = Failed and pupolate their Core_AGS_Integration_Message__c
            List<Contact_Message__c> ContactListRealtedToInbound = [Select Contact__r.Name, Contact__c, Inbound_Message__r.Core_Exception_Message__c from Contact_Message__c where Inbound_Message__c =: failedMessageIds];
            //Set<Id> ContactIds = new Set<Id>();
            Map<Id,String> contactAGSMessageMap = new Map<Id,String>();
            for(Contact_Message__c conMessage : ContactListRealtedToInbound){
                //ContactIds.add(conMessage.Contact__c);
                contactAGSMessageMap.put(conMessage.Contact__c, conMessage.Inbound_Message__r.Core_Exception_Message__c);
            }
            //List<Contact> ContactList = [Select id, Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c from Contact where Contact_ID__c IN: ContactIds];
            /*
            for(Contact con : ContactList){
                con.Core_AGS_Integration_Status__c = 'Failed';
                con.Core_AGS_Integration_Message__c = inMessage.Core_Exception_Message__c;
                contListToUpdateAGS.add(con);
            } */
            for(Id conId : contactAGSMessageMap.keySet()){
                Contact con = new Contact();
                con.Id = conId;
                con.Core_AGS_Integration_Status__c = 'Failed';
                con.Core_AGS_Integration_Message__c = contactAGSMessageMap.get(conId);
                contListToUpdateAGS.add(con);
            }

            // When inbound message is freshly received (ie. with retry counter = null OR retry counter = 0), then
            // Mark Core_Retry_Counter__c = 1 if that message is eligible for retry (so that flow will take up these failed inbound messages)
            // Mark Core_Retry_Counter__c = 0 if that message is NOT eligible for retry (so that flow will not take up these failed inbound messages)
            // When inbound message is reprocessed (ie. with retry counter > 0), then
            // Keep retry counter AS-IS so that flow will take these messages in next batch as per their eligibility.
            for(Core_Integration_Inbound_Message__c inMessage : failedIIMList){
                System.debug('Current IIM: ' + inMessage.Id + ' has exception: ' + inMessage.Core_Exception_Message__c);
                for(string apexError : apexErrorList){
                    System.debug('Checking for error: ' + apexError);
                    if(inMessage.Core_Exception_Message__c.contains(apexError) && !inboundAdded && (inMessage.Core_Retry_Counter__c == null || inMessage.Core_Retry_Counter__c == 0)){
                        inMessage.Core_Retry_Counter__c = 1;
                        inMessage.Core_Processing_Status__c = 'Failed';
                        retryIIMList.add(inMessage);
                        inboundAdded = true;
                    }
                }
                if(!inboundAdded && (inMessage.Core_Retry_Counter__c == null || inMessage.Core_Retry_Counter__c == 0)){
                    inMessage.Core_Retry_Counter__c = 0;
                    inMessage.Core_Processing_Status__c = 'Failed';
                    retryIIMList.add(inMessage); 
                    inboundAdded = true;
                }
                if(!inboundAdded){
                    inMessage.Core_Processing_Status__c = 'Failed';
                    retryIIMList.add(inMessage); 
                }
            }

            
            // Update Contacts to Failed and Inbound Messages to appropriate Retry Counter value
            System.debug('retryForAGSApexExeption-->'+Core_IntegrationInboundMessageHandler.retryForAGSApexExeption);
            Core_IntegrationInboundMessageHandler.retryForAGSApexExeption = false; // Added logic to retry processing the Integration Inbound Message in case of Apex Exception
            if(retryIIMList.size()>0 || contListToUpdateAGS.size()>0){
                retryInboundMessageProcessing = true;
                update retryIIMList;
                update contListToUpdateAGS;
            }
        }
    }
}