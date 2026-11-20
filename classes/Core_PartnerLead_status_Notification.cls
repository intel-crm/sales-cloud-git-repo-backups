public without sharing class Core_PartnerLead_status_Notification {
    static public FINAL String emailTemplateName = 'Partner Lead Status Update Notification';
    static public FINAL String emailTemplateNamePLCL = 'Partner Lead Status Update- PLCL Notification';
    private static Id orgWideEmail;

    static {
        List<OrgWideEmailAddress> orgEmails = [
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Id = :System.Label.Core_SetFromEmailAddress
            LIMIT 1
        ];
        orgWideEmail = (!orgEmails.isEmpty()) ? orgEmails[0].Id : null;
    }

    private static Map<String, EmailTemplate> getEmailTemplates() {
        List<String> emailTemp = new List<String>();
        emailTemp.add(emailTemplateName);
        emailTemp.add(emailTemplateNamePLCL);
        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        List<EmailTemplate> emTmp = [SELECT Id, Name, Subject, Description, HtmlValue, DeveloperName, Body
                                    FROM EmailTemplate
                                    WHERE Name IN :emailTemp];

        for(EmailTemplate temp : emTmp){
            templateMap.put(temp.Name,temp);
        }
        return templateMap;
    }

    private static String buildEmailBody(EmailTemplate emailTemplate, EmailNotificationWrapper notification) {
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{User_Core_Leads_Accepted_Current_Year__c}', String.valueOf(notification.acceptedLeadIds.size() + notification.contactedLeadIds.size() + notification.qualifiedLeadIds.size()));
        htmlBody = htmlBody.replace('{User_Core_Leads_Contacted_Current_Year__c}', String.valueOf(notification.contactedLeadIds.size() + notification.qualifiedLeadIds.size()));
        htmlBody = htmlBody.replace('{User_Core_Leads_Generated_Current_Year__c}', String.valueOf(notification.generatedLeadIds.size()));
        htmlBody = htmlBody.replace('{User_Core_Leads_Qualified_Current_Year__c}', String.valueOf(notification.qualifiedLeadIds.size()));
        htmlBody = htmlBody.replace('{User_Core_Leads_Rejected_Current_Year__c}', String.valueOf(notification.rejectedLeadIds.size()));
        if (!notification.dispositionedLeadIds.isEmpty()) {
            htmlBody = htmlBody.replace('{User_Core_Leads_Dispositioned_Current_Year__c}', String.valueOf(notification.dispositionedLeadIds.size()));
        }
        htmlBody = htmlBody.replace('{Label_Core_Partner_Community}', System.Label.Core_Partner_Community);
        htmlBody = htmlBody.replace('{Year}', String.valueOf(System.Today().year()));
        return htmlBody;
    }

    // Parameter wrapper class to reduce method parameters
    private class EmailSendContext {
        public Map<Id, List<EmailNotificationWrapper>> notificationMap { get; set; }
        public Map<String, EmailTemplate> templateMap { get; set; }
        public List<PRM_EmailLog__c> emailLogList { get; set; }
        public Map<String, PRM_EmailLog__c> targetIdLog { get; set; }
        
        public EmailSendContext(Map<Id, List<EmailNotificationWrapper>> notificationMap, 
                               Map<String, EmailTemplate> templateMap, 
                               List<PRM_EmailLog__c> emailLogList, 
                               Map<String, PRM_EmailLog__c> targetIdLog) {
            this.notificationMap = notificationMap;
            this.templateMap = templateMap;
            this.emailLogList = emailLogList;
            this.targetIdLog = targetIdLog;
        }
    }

    private static void sendEmailsAndHandleErrors(EmailSendContext context) {
        Messaging.SingleEmailMessage mailToUser;
        List<Messaging.SingleEmailMessage> mailToUserList = new List<Messaging.SingleEmailMessage>();

        // Extract parameters from context for clarity
        Map<Id, List<EmailNotificationWrapper>> notificationMap = context.notificationMap;
        Map<String, EmailTemplate> templateMap = context.templateMap;
        Map<String, PRM_EmailLog__c> targetIdLog = context.targetIdLog;
        List<PRM_EmailLog__c> emailLogList = context.emailLogList;

        // Refactored to reduce cognitive complexity by extracting logic into smaller methods
        for (Id mpId : notificationMap.keySet()) {
            List<EmailNotificationWrapper> notifications = notificationMap.get(mpId);
            for (EmailNotificationWrapper notification : notifications) {
                // Extract email template based on dispositioned leads
                EmailTemplate emailTemplate = getTemplateForNotification(templateMap, notification);
                
                // Process each user for this notification
                for (Id u : notification.userId) {
                    // Create email message
                    mailToUser = createEmailMessage(emailTemplate, u);
                    
                    // Build email body
                    String htmlBody = buildEmailBody(emailTemplate, notification);
                    mailToUser.setHtmlBody(htmlBody);
                    mailToUser.setSubject(emailTemplate.Subject);

                    // Create email log entry
                    PRM_EmailLog__c emailLog = createEmailLogEntry(mailToUser, emailTemplate);
                    emailLogList.add(emailLog);

                    // Store reference for error handling
                    targetIdLog.put(String.valueOf(u), emailLog);
                    mailToUserList.add(mailToUser);
                }
            }
        }

        // Send emails and handle errors
        sendEmailsWithErrorHandling(mailToUserList, targetIdLog);
    }

    // Extracted method to get appropriate email template
    private static EmailTemplate getTemplateForNotification(Map<String, EmailTemplate> templateMap, EmailNotificationWrapper notification) {
        return notification.dispositionedLeadIds.size() == 0 ? 
               templateMap.get(emailTemplateName) : 
               templateMap.get(emailTemplateNamePLCL);
    }

    // Extracted method to create email message
    private static Messaging.SingleEmailMessage createEmailMessage(EmailTemplate emailTemplate, Id userId) {
        Messaging.SingleEmailMessage mailToUser = new Messaging.SingleEmailMessage();
        mailToUser.setSaveAsActivity(false);
        mailToUser.setTargetObjectId(userId);
        mailToUser.setOrgWideEmailAddressId(orgWideEmail);
        return mailToUser;
    }

    // Extracted method to create email log entry
    private static PRM_EmailLog__c createEmailLogEntry(Messaging.SingleEmailMessage mailToUser, EmailTemplate emailTemplate) {
        PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
        emailLog.PRM_EmailContent__c = mailToUser.getHtmlBody();
        emailLog.PRM_EmailDeliverabilityStatus__c = true;
        emailLog.Email_Template_ID__c = emailTemplate.Id;
        emailLog.Email_Template_Name__c = emailTemplate.Name;
        emailLog.PRM_Subject__c = mailToUser.getSubject();
        emailLog.PRM_Timestamp__c = DateTime.now();
        emailLog.PRM_Email_API_Response__c = 'Mail sent successfully !!';
        return emailLog;
    }

    // Extracted method to send emails and handle errors
    private static void sendEmailsWithErrorHandling(List<Messaging.SingleEmailMessage> mailToUserList, Map<String, PRM_EmailLog__c> targetIdLog) {
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(mailToUserList, false);
        for (Messaging.SendEmailResult result : resultList) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    String targetId = error.getTargetObjectId();
                    String errorMsg = error.getMessage();
                    if (targetId != null && targetIdLog.containsKey(targetId)) {
                        PRM_EmailLog__c log = targetIdLog.get(targetId);
                        log.PRM_EmailDeliverabilityStatus__c = false;
                        log.PRM_Email_API_Response__c = errorMsg;
                    }
                }
            }
        }
    }

    public static void sendEmailToUser(Map<Id, List<EmailNotificationWrapper>> notificationMap) {
        try {
            List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
            Map<String, PRM_EmailLog__c> targetIdLog = new Map<String, PRM_EmailLog__c>();
            
            Map<String, EmailTemplate> templateMap = getEmailTemplates();
            EmailSendContext context = new EmailSendContext(notificationMap, templateMap, emailLogList, targetIdLog);
            sendEmailsAndHandleErrors(context);
            
            insert as system emailLogList;
        } catch (Exception e) {
			Core_Log_Entry.logEntryWithDetails('Core_PartnerLead_status_Notification', 'Core_PartnerLeads_Count_Batch','sendEmailToUser','Medium',
                                               	'Failed to Send Email','Error Occurred While sending email to users : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');	

        }
    }

    public class EmailNotificationWrapper {
        public List<Id> userId { get; set; }
        public Set<String> generatedLeadIds { get; set; }
        public Set<String> acceptedLeadIds { get; set; }
        public Set<String> contactedLeadIds { get; set; }
        public Set<String> qualifiedLeadIds { get; set; }
        public Set<String> rejectedLeadIds { get; set; }
        public Set<String> dispositionedLeadIds { get; set; }
    
        public EmailNotificationWrapper(List<Id> userId, Set<String> generatedLeadIds, Set<String> acceptedLeadIds,
                                        Set<String> contactedLeadIds, Set<String> qualifiedLeadIds, Set<String> rejectedLeadIds,
                                        Set<String> dispositionedLeadIds) {
            this.userId = userId;
            this.generatedLeadIds = generatedLeadIds;
            this.acceptedLeadIds = acceptedLeadIds;
            this.contactedLeadIds = contactedLeadIds;
            this.qualifiedLeadIds = qualifiedLeadIds;
            this.rejectedLeadIds = rejectedLeadIds;
            this.dispositionedLeadIds = dispositionedLeadIds;
        }
    }
}