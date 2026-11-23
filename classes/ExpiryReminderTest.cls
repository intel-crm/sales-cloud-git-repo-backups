global class ExpiryReminderTest implements Database.Batchable<SObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.today();
        Date[] reminderDates = new Date[] { today.addDays(10), today.addDays(7), today.addDays(3) };
        
        // Query to get Quotes expiring in 10, 7, and 3 days
        String query = 'SELECT Id, Name, SBQQ__Account__c, Pricing_SW_Expiry_Date__c, OwnerId, Owner.Email ' +
                       'FROM SBQQ__Quote__c WHERE Pricing_SW_Expiry_Date__c IN :reminderDates ' +
                       ' AND Pricing_Quote_Program_Nm__c = \'Software & Services\' AND Owner.Email = \'prasadx.kulkarni@intel.com\'';
                       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quotes) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        ID templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Pricing_SW_QuoteExpiryRemNotification' LIMIT 1].Id;

        for (SBQQ__Quote__c quote : quotes) {
            Integer daysLeft = quote.Pricing_SW_Expiry_Date__c.daysBetween(Date.today());

            // Create dynamic subject based on days left
            String subject = 'Reminder: ' + daysLeft + ' days left before Quote Expiry';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // Set recipient to the user associated with the quote (for example, the owner)
            System.debug('PKDebug quote.OwnerId: ' + quote.OwnerId);
            email.setTargetObjectId(quote.OwnerId); 
            email.setSaveAsActivity(false);

            // Set the email template
            System.debug('PKDebug templateId: ' + templateId);
            email.setTemplateId(templateId);
            
            // Set the dynamic subject
            System.debug('PKDebug subject: ' + subject);
            email.setSubject(subject);
            
            // Pass the Quote ID to the template
            System.debug('PKDebug quote.Id: ' + quote.Id);
            email.setWhatId('a9YDf0000008p3g');
            
            System.debug('PKDebug Email: ' + email);
            emails.add(email);
        }

        // Send emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}