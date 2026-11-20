global class Core_OpportunityPartnerBatchUpdate implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select Id,Core_Opportunity__c,Core_Partner_Type__c,Core_Partner__c from Core_Opportunity_Partner__c
                                         where Core_Opportunity__c != null and Core_Partner_Type__c != null and IsDeleted = false]);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_Opportunity_Partner__c> oppPartnerBatch) {
        
        for (Core_Opportunity_Partner__c oppPartner : oppPartnerBatch)
          
        Core_OpportunityPartnerHandler.opportunityPartnerFactsUpdate(oppPartnerBatch, null);
     
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Opportunity Partner -> Opportunity Facts batch status: ' + a.Status + '!');
        mail.setPlainTextBody('Opportunity Partner -> Opportunity Facts batch status: ' + a.Status + '. ' +
                              'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+
                              a.NumberOfErrors + ' failures.');
        mail.setOrgWideEmailAddressId(fromEmailAddress);                      
        mail.setToAddresses(new String[]{a.CreatedBy.Email});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}