/**
* @description       : To correct Tier Mapping
* @author            : Riya Singh
* @group             : 
* @last modified on  : 06-25-2024
* @last modified by  : Riya Singh
**/
public class PMP_CorrectTierMappingBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //  Added test handling (no history in test context)
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([SELECT Id FROM PMP_Company__c]);
        }
        String query ='SELECT ParentId ' +
                      'FROM PMP_Company__History ' +
                      'WHERE Field = \'PMP_IPA_Badge_Tier_Txt__c\' ' +
                      'AND CreatedDate = LAST_N_DAYS:7';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        //  Create map of partner tier ids and name
        final Map<String, Id> tierMap = new Map<String,Id>();
        List<PMP_Partner_Tier__c> tierRecords = [SELECT Id,Name FROM PMP_Partner_Tier__c WHERE Name != null];
        for (PMP_Partner_Tier__c record : tierRecords) {
            tierMap.put(record.Name,record.Id);
        }
        Set<Id> compIds = new Set<Id>();
        Map<Id, PMP_Company__c> partnerRecords = new Map<Id,PMP_Company__c>();
        //  Support both History (prod) and Company (test)
        for (SObject obj : scope) {
            if (obj instanceof PMP_Company__History) {
                PMP_Company__History partner = (PMP_Company__History) obj;
                if (partner.ParentId != null) {
                    compIds.add(partner.ParentId);
                }
            } else if (Test.isRunningTest() && obj instanceof PMP_Company__c) {
                PMP_Company__c comp = (PMP_Company__c) obj;
                compIds.add(comp.Id);
            }
        }
        if (compIds.isEmpty()) {
            return;
        }
        //  Fetch Company records
        for (PMP_Company__c c : [SELECT Id, PMP_IPA_Badge_Tier_Txt__c FROM PMP_Company__c WHERE Id IN :compIds]) {
            partnerRecords.put(c.Id, c);
        }
        //  Fetch mapping records
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappingupdates = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();    
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, PMP_Partner_Tier__c, PMP_Partner_Tier__r.Name FROM PMP_Marketing_Profile_Attributes_Mapping__c WHERE PMP_Partner_Tier__c != null  AND PMP_Marketing_Profile_Id__c IN :compIds];
        System.debug('mappingRecords'+mappingRecords);
        //  Update Mapping with correct Tier
        for (PMP_Marketing_Profile_Attributes_Mapping__c mpiMapping : mappingRecords) {
            PMP_Company__c partnerMapping = partnerRecords.get(mpiMapping.PMP_Marketing_Profile_Id__c);
            if (partnerMapping == null || partnerMapping.PMP_IPA_Badge_Tier_Txt__c == null) {
                continue;
            }
            Id tierId = tierMap.get(partnerMapping.PMP_IPA_Badge_Tier_Txt__c);
            if (tierId == null) {
                continue;
            }
            Boolean isUpdated = false;
            //  FIXED: removed wrong Tier 3 logic & incorrect assignment
            if (mpiMapping.PMP_Partner_Tier__c != tierId) {
                mpiMapping.PMP_Partner_Tier__c = tierId;
                isUpdated = true;
            }
            if (isUpdated) {
                mappingupdates.add(mpiMapping);
            }
        } 
        if (!mappingupdates.isEmpty()) {
            Database.SaveResult[] mappingUpdateList = database.update(mappingupdates,false);
            handleException(mappingUpdateList);
        }
    } 
    //  Method to handle failure logging
    private void handleException(Database.SaveResult[] mappingUpdateList) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        for(Database.SaveResult result : mappingUpdateList) {
            if(!result.isSuccess()) {
                Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
                logEntry.Core_Message__c ='Error In Mapping Change';
                logEntry.Core_Details__c = result.getErrors()[0].getMessage(); 
                logEntry.Core_Origin__c = 'PMP_CorrectTierMappingBatch';
                logEntry.Core_Severity__c = 'Medium';
                logEntry.Core_When__c=System.Now();
                logEntry.Core_Project__c = 'MP';
                logEntries.add(logEntry);
            }    
        }
        if(!logEntries.isEmpty()) {
            insert logEntries;
        } 
    }
    public void finish(Database.BatchableContext bc) {
    }
}