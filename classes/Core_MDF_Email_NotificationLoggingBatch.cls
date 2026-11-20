/****************************************************************************************************************************************
* Class Name        : Core_MDF_Email_NotificationLoggingBatch
* Test Class Name   : Core_MDF_PIC_Completion_NotifyBatch_Test
* Created Date      : 13/03/2024
* Description       : Batch for sending email and logging entries
* Developer         : Aditya
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Email_NotificationLoggingBatch implements Database.Batchable<EmailLogDetailsWrap> , Database.Stateful{
    //wrapper list to collect both internal and external users
    public List<EmailLogDetailsWrap> emailLogWrapList = new List<EmailLogDetailsWrap>();
    // Email template to send mail
    EmailTemplate template; 
    Set<Id> intUserIdList = new Set<Id>();
    Set<Id> extUserIdList = new Set<Id>();
    string templateName = '';
    String objName = '';
    String notificationType = '';
    public Core_MDF_Email_NotificationLoggingBatch(Set<Id> intUserIdList , Set<Id> extUserIdList , string templateName, String objName){
        this.intUserIdList = intUserIdList;
        this.extUserIdList = extUserIdList;
        this.templateName = templateName;
        this.objName = objName;
    }
    public Iterable<EmailLogDetailsWrap> start(Database.BatchableContext bc) {
        if(templateName!= Null){
            string query = '';
            query = 'SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = : templateName LIMIT 1';
            template = Database.query(String.escapeSingleQuotes(query));            
        }
        if(intUserIdList != null && intUserIdList.size()> 0){
            //Akanksha - Subscription Notification
            //Avoid Deeply Nested IF Statements
                if(templateName != Null && objName != Null && objName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObject_Case') && templateName == Core_MDF_CCP_ConstantClass.ClaimScore_Notification){
                    notificationType =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Weekly_Claim_Score'); 
                }
                else if(templateName != Null && objName != Null && objName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObjectClaim') && (templateName == Core_MDF_CCP_ConstantClass.PIC_Completed_Notification || templateName == Core_MDF_CCP_ConstantClass.PIC_Completed_IPA_OutcomeBased_Notification)){
                    notificationType =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Weekly_PIC_Completion_Notify'); //  indu 
                }
                else if(templateName != Null && objName != Null && objName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObjectClaim') && templateName == Core_MDF_CCP_ConstantClass.Paid_Claims_Notification){
                    notificationType =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Weekly_Paid_Claims_Notifiy');
                }
            List<Id> subscribedUserIdList = Core_MDF_SubUnsub_Notifications_Utility.filterUserBasedOnSubscription(notificationType,objName,intUserIdList);
            if(!subscribedUserIdList.isEmpty() && subscribedUserIdList.size() > 0){
                //adding internal users to iterable wrap list
                for(Id usr : subscribedUserIdList) {
                    EmailLogDetailsWrap emailLogWrap= new EmailLogDetailsWrap();
                    emailLogWrap.usrId = usr;
                    emailLogWrapList.add(emailLogWrap);
                } 
            }
        }
        if(extUserIdList != null && extUserIdList.size()> 0){
            //adding external users to iterable wrap list
            for(Id usr : extUserIdList) {
                EmailLogDetailsWrap emailLogWrap= new EmailLogDetailsWrap();
                emailLogWrap.usrId = usr;
                emailLogWrapList.add(emailLogWrap);
            }
        }
        return emailLogWrapList;
    }
    Public void execute(Database.BatchableContext bc, List<EmailLogDetailsWrap> EmailLogsWraps) {
        List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
        if( EmailLogsWraps != null && EmailLogsWraps.size() > 0){
            //creating SingleEmailMessage list for each user
            for(EmailLogDetailsWrap emailLogWrap : EmailLogsWraps){
                emailTosendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(emailLogWrap.usrId,template.id,emailLogWrap.usrId));
            }
            
            List<Messaging.SendEmailResult> res;
            //sending emails
            if( emailTosendList != null && emailTosendList.size() > 0){
                res = Messaging.sendEmail(emailTosendList, false);
                logEmails(emailTosendList,res);
            }
        }
    }
    Public void finish(Database.BatchableContext bc) {
    }
    public class EmailLogDetailsWrap{
        public Id usrId;
    }
    Public static  List<Core_Log_Entry__c> generateLogEntryInstance(List<Messaging.SingleEmailMessage> emailTosendList,List<Messaging.SendEmailResult> res ){
        List<Core_Log_Entry__c> logEntryObjList = new List<Core_Log_Entry__c>();
                    // iterate over SingleEmailMessage list to create wrapper with details needed for logging
                    for(integer index = 0 ; index <emailTosendList.size() ; index++ ){
                        Core_Log_Entry__c logEntryObj = new Core_Log_Entry__c();
                        Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper wrap = new Core_MDF_GenericClassToSendMail.EmailLogDetailsWrapper();
                        if(res[index].isSuccess()){
                            wrap.EmailDeliverabilityStatus = Core_MDF_CCP_ConstantClass.strSuccess;  
                            wrap.errorMessage = ''; 
                        }
                        else{
                            string errMsg =''; 
                            for( Messaging.SendEmailError error : res[index].getErrors()) {
                                errMsg += error.getMessage() + ','; 
                            }
                            wrap.errorMessage = errMsg;
                            wrap.EmailDeliverabilityStatus = Core_MDF_CCP_ConstantClass.strFailed;
                        }
                        wrap.sObjectId = emailTosendList[index].getWhatId();                
                        wrap.fromEmailId = emailTosendList[index].getOrgWideEmailAddressId();
                        wrap.toEmailId = '';
                        if(emailTosendList[index].getToAddresses() != null && !emailTosendList[index].getToAddresses().isEmpty()){
                            string toEmail = string.join(emailTosendList[index].getToAddresses(),';');
                            wrap.toEmailId = toEmail;
                        }
                        else if(emailTosendList[index].getTargetObjectId() != null){
                            wrap.toEmailId = emailTosendList[index].getTargetObjectId();
                        }                
                        wrap.templateName = emailTosendList[index] != null ? emailTosendList[index].getTemplateName() : '';
                        wrap.templateValue = emailTosendList[index] != null ? (emailTosendList[index].getHtmlBody()).stripHtmlTags() : '';                    
                        logEntryObj = Core_MDF_GenericClassToSendMail.createEmailLogInstance(wrap);
                        logEntryObjList.add(logEntryObj);
                    }
        return logEntryObjList;
    } 
    Public static void logEmails(List<Messaging.SingleEmailMessage> emailTosendList,List<Messaging.SendEmailResult> res ){
        // switch to bypass pic  notification email logging
                if(!Core_MDF_Utility.byPassFeature('Bypass_NotificationEmailLogging')){
                    List<Core_Log_Entry__c> logEntryObjList = new List<Core_Log_Entry__c>();
                    logEntryObjList = generateLogEntryInstance(emailTosendList,res);
                    //inserting log entry records
                    try{
                    if(logEntryObjList != null && logEntryObjList.size() > 0){
                        database.insert(logEntryObjList);
                    }
                    }
                    catch(exception ex){
                        Core_MDF_CCP_UtilityClass.logError(ex);
                    }
                }
    }
}