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


global Class Core_Batch_DDR_NotifyApprover implements Database.Batchable<sObject> 
{
    //To get the log switch details 
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Name, Core_Approver_Grp_Nm__c, Core_Approver_Grp_Notification_Sent_Ind__c, OwnerId, Owner.Name, CreatedById, Core_Partner_Account_Id__c, Core_Partner_Account_Nm__c, Core_End_Customer_Nm__c, Core_Design_Registration_Nm__c'+  
                        ' FROM Core_Design_Registration__c'+
                        ' WHERE Core_Approver_Grp_Nm__c != NULL AND Core_Approver_Grp_Notification_Sent_Ind__c != TRUE AND Core_Pending_Product_Cnt__c >0'; //US101132-Added this condition 'Core_Pending_Product_Cnt__c'> 0--Rajesh 
                        //' WHERE Core_Approver_Grp_Nm__c != NULL AND Core_Approver_Grp_Notification_Sent_Ind__c != TRUE AND CreatedDate > 2017-11-29T00:00:00Z AND ID = \'a352D0000004UFNQA2\'';
        return Database.getQueryLocator(query);
       
    }
     
    // Replace the template place holders with the correct values. Return the rendered template as a string.
    public String RenderEmailBody(Core_Design_Registration__c Data, Id Owner, String Body) 
    {
        String tempBody = Body;
        tempBody = tempBody.replace('(</span>', '(');
        
        tempBody = tempBody.replace('(Core_Design_Registration__c.Name)', Data.Name!=NULL?Data.Name:'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_Design_Registration_Nm__c)', Data.Core_Design_Registration_Nm__c !=NULL?Data.Core_Design_Registration_Nm__c :'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_Partner_Account_Nm__c)', Data.Core_Partner_Account_Nm__c!=NULL?Data.Core_Partner_Account_Nm__c:'');
        tempBody = tempBody.replace('(Core_Design_Registration__c.Core_End_Customer_Nm__c)', Data.Core_End_Customer_Nm__c!=NULL?Data.Core_End_Customer_Nm__c:'');
        
        tempBody = tempBody.replace('(Core_Design_Registration__c.Link)', '<a href="'+URL.getSalesforceBaseUrl().getHost()+'/'+Data.Id+'">link</a>');
        
        return tempBody;
    }
         
    global void execute(Database.BatchableContext BC, List<Core_Design_Registration__c> lstDesignReg)
    { 
        Map<Id, String> mapDesignIdToGroupName = new Map<Id, String>();
        List<Group> lstGroup = new List<Group>();
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        Set<Id> SetUserIds = new Set<Id>();
        List<User> lstUser = new List<User>();
        Map<Id, String> mapUserIdToUserEmail = new Map<Id, String>();    
        Map<String, Id> mapUserEmailToUserId = new Map<String, Id>();        
        Map<String, List<String>> mapGroupNameToLstUserEmail = new Map<String, List<String>>();        
        
        List<Core_Design_Registration__c> lstUpdateDesigns = new List<Core_Design_Registration__c>();
        
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        try
        {
        system.debug(lstDesignReg.size());
            for(Core_Design_Registration__c iDesign : lstDesignReg)
            {
                //Collect the group Names
                mapDesignIdToGroupName.put(iDesign.Id, iDesign.Core_Approver_Grp_Nm__c);        
            }    
            
            //Query the group record using the group names
            lstGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN: mapDesignIdToGroupName.Values()];
            
            //Query group members using group Ids
            lstGroupMember = [Select GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :lstGroup];

            for(GroupMember iGroupMember : lstGroupMember)
            {
                SetUserIds.add(iGroupMember.UserOrGroupId);
            }  
            
            //Query user record to query the user emails
            lstUser = [SELECT id, Name,Email, FirstName FROM USER WHERE ID IN: SetUserIds];

            for(User iUser : lstUser)
            {
                mapUserIdToUserEmail.put(iUser.Id, iUser.Email);
                mapUserEmailToUserId.put(iUser.Email, iUser.Id);
            }
            
            for(Group iGroup : lstGroup)
            {
                for(GroupMember iGroupMember : lstGroupMember)
                {
                    if(iGroup.Id == iGroupMember.GroupId)
                    {
                        if(!mapGroupNameToLstUserEmail.containskey(iGroup.DeveloperName))
                        {
                            mapGroupNameToLstUserEmail.put(iGroup.DeveloperName, new List<String>{});
                        }
                        
                        List<String> tLstUserEmail = new List<String>();
                        tLstUserEmail = mapGroupNameToLstUserEmail.get(iGroup.DeveloperName);
                        tLstUserEmail.add(mapUserIdToUserEmail.get(iGroupMember.UserOrGroupId));
                        mapGroupNameToLstUserEmail.put(iGroup.DeveloperName, tLstUserEmail);    
                    }
                }
            }
            
            //Query the email template
            EmailTemplate  emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =: Label.Core_DDR_Notify_Approver_Email_Template];
            // Get the subject, body from the email template
            String sSubject = emailTemplate.Subject;
            String sHTMLBody = emailTemplate.HtmlValue;
            String sPlainBody = emailTemplate.Body;
            
            //Query the org wide email address
            OrgWideEmailAddress  OWEmail = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.Core_DDR_From_Address];
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.id, null, null);
            
            for(Core_Design_Registration__c iDesign : lstDesignReg)
            {
                    // Create a new mail and set all the parameters
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //mail = email;
                    mail.OrgWideEmailAddressId = OWEmail.Id;

                    if(mapGroupNameToLstUserEmail.containskey(iDesign.Core_Approver_Grp_Nm__c))
                    {
                        mail.setToAddresses(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c));
                        mail.SetTargetObjectId(mapUserEmailToUserId.get(mapGroupNameToLstUserEmail.get(iDesign.Core_Approver_Grp_Nm__c)[0])); // Set the target object to a user in the queue, so the apex email count does not use the org limits
                    }
                    // Set the to address and body
                    
                    
                    
                    if (Label.Core_DDR_Notify_Approver_Bcc_Address.contains('@')) // Copy BCC mails if any
                        mail.setBccAddresses(Label.Core_DDR_Notify_Approver_Bcc_Address.split(','));
                    
                    String tempSubject = sSubject;
                    mail.Subject = tempSubject.replace('{!Core_Design_Registration__c.Core_Partner_Account_Nm__c}', string.valueof(iDesign.Core_Partner_Account_Nm__c != NULL?iDesign.Core_Partner_Account_Nm__c:''));
                    mail.setPlainTextBody(RenderEmailBody(iDesign, iDesign.OwnerId, email.PlainTextBody));
                    mail.setHtmlBody(RenderEmailBody(iDesign, iDesign.OwnerId, email.HtmlBody)); 
                    mail.setSaveAsActivity(false);
        
                    // Add the mail to the list
                  
                    lstMails.add(mail); 
            }  
                    system.debug(lstmails.size());

            if(lstMails.size() > 0)
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails);
                
                for (Integer i = 0; i < lstDesignReg.size(); i++) 
                {

                    Messaging.SendEmailResult Result = results[i];
                    
                    if(Result.isSuccess())
                    {
                        Core_Design_Registration__c itUpdDesign = new Core_Design_Registration__c(Id = lstDesignReg[i].Id, Core_Approver_Grp_Notification_Sent_Ind__c = TRUE);
                        lstUpdateDesigns.add(itUpdDesign);
                    }
                    else if (!Result.isSuccess()) 
                    {
                        System.debug('### The email failed to send: ' + Result.errors[0].message);
                    }  
                }  
                 
                
                List<Database.SaveResult> lstDesignRegSaveResultUpdate = Database.update(lstUpdateDesigns, false);
                
                // To handle the DR creation failure stage record ids and to update its status and error message
                for (Integer i = 0; i < lstDesignRegSaveResultUpdate.size(); i++) 
                {
                    Database.SaveResult DbSaveResult = lstDesignRegSaveResultUpdate[i];
                    
                    if (!DbSaveResult.isSuccess()) 
                    {
                        for (Database.Error err: DbSaveResult.getErrors()) 
                        {
                            System.debug('### The record failed' +  (err.getFields() + '\n'+ err.getMessage()));
                        }  
                    } 
                }                        
            }
        }
        catch(Exception err)
        {
            system.debug('Excpetion: Notify Approver Batch Apex Line No:'+err.getLineNumber());
            system.debug('Exception: Notify Approver Batch Apex Error Message:'+err.getMessage());
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = 'Error:'+err.getMessage(),Core_Details__c = 'Line number: ' + err.getLineNumber()+', Stack trace: ' + err.getStackTraceString(), Core_Origin__c='Core_Batch_DDR_NotifyApprover', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }              
        }
        
    }   
       
    global void finish(Database.BatchableContext BC)
    {
        
    }
}