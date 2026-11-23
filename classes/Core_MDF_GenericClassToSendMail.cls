/****************************************************************************************************************************************
* Class Name        : Core_MDF_GenericClassToSendMail
* Created Date      : 04/08/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       04/08/2020         Class to send email based on inputs
*****************************************************************************************************************************************/
public without sharing class Core_MDF_GenericClassToSendMail {
    public static Integer maxEmailChunksize = Core_MDF_CCP_ConstantClass.maxEmailChunckLimit;
    
    /***************************************************************************************************** 
    Method Name   :        sendEmailMethod
    @return       :        void
    @parameters   :        List of email parameters defined
    Description   :        Analyse the input parameters and send email
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/  
    
    /***************************************************************************************************** 
    
    Description   :        Added File Attachment logic to email if it has attachment
    Added By      :        Accenture - Bishal - 11/11/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/  
        @InvocableMethod
        public static void sendEmailMethod(List<mailParams> paramsList){
        
        Set<String> templateNameSet = new Set<String>();
        Set<Id> groupIdSet = new Set<Id>();
        
        //Key:Template Name, Value:Template Id
        Map<String,Id> templateNameAndIdMap = new Map<String,Id>();  
        
        //Key:RecordId, Value:GroupId Set
        Map<Id,Set<Id>> recordIdGroupIdSetMap = new Map<Id,Set<Id>>();
        
        //Key:RecordId, Value:UserId List
        Map<Id,List<String>> recordIdUserIdListMap = new Map<Id,List<String>>();  
    
        Map<Id,List<Id>> excludedUserIdMap = new Map<Id,List<Id>>();   
        Map<Id,List<String>> excludedUserEmailMap = new Map<Id,List<String>>();   
        List<String> objectNameList = new List<String>();
        List<String> notificationNameList = new List<String>();
        Map<String,List<Id>> objNotifTypeToRecordIdList = new Map<String,List<Id>>();

        try{
            for(mailParams params : paramsList){
                system.debug('params@@@' + params);

                // [emailAttachment=null, emailIds=null, excludedUserEmailList=(), excludedUserIdList=(), groupId=null, notificationName=Project Acceptance, objectName=CAMP - Campaign, recordId=701dh00000jwmSbAAI, sendDiff=false, templateName=Core_MDF_NotifyOnIPAProposalApproval, userIdList=(005Dz000009eZIUIA2, 005Dz000009dKDbIAM)]

                //Check if the input is groupId
                if(String.isNotEmpty(params.GroupId)){
                    for(Id groupId : params.GroupId.Split(';')){
                        //Prepare set to query on groupMember
                        groupIdSet.add(groupId);
                        
                        if(recordIdGroupIdSetMap.containsKey(params.recordId)){
                            recordIdGroupIdSetMap.get(params.recordId).add(groupId);
                        }else{
                            recordIdGroupIdSetMap.put(params.recordId,new Set<Id>{groupId});
                        }
                    }
                }
                
                templateNameSet.add(params.templateName);
    
                //If excluded user Id list is not empty then create a map of record Id to excluded user Id list
                if(params.excludedUserIdList != null && params.excludedUserIdList.size() > 0) {
                        excludedUserIdMap.put(params.recordId,params.excludedUserIdList);
                }
                //If excluded user email list is not empty then create a map of record Id to excluded user Email list
                if(params.excludedUserEmailList != null && params.excludedUserEmailList.size() > 0) {
                        excludedUserEmailMap.put(params.recordId,params.excludedUserEmailList);
    
                }
                //If object name and notification name is not blank then add to the ObjectName and Notification Name list
                if(string.isNotBlank(params.objectName) && string.isNotBlank(params.notificationName)) {
                        objectNameList.add(params.objectName);
                        notificationNameList.add(params.notificationName);
                        String objectNotificationKey = params.objectName + params.notificationName;
                        if(objNotifTypeToRecordIdList.containsKey(objectNotificationKey)) {
                           objNotifTypeToRecordIdList.get(objectNotificationKey).add(params.recordId);
                        }
                        else {
                            objNotifTypeToRecordIdList.put(objectNotificationKey, new List<Id> {params.recordId});
                        }
                    }
                
                
            }
        //If excluded user Id/Email list is not provided then get the excluded users based on object and notification name
        if(excludedUserIdMap.isEmpty() && excludedUserEmailMap.isEmpty() && !objectNameList.isEmpty() && !notificationNameList.isEmpty())  
        {
            List<Core_MDF_SubUnsub_Notifications_Utility.mailParams> mailParamsWrapperList = new List<Core_MDF_SubUnsub_Notifications_Utility.mailParams>();
            
            //Create Subscription mailparams wrapper
            Core_MDF_SubUnsub_Notifications_Utility.mailParams  paramsWrapper = new Core_MDF_SubUnsub_Notifications_Utility.mailParams();
            paramsWrapper.objectName = objectNameList;
            paramsWrapper.notificationName = notificationNameList;
            mailParamsWrapperList.add(paramsWrapper);
            
            //Call Subscription utility class to get excluded users Id/Email list
            List<List<Core_MDF_FlowMapClass>> flowMapWrapperResult =  Core_MDF_SubUnsub_Notifications_Utility.getExcludedUserList(mailParamsWrapperList);
            List<Core_MDF_FlowMapClass> flowMapWrapperList =  flowMapWrapperResult[0];
            
            
            for(Core_MDF_FlowMapClass wrapper : flowMapWrapperList) {
                String objectNotificationKey = wrapper.objectName+wrapper.notificationType;
                if(objNotifTypeToRecordIdList.containsKey(objectNotificationKey) && objNotifTypeToRecordIdList.get(objectNotificationKey) != null)
                    for(Id recordId : objNotifTypeToRecordIdList.get(objectNotificationKey))  {
                      excludedUserIdMap.put(recordId,wrapper.userIdList);
                      excludedUserEmailMap.put(recordId,wrapper.userEmailList);
                    }
              
                }
            }

            system.debug('excludedUserIdMap@@@' + excludedUserIdMap);
    
            
            //Query on groupMembers
            //Tag the users to the record for which they would receive mail
            //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            if(groupIdSet != NULL){
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId 
                                        FROM GroupMember
                                        WHERE GroupId IN: groupIdSet AND (UserOrGroup.isActive = true OR UserOrGroup.Partner_License_Reclaimed__c = true)]){
                                            //ATHR - Deeply Nested if 16209
                                            if(!string.valueof(gm.UserOrGroupId).startsWith('005')){
                                                continue;
                                            }
                                            //if(string.valueof(gm.UserOrGroupId).startsWith('005')){
                                                for(Id recordId : recordIdGroupIdSetMap.keySet()){
                                                    //ATHR - Deeply Nested if 16209
                                                    if(recordIdGroupIdSetMap.get(recordId) == NULL || !recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                                        continue;
                                                    }
                                                    //if(recordIdGroupIdSetMap.get(recordId) != NULL && recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                                        if(recordIdUserIdListMap.containsKey(recordId)){
                                                            recordIdUserIdListMap.get(recordId).add(gm.UserOrGroupId);
                                                        }else{
                                                            recordIdUserIdListMap.put(recordId,new List<String>{gm.UserOrGroupId});
                                                        }
                                                    
                                                    
                                                    //}     
                                                }
                                            //}
                                        }
            }                      
            
            if(templateNameSet != NULL){
                for(EmailTemplate template : [SELECT Id, Name, DeveloperName 
                                                FROM EmailTemplate 
                                                WHERE DeveloperName IN: templateNameSet]){
                                                    templateNameAndIdMap.put(template.DeveloperName, template.Id);
                                                }
            }
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();   
            
            for(mailParams params : paramsList){
                Id templateId = templateNameAndIdMap.get(params.templateName);
                if(params.sendDiff)
                {
                    if(recordIdUserIdListMap != NULL && recordIdUserIdListMap.Size() > 0 && 
                        recordIdUserIdListMap.containsKey(params.recordId) && recordIdUserIdListMap.get(params.recordId) != NULL){
                            for(String userId : recordIdUserIdListMap.get(params.recordId)){
                                
                                //Check whether user has unsubscribed for a notification or not. If not then send email.  
                                Boolean hasUserOptedOut = isUserExcluded(userId,null,params.recordId,excludedUserIdMap,null);
                                if(!hasUserOptedOut) {
                                    emailsToSend.add(createEmailInstance(params.recordId, templateId, NULL, userId));
                                }
                                
                            }                               
                        }  
                    
                        if(params.userIdList != NULL){
                        for(Id userId : params.userIdList){
                             //Check whether user has unsubscribed for a notification or not. If not then send email.  
                            Boolean hasUserOptedOut = isUserExcluded(userId,null,params.recordId,excludedUserIdMap,null);
                            if(!hasUserOptedOut) {
                                emailsToSend.add(createEmailInstance(params.recordId, templateId, NULL, userId));
                            }
                            
                        }
                    }
                    if(params.emailIds != NULL){
                    
                        system.debug('params.emailIds@@@' + params.emailIds);
                        for(String emailId : params.emailIds.split(';')){
                        //Check whether user has unsubscribed for a notification or not. If not then send email.  
                        Boolean hasUserOptedOut = isUserExcluded(null,emailId,params.recordId,null,excludedUserEmailMap);
                                                    
                        if(!hasUserOptedOut) 
                        {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                            String[] toAddresses = new String[] {emailId};
                            email.setToAddresses (toAddresses);
                            Id userId = UserInfo.getUserId();
                            email.targetObjectId = userId;
                            email.setTreatTargetObjectAsRecipient(false);
                            email.setWhatId(params.recordId);
                            email.setTemplateId(templateId);
                            email.setSaveAsActivity(false);
                            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                            
                            //Check whether the EmailAttachment is null or not. It should enter inside only if it is not null.
                            if(params.emailAttachment != NULL && params.emailAttachment.size()>0){
                                List<Messaging.Emailfileattachment> emailFileAttachmentList = new List<Messaging.Emailfileattachment>();
                                for(Core_MDF_SendEmailAttachment attachmap : params.emailAttachment){
                                    Messaging.Emailfileattachment emailFileAttachment = new Messaging.Emailfileattachment();
                                    //Setting the fileName which is we are getting from class Core_MDF_SendEmailAttachment
                                    emailFileAttachment.setFileName(attachmap.filename);
                                    //Setting the setBody which we are getting from class Core_MDF_SendEmailAttachment
                                    emailFileAttachment.setBody(attachmap.blobdata);
                                    //Adding Messaging.SingleEmailMessage to the List
                                    emailFileAttachmentList.add(emailFileAttachment);
                                }
                                email.setFileAttachments(emailFileAttachmentList);
                                
                            }
                            emailsToSend.add(email);
                            }
                        }    
                    }
                }
                else {
                    List<String> userIdList = new List<String>();
                    List<String> filteredUserIdList = new List<String>();
                    if(recordIdUserIdListMap != NULL && recordIdUserIdListMap.Size() > 0 &&
                        recordIdUserIdListMap.containsKey(params.recordId) && recordIdUserIdListMap.get(params.recordId) != NULL){
                        userIdList.addAll(recordIdUserIdListMap.get(params.recordId));
                        }
                    
                    if(params.userIdList != NULL && params.userIdList.Size() > 0){ 
                        userIdList.addAll(params.userIdList);
                        
                    }
    
                    for(ID userId : userIdList){
                        //Check whether user has unsubscribed for a notification or not. If not then add to the final UserId list.  
                        Boolean hasUserOptedOut = isUserExcluded(userId,null,params.recordId,excludedUserIdMap,null);
                        if(!hasUserOptedOut) {
                            filteredUserIdList.add(userId);
                        }
                            
                    }
    
                    if(!filteredUserIdList.isEmpty()){
                        List<List<String>> userIdChunkList = new List<List<String>>();
                        userIdChunkList = prepareListofChunks(filteredUserIdList,maxEmailChunksize); 
                        for(List<String> usrList:userIdChunkList){
                            emailsToSend.add(createEmailInstance(params.recordId, templateId, usrList, usrList[0]));
                        }
                    }
                    if(params.emailIds != NULL){ 
                        List<String> emailIdsList = params.emailIds.split(';');
                        List<String> filteredEmailIdsList = new List<String>();
                        for(String emailId : emailIdsList){
                            //Check whether user has unsubscribed for a notification or not. If not then add to the final User Email list. 
                            Boolean hasUserOptedOut = isUserExcluded(null,emailId,params.recordId,null,excludedUserEmailMap);
                                                    
                            if(!hasUserOptedOut) 
                            {
                                filteredEmailIdsList.add(emailId); 
                            }
                        }
                        
                        List<List<String>> emailIdsChunkList = new List<List<String>>();
                        emailIdsChunkList = prepareListofChunks(filteredEmailIdsList,maxEmailChunksize); 
                        for(List<String> emailId:emailIdsChunkList){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                         
                           
                            email.setToAddresses(emailId);
                            Id userId = UserInfo.getUserId();
                            email.targetObjectId = userId;
                            email.setTreatTargetObjectAsRecipient(false);
                            email.setWhatId(params.recordId);
                            email.setTemplateId(templateId);
                            email.setSaveAsActivity(false);
                            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                            emailsToSend.add(email);
                        }
                    }
                }
            }
            if(emailsToSend != NULL && emailsToSend.Size() > 0){
                List<Messaging.SendEmailResult> res = Messaging.sendEmail(emailsToSend, false);
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_EmailLogEntry')){//ByPass Email Log Creation
                    createEmailLogEntry(emailsToSend, res);//Create Email Log Entries
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    // Check whether user has opt-out for a notification type or not
    public static boolean isUserExcluded(Id userId,String emailId, Id recordId, Map<Id,List<Id>> excludedUserIdMap, Map<Id,List<String>> excludedUserEmailMap) 
    {
        Boolean isUserExcluded = false;
    
        //If recipient address is userId, then check whether user Id is part of excluded user id list or not
        if(string.isNotBlank(userId)) {
            //First check whether excluded user Id list is not empty
            if(excludedUserIdMap.containsKey(recordId) && excludedUserIdMap.get(recordId) !=null && excludedUserIdMap.get(recordId).contains(userId)) {
                isUserExcluded = true;
            }
        }
        //If recipient address is emailId, then check whether user email is part of excluded user email list or not
        else if(string.isNotBlank(emailId)) {
           //First check whether excluded user email list is not empty
            if(excludedUserEmailMap.containsKey(recordId) && excludedUserEmailMap.get(recordId) != null && excludedUserEmailMap.get(recordId).contains(emailId)) {
                isUserExcluded = true;
            }
        }
        return isUserExcluded;
    }
    
    /***************************************************************************************************** 
    Method Name   :        createEmailInstance
    @return       :        Messaging.SingleEmailMessage
    @parameters   :        Record Id, Template Id, List of UserId 
    Description   :        Creates and returns the Messaging.SingleEmailMessage instance based on input parameters
    Added By      :        Accenture - VD - 04/27/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static Messaging.SingleEmailMessage createEmailInstance(Id recordId, Id templateId, List<String> userIdList, String setTargetObjectId){
        
        try{
            system.debug('userIdList@@@' + userIdList);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            if(userIdList != NULL){
                email.setToAddresses(userIdList);
            }
            if(setTargetObjectId != NULL){
                email.setTargetObjectId(setTargetObjectId);
            }
            email.setWhatId(recordId);
            email.setTemplateId(templateId);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            return email;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;} 
    }
    
    /***************************************************************************************************** 
    Class Name    :        mailParams
    Description   :        contains all the invocable variables
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class MailParams{
        @InvocableVariable(label = 'GroupId')
        public String groupId;
        
        @InvocableVariable(label = 'UserIdList')
        public List<Id> userIdList = new List<Id>();
        
        @InvocableVariable(label = 'emailId')
        public String emailIds;
        
        @InvocableVariable(label = 'recordId')
        public Id recordId;
        
        @InvocableVariable(label = 'templateDeveloperName')
        public String templateName;
        
        @InvocableVariable(label = 'sendDiff')
        public Boolean sendDiff = TRUE;
        
        @InvocableVariable(label='emailAttachment')
        public Core_MDF_SendEmailAttachment[] emailAttachment;
    
        @InvocableVariable(label = 'objectName')
        public String objectName;
    
        @InvocableVariable(label = 'notificationName')
        public String notificationName;
    
        @InvocableVariable(label = 'excludedUserIdList')
        public List<Id> excludedUserIdList = new List<Id>();
    
        @InvocableVariable(label = 'excludedUserEmailList')
        public List<String> excludedUserEmailList = new List<String>();
        
    }
    
    /***************************************************************************************************** 
    Method Name   :        UrlStr
    @return       :        getReportUrl
    @parameters   :        varReportName, isExternal 
    Description   :        returns the report url dynamatically
    Added By      :        Accenture - Akilan - 06/10/2021
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public String UrlStr{  public get { return getReportUrl(); } set;}
    public String varReportName {get; set;}
    public Boolean isExternal {get; set;}
    public  String getReportUrl(){
        String reportId='';
        String url='';
        String startDate;
        String endDate;
        
        reportId = getReportId(varReportName); 
        PageReference pr;

        if(isExternal){
                //url= System.Label.Core_MDF_PFRCommunityLink +'s/report'+'/' + reportId; //commented for ATHR fix
                pr = new PageReference(System.Label.Core_MDF_PFRCommunityLink + 's/report/' + reportId);
            	return pr.getUrl();
        }
        else{            
            //url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/' + reportId;
            //url='https://'+ System.URL.getOrgDomainUrl().getHost() + '/' + reportId; //commented for ATHR fix
            pr = new PageReference('/' + reportId);
            return System.URL.getOrgDomainUrl().toExternalForm() + pr.getUrl();            
        } 
        //return url;
        
    }
    
    public string getReportId(String reportName){
        String reportId ='';
        List<Report> reportList   = [Select Id from Report where Name=: reportName LIMIT 1];
        if(reportList != null && !reportList.isEmpty()){
            reportId = reportList[0].Id;
        }
        return reportId;
    }
            
    /***************************************************************************************************** 
    Method Name   :        createEmailInstanceTarget
    @return       :        Messaging.SingleEmailMessage
    @parameters   :        Record Id, Template Id, List of UserId 
    Description   :        Creates and returns the Messaging.SingleEmailMessage instance based on input parameters
    Added By      :        Accenture - PD - 10/12/2021
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static Messaging.SingleEmailMessage createEmailInstanceTarget(Id recordId, Id templateId,String setTargetObjectId){        
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();   
            email.setTargetObjectId(setTargetObjectId);  
            if(string.isNotBlank(recordId)){
                email.setWhatId(recordId);
            }
            email.setTemplateId(templateId);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            return email;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;} 
    }
    /***************************************************************************************************** 
    Method Name   :        sendEmails
    @return       :        Messaging.SendEmailResult
    @parameters   :        List of Messaging.Email
    Description   :        send the email
    Added By      :        Accenture - PD - 10/12/2021
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
        public static List<Messaging.SendEmailResult> sendEmails(List<Messaging.Email> emailsToSend) {
            List<Messaging.SendEmailResult> res;
            if(emailsToSend != NULL && emailsToSend.Size() > 0){
                res = Messaging.sendEmail(emailsToSend, false);
                try{
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_EmailLogEntry')){//ByPass Email Log Creation
                        List<Messaging.SingleEmailMessage> listEmailMsg = (List<Messaging.SingleEmailMessage>)emailsToSend;
                        createEmailLogEntry(listEmailMsg, res);//Create Email Log Entries
                    }
                }catch(Exception e){
                    Core_MDF_CCP_UtilityClass.logError(e);
                }
            }
            return res;
        }
        
        
        /***************************************************************************************************** 
    Method Name   :        batchExecutionNotifyUser    
    @parameters   :        EmailTemplateName, BatchClassName, MetaDataLabelName
    Description   :        Notify Users about Batch Execution
    Added By      :        Accenture - Shiva - 31st May 2022
    ******************************************************************************************************/
        public static void batchExecutionNotifyUser(string emailTemplateName, string batchClassName, string toUsersLabel){   
            String htmlBody;String subject;
            List<string> emailUsers = new List<string>();
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Body,Subject,HtmlValue, Name 
                                                 FROM EmailTemplate 
                                                 WHERE Name =: emailTemplateName LIMIT 1]; 
            
            Messaging.SingleEmailMessage notifyMail = new Messaging.SingleEmailMessage();
            
            string users = Core_MDF_CustomLabelConfig.getTextValues(toUsersLabel);
            
            if(string.isNotBlank(users)){
                if(users.contains(',')){
                    emailUsers = users.split(',');   
                }else{
                    emailUsers.add(users);
                }
            }
            // replacing Email Body & Subject with class name
            if(!emailTemplate.isEmpty()){
                htmlBody = emailTemplate[0].HtmlValue;
                subject = emailTemplate[0].Subject;
                
                
                if(htmlBody.contains('##Class')){
                    htmlBody = htmlBody.replace('##Class', batchClassName);
                }
                if(subject.contains('##Class')){
                    subject = subject.replace('##Class', batchClassName);
                }
                
                htmlBody.stripHtmlTags();
                
            }
            if(!emailUsers.isEmpty()){
                notifyMail.setToAddresses(emailUsers);
            }
            notifyMail.setHtmlBody(htmlBody);
            notifyMail.setSubject(subject);
            notifyMail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            
            if(notifyMail !=null){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {notifyMail});
            }  
            
        }
        //Wrapper to store Email Log Details
        public class EmailLogDetailsWrapper{
            public Id sObjectId;
            public String emailDeliverabilityStatus;
            public String errorMessage;
            public String fromEmailId;
            public String toEmailId;
            public String templateName;
            public String templateValue;
        }
    
    //This method creates Email Log Entry at Core_Log_Entry object
    public static void  createEmailLogEntry(List<Messaging.SingleEmailMessage> listOfEmails, List<Messaging.SendEmailResult> EmailResultList){
        List<Core_MDF_Bulk_Transaction__e> listEvenPlatform = new List<Core_MDF_Bulk_Transaction__e>();
        try{
            Map<String, String> mapFailedEmailIdToErrorMsg = new Map<String, String>();
            List<EmailLogDetailsWrapper> wrapperList = new List<EmailLogDetailsWrapper>();
            //For getting all Emails that are failed
            Integer count = 0;
            for(Messaging.SendEmailResult result : emailResultList){
                if(!result.isSuccess())
                {   
                    //creating a key to store Failed Records in Map
                    String strToAddress = listOfEmails[count].getToAddresses() != null ? (string.join(listOfEmails[count].getToAddresses(),',')).trim(): '';
                    String strtempName = listOfEmails[count].getTemplateName() != null ? listOfEmails[count].getTemplateName().trim() : '';
                    String keyToAddressAndTempName = (strToAddress+','+strToAddress).toLowerCase();
                    for( Messaging.SendEmailError error : result.getErrors()) {
                        if(mapFailedEmailIdToErrorMsg.containsKey(keyToAddressAndTempName)){
                            mapFailedEmailIdToErrorMsg.put(keyToAddressAndTempName, mapFailedEmailIdToErrorMsg.get(keyToAddressAndTempName)+','+error.getMessage());
                        }else{
                            mapFailedEmailIdToErrorMsg.put(keyToAddressAndTempName, error.getMessage());
                        }
                    }
                }
                count++; 
            }
    
            //Creating Logs for Failed and Success Records
            for(Messaging.SingleEmailMessage mail : listOfEmails){
                EmailLogDetailsWrapper wrap = new EmailLogDetailsWrapper();
                wrap.EmailDeliverabilityStatus = Core_MDF_CCP_ConstantClass.strFailed;
                String strToAddress = mail.getToAddresses() != null ? (string.join(mail.getToAddresses(),',')).trim(): '';
                String strTempName = mail.getTemplateName() != null ? mail.getTemplateName().trim() : '';
                String keyToAddressAndTempName = (strToAddress+','+strTempName).toLowerCase();
                if(!mapFailedEmailIdToErrorMsg.containsKey(keyToAddressAndTempName)){
                    wrap.EmailDeliverabilityStatus = Core_MDF_CCP_ConstantClass.strSuccess;  
                    wrap.errorMessage = ''; 
                }
                else{
                    wrap.errorMessage = mapFailedEmailIdToErrorMsg.get(keyToAddressAndTempName);
                }
                wrap.sObjectId = mail.getWhatId();
                
                wrap.fromEmailId = mail.getOrgWideEmailAddressId();
    
                wrap.toEmailId = '';
                if(mail.getToAddresses() != null && !mail.getToAddresses().isEmpty()){
                    for(String email: mail.getToAddresses()){
                        wrap.toEmailId += email+'; ';
                    }
                }
                else if(mail.getTargetObjectId() != null){
                    wrap.toEmailId = mail.getTargetObjectId();
                }
                
                wrap.templateName = mail != null ? mail.getTemplateName() : '';
                wrap.templateValue = (mail != null && mail.getHtmlBody() != null) ? (mail.getHtmlBody()).stripHtmlTags() : '';                    
                
                Core_Log_Entry__c logEntryObj = createEmailLogInstance(wrap);
                listEvenPlatform.add(createBulkTransactionPlatEventInstance(logEntryObj));
            }
            if(!listEvenPlatform.isEmpty()){
                EventBus.publish(listEvenPlatform);  
            }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public static Core_MDF_Bulk_Transaction__e createBulkTransactionPlatEventInstance(Core_Log_Entry__c logEntryObj){
        Core_MDF_Bulk_Transaction__e bulkTransactionEvent = new Core_MDF_Bulk_Transaction__e();
        bulkTransactionEvent.Core_MDF_JSON_Data__c = JSON.serialize(logEntryObj);
        bulkTransactionEvent.Core_MDF_Object_Name__c = 'Core_Log_Entry__c';
        return bulkTransactionEvent;
    }
    
    public static Core_Log_Entry__c createEmailLogInstance(EmailLogDetailsWrapper EmailWrapper){
        Core_Log_Entry__c logEntryObj = new Core_Log_Entry__c();
        logEntryObj.Core_sObjectId__c = EmailWrapper.sObjectId; 
        logEntryObj.Core_sObjectType__c = EmailWrapper.sObjectId.getSObjectType().getDescribe().getName();
        String logDetails = JSON.serialize(EmailWrapper);
        logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,   32765) : logDetails;    
        logEntryObj.Core_Message__c = (EmailWrapper.EmailDeliverabilityStatus == Core_MDF_CCP_ConstantClass.strSuccess)
            ?'Email Sent Successfully at '+System.now()
            : 'Email Deliverability Failed';
        logEntryObj.Core_Project__c = Label.Core_MDF_Program_Name;
        logEntryObj.Core_Tags__c = EmailWrapper.sObjectId;
        logEntryObj.Core_When__c = System.now();
        logEntryObj.Core_Origin__c = 'Core_MDF_GenericClassToSendMail';
        logEntryObj.Core_Severity__c = EmailWrapper != null && (EmailWrapper.EmailDeliverabilityStatus == Core_MDF_CCP_ConstantClass.strSuccess) ? 'Info' : 'Medium';// cannot take critical as ut will initiate a Flow which sends email
        logEntryObj.Core_Scope__c = 'Email Logging for CCP';
    
        return logEntryObj;
    }
            /***************************************************************************************************** 
    Method Name   :        prepareListofChunks    
    @parameters   :        email List
    Description   :        split the emailList into chunks 
    return        :        List of email chunks 
    Added By      :        Accenture - AN - 20/05/2024
    ******************************************************************************************************/
    public static List<List<String>> prepareListofChunks(List<String> originalList, Integer maxChunkSize){
        List<List<String>> listOfChunks = new List<List<String>>();
        //Integer chunckMaxSize = 150; // Maximum size of each sublist
        List<String> chunkList = new List<String>();
        for(Integer i = 0; i < originalList.size(); i++) {
            chunkList.add(originalList[i]);
            if(chunkList.size() == maxChunkSize || i == originalList.size() - 1) {
                listOfChunks.add(new List<String>(chunkList));
                chunkList.clear();
            }
        }
        return listOfChunks;
    
    }
        /***************************************************************************************************** 
    Method Name   :        createEmailInstaceforHtmlBody    
    @parameters   :        
    Description   :        split the emailList into chunks 
    return        :        List of email chunks 
    Added By      :        Accenture - AN - 20/05/2024
    ******************************************************************************************************/
    public static List<Messaging.SingleEmailMessage> createEmailInstaceforHtmlBody(HtmlEmailParams htmlEmailParamsList){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        if(htmlEmailParamsList.userIds!=null){
            List<List<String>> userIdChunkList = new List<List<String>>();
            userIdChunkList = prepareListofChunks(htmlEmailParamsList.userIds,maxEmailChunksize); 
            for(List<String> userIdList:userIdChunkList){
                Messaging.SingleEmailMessage emailObjforAM = new Messaging.SingleEmailMessage();
                emailObjforAM.setToAddresses(userIdList);
                emailObjforAM.setTargetObjectId(htmlEmailParamsList.targetObjectId);
                emailObjforAM.setSaveAsActivity(false);
                emailObjforAM.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);//Label.Core_MDF_OrgWideId
                emailObjforAM.setSubject(htmlEmailParamsList.subject);
                emailObjforAM.setHTMLBody(htmlEmailParamsList.emailBody);
                emailsToSend.add(emailObjforAM);
                
            }
            
        }

        system.debug('emailsToSend@@@' + emailsToSend);
        return emailsToSend;
    
    }
    
    public class HtmlEmailParams {
        public List<String> userIds {get; set;} 
        public id userId { get; set; }
        public id recordId { get; set; }
        public string subject{ get; set; }
        public string emailBody { get; set; }
        public boolean saveAsActivity {get; set;}
        public string targetObjectId {get; set;}
        public string orgWideEmailAddressId { get; set; }
    } 
    }