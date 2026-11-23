/****************************************************************************************************************************************
Class Name  : PRM_EmailUtility
Version     : 1.0
Created Date: 27 FEB 2019
Function    : Utility class to send emails as per business events defined.

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Harshit Kabra            27/02/2019              Original version
*****************************************************************************************************************************************/
public without sharing class PRM_EmailUtility {
    public static  boolean firstRun = true;
    
    //Static Variable to store Log Details
    public static String logLanguage;
    public static String templateName;  
    public static Map<String,String> customPlaceholdersMap;
    public static final String LOG_ENTRY_ORIGIN = 'Email utility';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'PRM_EmailUtility';
    public static final String LOG_ENTRY_SEVERITY = 'Medium'; 
    public static map<string,PRM_EmailInputParamClause__mdt> inputParamQueryMap = new map<string,PRM_EmailInputParamClause__mdt>();
    public static  List<PRM_EmailConfigurationDetails__mdt> emailConfigList=new list <PRM_EmailConfigurationDetails__mdt>();
    public static string queryForTemplateDetails;
    public static list<string> lstEmailNotBusinessEvent=new list<string>();
    public static List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
    /**
* @description         : method to sendEmails as part of EmailFramework US
* @name                : sendEmail
* @param               : PRM_EmailUtility.EmailNotification 
* @throws exception    : NONE
**/   
    //Assumption : only one record will be passed at a time while invoking this method for sending emails
    //             hence, code and the design used for framework will not work for multiple records at once.  
    public static set<String> sendEmail(List<EmailNotification> objEmailNotifList){
        set<String> regRequestIdSet = new set<String>();
        // System.debug('>>>>>objEmailNotifList inside calling'+objEmailNotifList);
        if(!objEmailNotifList.isEmpty()){
            /*if(System.isBatch() || System.isFuture() || System.isQueueable()){
                System.debug('aaaaa');
                sendEmailUtil(objEmailNotifList);
            }else {
                System.debug('bbbbb');
                System.enqueueJob(new sendEmailQueuable(objEmailNotifList));
            }*/
            regRequestIdSet = sendEmailUtil(objEmailNotifList);
        }
        return regRequestIdSet;
    }  

    // public without sharing class sendEmailQueuable implements Queueable { 
    //     List<EmailNotification> objEmailNotifList = new List<EmailNotification>();
    //     public sendEmailQueuable(List<EmailNotification> objEmailNotifList) {        
    //         this.objEmailNotifList = objEmailNotifList;    
    //     }
        
    //     public void execute(QueueableContext context) { 
    //         sendEmailUtil(objEmailNotifList);
    //     }
    // }

    public static set<String> sendEmailUtil(List<EmailNotification> objEmailNotifList){
        List<Messaging.SingleEmailMessage> allmails = new List<Messaging.SingleEmailMessage>();
        list<String> regReqLst=new list<String>();
        List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
            for (PRM_EmailInputParamClause__mdt param : [select id,Query_Clause__c,Input_Parameter__c,Object__c from PRM_EmailInputParamClause__mdt]){
                if(param != null) {inputParamQueryMap.put(param.Input_Parameter__c,param); }
            }
        for(EmailNotification emailNot : objEmailNotifList){
            lstEmailNotBusinessEvent.add(String.escapeSingleQuotes(emailNot.BusinessEvent));     
        }
        queryForTemplateDetails= 'SELECT PRM_BusinessEvent__c, PRM_ChannelProgram__c, PRM_Country__c, PRM_FolderName__c, PRM_Geo__c, PRM_InputParameter__c, PRM_Language__c, PRM_MergeField__c, PRM_PartnerType__c, PRM_Recipient__c, PRM_RecipientLogic__c, PRM_TemplateName__c, PRM_TemplateUniqueName__c ' +
        'FROM PRM_EmailConfigurationDetails__mdt ' +
        'WHERE PRM_BusinessEvent__c IN (\'' + String.join(lstEmailNotBusinessEvent, '\',\'') + '\')';
        emailConfigList = database.query(queryForTemplateDetails);
        for(EmailNotification emailNot : objEmailNotifList){  
            SendEmailWrapper sendWrap = sendEmail(emailNot);
            System.debug(LoggingLevel.info,'sendWrap.allEmails>>>>'+sendWrap.allEmails);
            System.debug(LoggingLevel.info,'sendWrap.allEmails>>>>'+sendWrap.allEmails.size());
            allmails.addAll(sendWrap.allEmails);
            logList.addAll(sendWrap.logListWrap);
            regReqLst.add(sendWrap.regReqId);
        }
        return sendEmails(allmails,logList,regReqLst);
  }

    public static SendEmailWrapper sendEmail(EmailNotification objEmailNotif)
    {
        List<Messaging.SingleEmailMessage> allmails = new List<Messaging.SingleEmailMessage>();
        //list<String> regReqLst=new list<String>();
        String regReqId;
        List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
        if(objEmailNotif != null)
        {
            //Get all records from PRM_EmailInputParamClause__mdt and populate a map
            
            //Identify the templateMetadata : to get the email Configuration details i.e. template and data to populate in emails   

            String recipientContactId ; 
            Map<String,PRM_Email_Template_Translations__mdt> translationMap = new Map<String,PRM_Email_Template_Translations__mdt>();
            for(PRM_Email_Template_Translations__mdt rec : [Select id,Custom_Label_Name__c,Language__c,Translated_Value__c from PRM_Email_Template_Translations__mdt])
            {
                translationMap.put(rec.Custom_Label_Name__c+rec.Language__c,rec);
            } 
            
            String contactId;
            if(objEmailNotif.InputParameters!=null && !objEmailNotif.InputParameters.isEmpty()){
                contactId= objEmailNotif.InputParameters.get('Contact_ID');
            }
            
            List<User> listUser;
            if(String.IsNotBlank(contactId)){
                listUser = [Select Email,id from User where ContactId=:contactId];
            }
            
            //query list of metadata records present with the business_event provided
           
            //execute the logic for each metadata record, corresponding to the business event passed
          ////  List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
            Set<String> recipientTypeExecuted = new Set<String>();    
            for(PRM_EmailConfigurationDetails__mdt emailConfig : emailConfigList)
            {
                if((String.isBlank(objEmailNotif.PartnerType) || objEmailNotif.PartnerType == emailConfig.PRM_PartnerType__c) 
                && (String.isBlank(objEmailNotif.ChannelProgram) || objEmailNotif.ChannelProgram == emailConfig.PRM_ChannelProgram__c)){
                //don't iterate for the metadata record with same business event and same type of recipient     
                if(! recipientTypeExecuted.contains(emailConfig.PRM_Recipient__c))
                {
                    recipientTypeExecuted.add(emailConfig.PRM_Recipient__c);
                    // Boolean mergeFieldProcessed = false;     
                    Map<String,User> contactIdUserMap = new Map<String,User>();
                    Map<String,User> userIdMap = new Map<String,User>();   
                    //Get the record details to pass info in EmailTemplate using inputParams and inputParamQueryMap
                    Map<String,SObject> objDetailsMap = new Map<String,SObject>(); 
                    List<String> dataQueryList = new List<String>();
                    if(emailConfig != null && emailConfig.PRM_InputParameter__c != null && !String.isBlank(emailConfig.PRM_InputParameter__c))
                    {
                        List<String> allInputParams = emailConfig.PRM_InputParameter__c.split(';');
                        for(String inputParam : allInputParams)
                        { String dataQuery;
                         //ignore contactID in all cases, except Partner-User and External Emails --> if passed in inputParams  
                         if(inputParam == 'Contact_ID' && emailConfig.PRM_Recipient__c != Label.PRM_PartnerUser && emailConfig.PRM_Recipient__c != Label.PRM_ExternalEmails) { }
                         else {
                             if(inputParamQueryMap.get(inputParam) != null && inputParamQueryMap.get(inputParam).Query_Clause__c != null && objEmailNotif.InputParameters.get(inputParam) != null)  
                             {
                                 dataQuery = 'Select '+inputParamQueryMap.get(inputParam).Query_Clause__c+' from '+inputParamQueryMap.get(inputParam).Object__c+' where id= \''+objEmailNotif.InputParameters.get(inputParam)+'\'' ; 
                                 dataQueryList.add(dataQuery);  
                             }
                         }    
                        }
                        for(String q : dataQueryList) 
                        {
                            SObject retrivedObj = Database.query(q);  
                            Schema.SObjectType obj = retrivedObj.getSObjectType();
                            objDetailsMap.put(String.valueOf(obj),retrivedObj); 
                        }
                    }
                    
                    //Get address of receipients
                    // List<String> toAddress = new List<String>();
                    Map<String,String> idAddressMap= new Map<String,String>();
                    //take value of recipient type in a variable and modify it to handle all similar kind of recipient type together    
                    String recipient = emailConfig.PRM_Recipient__c;
                    if(recipient.contains('Contact Relationship:')) {recipient = 'Contact Relationship' ; }  
                    else if(recipient.contains('Public Group:')) {recipient = 'Public Groups' ;      }
                    //String partnerUser = label.PRM_PartnerUser ;    
                    Boolean isExternalUser = false ;
                    Set<String> recipientObjIdSet = new Set<String>();
                    Switch on recipient {
                        when 'Partner User'{
                            //String contactId= objEmailNotif.InputParameters.get('Contact_ID');
                            if(contactId != null)
                            {
                                recipientContactId = contactId;
                               
                                User u ;
                                if(listUser != null && !listUser.isEmpty()) {
                                    u = listUser[0] ;
                                }
                                if(u != null)
                                {
                                    idAddressMap.put(u.id,u.email);
                                    recipientObjIdSet.add(u.id);
                                    isExternalUser = false;  
                                    userIdMap.put(u.id,u);   
                                    contactIdUserMap.put(contactId,u);    
                                }    
                            }
                        }
                        when 'Contact Relationship' {
                            
                            Set<String> relationshipNameSet = new Set<String>();
                            Map<String,String> contactIdEmailMap = new Map<String,String>();
                            for(String w : emailConfig.PRM_Recipient__c.substringAfter('Contact Relationship: ').split(','))
                            {
                                relationshipNameSet.add(w);
                            }
                            if(objEmailNotif.mailToContactID==null){
                                if(objEmailNotif.inputParameters.keySet().contains('Account_ID') &&  objEmailNotif.inputParameters.get('Account_ID') != null)
                                {
                                    //for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Contact_Id__c,PRM_Contact_Id__r.email from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c= : objEmailNotif.inputParameters.get('Account_ID') and PRM_Relationship_Id__r.Name in : relationshipNameSet and PRM_InActive_Ind__c= false and Channel_Program__c =:emailConfig.PRM_ChannelProgram__c ]) {
                                    for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Contact_Id__c,PRM_Contact_Id__r.email,PRM_Account_Id__r.Name from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c= : objEmailNotif.inputParameters.get('Account_ID') and PRM_Relationship_Id__r.Name in : relationshipNameSet and PRM_InActive_Ind__c= false ]) {
                                        contactIdEmailMap.put(acr.PRM_Contact_Id__c,acr.PRM_Contact_Id__r.email);}
                                }
                            }else{
                                contactIdEmailMap = objEmailNotif.mailToContactID;
                            }
                            //List<User> userList = new List<User>();
                            //userList = [Select id,email,ContactId from user where ContactId in : contactIdEmailMap.keySet()];
                            for(user u : [Select id,email,ContactId from user where ContactId in : contactIdEmailMap.keySet()])
                            {
                                contactIdUserMap.put(u.ContactId,u);
                                userIdMap.put(u.id,u);
                            }
                            //check if user exist or not for all contact
                            for(String conId : contactIdEmailMap.keySet())
                            {
                                User u  ;
                                if(contactIdUserMap.keyset().contains(conId)) {
                                    u = contactIdUserMap.get(conId);
                                }
                                //if User available corresponding to the contact -- set targetId as user's record ID
                                if(u != null)
                                {
                                    //idAddressMap.put(u.Id,u.email);
                                    //put key as contactId and value as userEmail --> as mail needs to be sent to user's email , but recipient details must be populated from contact record
                                    idAddressMap.put(conId,u.email);
                                    recipientObjIdSet.add(conId);
                                    isExternalUser = false;  
                                }
                                else //set targetId as user's record ID
                                {
                                    idAddressMap.put(conId,contactIdEmailMap.get(conId));
                                    recipientObjIdSet.add(conId);
                                    isExternalUser = false;  
                                }
                            }
                        }    
                        when 'External Emails' {
                            //put both key and value as same i.e email , as no recipient data has to pass
                            if(objEmailNotif.EmailID!=null){
                            for(String emailId : objEmailNotif.EmailID.split(';')) { 
                                idAddressMap.put(emailId,emailId); 
                            }
                            //no need to add in recipientObjIdSet as no recipient fields will be there in this case
                            isExternalUser = true;
                        }
                    }
                        when 'Public Groups' {
                            //assuming only direct users will be there in group
                            String emailIds ='' ;
                            List<String> emailList = new List<String>();
                            List<String> groupNames = emailConfig.PRM_Recipient__c.substringAfter('Public Group: ').split(',') ;
                            List<Id> usersIdsInGroup= new List<Id>();
                            for(GroupMember gm : [Select Id, group.type, UserOrGroupId From GroupMember where group.name in : groupNames])
                            {
                                usersIdsInGroup.add(gm.UserOrGroupId);
                            }
                            for(User u : [Select id,email from user where id in : usersIdsInGroup])
                            {
                                emailList.add(u.email);
                                //emailIds+=u.email;
                            }
                            emailIds= string.join(emailList,';');
                            //no need to put recordId as there will be no recipient in this case.. i.e. single mail to all group of users
                            idAddressMap.put(emailIds,emailIds);
                            //can't set targetObjectId in case of single mails to multiple users. So consider it as externalUser and set recipient adress in ToAddress 
                            isExternalUser = true;
                        }
                    }
                    
                    //get all merge fields for recipient
                    //assuming for each type of recipient there will be merge fields from only one object
                    List<String> recipientMergeFields = new List<String>();
                    if(emailConfig.PRM_RecipientLogic__c != null && emailConfig.PRM_RecipientLogic__c != '') {recipientMergeFields = emailConfig.PRM_RecipientLogic__c.split(',') ; } 
                    Map<String,String> objectFieldMap = new Map<String,String>();
                    for(String s : recipientMergeFields)
                    {   String obj = s.substringBefore('.');
                     String fld = s.substringAfter('.');
                     if(objectFieldMap.containsKey(obj))
                     {  String newFields = objectFieldMap.get(obj)+','+fld ;
                      objectFieldMap.put(obj,newFields) ;
                     }
                     else{
                         objectFieldMap.put(obj,fld);  
                     }
                    }
                    
                    //create dynamic query to fetch recipient merge fields
                    List<String> recipientdataQueryList = new List<String>();
                    Map<String,SObject> recipientObjDetailsMap = new Map<String,Sobject>();
                    String recipientdataQuery;
                    for(String s : objectFieldMap.keyset())
                    {
                        recipientdataQuery = 'Select '+objectFieldMap.get(s)+' from '+s+' where id in : recipientObjIdSet' ; 
                    }
                    if(recipientdataQuery != null && recipientdataQuery.length() > 0) { recipientdataQueryList.add(recipientdataQuery); }
                    for(String q : recipientdataQueryList) 
                    {
                        List<SObject> retrivedObjList = Database.query(q);  
                        for(SObject obj : retrivedObjList){
                            Schema.SObjectType objType = obj.getSObjectType();
                            //String objectType = String.valueOf(objType); 
                            recipientObjDetailsMap.put(obj.id,obj); 
                        }
                    }
                    
                    //EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName =: emailConfig.PRM_TemplateUniqueName__c ];
                    //create mail for each recipient obtained above
                        // String processedBodyForMergeFields; 
                    //List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                    //owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
                    
                    
                    
                    //Get required emailTemplate for each recipient 
                    //recipientContactId is already set in case of 'Partner User' type recipient. Set it for 'Contact Relationship' type recipient
                    
                    Set<String> contactIds = new Set<String>();
                    if(emailConfig.PRM_Recipient__c != 'Partner User' ){
                        for(String s : idAddressMap.keySet()){
                            contactIds.add(s);
                        }
                    }else{
                        contactIds.add(recipientContactId);
                    }
                    
                    
                    List<ContactTemplateWrapper> listOfConTemWrap = getTemplateForRecipient(objEmailNotif,emailConfig,contactIds,translationMap);
                    for(ContactTemplateWrapper contWrapObj : listOfConTemWrap){
                        
                        Map<EmailTemplate,String> templateBodyMap = contWrapObj.templateDetailsMap;
                        EmailTemplate emailTemp;
                        if(templateBodyMap != null && templateBodyMap.keySet() != null && templateBodyMap.keySet().size() > 0 ) {
                            emailTemp = new List<EmailTemplate> (templateBodyMap.keySet()).get(0); 
                        }   
                        
                        String htmlValue= templateBodyMap.get(emailTemp) ;
                        htmlValue = processHtmlTemplate(htmlValue ,objDetailsMap ,null,null,objEmailNotif.partnerRole,objEmailNotif.businessEvent,objEmailNotif.language); //Utkarsh - TWC727-864 - Added businessevent and partner role in the parameter for welcome email changes.
                        if(objEmailNotif.partnerAdmin == false){ // UTKARSH - US741977 - Changes made for Team RUBY flow
                            htmlValue = processHtmlTemplate(htmlValue ,objDetailsMap ,null,false,objEmailNotif.partnerRole,objEmailNotif.businessEvent,objEmailNotif.language); //Utkarsh - TWC727-864 - Added businessevent and partner role in the parameter for welcome email changes
                        }
                        
                        //use isExternalUser to identify we need to set recipient address in TargetObjectId or ToAddresses
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(emailTemp.Id);
                        mail.setSubject(emailTemp.Subject);
                        //mail.setSenderDisplayName('Salesforce Email');
                        //set from adress and display name from OrgWide address
                        if ( owea.size() > 0 ) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        } 
                        mail.saveAsActivity = false;
                        //replace recipient merge field values from html value of template
                        String htmlValue1= processHtmlTemplate(htmlValue ,recipientObjDetailsMap ,contWrapObj.contId,null,objEmailNotif.partnerRole,objEmailNotif.businessEvent,objEmailNotif.language); //Utkarsh - TWC727-864 - Added businessevent and partner role in the parameter for welcome email changes
                        if(objEmailNotif.partnerAdmin == false){ // UTKARSH - US741977 - Changes made for Team RUBY flow
                            htmlValue1= processHtmlTemplate(htmlValue ,recipientObjDetailsMap ,contWrapObj.contId,false,objEmailNotif.partnerRole,objEmailNotif.businessEvent,objEmailNotif.language); //Utkarsh - TWC727-864 - Added businessevent and partner role in the parameter for welcome email changes
                        }
                        
                        if(objEmailNotif.contactNameMap != null && !objEmailNotif.contactNameMap.isEmpty()){
                            String fName = objEmailNotif.contactNameMap.get(contWrapObj.contId);
                            if(String.isNotEmpty(fName)){
                                htmlValue1 = htmlValue1.replace('{!UserName}', fName);
                            }                            
                        }
                        
                        htmlValue1 = htmlValue1.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
                        mail.setHtmlBody(htmlValue1);
                        if(isExternalUser) // when emailId received as input param
                        {   List<String> addString = new List<String>();
                         //addString.add(idAddressMap.get(s));
                         for(String e : idAddressMap.get(contWrapObj.contId).split(';'))
                         {
                             addString.add(e);
                         }
                         mail.setToAddresses(addString);
                         if(contactId != null){
                            mail.setTargetObjectId(contactId);    
                         }

                        }else {   
                            // when emailId is from user or contact
                            //check if user is acociated to this contactId
                            if(contactIdUserMap.get(contWrapObj.contId) != null) { mail.setTargetObjectId(contactIdUserMap.get(contWrapObj.contId).id) ; }
                            else { mail.setTargetObjectId(contWrapObj.contId) ; }   
                        }
                        allmails.add(mail);
                       
                        //create log data for each mail entry assuming status as success
                        logList.addAll(createEmailLogs(mail,emailConfig,logList,idAddressMap,contactIdUserMap,userIdMap,contWrapObj.lang,contWrapObj.templateUniqName)) ;
                        if((objEmailNotif.InputParameters!=null) && (objEmailNotif.InputParameters.get('Registration_Request_ID')!=null))
                            {
                                regReqId=objEmailNotif.InputParameters.get('Registration_Request_ID');
                              /*  PRM_Registration_Request__c regRequest=new PRM_Registration_Request__c();
                                regRequest.id=objEmailNotif.InputParameters.get('Registration_Request_ID');
                                regRequest.PRM_Email_Log__c=logList[0].Id;
                                update regRequest;*/
                    }
                }
            }       
               
            }       
            }       
      
    }  
        SendEmailWrapper snwr = new SendEmailWrapper();
        snwr.allEmails = allmails;
        snwr.logListWrap = logList;
        snwr.regReqId=regReqId;
        return snwr;        
    
    } 
  //TWC729-4865 : returning set of Registration Request Id for tracker record Creation.
    public static Set<String> sendEmails(List<Messaging.SingleEmailMessage> allmails,List<PRM_EmailLog__c> logList, list<String> regReqLst){
        Set<String> regRequestIdSet = new Set<String>(); //Set to store Registration Request Id
            //send mail and check the result obtained -- modify the log entry according to the results obtained 
            try{
                List<Messaging.SendEmailResult> resultList;
                //if(! (PRM_EmailUtility.templateName == 'SCRRENGENRLR')) 
                //{
                resultList = Messaging.sendEmail(allmails,false);
                //}
                //create a Map for targetId and log
                Map<String,PRM_EmailLog__c> targetIdLog = new Map<String,PRM_EmailLog__c>();
                for(PRM_EmailLog__c l : logList)
                {
                    if(l.PRM_Contact__c != null) {
                        targetIdLog.put(l.PRM_Contact__c,l); 
                    }
                    else if(l.PRM_User__c !=  null) {
                        targetIdLog.put(l.PRM_User__c,l);
                    }
                }
                //system.debug('logList-->'+logList);
                for(Messaging.SendEmailResult result : resultList)
                {
                    if(! result.isSuccess())
                    {
                        for( Messaging.SendEmailError error : result.getErrors()) {
                            //in case of targetObjectId received  
                            String targetId= error.getTargetObjectId();
                            String errorMsg= error.getMessage();
                            if(targetId !=  null && targetIdLog.get(targetId) != null)
                            {
                               
                                targetIdLog.get(targetId).PRM_EmailDeliverabilityStatus__c = false;
                                targetIdLog.get(targetId).PRM_Email_API_Response__c = errorMsg ;
                               
                            }
                        } 
                    } 
                
                
                }   
             }catch (Exception e) {
                //String eMessage = e.getMessage();  
                //createEmailLogs(false,eMessage,mail,emailConfig,emailTemplate.body);
                System.debug(e.getMessage()+e.getStackTraceString());
            }
            
            if(logList != null && logList.size()>0) { 
            Integer count=0;
            string logEntry;
            list<PRM_Registration_Request__c> regReqLstToupdate=new list<PRM_Registration_Request__c>();
            list<Database.saveResult> saveLogResLst =  Database.insert(logList,false); 
             for (Database.SaveResult sr : saveLogResLst) {
                    if (sr.isSuccess()) {
                        if(regReqLst.size() > count) {
                            PRM_Registration_Request__c regRequest=new PRM_Registration_Request__c();
                            regRequest.id=regReqLst[count];
                            regRequest.PRM_Email_Log__c=sr.getId(); //need to check the method
                            regReqLstToupdate.add(regRequest);
                        }  
                    }
                    else if (!sr.isSuccess()){
                       // create log entry dml exceptions
                       logEntry=Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                    }
                    count++;
                }
    
           if(!regReqLstToupdate.isEmpty()){
            list<Database.saveResult> saveRegResLst =  Database.Update(regReqLstToupdate,false); 
             for (Database.SaveResult sr : saveRegResLst) {
                   if (!sr.isSuccess()){
                       // create log entry dml exceptions
                       logEntry=Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                    }
        }
                } 
                    //passing Registration  request Id
                    for (PRM_Registration_Request__c regReq : regReqLstToupdate){
                        regRequestIdSet.add(regReq.Id);
            }
        } 
        return regRequestIdSet;
        }    
    
    public class SendEmailWrapper{
        List<Messaging.SingleEmailMessage> allEmails;
        List<PRM_EmailLog__c> logListWrap;
        String regReqId;
    } 
    
    public static List<ContactTemplateWrapper> getTemplateForRecipient(EmailNotification objEmailNotif, PRM_EmailConfigurationDetails__mdt obj,Set<String> recipientContactIds,Map<String,PRM_Email_Template_Translations__mdt> translationMap){
        Map<String,String> langTemplateMap = new Map<String,String>();
        Map<String,String> mapContTemplate = new map<String,String>();
        Map<String,EmailTemplate> langEmailTempMap = new Map<String,EmailTemplate>();
        Map<EmailTemplate,String> emailTempMap = new Map<EmailTemplate,String>();
        //Map<String,Map<EmailTemplate,String>> conEmailMap = new Map<String,Map<EmailTemplate,String>>();
        PRM_EmailConfigurationDetails__mdt emailConfDetails;
        Set<String> businessEventSet = new Set<String>{System.Label.PRM_OPIDGold_BusinessEvent,System.Label.PRM_OPIDTitanium_BusinessEvent};
        Map<String,Set<String>> mapbusinesseventLang = new Map<String,Set<String>>();
        String rLanguage ;
        String rCountry ;
        String rGeo ;
        if(obj.PRM_Recipient__c == 'External Emails' || String.valueOf(obj.PRM_Recipient__c).contains('Public Group:')){
            for(PRM_EmailConfigurationDetails__mdt upgradeMetadataRecords :[SELECT PRM_BusinessEvent__c,PRM_Recipient__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c,PRM_Language__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c IN :businessEventSet]){
                Set<String> metadataLangSet = new Set<String>();
                if(mapbusinesseventLang.get(upgradeMetadataRecords.PRM_BusinessEvent__c) != null && !mapbusinesseventLang.get(upgradeMetadataRecords.PRM_BusinessEvent__c).IsEmpty()){
                    metadataLangSet = mapbusinesseventLang.get(upgradeMetadataRecords.PRM_BusinessEvent__c);
                }
                metadataLangSet.add(upgradeMetadataRecords.PRM_Language__c);
                mapbusinesseventLang.put(upgradeMetadataRecords.PRM_BusinessEvent__c,metadataLangSet);
            }
            
            emailConfDetails = getEmailConfigDetails(objEmailNotif,obj,translationMap,objEmailNotif.Language,objEmailNotif.Country,objEmailNotif.Geo);
            for(String emailId : recipientContactIds){
                langTemplateMap.put(emailConfDetails.PRM_TemplateUniqueName__c,rLanguage);
                mapContTemplate.put(emailId,emailConfDetails.PRM_TemplateUniqueName__c);
                /*Utkarsh - US709296 - Changes to accomodate Team RUBY Flow*/
                if(emailConfDetails.PRM_BusinessEvent__c == System.Label.PRM_OPIDGold_BusinessEvent || emailConfDetails.PRM_BusinessEvent__c == System.Label.PRM_OPIDTitanium_BusinessEvent){
                    /*if(objEmailNotif.Language == System.Label.PRM_Language_English){
                        rLanguage = System.Label.PRM_Language_English;
                    }
                    else if(objEmailNotif.Language == System.Label.PRM_Language_Chinese){
                        rLanguage = System.Label.PRM_Language_Chinese;
                    }
                    else{
                        rLanguage = System.Label.PRM_Language_English;
                    }
                    langTemplateMap.put(emailConfDetails.PRM_TemplateUniqueName__c,rLanguage);*/
                    if(mapbusinesseventLang.get(emailConfDetails.PRM_BusinessEvent__c) != null && !mapbusinesseventLang.get(emailConfDetails.PRM_BusinessEvent__c).IsEmpty() && mapbusinesseventLang.get(emailConfDetails.PRM_BusinessEvent__c).contains(objEmailNotif.Language)){
                        rLanguage = objEmailNotif.Language;
                    }
                    else{
                        rLanguage = System.Label.PRM_Language_English;
                    }
                    
                }
                /*US709296 - END*/
            }
        }else if(String.valueOf(obj.PRM_Recipient__c).contains('Contact Relationship:') || obj.PRM_Recipient__c == 'Partner User'){
            //if(emailConfDetails.PRM_BusinessEvent__c != System.Label.PRM_OPIDGold_BusinessEvent && emailConfDetails.PRM_BusinessEvent__c != System.Label.PRM_OPIDTitanium_BusinessEvent){
            for(Contact con : [Select id,Core_eRPM_Language_Code__c,mailingCountry,Core_Account_Primary_Country__c from contact where id in :recipientContactIds]){
                if(con != null && con.Core_eRPM_Language_Code__c!= null){rLanguage = con.Core_eRPM_Language_Code__c;}
                rCountry = (con.mailingCountry != null) ? con.mailingCountry : con.Core_Account_Primary_Country__c ;
                //rGeo = objEmailNotif.Geo ;
                emailConfDetails = getEmailConfigDetails(objEmailNotif,obj,translationMap,rLanguage,rCountry,rGeo);                
                if(emailConfDetails != null){
                    langTemplateMap.put(emailConfDetails.PRM_TemplateUniqueName__c,rLanguage);
                    mapContTemplate.put(con.Id,emailConfDetails.PRM_TemplateUniqueName__c);
                }
            }      
            //}         
        }
        
        //get html format of email body based on emailConfDetails.PRM_TemplateUniqueName__c
        if(!langTemplateMap.isEmpty()){
            for(EmailTemplate emailTemp: [SELECT Id,Subject,HtmlValue,Body,DeveloperName FROM EmailTemplate WHERE DeveloperName in :langTemplateMap.keySet()]){
                langEmailTempMap.put(emailTemp.DeveloperName,emailTemp);
            }            
        }
        
        //Generate template body map
        //emailTempMap
        if(langEmailTempMap != null && !langEmailTempMap.IsEmpty()){
        for(String templateName : langTemplateMap.keySet()){
            String lang = langTemplateMap.get(templateName);
            EmailTemplate tempDetails = langEmailTempMap.get(templateName);
            String bodyAfterProcessingLabels = processLabelsInBody(tempDetails.HtmlValue,lang,translationMap) ; 
            emailTempMap.put(tempDetails,bodyAfterProcessingLabels);
            
            }
        }
        
        //Mapping Contact with emailTempMap
        List<ContactTemplateWrapper> listOfConactWrapper = new List<ContactTemplateWrapper>();
        if(!mapContTemplate.isEmpty() && !langEmailTempMap.isEmpty() && !langTemplateMap.isEmpty()){            
            for(String conId : mapContTemplate.keySet()){
                String devName = mapContTemplate.get(conId);
                EmailTemplate tempDetail = langEmailTempMap.get(devName);
                if(tempDetail != null && !emailTempMap.isEmpty()){
                    String processedData = emailTempMap.get(tempDetail);
                    if(String.isNotBlank(processedData)){
                        ContactTemplateWrapper conWrapp = new ContactTemplateWrapper();
                        Map<EmailTemplate,String> mapObj = new Map<EmailTemplate,String>();
                        mapObj.put(tempDetail,processedData);
                        conWrapp.contId = conId;
                        conWrapp.templateDetailsMap = mapObj;
                        conWrapp.templateUniqName = devName;
                        conWrapp.lang = langTemplateMap.get(devName);                        
                        listOfConactWrapper.add(conWrapp);
                    }
                }
                
            }
        }
        return listOfConactWrapper;
    } 
    
    private class ContactTemplateWrapper{
        String contId;
        Map<EmailTemplate,String> templateDetailsMap;
        String templateUniqName;
        String lang;
    }
    
    private static PRM_EmailConfigurationDetails__mdt getEmailConfigDetails(EmailNotification objEmailNotif,PRM_EmailConfigurationDetails__mdt obj,Map<String,PRM_Email_Template_Translations__mdt> translationMap, String rLanguage,String rCountry,String rGeo){
        //identify the metadata as per the recipient's language, country and geo
        PRM_EmailConfigurationDetails__mdt mdtIdentified ;
        //Set<String> languageSet = new Set<String>{'ENG','ZHO'};
        //Map<emailTemplate,String> templateBodyMap = new Map<emailTemplate,String>();
        //if no language is found then select English as default language to query metadata record
        if (rLanguage == null || rLanguage =='') {rLanguage= 'ENG' ; }
        /*Utkarsh - US709296 - Changes to accomodate Team RUBY Flow*/
        /*if(objEmailNotif.BusinessEvent == System.Label.PRM_OPIDGold_BusinessEvent || objEmailNotif.BusinessEvent == System.Label.PRM_OPIDTitanium_BusinessEvent){
            if(!languageSet.contains(rLanguage)){
                rLanguage = 'ENG';
            }
        }*/
        /*US709296 - END*/
        String queryForMdt = 'SELECT PRM_BusinessEvent__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c= \''+String.escapeSingleQuotes(objEmailNotif.BusinessEvent)+'\' and PRM_Recipient__c = \''+String.escapeSingleQuotes(obj.PRM_Recipient__c)+'\'' ; 
        string whereCondition=' ';
        if(rLanguage != null && rLanguage != ' '){
            whereCondition += ' and PRM_Language__c = \''+String.escapeSingleQuotes(rLanguage)+'\'' ;
        }
        if(rGeo != null && rGeo != ' '){
            whereCondition += ' and PRM_Geo__c = \''+String.escapeSingleQuotes(rGeo)+'\'' ;
        }
        if(rCountry != null && rCountry != ' '){
            whereCondition += ' and PRM_Country__c = \''+String.escapeSingleQuotes(rCountry)+'\'' ;
        }        
        if(objEmailNotif.ChannelProgram != null && objEmailNotif.ChannelProgram != ' '){
            whereCondition += ' and PRM_ChannelProgram__c = \''+String.escapeSingleQuotes(objEmailNotif.ChannelProgram)+'\'' ;
        }
        if(whereCondition != null && whereCondition.length() > 0) {queryForMdt += whereCondition; }
        
        //combination of businessEvent+Language+Country+Geo+recipientType will be unique and will return only one result
        List<PRM_EmailConfigurationDetails__mdt> emailConfigList = database.query(queryForMdt); 
        //if no metadata record found for combination of language and country then, search only for contact's language
        if(emailConfigList != null && emailConfigList.size() == 0)
        {
            if(String.IsNotBlank(objEmailNotif.ChannelProgram)) {
                emailConfigList = [SELECT PRM_BusinessEvent__c,PRM_Recipient__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=: objEmailNotif.BusinessEvent and PRM_Language__c =: rLanguage and PRM_Recipient__c =: obj.PRM_Recipient__c and PRM_ChannelProgram__c = :objEmailNotif.ChannelProgram] ;
            }
            else {
                emailConfigList = [SELECT PRM_BusinessEvent__c,PRM_Recipient__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=: objEmailNotif.BusinessEvent and PRM_Language__c =: rLanguage and PRM_Recipient__c =: obj.PRM_Recipient__c] ;
            }
            
        }
        //if no metadata record found then just take the record with language as "English" -- as a default template
        if(emailConfigList != null && emailConfigList.size() == 0)
        {   rLanguage = 'ENG' ;
         if(String.IsNotBlank(objEmailNotif.ChannelProgram)) {
             emailConfigList = [SELECT PRM_BusinessEvent__c,PRM_Recipient__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=: objEmailNotif.BusinessEvent and PRM_Language__c = 'ENG' and PRM_Recipient__c =: obj.PRM_Recipient__c and PRM_ChannelProgram__c = :objEmailNotif.ChannelProgram] ;
         }
         else {
             emailConfigList = [SELECT PRM_BusinessEvent__c,PRM_Recipient__c,PRM_FolderName__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=: objEmailNotif.BusinessEvent and PRM_Language__c = 'ENG' and PRM_Recipient__c =: obj.PRM_Recipient__c] ;
         }
        }
        if(emailConfigList != null && emailConfigList.size()>0) { mdtIdentified = emailConfigList[0]; }
        
        
        // set values in static variables to create records in logs
        /*
PRM_EmailUtility.logLanguage= rLanguage;
PRM_EmailUtility.templateName= mdtIdentified.PRM_TemplateUniqueName__c ;
*/
        return mdtIdentified; 
    }
    
    /**
* @description         : method to process HTML tenmplates and populate values for merge fields
* @name                : processHtmlTemplate
* @param               : String , Map<String,SObject> ,String
* @throws exception    : NONE
**/ 
    /*Utkarsh - US741977 - Added new parameter partnerAdmin to accomodate Team RUBY Flow*/     
    public static String processHtmlTemplate(String htmlToParse , Map<String,SObject> dataMap , String iterator, boolean partnerAdmin, String partnerRole,String businessEvent, String language)
    {
        String tempHtmlValue = htmlToParse;
        List<String> templateBody1 = tempHtmlValue.split('\\{\\!');
        for(String s1 : templateBody1)
        {
            if(s1.contains('}'))
            {  
                String o = s1.substringbefore('}').substringbefore('.');
                String f=  s1.substringbefore('}').substringafter('.') ;  
                if(iterator != null)
                {
                    if(DataMap.get(iterator) != null) 
                    {
                        if(DataMap.get(iterator).get(f)!= null)
                        {
                            String fieldValue = String.valueOf(DataMap.get(iterator).get(f));    
                            tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);     
                        }//replace the value of field with blank space if no value is present in record
                        else 
                        {
                            String fieldValue = ' ' ;  
                            tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);     
                        }
                    }
                }
                else
                {
                    if(DataMap.get(o) != null) 
                    { 
                        if(DataMap.get(o).get(f)!= null)
                        {
                            String fieldValue = String.valueOf(DataMap.get(o).get(f));    
                            tempHtmlValue = tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue); 
                        }//replace the value of field with blank space if no value is present in record
                        else{
                            String fieldValue = ' ' ;  
                            tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);  
                        }
                    }    
                }
            }
        }
        
        //Added to Embed values for Custom Placeholders in the email.
        if(customPlaceholdersMap != null){
            for(String key: customPlaceholdersMap.keySet()){                
                tempHtmlValue = tempHtmlValue.replace(key, String.IsEmpty(customPlaceholdersMap.get(key))?'':customPlaceholdersMap.get(key));
            }
        }
        /*Utkarsh - US741977 - Changes to accomodate Team RUBY Flow*/
        if(partnerAdmin == false){
           tempHtmlValue = tempHtmlValue.replace(System.Label.PRM_Partner_Admin_Link,System.Label.PRM_Non_Partner_Admin_Link);
        }
        /*END - US741977*/
    /*Utkarsh - TWC727-864 - Remove DZS releated line from welcome email template when contact partner role is Guest*/
    if((businessEvent == System.Label.PRM_Welcome_Email_New_Event) || (businessEvent == System.Label.PRM_Welcome_Email_Existing_Event) || (businessEvent == System.Label.PRM_Email_Admin_Approval_Event)){
          if(partnerRole == 'Guest'){
            system.debug('inside welcome template');
                if(language == 'ENG'){
                    tempHtmlValue = tempHtmlValue.replace('Access to Intel® Developer Zone','');
                }
                if(language == 'ENU'){
                    tempHtmlValue = tempHtmlValue.replace('Access to Intel® Developer Zone','');
                }
                if(language == 'DEU'){
                    tempHtmlValue = tempHtmlValue.replace('Zugang zur Intel® Developer Zone','');
                }
                if(language == 'ZHT'){
                    tempHtmlValue = tempHtmlValue.replace('Access to Intel® Developer Zone','');
                }
                if(language == 'FRA'){
                    tempHtmlValue = tempHtmlValue.replace('Accès à Intel® Developer Zone','');
                }
                if(language == 'IND'){
                    tempHtmlValue = tempHtmlValue.replace('Akses ke Intel® Developer Zone','');
                }
                if(language == 'ITA'){
                    tempHtmlValue = tempHtmlValue.replace('Accesso a Intel® Developer Zone','');
                }
                if(language == 'JPN'){
                    tempHtmlValue = tempHtmlValue.replace('インテル® デベロッパー・ゾーンへのアクセス','');
                }
                if(language == 'POL'){
                    tempHtmlValue = tempHtmlValue.replace('Dostęp do Intel® Developer Zone','');
                }
                if(language == 'POR'){
                    tempHtmlValue = tempHtmlValue.replace('Acesso ao Espaço do desenvolvedor Intel®','');
                }
                if(language == 'ZHO'){
                    tempHtmlValue = tempHtmlValue.replace('访问英特尔® 开发人员专区','');
                }
                if(language == 'SPA'){
                    tempHtmlValue = tempHtmlValue.replace('Acceso a Intel® Developer Zone','');
                }
                if(language == 'ESP'){
                    tempHtmlValue = tempHtmlValue.replace('Acceso a Intel® Developer Zone','');
                }
                if(language == 'THA'){
                    tempHtmlValue = tempHtmlValue.replace('เข้าถึง Intel® Developer Zone','');
                }
                if(language == 'TUR'){
                    tempHtmlValue = tempHtmlValue.replace('Intel® Developer Zone erişim','');
                }
                if(language == 'VIE'){
                    tempHtmlValue = tempHtmlValue.replace('Truy cập vào Intel® Developer Zone','');
                }
          }
        }
    system.debug('tempHtmlValue-->'+tempHtmlValue);
    /*END - TWC727-864*/
        return tempHtmlValue ;
    }
    
    public static String processLabelsInBody(String body,String language,Map<String,PRM_Email_Template_Translations__mdt> translationMap)
    {
        String temp = body;
        List<String> templateBody1 = temp.split('\\{\\!\\$Label');
        for(String s : templateBody1)
        {
            if(s.startsWith('.'))
            {   String labelName= (s.substringBefore('}')).substringAfter('.');
             if(translationMap.get(labelName+language) != null) {temp = temp.replace('{!$Label.'+labelName+'}',translationMap.get(labelName+language).Translated_Value__c); }
            }
        }
        return temp;
    }    
    
    public class EmailNotification
    {
        public String businessEvent;
        public Map<String,String> inputParameters;
        public String emailID;
        public String language;
        public String country;
        public String geo;
        public String channelProgram;
        public String partnerType;
        public Map<String, String> mailToContactID;
        public Map<String, String> contactPreferdLang;
        public Map<String,String> contactNameMap;
        public boolean partnerAdmin; // UTKARSH - US741977 - Changes made for Team RUBY flow
    public String partnerRole; //Utkarsh - TWC727-864 - Added new parameter
        
    }
    
    //public static List<PRM_EmailLog__c> createEmailLogs(Boolean emailStatus, String response, Messaging.SingleEmailMessage mail,PRM_EmailConfigurationDetails__mdt obj,List<PRM_EmailLog__c> logList,Map<String,String> idAddrMap,String statusCode)
    public static List<PRM_EmailLog__c> createEmailLogs(Messaging.SingleEmailMessage mail,PRM_EmailConfigurationDetails__mdt obj,List<PRM_EmailLog__c> logList, Map<String,String> idAddressMap,map<String,User>contactIdUserMap,Map<String,User> userIdMap,String lang,String templateName)
    {
        return createEmailLogsBasedOnType(mail,'IPA', idAddressMap, contactIdUserMap, userIdMap, lang, templateName) ;
    }
    
    public static List<PRM_EmailLog__c> createEmailLogsBasedOnType(Messaging.SingleEmailMessage mail,String type, Map<String,String> idAddressMap,map<String,User>contactIdUserMap,Map<String,User> userIdMap,String lang,String templateName)
    {
        //apend values in below fields and create record in EmailLogs Object using obtained status  
        List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
        PRM_EmailLog__c log = new PRM_EmailLog__c();
        String successMsg ='Mail sent successfully !!';
        String toEmailId;
        log.PRM_EmailDeliverabilityStatus__c = true ;
        log.PRM_Timestamp__c = DateTime.now();
        log.Language__c = lang ;
        log.Email_Template_Name__c = templateName ;
        log.PRM_Email_API_Response__c = successMsg ; 
        log.PRM_EmailContent__c =  mail.getHtmlBody();
        log.PRM_EmailHTMLContent__c = mail.getHtmlBody();
        log.PRM_Type__c = type;
        //log.PRM_EmailContent__c =emailBodyTempl;
        log.PRM_Subject__c = mail.getSubject();
        if(mail.getToAddresses() != null ) {
            log.PRM_ToEmailID__c = string.join(mail.getToAddresses(),';');
            //Added this if-else as part of US-618183
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
            //Commenting below code as part of US849818. Email id validation is already done upfront on form.
            //Removing this regex pattern check to avoid excluding valid email ids, instead updating any errors returned while sending email in email log
            /*
            //check if address given is in appropriate email pattern or not for all externalEmails
            if(obj.PRM_Recipient__c == 'External Emails')
            {
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
                Pattern myPattern = Pattern.compile(emailRegex);
                Matcher myMatcher = MyPattern.matcher(log.PRM_ToEmailID__c);
                if (!MyMatcher.matches()) { log.PRM_EmailDeliverabilityStatus__c = false ;  log.PRM_Email_API_Response__c = 'Invalid Email Address !' ; }    
            }*/
        }
       if(mail.getTargetObjectId() != null)
        {
            String objType = String.valueof(mail.getTargetObjectId().getSObjectType());
            if(objType == 'Contact')
            { log.PRM_Contact__c = mail.getTargetObjectId() ;
            if(idAddressMap.get(mail.getTargetObjectId()) != null){
                 log.PRM_ToEmailID__c = idAddressMap.get(mail.getTargetObjectId()) ;       
             }      
            }
            else if (objType == 'User') {
                log.PRM_User__c = mail.getTargetObjectId(); 
                log.PRM_ToEmailID__c = userIdMap.get(mail.getTargetObjectId()).email;
                for(String conId : contactIdUserMap.keySet())
                {
                    if(contactIdUserMap.get(conId).id == mail.getTargetObjectId()) 
                    {
                        log.PRM_Contact__c =  conId;
                        //log.PRM_ToEmailID__c = contactIdUserMap.get(conId).email ;
                    }    
                }
            }  
        }
        else{

        }
        
        // iterate over map
        if(contactIdUserMap != null && !contactIdUserMap.isEmpty()){
        for(String conId : contactIdUserMap.keySet())
            {
                if(contactIdUserMap.get(conId).id == mail.getTargetObjectId()) {
                    log.PRM_Contact__c =  conId;
                    log.PRM_ToEmailID__c =  contactIdUserMap.get(conId).email;
                }
            }
        logList.add(log);
        }else{
            logList.add(log);
        }
        
        return logList ;
    }
    /* *****************************************************************************************************************************************
* author:      Tejasree Tadi    
* Date:        12/3/2020
* Parameters:  List<PRM_Benefit_Group_Benefit_Association__c> listOfBGBA,Map<Id,PRM_Benefit_Group_Benefit_Association__c> oldMap
* Description: This is the method created as a part of US5670004 used for sending emails to specialty IT Admins whenever a benifit is added or removed from BGBA
****************************************************************************************************************************************** */
    /*
    public static void sendBenefitsEmailNotification(list<PRM_Benefit_Group_Benefit_Association__c> lstOfBGBA,Map<Id,PRM_Benefit_Group_Benefit_Association__c> oldMap)
    {
        Set<PRM_Benefit_Group_Benefit_Association__c> newListofBGBA = new Set<PRM_Benefit_Group_Benefit_Association__c>();
        List<PRM_Benefit_Group_Benefit_Association__c> newInsertListofBGBA = new List<PRM_Benefit_Group_Benefit_Association__c>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SendEmailResult> resultList;
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];//Query to retrieve owea address
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName =:Label.PRM_EmailTemplate_Name]; //Query to get the appropriate email template
        List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =:Label.PRM_PubliGroup_Name]; //Query to retrieve all the users from public group
        List<String> groupUserIdList = new List<String>();
        List<String> lstUsers = new List<String>();
        List<User> usrLst = new List<User>();
        if(gm != null && !gm.IsEmpty()){
            for(GroupMember g : gm)
            {
                groupUserIdList.add(g.UserOrGroupId);
            }
        }
        if(groupUserIdList != null && !groupUserIdList.isEmpty()){
            usrLst= [SELECT Id, Name, Email FROM User WHERE id IN: groupUserIdList ];
        }
        if(usrLst != null && !usrLst.isEmpty()){
            for(User u : usrLst){
                lstUsers.add(u.Email);
            }
        }
        if(lstOfBGBA!= null && lstOfBGBA.size()>0){
            
            for(PRM_Benefit_Group_Benefit_Association__c bgba: lstOfBGBA){
                if((bgba.PRM_Status_Nm__c==System.Label.PRM_BGBA_Status) && (bgba.PRM_InActive_Ind__c == false)){
                    newListofBGBA.add(bgba);  
                }
                PRM_Benefit_Group_Benefit_Association__c bgbaOld ; 
                if(oldMap!=null && oldMap.size()>0){
                    bgbaOld = (PRM_Benefit_Group_Benefit_Association__c) oldMap.get(bgba.id) ;  
                } 
                
                // Adding the list of BGBA records based on conditions to check if benefit status is Live and InActive Indicator is changed 
                if((oldMap!=null && oldMap.size()>0)&&(((bgbaOld.PRM_InActive_Ind__c !=bgba.PRM_InActive_Ind__c) && 
                                                        (bgba.PRM_InActive_Ind__c == true))||((bgbaOld.PRM_Status_Nm__c != bgba.PRM_Status_Nm__c)&& (bgba.PRM_Status_Nm__c ==System.Label.PRM_BGBA_Status)&& (bgba.PRM_InActive_Ind__c == false))))
                    
                {   
                    newListofBGBA.add(bgba);
                }
            }
        }
        if(newListofBGBA!=null && newListofBGBA.size()>0){
            for(PRM_Benefit_Group_Benefit_Association__c bgba : newListofBGBA) 
            {   
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(et.Id);
                mail.setwhatId(bgba.Id);
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setToAddresses(lstUsers); //List of users from public group
                mail.setSaveAsActivity(false); 
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id); // used existing org wide email address as from address in Email
                } 
                allmsg.add(mail);
                try{
                    if(bgba != null){ 
                        resultList=Messaging.sendEmail(allmsg);             
                    }
                } 
                catch(Exception e){
                    system.debug('Exception occured' +e.getMessage());
                }
            }
        }
    } 
    */
    //End of US5670004
    /********************************************************************************************************************************************
* author:      Vijay   
* Date:        12/3/2020
* Parameters:  List<PRM_Account_Specialty_Association__c> succASA
* Description: This is the method used for sending emails to Public group Ruby_Rec_Users whenever Account is added to Speciality.
* User Story : US554312
****************************************************************************************************************************************** */
    /*
    public static  void sendEmailToPublicGroup(List<PRM_Account_Specialty_Association__c> succASA){
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        List<String> lstUsers = new List<String>();
        List<String> emailList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        String specialtyname = '';
        Set<String> asaAccountName = new Set<String>();
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        EmailTemplate templateId = [select id, name,HtmlValue,Body,Subject from EmailTemplate where developername =:System.Label.PRM_Template_Name];
        List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =:Label.PRM_PubliGroup_Name];
        List<String> groupUserIdList = new List<String>();
        List<User> usrLst = new List<User>();
        // Fetching the Users Id from the Group
        if(gm != null && !gm.IsEmpty()){
            for(GroupMember g : gm){groupUserIdList.add(g.UserOrGroupId);
                                   }
        }
        // Fetching the Users from the Group
        if(groupUserIdList != null && !groupUserIdList.IsEmpty()){usrLst = [SELECT Id, Name, Email FROM User WHERE id IN: groupUserIdList];
                                                                 }
        //Retrieving User's email from the User List
        if(usrLst != null && !usrLst.IsEmpty()){
            for(User u : usrLst){lstUsers.add(u.Email);
                                }
        }
        String accountString = '';
        // Retrieving Account Names and Speciality names from Success ASA records
        if(succAsa != null && !succAsa.IsEmpty()){
            for(PRM_Account_Specialty_Association__c eachAsa : succAsa){
                asaAccountName.add(eachAsa.PRM_Account_Id__r.name);
                specialtyname = eachAsa.PRM_Specialty_Id__r.name;
            }
        }
        if(asaAccountName != null && !asaAccountName.IsEmpty()){
            for(String str : asaAccountName){
                accountString = accountString + str + '<br/>';
            }
        }
        String htmlBody = templateId.HtmlValue;
        htmlBody = htmlBody.replace('%Specialty%', specialtyname); // Replacing HTML Body with the SPeciality Name 
        htmlBody = htmlBody.replace('%account Name 1%',accountString); // Replacing HTML Body with the Account Names
        htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId 
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSubject(templateId.Subject);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(htmlBody);
        mail.setToAddresses(lstUsers);
        mail.setTemplateId(templateId.id);
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
        } 
        mailList.add(mail);
        try{
            if(mailList != null && !mailList.IsEmpty()){
                Messaging.sendEmail(mailList);
            }
        }
        catch(Exception e){
            system.debug('Exception occured' +e.getMessage());
        }
    } */
/* *****************************************************************************************************************************************************************************
* author:      Vijay       
* Date:        03/13/2020
* Parameters:  list<PRM_Account_Specialty_Association__c> lstOfASA, map<id,PRM_Account_Specialty_Association__c> mapOldASAById 
* Return:      Void
* Description: This method is used to send Email to Primary contact whenever a specialty is assigned to an Account
* Stories :    US554284
*********************************************************************************************************************************************************************************/
    /*
    public static void sendEmailToPrimaryContacts(List<PRM_Account_Specialty_Association__c> succAsaList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        Map<String,Id> conEmailConIdMap = new Map<String,Id>();
        Map<Id,String> conIdPreferedLangaugeMap = new Map<Id,String>();
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        List < Messaging.SingleEmailMessage > mailList = new List <Messaging.SingleEmailMessage> ();
        Set<Id> specialityID = new Set<Id>();
        string specialtyName ='';
        List<Id> asaAccountIdSet = new List<Id>();
        String asaPartnerrolestring ='';
        Map<Id,String> conEmailIds = new Map<Id,String>();
        List<string> email = new List<string>();
        String specialityPartnerRole;
        Map<String,String> userEmailMap = new Map<String,String>();
        
        Set<String> conFirstName = new Set<String>();
        Set<String> conLastName = new Set<String>();
        //List<String> contactNameSet = new List<String>();
        Set<id> contactId = new Set<id>();
        Map<String,String> contactNamePreferedLang = new Map<String,String>();
        Map<String,String> langTemplateMap = new Map<String,String>();
        Map<String,EmailTemplate>templateIdMap = new Map<String,EmailTemplate>();
        List<PRM_Account_Contact_Relationship__c> accConList = new List<PRM_Account_Contact_Relationship__c>();
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        Map<String,String> userContactMap = new Map<String,String>();
        Map<String,Id> userNameIdMap = new Map<String,Id>();
        Map<Id,String> accSpecMap = new Map<Id,String>();
        Map<String,Set<String>> mapSpecLang = new Map<String,Set<String>>();
        List<Id> asaId = new List<Id>();
        
        
        for(PRM_Account_Specialty_Association__c eachAsa : succAsaList){
            PRM_Account_Specialty_Association__c asaOld ; 
            // Fetching Partner role and Speciality Id from Success ASA records 
            if(oldMap!=null && oldMap.size()>0) {asaOld = (PRM_Account_Specialty_Association__c) oldMap.get(eachAsa.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0)&&((asaOld.PRM_InActive_Ind__c != eachAsa.PRM_InActive_Ind__c)&&(eachAsa.PRM_InActive_Ind__c==False))))
            {
                asaAccountIdSet.add(eachAsa.PRM_Account_Id__c);
                asaId.add(eachAsa.Id);
                if(asaPartnerrolestring != null){
                    asaPartnerrolestring =  asaPartnerrolestring + ';'  + eachAsa.PRM_Partner_Role__c ;
                }else{asaPartnerrolestring = eachAsa.PRM_Partner_Role__c;
                     }
                asaPartnerrolestring = asaPartnerrolestring.removeEnd(';');
                specialityID.add(eachAsa.PRM_Specialty_Id__c);
            }
        }
        // Fetching Spciality AccountId and Name from success ASA records 
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        if(asaId != null && !asaId.isEmpty()){
            asaList = [Select Id, Name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name From PRM_Account_Specialty_Association__c Where Id IN :asaId];
        }
        if(asaList!=null && !asaList.IsEmpty()){
            for(PRM_Account_Specialty_Association__c asa :asaList){
                accSpecMap.put(asa.PRM_Account_Id__c,asa.PRM_Specialty_Id__r.Name);
            }
        }
        // Fetching Spciality Name and Speciality Parter Role information from success ASA records 
        if(specialityID!=null&& specialityID.size()>0 && !specialityID.IsEmpty()){
            for(PRM_Specialty__c spec : [select id, name, PRM_Role_Nm__c from PRM_Specialty__c where ID=:specialityID limit 1]){
                specialtyName =spec.Name;
                specialityPartnerRole = specialityPartnerRole + ',' + spec.PRM_Role_Nm__c;
            }
        }
        // Fetching Meta data information based on the Specaility 
        List<PRM_EmailConfigurationDetails__mdt> metaDataList = [SELECT PRM_Specialty__c,PRM_Language__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c from PRM_EmailConfigurationDetails__mdt where PRM_Specialty__c =:specialtyName];
        if(metaDataList != null && !metaDataList.IsEmpty()){
            for(PRM_EmailConfigurationDetails__mdt metaData : metaDataList){
                Set<String> langSet = new Set<String>();
                langTemplateMap.put(metaData.PRM_TemplateName__c.right(3),metaData.PRM_TemplateName__c);
                if(mapSpecLang.get(metaData.PRM_Specialty__c) != null && !mapSpecLang.get(metaData.PRM_Specialty__c).IsEmpty()) {
                    langSet = mapSpecLang.get(metaData.PRM_Specialty__c);
                }
                langSet.add(metaData.PRM_Language__c);
                mapSpecLang.put(metaData.PRM_Specialty__c,langSet);
            }
        }
        // Retrieving Email Template information 
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            For(EmailTemplate eachTemplate : [select id, name,HtmlValue,Body, subject from EmailTemplate where developername in :langTemplateMap.values()]){
                templateIdMap.put(eachTemplate.Name,eachTemplate);
            }
        }
        // Vijay - US608241 -START - As part of this story, need to check whether "Do Not Contact" field on conatct is checked or not before sending email.
        set<string> contactEmailSet = new Set<String>();
        if((asaAccountIdSet != null && !asaAccountIdSet.IsEmpty()) && (asaPartnerrolestring != null)){
            for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Contact_Id__c, PRM_Contact_Id__r.email,Name,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Name,PRM_Contact_Id__r.Core_Do_Not_Contact__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Account_Id__r.BillingCountry,PRM_Account_Id__r.BillingStreet,PRM_Account_Id__r.BillingCity,PRM_Account_Id__r.BillingState,PRM_Account_Id__r.BillingPostalCode,PRM_Contact_Id__r.Phone from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :asaAccountIdSet and PRM_Relationship_Id__r.name=:System.Label.PRM_Primary_Contact and PRM_Contact_Id__r.Core_Do_Not_Contact__c = false AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status]){
                if(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null){
                  //  if(asaPartnerrolestring.containsAny(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){
                        Boolean suppressEmail = PRM_Email_Handler_Utility.checkForEmailSupression(accCon.PRM_Contact_Id__c,'Specialty Addition');
                        if(suppressEmail == false){  
                            contactId.add(accCon.PRM_Contact_Id__c);     
                            accConList.add(accCon);  
                            contactNamePreferedLang.put(accCon.PRM_Contact_Id__r.Name,accCon.PRM_Contact_Id__r.Core_Preferred_Language__c);
                            conEmailConIdMap.put(accCon.PRM_Contact_Id__r.email,accCon.PRM_Contact_Id__c);
                            conIdPreferedLangaugeMap.put(accCon.PRM_Contact_Id__c,accCon.PRM_Contact_Id__r.Core_Preferred_Language__c);
                        }
                    //}
                }
                
            }
        }
        //END - US608241
        // Querying User Information 
        if(contactId != null && !contactId.IsEmpty()){        
            for(User eachUser :[SELECT ID,Name,Email,ContactID FROM User where ContactID in :contactId]){
                userEmailMap.put(eachUser.Name, eachUser.Email);
                userContactMap.put(eachUser.Name,eachUser.ContactId);
                userNameIdMap.put(eachUser.Name,eachUser.id);
            }
        }
        if(accConList != null && !accConList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c eachRec : accConList){
                String firstName =  eachRec.PRM_Contact_Id__r.FirstName;
                String contactName = eachRec.PRM_Contact_Id__r.Name;
                String emailId = '';
                EmailTemplate templateId;
                
                PRM_EmailLog__c log = new PRM_EmailLog__c();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // Vijay -US554284 As part of this story need to check whether the Contact is a User or not  
                if(userContactMap.containsKey(eachRec.PRM_Contact_Id__r.Name)){ mail.setTargetObjectId(userNameIdMap.get(eachRec.PRM_Contact_Id__r.Name));
                                                                              }else{
                                                                                  mail.setTargetObjectId(eachRec.PRM_Contact_Id__c);
                                                                              }
                String objType = String.valueof(mail.getTargetObjectId().getSObjectType());
                // Vijay -US554284 As part of this story need to check whether the Contact is a User or not  
                if(objType == System.Label.PRM_Object_Contact){
                    log.PRM_Contact__c = mail.getTargetObjectId() ;
                    log.PRM_ToEmailID__c = eachRec.PRM_Contact_Id__r.Email ;
                }else if (objType == System.Label.PRM_Object_User){log.PRM_Contact__c = eachRec.PRM_Contact_Id__c;
                                                                   log.PRM_User__c = mail.getTargetObjectId(); 
                                                                   log.PRM_ToEmailID__c = userEmailMap.get(eachRec.PRM_Contact_Id__r.Name);
                                                                  } 
                //Retrieving Email Template based on Contact Preferred Language
                if((langTemplateMap !=null && !langTemplateMap.IsEmpty()) && (mapSpecLang !=null && !mapSpecLang.IsEmpty()) && (accSpecMap !=null && !accSpecMap.IsEmpty())){
                    if(eachRec.PRM_Contact_Id__r.Core_Preferred_Language__c != null && mapSpecLang.get(accSpecMap.get(eachRec.PRM_Account_Id__c)).contains(eachRec.PRM_Contact_Id__r.Core_Preferred_Language__c)){ 
                        templateId = templateIdMap.get(langTemplateMap.get(eachRec.PRM_Contact_Id__r.Core_Preferred_Language__c));
                        log.Language__c = eachRec.PRM_Contact_Id__r.Core_Preferred_Language__c;
                    } else { //Vijay - US608245 -START - As part of this story, need to send email in english language if preferred language of contact is null.
                        templateId = templateIdMap.get(langTemplateMap.get(System.Label.PRM_Language_English));
                        log.Language__c = System.Label.PRM_Language_English;
                    }
                    // Fetching User Email Id if the Contact is a User
                    if(userEmailMap !=null && !userEmailMap.IsEmpty() && userEmailMap.containsKey(eachRec.PRM_Contact_Id__r.Name)){
                        emailId = userEmailMap.get(eachRec.PRM_Contact_Id__r.Name);
                    } else {
                        // Fetching Contact Email Id if the Contact is not a User
                        emailId = eachRec.PRM_Contact_Id__r.email; 
                    }
                    String[] emailIds = new String[]{emailId}; 
                        String htmlBody = templateId.HtmlValue; //Setting HTML body to the Email Template
                    htmlBody = htmlBody.replace(System.Label.PRM_Contact_FirstName,firstName);
                    htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
                    // Setting all the fields realted to Messaging.SingleEmailMessage mail Object 
                    mail.setSaveAsActivity(false);
                    mail.setSubject(templateId.subject);
                    mail.setHtmlBody(htmlBody);
                    mail.setToAddresses(emailIds);
                    mail.setTemplateId(templateId.id);
                    if (owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id); //Setting email from address
                    }
                    // Setting all the fields realted to Email Log Object              
                    String successMsg =System.Label.PRM_Email_SuccessMsg;
                    log.PRM_EmailDeliverabilityStatus__c = true ;
                    log.PRM_Timestamp__c = DateTime.now();
                    log.Email_Template_Name__c = templateId.name ;
                    log.PRM_Email_API_Response__c = successMsg ; 
                    log.PRM_EmailContent__c =  mail.getHtmlBody() ;
                    log.PRM_EmailHTMLContent__c = mail.getHtmlBody() ;
                    log.PRM_Subject__c = mail.getSubject();
                    if(!emailLogList.contains(log)){
                        emailLogList.add(log); 
                    }
                    if(!mailList.contains(mail)){
                        mailList.add(mail);
                    }
                }
            }
        }
        //END - US608237 
        try{
            List<Messaging.SendEmailResult> resultList;                
           
            Map<String,PRM_EmailLog__c> targetIdLog = new Map<String,PRM_EmailLog__c>();                
            resultList = Messaging.sendEmail(mailList,false);
            for(PRM_EmailLog__c l : emailLogList)
                {
                    if(l.PRM_Contact__c != null) {targetIdLog.put(l.PRM_Contact__c,l); }
                    else if(l.PRM_User__c !=  null) {targetIdLog.put(l.PRM_User__c,l);}
                }
            for(Messaging.SendEmailResult result : resultList)
            {
                if(! result.isSuccess())
                {
                    for( Messaging.SendEmailError error : result.getErrors()) {
                        //in case of targetObjectId received  
                        String targetId= error.getTargetObjectId();
                        String errorMsg= error.getMessage();
                        if(targetId !=  null && targetIdLog.get(targetId) != null)
                        {
                            PRM_EmailLog__c log = targetIdLog.get(targetId);
                            log.PRM_EmailDeliverabilityStatus__c = false;
                            log.PRM_Email_API_Response__c = errorMsg ;
                        }
                    } 
                } 
            }   
            if(emailLogList != null && !emailLogList.IsEmpty() && emailLogList.size() > 0){
                insert emailLogList;
            }
        }
        catch(Exception e){system.debug('Exception occured' +e.getMessage());
                          }
    }*/
/******************************************************************************************************************************************************************************
* author:      Tejasree       
* Date:        11/07/2020
* Parameters:  list<PRM_Partner_Assist_Consent__c> pacList
* Return:      Void
* Description: This method is used to send Opt In Email for Partner User when he clicks submit button from Partner Assist UI in IPA Community
* Stories :    US642537
*********************************************************************************************************************************************************************************/
    public static void sendOptInEmail(List<PRM_Partner_Assist_Consent__c> pacList){
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        String accountName='';
        String accNo='';
        String conName='';
        String Email='';
        DateTime dateValue=Null;
        String contLang='';
        String finaldist='';
        Id contactId;
        String dayString='';
        PRM_EmailLog__c log=new PRM_EmailLog__c();
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        //string emailList='';
        Map<id,String> distributorMap= new Map<id,String>();
        Map<String,String> langTemplateMap = new Map<String,String>();
        Map<String,EmailTemplate>templateIdMap = new Map<String,EmailTemplate>();
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =:Label.PRM_wsm_postmaster_intel_com];
        EmailTemplate templateId ;
        if(pacList!=Null && (!pacList.isEmpty()) && pacList.size()>0){
            for(PRM_Partner_Assist_Consent__c pac :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.name,PRM_Account_Id__r.AccountNumber,PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c,PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c,
                                                    PRM_Consent_Provided_By_Id__r.firstName,PRM_Consent_Provided_By_Id__c,PRM_Consent_Provided_By_Id__r.Email,PRM_Distributor_Id__c,
                                                    PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c,PRM_InActive_Ind__c,PRM_Consent_Provided_Date_Dt__c
                                from PRM_Partner_Assist_Consent__c where Id IN:pacList AND PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c=false AND PRM_InActive_Ind__c = false]){
                                                        
            if(distributorMap.containsKey(pac.PRM_Consent_Provided_By_Id__c)){
             String exisDistributor = distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);
             if(pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c!=Null){
              exisDistributor = exisDistributor+ ',' +pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c ;}
              distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,exisDistributor);
              }
              else{
              distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c);
              }
              accountName =pac.PRM_Account_Id__r.name;
              if(pac.PRM_Account_Id__r.AccountNumber!=Null){
              accNo = pac.PRM_Account_Id__r.AccountNumber;}
              conName=pac.PRM_Consent_Provided_By_Id__r.firstName;
              contactId=pac.PRM_Consent_Provided_By_Id__c;
              Email =pac.PRM_Consent_Provided_By_Id__r.Email;
              //emailList=Email;
              if(pac.PRM_Consent_Provided_Date_Dt__c!=Null){     
              dateValue=pac.PRM_Consent_Provided_Date_Dt__c;
              dayString= dateValue.formatGmt('dd/MM/YYYY');}
              contLang=pac.PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c;
              if(distributorMap.get(pac.PRM_Consent_Provided_By_Id__c)!=Null){
                  finaldist=distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);}
                }
        }
       
        for(PRM_EmailConfigurationDetails__mdt metaData : [SELECT PRM_BusinessEvent__c,PRM_Language__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c 
                                                           from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=:System.Label.PRM_Opt_In]){
                                                               langTemplateMap.put(metaData.PRM_Language__c,metaData.PRM_TemplateName__c);
                                                               
                                                           }
        //Retrieving email templates 
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            For(EmailTemplate eachTemplate : [select id,name,developername,HtmlValue,Body, subject from EmailTemplate where developername in :langTemplateMap.values()]){
                templateIdMap.put(eachTemplate.developername,eachTemplate);
            }
        }
        
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            if(contLang!=Null && contLang!='' && langTemplateMap.keySet().contains(contLang)){ //Bharath changes for defect -DE87198 : Added extra condition if the metadata doesnot contains the contact preffered language
                templateId = templateIdMap.get(langTemplateMap.get(contLang));
                log.Language__c =contLang;
            }else{
                templateId = templateIdMap.get(langTemplateMap.get(System.Label.PRM_Language_English));
                log.Language__c =System.Label.PRM_Language_English;
            }
            
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('!%UserFirstName%!,',conName);
            htmlBody = htmlBody.replace('!%AccountName%!',accountName); // Replacing HTML Body with the Account Name 
            
            htmlBody = htmlBody.replace('!%AccountNumber%!',accNo); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%UserEmailAddr%!',Email); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%DateSigned%!',dayString); // Replacing HTML Body with the Date 
            htmlBody = htmlBody.replace('!%Distributors%!',finaldist);// Replacing HTML Body with the Distributors 
            htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /* Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId */
            mail.setTargetObjectId(contactId);
            mail.setSubject(templateId.Subject);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            String[] toAddresses = new String[] {Email};//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setToAddresses(toAddresses);//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setTemplateId(templateId.id);
            
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
            }  
            /* Setting all the fields realted to Email Log Object */               
            String successMsg =System.Label.PRM_Email_SuccessMsg;
            log.PRM_EmailDeliverabilityStatus__c = true ;
            log.PRM_Contact__c=mail.getTargetObjectId();
            log.PRM_Timestamp__c = DateTime.now();
            log.PRM_ToEmailID__c =Email;
            log.Email_Template_Name__c = templateId.name ;
            log.PRM_Email_API_Response__c = successMsg ; 
            log.PRM_EmailContent__c =  mail.getHtmlBody();
            log.PRM_EmailHTMLContent__c = mail.getHtmlBody();
            log.PRM_Subject__c = mail.getSubject();
            log.PRM_Type__c = 'IPA';
            if(!emailLogList.contains(log)){
                emailLogList.add(log); 
            }
            if(!mailList.contains(mail)){
                mailList.add(mail);
            }
        }
        
        try{
            if(mailList!=Null && mailList.size()>0){
                Messaging.sendEmail(mailList);
            }
            if(emailLogList != null && !emailLogList.IsEmpty() && emailLogList.size() > 0){
                insert emailLogList;
            }
            
        }
        catch(Exception e){system.debug('Exception occured' +e.getMessage());
                          }
    }
/*******************************************************************************************************************************************************************************
* author:      Tejasree       
* Date:        11/07/2020
* Parameters:  list<PRM_Partner_Assist_Consent__c> pacList, map<id,PRM_Partner_Assist_Consent__c> oldMap 
* Return:      Void
* Description: This method is used for sending Opt Out Email to Partner User when existing Partner Assist Conset record is updated with Consent Provided as false
* Stories :    US642543
*********************************************************************************************************************************************************************************/
    
    public static void sendOptOutEmail(List<PRM_Partner_Assist_Consent__c> pacList,Map<Id,PRM_Partner_Assist_Consent__c>oldMap){
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        String accountName='';
        String accNo='';
        String conName='';
        String Email='';
        DateTime dateValue=Null;
        String contLang='';
        String finaldist='';
        Id contactId;
        String dayString='';
        PRM_EmailLog__c log=new PRM_EmailLog__c();
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        //List<String> emailList=new List<String>();
        Map<id,String> distributorMap= new Map<id,String>();
        Map<String,String> langTemplateMap = new Map<String,String>();
        Map<String,EmailTemplate>templateIdMap = new Map<String,EmailTemplate>();
    //    List<OrgWideEmailAddress> owea  = new List<OrgWideEmailAddress>();
    //     owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        List<PRM_Partner_Assist_Consent__c> partnerAssistList= new List<PRM_Partner_Assist_Consent__c>();
        EmailTemplate templateId ;
        if(pacList!=Null && pacList.size()>0){
            for(PRM_Partner_Assist_Consent__c partnerAssist: pacList){
                PRM_Partner_Assist_Consent__c pacOld ; 
                if(oldMap!=null && oldMap.size()>0){ pacOld = (PRM_Partner_Assist_Consent__c) oldMap.get(partnerAssist.id) ;}
                if((oldMap!=null && oldMap.size()>0)&&((pacOld.PRM_Consent_Provided_Ind__c != partnerAssist.PRM_Consent_Provided_Ind__c)&&(partnerAssist.PRM_Consent_Provided_Ind__c==false) && (partnerAssist.PRM_InActive_Ind__c==false)))
                {
                    partnerAssistList.add(partnerAssist); 
                }
            }
        }
        if(partnerAssistList!=Null && partnerAssistList.size()>0){
            for(PRM_Partner_Assist_Consent__c pac :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.name,PRM_Account_Id__r.AccountNumber,
                                                    PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c,PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c,
                                                    PRM_Consent_Provided_By_Id__r.firstName,PRM_Consent_Provided_By_Id__c,PRM_Consent_Provided_By_Id__r.Email,
                                                    PRM_Distributor_Id__c,PRM_InActive_Ind__c,PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c,PRM_Consent_Provided_Date_Dt__c 
                                                    from PRM_Partner_Assist_Consent__c where Id IN:partnerAssistList AND PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c=false AND PRM_InActive_Ind__c = false]){
                                                        if(distributorMap.containsKey(pac.PRM_Consent_Provided_By_Id__c)){
                                                            String exisDistributor = distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);
                                                            if(pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c!=Null){
                                                                exisDistributor = exisDistributor+ ',' +pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c ;}
                                                            distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,exisDistributor);
                                                        }
                                                        else{
                                                            distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c);
                                                        }
                                                        accountName =pac.PRM_Account_Id__r.name;
                                                        if(pac.PRM_Account_Id__r.AccountNumber!=Null){
                                                            accNo = pac.PRM_Account_Id__r.AccountNumber;}
                                                        conName=pac.PRM_Consent_Provided_By_Id__r.firstName;
                                                        contactId=pac.PRM_Consent_Provided_By_Id__c;
                                                        Email =pac.PRM_Consent_Provided_By_Id__r.Email;
                                                        //emailList.add(Email);
                                                        if(pac.PRM_Consent_Provided_Date_Dt__c!=Null){       
                                                            dateValue=pac.PRM_Consent_Provided_Date_Dt__c;
                                                            dayString= dateValue.format('dd/MM/YYYY');}
                                                        contLang=pac.PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c;
                                                        if(distributorMap.get(pac.PRM_Consent_Provided_By_Id__c)!=Null){
                                                            finaldist=distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);}
                                                    }
        }
        
        for(PRM_EmailConfigurationDetails__mdt metaData : [SELECT PRM_BusinessEvent__c,PRM_Language__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c 
                                                           from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=:System.Label.PRM_Opt_Out]){
                                                               langTemplateMap.put(metaData.PRM_Language__c,metaData.PRM_TemplateName__c);
                                                               
                                                           }
        //Retrieving email templates 
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            For(EmailTemplate eachTemplate : [select id,name,developername,HtmlValue,Body, subject from EmailTemplate where developername in :langTemplateMap.values()]){
                templateIdMap.put(eachTemplate.developername,eachTemplate);
            }
        }
        
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            if(contLang!=Null && contLang!='' && langTemplateMap.keySet().contains(contLang)){ //Bharath changes for defect -DE87198 : Added extra condition if the metadata doesnot contains the contact preffered language
                templateId = templateIdMap.get(langTemplateMap.get(contLang));
                log.Language__c =contLang;
            }else{
                templateId = templateIdMap.get(langTemplateMap.get(System.Label.PRM_Language_English));
                log.Language__c =System.Label.PRM_Language_English;
            }
            
          
            
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('!%UserFirstName%!,',conName);
            htmlBody = htmlBody.replace('!%AccountName%!',accountName); // Replacing HTML Body with the Account Name 
            
            htmlBody = htmlBody.replace('!%AccountNumber%!',accNo); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%UserEmailAddr%!',Email); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%DateSigned%!',dayString); // Replacing HTML Body with the Date 
            htmlBody = htmlBody.replace('!%Distributors%!',finaldist); // Replacing HTML Body with the Distributors 
            htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /* Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId */
            mail.setTargetObjectId(contactId);
            mail.setSubject(templateId.Subject);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            String[] toAddresses = new String[] {Email};//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setToAddresses(toAddresses);//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setTemplateId(templateId.id);
            
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
            }  
            /* Setting all the fields realted to Email Log Object */               
            String successMsg =System.Label.PRM_Email_SuccessMsg;
            log.PRM_EmailDeliverabilityStatus__c = true ;
            log.PRM_Contact__c=mail.getTargetObjectId();
            log.PRM_Timestamp__c = DateTime.now();
            log.PRM_ToEmailID__c =Email;
            log.Email_Template_Name__c = templateId.name ;
            log.PRM_Email_API_Response__c = successMsg ; 
            log.PRM_EmailContent__c =  mail.getHtmlBody() ; 
            log.PRM_EmailHTMLContent__c = mail.getHtmlBody() ; 
            log.PRM_Subject__c = mail.getSubject();
            log.PRM_Type__c = 'IPA';
            if(!emailLogList.contains(log)){
                emailLogList.add(log); 
            }
            if(!mailList.contains(mail)){
                mailList.add(mail);
            }
        }
        
        try{
            if(mailList!=Null && mailList.size()>0){
                Messaging.sendEmail(mailList);
            }
            if(emailLogList != null && !emailLogList.IsEmpty() && emailLogList.size() > 0){
                insert emailLogList;
            }
            
        }
        catch(Exception e){system.debug('Exception occured' +e.getMessage());
                          }
    }
    /* *****************************************************************************************************************************************************************************
* author:      Tejasree       
* Date:        11/07/2020
* Parameters:  list<PRM_Partner_Assist_Consent__c> pacList , map<id,PRM_Partner_Assist_Consent__c> oldMap
* Return:      Void
* Description: This method is used for sending Modify Email for Partner User when PartnerAssist record is updated with Distributor Change
* Stories :    US642559
*********************************************************************************************************************************************************************************/
    public static void sendPartnerModifyEmail(List<PRM_Partner_Assist_Consent__c> pacList,Map<Id,PRM_Partner_Assist_Consent__c>oldMap){
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        String accountName='';
        String accNo='';
        String conName='';
        String Email='';
        DateTime dateValue=Null;
        String contLang='';
        String finaldist='';
        Id contactId;
        String dayString='';
        PRM_EmailLog__c log=new PRM_EmailLog__c();
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        //Boolean contactflag=false;
        //List<String> emailList=new List<String>();
        Map<id,String> distributorMap= new Map<id,String>();
        Map<String,String> langTemplateMap = new Map<String,String>();
        Map<String,EmailTemplate>templateIdMap = new Map<String,EmailTemplate>();
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        List<PRM_Partner_Assist_Consent__c> partnerAssistList= new List<PRM_Partner_Assist_Consent__c>();
        EmailTemplate templateId ;
        if(pacList!=Null && pacList.size()>0){
            for(PRM_Partner_Assist_Consent__c partnerAssist: pacList){
                PRM_Partner_Assist_Consent__c pacOld ; 
                if(oldMap!=null && oldMap.size()>0){ pacOld = (PRM_Partner_Assist_Consent__c) oldMap.get(partnerAssist.id) ;}
                if(((oldMap!=null && oldMap.size()>0)&& ((pacOld.PRM_Distributor_Id__c != partnerAssist.PRM_Distributor_Id__c) &&(partnerAssist.PRM_Consent_Provided_Ind__c==true) && (partnerAssist.PRM_InActive_Ind__c==false))))
                {
                    partnerAssistList.add(partnerAssist); 
                }
            }
        }
        if(partnerAssistList!=Null && partnerAssistList.size()>0){
            for(PRM_Partner_Assist_Consent__c pac :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.name,PRM_Account_Id__r.AccountNumber,
                                                    PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c,PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c,
                                                    PRM_Consent_Provided_By_Id__r.firstName,PRM_Consent_Provided_By_Id__c,PRM_Consent_Provided_By_Id__r.Email,PRM_InActive_Ind__c,
                                                    PRM_Distributor_Id__c,PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c,PRM_Consent_Provided_Date_Dt__c 
                                                    from PRM_Partner_Assist_Consent__c where Id IN:partnerAssistList AND PRM_Consent_Provided_By_Id__r.Core_Do_Not_Contact__c=false AND PRM_InActive_Ind__c = false]){
            if(distributorMap.containsKey(pac.PRM_Consent_Provided_By_Id__c)){
            String exisDistributor = distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);
            if(pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c!=Null){
            exisDistributor = exisDistributor+ ',' +pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c ;}
            distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,exisDistributor);}
            else{
            distributorMap.put(pac.PRM_Consent_Provided_By_Id__c,pac.PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c);
             }
            accountName =pac.PRM_Account_Id__r.name;
            if(pac.PRM_Account_Id__r.AccountNumber!=Null){
            accNo = pac.PRM_Account_Id__r.AccountNumber;}
            conName=pac.PRM_Consent_Provided_By_Id__r.firstName;
            contactId=pac.PRM_Consent_Provided_By_Id__c;
            Email =pac.PRM_Consent_Provided_By_Id__r.Email;
            //emailList.add(Email);
            if(pac.PRM_Consent_Provided_Date_Dt__c!=Null){       
            dateValue=pac.PRM_Consent_Provided_Date_Dt__c;
            dayString= dateValue.format('dd/MM/YYYY');}
            contLang=pac.PRM_Consent_Provided_By_Id__r.Core_Preferred_Language__c;
            if(distributorMap.get(pac.PRM_Consent_Provided_By_Id__c)!=Null){
               finaldist=distributorMap.get(pac.PRM_Consent_Provided_By_Id__c);}
             }
        }
        
        
        //string dateString = string.valueOfGmt(pac.PRM_Consent_Provided_Date_Dt__c);
        for(PRM_EmailConfigurationDetails__mdt metaData : [SELECT PRM_BusinessEvent__c,PRM_Language__c,PRM_TemplateName__c,PRM_TemplateUniqueName__c 
                                                           from PRM_EmailConfigurationDetails__mdt where PRM_BusinessEvent__c=:System.Label.PRM_PartnerAssist_Modify]){
                                                               langTemplateMap.put(metaData.PRM_Language__c,metaData.PRM_TemplateName__c);
                                                               
                                                           }
        //Retrieving email templates 
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            For(EmailTemplate eachTemplate : [select id,name,developername,HtmlValue,Body, subject from EmailTemplate where developername in :langTemplateMap.values()]){
                templateIdMap.put(eachTemplate.developername,eachTemplate);
            }
        }
        
        if(langTemplateMap != null && !langTemplateMap.IsEmpty()){
            if(contLang!=Null && contLang!='' && langTemplateMap.keySet().contains(contLang)){ //Bharath changes for defect -DE87198 : Added extra condition if the metadata doesnot contains the contact preffered language
                templateId = templateIdMap.get(langTemplateMap.get(contLang));
                log.Language__c =contLang;
            }else{
                templateId = templateIdMap.get(langTemplateMap.get(System.Label.PRM_Language_English));
                log.Language__c =System.Label.PRM_Language_English;
            }
            
            //if(contactflag){
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('!%UserFirstName%!,',conName);
            htmlBody = htmlBody.replace('!%AccountName%!',accountName); // Replacing HTML Body with the Account Name 
            
            htmlBody = htmlBody.replace('!%AccountNumber%!',accNo); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%UserEmailAddr%!',Email); // Replacing HTML Body with the Account Number
            htmlBody = htmlBody.replace('!%DateSigned%!',dayString); // Replacing HTML Body with the Date 
            htmlBody = htmlBody.replace('!%Distributors%!',finaldist); // Replacing HTML Body with the Distributors
            htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /* Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId */
            mail.setTargetObjectId(contactId);
            mail.setSubject(templateId.Subject);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            String[] toAddresses = new String[] {email};//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setToAddresses(toAddresses);//Fix for Business Business Account Update sent to multiple users by Teja Munagala
            mail.setTemplateId(templateId.id);
            
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
            }  
            /* Setting all the fields realted to Email Log Object */               
            String successMsg =System.Label.PRM_Email_SuccessMsg;
            log.PRM_EmailDeliverabilityStatus__c = true ;
            log.PRM_Contact__c=mail.getTargetObjectId();
            log.PRM_Timestamp__c = DateTime.now();
            log.PRM_ToEmailID__c =Email;
            log.Email_Template_Name__c = templateId.name ;
            log.PRM_Email_API_Response__c = successMsg ; 
            log.PRM_EmailContent__c =  mail.getHtmlBody() ; 
            log.PRM_EmailHTMLContent__c = mail.getHtmlBody() ;
            log.PRM_Type__c = 'IPA';
            log.PRM_Subject__c = mail.getSubject();
            if(!emailLogList.contains(log)){
                emailLogList.add(log); 
            }
            if(!mailList.contains(mail)){
                mailList.add(mail);
            }
        }
        
        try{
            if(mailList!=Null && mailList.size()>0){
                Messaging.sendEmail(mailList);
            }
            if(emailLogList != null && !emailLogList.IsEmpty() && emailLogList.size() > 0){
                insert emailLogList;
            }
            
        }
        catch(Exception e){system.debug('Exception occured' +e.getMessage());
                          }
    }  
  
    public static void deactivationEmailofLastCAGRecords(List<Core_Account_Group_Member__c> EmailNewList,Map<Id,Core_Account_Group_Member__c> EmailoldMap){
        
        List <Messaging.SingleEmailMessage> mailList = new List <Messaging.SingleEmailMessage> ();
        List<String> lstUsers = new List<String>();
        //List<String> emailList = new List<String>();
        //List<String> mailToAddresses = new List<String>(); 
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        EmailTemplate templateId = [select id, name,HtmlValue,Body,Subject from EmailTemplate where developername =:System.Label.IPA_OPID_ADMIN_TEMPLATE];
        List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName =:System.Label.IPA_ADMIN_GROUPNAME];
        List<String> groupUserIdList = new List<String>();
        List<User> usrLst = new List<User>();
        // Fetching the Users Id from the Group
        if(gm != null && !gm.IsEmpty()){
            for(GroupMember g : gm){groupUserIdList.add(g.UserOrGroupId);
                                   }
        }
        // Fetching the Users from the Group
        if(groupUserIdList != null && !groupUserIdList.IsEmpty()){usrLst = [SELECT Id, Name, Email FROM User WHERE id IN: groupUserIdList];
                                                                 }
        //Retrieving User's email from the User List
        if(usrLst != null && !usrLst.IsEmpty()){
            for(User u : usrLst){lstUsers.add(u.Email);
                                }
        }
        //Retriving the IPID and Name Data
        //Set<id> OPIDAccts = new Set<id>();// to store OPID accnts
        Map<Id, Core_Account_Group_Member__c> opidwithCagMap = new Map<Id, Core_Account_Group_Member__c>();
        Set<id> OPIDAcctswithActiveAccounts = new Set<id>();// to store OPID accnts   
        //Set<id> OPIDwithoutActiveAccount = new Set<id>();// to store OPID accounts 
        Set<String> OPIDNamesSet = new Set<String>();// to store OPID without Active account Names
        String accountNamesString = '';
        //String opidRecordIds = '';
          
        for(Core_Account_Group_Member__c PAGM:EmailNewList) {
             //The below set will contail all the Id's where account is inactive. 
            if( PAGM.Core_Inactive_Ind__c ==true && EmailoldMap.get(PAGM.id).Core_Inactive_Ind__c!=PAGM.Core_Inactive_Ind__c){
                opidwithCagMap.put(PAGM.Core_Partner_Account_Id__c, PAGM);
            }
        }
        Map<Id, Account> cagIdWithAccNamesMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: opidwithCagMap.keyset()]);
        if(!opidwithCagMap.keyset().isEmpty()){
            for(Core_Account_Group_Member__c CagMember :[SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:opidwithCagMap.keySet() AND Core_Inactive_Ind__c=false]){                                          
                OPIDAcctswithActiveAccounts.add(CagMember.Core_Partner_Account_Id__c );
            }
            //if(!OPIDAcctswithActiveAccounts.isEmpty()){
                for(Core_Account_Group_Member__c temp : opidwithCagMap.values()){
                  if(!OPIDAcctswithActiveAccounts.contains(Temp.Core_Partner_Account_Id__c)){
                       OPIDNamesSet.add(cagIdWithAccNamesMap.get(Temp.Core_Partner_Account_Id__c).Name);
                  }
                }
            //}
       }//End of Getting records
       if(OPIDNamesSet != null){
            for(String str : OPIDNamesSet){
                accountNamesString = accountNamesString + str + '<br/>';
            }
        }
        
        /*if(OPIDwithoutActiveAccount != null){
            for(Id ids : OPIDwithoutActiveAccount){
                opidRecordIds = opidRecordIds + String.valueOf(ids) + '<br/>';
            }
        }*/
        if(accountNamesString != null && accountNamesString !='' && templateId!=null){
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('%AccountNames%', accountNamesString); // Replacing HTML Body with the Account Names
            htmlBody = htmlBody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
            //htmlBody = htmlBody.replace('%OPIDRecordIDs%', opidRecordIds); // Replacing HTML Body with the SPeciality Name 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /* Setting all the email related inputs like toAddress,TargetObjectId,HTML body,TemplateId */
            mail.setTargetObjectId( UserInfo.getUserId() );
            mail.setSubject(templateId.Subject);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            mail.setToAddresses(lstUsers);
            mail.setTemplateId(templateId.id);
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); // Setting From address in the email
            } 
            mailList.add(mail);
            try{
                if(mailList != null && !mailList.IsEmpty()){
                        Messaging.sendEmail(mailList);
                }
            }
            catch(Exception e){
                system.debug('Exception occured' +e.getMessage());
            }
        }
        
    }//End of Method    
       
}