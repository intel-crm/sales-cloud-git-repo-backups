public without sharing class SendEmailNotification {
    public static void sendNotification(List<Id> approvalIds, String orgWideEmailAddress, String emailTemplateName) {
        if (approvalIds.isEmpty() || String.isBlank(orgWideEmailAddress) || String.isBlank(emailTemplateName)) {
            return;
        }
    
        Map<Id, String> failedEmails = new Map<Id, String>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideEmailAddress LIMIT 1];
    
        List<sbaa__Approval__c> approvals = [
            SELECT Id, OwnerId, sbaa__AssignedTo__r.Email, sbaa__Approver__r.sbaa__GroupId__c
            FROM sbaa__Approval__c WHERE Id IN :approvalIds
        ];
    
        Map<Id, List<String>> groupEmailsMap = getGroupEmails(approvals);
    
        for (sbaa__Approval__c approval : approvals) {
            List<String> recipientEmails = new List<String>();
    
            if (approval.sbaa__AssignedTo__r.Email != null) {
                recipientEmails.add(approval.sbaa__AssignedTo__r.Email);
            } else if (groupEmailsMap.containsKey(approval.sbaa__Approver__r.sbaa__GroupId__c)) {
                recipientEmails.addAll(groupEmailsMap.get(approval.sbaa__Approver__r.sbaa__GroupId__c));
            }
    
            if (!recipientEmails.isEmpty()) {
                emailsToSend.add(constructEmailMessage(approval, recipientEmails, emailTemplate.Id, orgWideEmail.Id));
            }
        }
    
        if (!emailsToSend.isEmpty()) {
            sendEmails(emailsToSend, failedEmails);
        }
    
        logFailedEmails(failedEmails);
    }
    
    private static Map<Id, List<String>> getGroupEmails(List<sbaa__Approval__c> approvals) {
        Set<Id> groupIds = new Set<Id>();
        Map<Id, List<String>> groupEmailsMap = new Map<Id, List<String>>();
    
        for (sbaa__Approval__c approval : approvals) {
            if (approval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                groupIds.add(approval.sbaa__Approver__r.sbaa__GroupId__c);
            }
        }
    
        if (!groupIds.isEmpty()) {
            for (GroupMember groupMember : [
                SELECT GroupId, UserOrGroup.Email
                FROM GroupMember WHERE GroupId IN :groupIds AND UserOrGroup.IsActive = true
            ]) {
                if (!groupEmailsMap.containsKey(groupMember.GroupId)) {
                    groupEmailsMap.put(groupMember.GroupId, new List<String>());
                }
                groupEmailsMap.get(groupMember.GroupId).add(groupMember.UserOrGroup.Email);
            }
        }
    
        return groupEmailsMap;
    }
    
    private static Messaging.SingleEmailMessage constructEmailMessage(sbaa__Approval__c approval, List<String> recipientEmails, Id templateId, Id orgWideEmailId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);
        email.setTargetObjectId(approval.OwnerId);
        email.setTreatTargetObjectAsRecipient(false);
        email.setWhatId(approval.Id);
        email.setOrgWideEmailAddressId(orgWideEmailId);
        email.setToAddresses(recipientEmails);
        email.setSaveAsActivity(false);
    
        return email;
    }
    
    private static void sendEmails(List<Messaging.SingleEmailMessage> emailsToSend, Map<Id, String> failedEmails) {
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailsToSend, false);
    
        for (Messaging.SendEmailResult result : emailResults) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    failedEmails.put(error.getTargetObjectId(), error.getMessage());
                }
            }
        }
    }
    
    private static void logFailedEmails(Map<Id, String> failedEmails) {
        if (!failedEmails.isEmpty()) {
            PSG_Utility.createCoreLogEntry(
                'SendEmailNotification',
                'SendEmailNotification',
                'Email sending failed for the following approvals:',
                failedEmails.toString(),
                'sbaa__Approval__c',
                'High',
                ''
            );
        }
    }    
}