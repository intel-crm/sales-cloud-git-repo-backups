/****************************************************************************************************
Apex Class Name : PSG_ApprovalEmailNotification
Version         : 1.0 
Created Date    : 08/29/2024
Function        : Send Email Notification to Requested and Recalled Approval records.
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                  08/29/2024                 Created
*****************************************************************************************************/
public without sharing class PSG_ApprovalEmailNotification {
    
    public static void sendApprovalNotification(List<Id> apprIdList,string orgWideEmailAddress,string emailTempDevName){
        Map<Id,String> failemailMap = new Map<Id,String>();
        if(!apprIdList.isempty() && !String.isBlank(orgWideEmailAddress) && !String.isBlank(emailTempDevName)){
            List<Messaging.SingleEmailMessage> mails=new List<Messaging.SingleEmailMessage>();
            EmailTemplate activetempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName =: emailTempDevName];
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:orgWideEmailAddress LIMIT 1];
            Set<Id> apprGrpIdSet=new Set<Id>();
            Map<String,List<String>> grpIdToEmailsMap=new Map<String,List<String>>();
            List<sbaa__Approval__c> apprList=[Select id,ownerId,sbaa__AssignedTo__c,sbaa__Approver__c,sbaa__AssignedTo__r.Email,sbaa__Approver__r.sbaa__GroupId__c from sbaa__Approval__c where id in:apprIdList];
            for(sbaa__Approval__c app :apprList){
                if(app.sbaa__AssignedTo__c == null && app.sbaa__Approver__r?.sbaa__GroupId__c != null){
                    apprGrpIdSet.add(app.sbaa__Approver__r.sbaa__GroupId__c);
                }                              
            }
            if(!apprGrpIdSet.isempty()){
                for(GroupMember gm:[SELECT Id,GroupId,UserOrGroup.Email FROM GroupMember where UserOrGroup.IsActive=true and GroupId IN :apprGrpIdSet]){
                    if(grpIdToEmailsMap.containsKey(gm.GroupId)){
                        grpIdToEmailsMap.get(gm.GroupId).add(gm.UserOrGroup.Email);
                    }else{
                        grpIdToEmailsMap.put(gm.GroupId,new List<String>{gm.UserOrGroup.Email});
                    }
                }
            }
            
            for(sbaa__Approval__c app :apprList){
                if(app.sbaa__AssignedTo__r.Email != null || (app.sbaa__Approver__r?.sbaa__GroupId__c != null && grpIdToEmailsMap.containsKey(app.sbaa__Approver__r?.sbaa__GroupId__c) && !grpIdToEmailsMap.get(app.sbaa__Approver__r?.sbaa__GroupId__c)?.isEmpty())){
                    Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                    mail1.setTemplateId(activetempId.Id);
                    mail1.setTargetObjectId(app.ownerId);
                    mail1.setTreatTargetObjectAsRecipient(false);
                    mail1.setWhatId(app.Id);
                    mail1.setSaveAsActivity(false);  
                    mail1.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
                    if(app.sbaa__AssignedTo__c != null){
                        mail1.setToAddresses(new List<string>{app.sbaa__AssignedTo__r.Email});
                    }else{
                        mail1.setToAddresses(grpIdToEmailsMap.get(app.sbaa__Approver__r.sbaa__GroupId__c));
                    }
                    mails.add(mail1);
                }
            }  
            if(!mails.isEmpty()){
                List<Messaging.SendEmailError> errorlist = new List<Messaging.SendEmailError>();
                Messaging.SendEmailResult[] results=Messaging.sendEmail(mails,false);
                for(Messaging.SendEmailResult res: results){
                    if (!res.isSuccess()) {
                         errorlist.addall(res.getErrors());   
                    } 
                }
                
                if(!errorlist.isempty()){
                    for (Messaging.SendEmailError err : errorlist) {
                            failemailMap.put(err.getTargetObjectId(),err.getMessage()); 
                        }
                }
            }
            
            if(!failemailMap.isempty()){
                PSG_Utility.createCoreLogEntry('PSG_ApprovalEmailNotification','PSG_ApprovalEmailNotification','Email sending failed for ',''+failemailMap
                                           ,'sbaa__Approval__c','High','');
            }
        }    
    }
}