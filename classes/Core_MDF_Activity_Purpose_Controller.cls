/*********************************
Class Name  : Core_MDF_Activity_Purpose_Controller
Function    : To show the data in the Activity details page
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Rishabh Srivastava     09/01/2026    Original version
**********************************/
public without sharing class Core_MDF_Activity_Purpose_Controller {
private static String localizeMultiSelectValues(String values, Map<String,String> localizedValueLabel) {
    if (String.isBlank(values)) {
        return '';
    }

    List<String> localizedValues = new List<String>();

    for (String value : values.split(';')) {
        String trimmedValue = value.trim();

        localizedValues.add(
            localizedValueLabel.containsKey(trimmedValue)
            ? localizedValueLabel.get(trimmedValue)
            : trimmedValue
        );
    }

    return String.join(localizedValues, ', ');
}

@AuraEnabled(cacheable=true)
public static List<ActivityOutcomeWrapper> getActivityOutcomes(Id activityId) {
    List<ActivityOutcomeWrapper> wrapperList = new List<ActivityOutcomeWrapper>();
    Map<String, String> baselineLocalizedValueLabel =
        Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'Core_MDF_Activity_Outcome__c',
            new List<String>{ 'Core_MDF_Baseline_Period_nm__c' }
        );
    Map<String, String> outcomeLocalizedValueLabel =
        Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'Core_MDF_Activity_Outcome__c',
            new List<String>{ 'Core_MDF_Outcome_Metric_nm__c' }
        );
    Map<String, String> brandLocalizedValueLabel =
        Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'Core_MDF_Activity_Outcome__c',
            new List<String>{ 'Core_MDF_Brand_nm__c' }
        );
    Map<String, String> technologyLocalizedValueLabel =
        Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'Core_MDF_Activity_Outcome__c',
            new List<String>{ 'Core_MDF_Technology_txt__c' }
        );

    if (activityId == null) return wrapperList;

    for (Core_MDF_Activity_Outcome__c record : [
        SELECT Id,
               Core_MDF_Outcome_Metric_nm__c,
               Core_MDF_Outcome_Type_nm__c,
               Core_MDF_Brand_nm__c,
               Core_MDF_Technology_txt__c,
               Core_MDF_Other_Brands_Technologies_txt__c,
               Core_MDF_Active_Ind__c,
               Core_MDF_Baseline_Value_nbr__c,
               Core_MDF_Goal_Value_nbr__c,
               Core_MDF_Result_Value_nbr__c,
               Core_MDF_Baseline_Period_nm__c,
               Core_MDF_Activity_Id__c,
               Core_MDF_Activity_Description__c,
               Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c,
               Core_MDF_Activity_Id__r.Core_MDF_Brand_nm__c,
               Core_MDF_Activity_Id__r.Core_MDF_Technology_txt__c
        FROM Core_MDF_Activity_Outcome__c
        WHERE Core_MDF_Activity_Id__c = :activityId
        AND Core_MDF_Active_Ind__c = TRUE
    ]) {
        ActivityOutcomeWrapper OutcomeWrapper = new ActivityOutcomeWrapper();

        String localizedBaselinePeriod =
            baselineLocalizedValueLabel.containsKey(record.Core_MDF_Baseline_Period_nm__c)
            ? baselineLocalizedValueLabel.get(record.Core_MDF_Baseline_Period_nm__c)
            : record.Core_MDF_Baseline_Period_nm__c;

        String brandValuesForPurpose;
        String technologyValuesForPurpose;

        if (String.isNotBlank(record.Core_MDF_Outcome_Type_nm__c)) {
            brandValuesForPurpose = record.Core_MDF_Brand_nm__c;
            technologyValuesForPurpose = record.Core_MDF_Technology_txt__c;
        } else {
            brandValuesForPurpose = record.Core_MDF_Activity_Id__r.Core_MDF_Brand_nm__c;
            technologyValuesForPurpose = record.Core_MDF_Activity_Id__r.Core_MDF_Technology_txt__c;
        }

        OutcomeWrapper.outcomeMetricApi = record.Core_MDF_Outcome_Metric_nm__c;
        OutcomeWrapper.outcomeMetric =
            outcomeLocalizedValueLabel.containsKey(record.Core_MDF_Outcome_Metric_nm__c)
            ? outcomeLocalizedValueLabel.get(record.Core_MDF_Outcome_Metric_nm__c)
            : record.Core_MDF_Outcome_Metric_nm__c;
        OutcomeWrapper.outcomeType = record.Core_MDF_Outcome_Type_nm__c;
        OutcomeWrapper.brandValues = brandValuesForPurpose;
        OutcomeWrapper.technologyValues = technologyValuesForPurpose;
        OutcomeWrapper.brandDisplayValues =
            localizeMultiSelectValues(brandValuesForPurpose, brandLocalizedValueLabel);
        OutcomeWrapper.technologyDisplayValues =
            localizeMultiSelectValues(
                technologyValuesForPurpose,
                technologyLocalizedValueLabel
            );
        OutcomeWrapper.otherBrandsTechnologies =
            record.Core_MDF_Other_Brands_Technologies_txt__c;
        OutcomeWrapper.baselineValue =
            record.Core_MDF_Baseline_Value_nbr__c != null
            ? String.valueOf(record.Core_MDF_Baseline_Value_nbr__c)
            : '';
        OutcomeWrapper.goalValue =
            record.Core_MDF_Goal_Value_nbr__c != null
            ? String.valueOf(record.Core_MDF_Goal_Value_nbr__c)
            : '';
        OutcomeWrapper.baseLinePeriod = localizedBaselinePeriod;
        OutcomeWrapper.Description =
            PrepareDyanmicText(
                record.Core_MDF_Baseline_Value_nbr__c,
                record.Core_MDF_Goal_Value_nbr__c,
                brandValuesForPurpose,
                technologyValuesForPurpose,
                localizedBaselinePeriod
            );
        OutcomeWrapper.resultValue =
            record.Core_MDF_Result_Value_nbr__c != null
            ? String.valueOf(record.Core_MDF_Result_Value_nbr__c)
            : '';
        OutcomeWrapper.isOutcomebaseActivity =
            record.Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c;

        wrapperList.add(OutcomeWrapper);
    }

    return wrapperList;
}


/***************************************************************************************************
Method Name:  saveActivityOutcome 
Version     : 1.0 
Created Date: 18/11/2025
Function    : Create Activity outcome record 
Input Parameters: Activity Id and Activity outcome base fields values wrap in the object
Output Parameters: 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   18/11/2025             Created
* Rishabh                    18/11/2025             Modified
****************************************************************************************************/
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
            for (Core_MDF_Activity_Outcome__c existing : [
    SELECT Id,
           Core_MDF_Outcome_Metric_nm__c,
           Core_MDF_Outcome_Type_nm__c,
           Core_MDF_Active_Ind__c
    FROM Core_MDF_Activity_Outcome__c
    WHERE Core_MDF_Activity_Id__c = :activityId
]) {
    existingOutcomeMap.put(
        getOutcomeKey(
            existing.Core_MDF_Outcome_Type_nm__c,
            existing.Core_MDF_Outcome_Metric_nm__c
        ),
        existing
    );
}
            
            List<Core_MDF_Activity_Outcome__c> recordsToUpsert = new List<Core_MDF_Activity_Outcome__c>();
            Set<String> incomingOutcomes = new Set<String>();
            
            // Create or update outcomes
            if (outcomeWrapperList != null && !outcomeWrapperList.isEmpty()) {
                for (ActivityOutcomeWrapper wrapper : outcomeWrapperList) {
                    if (String.isNotBlank(wrapper.outcomeMetric)) {
                        //incomingOutcomes.add(wrapper.outcomeMetric);

                        String outcomeKey = getOutcomeKey(wrapper.outcomeType,wrapper.outcomeMetric);
                        incomingOutcomes.add(outcomeKey);
                        
                        Core_MDF_Activity_Outcome__c record;
                        if (existingOutcomeMap.containsKey(outcomeKey)) {
                            record = existingOutcomeMap.get(outcomeKey);
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

                        if (String.isNotBlank(wrapper.outcomeType)) {
                            record.Core_MDF_Outcome_Type_nm__c = wrapper.outcomeType;
                            record.Core_MDF_Brand_nm__c =
                                String.isNotBlank(wrapper.brandValues)
                                ? wrapper.brandValues
                                : null;
                            record.Core_MDF_Technology_txt__c =
                                String.isNotBlank(wrapper.technologyValues)
                                ? wrapper.technologyValues
                                : null;
                            record.Core_MDF_Other_Brands_Technologies_txt__c =
                                String.isNotBlank(wrapper.otherBrandsTechnologies)
                                ? wrapper.otherBrandsTechnologies
                                : null;
                        }
                    }
                }
            }
            
            // Deactivate any removed outcomes
            for (Core_MDF_Activity_Outcome__c existingOutcome : existingOutcomeMap.values()) {
                String existingOutcomeKey = getOutcomeKey(
                        existingOutcome.Core_MDF_Outcome_Type_nm__c,
                        existingOutcome.Core_MDF_Outcome_Metric_nm__c
                    );

                    if (!incomingOutcomes.contains(existingOutcomeKey)
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
    /***************************************************************************************************
Method Name:  PrepareDyanmicText 
Version     : 1.0 
Created Date: 08/01/2026
Function    : Create a Dynamic Text
Input Parameters: baselineValue,goalValue,brand,tech,baseLinePicklistValue
Output Parameters: Dynamic sentence according to parameter
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   08/01/2026             Created
* Rishabh                    08/01/2026             Modified
****************************************************************************************************/
    
    public static String PrepareDyanmicText(Decimal baselineValue,Decimal goalValue,String brandMultiSelect,String techMultiSelect,String baseLinePicklistValue) {
        if (baselineValue == null || goalValue == null) return '';
        
        Decimal percent = (baselineValue == 0)? goalValue * 100 : ((goalValue - baselineValue) / baselineValue) * 100;
        
        Decimal absPercent = percent.abs();
        Decimal cleaned = absPercent.stripTrailingZeros();
        
        String formattedPercent =(cleaned.scale() <= 0) ? String.valueOf(cleaned.setScale(0)): String.valueOf(cleaned.setScale(2));
        
        String sentence = (percent >= 0 ? System.Label.Core_MDF_Increase_by : System.Label.Core_MDF_Decrease_by) + ' ' + formattedPercent;
        
        sentence +=  System.Label.Core_MDF_from + ' ' + baselineValue + ' ' + System.Label.Core_MDF_to_Ac + ' ' + goalValue + System.Label.Core_MDF_CloseBracket;
        
        if (!String.isBlank(baseLinePicklistValue)) {
            sentence += ' ' + baseLinePicklistValue;
        }
        
        // --- Brand localized ---
        Map<String, String> brandLocalizedMap = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'PartnerFundRequest',
            new List<String>{ 'Core_MDF_Brand_nm__c' }
        );
        
        List<String> brandValues = new List<String>();
        if (!String.isBlank(brandMultiSelect)) {
            for (String val : brandMultiSelect.split(';')) {
                brandValues.add(brandLocalizedMap.containsKey(val) ? brandLocalizedMap.get(val) : val);
            }
        }
        
        // --- Technology localized ---
        Map<String, String> techLocalizedMap = Core_MDF_Tactics_Controller.getLocalizedPicklistLabels(
            'PartnerFundRequest',
            new List<String>{ 'Core_MDF_Technology_txt__c' }
        );
        
        List<String> techValues = new List<String>();
        if (!String.isBlank(techMultiSelect)) {
            for (String val : techMultiSelect.split(';')) {
                techValues.add(techLocalizedMap.containsKey(val) ? techLocalizedMap.get(val) : val);
            }
        }
        if (!brandValues.isEmpty() && !techValues.isEmpty()) {
            sentence += ' ' + System.Label.Core_MDF_for + ' ' + String.join(brandValues, ',') + ' ' + System.Label.Core_MDF_and_Ac + ' ' + String.join(techValues, ',');
        }
        
        return sentence;
    }


    /***************************************************************************************************
    Method Name:  isResultValueEditable 
    Version     : 1.0 
    Created Date: 19/05/2026
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Shravani                   19/05/2026             Created
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean isResultValueEditable(Id activityId) {
        try {

            // First check current status
            PartnerFundRequest requestRecord = [
                SELECT Core_MDF_Fund_Request_Status__c
                FROM PartnerFundRequest
                WHERE Id = :activityId
                LIMIT 1
            ];

            // If current status is not Closed, do not allow edit
            if (requestRecord.Core_MDF_Fund_Request_Status__c != 'Closed') {
                return false;
            }

            // Fetch latest history records
            List<PartnerFundRequestHistory> historyRecords = [
                SELECT CreatedDate, NewValue
                FROM PartnerFundRequestHistory
                WHERE PartnerFundRequestId = :activityId
                AND Field = 'Core_MDF_Fund_Request_Status__c'
                ORDER BY CreatedDate DESC
            ];

            for (PartnerFundRequestHistory history : historyRecords) {

                // Latest time status changed to Closed
                if (String.valueOf(history.NewValue) == 'Closed') {
                    return history.CreatedDate.addYears(1) > Datetime.now();
                }
            }

            return false;

        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return false;
        }
    }

    @AuraEnabled(cacheable=true)
public static Boolean isActivityPurposeVisible(Id activityId) {
    if (activityId == null) {
        return true;
    }

    List<PartnerFundRequest> activityList = [
        SELECT Core_MDF_Activity_Level_nm__c
        FROM PartnerFundRequest
        WHERE Id = :activityId
        LIMIT 1
    ];

    if (activityList.isEmpty()) {
        return true;
    }

    return activityList[0].Core_MDF_Activity_Level_nm__c != 'Sub Activity';
}

private static String getOutcomeKey(String outcomeType, String outcomeMetric) {
    return String.isNotBlank(outcomeType)
        ? outcomeType + '|' + outcomeMetric
        : outcomeMetric;
}

    
    
    public class ActivityOutcomeWrapper {
        @AuraEnabled public String Description { get; set; }
        @AuraEnabled public String outcomeMetric { get; set; }
        @AuraEnabled public String outcomeMetricApi { get; set; }
        @AuraEnabled public String outcomeType { get; set; }
        @AuraEnabled public String brandValues { get; set; }
        @AuraEnabled public String technologyValues { get; set; }
        @AuraEnabled public String brandDisplayValues { get; set; }
        @AuraEnabled public String technologyDisplayValues { get; set; }
        @AuraEnabled public String otherBrandsTechnologies { get; set; }
        @AuraEnabled public String baselineValue { get; set; }
        @AuraEnabled public String goalValue { get; set; }
        @AuraEnabled public String baseLinePeriod { get; set; }
        @AuraEnabled public String resultValue { get; set; }
        @AuraEnabled public Boolean isOutcomebaseActivity { get; set; }
    }
}