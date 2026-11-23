global class DuplicateLeadConverter implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Set<Id> validRecordTypeIds = new Set<Id>();

        for (RecordType rt : [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Lead' 
            AND Name IN ('Lead', 'Sales Lead')
        ]) {
            validRecordTypeIds.add(rt.Id);
        }

        return Database.getQueryLocator([
            SELECT Id, Email, OwnerId, Core_Product_Interest__c, Core_Lead_Status__c, CreatedDate
            FROM Lead
            WHERE IsConverted = FALSE
            AND Email != null
            AND RecordTypeId IN :validRecordTypeIds
            ORDER BY CreatedDate DESC
            LIMIT 2000
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope) {

        Set<String> emails = new Set<String>();
        Set<Id> ownerIds = new Set<Id>();

        for (Lead l : scope) {
            emails.add(l.Email.toLowerCase());
            ownerIds.add(l.OwnerId);
        }

        Map<String, Contact> emailToContact = new Map<String, Contact>();
        for (Contact c : [
            SELECT Id, Email, OwnerId, AccountId
            FROM Contact
            WHERE Email IN :emails
        ]) {
            emailToContact.put(c.Email.toLowerCase(), c);
        }
        
        system.debug('Email to Contact ' +emailToContact);

        Map<Id, User> ownerMap = new Map<Id, User>(
            [SELECT Id, Email, FirstName FROM User WHERE Id IN :ownerIds]
        );

        Map<Id, Group> queueMap = new Map<Id, Group>(
            [SELECT Id FROM Group WHERE Id IN :ownerIds AND Type = 'Queue']
        );

        Id orgWideEmailId;
        List<OrgWideEmailAddress> oweList = [
            SELECT Id FROM OrgWideEmailAddress 
            WHERE Address = 'salescrm_sb@intel.com'
            LIMIT 1
        ];
        if (!oweList.isEmpty()) orgWideEmailId = oweList[0].Id;

        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Task> tasks = new List<Task>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Lead> leadsToUpdateOwner = new List<Lead>();

        Id runningUserId = UserInfo.getUserId();

        for (Lead l : scope) {

            Contact match = emailToContact.get(l.Email.toLowerCase());
            if (match == null) continue;

            User leadOwner = ownerMap.get(l.OwnerId);
            Boolean isQueueOwner = queueMap.containsKey(l.OwnerId);

            // ================= EMAIL BEFORE CONVERSION =================
            Boolean sendEmail = true;

            if (isQueueOwner) sendEmail = false;
            if (leadOwner != null && leadOwner.FirstName == 'Marketo') sendEmail = false;
            if (l.Core_Lead_Status__c == 'disqualified' ||
                l.CreatedDate > System.now().addMonths(-6)) sendEmail = false;

            if (sendEmail && orgWideEmailId != null && leadOwner != null) {

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(leadOwner.Id);
                mail.setOrgWideEmailAddressId(orgWideEmailId);
                mail.setSaveAsActivity(false);
                mail.setSubject('Notification: Lead Automatically Converted to Contact');

                mail.setPlainTextBody(
                    'Hello,\n\n' +
                    'The lead you own has been automatically converted because a new contact was created with the same email address.\n\n' +
                    'Details:\n' +
                    'Lead: ' + l.Id + ' (' + l.Email + ')\n' +
                    'Contact: ' + match.Id + ' (' + match.Email + ')\n\n' +
                    'The lead information is now associated with the contact record.'
                );

                emailsToSend.add(mail);
            }

            if (isQueueOwner) {
                l.OwnerId = runningUserId;
                leadsToUpdateOwner.add(l);
            }

            // ================= TASK CREATION =================
            if (l.Core_Product_Interest__c != null) {

                Task newTask = new Task();
                newTask.OwnerId = match.OwnerId;
                newTask.Type = 'Other';
                newTask.Priority = 'Normal';
                newTask.TaskSubtype = 'Task';
                newTask.Subject = 'Automated - Duplicate Lead contact consolidation Task';

                newTask.Description =
                    'We identified a Lead record linked to a Contact with the same email address, resulting in duplicate entries. To resolve this, automation has:\n' +
                    '1. Converted the Lead and mapped it to the existing Contact.\n' +
                    '2. Consolidated all product interest details under the Contact to maintain a complete engagement view.\n\n' +
                    'Updated Product Interests now associated with the Contact: ' + l.Core_Product_Interest__c;

                newTask.WhoId = match.Id;
                newTask.Status = 'Completed';
                newTask.ActivityDate = Date.today();
                newTask.RecordTypeId = '012o0000000Gn1AAAS';

                tasks.add(newTask);
            }

            // ================= CONVERSION =================
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setContactId(match.Id);
            lc.setAccountId(match.AccountId);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Sales Qualified Lead');

            conversions.add(lc);
        }

        if (!leadsToUpdateOwner.isEmpty()) {
            update leadsToUpdateOwner;
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }

        if (!conversions.isEmpty()) {
            Database.convertLead(conversions, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Duplicate Lead conversion batch completed successfully.');
    }
}