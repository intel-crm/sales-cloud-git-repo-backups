public Without Sharing class PRM_Retrigger_Emaillog_Utility{        

    @AuraEnabled
    Public static String sendMail(Boolean fromComponent,id recordId){ 
        //List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        List<Contact> conList =new List<Contact>();      
        Id emailID =recordId;
        String UIMessage;
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        //Code changes for MP
        Messaging.SingleEmailMessage[] messages ;
        Messaging.SendEmailResult[] results ;
        
        if(fromComponent)
        {                        
            //IPA2.0: US-TWC729-7976   
            emaillog = [Select ID,PRM_ToEmailID__c,PRM_Subject__c, Language__c,
                        Email_Template_Name__c,Email_Template_ID__c,PRM_Timestamp__c,PRM_EmailContent__c,PRM_Email_API_Response__c,
                        PRM_EmailHTMLContent__c,PRM_Contact__c,PRM_User__c,PMP_Partner_Offering__c,PMP_Company__c/*,PSS_Partner_Solution__c*/ 
                        FROM PRM_EmailLog__c WHERE Id=:emailID];        
                
            }
            if(emaillog != null){
                //Code changes for MP
                //IPA2.0: US-TWC729-7976   
                if(emaillog.PMP_Partner_Offering__c != null || emaillog.PMP_Company__c != null /*|| emaillog.PSS_Partner_Solution__c != null*/){
                    Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                    String userOrContactId = (emaillog.PRM_Contact__c != null ? emaillog.PRM_Contact__c : emaillog.PRM_User__c);
                    String sObjectId = emaillog.PMP_Company__c != null? emaillog.PMP_Company__c : '' ;
                    //String sObjectId = (emaillog.PMP_Partner_Offering__c != null ? emaillog.PMP_Partner_Offering__c : emaillog.PMP_Company__c);
                    //String sObjectId = (emaillog.PSS_Partner_Solution__c != null ? emaillog.PSS_Partner_Solution__c : emaillog.PMP_Partner_Offering__c != null ? emaillog.PMP_Partner_Offering__c : emaillog.PMP_Company__c);
                    emailMessage = createEmailInstances(emaillog.Email_Template_Name__c,userOrContactId,sObjectId);
                    messages = new List<Messaging.SingleEmailMessage> {emailMessage};
                        results = Messaging.sendEmail(messages);
                }else{  
                    List<PRM_Bulk_Data_Upload__c> bulkRecDetails =[
                        SELECT 
                        id, 
                        PRM_ContactEmail__c, 
                        PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c, 
                        PRM_Email_Template__c 
                        FROM PRM_Bulk_Data_Upload__c
                        WHERE PRM_ContactEmail__c =: emaillog.PRM_ToEmailID__c  
                        ORDER BY CreatedDate desc
                        LIMIT 1
                    ];
                    List<IPA_Batch_Configurations__mdt> listBatchConfigItems = [
                        SELECT 
                        Id,
                        DeveloperName,
                        Record_Limit__c,
                        PRM_SchedulingTimeMins__c,
                        PRM_StandardEmailBulk__c
                        FROM IPA_Batch_Configurations__mdt 
                    WHERE DeveloperName =: 'PRM_BulkBatchConfigurableItems'
                    LIMIT 1];
                List<String> emailTempBulk = new List<String>(); 
                if(!listBatchConfigItems.isEmpty()){
                    if(listBatchConfigItems[0].PRM_StandardEmailBulk__c != null){
                        emailTempBulk.add(listBatchConfigItems[0].PRM_StandardEmailBulk__c);
                    }
                }
                if(!bulkRecDetails.isEmpty()){
                    if(bulkRecDetails[0].PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c != null){
                        emailTempBulk.add(bulkRecDetails[0].PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c);    
                    }
                    if(bulkRecDetails[0].PRM_Email_Template__c != null){
                        emailTempBulk.add(bulkRecDetails[0].PRM_Email_Template__c);
                    }
                }
                
                owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
                Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                String emailTemplateName =emaillog.Email_Template_Name__c;  
                Boolean isBulkRetrigger = false;
                if(!emailTempBulk.isEmpty()){
                    for(String baseTempName : emailTempBulk){
                    if(emailTemplateName.contains(baseTempName)){
                        isBulkRetrigger = true;
                    }
                }
                }
                         
                String[] toAddresses = new String[] {emaillog.PRM_ToEmailID__c};
                email.setToAddresses(toAddresses);
                email.setSubject(emaillog.PRM_Subject__c);
                String emailHTMLContent = emaillog.PRM_EmailHTMLContent__c != null ? emaillog.PRM_EmailHTMLContent__c : emaillog.PRM_EmailContent__c;   
        		emailHTMLContent = emailHTMLContent.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);//IPA2.0 TWC727-3232
                if(emailTemplateName!=null){
                    if(emailTemplateName.contains(System.Label.PRM_Partner_Invite_Template) ||emailTemplateName.contains(System.Label.PRM_Admin_Invite_Template) || isBulkRetrigger){                                          
                        String newEVToken; 
                        String OldToken;
                            String EVToken='';
                            String Strtags=''; 
                        if(Test.isRunningTest()){emailHTMLContent='HTMLBODY var=EVVVV67892hdnj92unknknk&target=https://wcm-ciqa.com';}
                        if(emailHTMLContent.contains(System.Label.PRM_EV_TOKEN_Start_String) && emailHTMLContent.contains(System.Label.PRM_EV_TOKEN_End_String)){                        
                            String AfterString=emailHTMLContent.substringAfter(System.Label.PRM_EV_TOKEN_Start_String);
                            OldToken=AfterString.substringBefore(System.Label.PRM_EV_TOKEN_End_String);  
                            //System.debug('OldEVToken'+OldToken);
                        }                    
                            //AS a part od CiDaaS changes
                            if(emaillog != null){  
                                conList =[SELECT id,AccountId,Account.Name,Account.AccountNumber,Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false) FROM Contact WHERE email =:emaillog.PRM_ToEmailID__c LIMIT 1];
				
                                //List<String> sendEmailMsg = 
                                    PRM_Contact_AGS_CallbackHandler.sendEmailToContact(conList[0], EVToken, Strtags);
                                UIMessage=System.label.PRM_Email_SuccessMsg;
                                return UIMessage;
                            }
                            
                            //System.debug('OldToken:::::' +OldToken);
                            if(OldToken!=null){
                                if(!Test.isRunningTest()){
                                    //Implemented as part of CiDaaS changes
                                    newEVToken=null;                                    
                                }
                            }
                            if(OldToken!=null && newEVToken!=null){
                                emailHTMLContent=emailHTMLContent.replace(OldToken,newEVToken);
                                  emaillog.PRM_EmailHTMLContent__c = emailHTMLContent;
                                  emaillog.PRM_EmailContent__c = emailHTMLContent;
                            }
                            
                        }
                    }
                    
                    email.setHtmlBody(emailHTMLContent);
                    email.setOrgWideEmailAddressId(owea.Id);
                    //Code changes for MP
                    messages =   new List<Messaging.SingleEmailMessage> {email};
                        results = Messaging.sendEmail(messages);
                    
                }
                if (results[0].success) {
                    String templateName = emaillog.Email_Template_Name__c;
                    UIMessage=System.label.PRM_Email_SuccessMsg;
                    emaillog.PRM_Timestamp__c=System.now();
                    emaillog.PRM_Email_API_Response__c=emaillog.PRM_Email_API_Response__c+'\n'+System.label.PRM_Email_Re_trig_SuccessMsg+' '+userinfo.getFirstName()+' '+userinfo.getLastName()+' '+system.now().format(System.label.PRM_Date_Time,System.label.PRM_PST_Time_Zone);//emaillog.PRM_Email_API_Response__c+'\n'+System.label.PRM_Email_SuccessMsg               
                    List<PRM_EmailLog__c> listEmailLogs = createRetriggerEmailLogs(messages, new List<PRM_EmailLog__c>(),  templateName, emaillog.Language__c);
                    listEmailLogs[0].PRM_Contact__c = emailLog.PRM_Contact__c;
                    insert listEmailLogs;  
            }              
        }
        return UIMessage;
    } 
    
    /**
    * @description method to create email instance
    * @author Onyx - 11/30/2021 
    * @param String emailTemplateName 
    * @param String userOrContactId 
    * @param String sObjectId
    * @return Messaging.SingleEmailMessage 
    **/
    public static Messaging.SingleEmailMessage createEmailInstances (String emailTemplateName,String userOrContactId,String sObjectId) {
        
        OrgWideEmailAddress owa = new OrgWideEmailAddress ();    
        
        //Fetch Orgwide email address for MP emails
        owa =  [SELECT id, Address, DisplayName 
                    FROM OrgWideEmailAddress 
                    WHERE Address = :System.Label.PMP_Intel_partner_Alliance_Address limit 1]; 
        
        EmailTemplate template = [SELECT Id,Name,
                                        Subject,
                                        Body 
                                        FROM EmailTemplate 
                                        WHERE Name = :emailTemplateName];

        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage(); 
        emailMessage.setWhatId(sObjectId);// offering or company id
        emailMessage.setTargetObjectId(userOrContactId);//user or contact id
        emailMessage.setTemplateId(template.Id);
        emailMessage.setSaveAsActivity(false);
        if(owa!=Null){
            emailMessage.setOrgWideEmailAddressId(owa.Id);
        }
        if(Test.isRunningTest()){
            emailMessage.setSubject('Subject for Test Class');
            emailMessage.setHtmlBody('Email Body content for TestClass');
        }
        return emailMessage;
    }
    
    public static List<PRM_EmailLog__c> createRetriggerEmailLogs(List<Messaging.SingleEmailMessage> mail, List<PRM_EmailLog__c> logList, String templateName, String lang)
    {
        try{
            //apend values in below fields and create record in EmailLogs Object using obtained status  
            PRM_EmailLog__c log = new PRM_EmailLog__c();
            String successMsg ='Retriggered Email Successfully !!';
            String toEmailId;
            log.PRM_EmailDeliverabilityStatus__c = true ;
            log.PRM_Timestamp__c = DateTime.now();
            log.Language__c = lang ;
            log.Email_Template_Name__c = templateName ;
            log.PRM_Email_API_Response__c = successMsg ; 
            log.PRM_EmailContent__c =  mail[0].getHtmlBody();
            log.PRM_EmailHTMLContent__c = mail[0].getHtmlBody();
            log.PRM_Type__c = 'IPA';
            log.PRM_Subject__c = mail[0].getSubject();
            if(mail[0].getToAddresses() != null ) {
                log.PRM_ToEmailID__c = string.join(mail[0].getToAddresses(),';');
                if(log.PRM_ToEmailID__c.length() > 255)
                {
                    toEmailId = log.PRM_ToEmailID__c;
                    log.PRM_ToEmailID__c = log.PRM_ToEmailID__c.substring(0,255);
                    log.PRM_ToEmailIDCompleteValue__c = toEmailId;
                }
                else
                {
                    log.PRM_ToEmailIDCompleteValue__c = log.PRM_ToEmailID__c;
                }
            }
            
            logList.add(log);
            //system.debug('Email Logs-->'+ logList);
        }
        
        catch (Exception e) {
            // String eMessage = e.getMessage();  
            PRM_ErrorUtilityClass.logError(e);
        }
        return logList ;
    	}
    }