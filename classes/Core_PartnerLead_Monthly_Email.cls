public class Core_PartnerLead_Monthly_Email {
    static public Final String EmailTemplateName = 'Partner Lead Status Update Notification';
    private static Id orgWideEmail;
    static {
        List<OrgWideEmailAddress> orgEmails = [
            SELECT
            Id,Address
            FROM OrgWideEmailAddress
            WHERE Id = :System.Label.Core_SetFromEmailAddress
            LIMIT 1
        ];
        if (!orgEmails.isEmpty()) {
            orgWideEmail = orgEmails[0].Id;
        }
    }
    public static void sendEmailToUser(List<id> userListIds,Set<String> generatedLeadIds,Set<String> acceptedLeadIds,Set<String> contactedLeadIds,Set<String> qualifiedLeadIds,Set<String> rjectedLeadIds){
        try{
            EmailTemplate emailTemplate = [Select Id, Name, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where name =: EmailTemplateName];
            Messaging.SingleEmailMessage mailToUser;
            List<Messaging.SingleEmailMessage> mailToUserList = new List<Messaging.SingleEmailMessage>();
            if(userListIds != Null && !userListIds.isEmpty()){
                for(Id u : userListIds){
                    mailToUser =  new Messaging.SingleEmailMessage();
                    mailToUser.setSaveAsActivity(false);
                    //mailToUser.setToAddresses(userListIds);
                    mailToUser.setTargetObjectId(u);
                    mailToUser.setOrgWideEmailAddressId(orgWideEmail);
                    String htmlBody = emailTemplate.HtmlValue;
                    /*String CoreLeadsAcceptedCurrentYear = u.Core_Leads_Accepted_Current_Year__c != Null ? string.valueof(u.Core_Leads_Accepted_Current_Year__c): '';
                    String CoreLeadsContactedCurrentYear = u.Core_Leads_Contacted_Current_Year__c != Null ? string.valueof(u.Core_Leads_Contacted_Current_Year__c): '';
                    String LeadsGeneratedCurrentYear = u.Core_Leads_Generated_Current_Year__c != Null ? string.valueof(u.Core_Leads_Generated_Current_Year__c): '';
                    String LeadsQualifiedCurrentYear = u.Core_Leads_Qualified_Current_Year__c != Null ? string.valueof(u.Core_Leads_Qualified_Current_Year__c): '';
                    String LeadsRejectedCurrentYear = u.Core_Leads_Rejected_Current_Year__c != Null ? string.valueof(u.Core_Leads_Rejected_Current_Year__c): '';*/
                    
                    htmlBody = htmlBody.replace('{User_Core_Leads_Accepted_Current_Year__c}', String.valueof(acceptedLeadIds.size()));
                    htmlBody = htmlBody.replace('{User_Core_Leads_Contacted_Current_Year__c}', String.valueof(contactedLeadIds.size()));
                    htmlBody = htmlBody.replace('{User_Core_Leads_Generated_Current_Year__c}', String.valueof(generatedLeadIds.size()));
                    htmlBody = htmlBody.replace('{User_Core_Leads_Qualified_Current_Year__c}', String.valueof(qualifiedLeadIds.size()));
                    htmlBody = htmlBody.replace('{User_Core_Leads_Rejected_Current_Year__c}', String.valueof(rjectedLeadIds.size()));
                    htmlBody = htmlBody.replace('{Label_Core_Partner_Community}', System.Label.Core_Partner_Community);
                    htmlBody = htmlBody.replace('{Year}', String.valueOf(System.Today().year()));
                    mailToUser.setHtmlBody(htmlBody);
                    mailToUser.setSubject(emailTemplate.Subject);
                    mailToUserList.add(mailToUser);
                }
                //Messaging.sendEmail(mailToUserList);
                
                List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(mailToUserList, false);
                
                List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
                for(Messaging.SingleEmailMessage mail : mailToUserList){
                    PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
                    emailLog.PRM_EmailContent__c = mail.getHtmlBody();
                    emailLog.PRM_EmailDeliverabilityStatus__c = true;
                    emailLog.Email_Template_ID__c = emailTemplate.Id;
                    emailLog.Email_Template_Name__c = emailTemplate.Name;
                    emailLog.PRM_Subject__c = mail.getSubject();
                    emailLog.PRM_Timestamp__c = DateTime.now();
                    //emailLog.PRM_User__c = mail.getToAddresses()[0];
                    emailLog.PRM_Email_API_Response__c = 'Mail sent successfully !!';
                    emailLogList.add(emailLog);
                }
                
                Map<String,PRM_EmailLog__c> targetIdLog = new Map<String,PRM_EmailLog__c>();
                for(PRM_EmailLog__c emailLog : emailLogList){
                    targetIdLog.put(emailLog.PRM_User__c, emailLog);
                }
                
                for(Messaging.SendEmailResult result : resultList){
                    if(!result.isSuccess()){
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
                insert emailLogList;
                
            }
        }catch(Exception e){
            system.debug('Email failed' + e.getLineNumber()+ e.getMessage());
        }
    }
}