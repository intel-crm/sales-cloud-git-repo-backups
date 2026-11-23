/********************************************************************************************************************************************************************
Apex Class Name: Core_PCC_OpportunityReminderBatch
Version: 1.0
Created Date: 30/04/2024
Function: Batch class to send emails on delayed Opportunity approvals.

Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Chowdary Jahnavi 30/04/2024 Original Version developed
*******************************************************************************************************************************************************************/
public class Core_PCC_OpportunityReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    public static List<EmailTemplate> emailTemplate = [SELECT id,DeveloperName FROM EMailTemplate WHERE DeveloperName= 'Core_PCC_OppReminder30daysBeforeCloseDt'];
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date todayPlus30 = System.today().addDays(30);
        return Database.getQueryLocator([SELECT Id, Name, Core_Technical_Owner__c, OwnerId, Owner.Email , Core_Technical_Owner__r.Email FROM Opportunity
                                         WHERE Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c = 'Deal Registration' 
                                         AND CloseDate = :todayPlus30 AND StageName IN ('Qualify','Define','Develop','Design') and Core_Pending_Products__c > 0]);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<Id> allUserIds = new Set<Id>();
        Map<id, User> allActiveUsersMap = new Map<id,User>();
        Map<String,User> userIdMap = new Map<String,User>();
        Map<String,String> idAddressMap = new Map<String,String>();
        Map<String,User> contactIdUserMap = new Map<String,User>();
        List<PRM_EmailLog__c> prmEmailLogList = new List<PRM_EmailLog__c>();
        for(Opportunity opp : scope){
            allUserIds.add(opp.Core_Technical_Owner__c);
            allUserIds.add(opp.OwnerId);
        }
        
        allActiveUsersMap = new Map<id,User>([SELECT id,Name,Email,ContactId,Contact.Email FROM User WHERE Id IN :allUserIds AND IsActive=True]);
        if(emailTemplate.size() > 0){
            for(Opportunity opp : scope) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate[0].Id);
                email.settargetobjectid(opp.Core_Technical_Owner__c);
                email.setWhatId(opp.Id);
                email.setToAddresses(new List<String>{opp.Core_Technical_Owner__r.Email});
                email.setCcAddresses(new List<String>{opp.Owner.Email});
                email.setOrgWideEmailAddressId(fromEmailAddress);
                email.setSaveAsActivity(false);
                email.setTreatTargetObjectAsRecipient(false);
                emails.add(email);
            }
        }
        if(emails.size() > 0){
            try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            }
            catch(exception e){
                system.debug('exception e' +e);
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
    public void finish(Database.BatchableContext BC) {      
    }
}