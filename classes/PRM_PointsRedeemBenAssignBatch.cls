/***********************************************************************************************************************************************
Apex Class Name:  PRM_PointsRedeemBenAssignBatch
Version     : 1.0 
Created Date: 12 July 2022
Function    : Batch for Points Redemption Benefit and Entitlement Assignment for Member Tier OPID Accounts

Modification Log :
* Developer          Date               Description                                                 TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh       12/07/2022         Points Redemption Benefit and Entitlement Assignment        PRM_PointsRedeemBenAssignBatch_Test
                                        for Member Tier OPID Accounts
*************************************************************************************************************************************************/
global class PRM_PointsRedeemBenAssignBatch implements Database.Batchable<sObject>,Database.Stateful{
    global static PRM_BatchCustomSetting__c batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_LastExecutedTime__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
    global static Database.QueryLocator start(Database.BatchableContext context){
        String nameIPA = System.label.PRM_Intel_Partner_Alliance;
        String nameOPID = System.label.PRM_ParentAccRecordType;
        String nameMember = System.label.PRM_Member;
        DateTime lastExecutedTimeofBatch = batchCustomSetting.PRM_LastExecutedTime__c;
        List<PRM_AccountChannelMembership__c> listACMs = new List<PRM_AccountChannelMembership__c>();
        String acmList = '';
        Set<Id> setAccId = new Set<Id>();
        if(lastExecutedTimeofBatch != NULL){
            listACMs = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =: nameIPA AND PRM_Account_Id__r.recordtype.name =: nameOPID AND PRM_Channel_Program_Level_Id__r.Name =: nameMember AND LastModifiedDate > :lastExecutedTimeofBatch order by PRM_Account_Id__c];
        }else{
            listACMs = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =: nameIPA AND PRM_Account_Id__r.recordtype.name =: nameOPID AND PRM_Channel_Program_Level_Id__r.Name =: nameMember  AND LastModifiedDate = TODAY order by PRM_Account_Id__c];
        }
        if(listACMs.size()>0 && !listACMs.isEmpty()){
            for(PRM_AccountChannelMembership__c acm : listACMs){
                setAccId.add(acm.PRM_Account_Id__c);
            }
        }
        acmList = 'Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,'+
        ' PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name,'+
        ' PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c'+
        ' From PRM_AccountChannelMembership__c'+
        ' Where PRM_Channel_Program_Id__r.Name =: nameIPA '+
        ' AND PRM_Account_Id__r.recordtype.name =: nameOPID '+
        ' AND PRM_Account_Id__c in: setAccId '+
        ' order by PRM_Account_Id__c';

        batchCustomSetting.PRM_LastExecutedTime__c = System.Now();
        update batchCustomSetting;
        return Database.getQueryLocator(acmList);
    }
    global void execute(Database.BatchableContext context, List<PRM_AccountChannelMembership__c> scope){
        PRM_PointsRedeemBenAssignUtility.pointsBenefitEligibility(scope);
    }
    global void finish(Database.BatchableContext context){
        String body = 'Points Redemption Benefit Assignment for Partner Tier OPID Accounts is successful';
        if(String.isNotBlank(body)){
            sendMail('BATCH_JOB_NOTIFICATION', body ,'Points Redemption Benefit Assignment Completed Successfully'); //Calling Send Email Method to send batch completion email 
        }
    }
    
    
    //Get Email Addresses - IPA Admins  
    public List<String> getMailAddresses(){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        
        Group gp = [
            SELECT 
            (SELECT 
             UserOrGroupId 
             FROM GroupMembers) 
            FROM Group where developername ='PRM_Batch_Jobs_Email_Notification'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [
            SELECT Email 
            FROM User 
            WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        return mailToAddresses;
    }
    
    public void sendMail(String templateName, String jobStatusMessage, String jobSubject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [
                SELECT 
                Id 
                FROM OrgWideEmailAddress
                WHERE Address =: Label.PRM_wsm_postmaster_intel_com];
            if (owea != null) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        mail.setToAddresses(getMailAddresses());     
        String emailBody = [
            SELECT 
            HtmlValue 
            FROM EmailTemplate
            WHERE DeveloperName =:templateName limit 1].HtmlValue;
        emailBody = emailBody.replace('{!job_subject}',jobSubject);//'Batch Execution started'
        emailBody= emailBody.replace('{!JOB_MESSAGE}',jobStatusMessage);// 'Batch Execution is progress for Bulk Data Upload Batch'
        mail.setSubject('Points Redemption Benefit Assignment completed Successfully');
        mail.setHtmlBody(emailBody);               
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}