@RestResource(urlMapping='/Contact/AGSCallBackHandler')
global class PRM_Contact_AGS_CallbackHandler {
    private static final String PRIMARYCONTACT = 'Primary Contact';
    private static final String WORKSFOR = 'Works for';    
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'AGS Identity Creation';
    public static final String LOG_ENTRY_SCOPE    = 'Contact - AGS Identity Creation';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO    = 'info';
    
    @HttpPost
    global static OutputMessage AGSCallbackHandler(){
/*
{
"EnterpriseID" : "",
"LoginID" : "",
"EmailID" : "",
"EVPasswordToken" : "",
"EmailVerificationDateTime" : ""
}
*/
        String strTags = '';
        try {               
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            String EnterpriseID = params.containsKey('EnterpriseID')? (!String.isEmpty(((String) params.get('EnterpriseID')))?((String) params.get('EnterpriseID')).trim():null): null;
            String LoginID = params.containsKey('LoginID')?(!String.isEmpty(((String) params.get('LoginID')))?((String) params.get('LoginID')).trim():null): null;
            String EmailID = params.containsKey('EmailID')?(!String.isEmpty(((String) params.get('EmailID')))?((String) params.get('EmailID')).trim():null): null;
            String EVToken = params.containsKey('EVPasswordToken')?(!String.isEmpty(((String) params.get('EVPasswordToken')))?((String) params.get('EVPasswordToken')).trim():null): null;
            String EVDateTime = params.containsKey('EmailVerificationDateTime')?(!String.isEmpty(((String) params.get('EmailVerificationDateTime')))?((String) params.get('EmailVerificationDateTime')).trim():null): null;
            //
            if(!String.isEmpty(EnterpriseID)){
                strTags = (strTags=='') ? EnterpriseID : strTags+' , '+EnterpriseID;
            }
            if(!String.isEmpty(LoginID)){
                strTags = (strTags=='') ? LoginID : strTags+' , '+LoginID;
            }
            if(!String.isEmpty(EmailID)){
                strTags = (strTags=='') ? EmailID : strTags+' , '+EmailID;
            }            
            if(!String.isEmpty(EnterpriseID)){
                String whereCaluse = '';
                if(!String.isEmpty(EmailID)){
                    whereCaluse = ' Email=\''+String.escapeSingleQuotes(EmailID)+'\''; 
                }else if(!String.isEmpty(LoginID)){
                    whereCaluse = ' Core_Login_Id__c=\''+String.escapeSingleQuotes(LoginID)+'\''; 
                }
                
                String query = 'SELECT id,AccountId,Account.Name,Account.BillingCountryCode,MailingCountryCode,Core_IPA_Partner_Role__c,Core_Login_Id__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact WHERE '+whereCaluse+' LIMIT 1';
                List<Contact> contacts = Database.query(query);
                if(contacts.size() > 0){                    
                    strTags = strTags+','+contacts[0].Id;
                    contacts[0].Core_Enterprise_Id__c = EnterpriseID;                            
                    
                    contacts[0].MailingCountryCode = (String.isEmpty(contacts[0].MailingCountryCode)) ? contacts[0].Account.BillingCountryCode : contacts[0].MailingCountryCode;
                    contacts[0].Core_Preferred_Language__c = String.isEmpty(contacts[0].Core_Preferred_Language__c) ? 'ENG' : contacts[0].Core_Preferred_Language__c ;
                    contacts[0].Core_Login_Id__c = String.isEmpty(contacts[0].Core_Login_Id__c) ? contacts[0].Email : contacts[0].Core_Login_Id__c;
                    
                    Database.SaveResult res = Database.update(contacts[0]);
                    if(res.isSuccess()){
                        List<String> sendEmailMsg = sendEmailToContact(contacts[0], EVToken, strTags);
                        createLogEntry( sendEmailMsg[1], sendEmailMsg[1], contacts[0],strTags, sendEmailMsg[0]);
                        if(sendEmailMsg[0] == LOG_ENTRY_INFO){
                            return generateOutput(true, sendEmailMsg[1]);
                        }else{
                            return generateOutput(false, sendEmailMsg[1]);
                        }                        
                    }else{
                        String errorMsg = '';
                        for(Database.Error error: res.getErrors()){
                            errorMsg = (errorMsg=='')?errorMsg+', '+error.getMessage() : error.getMessage();
                        }                    
                        createLogEntry( errorMsg, errorMsg, contacts[0],strTags, LOG_ENTRY_ERROR);
                        return generateOutput(false, errorMsg); 
                    } 
                }else{
                    createLogEntry( System.Label.PRM_Contact_Not_Found, System.Label.PRM_Contact_Not_Found, null, strTags, LOG_ENTRY_ERROR);
                    return generateOutput(false, System.Label.PRM_Contact_Not_Found);
                }
            }else{
                createLogEntry( System.Label.PRM_Empty_Enterprise_ID, System.Label.PRM_Empty_Enterprise_ID, null,strTags, LOG_ENTRY_ERROR);
                return generateOutput(false, System.Label.PRM_Empty_Enterprise_ID);
            }
            
        }catch(Exception ex){
            String exc = 'Line#'+ex.getLineNumber()+' : '+ex.getMessage()+' :: '+ex.getStackTraceString();
            system.debug('Error ===>'+exc);
            createLogEntry( exc, exc, null, strTags, LOG_ENTRY_ERROR);
            return generateOutput(false, exc);
        }        
    }
    
    private static OutputMessage generateOutput(boolean isSuccess, String message){        
        return new OutputMessage(isSuccess, message );
    }
    
    public static List<String> sendEmailToContact(Contact cont, String EVToken, String strTags){        
        String EVlink = System.Label.PRM_EVTokenLink;
        String SecondaryContURL = System.Label.PRM_EVTLinkTarget_SecondaryContact;
        String AdminContURL = System.Label.PRM_EVTLinkTarget_PrimaryContact;
        String CompleteNowURL = '';
        String culture = '';   
        String countryCode = '';
        String countryCodeCulture = '';
        
        String strRandom = String.valueOf(system.now()).replace(' ','').replace('-','').replace(':', '');
        List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        String msg = '';
        List<String> contactPartnerRoles = cont.Core_IPA_Partner_Role__c.split(';');  
        //Core_IPA_Partner_Role__c
        if(!String.IsEmpty(cont.Core_IPA_Partner_Role__c) && configPartnerRoles.contains(contactPartnerRoles[0]) ){
            
            List<String> businessEventsList = Label.PRM_Email_Business_Events.split(',');
            Map<String,String> languagesMap = new Map<String,String>();
            
            List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt WHERE MasterLabel = :cont.Core_Preferred_Language__c ];
            for(PRM_EmailConfigurationDetails__mdt emailConfig : [SELECT PRM_Language__c, PRM_BusinessEvent__c FROM PRM_EmailConfigurationDetails__mdt WHERE PRM_BusinessEvent__c IN :businessEventsList]){
                if(!String.isEmpty(emailConfig.PRM_Language__c)){
                    languagesMap.put(emailConfig.PRM_BusinessEvent__c+'~~'+emailConfig.PRM_Language__c, emailConfig.PRM_Language__c );
                }
            }
            Map<String,PRM_AEM_Support_Redirect_Links__mdt> mapSupportAndRedirectLinks = new Map<String,PRM_AEM_Support_Redirect_Links__mdt>();
            for(PRM_AEM_Support_Redirect_Links__mdt linkMdt : [SELECT PRM_Partner_Role__c,PRM_Redirect_Link__c,PRM_Support_Link__c FROM PRM_AEM_Support_Redirect_Links__mdt WHERE PRM_Partner_Role__c IN :contactPartnerRoles]){
                mapSupportAndRedirectLinks.put(linkMdt.PRM_Partner_Role__c, linkMdt);
            }
            if(mapSupportAndRedirectLinks.size() > 0 && mapSupportAndRedirectLinks.containsKey(contactPartnerRoles[0])) {                
                PRM_AEM_Support_Redirect_Links__mdt linksForContact = mapSupportAndRedirectLinks.get(contactPartnerRoles[0]);                
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                Map<String, String> inputParameters = new Map<String, String>();        
                culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';
                
                //---------------- culture mapping country code ----------------
                countryCodeCulture = getCountryCodeForUrl(cont, lngCultureMdt);
                /*
                if(cont.Core_Preferred_Language__c == 'JPN' || cont.Core_Preferred_Language__c == 'POR' || cont.Core_Preferred_Language__c == 'KOR' || cont.Core_Preferred_Language__c == 'ZHT'){
                    countryCodeCulture = countryCode+'/'+culture;
                }else{
                    countryCodeCulture = countryCode+'/'+culture;
                }
				*/
                SecondaryContURL = SecondaryContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
                AdminContURL = AdminContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
                //---------------- culture mapping country code ----------------
                
                boolean isAdmin = false;   
                if([SELECT Id FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__c=:cont.AccountId AND PRM_Status_Nm__c='Pending' AND PRM_Partner_Role__c = :contactPartnerRoles[0]].size() > 0){
                    isAdmin = True;
                }      
                
                CompleteNowURL = !String.isEmpty(EVToken) ? 
                    			(isAdmin ? EVlink.replace('{{EVTOKEN}}', EVToken).replace('{{CULTURE}}', culture).replace('{{TARGET}}', AdminContURL) :
                     			EVlink.replace('{{EVTOKEN}}', EVToken).replace('{{CULTURE}}', culture).replace('{{TARGET}}', SecondaryContURL))
                    			: (isAdmin ? AdminContURL : SecondaryContURL);   
                        
                PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{{EVLINK}}' => CompleteNowURL, '{{SUPPORTLINK}}' =>  linksForContact.PRM_Support_Link__c, '{{ACCOUNTNAME}}' => cont.Account.Name };                       
                inputParameters.put('EV_Contact_ID',cont.Id);
                objEmailNotif.BusinessEvent = isAdmin ? 'Admin_Registration_Email_Template' : 'Secondary_Contact_Email_Template';
                objEmailNotif.InputParameters = inputParameters;
                //objEmailNotif.Language = (String.isEmpty(cont.Core_Preferred_Language__c) || (cont.Core_Preferred_Language__c != 'SPA' && cont.Core_Preferred_Language__c != 'RUS' && cont.Core_Preferred_Language__c != 'ZHO' && cont.Core_Preferred_Language__c != 'DEU')) ? 'ENG': cont.Core_Preferred_Language__c;
                objEmailNotif.Language = (String.isEmpty(cont.Core_Preferred_Language__c) || !languagesMap.containsKey(objEmailNotif.BusinessEvent+'~~'+cont.Core_Preferred_Language__c) ) ? 'ENG': cont.Core_Preferred_Language__c;
                objEmailNotif.ChannelProgram = System.Label.PRM_Intel_Partner_Alliance;
                objEmailNotif.PartnerType = System.Label.PRM_CsP;
                objEmailNotif.EmailID = cont.Email;               
                PRM_EmailUtility.sendEmail(objEmailNotif);               
                PRM_createAccountandRelatedRecords.linkEmailLogToContact(cont.Email);                
                return new List<String>{LOG_ENTRY_INFO, 'Contact updated successfully'};
                    }else{                
                        return new List<String>{LOG_ENTRY_ERROR, 'Redirect and Support Links are not configured for the contact\'s partner role'};
                            }
        }else{           
            return new List<String>{LOG_ENTRY_ERROR, 'Contact has no partner roles'};
                } 
    }
    private static void createLogEntry(String message, String detail, Contact cont, String tags, String severity){
        
        Id RecordId = (cont!= null) ? cont.Id : null;
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            //Name = strLogEntryName, // From Service Cloud
            Core_Origin__c = LOG_ENTRY_ORIGIN,
            Core_Project__c = LOG_ENTRY_PROJECT,
            Core_Scope__c = LOG_ENTRY_SCOPE,
            Core_Severity__c = severity,
            Core_Message__c =  (message == null || message.length() <= 255 ? message : message.substring(0, 255)),
            Core_When__c = system.now(),
            Core_Details__c = detail,
            Core_sObjectId__c = RecordId,
            Core_sObjectType__c = 'Contact',
            Core_Tags__c = (tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255))
        );
        insert objCLE;
        system.debug('Log Entry Id ==>'+objCLE.Id);
    }
    private static String getCountryCodeForUrl(Contact cont, List<PRM_Language_Culture_Mapping__mdt> lngCultureMdts){
        String countryCode = '';
        String culture = '';
        if(lngCultureMdts.size() > 0){
            if(lngCultureMdts.size() == 1){
                return String.isEmpty(lngCultureMdts[0].PRM_Country_Cd__c) ? System.Label.PRM_Default_CultureCountry : lngCultureMdts[0].PRM_Country_Cd__c.toLowerCase()+'/'+ lngCultureMdts[0].PRM_Culture__c.toLowerCase() ;
            }else{
                for(PRM_Language_Culture_Mapping__mdt mdt: lngCultureMdts){
                    if(!String.isEmpty(mdt.PRM_Country__c) && cont.MailingCountryCode == mdt.PRM_Country__c){
                        countryCode = mdt.PRM_Country_Cd__c;  
                        culture = mdt.PRM_Culture__c;
                        break;
                    }
                }
                return (String.isEmpty(countryCode) || String.isEmpty(culture)) ? System.Label.PRM_Default_CultureCountry : countryCode.toLowerCase()+'/'+culture.toLowerCase();
                //countryCode = lngCultureMdts[0].PRM_Default_CountryCode__c;                       
            }
            
        }else {
            return System.Label.PRM_Default_CultureCountry;
        }     
    } 
    global class OutputMessage {
        public boolean success {set; get;}
        public String msg {set; get;}
        public OutputMessage (boolean success, String msg ) {
            this.success = success;
            this.msg = msg;
        }
    }
}