/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_NotifyApprover
Version         : 1.0 
Created Date    : 10/06/2017
Function        : This batch apex is used send emails to ISR user based on the group member information for a particular region
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ---------------------------------------------------------------------------- 
* Rajesh Kumar              09/04/2018             US101132-Added logic for Design Registration Products greather than zero in the query.             
* Rajadinakaran             10/06/2017             Created
*****************************************************************************************************/


global Class Core_Batch_DDR_NotifyApprover implements Database.Batchable<sObject> {
    //To get the log switch details 
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
      String query = LabelConfiguration__mdt.getInstance('DDR_NotifyApproverBatchQueryPart4').value__c.trim() + LabelConfiguration__mdt.getInstance('DDR_NotifyApproverBatchQueryPart5').value__c.trim()+ LabelConfiguration__mdt.getInstance('DDR_NotifyApproverBatchQueryPart1').value__c.trim() + LabelConfiguration__mdt.getInstance('DDR_NotifyApproverBatchQueryPart3').value__c.trim()+' '+LabelConfiguration__mdt.getInstance('DDR_NotifyApproverBatchQueryPart2').value__c.trim();              
        return Database.getQueryLocator(query);  
        
    }
    
    /*Replace the template place holders with the correct values. Return the rendered template as a string.*/
    public String RenderEmailBody(Core_Design_Registration__c Data, Id Owner, String Body) {
        String tempBody = Body;
        tempBody = tempBody.replace('(</span>', '(');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Name)', Data.Name!=NULL?Data.Name:'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_Design_Registration_Nm__c)', Data.Core_Design_Registration_Nm__c !=NULL?Data.Core_Design_Registration_Nm__c :'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_Partner_Account_Nm__c)', Data.Core_Partner_Account_Nm__c!=NULL?Data.Core_Partner_Account_Nm__c:'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_End_Customer_Nm__c)', Data.Core_End_Customer_Nm__c!=NULL?Data.Core_End_Customer_Nm__c: ((Data.PCC_EndCustomerAcc_Mapping__r != null && Data.PCC_EndCustomerAcc_Mapping__r.Name != null) ? Data.PCC_EndCustomerAcc_Mapping__r.Name : ''));
        tempBody = tempBody.replace('(Core_Design_Registration__c.PCC_End_Customer_Country__c)', Data.PCC_End_Customer_Country__c!=NULL?Data.PCC_End_Customer_Country__c: ((Data.PCC_EndCustomerAcc_Mapping__r != null && Data.PCC_EndCustomerAcc_Mapping__r.PCC_End_Customer_Account_Id__r != null && Data.PCC_EndCustomerAcc_Mapping__r.PCC_End_Customer_Account_Id__r.BillingCountryCode != null)? Data.PCC_EndCustomerAcc_Mapping__r.PCC_End_Customer_Account_Id__r.BillingCountryCode : ''));
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_End_Customer_Country_Subdivision_Nm__c)', Data.Core_End_Customer_Country_Subdivision_Nm__c!=NULL?Data.Core_End_Customer_Country_Subdivision_Nm__c: ((Data.PCC_EndCustomerAcc_Mapping__r != null && Data.PCC_EndCustomerAcc_Mapping__r.PCC_End_Customer_State_Nm__c != null) ? Data.PCC_EndCustomerAcc_Mapping__r.PCC_End_Customer_State_Nm__c : ''));
        
        tempBody = tempBody.replace('(Core_Design_Registration__c.Link)', '<a href="'+URL.getSalesforceBaseUrl().getHost()+'/'+Data.Id+'">link</a>');
        //System.debug(tempBody);
        return tempBody;
    }
    /* mail template */    
    global void execute(Database.BatchableContext BC, List<Core_Design_Registration__c> lstDesignReg) { 
        Map<Id, String> mapDesignIdToGroupName = new Map<Id, String>();
        Id batchId = BC.getJobId(); 
        List<Group> lstGroup = new List<Group>();
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        Set<Id> SetUserIds = new Set<Id>();
        List<User> lstUser = new List<User>();      
        List<Core_Design_Registration__c> lstUpdateDesigns = new List<Core_Design_Registration__c>(); 
        Map<Id,Messaging.SingleEmailMessage> lstMailsMap = new Map<Id,Messaging.SingleEmailMessage>();
        Map<String, Group> mapGrpIdToGroup = new Map<String, Group>(); //ApexGuru
        Map<Id,String> drName = new Map<Id,String>();
        String drOwnerId;
        List<Core_Design_Registration__c> lstUpdateDesigns1 = new List<Core_Design_Registration__c>();
        Map<Id,String> failedDrs = new Map<Id,String>();
        try {
            for(Core_Design_Registration__c iDesign : lstDesignReg) {
                drName.put(iDesign.Id,iDesign.Name);
                mapDesignIdToGroupName.put(iDesign.Id, iDesign.Core_Approver_Grp_Nm__c);   //Collect the group Names //ApexGuru
            }    
            //Query the group record using the group names
            lstGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN: mapDesignIdToGroupName.Values()]; //ApexGuru
            //added by sushmita for ApexGuru
            for (Group grp : lstGroup) {
                mapGrpIdToGroup.put(grp.Id, grp);
            }
            lstGroupMember = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :mapGrpIdToGroup.keySet()]; //Query group members using group Ids
            for(GroupMember iGroupMember : lstGroupMember) {
                SetUserIds.add(iGroupMember.UserOrGroupId);
            }  
            lstUser = [SELECT id, Name,Email, FirstName FROM USER WHERE ID IN: SetUserIds]; //Query user record to query the user emails 
            lstMailsMap = emailList(lstGroup,lstGroupMember,lstUser,lstDesignReg,batchId,drName);
            List<Id> drIds = new List<Id>();
            if(lstMailsMap.size() > 0) {
                
                for (Id drId : lstMailsMap.keySet()) {
                    drIds.add(drId);
                }
                Messaging.SendEmailResult[] results;
                
                    results = Messaging.sendEmail(lstMailsMap.values(),false);
               
                         
                for (Integer i = 0; i < drIds.size(); i++) {
                    Messaging.SendEmailResult Result = results[i];
                    if(Result.isSuccess()) {    
                        Core_Design_Registration__c itUpdDesign = new Core_Design_Registration__c(Id = drIds[i], Core_Approver_Grp_Notification_Sent_Ind__c = TRUE);                    
                        lstUpdateDesigns1.add(itUpdDesign);
                    }
                    else if (!Result.isSuccess()) {
                        //mailSentFailedDrs.add(itUpdDesign.id);
                        failedDrs.put(drIds[i],'Failure occured at sending email to Approver Group.');
                        System.debug('### The email failed to send: ' + Result.errors[0].message);
                    }
                }
                        
               // lstUpdateDesigns = updateDesignFunc(drIds,results,batchId,drName);
                List<Database.SaveResult> lstDesignRegSaveResultUpdate = Database.update(lstUpdateDesigns1, false);
                // To handle the DR creation failure stage record ids and to update its status and error message
                for(Database.SaveResult ds : lstDesignRegSaveResultUpdate){
		//Database.SaveResult DbSaveResult = lstDesignRegSaveResultUpdate[i];
		//handleDRCreationFailureStageRecords(DbSaveResult);
                    if(!ds.isSuccess()){
                        failedDrs.put(ds.getId(),'Failure occured at DML on DR post sending email to Approver Group.');
                        system.debug('failed dr id inside dml'+ds.getId());                                             
                    }                    
                }
                if(!failedDrs.isempty()){
                     sendToL2(failedDrs,batchId,drName);
                                      
                }
            }
        }
        catch(Exception err) {
            //system.debug('Excpetion: Notify Approver Batch Apex Line No:'+err.getLineNumber());
            system.debug('Exception: Notify Approver Batch Apex Error Message:'+err.getMessage());
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c) {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = 'Error:'+err.getMessage(),Core_Details__c = 'Line number: ' + err.getLineNumber()+', Stack trace: ' + err.getStackTraceString(), Core_Origin__c='Core_Batch_DDR_NotifyApprover', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            } 
        }
    }  
    /* emailList*/ 
    public static void sendToL2(Map<Id,String> failedDrs,id batchId,Map<Id,String> drName){
		Map<Id,Messaging.SingleEmailMessage> lstL2MailsMap = sendEmailToL2(failedDrs,batchId,drName);
          			if(lstL2MailsMap.size() > 0) {
                		Messaging.SendEmailResult[] resultsL2 = Messaging.sendEmail(lstL2MailsMap.values());
                    } }
    
     public void handleDRCreationFailureStageRecords(Database.SaveResult DbSaveResult)
     {
        if (!DbSaveResult.isSuccess()) {
            for (Database.Error err: DbSaveResult.getErrors()) {
                System.debug('### The record failed' +  (err.getFields() + '\n'+ err.getMessage()));
            }  
        }
     }
/*private List<Core_Design_Registration__c> updateDesignFunc(List<Id> lstDesignReg1,Messaging.SendEmailResult[] results)
{
    List<Core_Design_Registration__c> lstUpdateDesigns1 = new List<Core_Design_Registration__c>();
    for (Integer i = 0; i < lstDesignReg1.size(); i++) {
        Messaging.SendEmailResult Result = results[i];
        if(Result.isSuccess()) {
            /*Core_Design_Registration__c itUpdDesign;
            if(lstDesignReg1[i].Core_Approver_Grp_Notification_Sent_Ind__c == false)
            {
                itUpdDesign = new Core_Design_Registration__c(Id = lstDesignReg1[i].Id, Core_Approver_Grp_Notification_Sent_Ind__c = TRUE);
            }*/
            //Core_Design_Registration__c itUpdDesign = new Core_Design_Registration__c(Id = lstDesignReg1[i], Core_Approver_Grp_Notification_Sent_Ind__c = TRUE);
            /*else if(lstDesignReg1[i].Resubmission_mail_design__c == false)
            {
                itUpdDesign = new Core_Design_Registration__c(Id = lstDesignReg1[i].Id, Resubmission_mail_design__c = TRUE);
            }*/
           /* lstUpdateDesigns1.add(itUpdDesign);

        }
        else if (!Result.isSuccess()) {
            System.debug('### The email failed to send: ' + Result.errors[0].message);
        }
    }
    return lstUpdateDesigns1;
    }*/
    //TWC727-2695 -PCC: Email should be sent to L2 if there is any exception in email batch job
    @testvisible
    private static Map<Id,Messaging.SingleEmailMessage> sendEmailToL2(map<id,string> lstDesignReg1, id batchId,Map<Id,String> drNames) {
        EmailTemplate  emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName ='PCC_DRRNotifyBatchFailure_MailToL2'];
        String sSubject = emailTemplate.Subject; 
        OrgWideEmailAddress  OWEmailL2 = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: Label.Core_DDR_From_Address];
        Messaging.SingleEmailMessage email1 = Messaging.renderStoredEmailTemplate(emailTemplate.id, null, null);
        Map<Id,Messaging.SingleEmailMessage> lstL2MailsMap = new Map<Id,Messaging.SingleEmailMessage>();
        String emailBody= 'Batch Id : ' + batchId + '<br/>'+ '<br/>';
        if(!lstDesignReg1.isempty()){
        for(id iDesign : lstDesignReg1.keyset()) {
            String drLink = LabelConfiguration__mdt.getInstance('PCC_Internal_Record_Link').value__c+ iDesign;//'https://intel--crmdevsls3.sandbox.lightning.force.com/' + iDesign.Id;
            String drName = drNames.get(iDesign);
            emailBody += '<li>DR Name: ' + drName +'<br/>Error Message :' +lstDesignReg1.get(iDesign)+ '<br/>Link: <a href="' + drLink + '" target="_blank">View Record</a></li>';
        }
        }
        /*else if(batchId!=null){
           emailBody +=' An Error has occured in the DDR Notify Batch ' ;
        }*/
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // String mailAdd = 'npp.agate@intel.com';//'cloud.crm.l2.support.team@intel.com';
        String toMailAdd = LabelConfiguration__mdt.getInstance('PCC_MailToL2Team').value__c;//'manasax.chennamoni@intel.com';
        email.setToAddresses(new String[] {toMailAdd});
        email.Subject = sSubject;
        email.setSaveAsActivity(false);
        email.OrgWideEmailAddressId = OWEmailL2.id;
        email.setTemplateId(emailTemplate.Id);
        email.setPlainTextBody(email1.HtmlBody.replace('(Core_Design_Registration__c.Name)',emailBody));
        email.setHtmlBody(email1.HtmlBody.replace('(Core_Design_Registration__c.Name)',emailBody)); 
        lstL2MailsMap.put(batchId,email);
        return lstL2MailsMap;
    }
    
    global Map<Id,Messaging.SingleEmailMessage> emailList(List<Group> lstGroup , List<GroupMember> lstGroupMember, List<User> lstUser,List<Core_Design_Registration__c> lstDesignReg,Id batchId,Map<Id,String> drName ) {
        Map<String, List<String>> mapGroupNameToLstUserEmail = new Map<String, List<String>>();   
        Map<String, Id> mapUserEmailToUserId = new Map<String, Id>();      
        Map<Id,Messaging.SingleEmailMessage> lstMailsMap = new Map<Id,Messaging.SingleEmailMessage>();
        Map<Id, String> mapUserIdToUserEmail = new Map<Id, String>();    
        for(User iUser : lstUser) {
            mapUserIdToUserEmail.put(iUser.Id, iUser.Email);
            mapUserEmailToUserId.put(iUser.Email, iUser.Id);
        }
        for(Group iGroup : lstGroup) {
            for(GroupMember iGroupMember : lstGroupMember) {
                if(iGroup.Id == iGroupMember.GroupId) {
                    if(!mapGroupNameToLstUserEmail.containskey(iGroup.DeveloperName)) {
                        mapGroupNameToLstUserEmail.put(iGroup.DeveloperName, new List<String>{});
                    }
                    List<String> tLstUserEmail = new List<String>();
                    tLstUserEmail = mapGroupNameToLstUserEmail.get(iGroup.DeveloperName);
                    tLstUserEmail.add(mapUserIdToUserEmail.get(iGroupMember.UserOrGroupId));
                    mapGroupNameToLstUserEmail.put(iGroup.DeveloperName, tLstUserEmail);    
                }
            }
        }
        
        /*Query the email template*/ 
        lstMailsMap = emailList1(mapGroupNameToLstUserEmail,mapUserEmailToUserId,lstDesignReg,batchId,drName);
        
        return lstMailsMap; 
    }
    
    private Map<Id,Messaging.SingleEmailMessage> emailList1(Map<String, List<String>> mapGroupNameToLstUserEmail,Map<String, Id> mapUserEmailToUserId, List<Core_Design_Registration__c> lstDesignReg,Id batchId,Map<Id,String> drName)
    {
        EmailTemplate  emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =: Label.Core_DDR_Notify_Approver_Email_Template];
        String sSubject = emailTemplate.Subject;  /* Get the subject, body from the email template*/ 
        OrgWideEmailAddress  OWEmail = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: Label.Core_DDR_From_Address];
        list<Core_Design_Registration__c> noMemberGroupDesign = new list<Core_Design_Registration__c>();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.id, null, null);
        Map<Id,Messaging.SingleEmailMessage> lstMailsMap = new Map<Id,Messaging.SingleEmailMessage>();
         Map<Id,String> failedDrs = new Map<Id,String>();
        for(Core_Design_Registration__c iDesign : lstDesignReg) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();// Create a new mail and set all the parameters
            mail.OrgWideEmailAddressId = OWEmail.Id; //mail = email;
            //(mapGroupNameToLstUserEmail.containskey(iDesign.Core_Approver_Grp_Nm__c)) 
            if(iDesign.Core_Design_Registration_Status_Nm__c == 'Pre-Approved'&& mapGroupNameToLstUserEmail.containskey(iDesign.Core_Approver_Grp_Nm__c)){
               // String mailAdd = 'manasa@ab';
               // mail.setToAddresses(new String[] {mailAdd});
               mail.setToAddresses(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c));
               mail.SetTargetObjectId(mapUserEmailToUserId.get(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c)[0]));
            }
            else if(iDesign.Core_Design_Registration_Status_Nm__c == 'Re-Submitted' && iDesign.Core_Intel_Technical_Owner_Id__r.isActive == true){
                
                //if(iDesign.Core_Intel_Technical_Owner_Id__r.isActive == true){
                String mailAdd = iDesign.Core_Intel_Technical_Owner_Id__r.Email;
                mail.setToAddresses(new String[] {mailAdd});
                System.debug('mailid'+iDesign.Core_Intel_Technical_Owner_Id__r.Email);
                mail.SetTargetObjectId(iDesign.Core_Intel_Technical_Owner_Id__r.id);
               }
            
            
            else if(iDesign.Core_Design_Registration_Status_Nm__c == 'Re-Submitted' && iDesign.Core_Intel_Technical_Owner_Id__r.isActive !=true && mapGroupNameToLstUserEmail.containskey(iDesign.Core_Approver_Grp_Nm__c)){
                mail.setToAddresses(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c));
                mail.SetTargetObjectId(mapUserEmailToUserId.get(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c)[0]));
            }
            System.debug('mail.setToAddresses'+mail.getToAddresses());
            
            //mail.SetTargetObjectId(mapUserEmailToUserId.get(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c)[0])); // Set the target object to a user in the queue, so the apex email count does not use the org limits
            
            
            // Set the to address and body
            if (Label.Core_DDR_Notify_Approver_Bcc_Address.contains('@')) { // Copy BCC mails if any
                mail.setBccAddresses(Label.Core_DDR_Notify_Approver_Bcc_Address.split(','));
            }
            String tempSubject = sSubject;
            mail.Subject = tempSubject.replace('{!Core_Design_Registration__c.Core_Partner_Account_Nm__c}', string.valueof((iDesign.Core_Partner_Account_Nm__c == NULL) ? '':iDesign.Core_Partner_Account_Nm__c));
            mail.setPlainTextBody(RenderEmailBody(iDesign, iDesign.OwnerId, email.PlainTextBody));
            mail.setHtmlBody(RenderEmailBody(iDesign, iDesign.OwnerId, email.HtmlBody)); 
            mail.setSaveAsActivity(false);
            if(mail.getToAddresses() != null){
                lstMailsMap.put(iDesign.Id,mail); // Add the mail to the list
            }
            else{
                iDesign.PCC_Empty_Approver_Group__c = true;
                noMemberGroupDesign.add(iDesign);
            }
        }
        if(noMemberGroupDesign.size()>0){
            List<Database.SaveResult> lstDesignRegSaveResultUpdate=Database.update(noMemberGroupDesign, false);
            for(Database.SaveResult ds : lstDesignRegSaveResultUpdate){
                    if(!ds.isSuccess()){
                        failedDrs.put(ds.getId(),'Failure occured at DML on DR while updating Empty Approver Group CheckBox');
                        system.debug('failed dr id inside dml11'+ds.getId());                                             
                    }                    
                }
            if(!failedDrs.isempty()){
                sendToL2(failedDrs,batchId,drName);}
        }
        
        return lstMailsMap;
    }
    
    
    /*finish method */
    global void finish(Database.BatchableContext BC) {
        
    }
}