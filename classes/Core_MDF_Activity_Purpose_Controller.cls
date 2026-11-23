public without sharing class Core_MDF_Activity_Purpose_Controller {
    @AuraEnabled(cacheable=true)
    public static List<ActivityOutcomeWrapper> getActivityOutcomes(Id activityId) {
        List<ActivityOutcomeWrapper> wrapperList = new List<ActivityOutcomeWrapper>();
        Map<String, String> baselineLocalizedValueLabel =Core_MDF_Tactics_Controller.getLocalizedPicklistLabels('Core_MDF_Activity_Outcome__c',new List<String>{ 'Core_MDF_Baseline_Period_nm__c' });
        if (activityId == null) return wrapperList;
   
        
        for (Core_MDF_Activity_Outcome__c record : [ select Id, toLabel(Core_MDF_Outcome_Metric_nm__c),Core_MDF_Active_Ind__c, Core_MDF_Baseline_Value_nbr__c, Core_MDF_Goal_Value_nbr__c, 
                                                    Core_MDF_Result_Value_nbr__c,Core_MDF_Baseline_Period_nm__c, Core_MDF_Activity_Id__c,Core_MDF_Activity_Description__c,Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c 
                                                    from Core_MDF_Activity_Outcome__c 
                                                    WHERE Core_MDF_Activity_Id__c = :activityId
                                                    AND Core_MDF_Active_Ind__c = TRUE
                                                   ]) {
                                                       ActivityOutcomeWrapper OutcomeWrapper = new ActivityOutcomeWrapper();
                                                       OutcomeWrapper.outcomeMetric = record.Core_MDF_Outcome_Metric_nm__c;
                                                       OutcomeWrapper.baselineValue = record.Core_MDF_Baseline_Value_nbr__c != null ? String.valueOf(record.Core_MDF_Baseline_Value_nbr__c) : '';
                                                       OutcomeWrapper.goalValue = record.Core_MDF_Goal_Value_nbr__c != null ? String.valueOf(record.Core_MDF_Goal_Value_nbr__c) : '';
                                                       OutcomeWrapper.baseLinePeriod = baselineLocalizedValueLabel.get(record.Core_MDF_Baseline_Period_nm__c);
                                                       OutcomeWrapper.Description=record.Core_MDF_Activity_Description__c;
                                                       OutcomeWrapper.resultValue = record.Core_MDF_Result_Value_nbr__c != null ? String.valueOf(record.Core_MDF_Result_Value_nbr__c) : '';
                                                       	OutcomeWrapper.isOutcomebaseActivity= record.Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c;
                                                       wrapperList.add(OutcomeWrapper);
                                                   }
        
        return wrapperList;
    }
    @AuraEnabled
    public static void saveActivityOutcome(Id activityId, Object outcomeActivityValues) {
        try {
            if (activityId == null) {
                throw new AuraHandledException('Activity Id is required.');
            }
            // Convert the incoming JSON/Object to a strongly typed list
            List<ActivityOutcomeWrapper> outcomeWrapperList = (List<ActivityOutcomeWrapper>) JSON.deserialize(JSON.serialize(outcomeActivityValues),List<ActivityOutcomeWrapper>.class);
            
            // Map existing active outcomes for this activity
            Map<String, Core_MDF_Activity_Outcome__c> existingOutcomeMap = new Map<String, Core_MDF_Activity_Outcome__c>();
            for (Core_MDF_Activity_Outcome__c existing : [SELECT Id, Core_MDF_Outcome_Metric_nm__c, Core_MDF_Active_Ind__c FROM Core_MDF_Activity_Outcome__c WHERE Core_MDF_Activity_Id__c = :activityId
                                                         ]) {
                                                             existingOutcomeMap.put(existing.Core_MDF_Outcome_Metric_nm__c, existing);
                                                         }
            
            List<Core_MDF_Activity_Outcome__c> recordsToUpsert = new List<Core_MDF_Activity_Outcome__c>();
            Set<String> incomingOutcomes = new Set<String>();
            
            // Create or update outcomes
            if (outcomeWrapperList != null && !outcomeWrapperList.isEmpty()) {
                for (ActivityOutcomeWrapper wrapper : outcomeWrapperList) {
                    if (String.isNotBlank(wrapper.outcomeMetric)) {
                        incomingOutcomes.add(wrapper.outcomeMetric);
                        
                        Core_MDF_Activity_Outcome__c record;
                        if (existingOutcomeMap.containsKey(wrapper.outcomeMetric)) {
                            record = existingOutcomeMap.get(wrapper.outcomeMetric);
                        } else {
                            record = new Core_MDF_Activity_Outcome__c();
                            record.Core_MDF_Activity_Id__c = activityId;
                            record.Core_MDF_Outcome_Metric_nm__c = wrapper.outcomeMetric;
                        }
                        
                        record.Core_MDF_Active_Ind__c = true;
                        record.Core_MDF_Baseline_Value_nbr__c = String.isNotBlank(wrapper.baselineValue)
                            ? Decimal.valueOf(wrapper.baselineValue)
                            : null;
                        record.Core_MDF_Goal_Value_nbr__c = String.isNotBlank(wrapper.goalValue)
                            ? Decimal.valueOf(wrapper.goalValue)
                            : null;
                        record.Core_MDF_Baseline_Period_nm__c = wrapper.baseLinePeriod;
                        record.Core_MDF_Result_Value_nbr__c = String.isNotBlank(wrapper.resultValue)
                            ? Decimal.valueOf(wrapper.resultValue)
                            : null;
                        record.Core_MDF_Activity_Description__c = wrapper.Description;
                        recordsToUpsert.add(record);
                    }
                }
            }
            
            // Deactivate any removed outcomes
            for (Core_MDF_Activity_Outcome__c existingOutcome : existingOutcomeMap.values()) {
                if (!incomingOutcomes.contains(existingOutcome.Core_MDF_Outcome_Metric_nm__c)
                    && existingOutcome.Core_MDF_Active_Ind__c) {
                        existingOutcome.Core_MDF_Active_Ind__c = false;
                        recordsToUpsert.add(existingOutcome);
                    }
            }
            
            if (!recordsToUpsert.isEmpty()) {
                upsert recordsToUpsert;
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ActivityOutcomeWrapper {
        @AuraEnabled public String Description { get; set; }
        @AuraEnabled public String outcomeMetric { get; set; }
        @AuraEnabled public String baselineValue { get; set; }
        @AuraEnabled public String goalValue { get; set; }
        @AuraEnabled public String baseLinePeriod { get; set; }
        @AuraEnabled public String resultValue { get; set; } 
		@AuraEnabled public Boolean isOutcomebaseActivity { get; set; } //  New boolean field

        // @AuraEnabled public String quantity { get; set; }
    }
    
    
}