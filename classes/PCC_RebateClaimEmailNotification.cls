/********************************************************************************************************************************************************************
Apex Class Name: PCC_RebateClaimEmailNotification
Version: 1.0
Created Date: 15/07/2024
Function: Rebate Claim Email Notification Generic method
Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Shijas KM 15/07/2024 Original Version developed
*******************************************************************************************************************************************************************/
public without sharing class PCC_RebateClaimEmailNotification {    
    public static void SendEmail(string emailTemplateName,  List<string> toEmailAddress, List<string> ccEmailAddress,   Id rebateClaimId){
       
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try
        { 
            Map<id, User> allActiveUsersMap = new Map<id,User>();
            Set<String> toEmailSet = new Set<String>(toEmailAddress);            
            String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
            List<EmailTemplate> emailTemplate = [SELECT id,DeveloperName FROM EMailTemplate WHERE DeveloperName= :emailTemplateName];
            List<PCC_Rebate_Claim__c> lstRebate_Claim = [SELECT id, OwnerId , PCC_Approved_By__c, PCC_Submitted_By__c FROM PCC_Rebate_Claim__c WHERE Id= :rebateClaimId];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();       
            Set<Id> allUserIds = new Set<Id>();
            Map<String,User> userIdMap = new Map<String,User>();
            Map<String,String> idAddressMap = new Map<String,String>();
            Map<String,User> contactIdUserMap = new Map<String,User>();
            List<PRM_EmailLog__c> prmEmailLogList = new List<PRM_EmailLog__c>(); 
            allUserIds.add(lstRebate_Claim[0].PCC_Approved_By__c);
            allUserIds.add(lstRebate_Claim[0].PCC_Submitted_By__c);
           	allActiveUsersMap = new Map<id,User>([SELECT id,Name,Email,ContactId,Contact.Email FROM User WHERE Id IN :allUserIds AND IsActive=True]);
            if(emailTemplate.size() > 0){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate[0].Id);
                email.settargetobjectid(lstRebate_Claim[0].OwnerId);
                email.setWhatId(lstRebate_Claim[0].Id);
                email.setToAddresses(new List<String>(toEmailSet));
                if (ccEmailAddress!= null && !ccEmailAddress.IsEmpty() && ccEmailAddress.Size() > 0 )
                {
                    Set<String> ccEmailSet = new Set<String>(ccEmailAddress);
                    email.setCcAddresses(new List<String>(ccEmailSet));
                }
                
                email.setOrgWideEmailAddressId(fromEmailAddress);
                email.setSaveAsActivity(false);
                email.setTreatTargetObjectAsRecipient(false);
                emails.add(email);
            }
            if(emails.size() > 0){
                try{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                  
                }
                catch(exception e){
                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage() + ' StackTraceString --->' + e.getStackTraceString() , Core_Origin__c='PCC_RebateClaimEmailNotification.SendEmail', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
                }
            }       
            for(Messaging.SingleEmailMessage mail  : emails ){
                for(user usr:allActiveUsersMap.values()){
                    userIdMap.put(mail.getTargetObjectId(),usr);
                    idAddressMap.put(mail.getTargetObjectId(),usr.Contact.Email);
                    contactIdUserMap.put(usr.ContactId,usr);
                    prmEmailLogList.addAll(PRM_EmailUtility.createEmailLogsBasedOnType(mail,'Sales CRM',idAddressMap,contactIdUserMap,userIdMap,'English',emailTemplate[0].DeveloperName));
                }
            } 
            if(prmEmailLogList.size() > 0){
                insert prmEmailLogList;
            }
        }
        catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage() + ' StackTraceString --->' + e.getStackTraceString(), Core_Origin__c='PCC_RebateClaimEmailNotification.SendEmail', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));   
            
        }
        finally{ insert logEntries;}
    }    
}