/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Ecosystem_Partner_Handler 
* Test class : Core_MDF_Ecosystem_Partner_Handler_Test
* Version     : 1.0 
* Created Date: 18-12-2025
* Modification Log :
* Developer                         Date                          Description
Accenture - Akash				18-12-2025				Ecosystem Partner Percentage Allocation
**********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_Ecosystem_Partner_Handler {
    
    /**
     * @description Saves ecosystem partner allocations for a specific activity
     * @param activityId The ID of the parent activity
     * @param ecosystemPartnerValues Object containing ecosystem partner allocation data
     */
    @AuraEnabled
    public static void saveEcosystemPartnerAllocations(Id activityId, Object ecosystemPartnerValues) {
        try {
            List<EcosystemPartnerAllocationWrapper> wrapperList = (List<EcosystemPartnerAllocationWrapper>) JSON.deserialize(
                JSON.serialize(ecosystemPartnerValues), 
                List<EcosystemPartnerAllocationWrapper>.class
            );
            processEcosystemPartnerMappings(activityId, wrapperList);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException('Error saving ecosystem partner allocations: ' + e.getMessage());
        }
    }
    
    /**
     * @description Processes ecosystem partner mappings by creating or updating Core_MDF_Ecosystem_Partner_Allocation__c records
     * @param activityId The parent activity ID
     * @param wrapperList List of ecosystem partner allocation wrappers
     */
    private static void processEcosystemPartnerMappings(Id activityId, List<EcosystemPartnerAllocationWrapper> wrapperList) {
        Map<String, Core_MDF_Ecosystem_Partner_Allocation__c> existingMap = new Map<String, Core_MDF_Ecosystem_Partner_Allocation__c>();
        List<Core_MDF_Ecosystem_Partner_Allocation__c> recordsToUpsert = new List<Core_MDF_Ecosystem_Partner_Allocation__c>();
        Set<String> incomingPartnerNames = new Set<String>();
        // Get existing ecosystem partner allocations
        for (Core_MDF_Ecosystem_Partner_Allocation__c existing : [
            SELECT Id, Core_MDF_Ecosystem_Partner_txt__c, Core_MDF_Percentage_pct__c, Core_MDF_Active_Ind__c 
            FROM Core_MDF_Ecosystem_Partner_Allocation__c 
            WHERE Core_MDF_Activity_Id__c = :activityId
        ]) {
            if (String.isNotBlank(existing.Core_MDF_Ecosystem_Partner_txt__c)) {
                existingMap.put(existing.Core_MDF_Ecosystem_Partner_txt__c, existing);
            }
        }
        // Process incoming allocations
        if (wrapperList != null && !wrapperList.isEmpty()) {
            for (EcosystemPartnerAllocationWrapper wrap : wrapperList) {
                if (String.isNotBlank(wrap.ecosystemPartner)) {
                    incomingPartnerNames.add(wrap.ecosystemPartner);
                    Core_MDF_Ecosystem_Partner_Allocation__c record;
                    if (existingMap.containsKey(wrap.ecosystemPartner)) {
                        record = existingMap.get(wrap.ecosystemPartner);
                    } else {
                        record = new Core_MDF_Ecosystem_Partner_Allocation__c();
                        record.Core_MDF_Activity_Id__c = activityId;
                        record.Core_MDF_Ecosystem_Partner_txt__c = wrap.ecosystemPartner;
                    }
                    record.Core_MDF_Percentage_pct__c = wrap.percent;
                    record.Core_MDF_Active_Ind__c = true;
                    recordsToUpsert.add(record);
                }
            }
        }
        
        // Deactivate removed ecosystem partners
        for (Core_MDF_Ecosystem_Partner_Allocation__c existing : existingMap.values()) {
            if (!incomingPartnerNames.contains(existing.Core_MDF_Ecosystem_Partner_txt__c) && existing.Core_MDF_Active_Ind__c) {
                existing.Core_MDF_Active_Ind__c = false;
                recordsToUpsert.add(existing);
            }
        }
        
        if (!recordsToUpsert.isEmpty()) {
            upsert recordsToUpsert;
        }
    }
    
    /**
     * @description Retrieves stored ecosystem partner allocations for a specific activity
     * @param activityId The ID of the activity to get allocations for
     * @return List<EcosystemPartnerAllocationWrapper> List of ecosystem partner allocation wrappers with stored data
     */
    @AuraEnabled(cacheable=true)
    public static List<EcosystemPartnerAllocationWrapper> getStoredEcosystemPartnerAllocations(Id activityId) {
        List<EcosystemPartnerAllocationWrapper> results = new List<EcosystemPartnerAllocationWrapper>();
        
        try {
            for (Core_MDF_Ecosystem_Partner_Allocation__c rec : [
                SELECT Id, Core_MDF_Ecosystem_Partner_txt__c, Core_MDF_Percentage_pct__c 
                FROM Core_MDF_Ecosystem_Partner_Allocation__c 
                WHERE Core_MDF_Activity_Id__c = :activityId 
                AND Core_MDF_Active_Ind__c = true
            ]) {
                EcosystemPartnerAllocationWrapper wrap = new EcosystemPartnerAllocationWrapper();
                wrap.ecosystemPartner = rec.Core_MDF_Ecosystem_Partner_txt__c;
                wrap.percent = rec.Core_MDF_Percentage_pct__c != null ? rec.Core_MDF_Percentage_pct__c.intValue() : 0;
                results.add(wrap);
            }
        } catch (Exception e) {
            System.debug('Error loading ecosystem partner allocations: ' + e.getMessage());
        }
        
        return results;
    }
    
    /**
     * @description Wrapper class for ecosystem partner allocation data
     */
    public class EcosystemPartnerAllocationWrapper {
        @AuraEnabled public String ecosystemPartner { get; set; }
        @AuraEnabled public Decimal percent { get; set; }
        
        public EcosystemPartnerAllocationWrapper() {
            this.percent = 0;
        }
    }
}