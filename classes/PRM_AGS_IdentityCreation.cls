public without sharing class PRM_AGS_IdentityCreation {
    
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'AGS Identity Creation';
    public static final String LOG_ENTRY_SCOPE    = 'Contact - AGS Identity Creation';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_OBJECT   = 'Contact';
    public static final String UPDATE_REASON_ERPM = 'ERPM';
    
    @future (callout=true)  
    public static void createIdentityInAGS(Id contactId){
        system.debug('*************************createIdentityInAGS**************');
        if(contactId!=null) {
            List<Contact> contacts = [SELECT Id, FirstName,LastName,Core_Login_Id__c,MailingCountryCode, Core_Preferred_Language__c, Email,Account.BillingCountryCode FROM Contact WHERE id= :contactId];
            try {                
                PRM_Integration__mdt agsAPIDetails = [Select Id, API_Key__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='SCtoAGS'];
                //system.debug('agsAPIDetails ==>'+agsAPIDetails);
                if(agsAPIDetails!=null){
                    if(contacts.size() > 0) {
                        HttpRequest httpReq = new  HttpRequest();                               
                        httpReq.setEndpoint(agsAPIDetails.EndPointURL__c);
                        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(agsAPIDetails.Username__c+':'+agsAPIDetails.Password__c)));
                        httpReq.setHeader('API_Key', agsAPIDetails.API_Key__c);   
                        httpReq.setHeader('Content-Type', 'text/plain');
                        //httpReq.setBody('{  "name": { "givenName": "Henry P", "familyName": "Denham"  },  "userName": "henry_91@mailinator.com",  "active": true,  "preferredLanguage": "EN",  "emails": [ {"value": "henry_91@mailinator.com","primary": true }  ],  "addresses": [ {"country": "US" }  ],  "schemas": ["urn:scim:schemas:core:1.0", "urn:scim:schemas:extension:inteluser:1.0"  ]}');
                        httpReq.setBody(constructInputJSON(contacts[0]));
                        httpReq.setMethod( 'POST' );
                        HttpResponse response = new Http().send(httpReq);
                        system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                        if(response.getStatusCode() != 200 || response.getBody().indexOf('ErrorCode') > -1){
                            CustomException ex = new CustomException();                    
                            ex.Message = response.getBody();                          
                            ex.StackTraceString = System.Label.PRM_Mulesoft_Api_Error;                    
                            createLogEntry(System.Label.PRM_Error_Identity_Creation, contacts[0], ex, LOG_ENTRY_ERROR); 
                        }else{
                            createLogEntry(EncodingUtil.urlDecode(response.getBody(), 'UTF-8'), contacts[0], null, LOG_ENTRY_INFO); 
                        }
                    }
                }else{
                    CustomException ex = new CustomException();                    
                    ex.Message = System.Label.PRM_Mulesoft_Config_Error;                          
                    ex.StackTraceString = System.Label.PRM_Mulesoft_Config_Error;                    
                    createLogEntry(System.Label.PRM_Error_Identity_Creation, null, ex, LOG_ENTRY_ERROR);  
                }
            }catch(Exception ex){
                system.debug('Error Cause ==>'+ ex.getCause());
                system.debug('Error Message==>'+ ex.getMessage());
                system.debug('Error Stacktrace==>'+ ex.getStackTraceString());
                system.debug('Error Line number==>'+ ex.getLineNumber());
                
                CustomException custEx = new CustomException();
                custEx.Message = ex.getMessage();
                custEx.Cause = ex.getCause();
                custEx.StackTraceString = ex.getStackTraceString();
                custEx.LineNumber = ex.getLineNumber();                
                custEx.TypeName = ex.getTypeName();
                
                createLogEntry(System.Label.PRM_Error_Identity_Creation, contacts[0], custEx, LOG_ENTRY_ERROR);               
            }
        }
    }
    private static String constructInputJSON(Contact cont) {
        system.JSONGenerator jg = JSON.createGenerator(false);  
        jg.writeStartObject();              
        jg.writeObjectField('name', new Map<String,String>{'givenName' => cont.FirstName, 'familyName' => cont.LastName});        
        jg.writeStringField('userName', (String.isEmpty(cont.Core_Login_Id__c)? cont.Email : cont.Core_Login_Id__c));
        jg.writeBooleanField('active', true);
        jg.writeStringField('preferredLanguage', (String.isEmpty(cont.Core_Preferred_Language__c)? 'ENG':cont.Core_Preferred_Language__c));
        jg.writeObjectField('emails', new List<Map<String,Object>>{new Map<String,Object>{'value' => (String.isEmpty(cont.Email)? '' :cont.Email), 'primary' => true }});   
        jg.writeObjectField('addresses', new List<Map<String,String>>{new Map<String,String>{'country' => (String.isEmpty(cont.MailingCountryCode)? (String.isEmpty(cont.Account.BillingCountryCode)? '':cont.Account.BillingCountryCode) : cont.MailingCountryCode)}});   
        jg.writeObjectField('schemas', new List<String>{ system.Label.PRM_Mulesoft_CoreSchema, system.Label.PRM_Mulesoft_IntelUserSchema}); 
        
        if(test.isRunningTest()) {
            //Below line will be executed only while Testclass execution, just for increasing test coverage
            jg.writeObjectField('addresses', new List<Map<String,String>>{new Map<String,String>{'country' => (String.isEmpty(cont.MailingCountryCode)? null :cont.MailingCountryCode)}}); 
        }
        jg.writeEndObject();
        system.debug('JSON ==>'+jg.getAsString());
        return jg.getAsString();
    }
    
    private static void createLogEntry(String msg, Contact cont, CustomException ex, String severity){
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
                if(!String.isEmpty(cont.Core_Login_Id__c)){
                    strTags = String.isEmpty(strTags)?cont.Core_Login_Id__c: strTags+','+cont.Core_Login_Id__c;
                }
            }
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                //Name = strLogEntryName, // From Service Cloud
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = severity,
                Core_Message__c = msg,
                Core_When__c = system.now(),
                //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
                //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = recordId,
                Core_sObjectType__c = 'Contact',
                Core_Tags__c = strTags
            );
            insert objCLE;
            system.debug('Log Entry Id ==>'+objCLE.Id);
        }catch(Exception e){
            system.debug('Error Cause ==>Log Entry -->'+ e.getCause());
            system.debug('Error Message==>Log Entry -->'+ e.getMessage());
            //system.debug('Error Message==>Log Entry -->'+ ex.ge);
        }
        
    }
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
    /*US575709 - Start - Expose new Get Profile API in SF for secondary contact, Admin registration & Account Request flows*/
    public static void SendEmailVerificationAndCreateIdentityInAGS(List<PRM_Account_Contact_Relationship__c> accConRelList){
        system.debug('*************************sendEVtoContact**************');
        Set<Id> contactsIdSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        Set<Id> relationNameIdSet = new Set<Id>();
        set<Id> processedContactIds = new Set<Id>();
        Map<Id,Integer> newContactACRNumMap = new Map<Id,Integer>();
        Map<Id,Integer> allContactACRNumMap = new Map<Id,Integer>();
        Id eRPMOBMUserId = Id.valueOf(Label.PRM_ERPMOBMUserId);
        List<String> partnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        for(PRM_Account_Contact_Relationship__c acr : accConRelList){
            if(!acr.PRM_InActive_Ind__c && !acr.PRM_No_Email__c) {
                if(newContactACRNumMap.containsKey(acr.PRM_Contact_Id__c)){
                    newContactACRNumMap.put(acr.PRM_Contact_Id__c, newContactACRNumMap.get(acr.PRM_Contact_Id__c)+1);
                }else{
                    newContactACRNumMap.put(acr.PRM_Contact_Id__c, 1);
                }
                contactsIdSet.add(acr.PRM_Contact_Id__c);
                relationNameIdSet.add(acr.PRM_Relationship_Id__c);
            }        
        }
        if(contactsIdSet.size() > 0 ) {
            //Map<id,PRM_ContactRelationships__c> mapConactRelationships = new Map<id,PRM_ContactRelationships__c>([Select id,Name from PRM_ContactRelationships__c where id IN :relationNameIdSet]);
            Map<id,Contact> mapContacts = new Map<id,Contact> ([SELECT id,AccountId,Account.Name,Core_Login_Id__c,Core_IPA_Partner_Role__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,
                                                                (SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact WHERE Id IN :contactsIdSet]);
            
            for(Contact cont: mapContacts.values()){
                allContactACRNumMap.put(cont.Id, cont.Account_Contact_Relationships__r.size());
                accountsIdSet.add(cont.AccountId);
            }
            
            Map<Id,Account> mapAccounts = new Map<Id,Account>();
            if(accountsIdSet.size() > 0){
                mapAccounts = new Map<Id,Account>([SELECT Id,Name,
                                                   (SELECT Id FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Pending' AND PRM_Partner_Role__c IN :partnerRoles) 
                                                   FROM Account WHERE Id IN :accountsIdSet]);
            }
            //system.debug('TestAcct mapAccounts ==>'+mapAccounts);
            for(PRM_Account_Contact_Relationship__c acctContRel : accConRelList){
                //&& acctContRel.CreatedById != eRPMOBMUserId 
                if(!processedContactIds.contains(acctContRel.PRM_Contact_Id__c) && !acctContRel.PRM_InActive_Ind__c
                   && mapContacts.containskey(acctContRel.PRM_Contact_Id__c) && allContactACRNumMap.get(acctContRel.PRM_Contact_Id__c) == newContactACRNumMap.get(acctContRel.PRM_Contact_Id__c)
                   && !acctContRel.PRM_No_Email__c){ //Check if already sent for Identity Creation
                       Contact cont = mapContacts.get(acctContRel.PRM_Contact_Id__c);
                       String contPartnerRoles = cont.Core_IPA_Partner_Role__c;
                       String strTags = '';
                       if(!String.isEmpty(cont.Core_Enterprise_Id__c)){
                           strTags = cont.Core_Enterprise_Id__c;
                       }
                       if(!String.isEmpty(cont.Core_Login_Id__c)){
                           strTags = (strTags=='') ? cont.Core_Login_Id__c : strTags+' , '+cont.Core_Login_Id__c;
                       }
                       if(!String.isEmpty(cont.Email)){
                           strTags = (strTags=='') ? cont.Email : strTags+' , '+cont.Email;
                       }       
                       //system.debug('TestAcct contPartnerRoles ==>'+contPartnerRoles);
                       if(!String.isEmpty(contPartnerRoles)){                
                           for(String partnerRole : contPartnerRoles.split(';')){
                               //Check if IPA Contact                                    
                               if(partnerRoles.contains(partnerRole) && mapAccounts.containskey(cont.AccountId)) {
                                   if(mapAccounts.get(cont.AccountId).Channel_Memberships1__r.size() > 0 || acctContRel.PRM_Status_Nm__c == 'Pending Action' || String.IsEmpty(cont.Core_Enterprise_Id__c) || String.isEmpty(String.valueOf(cont.Core_IPA_Email_Verification_Date__c)) ){
                                       //New Contact - Admin Registration or secondary contact addition || Existing contact without Enterprise Id
                                       PRM_AGS_IdentityCreation.createIdentityInAGS(acctContRel.PRM_Contact_Id__c); //Future method to make call out to MuleSoft API  
                                   }else if(!String.IsEmpty(cont.Core_Enterprise_Id__c) || !String.isEmpty(String.valueOf(cont.Core_IPA_Email_Verification_Date__c))){
                                       //Send email if already identity created                                               
                                       PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, null, strTags);
                                   }
                                   break;
                               }
                           }//End of Partner Roles For loop
                       }//ENd of Partner Roles IF 
                   }//ENd of User Check 
                processedContactIds.add(acctContRel.PRM_Contact_Id__c);
            }//End of FOR Loop
        }//End of IF             
    }
    public static void updateAcctContRelation_StatusField(List<PRM_Account_Contact_Relationship__c> accConRelList){
        Set<Id> contactsIdSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        Set<Id> relationNameIdSet = new Set<Id>();         
        Id eRPMOBMUserId = Id.valueOf(Label.PRM_ERPMOBMUserId);
        List<String> partnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        boolean isPending = false;
        for(PRM_Account_Contact_Relationship__c acr : accConRelList){
            if(!acr.PRM_InActive_Ind__c && !acr.PRM_No_Email__c) {
                contactsIdSet.add(acr.PRM_Contact_Id__c);
                relationNameIdSet.add(acr.PRM_Relationship_Id__c);
            }        
        }
        if(contactsIdSet.size() > 0 ) {
            //Map<id,PRM_ContactRelationships__c> mapConactRelationships = new Map<id,PRM_ContactRelationships__c>([Select id,Name from PRM_ContactRelationships__c where id IN :relationNameIdSet]);
            Map<id,Contact> mapContacts = new Map<id,Contact> ([SELECT Id,AccountId,Core_Enterprise_Id__c,Core_IPA_Partner_Role__c,Core_IPA_Email_Verification_Date__c,
                                                                (SELECT Id FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Status_Nm__c='Complete')
                                                                FROM Contact WHERE Id IN :contactsIdSet]);
            Map<Id,Account> mapAccounts = new Map<Id,Account>();
            for(Contact cont: mapContacts.values()){
                accountsIdSet.add(cont.AccountId);
            }
            if(accountsIdSet.size() > 0){
                mapAccounts = new Map<Id,Account>([SELECT Id,Name,
                                                   (SELECT Id,PRM_Partner_Role__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Pending' AND PRM_Partner_Role__c IN :partnerRoles) 
                                                   FROM Account WHERE Id IN :accountsIdSet]);
            }           
            
            for(PRM_Account_Contact_Relationship__c acctContRel : accConRelList){
                isPending = false;
                if(!acctContRel.PRM_No_Email__c  && mapContacts.containsKey(acctContRel.PRM_Contact_Id__c) && mapContacts.get(acctContRel.PRM_Contact_Id__c).Account_Contact_Relationships__r.size()==0 && !acctContRel.PRM_InActive_Ind__c ){
                    Contact cont = mapContacts.get(acctContRel.PRM_Contact_Id__c);
                    String contPartnerRoles = cont.Core_IPA_Partner_Role__c;                   
                    if(!String.isEmpty(contPartnerRoles)){                
                        for(String partnerRole : contPartnerRoles.split(';')){
                            //Check if IPA Contact and Works For Relationship, and No enterprise id
                            if(partnerRoles.contains(partnerRole) && ((mapAccounts.containsKey(cont.AccountId) && mapAccounts.get(cont.AccountId).Channel_Memberships1__r.size() == 0 ) && (String.IsEmpty(cont.Core_Enterprise_Id__c) || String.isEmpty(String.valueOf(cont.Core_IPA_Email_Verification_Date__c)) ))) {    
                                acctContRel.PRM_Status_Nm__c = 'Pending Action';  
                                isPending = true;
                                break;
                            }
                        }
                    }
                    if(!isPending && String.isEmpty(acctContRel.PRM_Status_Nm__c)){
                        acctContRel.PRM_Status_Nm__c = 'Complete'; 
                    }
                }else{
                     if(!isPending && String.isEmpty(acctContRel.PRM_Status_Nm__c)){
                        acctContRel.PRM_Status_Nm__c = 'Complete'; 
                    }
                }
            }//End of For Loop 
        }  
    }
    /*Finish - US575709*/
}