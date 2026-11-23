public with sharing class PMP_SearchCompanyLeadGenController extends PMP_SearchWrapperStore {
    
    
    Public String communityURL;
    Public UserDetails user;
    
   @AuraEnabled
    public static LeadGenSettings getExistingSettings(String partnerId){
        PMP_Company__c partner;
        
        
        partner = [SELECT toLabel(PMP_Company_Lead_Gen_Language_Nm__c)
                   ,PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c
                   from PMP_Company__c WHERE id =: partnerId];        
        
        
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
        
        
        
        company = [SELECT id, PMP_Working_Copy_Id__c from PMP_Company__c where id=:partnerId];         
        
        
        String wcId = '';
        if(String.isNotEmpty(company.PMP_Working_Copy_Id__c)  ){
            wcId = company.PMP_Working_Copy_Id__c;
        }
        else{
            return false;
        }
        
        partnerList = [SELECT PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Lead_Gen_Language_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where id=: wcId];         
        
        
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
        
        //if(Schema.sObjectType.PMP_Company__c.isUpdateable()){
        update partnerList;
        //}         
        return true;
    }
    
    @AuraEnabled
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
    public static UserDetails fetchUser(){      
        UserDetails user=null;
        User user1 = new User();
        Contact con = new Contact();
        Account acc = new Account();
        Boolean isGuest = PMP_SearchUtilityController.isGuest();
        if(!isGuest){
            user = new UserDetails();    
            if(Schema.sObjectType.User.isAccessible()){
                user1 = [Select id,ContactId from User where id=: userInfo.getUserId()];
            }
            
            if(user1!=null && (!String.isBlank(user1.ContactId))) {
                if(Schema.sObjectType.Contact.isAccessible()){
                    con = [select id,AccountId, FirstName, LastName, Email,Phone,Title,Core_Job_Function__c,MailingCountry,MailingState  from Contact where id=: user1.ContactId]; 
                    system.debug('contact Info'+con);
                    
                }if(con!=null && (!String.isBlank(con.AccountId))){
                    if(Schema.sObjectType.Account.isAccessible()){
                        acc= [select id,Name,Core_Account_State_Province__c,Core_Account_Country__c from Account where id=: con.AccountId];
                    }
                }
            }
            
            user.firstName = con.FirstName;
            user.lastName = con.LastName;
            user.jobTitle = con.Core_Job_Function__c ;
            user.companyName = acc.Name;
            
            user.country = con.MailingCountry;
            user.state = con.MailingState;
            user.phone = con.Phone;
            user.email = con.Email;
            user.partnerProgramSegment = null;    
            //user.preferredContact = PMP_StaticConstants_Partner.PreferredContact_CTA;
            system.debug('user'+user);
        }    
        return user;
    }
    
 /*   public static String getSegment(String intelAccountId){
        String segment = '';
        
        try{
            segment = [SELECT id, Core_IPA_Partner_Segment__c from Account where id=: intelAccountId limit 1].Core_IPA_Partner_Segment__c;
        }catch(Exception e){
            system.debug('Error is fetching segment : ' + e.getMessage());
        }
        return segment;
    } */
    
    @AuraEnabled(cacheable = true)
    public static List<Option> getDependentMap() {
        return PMP_SearchCountryStateMapping.getDependentMap();
    }	
    
    @AuraEnabled
    public static List<Option> getJobFunction(){
        
        Schema.DescribeFieldResult jfResult = Contact.Core_Job_Function__c.getDescribe();
        Schema.sObjectField ctrlField = jfResult.getSObjectField();
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<Option> jobFunctionList = new List<Option>();
        for( PickListEntry pe : contrEntries ){
            Option opt = new Option();
            opt.label = pe.label;
            opt.value = pe.value;
            jobFunctionList.add(opt);
        }
        
        return jobFunctionList;
    }
    
    
    @AuraEnabled
    public static void submit(UserDetails user, String formType, String partnerId, String partnerName, String offeringId, String offeringName, String offeringRecId){
        String userDetailsBody = '{"fieldValues": ';
        List<JsonSerializer> JsonSerializerList = new List<JsonSerializer>();
        Map<String, Core_Eloqua_Integration_Setting__mdt> eloquaIntMap = new Map<String, Core_Eloqua_Integration_Setting__mdt>();
        List<Core_Eloqua_Integration_Setting__mdt> eloquaIntList = [select Id, MasterLabel, DeveloperName, Core_Value__c from Core_Eloqua_Integration_Setting__mdt];
        system.debug('eloquaIntList '+eloquaIntList);
        for(Core_Eloqua_Integration_Setting__mdt eloquaInt : eloquaIntList){
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
            if(eloquaInt.equalsIgnoreCase('firstName') && user.firstName <> null){
                js.value = user.firstName;
                leadStageObj.Core_First_Name__c = user.firstName;
            }
            if(eloquaInt.equalsIgnoreCase('lastName') && user.lastName <> null){
                js.value = user.lastName;
                leadStageObj.Core_Last_Name__c = user.lastName;
            }
            if(eloquaInt.equalsIgnoreCase('companyName') && user.companyName <> null){
                js.value = user.companyName;
                leadStageObj.Core_Company__c = user.companyName;
            }
            /*if(eloquaInt.equalsIgnoreCase('jobFunction') && user.jobTitle <> null){
                js.value = user.jobTitle;
                leadStageObj.Core_Job_Title__c = user.jobTitle;
            }*/
            if(eloquaInt.equalsIgnoreCase('country') && user.country <> null){
                js.value = user.country;
                leadStageObj.Core_Country__c = user.country;
            }
            if(eloquaInt.equalsIgnoreCase('state') && user.state <> null){
                js.value = user.state;
                leadStageObj.Core_State__c = user.state;
            }
            if(eloquaInt.equalsIgnoreCase('deliveryDate') && user.deliveryDate <> null){
                js.value = String.valueOf(user.deliveryDate);
                leadStageObj.PMP_Offering_ExpDelivery_Dt__c = user.deliveryDate;
            }
            if(eloquaInt.equalsIgnoreCase('leadNotes') && user.description <> null){
                js.value = user.description;
                leadStageObj.Core_Lead_Notes__c = user.description;
            }
            if(eloquaInt.equalsIgnoreCase('email') && user.email <> null){
                js.value = user.email;
                leadStageObj.Core_Email__c = user.email;
            }
            if(eloquaInt.equalsIgnoreCase('phone') && user.phone <> null){
                js.value = user.phone;
                leadStageObj.Core_Business_Phone__c = user.phone;
            }
            if(eloquaInt.equalsIgnoreCase('volume') && user.volume <> null){
                js.value = String.valueOf(user.volume);
                leadStageObj.Core_Lead_Quotation_Cnt__c = String.valueOf(user.volume);
            }
            if(eloquaInt.equalsIgnoreCase('PartnerMDA_ID') && partnerId <> null){
                js.value = partnerId;
                leadStageObj.PMP_MDA_BizOrg_Id__c = partnerId;
            }
            if(eloquaInt.equalsIgnoreCase('partnerName') && partnerName <> null){
                js.value = partnerName;
                leadStageObj.Core_Partner_Name__c = partnerName;
            }
            if(eloquaInt.equalsIgnoreCase('OfferingId') && offeringId <> null){
                js.value = offeringId;
                leadStageObj.PMP_Offering_Id__c = offeringId;
            }
            if(eloquaInt.equalsIgnoreCase('Offering_Referring_URL') && offeringRecId <> null && offeringRecId <> ''){
                js.value = System.Label.Core_Marketplace_Url + '/s/offering/' + offeringRecId;
                leadStageObj.PMP_Offering_Referring_URL__c = System.Label.Core_Marketplace_Url + '/s/offering/'+ offeringRecId;
            }
            if(eloquaInt.equalsIgnoreCase('partnerProgramSegment') && user.partnerProgramSegment <> null){
                js.value = String.valueOf(user.partnerProgramSegment);
                leadStageObj.PMP_MktProfile_BizSegment__c = user.partnerProgramSegment;
            }
            if(eloquaInt.equalsIgnoreCase('NotifyOwner')){
                js.value = value;
                leadStageObj.Core_Notify_Owner__c = Boolean.valueOf(value);
            }
            if(eloquaInt.equalsIgnoreCase('specificLeadSource')){
                js.value = value;
                leadStageObj.Core_Specific_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction') && formType == 'quote'){
                js.value = 'Requested Quote';
                leadStageObj.Core_Lead_PMP_Action__c = 'Requested Quote';
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction') && formType == 'contact'){
                js.value = 'Asked for Follow-Up';
                leadStageObj.Core_Lead_PMP_Action__c = 'Asked for Follow-Up';
            }
            if(eloquaInt.equalsIgnoreCase('WebVisitSessionId') && user.sessionId <> null){
                js.value = user.sessionId;
                leadStageObj.Core_Web_Visit_Session_ID__c = user.sessionId;
            }
            if(eloquaInt.equalsIgnoreCase('LeadFormSubmitDate')){
                js.value = String.valueOf(system.now());
                leadStageObj.Core_Lead_Form_Submit_Date__c = system.now();
            }
            if(eloquaInt.equalsIgnoreCase('leadSource')){
                js.value = value;
                leadStageObj.Core_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('leadConversionPoint')){
                js.value = value;
                leadStageObj.Core_Lead_Conversion_Point__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sfdcCampaignID')){
                js.value = value;
                leadStageObj.Core_MktCampaign_Id__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('marketingTacticID')){
                js.value = value;
                leadStageObj.Core_Marketing_Tactic_ID__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sourceID')){
                js.value = value;
                leadStageObj.Core_Source_Id__c = value;
            }
            
            if(js.value <> null){
                JsonSerializerList.add(js);
            }
        }
        
        String serializeData = JSON.serialize(JsonSerializerList);
        userDetailsBody = userDetailsBody + serializeData + '}';
        
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
        insert leadStageObj;
    }
    
    public class JsonSerializer{
        public String type;
        public String id;
        public String value;
    }
    public static String getCommunityURL()
    {
        String communityURL = 'https://crmqa2-intelcloudcrm.cs93.force.com//imp/s/partner/';
        return communityURL ;
    }
    
    @AuraEnabled
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
        return emailBody;
    }
    
    public static String getFooter(String communityURL, String borderStyle){
        String emailFooter = '<tr>      '  + 
            '        			<td style="'+borderStyle+'">  '  + 
            '                       	For FAQs and helpful information about using Intel® Solutions Marketplace, <br/>'  + 
            '                       	please visit <a href="'+communityURL+'/s/help'+'" style="color:#0071c5;"> Marketplace Help. </a> '  + 
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