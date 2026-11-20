global class DuplicateLeadConverter implements Database.Batchable<SObject>, Database.Stateful {

    private Id orgWideEmailId;

    global Database.QueryLocator start(Database.BatchableContext bc) {

        List<OrgWideEmailAddress> oweList = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = 'salescrm_sb@intel.com'
            LIMIT 1
        ];
        if (!oweList.isEmpty()) {
            orgWideEmailId = oweList[0].Id;
        }

        return Database.getQueryLocator([
            SELECT Id,
                   Lead_Id__c,
                   Contact_Id__c,
                   Lead_Owner_Id__c,
                   Lead_Status__c,
                   Lead_Email__c,
                   Contact_Email__c,
                   Account_Id__c,
                   Lead_Created_Date__c,
                   IsConverted__c,
                   Conversion_Error__c
            FROM Lead_To_Convert__c
            WHERE IsConverted__c = FALSE
            ORDER BY Lead_Created_Date__c DESC
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Lead_To_Convert__c> scope) {

        if (scope.isEmpty()) return;

        Set<Id> userOwnerIds = new Set<Id>();

        for (Lead_To_Convert__c rec : scope) {
            if (rec.Lead_Owner_Id__c != null && !String.valueOf(rec.Lead_Owner_Id__c).startsWith('00G')) {
                userOwnerIds.add(rec.Lead_Owner_Id__c);
            }
        }

        Map<Id, User> ownerMap = userOwnerIds.isEmpty()
            ? new Map<Id, User>()
            : new Map<Id, User>([
                SELECT Id, Email, FirstName, IsActive
                FROM User
                WHERE Id IN :userOwnerIds
            ]);

        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Lead> leadsToUpdateOwner = new List<Lead>();

        Id runningUserId = UserInfo.getUserId();
        Datetime sixMonthsAgo = Datetime.now().addMonths(-6);

        for (Lead_To_Convert__c rec : scope) {

            if (rec.Lead_Id__c == null || rec.Contact_Id__c == null) {
                continue;
            }

            Boolean isQueueOwner = rec.Lead_Owner_Id__c != null 
                && String.valueOf(rec.Lead_Owner_Id__c).startsWith('00G');

            User leadOwner = ownerMap.get(rec.Lead_Owner_Id__c);

            Boolean isInactiveOwner = leadOwner != null && !leadOwner.IsActive;

            if (isQueueOwner || isInactiveOwner) {
                leadsToUpdateOwner.add(new Lead(
                    Id = rec.Lead_Id__c,
                    OwnerId = runningUserId
                ));
            }

            Boolean sendEmail = true;

            if (isQueueOwner) sendEmail = false;
            if (isInactiveOwner) sendEmail = false;
            if (leadOwner != null && leadOwner.FirstName == 'Marketo') sendEmail = false;
            if (rec.Lead_Status__c == 'Disqualified' ||
                rec.Lead_Created_Date__c < sixMonthsAgo) sendEmail = false;

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(rec.Lead_Id__c);
            lc.setContactId(rec.Contact_Id__c);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Sales Qualified Lead');

            if (rec.Account_Id__c != null) {
                lc.setAccountId(rec.Account_Id__c);
            }

            conversions.add(lc);
        }

        if (!leadsToUpdateOwner.isEmpty()) {
            update leadsToUpdateOwner;
        }

        if (!conversions.isEmpty()) {

            List<Database.LeadConvertResult> results = Database.convertLead(conversions, false);

            for (Integer i = 0; i < results.size(); i++) {

                Database.LeadConvertResult res = results[i];
                Lead_To_Convert__c rec = scope[i];

                Boolean isQueueOwner = rec.Lead_Owner_Id__c != null 
                    && String.valueOf(rec.Lead_Owner_Id__c).startsWith('00G');

                User leadOwner = ownerMap.get(rec.Lead_Owner_Id__c);
                Boolean isInactiveOwner = leadOwner != null && !leadOwner.IsActive;

                Boolean sendEmail = true;

                if (isQueueOwner) sendEmail = false;
                if (isInactiveOwner) sendEmail = false;
                if (leadOwner != null && leadOwner.FirstName == 'Marketo') sendEmail = false;
                if (rec.Lead_Status__c == 'Disqualified' ||
                    rec.Lead_Created_Date__c < sixMonthsAgo) sendEmail = false;

                if (res.isSuccess()) {
                    rec.IsConverted__c = true;
                    rec.Conversion_Error__c = null;

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
                            'Lead: ' + rec.Lead_Id__c + ' (' + rec.Lead_Email__c + ')\n' +
                            'Contact: ' + rec.Contact_Id__c + ' (' + rec.Contact_Email__c + ')\n\n' +
                            'The lead information is now associated with the contact record.'
                        );

                        emailsToSend.add(mail);
                    }
                }
                else {
                    rec.IsConverted__c = false;
                    String errMsg = '';
                    for (Database.Error err : res.getErrors()) {
                        errMsg += err.getMessage() + ' | ';
                    }
                    rec.Conversion_Error__c = errMsg;
                }
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc) {
    }
}