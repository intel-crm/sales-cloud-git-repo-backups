public without sharing class PRM_AGS_IdentityCreation {
    
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'AGS Identity Creation';
    public static final String LOG_ENTRY_SCOPE    = 'Contact - AGS Identity Creation';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_OBJECT   = 'Contact'; 
    public static final String UPDATE_REASON_ERPM = 'ERPM';
    public static final String ACR_STATUS = 'AGS Identity Creation Failed';
    public static final String STATUS_PENDING_ACTION = 'Pending Action';
    public static  boolean firstRunBulkLoad = true;
    public static boolean isBulk = false;    
    public static Boolean IS_DelayInviteEmail = !Test.isRunningTest()?Boolean.valueof(Label.PRM_DelayInviteEmail):True; 
    
    
    public static Map<Id, Boolean> mapOfContactSentForIdentity = new Map<Id, Boolean>();
    @future (callout=true)
    public static void createIdentityInAGSAsync(Id contactId){
        createIdentityInAGSSync(contactId); 
    }
    
    public static void createIdentityInAGSAsyncBulk(Id contactId){
        isBulk = true;
        createIdentityInAGSSync(contactId); 
    }
    
    @Auraenabled

    public static void createIdentityInAGSSync1(Id contactId,String acrID){
        List<PRM_Account_Contact_Relationship__c> acrlist =  new List<PRM_Account_Contact_Relationship__c>();
        for(PRM_Account_Contact_Relationship__c acr:[
            SELECT Id,PRM_AGS_Identity_Creation_Fail__c from PRM_Account_Contact_Relationship__c 
            WHERE PRM_Contact_Id__c = :contactId 
            AND PRM_AGS_Identity_Creation_Fail__c = true]
        ){
            acr.PRM_AGS_Identity_Creation_Fail__c=false;
            acrlist.add(acr);
        }
        System.debug(acrlist);
        update acrlist;
        //database.update(acrlist, false);
        createIdentityInAGSAsync(contactId);
    }
    
    @Auraenabled
    public static void createIdentityInAGSSync(Id contactId){
        //DateTime reqTime = System.now();
        set<string> conidss=new set<string>();
        list<PRM_Account_Contact_Relationship__c > acrList=new list<PRM_Account_Contact_Relationship__c >();
        List<Contact> contacts = new List<Contact>();
        if (contactId != null) {
            conidss.add(contactId );
            
            contacts = [
                SELECT
                Id,
                FirstName,
                LastName,
                MailingCountryCode,
                Core_Preferred_Language__c,
                Email,
                Account.BillingCountryCode,(SELECT id,PRM_Source_Agent__c,PRM_AGS_Response_Status__c,PRM_Status_Nm__c,PRM_InActive_Ind__c,Createddate,PRM_Contact_Id__c from Account_Contact_Relationships__r )
                FROM Contact
                WHERE id = :contactId
            ];
            
            HttpRequest httpReq = new HttpRequest();
            HttpResponse response = new HttpResponse();
            String requestBody;
            try {                
              //  PRM_Integration__mdt agsAPIDetails = [Select Id, API_Key__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='SCtoAGS'];
                //system.debug('agsAPIDetails ==>'+agsAPIDetails);
                /* if(agsAPIDetails!=null){
if(contacts.size() > 0) {
string token = getToken(agsAPIDetails) != null ? getToken(agsAPIDetails).access_token : null; 
if(token != null || String.isNotBlank(token)) {                               
httpReq.setEndpoint(agsAPIDetails.EndPointURL__c);
httpReq.setHeader('Authorization', 'Bearer '+token);                           
httpReq.setHeader('Content-Type', 'application/json');  */                          
                if (contacts.size() > 0) {
                    conidss.add(contacts[0].Id);
                    if(contacts[0].Account_Contact_Relationships__r.size()>0)
                        acrList=contacts[0].Account_Contact_Relationships__r;                       
                    httpReq.setEndpoint('callout:PRM_SCtoAGS_CiDaas');                                                                                   
                    httpReq.setHeader(
                        'Content-Type',
                        'application/json'
                    );
                    httpReq.setBody(constructInputJSON(contacts[0]));
                    httpReq.setMethod('POST');
                    httpReq.setTimeout(
                        Integer.valueOf(Label.APIGEETimeout)
                    );
                    requestBody = constructInputJSON(contacts[0]);
                    httpReq.setBody(requestBody);
                    response = new Http().send(httpReq);
                    system.debug(
                        'Response ===>' +
                        EncodingUtil.urlDecode(
                            response.getBody(),
                            'UTF-8'
                        )
                    );
                    if (
                        response.getStatusCode() != 200 ||
                        response.getBody().indexOf('ErrorCode') > -1
                    ) {
                        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(
                            contactId,
                            false
                        );
                        CustomException ex = new CustomException();
                        ex.Message = response.getBody();
                        ex.StackTraceString = System.Label.PRM_Mulesoft_Api_Error;
                        createLogEntry(
                            System.Label.PRM_Error_Identity_Creation,
                            contacts[0],
                            ex,
                            LOG_ENTRY_ERROR
                        );
                    } else {
                        createLogEntry(
                            EncodingUtil.urlDecode(
                                response.getBody(),
                                'UTF-8'
                            ),
                            contacts[0],
                            null,
                            LOG_ENTRY_INFO
                        );
                        PRM_AGS_IdentityCreation.updateACRStatusOnAgsIdentityCreationFailure(
                            contactId,
                            true
                        );
                        
                    }
                }
                else{
                    CustomException ex = new CustomException();                    
                    ex.Message = System.Label.PRM_Mulesoft_Config_Error;                          
                    ex.StackTraceString = System.Label.PRM_Mulesoft_Config_Error;                    
                    createLogEntry(System.Label.PRM_Error_Identity_Creation, null, ex, LOG_ENTRY_ERROR);  
                }
        } catch (Exception ex) {
                CustomException custEx = new CustomException();
                custEx.Message = ex.getMessage();
                custEx.Cause = ex.getCause();
                custEx.StackTraceString = ex.getStackTraceString();
                custEx.LineNumber = ex.getLineNumber();
                custEx.TypeName = ex.getTypeName();
                
                createLogEntry(
                    System.Label.PRM_Error_Identity_Creation,
                    contacts[0],
                    custEx,
                    LOG_ENTRY_ERROR
                );
                
            } finally {
                // Integration log record creation for AGS identity syn request
                if (!isBulk) {
                    PRM_IPA_Utility.createIntegrationLog(
                        String.valueOf(contactId),
                        PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND,
                        PRM_IPA_Constants.MODULE_ADMIN_REGISTRATION,
                        requestBody,
                        response.getBody(),
                        response.getStatusCode(),
                        PRM_IPA_Constants.SYSTEM_NAME_AGS,
                        'PRM_AGS_IdentityCreation'
                    );
                } else {
                    PRM_BulkDataUpload_Batch.listIntegrationLogs.add(
                        PRM_BulkDataUpload_Batch.createIntegrationLog(
                            String.valueOf(contactId),
                            PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND,
                            PRM_IPA_Constants.MODULE_ADMIN_REGISTRATION,
                            requestBody,
                            response.getBody(),
                            response.getStatusCode(),
                            PRM_IPA_Constants.SYSTEM_NAME_AGS,
                            'PRM_AGS_IdentityCreation'
                        ));
                }
                if(System.Label.PRM_Tracker_Enabled=='true'){
                    if(!system.isbatch() && !system.isFuture()){
                        system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,conidss,true,false));
                    }else if(system.isFuture()){
                        PRM_RegistrationTrackerUtility.executeMethod(null,conidss,true,false);  
                        
                    }
                }
                  
            }
        }
    }
    
    public static PRM_Token_Model getToken(API_M_Auth_Provider__mdt agsAPIDetails) {
        //DateTime reqTime = System.now();
        PRM_Token_Model token = new PRM_Token_Model();
        HttpRequest httpReq = new  HttpRequest();
        HttpResponse response = new HttpResponse();
        String payLoad;
        try {
            string accessToken = (string) Cache.Org.get(
                'local.PRMIPAPartition.APIGEEaccesstoken'
            );
            //system.debug('token-'+accessToken);
            if(String.isNotBlank(accessToken) ) {
                token.access_token = accessToken;
                return token; 
            }
            httpReq.setEndpoint(agsAPIDetails.Access_Token_URL__c);
            httpReq.setMethod('POST');
            httpReq.setHeader(
                'content-type',
                'application/x-www-form-urlencoded'
            );
            
            //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
            payLoad =
                'grant_type=client_credentials&client_id=' +
                EncodingUtil.urlEncode(agsAPIDetails.Consumer_Key__c, 'UTF-8') +
                '&client_secret=' +
                EncodingUtil.urlEncode(agsAPIDetails.Consumer_Secret__c, 'UTF-8');
            system.debug('payload- ' + payload);
            httpReq.setBody(payLoad);
            response = new Http().send(httpReq);
            if(response.getStatusCode() == 200 ) {
                system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                token = PRM_Token_Model.parse(response.getBody());
                Cache.Org.put('local.PRMIPAPartition.APIGEEaccesstoken',token.access_token, Integer.valueOf(Label.APIGEETokenExpiryTime),Cache.Visibility.ALL, true);
            }
            else {
                system.debug('response- '+response.getBody());
                CustomException ex = new CustomException();                    
                ex.Message = 'Error in token generation -'+response.getBody();  
                createLogEntry(System.Label.PRM_Error_Identity_Creation, null, ex, LOG_ENTRY_ERROR);
                /* Insert Integration log only when the token fetch is failed. On success case, we shouldn't create
as it will give You have uncommitted work pending. Please commit or rollback before calling out error
when futher request to sync to AGS is sent */
                PRM_IPA_Utility.createIntegrationLog( agsAPIDetails.Consumer_Key__c, PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND, PRM_IPA_Constants.MODULE_SELF_REGISTRATION, payLoad, response.getBody(), response.getStatusCode(), PRM_IPA_Constants.SYSTEM_NAME_AGS,'PRM_AGS_IdentityCreation');
            }
        }
        catch(Exception ex){
            CustomException custEx = new CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            createLogEntry(System.Label.PRM_Error_Identity_Creation, null, custEx, LOG_ENTRY_ERROR); 
        }
        return token;
    }
    
    private static String constructInputJSON(Contact cont) {
        String AccountBillingCountryCodeISO2= PRM_IPA_Utility.getTwoLwtterCountryCode(cont.Account.BillingCountryCode);
        String ContactMailingCountryCodeISO2= PRM_IPA_Utility.getTwoLwtterCountryCode(cont.MailingCountryCode);
        String languageCodeISO4=PRM_IPA_Utility.fourLetterLangCode(cont);
        system.JSONGenerator jg = JSON.createGenerator(false);  
        jg.writeStartObject();              
        jg.writeObjectField(
            'name',
            new Map<String, String>{
                'givenName' => cont.FirstName,
                    'familyName' => cont.LastName
                    }
        );
        
        jg.writeStringField('userName',cont.Email);
        
        jg.writeBooleanField('active', true);        
        jg.writeStringField('preferredLanguage',(String.isEmpty(cont.Core_Preferred_Language__c) ? 'en-US': languageCodeISO4));
        
        jg.writeObjectField('emails', new List<Map<String,Object>>{new Map<String,Object>{'value' => (String.isEmpty(cont.Email)? '' :cont.Email), 'primary' => true }});   
        
        jg.writeObjectField('addresses', new List<Map<String,String>>{new Map<String,String>{'country' => (String.isEmpty(cont.MailingCountryCode)? (String.isEmpty(cont.Account.BillingCountryCode)? '':AccountBillingCountryCodeISO2) : ContactMailingCountryCodeISO2)}});   
        
        jg.writeObjectField('schemas', new List<String>{ system.Label.PRM_Mulesoft_CoreSchema, system.Label.PRM_Mulesoft_IntelUserSchema}); 
        
        if(test.isRunningTest()) {
            //Below line will be executed only while Testclass execution, just for increasing test coverage
            jg.writeObjectField('addresses', new List<Map<String,String>>{new Map<String,String>{'country' => (String.isEmpty(cont.MailingCountryCode)? null :cont.MailingCountryCode)}}); 
        }
        jg.writeEndObject();
        return jg.getAsString();
    }
    
    private static Core_Log_Entry__c createLogEntry(String msg, Contact cont, CustomException ex, String severity){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        
        try{         
            String strTags = '';
            String strDetailsAndEx = '';
            Id recordId = null;
            if(cont!=null) {
                recordId = cont.Id;
                strTags = String.valueOf(cont.Id);           
                if(!String.isEmpty(cont.Email)){
                    strTags = strTags+','+cont.Email;
                }                
            }
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            
            //Name = strLogEntryName, // From Service Cloud
            objCLE.Core_Origin__c = LOG_ENTRY_ORIGIN;
            objCLE.Core_Project__c = LOG_ENTRY_PROJECT;
            objCLE.Core_Scope__c = LOG_ENTRY_SCOPE;
            objCLE.Core_Severity__c = severity;
            objCLE.Core_Message__c = msg;
            objCLE.Core_When__c = system.now();
            //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
            //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
            objCLE.Core_Details__c = strDetailsAndEx;
            objCLE.Core_sObjectId__c = recordId;
            objCLE.Core_sObjectType__c = 'Contact';
            objCLE.Core_Tags__c = strTags;
            
            if(!isBulk){
                insert objCLE;
            }
            else{
                PRM_BulkDataUpload_Batch.listCoreLogEntry.add(objCLE);
            }
        }
        
        catch(Exception e){
            system.debug('Error Cause ==>Log Entry -->'+ e.getCause());
            system.debug('Error Message==>Log Entry -->'+ e.getMessage());
            //system.debug('Error Message==>Log Entry -->'+ ex.ge);
        }
        
        return objCLE; 
    }
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
    
    
    /*US575709 - Start - Expose new Get Profile API in SF for secondary contact, Admin registration & Account Request flows*/
    @AuraEnabled
    public static void SendEmailVerificationAndCreateIdentityInAGS(List<PRM_Account_Contact_Relationship__c> accConRelList){
        system.debug('*************************sendEVtoContact**************');
        Set<Id> contactsIdSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        //  Set<Id> relationNameIdSet = new Set<Id>();
        set<Id> processedContactIds = new Set<Id>();
        Map<Id,Integer> newContactACRNumMap = new Map<Id,Integer>();
        Map<Id,Integer> allContactACRNumMap = new Map<Id,Integer>();
        //Id eRPMOBMUserId = Id.valueOf(Label.PRM_ERPMOBMUserId);
        //This is the list of Partner roles for which Identity should not be created.
        List<String> nonIPApartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(','); 
        try{
            for(PRM_Account_Contact_Relationship__c acr : accConRelList){
                if(!acr.PRM_InActive_Ind__c && 
                   (!acr.PRM_No_Email__c 
                    || (System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger)))
                  ) {
                      if(newContactACRNumMap.containsKey(acr.PRM_Contact_Id__c)){
                          newContactACRNumMap.put(acr.PRM_Contact_Id__c, newContactACRNumMap.get(acr.PRM_Contact_Id__c)+1);
                      }else{
                          newContactACRNumMap.put(acr.PRM_Contact_Id__c, 1);
                      }
                      contactsIdSet.add(acr.PRM_Contact_Id__c);
                      //    relationNameIdSet.add(acr.PRM_Relationship_Id__c);
                  }        
            }
            if(contactsIdSet.size() > 0 ) {
                //Map<id,PRM_ContactRelationships__c> mapConactRelationships = new Map<id,PRM_ContactRelationships__c>([Select id,Name from PRM_ContactRelationships__c where id IN :relationNameIdSet]);
                List<Contact> conList = new List <Contact>();                
                conList = [
                    SELECT
                    id,
                    AccountId,
                    Account.BillingCountryCode,
                    Core_Do_Not_Contact__c,
                    Account.AccountNumber,
                    MailingCountryCode,
                    Account.Name,
                    Core_IPA_PartnerRole__c,
                    Core_Enterprise_Id__c,
                    Core_Preferred_Language__c,
                    Email,
                    (
                        SELECT
                        PRM_Partner_Role__c,
                        PRM_Relationship_Id__r.Name
                        FROM Account_Contact_Relationships__r
                        WHERE PRM_InActive_Ind__c = FALSE
                    )
                    FROM Contact
                    WHERE Id IN :contactsIdSet
                ];
                
                Map<id, Contact> mapContacts = new Map<id, Contact>(conList);
                
                for(Contact cont: mapContacts.values()){                
                    allContactACRNumMap.put(cont.Id, cont.Account_Contact_Relationships__r.size());
                    accountsIdSet.add(cont.AccountId);
                }
                
                Map<Id,Account> mapAccounts = new Map<Id,Account>();
                Map<Id,Set<String>> mapAcctIdACMPartnerRoles = new Map<Id,Set<String>>();
                if(accountsIdSet.size() > 0){
                    mapAccounts = new Map<Id,Account>([SELECT Id,Name,
                                                       (SELECT Id,PRM_Partner_Role__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Pending' /*AND PRM_Partner_Role__c IN :partnerRoles*/ ) 
                                                       FROM Account WHERE Id IN :accountsIdSet]);
                    if(mapAccounts.size() > 0){
                        for(Account acct: mapAccounts.values()){
                            for(PRM_AccountChannelMembership__c acm: acct.Channel_Memberships1__r ){
                                if(mapAcctIdACMPartnerRoles.containsKey(acct.Id)){
                                    mapAcctIdACMPartnerRoles.get(acct.Id).add(acm.PRM_Partner_Role__c);
                                }else{
                                    mapAcctIdACMPartnerRoles.put(acct.Id, new Set<String>{acm.PRM_Partner_Role__c});
                                }
                            }
                        }
                    }
                }
                //system.debug('TestAcct mapAccounts ==>'+mapAccounts);
                for(PRM_Account_Contact_Relationship__c acctContRel : accConRelList){
                    //&& acctContRel.CreatedById != eRPMOBMUserId 
                    if(!processedContactIds.contains(acctContRel.PRM_Contact_Id__c) && !acctContRel.PRM_InActive_Ind__c
                       && mapContacts.containskey(acctContRel.PRM_Contact_Id__c) && allContactACRNumMap.get(acctContRel.PRM_Contact_Id__c) == newContactACRNumMap.get(acctContRel.PRM_Contact_Id__c)
                       && (!acctContRel.PRM_No_Email__c || (System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger)))){ //Check if already sent for Identity Creation
                            Contact cont = mapContacts.get(acctContRel.PRM_Contact_Id__c);
                           //String contPartnerRoles = cont.Core_IPA_Partner_Role__c;
                           String contPartnerRoles = cont.Core_IPA_PartnerRole__c;
                           //Restrict identity creation for non-IPA partner roles (configured)
                           if(!String.isEmpty(contPartnerRoles) && !nonIPApartnerRoles.contains(contPartnerRoles)){  
                               String strTags = '';
                               if(!String.isEmpty(cont.Core_Enterprise_Id__c)){
                                   strTags = cont.Core_Enterprise_Id__c;
                               }                               
                               if(!String.isEmpty(cont.Email)){
                                   strTags = (strTags=='') ? cont.Email : strTags+' , '+cont.Email;
                               }       
                               //system.debug('TestAcct contPartnerRoles ==>'+contPartnerRoles);
                               //if(!String.isEmpty(contPartnerRoles)){
                               for(String partnerRole : contPartnerRoles.split(';')){
                                   //Check if IPA Contact                                    
                                   //if(partnerRoles.contains(partnerRole) && mapAccounts.containskey(cont.AccountId)) {
                                   if(mapAccounts.containskey(cont.AccountId) && ((mapAcctIdACMPartnerRoles.containsKey(cont.AccountId) && mapAcctIdACMPartnerRoles.get(cont.AccountId).contains(partnerRole))|| 
                                                                                  acctContRel.PRM_Status_Nm__c == 'Pending Action' || String.IsEmpty(cont.Core_Enterprise_Id__c) )) { //As a part of CiDaaS change
                                                                                      //New Contact - Admin Registration or secondary contact addition || Existing contact without Enterprise Id
                                                                                      if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                                                                                          if(!mapOfContactSentForIdentity.containsKey(cont.id) || (mapOfContactSentForIdentity.containsKey(cont.id) && mapOfContactSentForIdentity.get(cont.id) == false)){
                                                                                              PRM_AGS_IdentityCreation.createIdentityInAGSAsync(acctContRel.PRM_Contact_Id__c); //Future method to make call out to MuleSoft API  
                                                                                              mapOfContactSentForIdentity.put(cont.id, true);
                                                                                          }
                                                                                      }
                                                                                      else if(System.isBatch() &&  PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger) { 
                                                                                          if(!mapOfContactSentForIdentity.containsKey(cont.id) || (mapOfContactSentForIdentity.containsKey(cont.id) && mapOfContactSentForIdentity.get(cont.id) == false)){
                                                                                              PRM_AGS_IdentityCreation.createIdentityInAGSAsyncBulk(acctContRel.PRM_Contact_Id__c); //Future method to make call out to MuleSoft API  
                                                                                              mapOfContactSentForIdentity.put(cont.id, true);
                                                                                          }
                                                                                          //Commented because for Bulk Invites we have to suppress the usual IPA invite emails
                                                                                          /*else{
System.debug('Entered else cont.Core_IPA_Email_Verification_Date__c'+cont.Core_IPA_Email_Verification_Date__c);
if(String.isNotBlank(String.valueOf(cont.Core_IPA_Email_Verification_Date__c))){
PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
}else{
PRM_AGS_IdentityCreation.reTriggerEVFuture(cont.Id);
} 
}*/ //Commented to Suppress email for Bulk Invite/Add 
                                                                                      }
                                                                                  }else if(String.isNotBlank(cont.Core_Enterprise_Id__c) && !(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                                                                                                                                                                               
                                                                                          //PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                                                                          /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
                                                                                          if(IS_DelayInviteEmail){
                                                                                              CreateBatchEntitlements(cont, null, strTags,'Admin Invite Email');
                                                                                          }
                                                                                          else{
                                                                                              PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                                                                          }                                                                                      
                                                                                  }
                                   break;
                                   //}
                               }//End of Partner Roles For loop
                           }//ENd of Partner Roles IF 
                       }//ENd of User Check 
                    processedContactIds.add(acctContRel.PRM_Contact_Id__c);
                }//End of FOR Loop
            }//End of IF             
        }//End of try
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
        }
    }
    
    public static void ReInviteBySendingEmailVerification(Map<Id,PRM_Account_Contact_Relationship__c> accConRelMapOld , List<PRM_Account_Contact_Relationship__c> accConRelListNew)
    {
        Set<Id> contactsIdSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        Set<Id> relationsIdSet = new Set<Id>();
        set<Id> processedContactIds = new Set<Id>();
        List<PRM_Account_Contact_Relationship__c> acrListforUpdate = new List<PRM_Account_Contact_Relationship__c>();
        
        //This is the list of Partner roles for which Identity should not be created.
        List<String> nonIPApartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        try{
            for(PRM_Account_Contact_Relationship__c acr : accConRelListNew)
            {
                contactsIdSet.add(acr.PRM_Contact_Id__c);
                accountsIdSet.add(acr.PRM_Account_Id__c);
                relationsIdSet.add(acr.PRM_Relationship_Id__c);
            }
            
            if (contactsIdSet.size() > 0) {
                List<Contact> conList = new List<Contact>();
                
                conList = [
                    SELECT
                    id,
                    AccountId,
                    Account.BillingCountryCode,
                    Account.AccountNumber,
                    MailingCountryCode,
                    Account.Name,
                    Core_IPA_PartnerRole__c,
                    Core_Enterprise_Id__c,
                    Core_Preferred_Language__c,
                    Email
                    FROM Contact
                    WHERE Id IN :contactsIdSet
                ];                
                Map<id, Contact> mapContacts = new Map<id, Contact>(conList);
                
                Map<Id,PRM_ContactRelationships__c> relMap = new Map<Id, PRM_ContactRelationships__c> ([Select Id,PRM_Contact_Relationship_Cd__c from PRM_ContactRelationships__c where Id IN:relationsIdSet]);
                
                Map<Id,Set<String>> mapAcctIdACMPartnerRoles = new Map<Id,Set<String>>();
                if(accountsIdSet.size() > 0)
                {
                    for(PRM_AccountChannelMembership__c acm: [SELECT Id,PRM_Partner_Role__c,PRM_Account_Id__c FROM PRM_AccountChannelMembership__c WHERE PRM_Status_Nm__c='Approved' and PRM_Account_Id__c IN : accountsIdSet])
                    {
                        if(mapAcctIdACMPartnerRoles.containsKey(acm.PRM_Account_Id__c))
                        {
                            mapAcctIdACMPartnerRoles.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }
                        else
                        {
                            mapAcctIdACMPartnerRoles.put(acm.PRM_Account_Id__c, new Set<String>{acm.PRM_Partner_Role__c});
                        }
                    }               
                    
                }
                
                System.debug('ReInviteBySendingEmailVerification mapAcctIdACMPartnerRoles'+mapAcctIdACMPartnerRoles);
                for(PRM_Account_Contact_Relationship__c acr : accConRelListNew)
                {           
                    
                    if(!processedContactIds.contains(acr.PRM_Contact_Id__c) && mapContacts.containsKey(acr.PRM_Contact_Id__c)
                       //&& accConRelMapOld.get(acr.Id).PRM_Status_Nm__c =='Complete' && acr.PRM_Status_Nm__c =='Pending Action'
                       && acr.PRM_Status_Nm__c ==STATUS_PENDING_ACTION
                       && accConRelMapOld.get(acr.Id).PRM_InActive_Ind__c && !acr.PRM_InActive_Ind__c && Label.AllowedReInviteRelationshipList.split(',').contains(relMap.get(acr.PRM_Relationship_Id__c).PRM_Contact_Relationship_Cd__c))
                    {
                        Contact cont = mapContacts.get(acr.PRM_Contact_Id__c);
                        String contPartnerRole = cont.Core_IPA_PartnerRole__c;
                        
                        if(!String.isEmpty(contPartnerRole) && !nonIPApartnerRoles.contains(contPartnerRole))
                        {
                            String strTags = '';
                            if(!String.isEmpty(cont.Core_Enterprise_Id__c)){
                                strTags = cont.Core_Enterprise_Id__c;
                            }
                            
                            if(!String.isEmpty(cont.Email)){
                                strTags = (strTags=='') ? cont.Email : strTags+' , '+cont.Email;
                            }
                            
                            //Check if IPA Contact
                            if(mapAcctIdACMPartnerRoles.containsKey(cont.AccountId) && mapAcctIdACMPartnerRoles.get(cont.AccountId).contains(contPartnerRole)) 
                            {
                                if(String.IsEmpty(cont.Core_Enterprise_Id__c))
                                {
                                    if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                                        //Existing contact without Enterprise Id
                                        PRM_AGS_IdentityCreation.createIdentityInAGSAsync(acr.PRM_Contact_Id__c); //Future method to make call out to MuleSoft API  
                                    }
                                    } else if (
                                    (String.isNotBlank(
                                        cont.Core_Enterprise_Id__c
                                    )) &&
                                    !(System.isBatch() &&
                                      (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))
                                ) {                                                                        
                                    //PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont,null,strTags);
                                    /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
                                    if(IS_DelayInviteEmail){
                                        CreateBatchEntitlements(cont, null, strTags,'Admin Invite Email');
                                    }
                                    else{
                                        PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                    }
                                    
                                    //Send email if already identity created
                                    // system.debug('ReInviteBySendingEmailVerification sendEmailToContact');
                                    //PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                }
                            }else
                            {
                                if(String.IsEmpty(cont.Core_Enterprise_Id__c))
                                {
                                    if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                                        //Existing contact without Enterprise Id
                                        PRM_AGS_IdentityCreation.createIdentityInAGSAsync(acr.PRM_Contact_Id__c); //Future method to make call out to MuleSoft API
                                    }
                                } else if((String.isNotBlank(cont.Core_Enterprise_Id__c)) && 
                                          !(System.isBatch() && 
                                            (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || 
                                             PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))
                                          
                                         ){                                             
                                             if ((!mapOfContactSentForIdentity.containsKey(acr.PRM_Contact_Id__c) ||
                                                  (mapOfContactSentForIdentity.containsKey(acr.PRM_Contact_Id__c) &&
                                                   mapOfContactSentForIdentity.get(acr.PRM_Contact_Id__c) == false))
                                                ) {                                                    
                                                    /*PRM_Contact_AGS_CallbackHandler.sendEmailToContact(
cont,
null,
strTags
);*/
                                                    /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
                                                    if(IS_DelayInviteEmail){
                                                        CreateBatchEntitlements(cont, null, strTags,'Admin Invite Email');
                                                    }
                                                    else{
                                                        PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                                    }
                                                    
                                                    mapOfContactSentForIdentity.put( acr.PRM_Contact_Id__c,true);
                                                }                                             
                                         }
                            }
                            
                            /*else
{
System.debug('ReInviteBySendingEmailVerification : ACM is Inactive/Partner Role does not match any ACM Partner Role');
PRM_Account_Contact_Relationship__c updateACR = new PRM_Account_Contact_Relationship__c(Id=acr.Id);
updateACR.PRM_Status_Nm__c = 'Complete';
updateACR.PRM_InActive_Ind__c = True;
updateACR.PRM_Status_Reason_Txt__c = 'ACM is Inactive/Partner Role does not match any ACM Partner Role';
acrListforUpdate.add(updateACR);
}*/
                            
                        }//End of Partner Roles IF 
                        processedContactIds.add(acr.PRM_Contact_Id__c);                    
                    }
                    
                } //End of For
            } // End of If  
            
            if(acrListforUpdate.size() > 0)
            {
                update acrListforUpdate;
            }
        }
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e); 
        }
    }
    
    public static void updateAcctContRelation_StatusField(List<PRM_Account_Contact_Relationship__c> accConRelList){
        Set<Id> contactsIdSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        //Set<Id> relationNameIdSet = new Set<Id>();         
        //Id eRPMOBMUserId = Id.valueOf(Label.PRM_ERPMOBMUserId);        
        List<String> nonIPApartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(','); 
        boolean isPending = false;
        try{
            for(PRM_Account_Contact_Relationship__c acr : accConRelList){
                if(!acr.PRM_InActive_Ind__c && !acr.PRM_No_Email__c) {
                    contactsIdSet.add(acr.PRM_Contact_Id__c);
                    //             relationNameIdSet.add(acr.PRM_Relationship_Id__c);
                }        
            }
            if(contactsIdSet.size() > 0 ) {
                //Map<id,PRM_ContactRelationships__c> mapConactRelationships = new Map<id,PRM_ContactRelationships__c>([Select id,Name from PRM_ContactRelationships__c where id IN :relationNameIdSet]);
                List<Contact> conList = new List<Contact>();
                
                conList = [
                    SELECT
                    Id,
                    AccountId,
                    Core_Enterprise_Id__c,
                    Core_IPA_PartnerRole__c,
                    (SELECT id, 
                     PRM_Status_Nm__c, 
                     PRM_InActive_Ind__c 
                     FROM Account_Contact_Relationships__r 
                     WHERE PRM_InActive_Ind__c = FALSE AND PRM_Status_Nm__c = 'Complete')
                    FROM Contact
                    WHERE Id IN :contactsIdSet
                ];
                Map<id, Contact> mapContacts = new Map<id, Contact>(conList);
                Map<Id, Account> mapAccounts = new Map<Id, Account>();
                Map<Id, Set<String>> mapAcctIdACMPartnerRoles = new Map<Id, Set<String>>();
                for (Contact cont : mapContacts.values()) {
                    //if(!cont.Core_IPA_Contact_Assignment__c){
                    accountsIdSet.add(cont.AccountId);
                }
                if(accountsIdSet.size() > 0){
                    mapAccounts = new Map<Id,Account>([SELECT Id,Name,
                                                       (SELECT Id,PRM_Partner_Role__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Pending' /*AND PRM_Partner_Role__c IN :partnerRoles*/) 
                                                       FROM Account WHERE Id IN :accountsIdSet]);
                    if(mapAccounts.size() > 0){
                        for(Account acct: mapAccounts.values()){
                            for(PRM_AccountChannelMembership__c acm: acct.Channel_Memberships1__r ){
                                if(mapAcctIdACMPartnerRoles.containsKey(acct.Id)){
                                    mapAcctIdACMPartnerRoles.get(acct.Id).add(acm.PRM_Partner_Role__c);
                                }else{
                                    mapAcctIdACMPartnerRoles.put(acct.Id, new Set<String>{acm.PRM_Partner_Role__c});
                                }
                            }
                        }
                    }
                }           
                if(accountsIdSet.size() > 0){
                    for(PRM_Account_Contact_Relationship__c acctContRel : accConRelList){
                        isPending = false;
                        if(!acctContRel.PRM_No_Email__c  && mapContacts.containsKey(acctContRel.PRM_Contact_Id__c) && mapContacts.get(acctContRel.PRM_Contact_Id__c).Account_Contact_Relationships__r.size()==0 && !acctContRel.PRM_InActive_Ind__c ){
                            Contact cont = mapContacts.get(acctContRel.PRM_Contact_Id__c);
                            //String contPartnerRoles = cont.Core_IPA_Partner_Role__c;   
                            String contPartnerRoles = cont.Core_IPA_PartnerRole__c;       
                            //Restrict updating status for non-IPA partner roles
                            if(!String.isEmpty(contPartnerRoles) && !nonIPApartnerRoles.contains(contPartnerRoles)){                
                                for(String partnerRole : contPartnerRoles.split(';')){
                                    //Check if IPA Contact and Works For Relationship, and No enterprise id
                                    //if(partnerRoles.contains(partnerRole) && ((mapAccounts.containsKey(cont.AccountId) && mapAccounts.get(cont.AccountId).Channel_Memberships1__r.size() == 0 ) && (String.IsEmpty(cont.Core_Enterprise_Id__c) || String.isEmpty(String.valueOf(cont.Core_IPA_Email_Verification_Date__c)) ))) {    
                                    //if(/*partnerRoles.contains(partnerRole) &&*/(!mapAcctIdACMPartnerRoles.containsKey(cont.AccountId) && (String.IsEmpty(cont.Core_Enterprise_Id__c) || String.isEmpty(String.valueOf(cont.Core_IPA_Email_Verification_Date__c)) ))) { 
                                    if(!mapAcctIdACMPartnerRoles.containsKey(cont.AccountId) ) { 
                                        acctContRel.PRM_Status_Nm__c = 'Pending Action'; 
                                        acctContRel.PRM_Status_Reason_Txt__c ='Registration from '+acctContRel.PRM_Source_Agent__c;//TWC729-8089 : Adding reason text : NJ  
                                        isPending = true;
                                        break;
                                    }
                                }
                            }
                            if(!isPending && String.isEmpty(acctContRel.PRM_Status_Nm__c)){
                                acctContRel.PRM_Status_Nm__c = 'Complete'; 
                                acctContRel.PRM_Status_Reason_Txt__c ='Set to complete post Identity Creation';//TWC729-8089 : Adding reason text : NJ  
                                acctContRel.PRM_Start_Date_Dt__c = Date.today();
                            }
                        }else{
                            if(!isPending && String.isEmpty(acctContRel.PRM_Status_Nm__c)){
                                acctContRel.PRM_Status_Nm__c = 'Complete'; 
                                acctContRel.PRM_Status_Reason_Txt__c ='Set to complete post Identity Creation';//TWC729-8089 : Adding reason text : NJ  
                                acctContRel.PRM_Start_Date_Dt__c = Date.today();
                            }
                        }
                        if(acctContRel.PRM_Source_Agent__c == null){
                            acctContRel.PRM_Source_Agent__c = 'Partner Invite';
                            acctContRel.PRM_CampaignId__c = null;
                            acctContRel.Bulk_Data_Upload__c=null;
                        }
                    }//End of For Loop
                }
            }  
        }
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
        }
    }
    /*Finish - US575709*/
    
    //Added below method as a part of TWC729-1307 when AGS Identity creation is Retriggered, updating the Status of ACR to 'Pending Action' and Status Reason
    public static void updateACRStatusOnAgsIdentityCreationFailure(Id contactId,Boolean isSuccess){
        List<PRM_Account_Contact_Relationship__c> acrUpdateList = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        
        for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Contact_Id__r.Id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,CreatedBy.Username, CreatedById,PRM_Contact_Id__r.name,PRM_Contact_Id__r.email,PRM_AGS_Identity_Creation_Fail__c,name,         
                                                       PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,PRM_Source_Agent__c,PRM_Initiated_By__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__r.Id =:contactId])                                                               
        {
            if(isSuccess){
                if(acr.PRM_AGS_Identity_Creation_Fail__c == true){
                    acr.PRM_AGS_Identity_Creation_Fail__c = false;
        acrList.add(acr);
                }
                
            }else if(!isSuccess){
                acr.PRM_AGS_Identity_Creation_Fail__c = true ;
                acr.PRM_Initiated_By__c=UserInfo.getUserId();
                if(acr.PRM_Status_Reason_Txt__c != ''){
                    acr.PRM_Status_Reason_Txt__c = String.join(new List<String>{acr.PRM_Status_Reason_Txt__c}, ',');
                }else{
                    acr.PRM_Status_Reason_Txt__c = System.label.PRM_ACR_Status_AGS_Identity_Creation_Failed;
                }
                acrList.add(acr);
                
            }
        }
        
        System.debug('ACR List'+acrList);
        System.debug('Acr update list'+acrUpdateList);
        if (!acrList.IsEmpty() ) {
            if(isBulk == false){
                /*if(!isSuccess){
                PRM_AGS_IdentityCreation.sendEmailToAdminOnAgsIdentityCreationFailure(acrList) ;  
                }*/
                update acrList;
            } else {
                PRM_BulkDataUpload_Batch.listAcrUpdateMulefailure.addAll(
                    acrList
                );
            }
        }
        
        if(mailList != null && !mailList.IsEmpty()){
            Messaging.sendEmail(mailList);
        }
    }
    
    //Added below method as a part of TWC729-1307, this method will return list of ACR's with respect to corresponding Contact
    @AuraEnabled
    public static List<PRM_Account_Contact_Relationship__c> getACRList(Id contactId) { 
        List<PRM_Account_Contact_Relationship__c> acrReturnList = new List<PRM_Account_Contact_Relationship__c>();
        if(contactId != null){
            for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Contact_Id__r.Id,PRM_Contact_Id__r.Core_Enterprise_Id__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__r.Id =:contactId]){
                acrReturnList.add(acr);
            }
            
        } 
        return acrReturnList;
    }
    @future(callout=true)
    public static void reTriggerEVFuture(Id contactId) {
        Contact cont = new Contact();
        
        cont = [
            SELECT
            id,
            AccountId,
            Account.Name,
            Account.AccountNumber,
            Account.BillingCountryCode,
            MailingCountryCode,
            Core_IPA_PartnerRole__c,
            Core_Do_Not_Contact__c,
            Core_Enterprise_Id__c,
            Core_Preferred_Language__c,
            Email,
            (
                SELECT PRM_Partner_Role__c, PRM_Relationship_Id__r.Name
                FROM Account_Contact_Relationships__r
                WHERE PRM_InActive_Ind__c = FALSE
            )
            FROM Contact
            WHERE Id = :contactId];
        
        String newEVToken = PRM_RetriggerEV_Token_API.reTriggerEV(cont.Email);
        String strTags = '';
        if(!String.isEmpty(cont.Core_Enterprise_Id__c)){
            strTags = cont.Core_Enterprise_Id__c;
        }
        
        if(!String.isEmpty(cont.Email)){
            strTags = (strTags=='') ? cont.Email : strTags+' , '+cont.Email;
        }                  
        if(!String.isEmpty(newEVToken))
        {
            //PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, newEVToken, strTags);
        /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
         if(IS_DelayInviteEmail){
          CreateBatchEntitlements(cont, null, strTags,'Admin Invite Email');
         }
         else{
           PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
         }
        }
    }  
    /*public static void sendEmailToAdminOnAgsIdentityCreationFailure(List<PRM_Account_Contact_Relationship__c> acrList){
        
        List <Messaging.SingleEmailMessage> mailList = new List <Messaging.SingleEmailMessage> ();
        string EmailBody = ' ' ;
        List<String> EmailidList  = new List<String>();
        String recordLink = '';                   
        String emailLink = '' ;                   
        //string devIpa = 'https://quoterequest.intel.com/--crmqa3.lightning.force.com/lightning/r/PRM_Account_Contact_Relationship__c/';
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        EmailTemplate templateId = [select id, name,HtmlValue,Body,Subject from EmailTemplate where developername =: system.label.IPA_AGS_IdentityFail_TEMPLATE ];
        System.debug('templateId '+ templateId);
        EmailidList.add(UserInfo.getUserEmail());
        if(!acrList.Isempty()  ){
            
            for(PRM_Account_Contact_Relationship__c acr : acrList){
                if (acr.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c == true){    
                    emailLink = acr.PRM_Contact_Id__r.email ;                                   
                    recordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+acr.Id;      
                }                                                                             
                system.debug('the record url is '+recordLink);
                system.debug('The value of the acr is'+acr);
            }
        }
        
        if(EmailBody != null && emailLink !='' && recordLink != ''){ 
            system.debug('---> Inside Acc Name String');
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('%%email Id%%', emailLink); 
            htmlBody = htmlBody.replace('%link%', recordLink); 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId 
            mail.setTargetObjectId( UserInfo.getUserId() );
            mail.setSubject(templateId.Subject);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            mail.setToAddresses(EmailidList);
            mail.setTemplateId(templateId.id);
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
            } 
            mailList.add(mail);
            system.debug('EmailBody ' +EmailBody);  
            system.debug('Email List to send for Public Group' +mailList);
            try{
                if(mailList != null && !mailList.IsEmpty()){
                    Messaging.sendEmail(mailList);
                }
            }
            catch(Exception e){
                system.debug('Exception occured' +e.getMessage());
            }
        }                
    }*/
    /*Utkarsh - TWC727-695 - This method creates batch entitlement record to Send invite email to user after 5 minutes of B2C creation*/
  public static void CreateBatchEntitlements(Contact contId,String evToken,String strTags,String source){
    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
    be.PRM_Contact_Id__c = contId.Id;
    be.PRM_EV_Token__c = evToken;
    be.PRM_IdentityAttribute__c = strTags;
    be.PRM_Status_Nm__c = 'New';
    be.PRM_Status_Reason_Txt__c ='PRM_AGS_IdentityCreation - Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ 
    be.Source__c = source;
    insert be;
  }  
}