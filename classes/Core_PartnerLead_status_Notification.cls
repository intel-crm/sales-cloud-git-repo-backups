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

    public static void sendEmailToUser(Map<Id, List<EmailNotificationWrapper>> notificationMap) {
        try {
            List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
            Map<String, PRM_EmailLog__c> targetIdLog = new Map<String, PRM_EmailLog__c>();
            List<String> emailTemp = new List<String>();
            emailTemp.add(emailTemplateName);
            emailTemp.add(emailTemplateNamePLCL);
            Map<String, EmailTemplate> templateMap = new Map<String, emailTemplate>();
            List<EmailTemplate> emTmp = [SELECT Id, Name, Subject, Description, HtmlValue, DeveloperName, Body
                                                    FROM EmailTemplate
                                                    WHERE Name IN :emailTemp];

            for(EmailTemplate temp : emTmp){
                templateMap.put(temp.Name,temp);
            }

            Messaging.SingleEmailMessage mailToUser;
            List<Messaging.SingleEmailMessage> mailToUserList = new List<Messaging.SingleEmailMessage>();

            for (Id mpId : notificationMap.keySet()) {
                List<EmailNotificationWrapper> notifications = notificationMap.get(mpId);
				for (EmailNotificationWrapper notification : notifications) {
                    for (Id u : notification.userId) {
                        EmailTemplate emailTemplate = notification.dispositionedLeadIds.size() == 0 ? templateMap.get(emailTemplateName) : templateMap.get(emailTemplateNamePLCL);
                        mailToUser = new Messaging.SingleEmailMessage();
                        mailToUser.setSaveAsActivity(false);
                        mailToUser.setTargetObjectId(u);
                        mailToUser.setOrgWideEmailAddressId(orgWideEmail);
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
                        mailToUser.setHtmlBody(htmlBody);
                        mailToUser.setSubject(emailTemplate.Subject);

                        PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
                        emailLog.PRM_EmailContent__c = mailToUser.getHtmlBody();
                        emailLog.PRM_EmailDeliverabilityStatus__c = true;
                        emailLog.Email_Template_ID__c = emailTemplate.Id;
                        emailLog.Email_Template_Name__c = emailTemplate.Name;
                        emailLog.PRM_Subject__c = mailToUser.getSubject();
                        emailLog.PRM_Timestamp__c = DateTime.now();
                        emailLog.PRM_Email_API_Response__c = 'Mail sent successfully !!';
                        emailLogList.add(emailLog);

                        targetIdLog.put(u, emailLog);
                        mailToUserList.add(mailToUser);
                    }
                }
            }

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