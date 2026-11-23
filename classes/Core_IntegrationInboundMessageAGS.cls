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
* Subhadeep Sadhu                                    04/08/2021                                                  Convert email to lowercase on AGS inbound
* Akshay [Team:Draco]                28/03/2022                                                  AGS retrigger mechanism upon entitlement assignment/removal failure - TWC1811-1457
* Akshay [Team:Draco]                05/04/2022                      Don't change ERPM Integration Status in case of 2.0 flow - ERPM Bypass Logic
* Shubham [Team:Draco]      30/05/2022              Added variable Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing to do contact entitlement validation in case of retrying IIM reprocessing
* Akshay [Team: Draco]               05/07/2022                                                  Added logic for Proactive Alerts capability
* Shubham [Team:Draco]      15/07/2022              Handle the inbound when there AGS Time out Failures - TWC1811-2189
* Team Draco                23/11/2023              Updated logic to process Salesforce Internal and External Entitlements after receiving AGS Role 2.0 Response
*****************************************************************************************************************************************/

public without sharing class Core_IntegrationInboundMessageAGS {
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    public static final String AGS_RESPONSE ='AGS Response';
    public static final String LOG_ENT_PROJ_ALERT = 'AccessAndEntitlement';
    public static final String LOG_ENT_SCOPE_ALERT = 'A&EFailureAlert';
    public static final String LOG_ENT_OBJ_ALERT = 'Contact';
    public static Boolean retryInboundMessageProcessing = false; // Draco Change [30-05-2022] - Added variable Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing to do contact entitlement validation in case of retrying IIM reprocessing
    public static Boolean dontCreateLogEntry = false; // Draco Change [11-08-2022] - Added logic to NOT create log entries if the inbound message processing is done in Bulk
    //public static boolean startedFromAGSInboundMsg = false; //DRACO Change - Don't change ERPM Integration Status in case of 2.0 flow
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
              // Main method for processing AGS messages
    public static void processMessages(List<Core_Integration_Inbound_Message__c> newList) {}
    
    // Main method for processing AGS messages2_0
    public static void processMessages2_0(List<Core_Integration_Inbound_Message__c> newList) {
        
        Id logEntryId = null; 
        String error = null;
        Map<Id, InBoundMessageWrapper> mIbMsgWrpr = new Map<Id,InBoundMessageWrapper>();
        Set<String> agsEmailIds  = new Set<String>();
        Map<String,InBoundMessageWrapper> agsEmailIdResponseMap  = new Map<String,InBoundMessageWrapper>();
        Map<String,Core_Integration_Inbound_Message__c> mapEmailInboundMsg = new Map<String,Core_Integration_Inbound_Message__c>();
        
        // Check if the operation is Bulk. If it is in bulk then dont create log entries on failure or success
        if(newList.Size() > 1){
            dontCreateLogEntry = true;
        }

        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET Email Id VALUES FOR FUTURE CONTACT LOOKUP
        for (Core_Integration_Inbound_Message__c msg : newList) {
            InBoundMessageWrapper ib = null;
            // Only process messages inserted/updated as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (msg.Core_Payload__c != null)) {
               
                // Constructor parses the payload into an object, then sets into wrapper class variable
                ib = new InBoundMessageWrapper();
                ib.setMessage(msg);
                //agsEmailIdResponseMap.put(ib.email, ib);//NOTE - inbound messaege is always getting overwritten, IPASS is not going to send bulk messages
                
                //DRACO Change. Start. Convert the payload email to all lowercase.
                string ibEmail = ib.email;
                if(ib.email != null){
                    ibEmail = ib.email.toLowerCase('en');
                    
                }
                agsEmailIdResponseMap.put(ibEmail, ib);
                mapEmailInboundMsg.put(ibEmail,msg);
                //DRACO Change. End.
                
                mIbMsgWrpr.put(msg.id, ib);                    
                
               
            }
        }
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL MATCHING CONTACT RECORDS, TO UPDATE
        try {
            
            agsEmailIds = getEmailIds(mIbMsgWrpr);
          
            // We need at least a Email ID. If we don't have one, the next SOQL statement will throw an
            // exception only when run in an actual org, not in our test classes. So let's throw one explicitly instead.
            if ((agsEmailIds.size() == 0) || ((agsEmailIds.size() == 1) && (agsEmailIds.contains('')))) 
            {
                throw new CustomException('AGS response message must contain an Email ID.');
            }
            
            // Pull all matching Contacts, by Email ID
            List<Contact> matchingContacts = [ select Id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Email,Account.Core_CNDA_Number__c,
                                              Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Core_AGS_Republish_Ind__c,  Core_AGS_Duration__c,Core_Contact_B2B_Indicator__c,
                                              (select Id, Name, Core_Display_Nm__c, Core_Entitlement_Id__c, Core_Entitlement_Id__r.Name, Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Entitlement_Id__r.Core_Display_Name__c,Core_Contact_Id__c,
                                               Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, Core_Status__c, Core_Selected__c, Core_Retrigger_Attempt__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c FROM  Contact_Entitlements__r)
                                              FROM Contact
                                              where Email in :agsEmailIds];
            
            //--------------------------------------------------------------------------------------------------
            // CONTACT RECORD UPDATES
            
            //Maps Holds the existing contact entitlements for the contact <Ags RoleName, contact entitlement> 
            Map<String, Core_Contact_Entitlement__c> mCurrSfAgsRole_ContEnt = null;
            Set<Core_Contact_Entitlement__c> sUpdateContEnt = new Set<Core_Contact_Entitlement__c> ();
            List<Map<String, Core_Contact_Entitlement__c>> allEntitlementsToUpdate = new List<Map<String, Core_Contact_Entitlement__c>>();
            
            //For creating the new missing entitlemnets thats existins in AGS
            Map<Contact,Set<String>> mMissingEntitlements = new Map<Contact,Set<String>> ();
            
            //Set of Ags Role Names
            Set<String> sAgsRoleNames = null;
            Map<Id, Contact> mRetriggerContactAGS = new Map<id, Contact>();
            List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
            Map<String,String> filteredInboundMsgIdMap = new Map<String,String>();
            Set<Id> ConId = new Set<Id>();
            for (Contact c : matchingContacts){
                ConId.add(c.Id);
            }
            List<User> UserList = [SELECT ContactId, IsActive, Core_License_Reclaimed_on_Creation__c FROM User WHERE ContactId IN : ConId];
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
                
                
                //Changes PopcornApps END
                
                if (agsEmailIdResponseMap.containsKey(c.Email)) {
                    
                    //Inbound Message object with additional enacapsulated properties
                    ibMsgWrpr = agsEmailIdResponseMap.get(c.Email);
                    ContactMsg.add(new Contact_Message__c(Contact__c = c.id, Inbound_Message__c = ibMsgWrpr.message.id));
                    
                    filteredInboundMsgIdMap.put(ibMsgWrpr.outboundMessageId, ibMsgWrpr.message.id);
                    
                    //Append tags to inboundMessage tags
                    ibMsgWrpr.tags += addTag(c.Id)+addTag(c.Core_eRPM_Person_Id__c)+addTag(c.Email);
                    ibMsgWrpr.tags = ((ibMsgWrpr.tags.length() > 255) ? ibMsgWrpr.tags.substring(0, 255) : ibMsgWrpr.tags);
                    
                    Core_IntegrationUtility.AGS_Response agsResponse = ibMsgWrpr.agsResponse;
                    Boolean retryPending = false;
                    
                    List<Core_IntegrationUtility.AGS_Response_Role> result = agsResponse.result;
                    error = agsResponse.error;
                    if(String.isBlank(error)){
                        
                        if (result != null) {  
                            
                            for (Core_IntegrationUtility.AGS_Response_Role currentResult : result) {
                                String errorDescription = null;
                                String errorSourceSystemMessage = '';    //Draco Change on 24/02/2022 - TWC1811-1432
                                String errorSourSysMsgAndDescription = '';
                                String roleName = '';
                                String roleType = '';
                                Core_IntegrationUtility.AGS_Response_Role_Result roleResult = new Core_IntegrationUtility.AGS_Response_Role_Result();

                                // If current operation is on AGS Roles, add details to roleName and roleResult and process it
                                if(currentResult.GroupName == null && currentResult.roleName != null){
                                    roleName = currentResult.roleName;
                                    roleResult = currentResult.roleResult;
                                    roleType = 'B2B';
                                }
                                
                                // If current operation is on Azure Group, add details to roleName and roleResult as it is the legacy system and process it
                                if(currentResult.GroupName != null && currentResult.roleName == null){
                                    Core_IntegrationUtility.AGS_Response_Group_Result grpResult = currentResult.GroupResult;
                                    roleName = currentResult.GroupName;
                                    //roleResult.status = grpResult.status;
                                    roleResult.workflowStatus = grpResult.workflowStatus;
                                    roleResult.operation = grpResult.operation;
                                    String errorvalue = grpResult.error;
                                    roleType = 'B2C';
                                    List<Core_IntegrationUtility.AGS_Response_Error> ErrorsList = new List<Core_IntegrationUtility.AGS_Response_Error>();
                                    if(errorvalue != null && errorvalue != ''){
                                        Core_IntegrationUtility.AGS_Response_Error Errors = new Core_IntegrationUtility.AGS_Response_Error();
                                        Errors.description = 'Failed to update Group: ' + roleName;
                                        Errors.sourceSystemMessage = errorvalue;
                                        Errors.code = '400';
                                        ErrorsList.add(Errors);
                                    } else{
                                        Core_IntegrationUtility.AGS_Response_Error Errors = new Core_IntegrationUtility.AGS_Response_Error();
                                        Errors.description = 'Failed to update Group: ' + roleName;
                                        Errors.sourceSystemMessage = roleResult.workflowStatus;
                                        Errors.code = '400';
                                        ErrorsList.add(Errors);
                                    }
                                    roleResult.Errors = ErrorsList;
                                }

                                ibMsgWrpr.integrationMessage += '\r\nRole: ' + roleName + ' Operation: ' + roleResult.operation + ' Status: ';
                                
                                    if (roleResult.workflowStatus == 'complete') {
                                    ibMsgWrpr.integrationMessage += 'Success';
                                
                                //Added Condition - 23-11-2022: Set AGS Integration Status to Failed only if the current failed role is with Core_Status__c = 'Pending'
                                }else if (roleResult.workflowStatus == null && mCurrSfAgsRole_ContEnt.get(roleName.trim()).Core_Status__c == 'Pending') {
                                    ibMsgWrpr.integrationStatus = 'Failed';
                                    ibMsgWrpr.integrationMessage += 'Failed';
                                    if(roleResult.Errors != null && !roleResult.Errors.isEmpty()) {                                                                    
                                        for (Core_IntegrationUtility.AGS_Response_Error err : roleResult.Errors) {
                                            String errorCodeAGS = err.code != null && err.code != '' ? err.code : 'NA';
                                            String errorDescrip = err.description != null && err.description != '' ? err.description : 'Error undefined by AGS';
                                            String errorSystMsg = err.sourceSystemMessage != null && err.sourceSystemMessage != '' ? err.sourceSystemMessage : 'Error : No system message received from AGS';
                                            ibMsgWrpr.integrationMessage += ', Error code: ' + errorCodeAGS +
                                                ', Description: ' + errorDescrip +
                                                ', System Message: ' + errorSystMsg + '. ';
                                            errorDescription = errorDescrip;
                                            errorSourceSystemMessage = errorSystMsg; //Draco Change on 24/02/2022 - TWC1811-1432
                                            errorSourSysMsgAndDescription = 'Description: ' + errorDescription + ', Source System Message: ' + errorSourceSystemMessage;
                                            errorDescription = ( (errorDescription != null && errorDescription.length() > 255) ? errorDescription.substring(0, 255) : errorDescription);
                                            
                                        }
                                    } 
                                    // Draco(Shubham) changes on 15/07/2022 - Handle the inbound when there AGS Time out Failures - TWC1811-2189
                                    else{                                                                    
                                        ibMsgWrpr.integrationMessage += ', Error code: NA' + 
                                            ', Description: Error undefined by AGS' + 
                                            ', System Message: No system message received from AGS.';
                                        errorDescription = 'Error undefined by AGS';
                                        errorSourceSystemMessage = 'Error : No system message received from AGS'; //Draco Change on 24/02/2022 - TWC1811-1432
                                        errorSourSysMsgAndDescription = errorSourceSystemMessage + errorDescription;
                                        errorDescription = ( (errorDescription != null && errorDescription.length() > 255) ? errorDescription.substring(0, 255) : errorDescription);
                                    }
                                    if(mapEmailInboundMsg.get(c.Email).Core_Retry_Counter__c == 0 || mapEmailInboundMsg.get(c.Email).Core_Retry_Counter__c == null){
                                        String entitlementAndError = mCurrSfAgsRole_ContEnt.get(roleName.trim()).Core_Entitlement_Id__r.Core_Display_Name__c + '-->' + errorSourSysMsgAndDescription;
                                        logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENT_PROJ_ALERT, LOG_ENT_SCOPE_ALERT, LOG_ENTRY_ERROR,
                                                                                    'A&E Failure in Inbound Message', entitlementAndError, c.Id,
                                                                                    LOG_ENT_OBJ_ALERT, ibMsgWrpr.tags);
                                        Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', errorSourSysMsgAndDescription, c.Id, ibMsgWrpr.message.id, (integer)c.Core_AGS_Duration__c, ibMsgWrpr.tags);
                                    }
                                }
                                
                                // Process the AGS response and updat the contact entitlement status accordinly
                                //Changes PopcornApps START
                                Core_Contact_Entitlement__c ce = mCurrSfAgsRole_ContEnt.get(roleName.trim());
                                Boolean isSuccess, isAssigned, isAlreadyAssiged, isRemoved;
                                if(roleType == 'B2B'){
                                    isSuccess = (roleResult.workflowStatus) != null;
                                    isAssigned ='assignUserRole'.equalsIgnoreCase(roleResult.operation) ;
                                    isAlreadyAssiged =  ('Role alreadyAssigned'.equalsIgnoreCase(roleResult.workflowStatus) && 'assignUserRole'.equalsIgnoreCase(roleResult.operation)) ;
                                    isRemoved =  'removeUserRole'.equalsIgnoreCase(roleResult.operation) ;
                                }
                                if(roleType == 'B2C'){
                                    isSuccess = 'UserAddedtoGroup'.equalsIgnoreCase(roleResult.workflowStatus) || 'UserRemovedfromGroup'.equalsIgnoreCase(roleResult.workflowStatus);
                                    isAssigned =  'Add'.equalsIgnoreCase(roleResult.operation);
                                    isAlreadyAssiged =  ('User already member of Group'.equalsIgnoreCase(roleResult.workflowStatus));
                                    isRemoved =  'Remove'.equalsIgnoreCase(roleResult.operation);
                                }
                               
                                
                                //AGS Role found in SF Contact Entitlement
                                //AGS retrigger mechanism upon entitlement assignment/removal failure - TWC1811-1457 - START - 28-03-2022 
                                if(ce != null){
                                    // AGS roles found in SF, Update the contact entitlement status
                                   
                                    if('Pending'.equalsIgnoreCase(ce.Core_Status__c)){
                                        //Draco Chnages Start 
                                        boolean findError = false;
                                        if(errorSourceSystemMessage != '' && errorSourceSystemMessage != null){
                                            for(String errorString : System.label.Core_LockRowError.split(';')){
                                                if(errorSourceSystemMessage.containsIgnoreCase(errorString)){
                                                    findError = true;
                                                    break;
                                                }
                                            }
                                        }     
                                        //Draco Changes End
                                        // IF : Selected is TRUE
                                        // ELSE : Selected is FALSE
                                        //Updated code on 24/02/2022 by Draco TWC 1811-1432- START 
                                        if(ce.Core_Selected__c){
                                            //assignUserRole Complete 
                                            if(isSuccess && (isAssigned || isAlreadyAssiged ) ){
                                                ce.Core_Retrigger_Attempt__c = 0;
                                                ce.Core_Status__c = 'Complete';
                                                ce.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';  
                                                ce.Core_Update_Reason__c = '';                                 
                                                /*if(System.Label.Core_Entitlements_B2B_Indicator_Update.split(';').contains(ce.Core_Display_Nm__c)){
                                                    c.Core_Contact_B2B_Indicator__c = true;
                                                } */                       
                                            }
                                            else{
                                                //Failed response from AGS for Role Assignment
                                                //If retrigger attempt is less than  max allowed attempt, increase the retrigger count and mark it pending-true for retriggering
                                                if((ce.Core_Retrigger_Attempt__c == null || ce.Core_Retrigger_Attempt__c < integer.valueof(system.label.Max_Entitlement_Retry_Attempt)) && findError){
                                                    ce.Core_Retrigger_Attempt__c = ce.Core_Retrigger_Attempt__c == null ? 1 : ce.Core_Retrigger_Attempt__c + 1; 
                                                    ce.Core_Status__c = 'Pending';
                                                    ce.Core_Selected__c = true;
                                                    ce.Core_Update_Reason__c = 'Retry Attempt ' + ce.Core_Retrigger_Attempt__c + ': ' + ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage); 
                                                    retryPending = true;
                                                    mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));
                                                } else{
                                                    ce.Core_Status__c = 'Complete';
                                                    ce.Core_Selected__c = false;
                                                    ce.Core_Update_Reason__c = ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage);                   
                                                    ce.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                                                }
                                            }
                                        }else{
                                            //Not selected in SF
                                            if(isRemoved && isSuccess){
                                                ce.Core_Retrigger_Attempt__c = 0;
                                                ce.Core_Status__c = 'Complete';
                                                ce.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                                                ce.Core_Update_Reason__c = '';                            
                                            }else if( isAlreadyAssiged && isSuccess){ 
                                                if(errorSourceSystemMessage == null)
                                                {
                                                    errorSourceSystemMessage='';
                                                }
                                                if((ce.Core_Retrigger_Attempt__c == null || ce.Core_Retrigger_Attempt__c < integer.valueof(system.label.Max_Entitlement_Retry_Attempt))){
                                                    ce.Core_Retrigger_Attempt__c = ce.Core_Retrigger_Attempt__c == null ? 1 : ce.Core_Retrigger_Attempt__c + 1;
                                                    ce.Core_Status__c = 'Pending';
                                                    ce.Core_Selected__c = false;
                                                    ce.Core_Update_Reason__c = 'Retry (Removal) Attempt ' + ce.Core_Retrigger_Attempt__c + ': ' + ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage);                   
                                                    retryPending = true;
                                                    mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));
                                                } else{
                                                    ce.Core_Status__c = 'Complete';
                                                    ce.Core_Selected__c = true;
                                                    ce.Core_Update_Reason__c = ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage);                   
                                                    ce.Core_Status_of_Assignment_Failure__c = 'Failed Removal';
                                                }
                                            }else{
                                                //Failed case                                                
                                                if(errorSourceSystemMessage == null)
                                                    errorSourceSystemMessage='';
                                                if((ce.Core_Retrigger_Attempt__c == null || ce.Core_Retrigger_Attempt__c < integer.valueof(system.label.Max_Entitlement_Retry_Attempt))&& findError){
                                                    ce.Core_Retrigger_Attempt__c = ce.Core_Retrigger_Attempt__c == null ? 1 : ce.Core_Retrigger_Attempt__c + 1;
                                                    ce.Core_Status__c = 'Pending';
                                                    ce.Core_Selected__c = false;
                                                    ce.Core_Update_Reason__c = 'Retry (Removal) Attempt ' + ce.Core_Retrigger_Attempt__c + ': ' + ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage);            
                                                    retryPending = true;
                                                    mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));
                                                } else{
                                                    ce.Core_Status__c = 'Complete';
                                                    ce.Core_Selected__c = true;
                                                    ce.Core_Update_Reason__c = ((errorSourceSystemMessage != null && errorSourceSystemMessage.length() > 225) ? errorSourceSystemMessage.substring(0, 225) : errorSourceSystemMessage);  
                                                    ce.Core_Status_of_Assignment_Failure__c = 'Failed Removal';  
                                                }
                                            }
                                        }
                                        //Updated code on 24/02/2022 by Draco TWC 1811-1432- END 
                                        //Mark the flag to true as the role exists in AGS
                                        ContactEntitlementWrapper ceWrap = existingContEntWrapper.get(ce.Id);
                                        if(ceWrap!= null){
                                            ceWrap.existInAgs = true;
                                        }
                                        
                                    }else if('Complete'.equalsIgnoreCase(ce.Core_Status__c)){
                                        //Is Removed and selected
                                        if(isRemoved && isSuccess && ce.Core_Selected__c){
                                            ce.Core_Selected__c = false;
                                            ce.Core_Retrigger_Attempt__c = 0;
                                            ce.Core_Update_Reason__c = AGS_RESPONSE;
                                            ce.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                                        }else if((isAssigned || isAlreadyAssiged ) && isSuccess && !ce.Core_Selected__c ){ 
                                            // !ce.Core_Selected__c 
                                            ce.Core_Retrigger_Attempt__c = 0;
                                            ce.Core_Update_Reason__c = AGS_RESPONSE;
                                            ce.Core_Selected__c = true;
                                            ce.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                                            /*if(System.Label.Core_Entitlements_B2B_Indicator_Update.split(';').contains(ce.Core_Display_Nm__c)){
                                                c.Core_Contact_B2B_Indicator__c = true;
                                            }*/
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
                    }
                    else {              
                        // ibMsgWrpr.integrationMessage = Label.Core_A_E_2_0_Error_Message;
                        ibMsgWrpr.integrationStatus = 'Failed';
                        ibMsgWrpr.integrationMessage =   agsResponse.error; 
                        if(mapEmailInboundMsg.get(c.Email).Core_Retry_Counter__c == 0 || mapEmailInboundMsg.get(c.Email).Core_Retry_Counter__c == null){
                            String entitlementError = 'Common Error in Payload-->' + agsResponse.error;
                            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENT_PROJ_ALERT, LOG_ENT_SCOPE_ALERT, LOG_ENTRY_ERROR,
                                                                            'A&E Failure in Inbound Message', entitlementError, c.Id,
                                                                            LOG_ENT_OBJ_ALERT, ibMsgWrpr.tags);
                            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', ibMsgWrpr.integrationMessage, c.Id, ibMsgWrpr.message.id, (integer)c.Core_AGS_Duration__c, ibMsgWrpr.tags);
                        }
                    }
                    
                    // Create an Integration Report Log Entry after Success:
                    if(ibMsgWrpr.integrationStatus == 'Successful'){
                        Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', 'Success', c.Id, ibMsgWrpr.message.id, (integer)c.Core_AGS_Duration__c, ibMsgWrpr.tags);
                        c.Core_AGS_Retry_Count__c = 0;
                    }
                    c.Core_AGS_Integration_Status__c = ibMsgWrpr.integrationStatus;
                    c.Core_AGS_Integration_Message__c = ((ibMsgWrpr.integrationMessage.length() > 9000) ?  ibMsgWrpr.integrationMessage.substring(0, 9000) : ibMsgWrpr.integrationMessage);
                   // c.Core_Login_Id__c        =   ibMsgWrpr.loginId; //Draco Commented deprecating attributes
                   // c.Core_Email_Verification_Token__c  = ibMsgWrpr.evToken; //Draco Commented deprecating attributes
                   // c.Core_Password_Token__c = ibMsgWrpr.passwordToken; //Draco Commented deprecating attributes
                    c.Core_Enterprise_Id__c = ibMsgWrpr.enterpriseId;
                   // c.Core_IPA_Email_Verification_Date__c = ibMsgWrpr.EVupdatedDate;//added by Draco to populate EV date on AGS response
                    
                    //-- Changes PopcornApps START
                    //Processing AGS Response role's completed, Now verify which one Does not exist in AGS Response but exists in SF
                    List<Core_Contact_Entitlement__c> listPendingIntContEnt = new List<Core_Contact_Entitlement__c>();
                    Set<Id> IntEntConId = new Set<Id>();
                    for(ContactEntitlementWrapper w : existingContEntWrapper.Values()){
                        //IF  1. Does not Exist in AGS && 2. Status Pending  && 3. External Entitlement --> Increase Retrigger counter and Retrigger OBM
                        //Else 1. Does not Exist in AGS && 2. Status Pending  && 3. Internal Entitlement --> Process the CE record for Internal Entitlements
                        if(!w.existInAgs && 'Pending'.equalsIgnoreCase(w.ent.Core_Status__c) && (w.ent.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'AGS' || String.isBlank(w.ent.Core_Entitlement_Id__r.Core_Entitlement_Type__c ))){
                            if((w.ent.Core_Retrigger_Attempt__c == null || w.ent.Core_Retrigger_Attempt__c < integer.valueof(system.label.Max_Entitlement_Retry_Attempt))){
                                w.ent.Core_Retrigger_Attempt__c = w.ent.Core_Retrigger_Attempt__c == null ? 1 : w.ent.Core_Retrigger_Attempt__c + 1;
                                mRetriggerContactAGS.put(c.id, new Contact(Id = c.Id, Core_AGS_Integration_Status__c = 'Pending'));
                            } 
                        }else if(!w.existInAgs && 'Pending'.equalsIgnoreCase(w.ent.Core_Status__c) && w.ent.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'Salesforce'){
                            c.Core_Entitlement_Assignment_Status__c = 'Pending';
                            c.Core_Entitlement_Assignment_Message__c = 'Timestamp: ' + System.now() + ' GMT \n';
                            listPendingIntContEnt.add(w.ent);
                            IntEntConId.add(w.ent.Core_Contact_Id__c);
                        }
                    }

                    // *********************Draco Change [START] - Update CE record and Contact AGS Intg Status for Internal Entitlements****************//
                    List<User> IntEntContUserList = new List<User>();
                    for (User usr : UserList){
                        if(IntEntConId.Contains(usr.ContactId)){
                            IntEntContUserList.add(usr);
                        }
                    }
                    Map<Id, Boolean> IntEntUserMap = new Map<Id, Boolean>();
                    for(User use : IntEntContUserList){
                        if(use.Core_License_Reclaimed_on_Creation__c){
                            IntEntUserMap.put(use.ContactId, use.Core_License_Reclaimed_on_Creation__c);
                        } else {
                        IntEntUserMap.put(use.ContactId, use.IsActive);
                    }
                    }
                    for(Core_Contact_Entitlement__c currIntEnt : listPendingIntContEnt){
                    String IntgLogTags = currIntEnt.Core_Display_Nm__c;                        
                        if((IntEntUserMap.containsKey(currIntEnt.Core_Contact_Id__c) && IntEntUserMap.get(currIntEnt.Core_Contact_Id__c)) || // If User is Present and Active, mark Internal Entitlements as Successful
                        (!currIntEnt.Core_Selected__c && IntEntUserMap.containsKey(currIntEnt.Core_Contact_Id__c) && !IntEntUserMap.get(currIntEnt.Core_Contact_Id__c) && !retryPending) || // If user is InActive, but Entitlement is for Removal, mark it as Successful
                        (!currIntEnt.Core_Selected__c && !IntEntUserMap.containsKey(currIntEnt.Core_Contact_Id__c) && !retryPending)){ // If user is Not Available, but Entitlement is for Removal, mark it as Successful
                            if(c.Core_AGS_Integration_Status__c != 'Failed'){
                               c.Core_AGS_Integration_Status__c = 'Successful'; //Mark the AGS Integration status to Successful ONLY if its not marked as Failed anywhere else in transaction before.
                            }
                                if(c.Core_Entitlement_Assignment_Status__c != 'Failed' ){
                               c.Core_Entitlement_Assignment_Status__c = 'Successful';
                                if(currIntEnt.Core_Selected__c){
                               c.Core_Entitlement_Assignment_Message__c += 'Entitlement: '+currIntEnt.Core_Display_Nm__c +'\n'+'Operation: Assign Entitlement; Status: Successful \n' ;
                                }
                                else{
                                    c.Core_Entitlement_Assignment_Message__c += 'Entitlement: '+currIntEnt.Core_Display_Nm__c +'\n'+ 'Operation: Remove Entitlement; Status: Successful \n' ;
                                }
                            }
                            currIntEnt.Core_Status__c = 'Complete';
                            currIntEnt.Core_Update_Reason__c='';
                            if(currIntEnt.Core_Selected__c){
                                currIntEnt.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                            } else {
                                currIntEnt.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                            }
                            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('Salesforce','Success',currIntEnt.Core_Contact_Id__c, null, 0,IntgLogTags);

                        }else if(currIntEnt.Core_Selected__c && IntEntUserMap.containsKey(currIntEnt.Core_Contact_Id__c) && !IntEntUserMap.get(currIntEnt.Core_Contact_Id__c) && !retryPending){ // Update Internal entitlements to failed ONLY if there is nothing pending for Retry also
                            currIntEnt.Core_Status__c = 'Complete';
                            c.Core_Entitlement_Assignment_Status__c = 'Failed';
                            c.Core_Entitlement_Assignment_Message__c += 'Entitlement: '+currIntEnt.Core_Display_Nm__c +'\n'+'Operation: Assign Entitlement; Status: Failed'+'\n'+ 'User Record Inactive;'+ '\n';
                            currIntEnt.Core_Selected__c = false;
                            currIntEnt.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                            currIntEnt.Core_Update_Reason__c='User Record Inactive';
                            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('Salesforce','User Record Inactive',currIntEnt.Core_Contact_Id__c, null, 0, IntgLogTags);
                        }else if(currIntEnt.Core_Selected__c && !IntEntUserMap.containsKey(currIntEnt.Core_Contact_Id__c) && !retryPending){ // Update Internal entitlements to failed ONLY if there is nothing pending for Retry also
                            currIntEnt.Core_Status__c = 'Complete';
                            c.Core_Entitlement_Assignment_Status__c = 'Failed';
                            c.Core_Entitlement_Assignment_Message__c += 'Entitlement: '+currIntEnt.Core_Display_Nm__c +'\n'+'Operation: Remove Entitlement; Status: Failed' +'\n'+ 'User Record Not Available;'+ '\n';
                            currIntEnt.Core_Selected__c = false;
                            currIntEnt.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                            currIntEnt.Core_Update_Reason__c='User Record Not Available';
                            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('Salesforce','User Record Not Available',c.Id, null, 0,IntgLogTags);
                        }
                    }
                    // *********************Draco Change [END] - Update CE record and Contact AGS Intg Status for Internal Entitlements****************//
                }
            
                mMissingEntitlements.put(C, sAgsRoleNames);
                //-- Changes PopcornApps END
                
                /***********************Draco : AGS Multiple OBM issue 14 Aug - START****************************/
                if(c.Core_AGS_Republish_Ind__c == true){
                    //c.Core_AGS_Integration_Status__c = 'Pending';
                    c.Core_AGS_Republish_Ind__c = false;
                    
                }
                /***********************Draco : AGS Multiple OBM issue 14 Aug - END******************************/

                //Add the entitlements map that are to be updated into the list of Map
                allEntitlementsToUpdate.add(mCurrSfAgsRole_ContEnt);
            }
            
            // -------------------------------------Start  DML's for updating contacts and entitlements----------------------------
            // Perform DML UPDATE for Contacts
            // 
            List<Contact_Message__c> conMsgList = [ select Name,Inbound_Message__c,Outbound_Message__c,Core_Inbound_Message_Status__c,Core_Message_Type__c from Contact_Message__c where Core_Message_Type__c ='AGS Contact Entitlement 2.0' AND Outbound_Message__c IN :filteredInboundMsgIdMap.keySet() ];
            for(Contact_Message__c conMsg : conMsgList){
                conMsg.Inbound_Message__c = filteredInboundMsgIdMap.get(conMsg.Outbound_Message__c);
            }
            //update conMsgList;
            // TO DO: add exception handling            
            //--------Changes PopcornApps START
            
            //Update the entilement status to Completed
            List<Core_Contact_Entitlement__c> entForUpdate = new List<Core_Contact_Entitlement__c>();
           // Map<id,id> contactEntMap= new Map<id,id>();
            List<Core_Contact_Entitlement__c> contactEntSuccessIdListToUpdate =  new List<Core_Contact_Entitlement__c>();
            for(Map<String, Core_Contact_Entitlement__c> currentMap : allEntitlementsToUpdate){
                entForUpdate.addAll(currentMap.values());
            }
            
           
            
            contactEntSuccessIdListToUpdate = Core_Draco_Misc_Functionalities.validateBeforeDML(entForUpdate,matchingContacts);
           
            if(contactEntSuccessIdListToUpdate != null && !contactEntSuccessIdListToUpdate.isEmpty()){
                update contactEntSuccessIdListToUpdate;
            }
            if (matchingContacts.size() > 0) {
                insert ContactMsg;
                update matchingContacts;
            }
            
            //Contact ReTrigger to make AGS outbound again for the pending entitlements
            if(String.isBlank(error)){
              
                if(mRetriggerContactAGS != null && mRetriggerContactAGS.size() > 0)
                    update mRetriggerContactAGS.values();
            }
            //Updating the missing entitlement status for AGS 
           
            if(sUpdateContEnt!= null && sUpdateContEnt.size() > 0)
                update new List<Core_Contact_Entitlement__c>(sUpdateContEnt);
            
            
            //Insert all the missing entitlements. AGS-Not Exist && In SF with selected = False & Status - Pending 
           
            Core_HttpCallouts_Handler.insertConEntByAGSRoles(mMissingEntitlements, AGS_RESPONSE);
            //--------Changes PopcornApps END
            
            // Create a log entry for the all items in LIst of InBoundMessageWrapper
            if(dontCreateLogEntry == false){
                for(InBoundMessageWrapper ib : mIbMsgWrpr.Values()){
                    ib.logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                                       'Successfully processed AGS response message',
                                                                       'Success!', ib.message.Id, LOG_ENTRY_OBJECT, ib.tags);
                }
            }  
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
           
            if(dontCreateLogEntry == false){
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
        // -------------------------------------END  DML's for updating contacts and entitlements----------------------------
        // 
        //Update processing status and integration
        updateInboundMessageProcessingStatus(mIbMsgWrpr);
        
        
    }
    
    
    private static void updateInboundMessageProcessingStatus(Map<Id,InBoundMessageWrapper> inbMsgMap){
        List<Core_Integration_Inbound_Message__c> messagesToUpdate =  [SELECT Id, Core_Processing_Status__c, Core_Exception_Message__c, 
                                                                       Core_Log_Entry__c, Core_Tags__c, Core_Outbound_Message__c 
                                                                       FROM Core_Integration_Inbound_Message__c 
                                                                       WHERE Id IN :inbMsgMap.keySet()];
        
        Set<Id> failedMessageSet = new Set<Id>();
        for (Core_Integration_Inbound_Message__c msg : messagesToUpdate) {
            InBoundMessageWrapper ib = inbMsgMap.get(msg.Id);
            msg.Core_Processing_Status__c = ib.processingStatus;
            msg.Core_Exception_Message__c = ib.processingMessage;
            if(msg.Core_Processing_Status__c == 'Successful'){
                msg.Core_Retry_Counter__c = 0;
            }
            msg.Core_Log_Entry__c = ib.logEntryId; 
            msg.Core_Tags__c = Ib.tags.length() > 255 ? Ib.tags.subString(0,255) : Ib.tags;
            msg.Core_Outbound_Message__c = ( Test.isRunningTest() == true ) ?  null  :  ib.outboundMessageId;
            if(msg.Core_Processing_Status__c == 'Failed'){
                failedMessageSet.add(msg.Id);
            }
        }
        update messagesToUpdate;
        Core_IntegrationInboundMessageAGS.processFailedInbound(failedMessageSet);
        
    }    
    
    
    // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
            }
    
    //Get all unique enterprise Id's
    /*private static set<String> getEnterpriseIds(Map<Id,InBoundMessageWrapper> wraprObj){
Set<String> enterpriseIdSet = new Set<String>();
if(wraprObj != null && !wraprObj.isEmpty()){
for(InBoundMessageWrapper ib : wraprObj.values()){

if(String.isNotBlank(ib.enterpriseId))
enterpriseIdSet.add(ib.enterpriseId);
}
}
return enterpriseIdSet;
}*/
    
    //Get all unique Email Id's
    private static set<String> getEmailIds(Map<Id,InBoundMessageWrapper> wraprObj){
        Set<String> emailIdSet = new Set<String>();
        if(wraprObj != null && !wraprObj.isEmpty()){
            for(InBoundMessageWrapper ib : wraprObj.values()){
              
                if(String.isNotBlank(ib.email)){
                    
                    //emailIdSet.add(ib.email);
                    emailIdSet.add(ib.email.toLowerCase('en'));//DRACO Change. Email case.
                }
            }
        }
        return emailIdSet;
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
        Integer retryCounter {get;set;}
        String integrationMessage {get; set;}
        DateTime EVupdatedDate {get; set;}//added by Draco to populate EV date on AGS response
        
        public InBoundMessageWrapper(){
            this.processingStatus = 'Successful'; 
            this.retryCounter = 0;
            this.processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
            this.fullPayload = '';
        }
        
        //Parses the message and initializes all other variables
        public void setMessage(Core_Integration_Inbound_Message__c msg){
           
            this.message = msg;
            this.integrationStatus = 'Successful';
            this.integrationMessage = 'Timestamp: ' + Datetime.now() + ' GMT\r\nInbound Message ID: ' + message.Id;
            String processedPayload = '';
            if(msg.Core_Payload__c.containsIgnoreCase('"Errors": "')){
                processedPayload = errorFormatting(msg.Core_Payload__c);
            } else{
                processedPayload = msg.Core_Payload__c;
            }
           
            try{
                if(msg.Core_Payload__c!= null){
                    fullPayload += processedPayload;
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
               
                this.agsResponse =  Core_IntegrationInboundMessageParsing.parseAGSResponse(fullPayload); 
                this.enterpriseId = agsResponse.enterpriseId;
                this.email = agsResponse.email;
                this.evToken = agsResponse.EmailVerificationToken;
                this.passwordToken = agsResponse.passwordResetToken;
                this.EVupdatedDate = agsResponse.EVupdatedDate;//added by Draco to populate EV date on AGS response
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
          
        }
        
    }
    
    // Added by Draco to retry processing of Integration Inbound Message in case of Apex error
    Public static void processFailedInbound(Set<Id> failedMessageIds){
        if(!failedMessageIds.isEmpty()){
            List<Contact> contListToUpdateAGS = new List<Contact>();
            List<Core_Integration_Inbound_Message__c> retryIIMList = new List<Core_Integration_Inbound_Message__c>();
            List<Core_Integration_Inbound_Message__c> failedIIMList = [Select id, Core_Retry_Counter__c,Core_Processing_Status__c, Core_Exception_Message__c from Core_Integration_Inbound_Message__c where Id IN: failedMessageIds];
            List<String> apexErrorList = string.isNotBlank(Label.Core_InbMsgReprocessingApexErrors) ? Label.Core_InbMsgReprocessingApexErrors.split(',') : null;
            Boolean inboundAdded = false;
            // Mark all the contacts with the failed Inbound as Core_AGS_Integration_Status__c = Failed and pupolate their Core_AGS_Integration_Message__c
            List<Contact_Message__c> ContactListRealtedToInbound = [Select Contact__r.Name, Contact__c, Inbound_Message__r.Core_Exception_Message__c from Contact_Message__c where Inbound_Message__c =: failedMessageIds ];
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
               
                for(string apexError : apexErrorList){
                   
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
        
            Core_IntegrationInboundMessageHandler.retryForAGSApexExeption = false; // Added logic to retry processing the Integration Inbound Message in case of Apex Exception
            if(retryIIMList.size()>0 || contListToUpdateAGS.size()>0){
                retryInboundMessageProcessing = true;
                update retryIIMList;
                update contListToUpdateAGS;
            }
        }
    }
    
    // Added by Draco to re-process the failed Inbound Message in the Flow Batch (once exhaused from reprocessing when inbound is received)
    // This method was mainly introduced to cater the fallouts from the reprocessing logic due to the lock row error. 
    @InvocableMethod(label='Reprocess failed Role 2.0 Inbound Flow Batch' description='This method will reprocess the failed inbound one last time which are exhaused in reprocessing logic')
    public static void reprocessFailedInboundFlowBatch() {
        reprocessFailedInboundAsync();
    }

    // BELOW METHOD SHOULD NOT BE COMMENTED IN DEVINT AND HIGHER ORGS!!!!!!!!!!!!!!!**********************
    
    @future
    public static void reprocessFailedInboundAsync(){
        try{
        Integer maxRetryAttempt = integer.valueof(system.label.Max_Entitlement_Retry_Attempt);
        List<Core_Integration_Inbound_Message__c> pendingIIM = new List<Core_Integration_Inbound_Message__c>();
        Integer addMins = integer.valueof(System.Label.Core_Reprocess_TimeOffset_Minutes);
        Datetime timeOffset = System.now();
        timeOffset = timeOffset.addMinutes(-addMins);
        string failedVal='Failed';
        string roleVal='Role 2.0';
            Integer batchSize = integer.valueof(System.Label.Core_Reprocess_Batch_Size);
        String soqlQueryStr = 'SELECT Id,Core_Retry_Counter__c,Core_Processing_Status__c, Core_Exception_Message__c FROM Core_Integration_Inbound_Message__c WHERE Core_Processing_Status__c =:failedVal  AND Core_Retry_Counter__c <=: maxRetryAttempt AND Core_Retry_Counter__c != 0 AND Core_Message_Type__c =:roleVal AND LastModifiedDate < ' + + timeOffset.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' LIMIT ' + batchSize;
            
        //Get the list of Role 2.0 Inbound messages which are exhaused in reprocessing attempt
        List<Core_Integration_Inbound_Message__c> failedIIM = Database.query(soqlQueryStr);
        
        for(Core_Integration_Inbound_Message__c IIM : failedIIM){
            IIM.Core_Processing_Status__c = 'Pending';
            IIM.Core_Retry_Counter__c += 1;
            pendingIIM.add(IIM);

            
            Map<String,Object> FailedIIMMap = new Map<String,Object>();
            FailedIIMMap.put('InboundMessageId',IIM.Id);

            //create instance of Interview
            Flow.Interview.Update_Failed_Inbound_to_Pending pendingIIMFlow = new Flow.Interview.Update_Failed_Inbound_to_Pending(FailedIIMMap);

            //Invoke start method of the flow
            pendingIIMFlow.start();
        }
        }catch(Exception e){
            UCD_ACM_Logger.error('Core_IntegrationInboundMessageAGS','reprocessFailedInboundAsync',e.getMessage(), null);
            UCD_ACM_Logger.setLogDetails();
        }
       
        //update pendingIIM;
    }


    // Added by Draco to format the payload information to convert errors in the roles from "Errors": "<some error>" format to 
    // "Errors": [{"description": "Failed to update role","code": 400,"serviceCode": "WorkflowExecutionError","sourceSystemCode": "","sourceSystemMessage": "<some error>","requestId": null}] format
    public static String errorFormatting (String payloadString){
    Map<String, String> errorMap = new Map<String, String>();
        if(payloadString != null && payloadString != '' && payloadString.containsIgnoreCase('"Errors": "')){
            List<String> strListErrorsSplit = payloadString.split('"Errors": "');
            for(Integer i = 1; i < strListErrorsSplit.size(); i++){
                String errorStrSplit = strListErrorsSplit[i];
              
                String rawError = errorStrSplit.split('"')[0];
                //String sInteger = String.valueOf(i);
                String errorString = '[{"description": "Failed to update role","code": 400,"serviceCode": "WorkflowExecutionError","sourceSystemCode": "","sourceSystemMessage": "' + rawError + '","requestId": null}]';
                rawError = '"' + rawError + '"';

                if(!errorMap.containsKey(rawError)) {
                    errorMap.put(rawError, errorString);
                } else {
                    
                }

               
                //payloadString = payloadString.replaceFirst(rawError,errorString);
            }
            for(String errorStr : errorMap.keySet()){
                payloadString = payloadString.replace(errorStr,errorMap.get(errorStr));
            }
        }
        
        return payloadString;
    }
}