/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_NotifyApprover
Version         : 1.0 
Created Date    : 10/06/2017
Function        : This batch apex is used send emails to ISR user based on the group member information for a particular region
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             10/06/2017             Created
*****************************************************************************************************/


global Class Core_Batch_DDR_NotifyApprover implements Database.Batchable<sObject> 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id, Name, Core_Approver_Grp_Nm__c, Core_Approver_Grp_Notification_Sent_Ind__c, OwnerId, CreatedById, Core_Partner_Account_Id__c'+  
                        ' FROM Core_Design_Registration__c'+
                        ' WHERE Core_Approver_Grp_Notification_Sent_Ind__c != TRUE';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Core_Design_Registration__c> lstDesignReg)
    {
        try
        {
        
        //*****************************************************//
        //Find the Group name 
        
        Set<Id> setDistiAccountIds = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Core_Location_To_Approver_Group_Mapping__c> lstISRMappings = new List<Core_Location_To_Approver_Group_Mapping__c>();
        
        Map<String, String> mapISRCityTOGroupName = new Map<String, String>();
        Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
        Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
        
        String GroupName;
        
        //Get disti account Ids for query disti account to identify their location
        for(Core_Design_Registration__c iDR : lstDesignReg)
        {
            setDistiAccountIds.add(iDR.Core_Partner_Account_Id__c);
        }
        
        
        lstAccount = [SELECT id, Name, BillingState, BillingCountry FROM Account WHERE Id IN: setDistiAccountIds];        
        
        lstISRMappings = Core_Location_To_Approver_Group_Mapping__c.getAll().values();
        
        //create a map of ISR location and group name              
        for(Core_Location_To_Approver_Group_Mapping__c iISRMap : lstISRMappings)
        {
        
            if(iISRMap.Core_Active_Ind__c == TRUE)
            {
                if(iISRMap.Core_State_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
                else if(iISRMap.Core_Country_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
            }
        }    
        
        //Create a map of Account Id to Billing location (State/ Country)
        for(Account iAcc : lstAccount)
        {
            mapAccountToBillingState.put(iAcc.Id, iAcc.BillingState);
            mapAccountToBillingCountry.put(iAcc.Id, iAcc.BillingCountry);
        }
        
        
        //get group name based on the DR's distributor account
        for(Core_Design_Registration__c iDR : lstDesignReg)
        {
            if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
            {
                iDR.Core_Approver_Grp_Nm__c = mapISRCityTOGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
            
            }
            else if(mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
            {
                iDR.Core_Approver_Grp_Nm__c = mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c);
            }
            else
            {
                iDR.Core_Approver_Grp_Nm__c = 'Core_Design_Approver_Catch_All';
            }
            
        }
        
        //*********************Close Find the Group Name********************************//
        
            List<User> lstUser = new List<User>();
            List<Group> lstGroup = new List<Group>();
            List<GroupMember> lstGroupMember = new List<GroupMember>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
            Set<Id> SetUserIds = new Set<Id>();
            Set<String> SetGroupNames = new Set<String>();
            
            //Collect group name to query group members
            for(Core_Design_Registration__c iDR : lstDesignReg)
            {
                SetGroupNames.add(iDR.Core_Approver_Grp_Nm__c);
            }
            
            lstGroup = [SELECT Id, Name FROM Group WHERE DeveloperName IN: SetGroupNames];
            lstGroupMember = [Select UserOrGroupId FROM GroupMember WHERE GroupId IN :lstGroup];
            
            for(GroupMember iGM : lstGroupMember)
            {
                SetUserIds.add(iGm.UserOrGroupId);
            }
            
            lstUser = [SELECT id, Name,Email, FirstName FROM USER WHERE ID IN: SetUserIds];
            
            //Query the email template
            EmailTemplate et=[Select id from EmailTemplate where name=:'DR Creation mail for Intel users'];
            
            //Query the org wide email address
            OrgWideEmailAddress  OWEmail = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.Core_Org_wide_Email];
            
            // Iterate the Designs which need to process
            for(Core_Design_Registration__c iDR : lstDesignReg)
            {
                //Iterate the group members who should receive an email
                for (User iUser: lstUser) 
                {
                    if (iUser.Email != null && iUser.FirstName != null) 
                    {
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.id, iDR.OwnerId, iDR.Id);
                        String emailSubject = email.getSubject();
                        String emailHTMLBody = email.getPlainTextBody();           
                        
                             
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                        List<String> sendTo = new List<String>();
                        sendTo.add(iUser.Email);
                        //sendTo.add('rajadinakaranx.ramachandran@intel.com');
                        
                        mail.setToAddresses(sendTo);
                        
                        mail.setOrgWideEmailAddressId(OWEmail.Id);
                        //mail.setReplyTo('rajadinakaranx.ramachandran@intel.com');
                        //mail.setSenderDisplayName('Intel Dev Team - Testing'+iDR.Name);
                        //mail.setTargetObjectId(iDR.OwnerId);
                        mail.setTemplateId(et.id);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(iDR.Id);
                        
                        // (Optional) Set list of people who should be CC'ed
                        List<String> ccTo = new List<String>();
                        //ccTo.add('rajadinakaranx.ramachandran@intel.com');
                        //ccTo.add('rosyx.sinha@intel.com');
                        mail.setCcAddresses(ccTo);
               
                        mail.setSubject(emailSubject);
                        mail.setHtmlBody(emailHTMLBody);
                 
                        mails.add(mail);
                    }
                }
                
                iDR.Core_Approver_Grp_Notification_Sent_Ind__c = TRUE;
            }
            
            Messaging.sendEmail(mails); 
            
            
            update lstDesignReg;
        }
        catch(Exception err)
        {
            System.debug('NotifyISRBatchApex::'+err.getMessage());
        }
        
    }   
     
    global void finish(Database.BatchableContext BC)
    {
        
    }
}