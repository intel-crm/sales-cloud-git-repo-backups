global class RoleAndTierUpdate implements Database.Batchable<SObject>, Database.Stateful {

    private Map<String, Id> roleMap = new Map<String, Id>();
    private Map<String, Id> tierMap = new Map<String, Id>();
    private Integer processedCount = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (roleMap.isEmpty() || tierMap.isEmpty()) {
            initializeLookups();
        }
	  return Database.getQueryLocator([
            SELECT Id, PMP_Partner_Role__c, PMP_Partner_Tier__c,
                   PMP_Partner_Segment__c, PMP_Partner_Specialty__c
            FROM PMP_Marketing_Profile_Attributes_Mapping__c
            WHERE PMP_Partner_Role__c IN :roleMap.keySet()
               OR PMP_Partner_Tier__c IN :tierMap.keySet()
               OR PMP_Partner_Segment__c != null
               OR PMP_Partner_Specialty__c != null
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<PMP_Marketing_Profile_Attributes_Mapping__c> updates = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();
        for (PMP_Marketing_Profile_Attributes_Mapping__c record : (List<PMP_Marketing_Profile_Attributes_Mapping__c>) scope) {
            Boolean isChanged = false;

            if (roleMap.containsKey(record.PMP_Partner_Role__c)) {
                System.debug('Updating Role for record Id ' + record.Id);
                record.PMP_Partner_Role__c = roleMap.get(record.PMP_Partner_Role__c);
                isChanged = true;
            }

            if (tierMap.containsKey(record.PMP_Partner_Tier__c)) {
                System.debug('Updating Tier for record Id ' + record.Id);
                record.PMP_Partner_Tier__c = tierMap.get(record.PMP_Partner_Tier__c);
                isChanged = true;
            }

            if (record.PMP_Partner_Segment__c != null || record.PMP_Partner_Specialty__c != null) {
                System.debug('Clearing Segment and Specialty for record Id ' + record.Id);
                record.PMP_Partner_Segment__c = null;
                record.PMP_Partner_Specialty__c = null;
                isChanged = true;
            }

            if (isChanged) {
                updates.add(record);
                processedCount++;
                System.debug('Record marked for update: ' + record);
            }
        }

        if (!updates.isEmpty()) {
            System.debug('Performing update on records: ' + updates);
            update updates;
        } else {
            System.debug('No records to update in this batch.');
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateMarketingProfileBatch completed.');
        System.debug('Total records processed: ' + processedCount);
    }

    private void initializeLookups() {
        
        for (PMP_Partner_Program__c role : [
            SELECT Id, Name FROM PMP_Partner_Program__c
            WHERE Name IN ('Manufacturer', 'Original Equipment Manufacturer (OEM)', 'Solution Provider', 'Builder', 'Solution Integrator')
        ]) {
            System.debug('Found role: ' + role.Name + ' => ' + role.Id);
            if (role.Name == 'Manufacturer' || role.Name == 'Original Equipment Manufacturer (OEM)') {
                Id targetId = getRoleIdByName('Builder');
                roleMap.put(role.Id, targetId);
                System.debug('Mapped to Builder: ' + targetId);
            } else if (role.Name == 'Solution Provider') {
                Id targetId = getRoleIdByName('Solution Integrator');
                roleMap.put(role.Id, targetId);
                System.debug('Mapped to Solution Integrator: ' + targetId);
            }
        }

        for (PMP_Partner_Tier__c tier : [
            SELECT Id, Name FROM PMP_Partner_Tier__c
            WHERE Name IN ('Member', 'Gold', 'Titanium', 'Partner', 'Prestige')
        ]) {
            System.debug('Found tier: ' + tier.Name + ' => ' + tier.Id);
            if (tier.Name == 'Member' || tier.Name == 'Gold') {
                Id targetId = getTierIdByName('Partner');
                tierMap.put(tier.Id, targetId);
                System.debug('Mapped to Partner: ' + targetId);
            } else if (tier.Name == 'Titanium') {
                Id targetId = getTierIdByName('Prestige');
                tierMap.put(tier.Id, targetId);
                System.debug('Mapped to Prestige: ' + targetId);
            }
        }

        System.debug('Final roleMap: ' + roleMap);
        System.debug('Final tierMap: ' + tierMap);
    }

    private Id getRoleIdByName(String roleName) {
        PMP_Partner_Program__c role = [SELECT Id FROM PMP_Partner_Program__c WHERE Name = :roleName LIMIT 1];
        System.debug('Fetched role ID for ' + roleName + ': ' + role.Id);
        return role.Id;
    }

    private Id getTierIdByName(String tierName) {
        PMP_Partner_Tier__c tier = [SELECT Id FROM PMP_Partner_Tier__c WHERE Name = :tierName LIMIT 1];
        System.debug('Fetched tier ID for ' + tierName + ': ' + tier.Id);
        return tier.Id;
    }
}