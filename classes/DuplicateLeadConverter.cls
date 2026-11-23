global class DuplicateLeadConverter implements Database.Batchable<SObject>, Database.Stateful {

    // Store once per batch execution
    private Id orgWideEmailId;

    global Database.QueryLocator start(Database.BatchableContext bc) {

        //Query Org Wide Email ONLY ONCE per batch execution
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
                   IsConverted__c
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
                SELECT Id, Email, FirstName 
                FROM User 
                WHERE Id IN :userOwnerIds
            ]);

        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Lead> leadsToUpdateOwner = new List<Lead>();

        Id runningUserId = UserInfo.getUserId();
        Datetime sixMonthsAgo = Datetime.now().addMonths(-6);

        for (Lead_To_Convert__c rec : scope) {

            System.debug('Processing Lead_To_Convert__c: ' + rec.Id +
                         ' | Lead: ' + rec.Lead_Id__c +
                         ' | Contact: ' + rec.Contact_Id__c);

            if (rec.Lead_Id__c == null || rec.Contact_Id__c == null) {
                System.debug('Skipped due to missing Lead or Contact Id');
                continue;
            }

            Boolean isQueueOwner = rec.Lead_Owner_Id__c != null 
                && String.valueOf(rec.Lead_Owner_Id__c).startsWith('00G');

            User leadOwner = ownerMap.get(rec.Lead_Owner_Id__c);

            // ---------------- EMAIL LOGIC ----------------
            Boolean sendEmail = true;

            if (isQueueOwner) sendEmail = false;
            if (leadOwner != null && leadOwner.FirstName == 'Marketo') sendEmail = false;
            if (rec.Lead_Status__c == 'Disqualified' ||
                rec.Lead_Created_Date__c < sixMonthsAgo) sendEmail = false;

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

            // ---------------- QUEUE OWNER FIX ----------------
            if (isQueueOwner) {
                leadsToUpdateOwner.add(new Lead(
                    Id = rec.Lead_Id__c,
                    OwnerId = runningUserId
                ));
            }

            // ---------------- LEAD CONVERSION ----------------
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

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }

        //EXECUTE CONVERSION WITH RESULT DEBUGGING
        if (!conversions.isEmpty()) {

            List<Database.LeadConvertResult> results =
                Database.convertLead(conversions, false);

            for (Integer i = 0; i < results.size(); i++) {

                Database.LeadConvertResult res = results[i];
                Lead_To_Convert__c rec = scope[i];

                if (res.isSuccess()) {
                    System.debug('SUCCESS: Lead Converted ' + rec.Lead_Id__c);
                    rec.IsConverted__c = true;
                }
                else {
                    rec.IsConverted__c = false;

                    for (Database.Error err : res.getErrors()) {
                        System.debug('CONVERSION FAILED for Lead ' + rec.Lead_Id__c);
                        System.debug('   StatusCode: ' + err.getStatusCode());
                        System.debug('   Message: ' + err.getMessage());
                    }
                }
            }
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Duplicate Lead Conversion Batch Completed.');
    }
}