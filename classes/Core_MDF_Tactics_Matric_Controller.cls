public without sharing class Core_MDF_Tactics_Matric_Controller {

    @AuraEnabled
    public static List<TacticKpiWrapper> getTacticMappings(String activityId, String recordId) {
        Map<String, String> picklistValueToLocalizedLabelMap = Core_MDF_Tactics_Controller.getPicklistLabels(); // In this Method pass field label and get localized Label
        Map<String, TacticKpiWrapper> tacticMap = new Map<String, TacticKpiWrapper>();
		
        
        if (String.isNotBlank(recordId)) {
            tacticMap = getTacticMappingsByRecordId(recordId, picklistValueToLocalizedLabelMap); // This Method Call in case of Edit and when showing on detail page
        } else if (String.isNotBlank(activityId)) {												
            tacticMap = getTacticMappingsByActivityId(activityId, picklistValueToLocalizedLabelMap); // This Method call in case of Create and Clone
        }

        return tacticMap.values();
    }
	// This Method Call in case of Edit and when showing on detail page
	@AuraEnabled
    public static Map<String, TacticKpiWrapper> getTacticMappingsByRecordId(String recordId, Map<String, String> picklistValueToLocalizedLabelMap) {
        Map<String, TacticKpiWrapper> tacticMap = new Map<String, TacticKpiWrapper>();

        for (Core_MDF_Claim_Attributes__c mapping : [SELECT Id, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c, Core_MDF_Type_nm__c, Core_MDF_Tactics_nm__c,
                                                     Core_MDF_Claim_Id__r.Core_MDF_Program__c, Core_MDF_Claim_Id__r.Core_MDF_Activity_Category__c
                                                     FROM Core_MDF_Claim_Attributes__c
                                                     WHERE Core_MDF_Claim_Id__c = :recordId
                                                     AND Core_MDF_Is_Active_Ind__c = TRUE 
                                                     AND Core_MDF_Tactics_nm__c != Null]) {
            String tacticName = picklistValueToLocalizedLabelMap.containsKey(mapping.Core_MDF_Tactics_nm__c)
                ? picklistValueToLocalizedLabelMap.get(mapping.Core_MDF_Tactics_nm__c)
                : mapping.Core_MDF_Tactics_nm__c;

            TacticKpiWrapper wrapper;
            if (tacticMap.containsKey(tacticName)) {
                wrapper = tacticMap.get(tacticName);
            } else {
                wrapper = new TacticKpiWrapper();
                wrapper.tactic = tacticName;
                wrapper.ipaOutcomeBased = ((mapping.Core_MDF_Claim_Id__r.Core_MDF_Program__c == 'Intel Partner Alliance' ||
                                            mapping.Core_MDF_Claim_Id__r.Core_MDF_Program__c == 'Datacenter' ||
                                            mapping.Core_MDF_Claim_Id__r.Core_MDF_Program__c == 'Client') && mapping.Core_MDF_Claim_Id__r.Core_MDF_Activity_Category__c == 'Outcome-Based') ? true : false;//made changes
                wrapper.kpis = new List<FieldValue>();
                wrapper.kpiMap = new Map<String, FieldValue>();
                tacticMap.put(tacticName, wrapper);
            }

            String fieldName = mapping.Core_MDF_Field_Name_nm__c;
            FieldValue kpi;
            if (wrapper.kpiMap.containsKey(fieldName)) {
                kpi = wrapper.kpiMap.get(fieldName);
            } else {
                kpi = new FieldValue();
                kpi.tacticMetrics = picklistValueToLocalizedLabelMap.containsKey(fieldName)
                    ? picklistValueToLocalizedLabelMap.get(fieldName)
                    : fieldName;
                if (String.isNotBlank(kpi.tacticMetrics)) {
                    wrapper.kpiMap.put(fieldName, kpi);
                    wrapper.kpis.add(kpi);
                }
            }

            if (mapping.Core_MDF_Type_nm__c == 'KPI - Activity') {
                kpi.activityAttributevalue = mapping.Core_MDF_Field_Value_nbr__c!=null ? mapping.Core_MDF_Field_Value_nbr__c : 0;
                kpi.kpiActivityAttributesId = mapping.Id;
            } else if (mapping.Core_MDF_Type_nm__c == 'KPI - Claim') {
                kpi.claimAttributeValue = mapping.Core_MDF_Field_Value_nbr__c!=null ? (Integer)mapping.Core_MDF_Field_Value_nbr__c : 0;
                kpi.kpiClaimAttributesId = mapping.Id;
            }
        }

        return tacticMap;
    }
	// This Method call in case of Create or Clone
	@AuraEnabled
    public static Map<String, TacticKpiWrapper> getTacticMappingsByActivityId(String activityId, Map<String, String> picklistValueToLocalizedLabelMap) {
        Map<String, TacticKpiWrapper> tacticMap = new Map<String, TacticKpiWrapper>();

        for (Core_MDF_Activity_Attributes__c mapping : [SELECT Id, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c, Core_MDF_Co_Marketing_Activity__c, Core_MDF_Type_nm__c,
                                                        Core_MDF_Tactics_nm__c, Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c, Core_MDF_Co_Marketing_Activity__r.Core_MDF_ActivityCategory__c 
                                                        FROM Core_MDF_Activity_Attributes__c 
                                                        WHERE Core_MDF_Co_Marketing_Activity__c = :activityId 
                                                        AND Core_MDF_Is_Active_Ind__c = TRUE 
                                                        AND Core_MDF_Field_Value_nbr__c != NULL
                                                        AND Core_MDF_Type_nm__c = 'KPI']) {
            String tacticName = picklistValueToLocalizedLabelMap.containsKey(mapping.Core_MDF_Tactics_nm__c)
                ? picklistValueToLocalizedLabelMap.get(mapping.Core_MDF_Tactics_nm__c)
                : mapping.Core_MDF_Tactics_nm__c;

            TacticKpiWrapper wrapper;
            if (tacticMap.containsKey(tacticName)) {
                wrapper = tacticMap.get(tacticName);
            } else {
                wrapper = new TacticKpiWrapper();
                wrapper.tactic = tacticName;
                wrapper.tacticLabelForRecordCreation = mapping.Core_MDF_Tactics_nm__c;
                wrapper.ipaOutcomeBased = ((mapping.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c == 'Intel Partner Alliance' ||
                                            mapping.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c == 'Datacenter' ||
                                            mapping.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c == 'Client') && mapping.Core_MDF_Co_Marketing_Activity__r.Core_MDF_ActivityCategory__c == 'Outcome-Based') ? true : false;//made changes
                wrapper.kpis = new List<FieldValue>();
                wrapper.kpiMap = new Map<String, FieldValue>();
                tacticMap.put(tacticName, wrapper);
            }

            String fieldName = mapping.Core_MDF_Field_Name_nm__c;
            FieldValue kpi;
            if (wrapper.kpiMap.containsKey(fieldName)) {
                kpi = wrapper.kpiMap.get(fieldName);
            } else {
                kpi = new FieldValue();
                kpi.tacticMetrics = picklistValueToLocalizedLabelMap.containsKey(fieldName)
                    ? picklistValueToLocalizedLabelMap.get(fieldName)
                    : fieldName;
                kpi.tacticMetricsLabelForRecordCreation = mapping.Core_MDF_Field_Name_nm__c;
                if (String.isNotBlank(kpi.tacticMetrics)) {
                    wrapper.kpiMap.put(fieldName, kpi);
                    wrapper.kpis.add(kpi);
                }
            }

            kpi.activityAttributevalue = mapping.Core_MDF_Field_Value_nbr__c;
            kpi.claimAttributeValue = null;
        }

        return tacticMap;
    }
    
	// Initialize wrapper 
    public class TacticKpiWrapper {
        @AuraEnabled public String tactic;									// Here we store the tactic localized label
        @AuraEnabled public String tacticLabelForRecordCreation;			// Here we store the tactic label for record Creation
        @AuraEnabled public Boolean ipaOutcomeBased;						// Here check this IPA program activity
        @AuraEnabled public List<FieldValue> kpis;							// In this list we store the below FieldValue
        public Map<String, FieldValue> kpiMap;
    }

    public class FieldValue {
        @AuraEnabled public String tacticMetrics;							// Here we store the tactic Metrics localized label
        @AuraEnabled public String tacticMetricsLabelForRecordCreation;  	// Here we store the tactic Metrics label for record Creation
        @AuraEnabled public Decimal activityAttributevalue;					// Here we store the either Activity attribute or claim attribute value having type is KPI-Activity
        @AuraEnabled public Integer claimAttributeValue;    				// Here we store the Claim Attribute value having type is KPI-Claim
        @AuraEnabled public Id kpiClaimAttributesId;       					// Here we store the Claim Attribute Id
        @AuraEnabled public Id kpiActivityAttributesId;   		            // Here we store the Attribute Id
    }
}