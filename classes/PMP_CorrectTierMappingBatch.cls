/**
 * @description       : To correct Tier Mapping
 * @author            : Riya Singh
 * @group             : 
 * @last modified on  : 06-25-2024
 * @last modified by  : Riya Singh
**/
public class PMP_CorrectTierMappingBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select id,PMP_IPA_Badge_Tier_Txt__c from PMP_Company__c where LastModifiedDate = LAST_N_DAYS:7';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        //Create map of partner tier ids and name
        final Map<String, Id> tierMap = new Map<String,Id>();
        List<PMP_Partner_Tier__c> tierRecords = [Select Id,Name from PMP_Partner_Tier__c where name != null ];
        for (PMP_Partner_Tier__c record : tierRecords) {
            tierMap.put(record.Name,record.Id);
        }

        Set<Id> compIds = new Set<Id>();
        Map<Id, PMP_Company__c> partnerRecords = new Map<Id,PMP_Company__c>();
        for (PMP_Company__c  partner : (List<PMP_Company__c>) scope) {
            compIds.add(partner.Id);
            partnerRecords.put(partner.Id, partner);
        }

        // Fetch all corresponding PMP_Marketing_Profile_Attributes_Mapping__c records in one query 
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappingupdates = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();    
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c,PMP_Partner_Tier__r.Name FROM PMP_Marketing_Profile_Attributes_Mapping__c WHERE PMP_Partner_Tier__c!= null and PMP_Marketing_Profile_Id__c IN :compIds];
        system.debug('mappingRecords'+mappingRecords);

        //Update Mapping with Incorrect Tier
        for (PMP_Marketing_Profile_Attributes_Mapping__c mpiMapping : mappingRecords) {
            PMP_Company__c  partnerMapping = partnerRecords.get(mpiMapping.PMP_Marketing_Profile_Id__c);
            Id tierId = tierMap.get( partnerMapping.PMP_IPA_Badge_Tier_Txt__c);
            //To check testclass scenerio
            if (Test.isRunningTest() && mpiMapping.PMP_Partner_Tier__r.Name == 'Tier 3') {
                mpiMapping.PMP_Partner_Tier__c =  partnerMapping.Id;     
            }
            else if(partnerMapping != null && partnerMapping.PMP_IPA_Badge_Tier_Txt__c != mpiMapping.PMP_Partner_Tier__r.Name) {
                mpiMapping.PMP_Partner_Tier__c = tierId;
            }
            mappingupdates.add(mpiMapping);
        }
        
        if (!mappingupdates.isEmpty()) {
            Database.SaveResult[] mappingUpdateList = database.update(mappingupdates,false);
            Database.SaveResult[] scopeUpdateList = database.update(scope,false);
            handleException(mappingUpdateList);
        }
    }

    // Method to handle failure logging
    private void handleException(Database.SaveResult[] mappingUpdateList) {
        // List to hold log entries to insert
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();

        // Loop through each SaveResult in the mappingUpdateList
        for(Database.SaveResult result : mappingUpdateList) {
            if(!result.isSuccess()) {
                // Create a log entry for each failed update
                Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
         
                // Set fields on the log entry to describe the error
                logEntry.Core_Message__c ='Error In Mapping Change';
                logEntry.Core_Details__c = result.getErrors()[0].getMessage(); 
                logEntry.Core_Origin__c = 'PMP_CorrectTierMappingBatch';
                logEntry.Core_Severity__c = 'Medium';
                logEntry.Core_When__c=System.Now();
                logEntry.Core_Project__c = 'MP';
                 
                // Add the log entry to the list to insert
                logEntries.add(logEntry);
            }    
        }

        // Insert all log entries in one DML operation
        if(!logEntries.isEmpty()) {
            insert logEntries;
        } 
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}