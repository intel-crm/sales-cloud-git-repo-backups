public class Core_SendEmailNotificaton {
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    public static final String AGS_RESPONSE ='AGS Response';
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
    public static void sendEmail(List<Core_Integration_Inbound_Message__c> newList) {
        
        Id logEntryId = null;
        Map<Id, InBoundMessageWrapper> mIbMsgWrpr = new Map<Id,InBoundMessageWrapper>();
        Set<String> agsEnterpriseIds = new Set<String>();
        Map<String,InBoundMessageWrapper> agsEnterpriseIdResponseMap = new Map<String,InBoundMessageWrapper>();
        Map<String,List<String>> mapNewRolesAdded = new Map<String,List<String>>();
        Map<String,List<String>> mapNewRolesRemoved = new Map<String,List<String>>();
        
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET ENTERPRISE ID VALUES FOR FUTURE CONTACT LOOKUP
        for (Core_Integration_Inbound_Message__c msg : newList) {
            InBoundMessageWrapper ib = null;
            // Only process messages inserted/updated as "Pending"
            // (msg.Core_Processing_Status__c == 'Pending') &&
            if ((msg.Core_Payload__c != null)) {
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
                                              Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Core_AGS_Republish_Ind__c,  
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
            Map<String,String> filteredInboundMsgIdMap = new Map<String,String>();
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

                    filteredInboundMsgIdMap.put(ibMsgWrpr.outboundMessageId, ibMsgWrpr.message.id);
                    
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
                           
                            //Changes PopcornApps START
                            Core_Contact_Entitlement__c ce = mCurrSfAgsRole_ContEnt.get(roleName.trim());
                            Boolean isSuccess = 'success'.equalsIgnoreCase(roleResult.status);
                            Boolean isAssigned =  'complete'.equalsIgnoreCase(roleResult.workflowStatus) && 'assignUserRole'.equalsIgnoreCase(roleResult.operation) ;
                            Boolean isAlreadyAssiged =  ( 'alreadyAssigned'.equalsIgnoreCase(roleResult.workflowStatus) && ''.equalsIgnoreCase(roleResult.operation) ) ;
                            Boolean isRemoved =  'removeUserRole'.equalsIgnoreCase(roleResult.operation) ;//TODO Revist the code to address new workflow status 'APPROVING' 
                            
                            System.debug(' ++++++++++++ Existing Entitlement ce '+ce);
                            System.debug(' ++++++++++++ AGS Role Name '+roleName+ ' AGS Role Status '+roleResult.status);
                            System.debug(' ++++++++++++ isSuccess '+isSuccess+'++++++ isAssigned '+isAssigned+'++++++ isAlreadyAssiged '+isAlreadyAssiged+' ++++++++++++ isRemoved '+isRemoved);
                            
                            
                            //New Code***************************
                            if(isAssigned && isSuccess){
                                if(!mapNewRolesAdded.containsKey(c.Id)){
                                    mapNewRolesAdded.put(c.Id, new List<String>());
                                }
                                mapNewRolesAdded.get(c.Id).add(ce.Core_Entitlement_Id__r.Name);

                            } else if(isRemoved) {
                                if(mapNewRolesRemoved.containsKey(c.Id)){
                                    mapNewRolesRemoved.get(c.Id).add(ce.Core_Entitlement_Id__r.Name);
                                } else {
                                    mapNewRolesRemoved.put(c.Id, new List<String>{ce.Core_Entitlement_Id__r.Name});
                                }
                            }
                            
                            System.debug('mapNewRolesAdded$*$*'+mapNewRolesAdded);
                            System.debug('mapNewRolesRemoved$*$*'+mapNewRolesRemoved);
                            
                            
                            //Changes PopcornApps END
                        }
                    }
                                        
                }
                System.debug(' +++++++++++  ContactEntitlementWrapper ' + existingContEntWrapper);
                mMissingEntitlements.put(C, sAgsRoleNames);
                
            }
            
            sendMessage(matchingContacts,mapNewRolesAdded,mapNewRolesRemoved);

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
        
        
        
    }
    /*
    private static void updateInboundMessageProcessingStatus(Map<Id,InBoundMessageWrapper> inbMsgMap){
        List<Core_Integration_Inbound_Message__c> messagesToUpdate =  [SELECT Id, Core_Processing_Status__c, Core_Exception_Message__c, 
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
    }*/
    
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
    public static void sendMessage(List<Contact> matchingContacts, Map<String,List<String>> mapNewRolesAdded, Map<String,List<String>> mapNewRolesRemoved){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SendEmailResult> resultList;
        String emailSub = 'Roles Added/Removed';
        List<PRM_EmailLog__c> listEmailLog = new List<PRM_EmailLog__c>();
        for(Contact con: matchingContacts) {
            if(mapNewRolesAdded.containsKey(con.Id) || mapNewRolesRemoved.containsKey(con.Id)){
                String body = 'Hello, <br/><br/>';
                if(mapNewRolesAdded.containsKey(con.Id)){
                    body = body +'Following roles have been Added<br/>';
                    for(String str : mapNewRolesAdded.get(con.Id)){
                        body = body + '&nbsp;&nbsp;&nbsp;&nbsp;' + str;
                    } 
                }
                if(mapNewRolesRemoved.containsKey(con.Id)){
                    body = body +'Following roles have been Removed<br/>';
                    for(String str : mapNewRolesRemoved.get(con.Id)){
                        body = body + '&nbsp;&nbsp;&nbsp;&nbsp;' + str;
                    } 
                }
                
                body = body+'<br/><br/>Regards,<br/>DevInt';
                    
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{con.Email});
                email.setSubject(emailSub);
                email.setHtmlBody(body);
                mailList.add(email);
                
                PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
                emailLog.PRM_Contact__c = con.Id;
                emailLog.PRM_EmailContent__c = body;
                emailLog.PRM_EmailHTMLContent__c = body;
                emailLog.PRM_Subject__c = emailSub;
                emailLog.PRM_ToEmailID__c = con.Email;
                emailLog.PRM_Type__c='IPA';
                listEmailLog.add(emailLog);
            }
        }
        try{
            if(!mailList.isEmpty()){
                resultList = Messaging.sendEmail(mailList);  
                insert listEmailLog;
            }
            system.debug('resultList--->'+resultList);
            system.debug('resultList size'+resultList.size());
        } 
        catch(Exception e){
            system.debug('Exception occured' +e.getMessage());
        }
        
    }
     //Get all unique Email Id's
    private static set<String> getEmailIds(Map<Id,InBoundMessageWrapper> wraprObj){
        Set<String> emailIdSet = new Set<String>();
        if(wraprObj != null && !wraprObj.isEmpty()){
            for(InBoundMessageWrapper ib : wraprObj.values()){
                System.debug(' +++++++ InBoundMessageWrapper '+ib);
                if(String.isNotBlank(ib.email))
                   emailIdSet.add(ib.email);
            }
        }
        return emailIdSet;
    }
    
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
        String email {get; set;}
        String evToken {get; set;}
        String passwordToken {get; set;}
        //String firstName {get; set;}
        //String lastName {get; set;}
        String loginId {get; set;}
        //String language {get; set;}
        //String country {get; set;}
        String error {get; set;}
        String tags {get; set;}
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
                this.email = agsResponse.email;
                this.evToken = agsResponse.EmailVerificationToken;
                this.passwordToken = agsResponse.passwordResetToken; 
               // this.firstName = agsResponse.firstName;
                //this.lastName = agsResponse.lastName;
                this.loginId = agsResponse.loginId;
                //this.language = agsResponse.language;
                //this.country = agsResponse.country;
                //this.error = agsResponse.error;
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

}