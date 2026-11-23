@RestResource(urlMapping='/Contact/AGSCallBackHandler')
global with sharing class PRM_Contact_AGS_CallbackHandler {
    private static final String PRIMARYCONTACT = 'Primary Contact';
    private static final String WORKSFOR = 'Works for';    
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'AGS Identity Creation';
    public static final String LOG_ENTRY_SCOPE    = 'Contact - AGS Identity Creation';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO    = 'info';    
    public static Boolean IS_DelayInviteEmail = Boolean.valueof(Label.PRM_DelayInviteEmail);
    // !Test.isRunningTest()?Boolean.valueof(Label.PRM_CiDaaS_Enabled):True; //As Per CiDaaS Change
    
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
        String errorMsg = '';
        List<PRM_Account_Contact_Relationship__c> accountContRels =new List<PRM_Account_Contact_Relationship__c>();
        set<String> contRecordIds=new set<string>();
        try {               
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            // Check the AGS response
            if(params.containskey('cidaas'))            
                if(!String.isEmpty((String) params.get('EnterpriseID'))){
                    
                    String enterpriseID = params.containsKey('EnterpriseID')? (!String.isEmpty(((String) params.get('EnterpriseID')))?((String) params.get('EnterpriseID')).trim():null): null;
                    String emailID = params.containsKey('EmailID')?(!String.isEmpty(((String) params.get('EmailID')))?((String) params.get('EmailID')).trim():null): null;
                    String loginID = '';
                    String evToken = '';
                    String evDateTime = '';
                    String query = '';                               
                    if(!String.isEmpty(enterpriseID)){
                        strTags = (strTags=='') ? enterpriseID : strTags+' , '+enterpriseID;
                    }
                    if(!String.isEmpty(loginID)){
                        strTags = (strTags=='') ? loginID : strTags+' , '+loginID;
                    }
                    if(!String.isEmpty(emailID)){
                        strTags = (strTags=='') ? emailID : strTags+' , '+emailID;
                    }            
                    if(!String.isEmpty(enterpriseID)){
                        String whereCaluse = '';
                        if(!String.isEmpty(emailID)){
                            whereCaluse = ' Email=\''+String.escapeSingleQuotes(emailID)+'\''; 
                        }
                        
                        
                        
                        query = 'SELECT id,Core_Login_Status__c,AccountId,Account.Name,Account.AccountNumber,FirstName,LastName,Core_Do_Not_Contact__c,Account.BillingCountryCode,Core_ERPM_Integration_Status__c,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact WHERE '+whereCaluse+' LIMIT 1';
                        
                        List<Contact> contacts = Database.query(query);
                        if(contacts.size() > 0){
                            strTags = strTags+','+contacts[0].Id;
                            contacts[0].Core_Enterprise_Id__c = enterpriseID;
                            contacts[0].MailingCountryCode = (String.isEmpty(contacts[0].MailingCountryCode)) ? contacts[0].Account.BillingCountryCode : contacts[0].MailingCountryCode;
                            contacts[0].Core_Preferred_Language__c = String.isEmpty(contacts[0].Core_Preferred_Language__c) ? 'ENG' : contacts[0].Core_Preferred_Language__c ;
                            
                            /*contacts[0].Core_Login_Id__c = null;*/ //IPA 2.0 - Removed login id reference- TWC-729-8150
                            
                            if(contacts[0].Core_Login_Status__c == 'Deleted' && !String.isEmpty(enterpriseID)){
                                //populate Enterprise id on Contact for the Existing contact - Use It or Lose It Scenario - Contact's return journey
                                contacts[0].Core_Login_Status__c = 'Active';   
                                contacts[0].Core_Deletion_Reason__c = null;                                                             
                            }
                            
                            accountContRels = [
                                SELECT id,PRM_Contact_Id__c,PRM_AGS_Response_Status__c,PRM_Retry_Count__c,PRM_Error_Message__c,PRM_Source_Agent__c 
                                FROM PRM_Account_Contact_Relationship__c 
                                WHERE PRM_Contact_Id__r.Email  =: contacts[0].Email
                            ];
                            
                            for (PRM_Account_Contact_Relationship__c acr : accountContRels) {
                                contRecordIds.add(acr.PRM_Contact_Id__c);
                                if(acr.PRM_Source_Agent__c == 'Bulk Add' || acr.PRM_Source_Agent__c == 'Bulk Invite'){
                                    contacts[0].Core_Login_Status__c = 'Active';
                                    break;
                                }
                            }
                            
                            Database.SaveResult res = Database.update(contacts[0]);
                            if(res.isSuccess()){
                                if(!accountContRels.isEmpty()){
                                    for(PRM_Account_Contact_Relationship__c acr : accountContRels){
                                        acr.PRM_AGS_Response_Status__c = 'Success';
                                        acr.PRM_Error_Message__c = null;
                                        acr.PRM_Retry_Count__c = null;
                                    }
                                    
                                    TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
                                    List<Database.SaveResult> resList1 = Database.update(accountContRels);
                                    Integer counter = 0;
                                    for(Database.SaveResult res1:resList1){
                                        if(!res1.isSuccess()){
                                            for(Database.Error error: res1.getErrors()){                                
                                                errorMsg = (errorMsg=='')?errorMsg+', '+error.getMessage() : error.getMessage();                                
                                            }                    
                                            logEntryList.add(createLogEntryNoInsert( errorMsg, errorMsg, accountContRels[counter],strTags, LOG_ENTRY_ERROR, 'PRM_Account_Contact_Relationship__c'));
                                        }
                                        counter++;
                                    }
                                    TriggerHandler.clearBypass('PRM_AcctContRel_TriggerHandler');
                                    
                                }else{
                                    createLogEntry(errorMsg,errorMsg, null, strTags, LOG_ENTRY_ERROR,null);
                                    return generateOutput(false, errorMsg);
                                }
                                
                                if(!accountContRels.isEmpty()){
                                    if(accountContRels[0].PRM_Source_Agent__c == 'Bulk Add' || accountContRels[0].PRM_Source_Agent__c == 'Bulk Invite'){
                                        if(accountContRels[0].PRM_Source_Agent__c == 'Bulk Invite' && !contacts[0].Core_Do_Not_Contact__c ){
                                            /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
                                            if(IS_DelayInviteEmail){
                                                PRM_AGS_IdentityCreation.CreateBatchEntitlements(contacts[0], evToken, null,'Bulk Invite Email');
                                                return generateOutput(true, errorMsg);
                                            }
                                            /*Utkarsh - TWC727-695 - END*/
                                            else{
                                                List<String> responseValues = PRM_BulkDataUpload_Batch.emailToContact(contacts[0], evToken, null);
                                                return generateOutput((Boolean.valueOf(responseValues[0])), responseValues[1]);
                                            }
                                        }
                                        else {
                                            return generateOutput(True, 'Contact updated successfully');
                                        }
                                    }
                                    else{
                                        /*Utkarsh - TWC727-695 - Send invite email to user after 5 minutes of B2C creation*/
                                        if(IS_DelayInviteEmail){
                                            PRM_AGS_IdentityCreation.CreateBatchEntitlements(contacts[0], evToken, strTags,'Admin Invite Email');
                                            return generateOutput(true, errorMsg);
                                        }
                                        /*Utkarsh - TWC727-695 - END*/
                                        else{
                                            List<String> sendEmailMsg = sendEmailToContact(contacts[0], evToken, strTags);
                                            createLogEntry( sendEmailMsg[1], sendEmailMsg[1], contacts[0],strTags, sendEmailMsg[0], 'Contact'); 
                                            if(sendEmailMsg[0] == LOG_ENTRY_INFO){
                                                return generateOutput(true, sendEmailMsg[1]);
                                            }else{
                                                return generateOutput(false, sendEmailMsg[1]);
                                            }
                                        }
                                    }
                                }
                                
                            }else{                            
                                for(Database.Error error: res.getErrors()){
                                    errorMsg = (errorMsg=='')?errorMsg+', '+error.getMessage() : error.getMessage();
                                }                    
                                createLogEntry( errorMsg, errorMsg, contacts[0],strTags, LOG_ENTRY_ERROR, 'Contact');
                                return generateOutput(false, errorMsg); 
                            } 
                        }else{
                            createLogEntry( System.Label.PRM_Contact_Not_Found, System.Label.PRM_Contact_Not_Found, null, strTags, LOG_ENTRY_ERROR,null);
                            return generateOutput(false, System.Label.PRM_Contact_Not_Found);
                        }
                    }else{
                        createLogEntry( System.Label.PRM_Empty_Enterprise_ID, System.Label.PRM_Empty_Enterprise_ID, null,strTags, LOG_ENTRY_ERROR, null);
                        return generateOutput(false, System.Label.PRM_Empty_Enterprise_ID);
                    }
                }
            else{
                
                String status = (String) params.get('status');
                String errorMessage = (String) params.get('ErrorMessage');
                String retryCount = (String) params.get('retryCount');
                String emailID = params.containsKey('EmailID')?(!String.isEmpty(((String) params.get('EmailID')))?((String) params.get('EmailID')).trim():null): null;
                
                String agsEmail = '';      
                if(!String.isEmpty(emailID)){
                    strTags = (strTags=='') ? emailID : strTags+' , '+emailID;
                    agsEmail = 'PRM_Contact_Id__r.Email=\''+String.escapeSingleQuotes(emailID)+'\'';
                    
                    String query = 'SELECT id,PRM_AGS_Response_Status__c,PRM_Retry_Count__c,PRM_Contact_Id__c,PRM_Error_Message__c FROM PRM_Account_Contact_Relationship__c WHERE '+agsEmail;
                    accountContRels = Database.query(query);
                    if( !accountContRels.isEmpty()){
                        for(PRM_Account_Contact_Relationship__c acr :accountContRels){
                            contRecordIds.add(acr.PRM_Contact_Id__c);
                            acr.PRM_AGS_Response_Status__c = status;
                            acr.PRM_Error_Message__c = errorMessage;
                            acr.PRM_Retry_Count__c = retryCount; 
                            if(acr.PRM_AGS_Response_Status__c == 'Failure'){
                                acr.PRM_AGS_Identity_Creation_Fail__c = true;
                            }
                        }
                        
                        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
                        List<Database.SaveResult> resList = Database.update(accountContRels);
                        Integer counter = 0;
                        for(Database.SaveResult res: resList){
                            if(!res.isSuccess()){
                                for(Database.Error error: res.getErrors()){                                
                                    errorMsg = (errorMsg == '') ? errorMsg+', '+error.getMessage() : error.getMessage();                                
                                }                
                                logEntryList.add(createLogEntryNoInsert( errorMsg, errorMsg, accountContRels[counter],strTags, LOG_ENTRY_ERROR, 'PRM_Account_Contact_Relationship__c'));
                            }
                            counter++;
                        }
                        TriggerHandler.clearBypass('PRM_AcctContRel_TriggerHandler');
                        if(logEntryList.isEmpty()){
                            return generateOutput(true, 'Error details captured successfully.');
                        }else{
                            return generateOutput(false, 'Error While Capturing the Error Details.');
                        }
                        
                    }else{
                        createLogEntry(errorMsg,errorMsg, null, strTags, LOG_ENTRY_ERROR, null);
                        return generateOutput(false, errorMsg);
                    }
                    
                }
            }
            if(!logEntryList.isEmpty()){
                database.insert(logEntryList,false);
            }
            return generateOutput(false, errorMsg);
            
        }catch(Exception ex){
            String exc = 'Line#'+ex.getLineNumber()+' : '+ex.getMessage()+' :: '+ex.getStackTraceString();
            system.debug('Error ==>'+exc);
            createLogEntry( exc, exc, null, strTags, LOG_ENTRY_ERROR,null);
            return generateOutput(false, exc);
        }  
        finally{
            if(contRecordIds.size()>0 && System.Label.PRM_Tracker_Enabled=='true')
                system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contRecordIds,false,false));
            
        }    
    }
    
    private static OutputMessage generateOutput(boolean isSuccess, String message){        
        return new OutputMessage(isSuccess, message );
    }
    
    public static List<String> sendEmailToContact(Contact cont, String EVToken, String strTags) {
        
        String EVlink = System.Label.PRM_EVTokenLink;
        String SecondaryContURL = System.Label.PRM_EVTLinkTarget_SecondaryContact;
        String AdminContURL = System.Label.PRM_EVTLinkTarget_PrimaryContact;
        //Nilesh 
        String SupportContURL = System.Label.PRM_Admin_Support_Link;
        //As part of CIDass change TWC729-4289,4288,4201
        String AdminCidaasURL =System.Label.PRM_CiDaaS_PrimaryContact_Link;
        String SecondaryCidaasURL = System.Label.PRM_CiDaaS_Secondary_Invite_Link;
        //String SupportContCidaasURL = System.Label.PRM_CiDaaS_Admin_Support_Link;
        String CompleteNowURL = '';
        String culture = '';   
        //String countryCode = '';
        String countryCodeCulture = '';
        //Nilesh 
        String countrycdcul = '';
        //
        
        //String strRandom = String.valueOf(system.now()).replace(' ','').replace('-','').replace(':', '');
        List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        //String msg = '';
        //List<String> contactPartnerRoles = cont.Core_IPA_Partner_Role__c.split(';');  
        List<String> contactPartnerRoles = String.isEmpty(cont.Core_IPA_PartnerRole__c)? new List<String>() : cont.Core_IPA_PartnerRole__c.split(';');  
        //Core_IPA_Partner_Role__c
        if((!String.IsEmpty(cont.Core_IPA_PartnerRole__c) && !configPartnerRoles.contains(contactPartnerRoles[0])) ||(String.IsEmpty(cont.Core_IPA_PartnerRole__c) && cont.Core_Login_Status__c=='Deleted') ){
            //if(System.isBatch()){
            List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
            
            acrlist = [SELECT id, PRM_Contact_Id__c, PRM_Source_Agent__c, PRM_Contact_Id__r.Core_Preferred_Language__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Contact_Id__c =: cont.id LIMIT 1];
            
            List<String> businessEventsList = Label.PRM_Email_Business_Events.split(',');
            Map<String,String> languagesMap = new Map<String,String>();
            
            List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt WHERE MasterLabel = :cont.Core_Preferred_Language__c ];
            for(PRM_EmailConfigurationDetails__mdt emailConfig : [SELECT PRM_Language__c, PRM_BusinessEvent__c FROM PRM_EmailConfigurationDetails__mdt WHERE PRM_BusinessEvent__c IN :businessEventsList]){
                if(!String.isEmpty(emailConfig.PRM_Language__c)){
                    languagesMap.put(emailConfig.PRM_BusinessEvent__c+'~~'+emailConfig.PRM_Language__c, emailConfig.PRM_Language__c );
                }
            }
            /* 
Map<String,PRM_AEM_Support_Redirect_Links__mdt> mapSupportAndRedirectLinks = new Map<String,PRM_AEM_Support_Redirect_Links__mdt>();
for(PRM_AEM_Support_Redirect_Links__mdt linkMdt : [SELECT PRM_Partner_Role__c,PRM_Redirect_Link__c,PRM_Support_Link__c FROM PRM_AEM_Support_Redirect_Links__mdt WHERE PRM_Partner_Role__c IN :contactPartnerRoles]){
mapSupportAndRedirectLinks.put(linkMdt.PRM_Partner_Role__c, linkMdt);
}*/
            // if(mapSupportAndRedirectLinks.size() > 0 && mapSupportAndRedirectLinks.containsKey(contactPartnerRoles[0])) {                
            //  PRM_AEM_Support_Redirect_Links__mdt linksForContact = mapSupportAndRedirectLinks.get(contactPartnerRoles[0]);                
            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
            Map<String, String> inputParameters = new Map<String, String>();        
            culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';
            
            //---------------- culture mapping country code ----------------
            countryCodeCulture = getCountryCodeForUrl(cont, lngCultureMdt);
            
            //countrycdcul = getCountryCultureUrl(cont, lngCultureMdt);
            List<String> countryCodeCultureArr = countryCodeCulture.split('/');
            countrycdcul = countryCodeCultureArr[1]+'-'+countryCodeCultureArr[0];
            //
            /*
if(cont.Core_Preferred_Language__c == 'JPN' || cont.Core_Preferred_Language__c == 'POR' || cont.Core_Preferred_Language__c == 'KOR' || cont.Core_Preferred_Language__c == 'ZHT'){
countryCodeCulture = countryCode+'/'+culture;
}else{
countryCodeCulture = countryCode+'/'+culture;
}
*/
            SecondaryContURL = SecondaryContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
            AdminContURL = AdminContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
            //Nilesh
            SupportContURL = SupportContURL.replace('{{CULTURECODE}}',countrycdcul);
            //As part of CIDass change TWC729-4289,4288,4201
            AdminCidaasURL=AdminCidaasURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
            SecondaryCidaasURL=SecondaryCidaasURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
            //---------------- culture mapping country code ----------------
            
            boolean isAdmin = false;   
            if(!contactPartnerRoles.isEmpty())
            { if([SELECT Id FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__c=:cont.AccountId AND PRM_Status_Nm__c='Pending' AND PRM_Partner_Role__c = :contactPartnerRoles[0]].size() > 0){
                isAdmin = True;
            	}
            }
            map<String,Language_Translation__mdt> dynamicTranslations =  new map<String,Language_Translation__mdt>();
            
            for(Language_Translation__mdt langTrans : [select DeveloperName, DEU__c, ENG__c, ENU__c, FRA__c, IND__c, ITA__c,JPN__c, KOR__c, POL__c, POR__c, RUS__c, SPA__c, ESP__c,  THA__c, TUR__c, VIE__c, ZHO__c, ZHT__c, FRC__c from Language_Translation__mdt]){
                dynamicTranslations.put(langTrans.DeveloperName,langTrans);    
            }                
            String Buttontext;
            String Warning_Placeholder;
            //--implemented as part of CiDaaS (using static link as part of cidaas)
            //Need to place the proper buttontext value of dynamic translation at line 332 & 333. 
            
            CompleteNowURL = isAdmin ? AdminCidaasURL : SecondaryCidaasURL;
            //  CompleteNowURL=cidaaslink;
            
            if(!acrList.isEmpty()){
                Buttontext = (String) dynamicTranslations.get('Complete_Now_Button_Name').get(acrList[0].PRM_Contact_Id__r.Core_Preferred_Language__c + '__c');
                Warning_Placeholder = '';   
            }
            
            PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{{EVLINK}}' => CompleteNowURL, '{{SUPPORTLINK}}' =>  SupportContURL, '{{ACCOUNTNAME}}' => cont.Account.Name ,'{{ACCOUNTNUMBER}}' => cont.Account.AccountNumber, '{{ButtonText}}' => Buttontext, '{{24Hour Warning}}' => Warning_Placeholder};                       
                inputParameters.put('EV_Contact_ID',cont.Id);
            objEmailNotif.BusinessEvent = isAdmin ? 'Admin_Registration_Email_Template' : 'Secondary_Contact_Email_Template';
            objEmailNotif.InputParameters = inputParameters;
            //objEmailNotif.Language = (String.isEmpty(cont.Core_Preferred_Language__c) || (cont.Core_Preferred_Language__c != 'SPA' && cont.Core_Preferred_Language__c != 'RUS' && cont.Core_Preferred_Language__c != 'ZHO' && cont.Core_Preferred_Language__c != 'DEU')) ? 'ENG': cont.Core_Preferred_Language__c;
            objEmailNotif.Language = (String.isEmpty(cont.Core_Preferred_Language__c) || !languagesMap.containsKey(objEmailNotif.BusinessEvent+'~~'+cont.Core_Preferred_Language__c) ) ? 'ENG': cont.Core_Preferred_Language__c;
            objEmailNotif.ChannelProgram = System.Label.PRM_Intel_Partner_Alliance;
            objEmailNotif.PartnerType = System.Label.PRM_CsP;
            objEmailNotif.EmailID = cont.Email;                                              
            String event = !acrList.isEmpty() && String.isNotBlank(acrList[0].PRM_Source_Agent__c) ? acrList[0].PRM_Source_Agent__c : isAdmin == true ? 'Admin Registration':'Partner Invite';
            Boolean suppressEmail = PRM_Email_Handler_Utility.checkForEmailSupression(cont.Id, event);
            if(suppressEmail==false){           
                //PRM_EmailUtility.sendEmail(objEmailNotif); 
                //added as part of governor limit story:4380
                //if(System.isBatch()){
                PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});
                //}          
            }
            PRM_createAccountandRelatedRecords.linkEmailLogToContact(cont.Email);                
            return new List<String>{LOG_ENTRY_INFO, 'Contact updated successfully'};
                /*    }else{                
return new List<String>{LOG_ENTRY_ERROR, 'Redirect and Support Links are not configured for the contact\'s partner role'};
}*/
                //}
                }else{           
                    return new List<String>{LOG_ENTRY_ERROR, 'Contact has no partner roles'};
                        }
        
    }
    private static void createLogEntry(String message, String detail, sObject cont, String tags, String severity, String objectType){
        
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
            Core_sObjectType__c = objectType,
            Core_Tags__c = (tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255))
        );
        insert objCLE;
    }
    @TestVisible public static Core_Log_Entry__c createLogEntryNoInsert(String message, String detail, sObject cont, String tags, String severity, String objectType){
        
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
            Core_sObjectType__c = objectType,
            Core_Tags__c = (tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255))
        );
        return objCLE;
        //system.debug('Log Entry Id ==>'+objCLE.Id);
    }
    private static String getCountryCodeForUrl(Contact cont, List<PRM_Language_Culture_Mapping__mdt> lngCultureMdts){
        String countryCode = '';
        String culture = '';
        // if(lngCultureMdts.size() > 0){
        if(lngCultureMdts.size() == 1 && !String.isEmpty(lngCultureMdts[0].PRM_Country_Cd__c) && !String.isEmpty(lngCultureMdts[0].PRM_Culture__c)){
            return String.isEmpty(lngCultureMdts[0].PRM_Country_Cd__c) ? System.Label.PRM_Default_CultureCountry : lngCultureMdts[0].PRM_Country_Cd__c.toLowerCase()+'/'+ lngCultureMdts[0].PRM_Culture__c.toLowerCase() ;
            /*  }else{
for(PRM_Language_Culture_Mapping__mdt mdt: lngCultureMdts){
if(!String.isEmpty(mdt.PRM_Country__c) && cont.MailingCountryCode == mdt.PRM_Country_Cd__c){
countryCode = mdt.PRM_Country_Cd__c;  
culture = mdt.PRM_Culture__c;
break;
}
}
return (String.isEmpty(countryCode) || String.isEmpty(culture)) ? System.Label.PRM_Default_CultureCountry : countryCode.toLowerCase()+'/'+culture.toLowerCase();
//countryCode = lngCultureMdts[0].PRM_Default_CountryCode__c;                       
}
*/
        }else {
            return System.Label.PRM_Default_CultureCountry;
        }     
    } 
    //Nilesh
    /* private static String getCountryCultureUrl(Contact cnt, List<PRM_Language_Culture_Mapping__mdt> lngCulMdts){
String countryCode = '';
String culture = '';
if(lngCulMdts.size() > 0){
if(lngCulMdts.size() == 1){
return String.isEmpty(lngCulMdts[0].PRM_Country_Cd__c) ? System.Label.PRM_Default_Cul_Country_Code : lngCulMdts[0].PRM_Culture__c.toLowerCase()+'-'+ lngCulMdts[0].PRM_Country_Cd__c.toLowerCase() ;
}else{
for(PRM_Language_Culture_Mapping__mdt mdt: lngCulMdts){
if(!String.isEmpty(mdt.PRM_Country__c) && cnt.MailingCountryCode == mdt.PRM_Country__c){
countryCode = mdt.PRM_Country_Cd__c;  
culture = mdt.PRM_Culture__c;
break;
}
}
return (String.isEmpty(culture) || String.isEmpty(countryCode)) ? System.Label.PRM_Default_Cul_Country_Code : culture.toLowerCase()+'-'+countryCode.toLowerCase();
//countryCode = lngCulMdts[0].PRM_Default_CountryCode__c;                       
}

}else {
return System.Label.PRM_Default_Cul_Country_Code;
}     
}*/
    //
    global class OutputMessage {
        public boolean success {set; get;}
        public String msg {set; get;}
        public OutputMessage (boolean success, String msg ) {
            this.success = success;
            this.msg = msg;
        }
    }
}