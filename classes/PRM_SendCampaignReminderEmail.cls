public class PRM_SendCampaignReminderEmail  implements  Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts{
  public static final String LOG_ENTRY_ORIGIN   = 'PRM_SendCampaignReminderEmail';
  public static final String LOG_ENTRY_PROJECT  = 'Campaign Reminder';
  public static final String LOG_ENTRY_SCOPE    = 'PRM_SendCampaignReminderEmail';
  public static final String LOG_ENTRY_SEVERITY = 'Medium'; 

  public Database.QueryLocator start(Database.BatchableContext bc) {
  Date Today = Date.today();
  String query = 'Select ID,PRM_Campaign__c,PRM_Status__c, PRM_Reminder_Date__c,PRM_Email_Template__c,PRM_Reminder_Email__c.Failed_Contacts__c, PRM_Reminder__c,PRM_BatchID__c FROM PRM_Reminder_Email__c where PRM_Status__c =\'Scheduled\' and PRM_Reminder_Date__c =:Today';
  return Database.getQueryLocator(query); 
  }

  public void execute(Database.BatchableContext bc,List<PRM_Reminder_Email__c> reminderRecords)
  {      
     system.debug('REMINDER'+reminderRecords);
     try{
     List<Messaging.SingleEmailMessage > allEmails = new List<Messaging.SingleEmailMessage >();
     Map<String,Id> userNameIdMap = new Map<String,Id>(); 
     Map<String,String> userConIdMap = new Map<String,String>();  
     List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();                            
     Map<String,PRM_Bulk_Data_Upload__c> ContactBulkRecordMap = new Map<String,PRM_Bulk_Data_Upload__c>();
     Map<String,PRM_Reminder_Email__c> batchToReminderMap = new Map<String,PRM_Reminder_Email__c>();
     Map<Id,Set<Id>> failedContactMap = new Map<Id,Set<Id>>();
     Map<Id,String> contactMap = new Map<Id,String>();
     List<contact> conList = new List<contact>();
     List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
      
     for(PRM_Reminder_Email__c reminderRec: reminderRecords){
         reminderRec.PRM_Status__c='Reminder Processed';
         batchToReminderMap.put(reminderRec.PRM_BatchID__c,reminderRec);
     }
     system.debug('REMINDER MAP'+batchToReminderMap.keyset());

     for(PRM_Bulk_Data_Upload__c bulkRec : [Select ID,PRM_Contact_Id__c,PRM_Preferred_Language__c, PRM_BatchID__c, 
                                             PRM_Suppress_Email__c,PRM_CampaignId__c,PRM_Email_Template__c,PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c
                                            from PRM_Bulk_Data_Upload__c where PRM_BatchID__c in :batchToReminderMap.keySet() and PRM_Suppress_Email__c = FALSE and PRM_Send_Reminders__c=true and PRM_CampaignId__c!=null]){
        ContactBulkRecordMap.put(bulkRec.PRM_Contact_Id__c,bulkRec);
      }
      List<String> alleEmailTempDevNames = new List<String>();     
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
       String standadrdEmailTemp = listBatchConfigItems[0].PRM_StandardEmailBulk__c+'_English';
       alleEmailTempDevNames.add(standadrdEmailTemp);
      
       Map<String,String> languageToDefaultTemplateMap = new Map<String,String>();
       for(PRM_EmailConfigurationDetails__mdt emailConfig : [
           SELECT
           PRM_Language__c, 
           PRM_BusinessEvent__c,
           PRM_TemplateUniqueName__c
           FROM PRM_EmailConfigurationDetails__mdt
           WHERE PRM_TemplateUniqueName__c like :listBatchConfigItems[0].PRM_StandardEmailBulk__c+'%']
          ){
              if(!String.isEmpty(emailConfig.PRM_Language__c)){
                  languageToDefaultTemplateMap.put(emailConfig.PRM_Language__c, emailConfig.PRM_TemplateUniqueName__c );
              }
          }
     
      owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];

      if(ContactBulkRecordMap.keySet() != null){        
        for(User eachUser :[SELECT ID,Name,Email,ContactID FROM User where ContactID in :ContactBulkRecordMap.keySet()]){
           userNameIdMap.put(eachUser.ContactId,eachUser.id);
           userConIdMap.put(eachUser.id,eachUser.ContactID);
        }
    }    
    
        conList = [SELECT Id,Name,AccountId,Account.Name,Firstname,lastname,
        Account.AccountNumber,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,
        Core_IPA_Email_Verification_Date__c,(
          SELECT
          PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name
          FROM Account_Contact_Relationships__r)
          FROM Contact WHERE Core_Do_Not_Contact__c = false and Id IN :ContactBulkRecordMap.keySet()
        AND Id IN
        (
        SELECT
        PRM_Contact_Id__c
        FROM PRM_Account_Contact_Relationship__c  
        WHERE PRM_InActive_Ind__c = FALSE AND PRM_Suppress_Email__c = FALSE	AND PRM_Status_Nm__c = 'Pending Action')
        ];
    system.debug('ACR '+conList);

   Map<ID,String> contactEmailMap = new    Map<ID,String>(); 
   Map<Id,String> relationshipMap = new  Map<Id,String>();
   list<String> langList = new    list<String>();

   //mapping the Reminder Emailtemplate for each contact based on priority     
    for(Contact eachRec : conList){      
     String reminderTemplateId;
     langList.add(eachRec.Core_Preferred_Language__c);
     if(batchToReminderMap.get(ContactBulkRecordMap.get(eachRec.id).PRM_BatchID__c).PRM_Email_Template__c == null){
      //Considering the template mentioned at the campaign level if not specified then template is choosen from bulk record.
            String emailType =  ContactBulkRecordMap.get(eachRec.id).PRM_CampaignId__c != null && ContactBulkRecordMap.get(eachRec.id).PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c != null ?ContactBulkRecordMap.get(eachRec.id).PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c :ContactBulkRecordMap.get(eachRec.id).PRM_Email_Template__c != null? ContactBulkRecordMap.get(eachRec.id).PRM_Email_Template__c:null;
                 
            //default email + suffix the language
            String templateName = emailType != null? emailType+'_'+ContactBulkRecordMap.get(eachRec.id).PRM_Preferred_Language__c
                           : languageToDefaultTemplateMap.containsKey(ContactBulkRecordMap.get(eachRec.id).PRM_Preferred_Language__c)
                           ? languageToDefaultTemplateMap.get(ContactBulkRecordMap.get(eachRec.id).PRM_Preferred_Language__c): languageToDefaultTemplateMap.get('ENG');
           //String templateEngVersion = templateName != null ? templateName +'_ENG': languageToDefaultTemplateMap.get('ENG');
        String templateEngVersion = templateName != null ? emailType+'_ENG': languageToDefaultTemplateMap.get('ENG');         
        alleEmailTempDevNames.add(templateName);
        alleEmailTempDevNames.add(templateEngVersion);            
        contactEmailMap.put(eachRec.id,templateName);        
       }else{
         //if template is found at reminder record
        reminderTemplateId =  batchToReminderMap.get(ContactBulkRecordMap.get(eachRec.id).PRM_BatchID__c).PRM_Email_Template__c +'_'+ (ContactBulkRecordMap.get(eachRec.id).PRM_Preferred_Language__c!= null?ContactBulkRecordMap.get(eachRec.id).PRM_Preferred_Language__c :'ENG');
         System.debug('rem template'+reminderTemplateId);
         alleEmailTempDevNames.add(reminderTemplateId);
         String templateEngVersion = reminderTemplateId != null ? batchToReminderMap.get(ContactBulkRecordMap.get(eachRec.id).PRM_BatchID__c).PRM_Email_Template__c +'_ENG': languageToDefaultTemplateMap.get('ENG');          
         alleEmailTempDevNames.add(templateEngVersion);
         
         contactEmailMap.put(eachRec.id,reminderTemplateId);        
          }
       contactMap.put(eachRec.id,eachRec.Email);
      for(PRM_Account_Contact_Relationship__c conACR :eachRec.Account_Contact_Relationships__r){
          system.debug('here'+conACR.PRM_Relationship_Id__r.Name);
        if(conACR.PRM_Relationship_Id__r.Name == System.Label.PRM_Primary_Contact)
        relationshipMap.put(eachRec.id,System.Label.PRM_Primary_Contact);
      }
      if(!relationshipMap.containsKey(eachRec.id)){
        relationshipMap.put(eachRec.id,System.Label.PRM_WorksFor);     
      }
    }
    List<EmailTemplate> listEmailTemplate = [
                       SELECT 
                       id, Name,
                       DeveloperName,
                       HtmlValue, 
                       Subject 
                       FROM EmailTemplate
                       WHERE  DeveloperName in: alleEmailTempDevNames];
                   Map<String, EmailTemplate> mapDevNameToEmailTemp = new Map<String, EmailTemplate>();
                   if(!listEmailTemplate.isEmpty()){
                       for(EmailTemplate emtemp: listEmailTemplate){
                           mapDevNameToEmailTemp.put(emtemp.DeveloperName, emtemp);
                       }
                   }
    Map<String,PRM_Language_Culture_Mapping__mdt> cultureMap = new Map<String,PRM_Language_Culture_Mapping__mdt>();             
    for(PRM_Language_Culture_Mapping__mdt lngCultureMdt : [
    SELECT 
    Id,
    MasterLabel,
    PRM_Culture__c,
    PRM_Country__c,
    PRM_Country_Cd__c 
    FROM PRM_Language_Culture_Mapping__mdt
    WHERE MasterLabel IN :langList])
    {
cultureMap.put(lngCultureMdt.MasterLabel,lngCultureMdt);
    }
                
    
    List<Core_Log_Entry__c> logEntryList = new  List<Core_Log_Entry__c>();
    List<String> failedContacts = new List<String>();
    //system.debug('TEMPL '+templateIdMap);    
     if(conList != null && !conList.IsEmpty()){
        for(Contact eachRec : conList){
         String tempEmail= contactEmailMap.get(eachRec.id).substringAfterLast('_');
         String engVersion =  contactEmailMap.get(eachRec.id).replace(tempEmail,'ENG');
         String emailBody = '';
         Boolean isUpdateInvite = true;
         Boolean supressEmailForInvite = false;
         String primaryContURL = System.Label.PRM_CiDaaS_PrimaryContact_Link;
          String secondaryContURL = System.Label.PRM_CiDaaS_Secondary_Invite_Link;
          String supportContURL = System.Label.PRM_Admin_Support_Link;
          String CompleteNowURL = '';
          String culture = '';   
          String countryCode = '';
          String countryCodeCulture = '';
          String countrycdcul = '';
          map<String,Language_Translation__mdt> dynamicTranslations =  new map<String,Language_Translation__mdt>();
                             
          for(Language_Translation__mdt langTrans : [select DeveloperName, DEU__c, ENG__c, ENU__c, FRA__c, IND__c, ITA__c,JPN__c, KOR__c, POL__c, POR__c, RUS__c, SPA__c, ESP__c,  THA__c, TUR__c, VIE__c, ZHO__c, ZHT__c from Language_Translation__mdt]){
              dynamicTranslations.put(langTrans.DeveloperName,langTrans);    
          }
          
      String Buttontext;     
          Buttontext =  dynamicTranslations.get('Complete_Now_Button_Name')!= null ?(String) dynamicTranslations.get('Complete_Now_Button_Name').get(eachRec.Core_Preferred_Language__c + '__c'):null;
           
                culture = cultureMap.get(eachRec.Core_Preferred_Language__c)!=null ? cultureMap.get(eachRec.Core_Preferred_Language__c).PRM_Culture__c : 'en';
                countryCodeCulture = getCountryCodeForUrl(eachRec, cultureMap.get(eachRec.Core_Preferred_Language__c));
                List<String> countryCodeCultureArr = countryCodeCulture.split('/');
                countrycdcul = countryCodeCultureArr[1]+'-'+countryCodeCultureArr[0];
                secondaryContURL = secondaryContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
                primaryContURL = primaryContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
                supportContURL = supportContURL.replace('{{CULTURECODE}}',countrycdcul);
                /*if(relationshipMap.get(eachRec.id) == System.Label.PRM_WorksFor){
                CompleteNowURL = secondaryContURL;}
                else{
                CompleteNowURL = primaryContURL;
                }*/
              CompleteNowURL = secondaryContURL;             
              PRM_EmailLog__c log = new PRM_EmailLog__c();
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              List<String> emailAddress = new List<String>();
              EmailTemplate emailTemplate;
              emailAddress.add(eachRec.Email);
             if(mapDevNameToEmailTemp.containsKey(contactEmailMap.get(eachRec.id))){
               emailTemplate = mapDevNameToEmailTemp.get(contactEmailMap.get(eachRec.id));
               emailBody = mapDevNameToEmailTemp.get(contactEmailMap.get(eachRec.id)).HtmlValue; 
             }
           else if(mapDevNameToEmailTemp.containsKey(engVersion)){
               emailTemplate = mapDevNameToEmailTemp.get(engVersion);
               emailBody = mapDevNameToEmailTemp.get(engVersion).HtmlValue;
           }
         else{
               emailTemplate = mapDevNameToEmailTemp.get(standadrdEmailTemp);
               emailBody = mapDevNameToEmailTemp.get(standadrdEmailTemp).HtmlValue;
           } 
          
              //key - conID
              if(userNameIdMap.containsKey(eachRec.Id)){
                 mail.setTargetObjectId(userNameIdMap.get(eachRec.Id));
               }else{
                 mail.setTargetObjectId(eachRec.Id);
               }
              if(String.isNotBlank(CompleteNowURL)){emailBody = emailBody.replace('{{EVLINK}}', CompleteNowURL);}
              if(String.isNotBlank(supportContURL)){emailBody = emailBody.replace('{{SUPPORTLINK}}', supportContURL);}
              if(String.isNotBlank(eachRec.Email)){emailBody = emailBody.replace('{!Contact.Email}', eachRec.Email);}
              if(String.isNotBlank(eachRec.FirstName)){emailBody = emailBody.replace('{!Contact.FirstName}', eachRec.FirstName);}
              if(String.isNotBlank(eachRec.LastName)){emailBody = emailBody.replace('{!Contact.LastName}', eachRec.LastName);}
              if(String.isNotBlank(eachRec.Account.Name)){emailBody = emailBody.replace('{{ACCOUNTNAME}}', eachRec.Account.Name);}
              if(String.isNotBlank(Buttontext)){emailBody = emailBody.replace('{{ButtonText}}',Buttontext);}                
              if(String.isNotBlank(eachRec.Account.AccountNumber)){emailBody = emailBody.replace('{{ACCOUNTNUMBER}}',eachRec.Account.AccountNumber);}
              //emailBody = emailBody.replace('{!$Label.Core_MDF_PFRDetailLink}',Label.Core_MDF_PFRDetailLink);
              mail.setSubject(emailTemplate.Subject);
              mail.setOrgWideEmailAddressId(owea[0].Id);
              mail.setHtmlBody(emailBody); 
              String objType = String.valueof(mail.getTargetObjectId().getSObjectType());
              if(objType == System.Label.PRM_Object_Contact){
                 log.PRM_Contact__c = mail.getTargetObjectId() ;
                 log.PRM_ToEmailID__c = eachRec.Email ;
             }else if (objType == System.Label.PRM_Object_User){log.PRM_Contact__c = eachRec.Id;
                                                                log.PRM_User__c = mail.getTargetObjectId(); 
                                                                log.PRM_ToEmailID__c = eachRec.Email ;
                                                               }
              allEmails.add(mail);
              /* Setting all the fields realted to Email Log Object */               
              String successMsg =System.Label.PRM_Email_SuccessMsg;
              log.PRM_EmailDeliverabilityStatus__c = true ;
              log.PRM_Timestamp__c = DateTime.now();
              log.Email_Template_Name__c = emailTemplate.name ;
              log.PRM_Email_API_Response__c = successMsg ; 
              log.PRM_EmailContent__c =  mail.getHtmlBody() ;
              log.PRM_EmailHTMLContent__c = mail.getHtmlBody() ;
              log.PRM_Subject__c = mail.getSubject();
              if(!emailLogList.contains(log)){
                  emailLogList.add(log); 
              }               
        }
     }
        //add it in the begininng
         if(!(Test.isRunningTest())){
        integer dailyEmailLimit;
            //dailyEmailLimit = PRM_IPA_Utility.getRemainingLimitsAPI('SingleEmail');
        system.debug('dailyEmailLimit'+dailyEmailLimit);
        if(allEmails.size()>dailyEmailLimit){
          for(PRM_Reminder_Email__c reminderRec: reminderRecords)
        // batchEmailMap.put(reminderRec.PRM_BatchID__c,reminderRec.PRM_Email_Template__c);
         reminderRec.PRM_Status__c='Partially Processed';
       
        }
        }
           List<Messaging.SendEmailResult> resultList =  Messaging.sendEmail(allEmails,false);              
           System.debug('sent'+resultList);
           //loop through resultList to create log entry for failure
           
           Map<String,PRM_EmailLog__c> targetIdLog = new Map<String,PRM_EmailLog__c>();                
           for(PRM_EmailLog__c logRec : emailLogList)
               {
                 if(logRec.PRM_User__c !=  null) {targetIdLog.put(logRec.PRM_User__c,logRec);} 
                 else  if(logRec.PRM_Contact__c != null) {targetIdLog.put(logRec.PRM_Contact__c,logRec); }                                  
              }
           for(Messaging.SendEmailResult result : resultList)
           {
               System.debug('Messaging.SendEmailError: '+result.getErrors());
               if(! result.isSuccess())
               {
                   for( Messaging.SendEmailError error : result.getErrors()) {
                       //in case of targetObjectId received 

                       String targetId= error.getTargetObjectId();String errorMsg= error.getMessage();
                       failedContacts.add(targetId);
                       if(targetId !=  null && targetIdLog.get(targetId) != null)
                       {
                           PRM_EmailLog__c log = targetIdLog.get(targetId);
                           log.PRM_EmailDeliverabilityStatus__c = false;log.PRM_Email_API_Response__c = errorMsg ;
                       }
                   //failedContacts.add(targetId);             
               }      
             } 
           }
           for(string failedCon: failedContacts){ 
             Set<Id> contList;String conIdfromUser ;
             if(userConIdMap.containskey(failedCon)){
             conIdfromUser = userConIdMap.get(failedCon);
             }else{
              conIdfromUser = failedCon;
             }
             PRM_Reminder_Email__c relatedReminder;
            relatedReminder = batchToReminderMap.get(ContactBulkRecordMap.get(conIdfromUser).PRM_BatchID__c);
            if(!failedContactMap.containsKey(relatedReminder.id)){
               contList = new Set<Id>();
               contList.add(conIdfromUser);
               failedContactMap.put(relatedReminder.id,contList); 
             }else{               
               failedContactMap.get(relatedReminder.id).add(conIdfromUser);
             }
           }
           for(PRM_Reminder_Email__c rem:reminderRecords){
             if(failedContactMap.containsKey(rem.id)){
               for(Id cont : failedContactMap.get(rem.id)){
               if(rem.Failed_Contacts__c != null){
                 rem.Failed_Contacts__c = rem.Failed_Contacts__c + ';'+contactMap.get(cont);
               }else{
                 rem.Failed_Contacts__c = contactMap.get(cont);
               }
             }
            }
           }
           if(reminderRecords!= null && reminderRecords.size()>0){
           database.update(reminderRecords,false);
           }
           if(emailLogList!= null && emailLogList.size()>0){            
           database.insert(emailLogList,false); 
           }
           if(Test.isRunningTest()) {
          throw new EmailException('Email Exception occurred for testing'); 
          }
          }
          catch(Exception e){
           //update the reminder 
           system.debug('Exception occured' +e.getMessage());
           for(PRM_Reminder_Email__c reminderRec: reminderRecords){
                reminderRec.PRM_Status__c='Failed';
           } 
           if(reminderRecords!= null && reminderRecords.size()>0){
            database.update(reminderRecords,false);
            }               
           Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);           
       }
       
  
}
   
  public void finish(Database.BatchableContext bc) { 
  }

  public static String getCountryCodeForUrl(Contact cont, PRM_Language_Culture_Mapping__mdt lngCultureMdts){
    String countryCode = '';
    String culture = '';
    if(lngCultureMdts!=null){
       return String.isEmpty(lngCultureMdts.PRM_Country_Cd__c) ? System.Label.PRM_Default_CultureCountry : lngCultureMdts.PRM_Country_Cd__c.toLowerCase()+'/'+ lngCultureMdts.PRM_Culture__c.toLowerCase() ;
        }
        return '';
      }
}