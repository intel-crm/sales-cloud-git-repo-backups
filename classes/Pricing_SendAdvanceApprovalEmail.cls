public without sharing class Pricing_SendAdvanceApprovalEmail {
    public static void sendNotification(List<Id> approvalIds, String orgWideEmailAddress, String emailTemplateName) {
        // Validate inputs
        if (approvalIds.isEmpty() || String.isBlank(orgWideEmailAddress) || String.isBlank(emailTemplateName)) {
            return;
        }
    
        Map<Id, String> failedEmails = new Map<Id, String>();// Map to store any failed email sends with the related error message
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];// Fetch the email template by DeveloperName
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideEmailAddress LIMIT 1]; // Fetch the Org-Wide Email Address to be used as the sender
    
        // Query for approval records and associated email details
        List<sbaa__Approval__c> approvals = [
            SELECT Id, OwnerId, sbaa__AssignedTo__r.Email, sbaa__Approver__r.sbaa__GroupId__c, 
                   Quote__r.Pricing_Quote_Program_Nm__c, sbaa__ApprovalStep__c, sbaa__Status__c, Quote__r.Owner.Email
            FROM sbaa__Approval__c 
            WHERE Id IN :approvalIds
        ];
    
        Map<Id, List<String>> groupEmailsMap = getGroupEmails(approvals);
        for (sbaa__Approval__c approval : approvals) {
            // Handle the specific logic for 'Software & Services'
            if (approval.Quote__r.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software) {
                handleSoftwareAndServices(approval, emailsToSend, emailTemplate.Id, orgWideEmail.Id);
            } else {                
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
        }
    
        if (!emailsToSend.isEmpty()) {
            sendEmails(emailsToSend, failedEmails);
        }

        // Log errors if any
        //logFailedEmails(failedEmails);
    }
    
    private static void handleSoftwareAndServices(sbaa__Approval__c approval, List<Messaging.SingleEmailMessage> emailsToSend, Id templateId, Id orgWideEmailId) {
        // Query all approval steps for the same quote with the program type 'Software & Services'
        List<sbaa__Approval__c> relatedApprovals = [
            SELECT sbaa__ApprovalStep__c, sbaa__AssignedTo__r.Email, sbaa__Status__c, OwnerId
            FROM sbaa__Approval__c
            WHERE Quote__r.Pricing_Quote_Program_Nm__c = :Label.Pricing_Program_Code_Software
            AND Quote__r.Id = :approval.Quote__r.Id
        ];       
        
        // Find the maximum approval step
        Decimal maxApprovalStep = 0;
        for (sbaa__Approval__c relatedApproval : relatedApprovals) {
            if (relatedApproval.sbaa__ApprovalStep__c > maxApprovalStep) {
                maxApprovalStep = relatedApproval.sbaa__ApprovalStep__c;
            }
        }
        List<sbaa__Approval__c> approvals = [
            SELECT Id, OwnerId, sbaa__AssignedTo__r.Email, sbaa__Approver__r.sbaa__GroupId__c, 
                   Quote__r.Pricing_Quote_Program_Nm__c, sbaa__ApprovalStep__c, sbaa__Status__c
            FROM sbaa__Approval__c 
            WHERE Id = :approval.Id
        ];
        Map<Id, List<String>> groupEmailsMap = getGroupEmails(approvals);
        
        // Check approval status of the maximum approval step
        if (approval.sbaa__Status__c == Label.Pricing_SW_QuoteStatusApproved) {
            if (approval.sbaa__ApprovalStep__c == maxApprovalStep) {    
                // Send email to the quote owner
                Messaging.SingleEmailMessage email = constructEmailMessage(approval, new List<String>{approval.Quote__r.Owner.Email}, templateId, orgWideEmailId);
                emailsToSend.add(email);
            }
        }
        else if (approval.sbaa__Status__c == Label.Pricing_SW_QuoteStatusRejected){
            // Send email to the quote owner
            Messaging.SingleEmailMessage email = constructEmailMessage(approval, new List<String>{approval.Quote__r.Owner.Email}, templateId, orgWideEmailId);
            emailsToSend.add(email);
        }
        else if (approval.sbaa__Status__c == Label.Pricing_SW_QuoteApprovalStatusRecalled || approval.sbaa__Status__c == Label.Pricing_SW_Requested) {
            // Send email to the assigned owner

            if (approval.sbaa__AssignedTo__r.Email != null) {
                Messaging.SingleEmailMessage email = constructEmailMessage(approval, new List<String>{approval.sbaa__AssignedTo__r.Email}, templateId, orgWideEmailId);
                If(approval.sbaa__Status__c == Label.Pricing_SW_Requested){
                    email.setReplyTo(Label.Pricing_SW_ReplyToEmailAddress);
                }
                emailsToSend.add(email);                   
            } else if (groupEmailsMap.containsKey(approval.sbaa__Approver__r.sbaa__GroupId__c)) {

                Messaging.SingleEmailMessage email = constructEmailMessage(approval, groupEmailsMap.get(approval.sbaa__Approver__r.sbaa__GroupId__c), templateId, orgWideEmailId);
                If(approval.sbaa__Status__c == Label.Pricing_SW_Requested){
                    email.setReplyTo(Label.Pricing_SW_ReplyToEmailAddress);
                }
                emailsToSend.add(email);
            }               
        }           
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
            // Query for active group members if group IDs are present
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

    // Create email messages for each approval

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
    
    // Send emails if there are any to send
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
    
    // Log any failed email sends
    /*private static void logFailedEmails(Map<Id, String> failedEmails) {
        if (!failedEmails.isEmpty()) {
            PSG_Utility.createCoreLogEntry(
                'Pricing_SendAdvanceApprovalEmail',
                'SendNotification',
                'Email sending failed for the following approvals:',
                failedEmails.toString(),
                'sbaa__Approval__c',
                'High',
                ''
            );
        }
    }*/    
}