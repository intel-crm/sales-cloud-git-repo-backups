/**************************************************************************************
Apex Class Name: Core_Lead_Daily_PartnerNotification
Version : 1.0 
Created Date: 15 AUG 2016
Function: Schedulable class that will send daily email summary notifications to partner users
This summary contains the number of leads they got assigned each day.

Modification Log :
Developer                 Date                    Description
----------------------------------------------------------------------------                 
Venu Karumuru             08/15/2016              Initial Version
*************************************************************************************/

global class Core_Lead_Daily_PartnerNotification implements schedulable
{
    // Main method that gets called by the sechduler and is required
    global void execute(SchedulableContext sc)
    {
        SendSummayMailToPartners();
    }


    public integer SendSummayMailToPartners()
    {
        // Get a list of Partner leads created yesterday
        list<lead> lstLeads = new list<lead>();
        lstLeads = [SELECT Id, Name, OwnerId, Core_Partner_Name__c FROM Lead WHERE CreatedDate = YESTERDAY AND RecordTypeId = :System.Label.Core_Partner_Lead_Record_Id];
        //lstLeads = [SELECT Id, Name, OwnerId, Core_Partner_Name__c FROM Lead WHERE DAY_ONLY(CreatedDate) = 2016-08-10 AND RecordTypeId = :System.Label.Core_Partner_Lead_Record_Id ORDER BY OwnerId]; // Testing only

        System.debug('### SendSummayMailToPartners() 01 ### Total Lead Count: ' + lstLeads.size());
        for (Lead lead :lstLeads)
            System.debug('### SendSummayMailToPartners() 02 ### Lead Details: ' + lead);

        
        // No leads to process
        if (lstLeads.size() == 0)
            return 0;


        // The OwnerId of Partner Leads is a Queue
        // Create the mapping between QueueId and Count of leads for that QueueId
        Map<Id, Integer> map_QueueId_LeadCount = new Map<Id, Integer>();

        for (Lead lead :lstLeads)
        {
            if (map_QueueId_LeadCount.get(lead.OwnerId) == null) // First lead of the Queue
                map_QueueId_LeadCount.put(lead.OwnerId, 1);  
            else
                map_QueueId_LeadCount.put(lead.OwnerId, map_QueueId_LeadCount.get(lead.OwnerId) + 1); // Increment the Lead count
        }

        for (Id queueId :map_QueueId_LeadCount.keyset())
            system.debug('### SendSummayMailToPartners() 03 ### Lead Count By Queue: ' + queueId + ' - ' + map_QueueId_LeadCount.get(queueId));

                
        // Create the mapping between QueueId and Partner Name for that QueueId
        Map<Id, String> map_QueueId_PartnerName = new Map<Id, String>();

        for (Lead lead :lstLeads)
            map_QueueId_PartnerName.put(lead.OwnerId, lead.Core_Partner_Name__c);

        for (String queueId :map_QueueId_PartnerName.keyset())
            system.debug('### SendSummayMailToPartners() 05 ### Partner Name By Queue: ' + queueId + ' - ' + map_QueueId_PartnerName.get(queueId));


        // Get the list of all QueueIds where the lead count is greater than the threshold
        Set<Id> setQueueIds = new Set<Id>();
        for (Id queueId :map_QueueId_LeadCount.keyset())
        {
            if (map_QueueId_LeadCount.get(queueId) >= Integer.ValueOf(System.Label.Core_Partner_Daily_Summary_Threshold))
                setQueueIds.add(queueId);
        }

        System.debug('### SendSummayMailToPartners() 06 ### Total Queue Count to receive Email: ' + setQueueIds.size());
        for (Id queueId :setQueueIds)
            System.debug('### SendSummayMailToPartners() 07 ### Queue to receive Email: ' + queueId);


        // Check if there are any queues to receive emails
        if (setQueueIds.size() == 0)
            return 0;

        
        // Get the list of all members of all the queues that would receive emails
        List<groupmember> lstQueueMembers = new List<groupmember>();
        lstQueueMembers = [SELECT Groupid, UserOrGroupId FROM GroupMember WHERE GroupId = :setQueueIds ORDER BY Groupid];

        for (GroupMember queueMember :lstQueueMembers)
            System.debug('### SendSummayMailToPartners() 08 ### Queue Member: ' + queueMember.Groupid + ' - ' + queueMember.UserOrGroupId);


        // Get the unique list of all users
        Set<Id> setUserIds = new Set<Id>();
        for (GroupMember queueMember :lstQueueMembers)
            setUserIds.add(queueMember.UserOrGroupId);

        // Get the email ids of all users
        List<User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, Email FROM User WHERE Id = :setUserIds];
        for (User usr :lstUsers)
            System.debug('### SendSummayMailToPartners() 09 ### User: ' + usr.Id + ' - ' + usr.Email);

        
        // Check if the code needs to be run in Debug mode
        Boolean bDebugMode = Boolean.ValueOf(System.Label.Core_Partner_Daily_Summary_Debug_Mode);
        System.debug('### SendSummayMailToPartners() 10 ### Debug Mode: ' + bDebugMode);

        // Get the FROM Address
        OrgWideEmailAddress OWA = new OrgWideEmailAddress();
        OWA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.Label.Core_Partner_Daily_Summary_From_Address];
        Id OWD_ID = OWA.id;
        System.debug('### SendSummayMailToPartners() 11 ### OrgWideEmailAddress: ' + OWD_ID);


        // Get the correct email template to be used
        EmailTemplate emailTemplate = null;
        
        if (bDebugMode)
            emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id = :System.Label.Core_Partner_Daily_Summary_EmailTemplate_Id_Debug];
        else
            emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id = :System.Label.Core_Partner_Daily_Summary_EmailTemplate_Id];

        System.debug('### SendSummayMailToPartners() 12 ### Email Template: ' + emailTemplate.Id + ' - ' + emailTemplate.Name);


        // Structure to store the list of emails to be sent
        Messaging.SingleEmailMessage[] lstMails = new Messaging.SingleEmailMessage[]{};

        // Build the list of emails to be sent
        // One email for one Queue
        for (Id queueId :setQueueIds)
        {
            // Get the list of users for the current queue
            List<Id> lstUserIds = new List<Id>();

            for (GroupMember queueMember :lstQueueMembers)
            {
                if (queueId == queueMember.groupid)
                    lstUserIds.add(queueMember.UserOrGroupId);
            }

            // Get the list of emails of the users for the current queue
            String[] lstUersEmails = new string[]{};
            for (Id usrId :lstUserIds)
            {
                for (User usr: lstUsers)
                {
                    if (usrId == usr.Id)
                        lstUersEmails.add(usr.Email);
                }
            }

            // Log the details
            System.debug('### SendSummayMailToPartners() 13 ### Queue id: ' + queueId);
            System.debug('### SendSummayMailToPartners() 13 ### Queue User Ids: ' + lstUserIds);
            System.debug('### SendSummayMailToPartners() 13 ### Queue User Emails: ' + lstUersEmails);
            System.debug('### SendSummayMailToPartners() 13 ### Queue Lead Count: ' + map_QueueId_LeadCount.Get(queueId));
            System.debug('### SendSummayMailToPartners() 13 ### Queue Partner Name: ' + map_QueueId_PartnerName.Get(queueId));

            // Skip if ther are no users in the current queue
            if (lstUserIds.size() == 0)
                continue;

            // Get the subject, body from the email template
            String sSubject = emailTemplate.Subject;
            String sHTMLBody = emailTemplate.HtmlValue;
            String sPlainBody = emailTemplate.Body;

            // Create a new mail and set all the parameters
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.OrgWideEmailAddressId = OWD_ID;
            mail.Subject = sSubject;

            if (bDebugMode)
            {
                // Replace the place holders with the correct values
                sPlainBody = sPlainBody.replace('{!Lead.SummaryDate}', String.valueof(Date.today().addDays(-1)));
                sPlainBody = sPlainBody.replace('{!Lead.SummaryCount}', String.valueof(map_QueueId_LeadCount.Get(queueId)));
                sPlainBody = sPlainBody.replace('{!Lead.QueueId}', String.valueof(queueId));
                if (map_QueueId_PartnerName.Get(queueId) != null)                
                    sPlainBody = sPlainBody.replace('{!Lead.PartnerName}', map_QueueId_PartnerName.Get(queueId));
                else
                    sPlainBody = sPlainBody.replace('{!Lead.PartnerName}', 'null');
                sPlainBody = sPlainBody.replace('{!Lead.QueueMembers}', String.valueof(lstUersEmails));

                // Ignore the actual emails and use test emails if we are running in the debug mode
                lstUersEmails.clear();
                lstUersEmails = System.Label.Core_Partner_Daily_Summary_To_Address_Debug.split(',');

            }
            else
            {
                // Replace the place holders with the correct values
                sPlainBody = sPlainBody.replace('{!Lead.SummaryDate}', string.valueof(Date.today().addDays(-1)));
                sPlainBody = sPlainBody.replace('{!Lead.SummaryCount}', string.valueof(map_QueueId_LeadCount.Get(queueId)));

                mail.SetTargetObjectId(lstUserIds[0]); // Set the target object to a user in the queue, so the apex email count does not use the org limits
            }

            System.debug('### SendSummayMailToPartners() 14 ### Queue Final User Emails: ' + lstUersEmails);
            
            // Set the to address and body
            mail.setToAddresses(lstUersEmails);
            if (System.Label.Core_Partner_Daily_Summary_Bcc_Address.contains('@')) // Copy BCC mails if any
                mail.setBccAddresses(System.Label.Core_Partner_Daily_Summary_Bcc_Address.split(','));
            mail.setPlainTextBody(sPlainBody);
            mail.setSaveAsActivity(false);

            // Add the mail to the list
            lstMails.add(mail);
        }


        // Send the mails
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails);
        if (results != null)
        {
            for (Integer i = 0; i < results.size(); i++)
            {
                if (results[i].success)
                    System.debug('### SendSummayMailToPartners() 15 ### The email was sent successfully.'); 
                else 
                    System.debug('### SendSummayMailToPartners() 16 ### The email failed to send: ' + results[i].errors[0].message);
            }
        }

        return 0;
    }
}