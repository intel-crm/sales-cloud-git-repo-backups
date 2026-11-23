public without Sharing class PMP_SearchCompanyLeadGenFromRegistration extends PMP_SearchWrapperStore {

    Public String communityURL;
    Public UserDetails user;
	Public PRM_Registration_Request__c registerUserDetails;
 
   @AuraEnabled(cacheable = true)
    public static LeadGenSettings getExistingSettings(String partnerId){
        PMP_Company__c partner;
        
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){  //PMD Fixes
        partner = [SELECT toLabel(PMP_Company_Lead_Gen_Language_Nm__c)
                   ,PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c
                   from PMP_Company__c WHERE id =: partnerId];        
        }
        
        LeadGenSettings leadGenSettings = new LeadGenSettings();
        leadGenSettings.languagePreference = new List<Options>();
        leadGenSettings.enableLeadGeneration = true;
        leadGenSettings.limitToPartners = false;
        
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Company_Lead_Gen_Language_Nm__c.getDescribe();      
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        
        
        for( Schema.PicklistEntry pickListVal : ple){
            
            Options language = new Options();
            language.label = pickListVal.getLabel();
            language.value = pickListVal.getValue();
            leadGenSettings.languagePreference.add(language);
           
        }
        
        
        
        if(partner.PMP_Company_Lead_Gen_Language_Nm__c!=null){
            
            for(Options lang : leadGenSettings.languagePreference){
                for(String prefLang : partner.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
                    if(lang.label == prefLang)
                        lang.selected = true;
                }
            }
            
            
            
        }
        
        if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c!=null && partner.PMP_Is_Lead_Gen_Limited_Nm__c!=null){
            if(partner.PMP_Is_Enabled_Lead_Gen_Nm__c == 'True')
                leadGenSettings.enableLeadGeneration = true;
            else
                leadGenSettings.enableLeadGeneration = false;
            if(partner.PMP_Is_Lead_Gen_Limited_Nm__c == 'True')
                leadGenSettings.limitToPartners= true;
            else
                leadGenSettings.limitToPartners=false;
            
        } 
        
        system.debug(leadGenSettings);
        return leadGenSettings;
    }
    
    @AuraEnabled
    public static Boolean saveSettingsData(String partnerId, String requestJSON){
        PMP_Company__c company;
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        LeadGenSettings saveRequest = (LeadGenSettings)JSON.deserialize(requestJSON, LeadGenSettings.class);
        
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //PMD Fixes
        company = [SELECT id, PMP_Working_Copy_Id__c from PMP_Company__c where id=:partnerId];         
        }
        
        String wcId = '';
        if(String.isNotEmpty(company.PMP_Working_Copy_Id__c)  ){
            wcId = company.PMP_Working_Copy_Id__c;
        }
        else{
            //return false;
            wcId = company.Id;
        }
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){ //PMD Fixes
        partnerList = [SELECT PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Lead_Gen_Language_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where id=: wcId];         
        }
        
        if(saveRequest.enableLeadGeneration == true)
            partnerList[0].PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        else
            partnerList[0].PMP_Is_Enabled_Lead_Gen_Nm__c ='False';
        if(saveRequest.limitToPartners == true)
            partnerList[0].PMP_Is_Lead_Gen_Limited_Nm__c= 'True';
        else
            partnerList[0].PMP_Is_Lead_Gen_Limited_Nm__c = 'False';
        
        partnerList[0].PMP_Company_Lead_Gen_Language_Nm__c = '';
        
        system.debug('pref'+ saveRequest.languagePreference);
        for(Options lang : saveRequest.languagePreference){
            if(lang.selected == true){
                partnerList[0].PMP_Company_Lead_Gen_Language_Nm__c+= lang.value+ ';';
            }
        }
        
        //if(Schema.sObjectType.PMP_Company__c.isUpdateable()){ //PMD Fixes //breaking existing functionality
        update partnerList;
        //}         
        return true;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getLanguagePreferences(String partnerId){
        PMP_Company__c partner;
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            partner = [SELECT PMP_Company_Lead_Gen_Language_Nm__c from PMP_Company__c where id =:partnerId];        
        }
        List<String> prefLanguage = new List<String>();
        
        for(String lang : partner.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
            prefLanguage.add(lang);    
        }
        
        return prefLanguage;
    }
      
    
    @AuraEnabled
    public static PRM_Registration_Request__c fetchUser(String registerId){ 
        System.debug('registerId 144--->'+registerId); 
        PRM_Registration_Request__c registerUserDetails=null;
        PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
        List<String> registerDetails = new List<String>();
   //     Contact con = new Contact();
   //     Account acc = new Account();       
        
      if(!String.isBlank(registerId)){
            
       
            registerUserDetails = new PRM_Registration_Request__c();    
            if(Schema.sObjectType.User.isAccessible()){
                regUser = [Select id,Account_ID__c,PRM_Contact_Salesforce_Id__c,PRM_Email_ID__c,PRM_Contact_Login_ID__c from PRM_Registration_Request__c where id=: registerId];
               System.debug('regUser 155--->'+regUser); 
            }
    
            //TODO:  Revisite later
            
       /*?     if(regUser!=null && (!String.isBlank(regUser.PRM_Email_ID__c))) {
                if(Schema.sObjectType.Contact.isAccessible()){
                    con = [select id,AccountId, FirstName, LastName, Email,Phone,Title,Core_Job_Function__c,Core_Profession__c,MailingCountry,MailingState  from Contact where Email=:regUser.PRM_Email_ID__c]; 
                    system.debug('contact Info'+con);
                    
                }
                   if(con!=null && (!String.isBlank(con.AccountId))){
                    if(Schema.sObjectType.Account.isAccessible()){
                        acc= [select id,Name,Core_Account_State_Province__c,Core_Account_Country__c from Account where id=: con.AccountId];
                    	system.debug('Account Info'+acc);
                    }
                }
            }
            
            
            
            registerUserDetails.PRM_First_Name__c = con.FirstName;
            registerUserDetails.PRM_Last_Name__c = con.LastName;
           // user.jobTitle = con.Core_Job_Function__c ;
           // user.profession = con.Core_Profession__c;
            registerUserDetails.PRM_Account_Name__c = acc.Name;
            
            registerUserDetails.PRM_Country__c = con.MailingCountry;
            registerUserDetails.PRM_State_Province__c = con.MailingState;
            registerUserDetails.PRM_Person_Phone_Number__c = con.Phone;
            registerUserDetails.PRM_Email_ID__c = con.Email;
        */
         //   user.partnerProgramSegment = null;    
            //user.preferredContact = PMP_StaticConstants_Partner.PreferredContact_CTA;
            system.debug('user-->'+registerUserDetails);
          //  submit(registerUserDetails,'Quote', null, null, null,  null, null);
     
      }
        system.debug('registerUserDetails-->'+registerUserDetails);  
        return registerUserDetails;
        
        
        
    }
   
    @AuraEnabled(cacheable = true)
    public static List<Option> getDependentMap() {
        return PMP_SearchCountryStateMapping.getDependentMap();
    }	
    
    //We have updated this method to receive Profession instead of Job Function
    //Sai: 12thNov2021
    @AuraEnabled(cacheable = true)
    public static List<Option> getPartnerProfession(){
        
        Schema.DescribeFieldResult jfResult = Contact.Core_Profession__c.getDescribe();
        Schema.sObjectField ctrlField = jfResult.getSObjectField();
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<Option> partnerProfessionList = new List<Option>();
        for( PickListEntry pe : contrEntries ){
            Option opt = new Option();
            opt.label = pe.label;
            opt.value = pe.value;
            partnerProfessionList.add(opt);
        }
        
        return partnerProfessionList;
    }
    
    
    
 /*   public static void submit(PRM_Registration_Request__c registerUserDetails, String formType, String partnerId, String partnerName, String offeringId, String offeringName, String offeringRecId){
        String userDetailsBody = '{"fieldValues": ';
        List<JsonSerializer> JsonSerializerList = new List<JsonSerializer>();
        Map<String, Core_Eloqua_Integration_for_Lead__mdt> eloquaIntMap = new Map<String, Core_Eloqua_Integration_for_Lead__mdt>();
        List<Core_Eloqua_Integration_for_Lead__mdt> eloquaIntList = [select Id, MasterLabel, DeveloperName, Core_Value__c from Core_Eloqua_Integration_for_Lead__mdt];
        system.debug('eloquaIntList '+eloquaIntList);
        for(Core_Eloqua_Integration_for_Lead__mdt eloquaInt : eloquaIntList){
            eloquaIntMap.put(eloquaInt.DeveloperName, eloquaInt);
        }
        Core_Lead_Staging__c leadStageObj = new Core_Lead_Staging__c();
        JsonSerializer js = new JsonSerializer();
        String value;
        for(String eloquaInt : eloquaIntMap.keyset()){
            js = new JsonSerializer();
            js.type = 'FieldValue';
            js.id = eloquaIntMap.get(eloquaInt).MasterLabel;
            value = eloquaIntMap.get(eloquaInt).Core_Value__c;
            if(eloquaInt.equalsIgnoreCase('firstName') && registerUserDetails.PRM_First_Name__c <> null){
                js.value = registerUserDetails.PRM_First_Name__c;
                leadStageObj.Core_First_Name__c = registerUserDetails.PRM_First_Name__c;
                system.debug('First if'+leadStageObj.Core_First_Name__c);
            }
            if(eloquaInt.equalsIgnoreCase('lastName') && registerUserDetails.PRM_Last_Name__c <> null){
                js.value = registerUserDetails.PRM_Last_Name__c;
                leadStageObj.Core_Last_Name__c = registerUserDetails.PRM_Last_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('companyName') && registerUserDetails.PRM_Account_Name__c <> null){
                js.value = registerUserDetails.PRM_Account_Name__c;
                leadStageObj.Core_Company__c = registerUserDetails.PRM_Account_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('country') && registerUserDetails.PRM_Country__c <> null){
                js.value = registerUserDetails.PRM_Country__c;
                leadStageObj.Core_Country__c = registerUserDetails.PRM_Country__c;
            }
            if(eloquaInt.equalsIgnoreCase('state') && registerUserDetails.PRM_State_Province__c <> null){
                js.value = registerUserDetails.PRM_State_Province__c;
                leadStageObj.Core_State__c = registerUserDetails.PRM_State_Province__c;
            }
            if(eloquaInt.equalsIgnoreCase('email') && registerUserDetails.PRM_Email_ID__c <> null){
                js.value = registerUserDetails.PRM_Email_ID__c;
                leadStageObj.Core_Email__c = registerUserDetails.PRM_Email_ID__c;
            }
            if(eloquaInt.equalsIgnoreCase('phone') && registerUserDetails.PRM_Person_Phone_Number__c <> null){
                js.value = registerUserDetails.PRM_Person_Phone_Number__c;
                leadStageObj.Core_Business_Phone__c = registerUserDetails.PRM_Person_Phone_Number__c;
            }

            
            if(js.value <> null){
                JsonSerializerList.add(js);
            }
        }
        
        String serializeData = JSON.serialize(JsonSerializerList);
        userDetailsBody = userDetailsBody + serializeData + '}';
        system.debug('Before Callout'+serializeData);
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
        
        httpReq.setEndpoint('callout:Core_IPALeadEloquaIntegration'); 
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setTimeout(120000);
        httpReq.setBody(userDetailsBody);
        httpResp = http.send(httpReq);
        
        sendEmailNotification(formType,leadStageObj,offeringName,partnerName);
        
        system.debug('Response body '+httpResp.getBody());
        System.debug('*STATUS_CODE:'+httpResp.getStatusCode());
        if(httpResp.getStatusCode() == 201){
            leadStageObj.Core_Status__c = 'Success';
        }else{
            leadStageObj.Core_Status__c = 'Failed';
            leadStageObj.Core_Eloqua_Error__c = httpResp.getBody();
        }
        System.debug('leadStageObj--'+leadStageObj);
        insert leadStageObj;
    } */
    
    public class JsonSerializer{
        public String type;
        public String id;
        public String value;
    }
    public static String getCommunityURL()
    {
        String communityURL = '{!Environment.RemoteSiteSetting: caseExport_community}/imp/s/partner/';
        return communityURL ;
    }
    
    @AuraEnabled(cacheable = true)
    public static List <Contact> getPartnerAdminAccounts() {
        Core_Account_Group_Member__c pagMember = new Core_Account_Group_Member__c();
        List<Core_Account_Group_Member__c> pagMemberList = new List<Core_Account_Group_Member__c>();
        List<String> intelAccountIds = new List<String>();
        List<String> partnerUserIds = new List<String>();
        List<String> partnerAdminUserIds = new List<String>();
        List<String> PartnerAdminUser = new List<String>();
        User user = [SELECT AccountId FROM User WHERE id =:Userinfo.getUserId()];
        try{
            pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: user.AccountId];
            pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c=:pagMember.Core_Partner_Account_Id__c]; 
        }catch(Exception e){
            System.debug('No PAG Records found : ' + e.getMessage());
        }
        
        for(Core_Account_Group_Member__c mem : pagMemberList){
            intelAccountIds.add(mem.Core_Intel_Account_Id__c);
        }
        
        List<User> partnerUserList = [SELECT id, AccountId from User where AccountId in: intelAccountIds ];
        
        for(User u : partnerUserList){
            partnerUserIds.add(u.id);
        }
        
        List<PermissionSetAssignment> partnerAdminAssignmentList = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId in:partnerUserIds AND PermissionSet.Name =:PMP_StaticConstants_Partner.PARTNER_ADMIN];
        
        for(PermissionSetAssignment pa : partnerAdminAssignmentList){
            partnerAdminUserIds.add(pa.AssigneeId);
        }
        List<User> PartnerUser = [SELECT id,ContactId from User where id in: partnerAdminUserIds];
        for(User u : PartnerUser){
            PartnerAdminUser.add(u.ContactId);
        }        
        List<Contact> partnerAdminUserList = [SELECT id,Name,Email,Phone from Contact where id in:PartnerAdminUser];
        return partnerAdminUserList;
    }
    
    public static void sendEmailNotification(String formType, Core_Lead_Staging__c leadStageObj,String offeringName,String partnerName){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailAddresses = new List<String>();
        emailAddresses.add(leadStageObj.Core_Email__c);
        mail.setToAddresses(emailAddresses);
        String borderStyle = 'border: 1px solid #d3d3d3;padding-left:50px;padding-top:5px;padding-bottom:5px;';
        String fontStyle = 'font-family:intel clear;font-size:14px;';
        if(formType == 'Quote'){
            mail.setSubject('Your Quote Inquiry: Submitted');
            mail.setHtmlBody(getQuoteTemplateBody(leadStageObj,offeringName,partnerName,borderStyle,fontStyle));
        }else{
            mail.setSubject('Your Inquiry: Submitted');
            mail.setHtmlBody(getEnquiryTemplateBody(leadStageObj,partnerName,borderStyle,fontStyle));
        }
        mail.setOrgWideEmailAddressId(System.Label.Core_SetFromEmailAddress);
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
    
    public static String getEnquiryTemplateBody(Core_Lead_Staging__c leadStageObj, String partnerName, String borderStyle, String fontStyle){
        String logoUrl = System.Label.Core_Intel_Logo_Id+'&amp;oid='+ UserInfo.getOrganizationId();
        String communityUrl = System.Label.Core_Marketplace_Url;
        String emailBody = '';
        emailBody += '       <html>  '  +  
            '           <body>  '  + 
            '               <table style="background-color:#0071c5;'+fontStyle+'" width="75%"><tbody><tr><td style="padding-left:50px;border: 0px;border:none;"><div style="color:white;"><h1>YOUR INQUIRY HAS BEEN SUBMITTED </h1></div></td><td align="right" style="border:none;padding-right:20px;"><img src="'+logoUrl+'"></td></tr></tbody></table>' +
            '               <table width="75%" style="border-collapse: collapse;'+fontStyle+'">   '  + 
            '    				<tr>  '  + 
            '                       <td style="'+borderStyle+'">  '  + 
            '                           Hello<br/><br/>     '  + 
            '                           Thanks for your recent request for information from '+partnerName+'. Your inquiry has been submitted. For your reference, please see the details of your request below.<br/>  '  + 
            '   					<p>Thanks for engaging with the Solutions Marketplace community</p>  '  + 
            '   					<b><p>The Intel Solutions Marketplace Team</p></b>  '  + 
            '                      <b>INQUIRY DETAILS<br /></b><hr />  '  + 
            '   					Submitted To: '+partnerName+'<br/>  '  + 
            '   					<p>What would you like to know?<br />  '  + leadStageObj.Core_Lead_Notes__c+' <br /><br />  '  + 
            '                       Tell us about you: <br />  '  + 
            '                       First Name: '+leadStageObj.Core_First_Name__c+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last Name: '+leadStageObj.Core_Last_Name__c+' <br />  '  + 
            '   					Company Name: '+leadStageObj.Core_Company__c+' <br />  '  + 
            '                       Country/Region: '+leadStageObj.Core_Country__c+' <br />  '  + 
            '                       State: '+leadStageObj.Core_State__c+' <br />  '  + 
            '                       Phone: '+leadStageObj.Core_Business_Phone__c+' <br />  '  + 
            '                       Email: '+leadStageObj.Core_Email__c+' <br/><br/></p>'  + 
            '   	               </td>  '  + 
            '                   </tr>  '  + 
            '                   <!-- Questions/Contact -->  '  + 
            '                           <tr>  '  + 
            '                               <td style="'+borderStyle+'">    '  + 
            '                                   Looking for more Intel Partners to collaborate with? <br/>  '  + 
            '                                   <a href="'+communityUrl+'" style="color:#0071c5;">  '  + 
            '                                   Explore the Marketplace </a> '  + 
            '                               </td>  '  + 
            '                            </tr>  '  + 
            '                    <!-- Questions/Contact -->  '  + getFooter(communityURL,borderStyle) +
            '              </table>  '  + 
            '           </body>  '  + 
            '      </html>  ' ;
        system.debug(' enquiry template emailbody---->'+emailBody);
        return emailBody;
    }
    
    public static String getQuoteTemplateBody(Core_Lead_Staging__c leadStageObj, String offeringName, String partnerName, String borderStyle, String fontStyle){
        String logoUrl = System.Label.Core_Intel_Logo_Id+'&amp;oid='+ UserInfo.getOrganizationId();
        String communityUrl = System.Label.Core_Marketplace_Url;
        String emailBody = '';
        emailBody += '       <html>  '  +  
            '           <body>  '  + 
            '               <table style="background-color:#0071c5;'+fontStyle+'" width="75%"><tbody><tr><td style="padding-left:50px;border: 0px;border:none;"><div style="color:white;"><h1>YOUR QUOTE INQUIRY HAS BEEN SUBMITTED </h1></div></td><td align="right" style="border:none;padding-right:20px;"><img src="'+logoUrl+'"></td></tr></tbody></table>' +
            '               <table width="75%" style="border-collapse: collapse;'+fontStyle+'">   '  + 
            '    				<tr>  '  + 
            '                       <td style="'+borderStyle+'">  '  + 
            '                       	Hello<br/><br/>      '  + 
            '                          Thanks for contacting '+partnerName+' regarding '+offeringName+'. Your quote inquiry has been submitted. For your reference, please see the details of your request below.<br/>  '  + 
            '   					<p>Thanks for taking part in the Solutions Marketplace community</p>  '  + 
            '   					<b><p>The Intel Solutions Marketplace Team</p></b> '  + 
            '                       <b>INQUIRY DETAILS</b><hr />  '  + 
            '   					Submitted To: '+partnerName + '<br/>' +
            '   					Volume for Quotation: '+leadStageObj.Core_Lead_Quotation_Cnt__c+'<br/>  '  + 
            '                       <p>Please describe how we can assist with your project: <br />	  '  + 
            '                       '+leadStageObj.Core_Lead_Notes__c+' </p> '  + 
            '                       <p>Tell us about you:<br />  '  + 
            '                       First Name: '+leadStageObj.Core_First_Name__c+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last Name: '+leadStageObj.Core_Last_Name__c+' <br />  '  + 
            '   					Company Name: '+leadStageObj.Core_Company__c+' <br />  '  + 
            '                       Country/Region: '+leadStageObj.Core_Country__c+' <br />  '  + 
            '                       State: '+leadStageObj.Core_State__c+' <br />  '  + 
            '                       Phone: '+leadStageObj.Core_Business_Phone__c+' <br />  '  + 
            '                       Email: '+leadStageObj.Core_Email__c+' <br/><br/></p> '  + 
            '   	               </td>  '  + 
            '                   </tr>  '  + 
            '                   <!-- Questions/Contact -->  '  + 
            '                           <tr>  '  + 
            '                               <td style="'+borderStyle+'">    '  + 
            '                                   Looking for more Intel Partners to collaborate with? <br/>  '  + 
            '                                   <a href="'+communityURL+'" style="color:#0071c5;">  '  + 
            '                                   Explore the Marketplace  </a>'  + 
            '                               </td>  '  + 
            '                            </tr>  '  + 
            '                    <!-- Questions/Contact -->  '  + getFooter(communityURL,borderStyle) +
            '              </table>  '  + 
            '           </body>  '  + 
            '      </html>  ' ; 
        system.debug(' quote template emailbody---->'+emailBody);
        return emailBody;
    }
    
    public static String getFooter(String communityURL, String borderStyle){
        String emailFooter = '<tr>      '  + 
            '        			<td style="'+borderStyle+'">  '  + 
            '                       	For FAQs and helpful information about using Intel® Solutions Marketplace, <br/>'  + 
            '                       	please visit <a href="'+System.Label.PMP_IPA_HelpLink+'" style="color:#0071c5;"> Marketplace Help. </a> '  + 
            '                   </td></tr>  '  + 
            '                   <tr><td style="font-size:10px;text-align:center;'+borderStyle+'">  '  + 
            '                           This message was sent to you as an important business communication related to your current relationship with Intel Solutions Marketplace<br/>  '  + 
            '                           ©'+System.Label.PMP_Current_Year+' Intel Corporation <br/>  '  + 
            '                           Intel Corporation, 2200 Mission College Blvd., M/S RNB4-145, Santa Clara, CA 95054 USA. '  + 
            '                           <a href="www.intel.com" style="color:#0071c5;"> www.intel.com</a><br/>  '  + 
            '                           <a href="www.intel.com/privacy" style="color:#0071c5;">Privacy</a> | &nbsp;  '  + 
            '                           <a href="www.intel.com/cookies" style="color:#0071c5;">Cookies</a>  '  + 
            '                     </td>  '  + 
            '                  </tr>  ';
        return emailFooter;
    }
}