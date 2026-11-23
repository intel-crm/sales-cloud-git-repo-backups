/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_Utility
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Utility Class for the object PRM_EmailLog__c 

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021          Added publish_Platform_Event method to Publish the Platform Event
* Neha Sharma                 13/02/2024          Updated the class to reduce cognitive complexity. Divided the method 'publishEmailLogDetails'
                                                  into smaller methods.
*******************************************************************************************************************************/
public with sharing class PRM_Email_Log_Utility{     
   
    public static void publishEmailLogDetails(List<PRM_EmailLog__c> logList, Map<Id, PRM_EmailLog__c> oldMap) {
    List<PRM_EmailLog__c> emaillogList = new List<PRM_EmailLog__c>();

    for (PRM_EmailLog__c emaillog : logList) {
        if (emaillog.PRM_Type__c == 'IPA' && shouldPublishEmailLog(emaillog, oldMap)) {
            emaillogList.add(emaillog);
        }
    }

    if (emaillogList != null && !emaillogList.isEmpty()) {
       
        publish_Platform_EventWrapper obj=new publish_Platform_EventWrapper();
        obj.republishList=emailLogList;
        obj.isRepublish=false;
        obj.platFormEventLogidList=null;
        obj.attemptList=null;
        publish_Platform_Event(obj);//Athr fixes
        //publish_Platform_Event(emaillogList, false, null, null);
    }
}

private static Boolean shouldPublishEmailLog(PRM_EmailLog__c emaillog, Map<Id, PRM_EmailLog__c> oldMap) {
    if (oldMap == null) {
        return true;
    }

    PRM_EmailLog__c oldEmailLog = oldMap.get(emaillog.Id);

    if (oldEmailLog == null) {
        return true;
    }

    return (emaillog.PRM_Read__c != oldEmailLog.PRM_Read__c || 
            emaillog.PRM_Is_Deleted__c != oldEmailLog.PRM_Is_Deleted__c) &&
           (emaillog.PRM_Updated_By_API__c == false || emaillog.PRM_IsEmailPublished__c == true);
}
    /*public static void publish_Platform_Event(List<PRM_EmailLog__c> republishList, boolean isRepublish,List<Id> platFormEventLogidList, List<Integer> attemptList) {
    List<Boolean> publishStatusList = new List<Boolean>();
    Boolean publishStatus = true;
    List<Core_Platform_Event_Log__c> platformEventLogList = new List<Core_Platform_Event_Log__c>();
    
    try {
        List<Core_Platform_Event_Bus__e> emailEventRecordList = buildEmailEventRecordList(republishList,platformEventLogList);
       
        List<Database.SaveResult> results = EventBus.publish(emailEventRecordList);
        
        for (Database.SaveResult sr : results) {
            publishStatusList.add(sr.isSuccess());
        }
    } catch (Exception e) {
        publishStatus = false; 
        Core_Log_Entry.logEntryWithException('PRM_Email_Log_Utility', 'IPA Registrations', 'PRM_Email_Log_Utility', 'Exception', '', '', '', '', '', e);
    } finally {
        updatePlatformEventLogs(platformEventLogList,publishStatusList, publishStatus, isRepublish, platFormEventLogidList, attemptList);
    }
}*/
        
    public class publish_Platform_EventWrapper{
    public List<PRM_EmailLog__c> republishList{get;set;}
    public boolean isRepublish{get;set;}
    public List<Id> platFormEventLogidList{get;set;}
    public List<Integer> attemptList{get;set;}
   }//JB
    
    public static void publish_Platform_Event(publish_Platform_EventWrapper att)
    {
    List<Boolean> publishStatusList = new List<Boolean>();
    Boolean publishStatus = true;
    List<Core_Platform_Event_Log__c> platformEventLogList = new List<Core_Platform_Event_Log__c>();
    
    try {
        List<Core_Platform_Event_Bus__e> emailEventRecordList = buildEmailEventRecordList(att.republishList,platformEventLogList);
        
        
       List<Database.SaveResult> results = EventBus.publish(emailEventRecordList);
    
       
        
        for (Database.SaveResult sr : results) {
            publishStatusList.add(sr.isSuccess());
        }
    } catch (Exception e) {
        publishStatus = false; 
        Core_Log_Entry.logEntryWithException('PRM_Email_Log_Utility', 'IPA Registrations', 'PRM_Email_Log_Utility', 'Exception', '', '', '', '', '', e);
    } finally {
        updatePlatformEventLogsWrapper obj=new updatePlatformEventLogsWrapper();
        obj.platformEventLogList=platformEventLogList;
        obj.publishStatusList=publishStatusList;
        obj.isRepublish=att.isRepublish;
        obj.publishStatus=publishStatus;
        obj.platFormEventLogidList=att.platFormEventLogidList;
        obj.attemptList=att.attemptList;
        updatePlatformEventLogs(obj);//Athr fixes
        //updatePlatformEventLogs(platformEventLogList,publishStatusList, publishStatus, att.isRepublish, att.platFormEventLogidList, att.attemptList);
    }
   }//Athr fixes
    
    
private static List<Core_Platform_Event_Bus__e> buildEmailEventRecordList(List<PRM_EmailLog__c> republishList,List<Core_Platform_Event_Log__c> platformEventLogList) {
    List<Core_Platform_Event_Bus__e> emailEventRecordList = new List<Core_Platform_Event_Bus__e>();
    EmailWrapper updatedwrap = new EmailWrapper();
    for (PRM_EmailLog__c emaillogs : republishList) {
        Core_Platform_Event_Bus__e emailEventRecord = new Core_Platform_Event_Bus__e();
                String catergoryID =System.Label.PRM_MyIntel_CatergoryID;
                String sourceOfMsg =System.Label.PRM_MyIntel_SourceOfMsg;
                String EmailContent = emaillogs.PRM_EmailContent__c;
                String EmailLogId  =emaillogs.Name;
                EmailContent= EmailContent.unescapeHTML4();
                updatedwrap.MessageId =emaillogs.Name;
                updatedwrap.MessageHeaderTxt =emaillogs.PRM_Subject__c;
                updatedwrap.MessageReadInd =emaillogs.PRM_Read__c;
                updatedwrap.MessageSummaryTxt =EmailContent;
                updatedwrap.MessageCategoryCd =catergoryID;
                updatedwrap.MessageDt = emaillogs.CreatedDate;
                updatedwrap.source =sourceOfMsg;
                updatedwrap.EmailId=emaillogs.PRM_ToEmailID__c;
                
                updatedwrap.EnterpriseId=emaillogs.PRM_EnterpriseId__c!=null ?emaillogs.PRM_EnterpriseId__c:null;
                updatedwrap.MessageDeleteInd=emaillogs.IsDeleted;
                String emailMsgInJsonFormat = JSON.serialize(updatedwrap);
                Object obj = JSON.deserializeUntyped(emailMsgInJsonFormat);
                String cleanJson = JSON.serialize(obj);
                
                
                
                //emailEventRecord.Core_Message__c = updatedwrap.toString();
                emailEventRecord.Core_Message__c = cleanJson;
                emailEventRecord.Core_IsActive__c =true;
                emailEventRecord.Core_Object_Type__c ='PRM_EmailLog__c';
                
                emailEventRecordList.add(emailEventRecord);

        
        if (!emaillogs.PRM_IsEmailPublished__c) {
            Core_Platform_Event_Log__c platformEventLog = buildPlatformEventLog(emaillogs.Name);
            platformEventLogList.add(platformEventLog);
        }
    }
    return emailEventRecordList;
}

private static Core_Platform_Event_Log__c buildPlatformEventLog(String emailLogId) {
    Core_Platform_Event_Log__c platformEventLog = new Core_Platform_Event_Log__c();
    platformEventLog.Core_Object_API_Name__c = 'PRM_EmailLog__c';
    platformEventLog.Core_Message__c = emailLogId;
    platformEventLog.Core_IsActive__c = true;
    platformEventLog.Core_Number_Of_Attempts__c = 0;
    return platformEventLog;
}

  /*private static void updatePlatformEventLogs(List<Core_Platform_Event_Log__c> platformEventLogList,List<Boolean> publishStatusList, Boolean publishStatus, boolean isRepublish, List<Id> platFormEventLogidList, List<Integer> attemptList) {
    List<String> failedRecordIds = new List<String>();
    List<String> toEmailAddressList = new List<String>();

    // Query Custom Setting for max number of attempts
    List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Number_Of_Attempts__c, Core_IPA_Support_Email_Address__c FROM Core_Platform_Event_Attempts__c LIMIT 1];

    // Add the status of records
    for (Integer idx = 0; idx < platformEventLogList.size(); idx++) {
        platformEventLogList[idx].Core_Status__c = !publishStatus ? 'failed' : (publishStatusList[idx] ? 'success' : 'failed');

        if (isRepublish) {
            platformEventLogList[idx].Core_Number_Of_Attempts__c = attemptList[idx] + 1;
            platformEventLogList[idx].Id = platFormEventLogidList[idx];

            Integer maxAttempts = 2;
            if (platFormEventAttempList != null && platFormEventAttempList.size() > 0 && platFormEventAttempList[0] != null && platFormEventAttempList[0].Core_Number_Of_Attempts__c != null) {
                maxAttempts = Integer.valueOf(platFormEventAttempList[0].Core_Number_Of_Attempts__c);
            }

            // Get ToEmail Address from custom settings
            if (platFormEventAttempList != null && platFormEventAttempList.size() > 0 && platFormEventAttempList[0] != null && platFormEventAttempList[0].Core_IPA_Support_Email_Address__c != null) {
                if ((platFormEventAttempList[0].Core_IPA_Support_Email_Address__c).contains(',')) {
                    List<String> unTrimmedToEmailAddressList = (platFormEventAttempList[0].Core_IPA_Support_Email_Address__c).split(',');
                    for (String unTrimmedToEmailAddress : unTrimmedToEmailAddressList) {
                        toEmailAddressList.add(unTrimmedToEmailAddress.trim());
                    }
                } else {
                    toEmailAddressList.add(platFormEventAttempList[0].Core_IPA_Support_Email_Address__c);
                }
            }

            if (Test.isRunningTest()) {
                platformEventLogList[idx].Core_Status__c = 'failed';
            }

            // If we are republishing a failed message again and if the max attempts are reached, then send an email to the Support Team
            if (platformEventLogList[idx].Core_Status__c == 'failed' && attemptList[idx] + 1 >= maxAttempts) {
                failedRecordIds.add(platformEventLogList[idx].Core_Message__c);
            }
        }
    }

    if (platformEventLogList.size() > 0 && (Schema.sObjectType.Core_Platform_Event_Log__c.isUpdateable() || Schema.sObjectType.Core_Platform_Event_Log__c.isCreateable())) {
        upsert platformEventLogList;
    }

    if (failedRecordIds != null && failedRecordIds.size() > 0) {
        sendEmailOnFailure(failedRecordIds, toEmailAddressList);
    }
}*/
    
    public class updatePlatformEventLogsWrapper{
        public List<Core_Platform_Event_Log__c> platformEventLogList{get;set;}
        public List<Boolean> publishStatusList{get;set;}
        public Boolean publishStatus{get;set;}
        public boolean isRepublish{get;set;}
        public List<Id> platFormEventLogidList{get;set;}
        public List<Integer> attemptList{get;set;}
    }//Athr fixes

    private static void updatePlatformEventLogs(updatePlatformEventLogsWrapper att) {
        List<String> failedRecordIds = new List<String>();
        List<String> toEmailAddressList = new List<String>();
    
        // Query Custom Setting for max number of attempts
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Number_Of_Attempts__c, Core_IPA_Support_Email_Address__c FROM Core_Platform_Event_Attempts__c LIMIT 1];
    
        // Add the status of records
        for (Integer idx = 0; idx < att.platformEventLogList.size(); idx++) {
            att.platformEventLogList[idx].Core_Status__c = !att.publishStatus ? 'failed' : (att.publishStatusList[idx] ? 'success' : 'failed');
    
            if (att.isRepublish) {
                att.platformEventLogList[idx].Core_Number_Of_Attempts__c = att.attemptList[idx] + 1;
                att.platformEventLogList[idx].Id = att.platFormEventLogidList[idx];
    
                Integer maxAttempts = 2;
                if (platFormEventAttempList != null && platFormEventAttempList.size() > 0 && platFormEventAttempList[0] != null && platFormEventAttempList[0].Core_Number_Of_Attempts__c != null) {
                    maxAttempts = Integer.valueOf(platFormEventAttempList[0].Core_Number_Of_Attempts__c);
                }
    
                // Get ToEmail Address from custom settings
                if (platFormEventAttempList != null && platFormEventAttempList.size() > 0 && platFormEventAttempList[0] != null && platFormEventAttempList[0].Core_IPA_Support_Email_Address__c != null) {
                    if ((platFormEventAttempList[0].Core_IPA_Support_Email_Address__c).contains(',')) {
                        List<String> unTrimmedToEmailAddressList = (platFormEventAttempList[0].Core_IPA_Support_Email_Address__c).split(',');
                        for (String unTrimmedToEmailAddress : unTrimmedToEmailAddressList) {
                            toEmailAddressList.add(unTrimmedToEmailAddress.trim());
                        }
                    } else {
                        toEmailAddressList.add(platFormEventAttempList[0].Core_IPA_Support_Email_Address__c);
                    }
                }
    
                if (Test.isRunningTest()) {
                    att.platformEventLogList[idx].Core_Status__c = 'failed';
                }
    
                // If we are republishing a failed message again and if the max attempts are reached, then send an email to the Support Team
                if (att.platformEventLogList[idx].Core_Status__c == 'failed' && att.attemptList[idx] + 1 >= maxAttempts) {
                    failedRecordIds.add(att.platformEventLogList[idx].Core_Message__c);
                }
            }
        }
    
        if (att.platformEventLogList.size() > 0 && (Schema.sObjectType.Core_Platform_Event_Log__c.isUpdateable() || Schema.sObjectType.Core_Platform_Event_Log__c.isCreateable())) {
            upsert att.platformEventLogList;
        }
    
        if (failedRecordIds != null && failedRecordIds.size() > 0) {
            sendEmailOnFailure(failedRecordIds, toEmailAddressList);
        }
    }
    
    //Send Email of Failure Record Id's to Support Team 
    public static void sendEmailOnFailure(List<Id> failedRecordIds, List<String> toEmailAddressList){   
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toEmailAddressList;
        message.setOrgWideEmailAddressId(owea.get(0).Id);
        message.optOutPolicy = 'FILTER';
        message.subject = 'SF to iPaaS Failure Record Notification';
        message.plainTextBody = 'Hi Everyone,';
        message.plainTextBody +='\n\nPlease find the details of failed records:';
        message.plainTextBody += '\nRecord Ids:'+failedRecordIds;
        message.plainTextBody += '\n\n\nThanks, \nIntel Support Team';
                
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            //System.debug('The email was sent successfully.');
        } else {
            //System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        
    }    
    
    /*
    public static boolean checkForIPAEmailTemplates(String templateName){
        boolean returnValue=false;
        try{
            List<String> IPAEmailtemplateList;            
        List<PRM_Email_Template_Names__mdt> emailTemplateRecords=[Select PRM_Email_Template_Names__c from PRM_Email_Template_Names__mdt Where Label='IPA Email Template Names'];       
        if(emailTemplateRecords!=null && emailTemplateRecords.size()>0 && emailTemplateRecords[0]!=null && emailTemplateRecords[0].PRM_Email_Template_Names__c!=null){
            IPAEmailtemplateList=(emailTemplateRecords[0].PRM_Email_Template_Names__c).split(',');
        }
        //System.debug('IPAEmailtemplateList'+IPAEmailtemplateList);
        if(IPAEmailtemplateList.contains(templateName)){
            returnValue =true;
        }  
        }Catch(Exception e){Core_Log_Entry.logEntryWithException('PRM_Email_Log_Utility', 'IPA Registrations', 'PRM_Email_Log_Utility', 'Exception','' ,'' , '', '', '',e);}
        return returnvalue;
    } 
    */   
    
    //Wrapper class to store EmailLog record details 
    public class EmailWrapper{ 
        public String MessageHeaderTxt;
        public boolean MessageReadInd;
        public String MessageSummaryTxt;
        public datetime MessageDt;
        public string source;
        public string MessageCategoryCd;
        public string MessageId;
        public string EmailId;
        public string EnterpriseId;
        public boolean MessageDeleteInd;
    } 
}