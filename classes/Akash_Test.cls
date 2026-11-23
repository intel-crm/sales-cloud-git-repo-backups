public class Akash_Test {
    @AuraEnabled
    public static Map<String, List<String>> getAllDependentPicklistValues(String recordTypeDeveloperName) {
        Map<String, List<String>> allPicklistValues = new Map<String, List<String>>();
        
        try {
            // Get all focus area values
            List<String> focusAreas = getPicklistValues('Core_MDF_Custom_Picklist__c', 'Core_MDF_Focus_Area_nm__c', recordTypeDeveloperName);
            allPicklistValues.put('focusArea', focusAreas);
            
            // Get dependent values using SOQL queries
            Set<String> allPriorities = new Set<String>();
            Set<String> allPriorities2 = new Set<String>();
            Set<String> allCountries = new Set<String>();
            Set<String> allTargetAudiences = new Set<String>();
            Set<String> allBrands = new Set<String>();
            Set<String> allTechnologies = new Set<String>();
            Set<String> allInitiatives = new Set<String>();
            Set<String> allEcosystemPartners = new Set<String>();
            Set<String> allProductTypes = new Set<String>();
            Set<String> allTactics = new Set<String>();
            Set<String> allOutcomeMetrics = new Set<String>();
            Set<String> allRegions = new Set<String>();
            
            // Query records to get actual dependent values
            List<Core_MDF_Custom_Picklist__c> records = [
                SELECT Core_MDF_Focus_Area_nm__c, Core_MDF_Priority_nm__c, Core_MDF_Priority_2_nm__c,
                       Core_MDF_Country_nm__c, Core_MDF_TargetAudience_nm__c, Core_MDF_Brand_nm__c,
                       Core_MDF_Technology__c, Core_MDF_Initiative_nm__c, Core_MDF_EcosystemPartner_nm__c,
                       Core_MDF_ProductType__c, Core_MDF_Tactics_nm__c, Core_MDF_Outcomes_nm__c,
                       Core_MDF_Outcome_Region_nm__c
                FROM Core_MDF_Custom_Picklist__c
                WHERE Core_MDF_Focus_Area_nm__c IN :focusAreas
                AND RecordType.DeveloperName = :recordTypeDeveloperName
            ];
            
            for (Core_MDF_Custom_Picklist__c record : records) {
                if (String.isNotBlank(record.Core_MDF_Priority_nm__c)) {
                    allPriorities.add(record.Core_MDF_Priority_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Priority_2_nm__c)) {
                    allPriorities2.add(record.Core_MDF_Priority_2_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Country_nm__c)) {
                    allCountries.add(record.Core_MDF_Country_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_TargetAudience_nm__c)) {
                    allTargetAudiences.add(record.Core_MDF_TargetAudience_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Brand_nm__c)) {
                    allBrands.add(record.Core_MDF_Brand_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Technology__c)) {
                    allTechnologies.add(record.Core_MDF_Technology__c);
                }
                if (String.isNotBlank(record.Core_MDF_Initiative_nm__c)) {
                    allInitiatives.add(record.Core_MDF_Initiative_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_EcosystemPartner_nm__c)) {
                    allEcosystemPartners.add(record.Core_MDF_EcosystemPartner_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_ProductType__c)) {
                    allProductTypes.add(record.Core_MDF_ProductType__c);
                }
                if (String.isNotBlank(record.Core_MDF_Tactics_nm__c)) {
                    allTactics.add(record.Core_MDF_Tactics_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Outcomes_nm__c)) {
                    allOutcomeMetrics.add(record.Core_MDF_Outcomes_nm__c);
                }
                if (String.isNotBlank(record.Core_MDF_Outcome_Region_nm__c)) {
                    allRegions.add(record.Core_MDF_Outcome_Region_nm__c);
                }
            }
            
            // Convert sets to lists and add to result map
            allPicklistValues.put('priority', new List<String>(allPriorities));
            allPicklistValues.put('priority2', new List<String>(allPriorities2));
            allPicklistValues.put('country', new List<String>(allCountries));
            allPicklistValues.put('targetAudience', new List<String>(allTargetAudiences));
            allPicklistValues.put('brands', new List<String>(allBrands));
            allPicklistValues.put('technologies', new List<String>(allTechnologies));
            allPicklistValues.put('initiatives', new List<String>(allInitiatives));
            allPicklistValues.put('ecosystemPartners', new List<String>(allEcosystemPartners));
            allPicklistValues.put('productTypes', new List<String>(allProductTypes));
            allPicklistValues.put('tactics', new List<String>(allTactics));
            allPicklistValues.put('outcomeMetrics', new List<String>(allOutcomeMetrics));
            allPicklistValues.put('regions', new List<String>(allRegions));
            
        } catch (Exception e) {
            System.debug('Error getting all dependent picklist values: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving picklist values: ' + e.getMessage());
        }
        
        return allPicklistValues;
    }

    // Helper method to get picklist values for a field
    private static List<String> getPicklistValues(String objectName, String fieldName, String recordTypeDeveloperName) {
        List<String> picklistValues = new List<String>();
        
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
            
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getValue());
                }
            }
        } catch (Exception e) {
            System.debug('Error getting picklist values for ' + fieldName + ': ' + e.getMessage());
        }
        
        return picklistValues;
    }
    public static Map<String, Object> getIPARecordType() {
        try {
            Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper wrapper = 
                Core_MDF_PFR_RecordTypeSelector.fetchRecordType('PartnerFundRequest');
            
            String ipaDevName = System.Label.Core_MDF_DCF_RecordTypeName;
            
            if(wrapper != null &&
               wrapper.recordTypeDevNameAndLabelName != null && 
               wrapper.recordTypeDevNameAndId != null &&
               wrapper.recordTypeDevNameAndLabelName.containsKey(ipaDevName) && 
               wrapper.recordTypeDevNameAndId.containsKey(ipaDevName)) {
                
                Map<String, Object> result = new Map<String, Object>{
                    'recordTypeId' => wrapper.recordTypeDevNameAndId.get(ipaDevName),
                    'recordTypeName' => wrapper.recordTypeDevNameAndLabelName.get(ipaDevName),
                    'recordTypeDeveloperName' => ipaDevName
                };
                system.debug('@@@result '+result);
                return result;
            } else {
                throw new AuraHandledException('IPA record type not found or not accessible to current user');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch IPA record type: ' + e.getMessage());
        }
    }
}