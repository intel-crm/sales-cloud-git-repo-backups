global class Temp_MapAccountIDs implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select Id, Core_CIM_ID__c from Temp_CIM_ID__c]);
    }
    
    global void execute(Database.BatchableContext bc, List<Temp_CIM_ID__c> cimIDBatch) {
        System.debug('############################# Temp_MapAccountIDs BATCH BEGIN ');
        Set<String> cimIDs = new Set<String>();
        for (Temp_CIM_ID__c cimID : cimIDBatch) {
            System.debug('###### ' + cimID);
            cimIDs.add(cimID.Core_CIM_ID__c);
        }
        List<Account> accts = [select Id, Core_CIM_ID__c, Core_Covered_Account__c from Account where Core_CIM_ID__c in :cimIDs];
        List<Temp_SFDC_ID__c> sfdcIDs = new List<Temp_SFDC_ID__c>();
        for (Account acct : accts)
            sfdcIDs.add(new Temp_SFDC_ID__c(Core_CIM_ID__c=acct.Core_CIM_ID__c, Core_SFDC_ID__c=acct.Id,
                                            Core_Covered_Account__c=acct.Core_Covered_Account__c));
        insert sfdcIDs;
        System.debug('############################# Temp_MapAccountIDs BATCH END ');
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Mapping of CIM ID to SFDC ID batch status: ' + a.Status + '!');
        mail.setPlainTextBody('Mapping of CIM ID to SFDC ID batch status: ' + a.Status + '. ' +
                              'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+
                              a.NumberOfErrors + ' failures.');
        mail.setToAddresses(new String[]{a.CreatedBy.Email});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}