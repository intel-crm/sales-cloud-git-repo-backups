/******************************************************************************************************
Apex Class Name : PSG_QuoteApprovalRejectionEmailAlerts
Version         : 1.0 
Created Date    : 11/16/2022
Function        : This class is to be used to send Quote Approval & Rejection Email to Owner Delegate.
Modifications   :
*******************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh Parashar             11/16/2022             Created
*******************************************************************************************************/
@isTest
public without sharing class PSG_QuoteApprovalRejectionEmailAlerts {
    /*@InvocableMethod(label='Quote Approval/Rejection email alerts' category='sbaa__Approval__c')
    public static void getApprovalId(List<ID> approvalId){
        List<sbaa__Approval__c> apprList = new List<sbaa__Approval__c>();
        Map<Id,Set<String>> userTodelegatedUserMap = PSG_QuoteEmailAlerts.getAllDelegatedUsers();
        List<Messaging.SingleEmailMessage> mails=new List<Messaging.SingleEmailMessage>();
        List<sbaa__Approval__c> getapprovals = [Select id,sbaa__Status__c,Quote__r.core_cpq_requestor_nm__r.Email,Quote__r.OwnerId,Quote__r.owner.email, Quote__r.SBQQ__Status__c from sbaa__Approval__c where id in :approvalId];
        //Changes made by Bishal Singh
        Map<String,List<String>> relatedValues = new Map<String,List<String>>();
        List<String> relatedToId = new List<String>();
        List<String> subject = new List<String>(); 
        List<String> htmlBody = new List<String>();
        Set<String> toAddress = new Set<String>();
        OrgWideEmailAddress orgWideEmailAdd = [Select Id,Address,DisplayName from OrgWideEmailAddress where address='wsm-postmaster@intel.com' Limit 1];
        
        EmailTemplate activetempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_Quote_Approval_Notification'];
        EmailTemplate activetempId1 = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_CP_Quote_Reject_Notification'];
        
        if(getapprovals[0].sbaa__Status__c == 'Approved'){
            apprList = [Select id,sbaa__Status__c from sbaa__Approval__c where Quote__c = :getapprovals[0].Quote__c and sbaa__Status__c In ('Requested','Assigned')]; 
        }
        String templateId = '';
        if(getapprovals[0].sbaa__Status__c == 'Approved' && apprList.isEmpty()){
            templateId = activetempId.Id;
        }else if(getapprovals[0].sbaa__Status__c == 'Rejected'){
            templateId = activetempId1.Id;
        }
        if(!String.isBlank(templateId)){
        Messaging.SingleEmailMessage mail1 = Messaging.renderStoredEmailTemplate(templateId, null,getapprovals[0].Id);
        for(sbaa__Approval__c appr: getapprovals){
                Set<String> toAddresses = new Set<String>();
                //if(appr.Quote__r?.core_cpq_requestor_nm__r?.Email != null)
                //toAddresses.add(appr.Quote__r.core_cpq_requestor_nm__r.Email);
                if(appr.Quote__r?.owner?.Email != null){
                    toAddresses.add(appr.Quote__r.owner.Email);
                    toAddress.add(appr.Quote__r.owner.Email);
                }
                if(userTodelegatedUserMap.containsKey(appr.Quote__r.ownerId)){
                    toAddresses.addAll(userTodelegatedUserMap.get(appr.Quote__r.ownerId)); 
                    toAddress.addAll(userTodelegatedUserMap.get(appr.Quote__r.ownerId)); 
                }
                mail1.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
                mail1.setToAddresses(new List<String>(toAddresses));
                mail1.setSaveAsActivity(false);
                mails.add(mail1);
                relatedToId.add(getapprovals[0].Id);
                subject.add(mail1.getSubject());
                htmlBody.add(mail1.getHtmlBody());
            }
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
            relatedValues.put('relatedToId',relatedToId);
            relatedValues.put('subject',subject);
            relatedValues.put('htmlBody',htmlBody);
            //PSG_EmailMessageLog.createEmailMessageRecord(relatedValues,orgWideEmailAdd.Address,orgWideEmailAdd.DisplayName,new String[]{},
            //                                             new List<String>(toAddress),null,null);
        }
    }*/
}