/*********************************************************************************************************************
Class Name    : PRM_ACMUpdateBatchUtility
Version       : 1.0
Created Date  : July, 2021
Function      : Update Account channel membership at OPID OR Account wihout OPID based on IPA Membership

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Dinesh Mengade            July, 2021              This class will update ACM and assign benefits based on new Partner role and tier
-----------------------------
NOTE - This class will work for Account which has only one ACM(Account Channel Membership)
SOQL Consumed - 6 -PRM_IPA_Membership__c, ChannelProgramLevel, PRM_AccountChannelMembership__c, PRM_Account_Contact_Relationship__c, PRM_VXBnftMatrix__c, PRM_AccountBenefitAssociation__c
-----------------------------
*********************************************************************************************************************/
public without sharing class PRM_ACMUpdateBatchUtility implements Database.Batchable<SObject>, Database.Stateful{    
    public List<Sobject> sobjectoUpsert = new List<Sobject>();
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        String status = Label.PRM_ACM_Change_Request_InProgress;
        String query = 'select id,PRM_Account_Channel_Membership__r.PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Record_Type__c, PRM_Account_Id__c, PRM_Account_Channel_Membership__c, PRM_Status__c, PRM_Old_Partner_Role__c, PRM_Old_Partner_Tier__c, PRM_Partner_Role__c, PRM_Partner_Tier__c,PRM_Partner_Tier__r.Rank,PRM_Partner_Tier__r.Name,PRM_Account_Channel_Membership__r.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Comments__c from PRM_IPA_Membership__c where PRM_Status__c = :status';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<PRM_IPA_Membership__c> scope){
        try{
            //boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
            List<Sobject> SObjectLst = new List<Sobject>();
            //if(IPARefresh){
                PRM_IPAR_ACMUpdateUtility utility = new PRM_IPAR_ACMUpdateUtility(); //calling constructor of utility class and passing the scope.
                PRM_IPAR_ACMUpdateUtility.contactEntilementResponse cersp = utility.assignBenefits(scope);   
                SObjectLst.addAll(cersp.entitlementsTOUpsert);
                SObjectLst.addAll(cersp.updateAccountandContact);      
                
                sobjectoUpsert.addAll(SObjectLst);
                Map<Id, PRM_IPA_Membership__c> ipaMemMap = new Map<Id,PRM_IPA_Membership__c>();
                PRM_IPA_Membership__c ipaMem;
                if(!cersp.memResponseWrapper.values().isEmpty() && cersp.memResponseWrapper.values()!=null && cersp.memResponseWrapper!=null && !cersp.memResponseWrapper.isEmpty())
                { for(PRM_IPAR_ACMUpdateUtility.MembershipWrapper memeb : cersp.memResponseWrapper.values()){
                    ipaMem = new PRM_IPA_Membership__c();
                    if(ipaMemMap.size()>0 && ipaMemMap.containsKey(memeb.memId)){
                        ipaMem = ipaMemMap.get(memeb.memId);
                        ipaMem.prm_error_summary__c+=memeb.errorMessage;
                        ipaMemMap.put(memeb.memId,ipaMem);
                    }else{
                        ipaMem.Id = memeb.memId;
                        ipaMem.PRM_Status__c=memeb.errorMessage.length()>0?'Completed with errors':'Complete';
                        ipaMem.prm_error_summary__c = memeb.errorMessage;
                        ipaMemMap.put(memeb.memId,ipaMem);
                    }
                    
                }
                }
                System.debug('ipaMemMap -->'+sobjectoUpsert);
                
                if(ipaMemMap.size()>0){
                    
                    PRM_IPAR_ACMUpdateUtility.upsertData(ipaMemMap.values());
                }
                
            //} // IPA Switch Removal
            /*if(!IPARefresh){
                PRM_ACMUpdateUtility utility = new PRM_ACMUpdateUtility(); //calling constructor of utility class and passing the scope.
                PRM_ACMUpdateUtility.contactEntilementResponse cersp = utility.assignBenefits(scope);   
                SObjectLst.addAll(cersp.entitlementsTOUpsert);SObjectLst.addAll(cersp.updateAccountandContact);sobjectoUpsert.addAll(SObjectLst);
                Map<Id, PRM_IPA_Membership__c> ipaMemMap = new Map<Id,PRM_IPA_Membership__c>();        PRM_IPA_Membership__c ipaMem;
                for(PRM_ACMUpdateUtility.MembershipWrapper memeb : cersp.memResponseWrapper.values()){
                    ipaMem = new PRM_IPA_Membership__c();
                    if(ipaMemMap.size()>0 && ipaMemMap.containsKey(memeb.memId)){                ipaMem = ipaMemMap.get(memeb.memId);
                                                                                 ipaMem.prm_error_summary__c+=memeb.errorMessage;                ipaMemMap.put(memeb.memId,ipaMem);
                                                                                }else{
                                                                                    ipaMem.Id = memeb.memId;                ipaMem.PRM_Status__c=memeb.errorMessage.length()>0?'Completed with errors':'Complete';
                                                                                    ipaMem.prm_error_summary__c = memeb.errorMessage;                ipaMemMap.put(memeb.memId,ipaMem);
                                                                                }
                    
                }
                System.debug('ipaMemMap -->'+ipaMemMap);
                
                if(ipaMemMap.size()>0){            PRM_ACMUpdateUtility.upsertData(ipaMemMap.values());
                                      }
                
                System.debug('lstEntitlement -->'+sobjectoUpsert);
            }*/ // IPA Switch Removal
        }catch(exception ex){
            
        }
    }
    public void finish(Database.BatchableContext context){
        System.debug('lstEntitlement -->'+sobjectoUpsert);
        if(sobjectoUpsert.size()>0){
            Database.executeBatch(new PRM_UpdateEntitlementBatch(sobjectoUpsert), 9);
        }
    }
    
    //Get Email Addresses
    public List<String> getMailAddresses(){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group where developername ='PRM_Batch_Jobs_Email_Notification'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        return mailToAddresses;
    }
    
    
    //Send Email    
    public void sendMail(String templateName, String jobStatusMessage, String jobSubject) {
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(getMailAddresses());     
        String emailBody = [select HtmlValue from EmailTemplate where DeveloperName =:templateName limit 1].HtmlValue;
        emailBody = emailBody.replace('{!job_subject}',jobSubject);//'Batch Execution started'
        emailBody= emailBody.replace('{!JOB_MESSAGE}',jobStatusMessage);// 'Batch Execution is progress for Role/Tier Benefit Update'
        emailBody= emailBody.replace('{!$Label.PRM_CurrentYear}',Label.PRM_CurrentYear);//IPA2.0 TWC727-3232
        
        mail.setHtmlBody(emailBody); 
        if (owea != null) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}