global class PRM_BulkDataUpload_Batch implements Database.Batchable<PRM_Bulk_Data_Upload__c>,Database.Stateful, Database.AllowsCallouts{
    
    global static final String LOG_ENTRY_ORIGIN   = 'PRM_BulkDataUpload_Batch';
    global static final String LOG_ENTRY_PROJECT  = 'Bulk Data Upload';
    global static final String LOG_ENTRY_SCOPE    = 'PRM_BulkDataUpload_Batch';
    global static final String LOG_ENTRY_SEVERITY = 'error';
    global Map<String,PRM_Bulk_Data_Upload__c> mapContactEmailToBDU =new Map<String,PRM_Bulk_Data_Upload__c>();
    global String queryBulkUploadObjects, statusObject;
    global Map<String, String> updateContacts = new Map<String, String>();
    global Map<String, String> insertContacts = new Map<String, String>();
    global Map<String, String> emailToEvToken = new Map<String, String>();
    global static List<Core_Log_Entry__c> listCoreLogEntry = new List<Core_Log_Entry__c>();
    global static List<PRM_Account_Contact_Relationship__c> listAcrUpdateMulefailure = new List<PRM_Account_Contact_Relationship__c>(); 
    global static List<PRM_Account_Contact_Relationship__c> listAcrUpdateAGSfailure = new List<PRM_Account_Contact_Relationship__c>(); 
    global static List<PRM_Integration_Log__c> listIntegrationLogs = new List<PRM_Integration_Log__c>();
    global static List<PRM_EmailLog__c> emailLogsForContact = new List<PRM_EmailLog__c>();
    global List<String> listUniqueBatchId = new List<String>();
    global List<PRM_Bulk_Data_Upload__c> listBulkDataUpload = new List<PRM_Bulk_Data_Upload__c>();
    global static List<Messaging.SingleEmailMessage> mapEmailMessaging = new List<Messaging.SingleEmailMessage>();

    public static String sanitizedSearchKey = String.escapeSingleQuotes(UserInfo.getUserId());
    public static User user = [select Id,IsPortalEnabled, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c,Email from User where Id = :sanitizedSearchKey];//where Id =: currentUserId  
    public static string userEmail=string.valueOf(user.email);
    public static boolean isExtPartnerInvite=false;
    public static boolean IsPortalUser=user.IsPortalEnabled;
    public static String uniqueBatchId;
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
    global static OrgWideEmailAddress[] owea = [
            SELECT 
            Id 
            FROM OrgWideEmailAddress
            WHERE Address =: Label.PRM_wsm_postmaster_intel_com];
    global Iterable<PRM_Bulk_Data_Upload__c> start(Database.BatchableContext bc) {
        String status = 'New';
        Integer batchLimit = Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c) + 1 ;
        String query = 'SELECT'
            + ' Id,PRM_AccountId__c,PRM_AccountId__r.BillingCountryCode,PRM_CampaignId__c,PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c,PRM_AccountId__r.Core_Geo__c,'
            + 'PRM_Email_Template__c,PRM_ContactEmail__c,OwnerId,PRM_Comments__c,PRM_BatchID__c,PRM_Contact_Id__c,'
            + 'PRM_First_Name__c,PRM_Last_Name__c,PRM_Object__c,PRM_OperationType__c,PRM_Partner_Program__c,'
            + 'PRM_Partner_Relationship__c,PRM_IPA_Partner_Role__c,PRM_Preferred_Language__c,PRM_Contact_Phone__c,'
            + 'PRM_Status_Reason__c,PRM_Suppress_Email__c,PRM_Status__c,CreatedById, PRM_Upload_Type__c,PRM_Mailing_Country__c'
            + ' FROM PRM_Bulk_Data_Upload__c'
            + ' Where PRM_Status__c=:status'
            + ' and createdBy.Email=:userEmail'
            + ' and PRM_Upload_Type__c!=\'Auto Granted IPA for DZP\''
            + ' ORDER BY PRM_BatchID__c,createdDate '
            + ' LIMIT :batchLimit';
        
        listBulkDataUpload = Database.query(query);
        List<PRM_Bulk_Data_Upload__c> itemsToProcess = new List<PRM_Bulk_Data_Upload__c>();
        if(listBulkDataUpload.size() > Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c)){
            for(Integer i =0; i<listBulkDataUpload.size() - 1; i++){
                itemsToProcess.add(listBulkDataUpload[i]);
            }
        }else{
            itemsToProcess = listBulkDataUpload;
        }
        
        return itemsToProcess;
        
    }
    
    global void execute(Database.BatchableContext context, List<PRM_Bulk_Data_Upload__c> listBulkDataUpload){        
            //Map<String,id>  emailToTemplateID =new Map<String,id>();
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

            for(PRM_Bulk_Data_Upload__c bulkDataUpload:listBulkDataUpload){
                if((!listUniqueBatchId.contains(bulkDataUpload.PRM_BatchID__c))){
                    listUniqueBatchId.add(bulkDataUpload.PRM_BatchID__c);
                }
                if(bulkDataUpload.PRM_Object__c=='Contact'){
                    mapContactEmailToBDU.put(bulkDataUpload.PRM_ContactEmail__c,bulkDataUpload);               
                }
                String emailType = bulkDataUpload.PRM_CampaignId__c != null && bulkDataUpload.PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c != null 
                                    ? bulkDataUpload.PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c
                                    : bulkDataUpload.PRM_Email_Template__c != null
                                        ? bulkDataUpload.PRM_Email_Template__c
                                        : null;
                
                if(bulkDataUpload.PRM_OperationType__c == 'Insert'){
                    insertContacts.put(bulkDataUpload.PRM_ContactEmail__c, emailType != null 
                        ? emailType+'_'+bulkDataUpload.PRM_Preferred_Language__c: languageToDefaultTemplateMap.containsKey(bulkDataUpload.PRM_Preferred_Language__c)? languageToDefaultTemplateMap.get(bulkDataUpload.PRM_Preferred_Language__c): languageToDefaultTemplateMap.get('ENG'));
                } 
                else{
                    updateContacts.put(bulkDataUpload.PRM_ContactEmail__c, emailType != null 
                        ? emailType+'_'+bulkDataUpload.PRM_Preferred_Language__c : languageToDefaultTemplateMap.containsKey(bulkDataUpload.PRM_Preferred_Language__c)? languageToDefaultTemplateMap.get(bulkDataUpload.PRM_Preferred_Language__c): languageToDefaultTemplateMap.get('ENG'));
                }                             
            }
            if(mapContactEmailToBDU.size()>0){
                PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(mapContactEmailToBDU);
            }  
    }
    
    global void finish(Database.BatchableContext BC){
        List<PRM_Account_Contact_Relationship__c> agsIdentityContactACRs = new List<PRM_Account_Contact_Relationship__c>();
        //List<PRM_Account_Contact_Relationship__c> allContactACRs = new List<PRM_Account_Contact_Relationship__c>();
        Map<String, String> updateContactsWithNoEv = new Map<String, String>();
        set<String> conrecordidss=new set<string>();
        List<Contact> contactsForERPMSync = new List<Contact> ();
        try{
           
                contactsForERPMSync = [
                    SELECT 
                    Id,
                    Email,
                    Core_ERPM_Integration_Status__c,
                Core_eRPM_Person_Id__c,
                    Core_Enterprise_Id__c,
                    Core_ERPM_Integration_Queue_txt__c,
                    Core_IPS_Employee_Customer__c 
                    FROM Contact
                    WHERE email in: mapContactEmailToBDU.keySet()];
        Map<String, Contact> allContactMap = new Map<String, Contact>();
        for(Contact con : contactsForERPMSync){
            allContactMap.put(con.Email, con);
                            conrecordidss.add(con.Id);

        }
        for(String email  : updateContacts.keySet()){
            if(String.isBlank(allContactMap.get(email).Core_Enterprise_Id__c) || allContactMap.get(email).Core_Enterprise_Id__c == null){
                insertContacts.put(email,updateContacts.get(email));
                updateContacts.remove(email);
            }
                else if(String.isNotBlank(allContactMap.get(email).Core_Enterprise_Id__c)){// As per CiDaaS Change
                updateContactsWithNoEv.put(email,updateContacts.get(email));
                updateContacts.remove(email);
            }
        }
        
        
        
        if(!insertContacts.isEmpty()){
            agsIdentityContactACRs = [
                SELECT 
                Id,
                PRM_Status_Nm__c,
                PRM_Contact_Id__c,
                PRM_InActive_Ind__c,
                PRM_AGS_Identity_Creation_Fail__c,
                PRM_No_Email__c,
                PRM_Relationship_Id__r.Name,
                PRM_Contact_Id__r.Email
                FROM PRM_Account_Contact_Relationship__c
                WHERE PRM_Contact_Id__r.Email in: insertContacts.keySet()];
        }
        
        
        PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger = true;
        if(!agsIdentityContactACRs.isEmpty()){
            PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS(agsIdentityContactACRs);
        }

        if(!updateContactsWithNoEv.isEmpty()){
            sendEmailNotificationtoEndUserUpdate(updateContactsWithNoEv); 
        }

        if(!updateContacts.isEmpty()){
            sendEmailNotificationtoEndUserUpdate(updateContacts); 
        }
        if(!contactsForERPMSync.isEmpty()){
            Core_Entitlement_Outbound_Integrations.publishERPMMessage(contactsForERPMSync, null);
        }
            list<PRM_Bulk_Data_Upload__c> bulkListFailure=new list<PRM_Bulk_Data_Upload__c>();
            list<string> conEmails=new list<string>();
            List<PRM_Bulk_Data_Upload__c> bulkFailLstUpdate= new list<PRM_Bulk_Data_Upload__c>();
        if(!listAcrUpdateMulefailure.isEmpty()){
            upsert listAcrUpdateMulefailure;
                for(PRM_Account_Contact_Relationship__c acr:listAcrUpdateMulefailure){
                    conEmails.add(acr.PRM_Contact_Id__r.Email); 
                   
                }
                // bulkListFailure =[select id, PRM_Status__c,PRM_First_Name__c, PRM_Last_Name__c,  PRM_ContactEmail__c,PRM_Comments__c 
                // from PRM_Bulk_Data_Upload__c where PRM_ContactEmail__c in: conEmails  and PRM_Status__c ='Completed' ];
            }
            if(!listAcrUpdateAGSfailure.isEmpty()){
                for(PRM_Account_Contact_Relationship__c acr1:listAcrUpdateAGSfailure){
                    if(acr1.PRM_AGS_Response_Status__c==System.Label.PRM_retry){
                        conEmails.add(acr1.PRM_Contact_Id__r.Email);
                    }}}
        if(!conEmails.isEmpty()){
            for(PRM_Bulk_Data_Upload__c bulkFailRec:[select id, PRM_Status__c,PRM_First_Name__c, PRM_Last_Name__c,  PRM_ContactEmail__c,PRM_Comments__c,PRM_Mailing_Country__c 
                                                    from PRM_Bulk_Data_Upload__c where PRM_ContactEmail__c in: conEmails  and 
                                                    PRM_Status__c =:System.Label.PRM_AsyncStatus ]){
                if(bulkFailRec.PRM_Status__c==System.Label.PRM_AsyncStatus){
                    bulkFailRec.PRM_Status__c=System.Label.PRM_Discarded;
                    bulkFailRec.PRM_Comments__c=System.Label.PRM_Integration_Fail_Bulk;
                    bulkFailLstUpdate.add(bulkFailRec);
                }}}
       
            if(!bulkFailLstUpdate.isEmpty()){
                update bulkFailLstUpdate;
            }
        if(!listIntegrationLogs.isEmpty()){
            insert listIntegrationLogs;
        }
        if(!mapEmailMessaging.isEmpty()){
            Messaging.sendEmail(mapEmailMessaging );
        }
        if(!emailLogsForContact.isEmpty()){
            insert emailLogsForContact;
        }
            if(!listCoreLogEntry.isEmpty()){
                insert listCoreLogEntry;
            }
        if(listUniqueBatchId.size()>=1){
            List<PRM_Bulk_Data_Upload__c> listBulkRecs = new List<PRM_Bulk_Data_Upload__c>();
            List<String> batchIdsForEmail = new List<String>();
            //list-1 index
                 if(listBulkDataUpload.size() > Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c) ){
                List<String> batchIds = new List<String>();
                for(Integer i = 0; i<listUniqueBatchId.size()-1 ; i++){
                    batchIds.add(listUniqueBatchId[i]);
                }
                batchIdsForEmail = batchIds;
                listBulkRecs = [
                    SELECT 
                    Id,
                    PRM_Status__c,
                        PRM_ContactEmail__c,
                        CreatedBy.Email, 
                        PRM_First_Name__c,
                        PRM_Last_Name__c,
                        PRM_BatchID__c,
                        PRM_Comments__c,
                        PRM_CampaignId__c,
						PRM_Mailing_Country__c
                        FROM PRM_Bulk_Data_Upload__c
                        WHERE PRM_BatchID__c IN: batchIds];
                }else if(listBulkDataUpload.size() <= Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c) ){
                    //for complete list
                    listBulkRecs = [
                        SELECT 
                        Id,
                        PRM_Status__c,
                        PRM_ContactEmail__c,
                        CreatedBy.Email, 
                        PRM_First_Name__c,
                        PRM_Last_Name__c,
                        PRM_BatchID__c,
                        PRM_CampaignId__c,
                        PRM_Comments__c,
						PRM_Mailing_Country__c
                        FROM PRM_Bulk_Data_Upload__c
                        WHERE PRM_BatchID__c IN: listUniqueBatchId];
                    batchIdsForEmail = listUniqueBatchId;
                }
                list<string> mailDataList=new list<string>();
            Integer successRecs = 0;
            Integer failRecs = 0;
                string bulkRecStringSuccess,bulkRecStringForExcelSuccess='',statuss; 
                string emailBody,bulkRecStringFail,bulkRecStringForExcelFail='';
                list<string> statusList=new list<string>();
                Set<String> batchIds = new Set<String>();
                string mailingCountrystr;
            for( PRM_Bulk_Data_Upload__c bulkrec : listBulkRecs){
                   
                    if(bulkrec.PRM_Status__c == System.Label.PRM_AsyncStatus){
                        successRecs += 1; 
                        statuss=System.Label.PRM_Success_status;
                        //mailingCountrystr=(bulkrec.PRM_Mailing_Country__c!=null || bulkrec.PRM_Mailing_Country__c==' ') ?bulkrec.PRM_Mailing_Country__c:' ';
                        mailingCountrystr = (bulkrec.PRM_Mailing_Country__c != null && bulkrec.PRM_Mailing_Country__c.trim() != '') ? bulkrec.PRM_Mailing_Country__c : ' ';

                        //bulkRecStringSuccess=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+mailingCountrystr+','+statuss+'\n';
                        bulkRecStringSuccess=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+mailingCountrystr+'"'+','+'"'+statuss+'"'+'\n';

                        bulkRecStringForExcelSuccess = bulkRecStringForExcelSuccess +bulkRecStringSuccess;
                        //statusList.add()
                    }
                    else if(bulkrec.PRM_Status__c == System.Label.PRM_FailedLabel){
                        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                        Pattern MyPattern = Pattern.compile(emailRegex);
                        Matcher MyMatcher = MyPattern.matcher(bulkrec.PRM_ContactEmail__c);
                        failRecs += 1;
                        if(!MyMatcher.matches())
                        {
                            
                            statuss=System.Label.PRM_Email_Failure;
                            bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }else if(bulkrec.PRM_Comments__c==System.Label.PRM_Integration_Fail_Bulk){
                            
                            statuss=System.Label.PRM_Integration_Failure;
                            bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                        
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }else if(bulkrec.PRM_Comments__c=='Invalid_Domain'){
                            statuss=System.Label.PRM_BlockedDomainMsg_Bulk;
                            bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }
                        else if(bulkrec.PRM_Comments__c=='Invalid_Country'){
                            statuss='Country not valid. Please refer to the list of countries downloaded for proper format.';
                            bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }
                        else if(bulkrec.PRM_Comments__c=='Blank_Country'){
                            statuss='Country should not be blank. Please refer to the list of countries downloaded for proper format.';
                            bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+' '+','+statuss+'\n';
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }
                        
                        else{
                            statuss=System.Label.PRM_Integration_Failure;
                           bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                            bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                        }
                    }else if(bulkrec.PRM_Status__c == System.Label.PRM_Discarded){
                        failRecs += 1;
                        statuss='records not processed. Please try again';
                       bulkRecStringFail=bulkrec.PRM_ContactEmail__c+','+bulkrec.PRM_Last_Name__c+','+bulkrec.PRM_First_Name__c+','+'"'+bulkrec.PRM_Mailing_Country__c+'"'+','+'"'+statuss+'"'+'\n';
                        bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail;
                    }   
                    mailDataList.add(bulkrec.PRM_ContactEmail__c);
                }
                if(successRecs>0 && failRecs>0){
                    emailBody= System.Label.PRM_Failure_Email_Bulk;
                    //bulkRecStringForExcelSuccess='';
                   
                }else if (failRecs>0 &&successRecs==0){
                     emailBody= System.Label.PRM_Failure_Email_Bulk;
                    bulkRecStringForExcelSuccess='';
                }else if(failRecs==0 && successRecs>0){
                    bulkRecStringForExcelFail='';
                    emailBody= System.Label.PRM_Success_Email_Bulk;
                }
                // if(!mailDataList.isEmpty()){
                //    for(PRM_Account_Contact_Relationship__c acrExt:[select Id, PRM_Contact_Id__r.email,PRM_Source_Agent__c, PRM_Contact_Id__c 
                //    from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__r.email in:mailDataList]) {
                //     if(acrExt.PRM_Source_Agent__c==system.label.PRM_ExtPartnerInvite){
                //         isExtPartnerInvite=true;
                //     }
                //    }
                // }
                if(string.isNotBlank(bulkRecStringForExcelFail) && string.isNotBlank(bulkRecStringForExcelSuccess) && IsPortalUser)
                {
                    PRM_SendEmailToUsers.sendData('PRM_Bulk_Invite_template','',bulkRecStringForExcelFail+bulkRecStringForExcelSuccess,emailBody,system.label.PRM_Bulk_Email_Subject);
                }
                else if(string.isNotBlank(bulkRecStringForExcelSuccess) && IsPortalUser){
                    PRM_SendEmailToUsers.sendData('PRM_Bulk_Invite_template',bulkRecStringForExcelSuccess,'',emailBody,system.label.PRM_Bulk_Email_Subject);
                }else if(string.isNotBlank(bulkRecStringForExcelFail) && IsPortalUser){
                    PRM_SendEmailToUsers.sendData('PRM_Bulk_Invite_template','',bulkRecStringForExcelFail,emailBody,system.label.PRM_Bulk_Email_Subject);
                }
               
                if(listUniqueBatchId.size() == 1 && !(listBulkDataUpload.size() > Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c) ) || listUniqueBatchId.size()>1 ){
                    String body = emailBodyMessage(successRecs, failRecs, batchIdsForEmail);//Defining Email Body 
                    if(String.isNotBlank(body) && !IsPortalUser){
                        sendMail('BATCH_JOB_NOTIFICATION', body ,'Bulk Data Upload completed Successfully'); //Calling Send Email Method to send batch completion email 
                    } 
                } 
            }
            if(listBulkDataUpload.size() > Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c)){
                PRM_BulkDataUpload_Batch bulkBatch = new PRM_BulkDataUpload_Batch();
            Integer schedulingTime = (Integer)listBatchConfigItems[0].PRM_SchedulingTimeMins__c;
                Integer batchLimit = Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c);
            uniqueBatchId = string.valueOf(system.now()+Integer.valueof((Math.random() * 10)));
            uniqueBatchId=uniqueBatchId.remove('-').remove(':').remove(' ');
            try{
                    System.scheduleBatch(bulkBatch, 'Bulk Data Upload'+uniqueBatchId, schedulingTime, batchLimit); //batchLimit
            }
            
            catch(Exception e){
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);  
         }      
    }
}
        catch(Exception e){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);  }
        finally{
         if(conrecordidss.size()>0)
                system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,conrecordidss,false,false));   
        
        } 
    }
    
    global static PRM_Integration_Log__c createIntegrationLog(String recordId ,String callType, String module, String reqPayload, String respPayload, Integer respCode ,String systemName, String className)
    {
        PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
        intLog.PRM_Record_ID__c = recordId;
        intLog.PRM_Callout_Type__c = callType;
        intLog.PRM_Module__c = module;
        intLog.PRM_Request_Payload__c = reqPayload;
        intLog.PRM_Response_Payload__c = respPayload;
        intLog.PRM_Response_Code__c = respCode;
        intLog.PRM_System_Name__c = systemName;
        intLog.PRM_Class__c = className;
        
        return intLog;
    }
    
    
    global void sendEmailNotificationtoEndUserUpdate(Map<String, String> EmailIdandemailType){
        //String standadrdEmailTemp = listBatchConfigItems[0].PRM_StandardEmailBulk__c+'_English';
        List<String> allDevNamesEmailTemps = new List<String>();
        for(String emailTemp : EmailIdandemailType.values()){
            String tempName = emailTemp.substringBefore('_') + '_ENG';
            allDevNamesEmailTemps.add(tempName);
        }
        allDevNamesEmailTemps.addAll(EmailIdandemailType.values());
        //allDevNamesEmailTemps.add(standadrdEmailTemp);
        Set<EmailTemplate> setAllEmailTemplates = new Set<EmailTemplate>([
            SELECT 
            id, 
            DeveloperName, 
            HtmlValue, 
            Subject
            FROM EmailTemplate
            WHERE  DeveloperName in: allDevNamesEmailTemps]);       
        Map<String, EmailTemplate> mapAllEmailTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate emtemp :setAllEmailTemplates){
            mapAllEmailTemplates.put(emtemp.DeveloperName, emtemp);
        }

        Map<String, Contact> emailToContactMapForEmail = new Map<String, Contact>();
        List<Contact> conList = new List<Contact>();
        
            conList =       [SELECT 
                            id,
                            AccountId,
                            Account.Name,
                            Account.AccountNumber,
                            Account.BillingCountryCode,
                            MailingCountryCode,
                            FirstName,
                            LastName,
                            Core_IPA_PartnerRole__c,
                            Core_Do_Not_Contact__c,
                            Core_Enterprise_Id__c,
                            Core_Preferred_Language__c,
                            Email,
                            (SELECT 
                             id, 
                             PRM_Partner_Role__c, 
                             PRM_Source_Agent__c, 
                             PRM_Relationship_Id__r.Name 
                             FROM Account_Contact_Relationships__r 
                             WHERE PRM_InActive_Ind__c=false) 
                            FROM Contact
                            WHERE Email in: EmailIdandemailType.keySet()];
                for(Contact cont : conList){
            emailToContactMapForEmail.put(cont.Email, cont);
        }  
        
        if(!EmailIdandemailType.isEmpty()){
            for(String email : EmailIdandemailType.keySet()){
                String engVersion = EmailIdandemailType.get(email).substringBefore('_') + '_ENG';
                if(emailToContactMapForEmail.containsKey(email)){
                    Contact cont = emailToContactMapForEmail.get(email);
                    List<PRM_Account_Contact_Relationship__c> conACR = cont.Account_Contact_Relationships__r;
                    if(String.isNotBlank(cont.Core_Enterprise_Id__c)){
                        if(!conACR.isEmpty() && conACR != null &&  (conACR[0].PRM_Source_Agent__c == 'Bulk Invite' ||  conACR[0].PRM_Source_Agent__c == system.label.PRM_ExtPartnerInvite) && !mapContactEmailToBDU.get(email).PRM_Suppress_Email__c){
                            
                                if(!cont.Core_Do_Not_Contact__c ){
                                    if(EmailIdandemailType.containsKey(email) && mapAllEmailTemplates.containsKey(EmailIdandemailType.get(email))){
                                        emailToContact(cont, null,mapAllEmailTemplates.get(EmailIdandemailType.get(email))); 
                                    }
                                    else if(EmailIdandemailType.containsKey(email) && mapAllEmailTemplates.containsKey(engVersion)){
                                        emailToContact(cont, null, mapAllEmailTemplates.get(engVersion));
                                    }
                                }                              
                        }     
                    }
                }
            } 
        }
    }
    
    public static List<String> emailToContact(Contact cont, String evToken, EmailTemplate emailTemplate){
        
        Boolean isUpdateInvite = true;
        Boolean supressEmailForInvite = false;
        String evlink = System.Label.PRM_EVTokenLink;
        String secondaryContURL = System.Label.PRM_EVTLinkTarget_SecondaryContact;
        String supportContURL = System.Label.PRM_Admin_Support_Link;
        //As part of CIDAAS Story - TWC729-4208
        String SecondaryCidaasURL = System.Label.PRM_CiDaaS_Secondary_Invite_Link;
        String CompleteNowURL = '';
        String culture = '';   
        //String countryCode = '';
        String countryCodeCulture = '';
        String countrycdcul = '';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (owea != null) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }else{
                owea = [
                    SELECT 
                    Id 
                    FROM OrgWideEmailAddress
                    WHERE Address =: Label.PRM_wsm_postmaster_intel_com];
                if (owea != null) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }

            //String strRandom = String.valueOf(system.now()).replace(' ','').replace('-','').replace(':', '');
            List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
            //String msg = '';
            List<String> contactPartnerRoles = String.isEmpty(cont.Core_IPA_PartnerRole__c)? new List<String>() : cont.Core_IPA_PartnerRole__c.split(';');  
            if(!String.IsEmpty(cont.Core_IPA_PartnerRole__c) && !configPartnerRoles.contains(contactPartnerRoles[0]) ){
                
                //String businessEvents = 'Secondary_Contact_Email_Template';
                Map<String,String> languageToDefaultTemplateMap = new Map<String,String>();
                List<IPA_Batch_Configurations__mdt> BatchConfigItems = [
                    SELECT 
                    id, 
                    DeveloperName, 
                    Record_Limit__c, 
                    PRM_SchedulingTimeMins__c, 
                    PRM_StandardEmailBulk__c
                    FROM IPA_Batch_Configurations__mdt
                    WHERE DeveloperName =: 'PRM_BulkBatchConfigurableItems' limit 1];

                List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [
                    SELECT 
                    Id,
                    MasterLabel,
                    PRM_Culture__c,
                    PRM_Country__c,
                    PRM_Country_Cd__c 
                    FROM PRM_Language_Culture_Mapping__mdt
                    WHERE MasterLabel = :cont.Core_Preferred_Language__c ];

                for(PRM_EmailConfigurationDetails__mdt emailConfig : [
                    SELECT
                    PRM_Language__c, 
                    PRM_BusinessEvent__c,
                    PRM_TemplateUniqueName__c
                    FROM PRM_EmailConfigurationDetails__mdt
                    WHERE PRM_TemplateUniqueName__c like :BatchConfigItems[0].PRM_StandardEmailBulk__c+'%']
                ){
                    if(!String.isEmpty(emailConfig.PRM_Language__c)){
                        languageToDefaultTemplateMap.put(emailConfig.PRM_Language__c, emailConfig.PRM_TemplateUniqueName__c );
                    }
                }               
                
                //Map<String, String> inputParameters = new Map<String, String>();      
                culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';
                countryCodeCulture = getCountryCodeForUrl(cont, lngCultureMdt);
                List<String> countryCodeCultureArr = countryCodeCulture.split('/');
                countrycdcul = countryCodeCultureArr[1]+'-'+countryCodeCultureArr[0];
                secondaryContURL = secondaryContURL.replace('{{COUNTRYCODE}}', countryCodeCulture);
                supportContURL = supportContURL.replace('{{CULTURECODE}}',countrycdcul);
                
                 CompleteNowURL = secondaryContURL;
                
                List<String> emailAddress = new List<String>();
                emailAddress.add(cont.Email);
                mail.setToAddresses(emailAddress);
                String emailBody = '';
                if(emailTemplate != null){
                    emailBody = emailTemplate.HtmlValue;
                }
                else{
                    List<String> alleEmailTempDevNames = new List<String>();
                    isUpdateInvite = false;
                    List<PRM_Bulk_Data_Upload__c> bulkObject = [
                        SELECT 
                        id, 
                        name, 
                        PRM_CampaignId__c,
                        PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c,
                        PRM_Email_Template__c,
                        PRM_Suppress_Email__c,
                        CreatedDate, 
                        PRM_ContactEmail__c, 
                        PRM_Preferred_Language__c,
						PRM_Mailing_Country__c
                        FROM PRM_Bulk_Data_Upload__c
                        WHERE PRM_ContactEmail__c =: cont.email
                        ORDER BY CreatedDate desc limit 1];
                    
                    String standadrdEmailTemp = BatchConfigItems[0].PRM_StandardEmailBulk__c+'_English';
                    alleEmailTempDevNames.add(standadrdEmailTemp);
                    supressEmailForInvite = bulkObject[0].PRM_Suppress_Email__c;
                    
                    String templateId = bulkObject[0].PRM_CampaignId__c != null && bulkObject[0].PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c != null 
                                            ? bulkObject[0].PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c
                                            : bulkObject[0].PRM_Email_Template__c != null
                                                ? bulkObject[0].PRM_Email_Template__c
                                                : null;

                    
                    String templateEngVersion = templateId != null ? templateId +'_ENG': languageToDefaultTemplateMap.get('ENG');
                    
                    templateId = templateId != null 
                        ? templateId+'_'+bulkObject[0].PRM_Preferred_Language__c 
                        : languageToDefaultTemplateMap.containsKey(cont.Core_Preferred_Language__c)
                            ?languageToDefaultTemplateMap.get(cont.Core_Preferred_Language__c)
                            :languageToDefaultTemplateMap.get('ENG') ;
                    
                            alleEmailTempDevNames.add(templateId);
                    alleEmailTempDevNames.add(templateEngVersion);
                    List<EmailTemplate> listEmailTemplate = [
                        SELECT 
                        id, 
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
                    if(mapDevNameToEmailTemp.containsKey(templateId)){
                        emailTemplate = mapDevNameToEmailTemp.get(templateId);
                        emailBody = mapDevNameToEmailTemp.get(templateId).HtmlValue; 
                    }
                    else if(mapDevNameToEmailTemp.containsKey(templateEngVersion)){
                        emailTemplate = mapDevNameToEmailTemp.get(templateEngVersion);
                        emailBody = mapDevNameToEmailTemp.get(templateEngVersion).HtmlValue;
                    }else{
                        emailTemplate = mapDevNameToEmailTemp.get(standadrdEmailTemp);
                        emailBody = mapDevNameToEmailTemp.get(standadrdEmailTemp).HtmlValue;
                    }           
                }

                map<String,Language_Translation__mdt> dynamicTranslations =  new map<String,Language_Translation__mdt>();
                             
                    for(Language_Translation__mdt langTrans : [select DeveloperName, DEU__c, ENG__c, ENU__c, FRA__c, IND__c, ITA__c,JPN__c, KOR__c, POL__c, POR__c, RUS__c, SPA__c, ESP__c,  THA__c, TUR__c, VIE__c, ZHO__c, ZHT__c from Language_Translation__mdt]){
                        dynamicTranslations.put(langTrans.DeveloperName,langTrans);    
                    }
                    
                String Buttontext;
                String Warning_Placeholder = '';
                
                Buttontext = (String) dynamicTranslations.get('Complete_Now_Button_Name').get(cont.Core_Preferred_Language__c + '__c');
                        Warning_Placeholder = '';  
                                      
                if(String.isNotBlank(CompleteNowURL)){emailBody = emailBody.replace('{{EVLINK}}', CompleteNowURL);}
                if(String.isNotBlank(supportContURL)){emailBody = emailBody.replace('{{SUPPORTLINK}}', supportContURL);}
                if(String.isNotBlank(cont.Email)){emailBody = emailBody.replace('{!Contact.Email}', cont.Email);}
                if(String.isNotBlank(cont.FirstName)){emailBody = emailBody.replace('{!Contact.FirstName}', cont.FirstName);}
                if(String.isNotBlank(cont.LastName)){emailBody = emailBody.replace('{!Contact.LastName}', cont.LastName);}                
                if(String.isNotBlank(cont.Account.Name)){emailBody = emailBody.replace('{{ACCOUNTNAME}}', cont.Account.Name);}
                if(String.isNotBlank(cont.Account.AccountNumber)){emailBody = emailBody.replace('{{ACCOUNTNUMBER}}',cont.Account.AccountNumber);}
                if(String.isNotBlank(Buttontext)){emailBody = emailBody.replace('{{ButtonText}}',Buttontext);}
                if(emailBody.contains('{{24Hour Warning}}')){emailBody = emailBody.replace('{{24Hour Warning}}',Warning_Placeholder);}

                emailBody = emailBody.replace('{!$Label.Core_MDF_PFRDetailLink}',Label.Core_MDF_PFRDetailLink);
      emailBody = emailBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
                mail.setSubject(emailTemplate.Subject);
                mail.setHtmlBody(emailBody); 
                
                if(!supressEmailForInvite){
                    List<PRM_EmailLog__c> listEmailLogs = PRM_EmailUtility.createEmailLogs(mail, null,new List<PRM_EmailLog__c>(), new Map<String,String>{cont.id => cont.email},null,null,null ,emailTemplate.DeveloperName);
                    listEmailLogs[0].PRM_Contact__c =cont.id;
                    if(isUpdateInvite){
                        mapEmailMessaging.add(mail);
                        PRM_BulkDataUpload_Batch.emailLogsForContact.addAll(listEmailLogs);
                    }
                    else{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        insert listEmailLogs;
                    }
                    PRM_BulkDataUpload_Batch.createLogEntry( 'Info', 'Info', cont ,null, 'Email sent BulkBatch', 'Contact', isUpdateInvite); 
                }
                return new List<String>{'True', 'Contact updated successfully'};
            }else {
                return new List<String>{'False', 'Contact has no partner roles'};
            }
        } catch(Exception ex){
            PRM_BulkDataUpload_Batch.createLogEntry( ex.getMessage(), 'Info', cont ,null,'Medium', 'Contact', isUpdateInvite);
            return new List<String>{'False', ex.getMessage()};
        }
        
    }
    
    private static void createLogEntry(String message, String detail, sObject cont, String tags, String severity, String objectType, Boolean isUpdateInvite){
        
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
        
        if(isUpdateInvite){
            PRM_BulkDataUpload_Batch.listCoreLogEntry.add(objCLE);
        }
        else{
            insert objCLE;
        }
    }
    public static String getCountryCodeForUrl(Contact cont, List<PRM_Language_Culture_Mapping__mdt> lngCultureMdts){
        String countryCode = '';
        String culture = '';
        if(lngCultureMdts.size() > 0){
            if(lngCultureMdts.size() == 1){
                return String.isEmpty(lngCultureMdts[0].PRM_Country_Cd__c) ? System.Label.PRM_Default_CultureCountry : lngCultureMdts[0].PRM_Country_Cd__c.toLowerCase()+'/'+ lngCultureMdts[0].PRM_Culture__c.toLowerCase() ;
            }else{
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
            
        }else {
            return System.Label.PRM_Default_CultureCountry;
        }     
    } 
    
    //Email Body Message for Email to IPA Admins
    global String emailBodyMessage(Integer successItems, Integer failureItems, List<String> listBatchId){
        List<Report> bulkReport = [
            SELECT 
            id, DeveloperName 
            FROM Report
            WHERE DeveloperName =: System.Label.PRM_Bulk_Report LIMIT 1];
        String bulkreportid = '';
        if(bulkReport.size() > 0){
            bulkreportid = String.valueOf(bulkReport[0].id);
        }
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String url = '/lightning/r/Report/' + bulkreportid + '/view'; 
        String reportLink = baseURL+url;
        String body1 = '<br>The Bulk Invite request is complete with '+ successItems +' success and '+ failureItems +' failures. \n\n<br><br>';
        String body3 = 'Click '+ '<a href = "'+ reportLink +'"> here </a>' +'to view the bulk upload report.<br>';
        String body4 ='';
        if(listBatchId.size() == 1){
            body4 = 'Batch Id for this transaction is: '+listBatchId[0];
        }
        else if(listBatchId.size() >1){
            String tempBody='';
            for(Integer i =0 ; i< listBatchId.size(); i++){
                if(!(i == listBatchId.size() - 1)){
                    tempBody = tempBody+', '+listBatchId[i];
                }
                else{
                    tempBody = tempBody+' and '+listBatchId[i];
                }
            }
            body4 = 'Batch Id for this transaction is:'+tempBody;
        }
        String body =  body1+body3+body4;
        return body;
    }
    
    //Get Email Addresses - IPA Admins    
    public List<String> getMailAddresses(){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        
        Group gp = [
            SELECT 
            (SELECT 
             UserOrGroupId 
             FROM GroupMembers) 
            FROM Group where developername ='PRM_Batch_Jobs_Email_Notification'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [
            SELECT Email 
            FROM User 
            WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        return mailToAddresses;
    }
    
    
    //Send Email - IPA Admins 
    public void sendMail(String templateName, String jobStatusMessage, String jobSubject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if (owea != null) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            owea = [
                SELECT 
                Id 
                FROM OrgWideEmailAddress
                WHERE Address =: Label.PRM_wsm_postmaster_intel_com];
            if (owea != null) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        }
        mail.setToAddresses(getMailAddresses());     
        String emailBody = [
            SELECT 
            HtmlValue 
            FROM EmailTemplate
            WHERE DeveloperName =:templateName limit 1].HtmlValue;
        emailBody = emailBody.replace('{!job_subject}',jobSubject);//'Batch Execution started'
        emailBody= emailBody.replace('{!JOB_MESSAGE}',jobStatusMessage);// 'Batch Execution is progress for Bulk Data Upload Batch'
        mail.setSubject('Bulk Data Upload completed Successfully');
        mail.setHtmlBody(emailBody);               
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}