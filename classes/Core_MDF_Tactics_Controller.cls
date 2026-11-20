public without sharing class Core_MDF_Tactics_Controller {
    @AuraEnabled(cacheable=true)
        public static List<Map<String, Object>> getTacticMappings(String programName) {
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
    
        for (Core_MDF_CCP_Custom_Metadata_Utility__c mapping : [SELECT Core_MDF_Field_1_txt__c, Core_MDF_Field_2_txt__c, Core_MDF_Field_3_txt__c, Core_MDF_Program__c 
                                                                FROM Core_MDF_CCP_Custom_Metadata_Utility__c
                                                                WHERE Core_MDF_Is_Active_Ind__c = TRUE
                                                                AND Core_MDF_Category__c = 'Tactic Metrics' AND Core_MDF_Program__c =: programName
                                                                ORDER BY Core_MDF_Field_1_txt__c, Core_MDF_Field_3_txt__c ASC]) {
            String tactic = mapping.Core_MDF_Field_1_txt__c;
            String field = mapping.Core_MDF_Field_2_txt__c;
            String type = mapping.Core_MDF_Field_3_txt__c;

            if (!resultMap.containsKey(tactic)) {
                resultMap.put(tactic, new Map<String, Object>{
                    'tactic' => tactic,
                    'kpiFields' => new List<String>(),
                    'percentageField' => ''
                });
            }

            if (type == 'KPI') {
                ((List<String>)resultMap.get(tactic).get('kpiFields')).add(field);
            } else if (type == 'Percentage') {
                resultMap.get(tactic).put('percentageField', field);
            }
        }

    return resultMap.values();
        }

        @AuraEnabled
        public static KpiSaveResponse saveKpiData(Object rawRecords, Id pfrId, Boolean isProposalBased) {
            List<Core_MDF_Activity_Attributes__c> recordsToUpsert = new List<Core_MDF_Activity_Attributes__c>();
            // Deserialize input
            List<Object> records = (List<Object>) JSON.deserializeUntyped(JSON.serialize(rawRecords));
            Map<String, Boolean> tacticToHasKpiValue = new Map<String, Boolean>();
            Set<String> incomingTactics = new Set<String>();
            Set<String> processedKeys = new Set<String>(); // tactic|field|type
            Decimal totalPercentage = 0;
            //Rishabh
            Decimal totalSpendingAmount = 0;
           	Decimal maximumIntelInvestment = 0;
            // Query existing records
            Map<String, Core_MDF_Activity_Attributes__c> existingMap = new Map<String, Core_MDF_Activity_Attributes__c>();
            for (Core_MDF_Activity_Attributes__c existing : [
                SELECT Id, Core_MDF_Tactics_nm__c, Core_MDF_Field_Name_nm__c, Core_MDF_Type_nm__c, Core_MDF_Is_Active_Ind__c
                FROM Core_MDF_Activity_Attributes__c
                WHERE Core_MDF_Co_Marketing_Activity__c = :pfrId ]) {

                String key = existing.Core_MDF_Tactics_nm__c + '|' + existing.Core_MDF_Field_Name_nm__c + '|' + existing.Core_MDF_Type_nm__c;
                existingMap.put(key, existing);
            }

            for (Object raw : records) {
                Map<String, Object> record = (Map<String, Object>) raw;

                //String tactic = (String) record.get('tactic');

                String tactic;
                Object tacticObj = record.get('tactic');
                if (tacticObj instanceof Map<String, Object>) {
                    tactic = (String)((Map<String, Object>)tacticObj).get('api');
                } else {
                    tactic = String.valueOf(tacticObj);
                }
                incomingTactics.add(tactic);

                // Handle percentage
                //String percentageField = (String) record.get('percentageField');

                Map<String, Object> percentageFieldObj = (Map<String, Object>) record.get('percentageField');
                String percentageFieldApi = (String) percentageFieldObj.get('api');               
                Object pctVal = record.get('percentageValue');
                Decimal percentageValue; //= record.containsKey('percentageValue') ? Decimal.valueOf(String.valueOf(record.get('percentageValue'))) : null;
                //Rishabh
                Object spdngAmount = record.get('intelContri');
                Object maxIntelContribution = record.get('maxIntelInvest');
				Decimal spendingAmount = 0;
                Decimal maxIntelCon = 0;
                
				
               
                
                if (pctVal != null && String.valueOf(pctVal).trim() != '' && !String.isBlank(String.valueOf(spdngAmount)) && !String.isBlank(String.valueOf(maxIntelContribution))) {
                    percentageValue = Decimal.valueOf(String.valueOf(pctVal));
                    spendingAmount = Decimal.valueOf(String.valueOf(spdngAmount));
                    maxIntelCon = Decimal.valueOf(String.valueOf(maxIntelContribution));
                    
                    if (percentageValue < 0 || percentageValue > 100) {
                        throw new AuraHandledException(System.Label.Core_MDF_Spending_Percentage_Range_Error); //Spending Percentage must be between 0 and 100
                    }
                    if (percentageValue.scale() > 2) {
                        throw new AuraHandledException(System.Label.Core_MDF_Spending_Percentage_Decimal_Error); //Spending Percentage must be decimals.
                    }
                    if(maximumIntelInvestment == 0){
                        maximumIntelInvestment = maxIntelCon;
                    }
        
                   // totalPercentage += percentageValue;
						totalSpendingAmount += spendingAmount; // Rishabh

                    String key = tactic + '|' + percentageFieldApi + '|Percentage';
                    processedKeys.add(key);

                    Core_MDF_Activity_Attributes__c existing = existingMap.get(key);
                    if (existing != null && pfrId != null) {
                        existing.Core_MDF_Field_Value_nbr__c = percentageValue;
                        existing.Core_MDF_Spending_Amount_amt__c = spendingAmount; //rishabh
                        existing.Core_MDF_Is_Active_Ind__c = true;
                        recordsToUpsert.add(existing);
                    } else {
                        recordsToUpsert.add(new Core_MDF_Activity_Attributes__c(
                            Core_MDF_Co_Marketing_Activity__c = pfrId,
                            Core_MDF_Field_Name_nm__c = percentageFieldApi,
                            Core_MDF_Field_Value_nbr__c = percentageValue,
                            Core_MDF_Spending_Amount_amt__c = spendingAmount, //rishabh
                            Core_MDF_Is_Active_Ind__c = true,
                            Core_MDF_Type_nm__c = 'Percentage',
                            Core_MDF_Tactics_nm__c = tactic
                        ));
                    }
                }
                else {
                    //throw new AuraHandledException('Please enter a percentage value for ' + tactic);
                    throw new AuraHandledException(System.Label.Core_MDF_Spending_Percentage_Blank_Error); //Spending Percentage cannot be blank
                }

                Boolean hasAtLeastOneKPIValue = false;

                // First KPI
                Map<String, Object> firstKpi = (Map<String, Object>) record.get('firstKpi');
                //if (firstKpi != null) {
                    //String label = (String) firstKpi.get('label');

                    String firstkpiApi = (String) firstKpi.get('api');
                    Object val = firstKpi.get('value');
                    Decimal firstKpiValue;
                    if (val != null && String.valueOf(val).toLowerCase().trim() != 'null' && String.valueOf(val).trim() != '') {
                        firstKpiValue = Decimal.valueOf(String.valueOf(val));
                        hasAtLeastOneKPIValue = true;
                        if(hasMoreThanTwoDecimals(firstKpiValue)){
                            throw new AuraHandledException(System.Label.Core_MDF_Goal_Value_Decimal_Error); //Please enter Goal values upto 2 decimal places only.
                        }
                        if(firstKpiValue < 0){
                            throw new AuraHandledException(System.Label.Core_MDF_Goal_Value_Negative_Error); //Goal values cannot be negative
                        }
                    }

                        String key = tactic + '|' + firstkpiApi + '|KPI';
                        processedKeys.add(key);

                        Core_MDF_Activity_Attributes__c existing = existingMap.get(key);
                        if (existing != null && pfrId != null) {
                            existing.Core_MDF_Field_Value_nbr__c = firstKpiValue;
                            existing.Core_MDF_Is_Active_Ind__c = true;
                            recordsToUpsert.add(existing);
                        } else {
                            recordsToUpsert.add(new Core_MDF_Activity_Attributes__c(
                                Core_MDF_Co_Marketing_Activity__c = pfrId,
                                Core_MDF_Field_Name_nm__c = firstkpiApi,
                                Core_MDF_Field_Value_nbr__c = firstKpiValue,
                                Core_MDF_Is_Active_Ind__c = true,
                                Core_MDF_Type_nm__c = 'KPI',
                                Core_MDF_Tactics_nm__c = tactic
                            ));
                        }
                   // }
                //}

                // Other KPIs
                List<Object> otherKpis = (List<Object>) record.get('otherKpis');
                //if (otherKpis != null) {
                    for (Object kpiObj : otherKpis) {
                        Map<String, Object> kpi = (Map<String, Object>) kpiObj;
                        
                            String otherKpiApi = (String) kpi.get('api');
                           
                        Object otherKpiVal = kpi.get('value');
                        Decimal otherKpiValue;
                        if (otherKpiVal != null && String.valueOf(otherKpiVal).trim() != '') {
                            otherKpiValue = Decimal.valueOf(String.valueOf(otherKpiVal));
                            hasAtLeastOneKPIValue = true;
                            if(hasMoreThanTwoDecimals(otherKpiValue)){
                                throw new AuraHandledException(System.Label.Core_MDF_Goal_Value_Decimal_Error); //Please enter Goal values upto 2 decimal places only.
                            }
                            if(otherKpiValue < 0){
                                throw new AuraHandledException(System.Label.Core_MDF_Goal_Value_Negative_Error); //Goal values cannot be negative
                            }
                        }

                            String otherKpiKey = tactic + '|' + otherKpiApi + '|KPI';
                            processedKeys.add(otherKpiKey);

                            Core_MDF_Activity_Attributes__c existingOtherKpi = existingMap.get(otherKpiKey);
                            if (existingOtherKpi != null && pfrId != null) {
                                existingOtherKpi.Core_MDF_Field_Value_nbr__c = otherKpiValue;
                                existingOtherKpi.Core_MDF_Is_Active_Ind__c = true;
                                recordsToUpsert.add(existingOtherKpi);
                            } else {
                                recordsToUpsert.add(new Core_MDF_Activity_Attributes__c(
                                    Core_MDF_Co_Marketing_Activity__c = pfrId,
                                    Core_MDF_Field_Name_nm__c = otherKpiApi,
                                    Core_MDF_Field_Value_nbr__c = otherKpiValue,
                                    Core_MDF_Is_Active_Ind__c = true,
                                    Core_MDF_Type_nm__c = 'KPI',
                                    Core_MDF_Tactics_nm__c = tactic
                                ));
                            }
                        //}
                    }
                //}

                tacticToHasKpiValue.put(tactic, hasAtLeastOneKPIValue);
            }

           /* if (totalPercentage != 100) {
                throw new AuraHandledException(System.Label.Core_MDF_Percentage_Sum_Error); //The percentage values must total 100%. Please adjust the fields to ensure the sum equals 100%.
            }*/
           
            
            if (maximumIntelInvestment.setScale(2) != totalSpendingAmount.setScale(2)) {
                throw new AuraHandledException(System.Label.Core_MDF_Percentage_Sum_Error); 
            }

            // Final KPI validation
            List<String> kpiMissingList = new List<String>();
            for (String tactic : tacticToHasKpiValue.keySet()) {
                if (!tacticToHasKpiValue.get(tactic)) {
                    kpiMissingList.add(tactic);
                }
            }
            if (!kpiMissingList.isEmpty()) {
                //throw new AuraHandledException('Please enter at least one tactic metrics value for: ' + String.join(missing, ', '));
                throw new AuraHandledException(System.Label.Core_MDF_Tactic_Metrics_Mandatory_Error); //Please enter at least one Metrics value per Tactic.
            }

            // Deactivate removed tactic fields
            for (String key : existingMap.keySet()) {
                if (!processedKeys.contains(key)) {
                    Core_MDF_Activity_Attributes__c toDeactivate = existingMap.get(key);
                    toDeactivate.Core_MDF_Is_Active_Ind__c = false;
                    recordsToUpsert.add(toDeactivate);
                }
            }
            if(isProposalBased){
                return new KpiSaveResponse(true, recordsToUpsert);
            }
            else{
                // Final upsert
                if (!recordsToUpsert.isEmpty()) {
                    upsert recordsToUpsert;
                }
            }
            return null;
        }

     @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getSavedKpiData(Id pfrId) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    // Get picklist label maps for tactics and KPI field names
    Map<String, String> tacticLabelMap = new Map<String, String>();
    Map<String, String> fieldLabelMap = new Map<String, String>();

    // Describe picklists
    Schema.DescribeFieldResult tacticField = Core_MDF_Activity_Attributes__c.Core_MDF_Tactics_nm__c.getDescribe();
    Schema.DescribeFieldResult fieldNameField = Core_MDF_Activity_Attributes__c.Core_MDF_Field_Name_nm__c.getDescribe();

    for (Schema.PicklistEntry entry : tacticField.getPicklistValues()) {
        tacticLabelMap.put(entry.getValue(), entry.getLabel());
    }
    for (Schema.PicklistEntry entry : fieldNameField.getPicklistValues()) {
        fieldLabelMap.put(entry.getValue(), entry.getLabel());
    }

    List<Core_MDF_Activity_Attributes__c> records = [
        SELECT Id, Core_MDF_Co_Marketing_Activity__c, Core_MDF_Co_Marketing_Activity__r.Core_MDF_Activity_Reimbursement_Amt_nbr__c, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c,
               Core_MDF_Type_nm__c, Core_MDF_Tactics_nm__c,Core_MDF_Spending_Amount_amt__c //rishabh
        FROM Core_MDF_Activity_Attributes__c
        WHERE Core_MDF_Co_Marketing_Activity__c = :pfrId AND Core_MDF_Is_Active_Ind__c = TRUE
    ];

    Map<String, Map<String, Object>> tacticMap = new Map<String, Map<String, Object>>();

    for (Core_MDF_Activity_Attributes__c rec : records) {
        String tactic = rec.Core_MDF_Tactics_nm__c;
        String tacticLabel = tacticLabelMap.get(tactic);
        String fieldApi = rec.Core_MDF_Field_Name_nm__c;
        String fieldLabel = fieldLabelMap.get(fieldApi);
        Decimal intelContribution = rec.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Activity_Reimbursement_Amt_nbr__c;

        if (!tacticMap.containsKey(tactic)) {
            tacticMap.put(tactic, new Map<String, Object>{
                'tactic' => tactic,
                'tacticLabel' => tacticLabel,
                'percentageField' => '',
                'percentageFieldLabel' => '',
                'percentageValue' => null,
                'spendingAmount' => null,   //Risabh
                'firstKpi' => null,
                'otherKpis' => new List<Map<String, Object>>(),
                'intelContribution' => intelContribution
            });
        }

        Map<String, Object> tacticData = tacticMap.get(tactic);
        if (rec.Core_MDF_Type_nm__c == 'Percentage') {
            tacticData.put('percentageField', fieldApi);
            tacticData.put('percentageFieldLabel', fieldLabel);
            tacticData.put('percentageValue', rec.Core_MDF_Field_Value_nbr__c);
            tacticData.put('spendingAmount', rec.Core_MDF_Spending_Amount_amt__c); //Rishabh
        } else if (rec.Core_MDF_Type_nm__c == 'KPI') {
            Map<String, Object> kpiEntry = new Map<String, Object>{
                'api' => fieldApi,
                'label' => fieldLabel,
                'value' => rec.Core_MDF_Field_Value_nbr__c
            };
            if (tacticData.get('firstKpi') == null) {
                tacticData.put('firstKpi', kpiEntry);
            } else {
                ((List<Map<String, Object>>) tacticData.get('otherKpis')).add(kpiEntry);
            }
        }
    }

    result.addAll(tacticMap.values());
    return result;
}

        public class KpiSaveResponse {
            @AuraEnabled public Boolean noError;
            @AuraEnabled public List<Core_MDF_Activity_Attributes__c> records;
        
            public KpiSaveResponse(Boolean noError,  List<Core_MDF_Activity_Attributes__c> records) {
                this.noError = noError;
                this.records = records;
            }
        }

        public static boolean hasMoreThanTwoDecimals(Decimal value){
            String valueString = String.valueOf(value);
            if(valueString.contains('.')){
                String decimalPart = valueString.split('\\.')[1];
                return decimalPart.length() > 2;
            }
            return false;
        }

@AuraEnabled(cacheable=true)
public static Map<String, String> getPicklistLabels() {
    Map<String, String> labelMap = new Map<String, String>();

    // Describe the custom object and relevant fields
    //Avoid Using Empty Schema Methods
    Schema.DescribeSObjectResult objDescribe = Core_MDF_Activity_Attributes__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED);

    // List of picklist fields you care about
    List<String> fieldsToLocalize = new List<String>{
        'Core_MDF_Tactics_nm__c',
        'Core_MDF_Field_Name_nm__c'
    };

    for (String fieldName : fieldsToLocalize) {
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            labelMap.put(entry.getValue(), entry.getLabel()); // English API → Localized Label
        }
    }

    return labelMap;
}

    //Test Class: Core_MDF_PFC_IPAClaim_Test
    public static Map<String, String> getLocalizedPicklistLabels(String objectApiName, List<String> fieldApiNames) {
        Map<String, String> result = new Map<String, String>();

        // Get object describe
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);

        Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objDescribe.fields.getMap();

        for (String fieldName : fieldApiNames) {
            Schema.SObjectField field = fieldsMap.get(fieldName);
            if (field != null) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry entry : entries) {
                    result.put(entry.getValue(), entry.getLabel());
                }
            }
        }

        return result;
    }

    //Test Class: Core_MDF_PFC_IPAClaim_Test
    public static List<FieldInfo> getLocalizedFieldMetadata(List<String> objectList, List<String> fieldList) {
        List<FieldInfo> result = new List<FieldInfo>();

        for (String objectName : objectList) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
            if (sObjectType == null) continue;

            Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

            for (String fieldName : fieldList) {
                if (fieldMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
                    result.add(new FieldInfo(objectName, fieldName, fieldDesc.getLabel(), fieldDesc.getInlineHelpText()));
                }
            }
        }

        return result;
    }

    public class FieldInfo {
        @AuraEnabled public String objectName { get; set; }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String label { get; set; }     // Localized label
        @AuraEnabled public String helpText { get; set; }  // Localized help text

        public FieldInfo(String objectName, String fieldName, String label, String helpText) {
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.label = label;
            this.helpText = helpText;
        }
    }

    //Test Class: Core_MDF_PFC_IPAClaim_Test
    @AuraEnabled
    public static List<TacticSpendingWrpper> getTacticSpending(Boolean editable , String claimId, String activityId) {//@@Amount field checks
        Map<String, TacticSpendingWrpper> tacticToTacticSpendingMap = new Map<String, TacticSpendingWrpper>();
        Map<String, String> picklistValueToLocalizedLabelMap = getLocalizedPicklistLabels('Core_MDF_Activity_Attributes__c', new List<String>{'Core_MDF_Tactics_nm__c','Core_MDF_Field_Name_nm__c'});
		List<String> programList = Label.Core_MDF_Program_Enabled_Tactics.split(',');

        //PartnerFundRequest activity = [SELECT Id, RequestedAmount, Core_MDF_Program__c, Core_MDF_ActivityCategory__c, Core_MDF_Reimbursement_Rate__c FROM PartnerFundRequest WHERE Id =: activityId LIMIT 1];

        Boolean ipaOutcomeBased = false;
        Decimal requestedAmount;
        String reimbursementRate;
        /*if(activity != null){
            ipaOutcomeBased = (activity.Core_MDF_Program__c == 'Intel Partner Alliance' && activity.Core_MDF_ActivityCategory__c == 'Outcome-Based') ? true : false;
        }*/
        
        if(String.isNotBlank(claimId)){
            for(Core_MDF_Claim_Attributes__c claimAttribute : [SELECT Id, Core_MDF_Claim_Id__r.Request.Core_MDF_Reimbursement_Rate__c, Core_MDF_Claim_Id__r.Request.RequestedAmount, Core_MDF_Claim_Id__r.Request.Core_MDF_Program__c, Core_MDF_Claim_Id__r.Request.Core_MDF_ActivityCategory__c,   Core_MDF_Type_nm__c, Core_MDF_Tactics_nm__c, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c FROM Core_MDF_Claim_Attributes__c WHERE Core_MDF_Type_nm__c IN ('Percentage','Total Planned Spend' ,'Spend This Period', 'Previous Period Spends' ) AND Core_MDF_Is_Active_Ind__c = true AND Core_MDF_Claim_Id__c =: claimId ORDER BY Core_MDF_Tactics_nm__c]){
                
                if(!ipaOutcomeBased){ // Rishabh
                    ipaOutcomeBased = (programList.contains(claimAttribute.Core_MDF_Claim_Id__r.Request.Core_MDF_Program__c) && claimAttribute.Core_MDF_Claim_Id__r.Request.Core_MDF_ActivityCategory__c == 'Outcome-Based') ? true : false;
                    requestedAmount = claimAttribute.Core_MDF_Claim_Id__r.Request.RequestedAmount;
                    reimbursementRate = claimAttribute.Core_MDF_Claim_Id__r.Request.Core_MDF_Reimbursement_Rate__c;
                }

                TacticSpendingWrpper tacticSpending = new TacticSpendingWrpper();
                if(tacticToTacticSpendingMap.containsKey(claimAttribute.Core_MDF_Tactics_nm__c)){
                    tacticSpending = tacticToTacticSpendingMap.get(claimAttribute.Core_MDF_Tactics_nm__c);
                }

                if(claimAttribute.Core_MDF_Type_nm__c == 'Total Planned Spend'){
                    tacticSpending.totalPlannedSpend = claimAttribute.Core_MDF_Field_Value_nbr__c;
                    tacticSpending.totalPlannedSpendRecordId = claimAttribute.Id;
                }else if(claimAttribute.Core_MDF_Type_nm__c == 'Previous Period Spends'){
                    tacticSpending.previousSpend = claimAttribute.Core_MDF_Field_Value_nbr__c;
                    tacticSpending.previousSpendRecordId = claimAttribute.Id;
                }else if(claimAttribute.Core_MDF_Type_nm__c == 'Spend This Period'){
                    tacticSpending.spendThisPeriod = claimAttribute.Core_MDF_Field_Value_nbr__c;
                    tacticSpending.spendThisPeriodRecordId = claimAttribute.Id;
                }

                tacticSpending.tactic = claimAttribute.Core_MDF_Tactics_nm__c;
                tacticSpending.tacticLabel = picklistValueToLocalizedLabelMap.containsKey(claimAttribute.Core_MDF_Tactics_nm__c) ? picklistValueToLocalizedLabelMap.get(claimAttribute.Core_MDF_Tactics_nm__c) : claimAttribute.Core_MDF_Tactics_nm__c;
                tacticSpending.reimbursementRate = Decimal.valueOf(reimbursementRate.replace('%',''));
                tacticSpending.editable = editable;
                tacticSpending.ipaOutcomeBased = ipaOutcomeBased;

                tacticToTacticSpendingMap.put(claimAttribute.Core_MDF_Tactics_nm__c, tacticSpending);
            }

            List<TacticSpendingWrpper> tacticSpendingList = new List<TacticSpendingWrpper>();
            for(TacticSpendingWrpper tacticSpending : tacticToTacticSpendingMap.values()){
                tacticSpending.remainingSpend = tacticSpending.totalPlannedSpend - tacticSpending.previousSpend;
                tacticSpending.intelContribution = (tacticSpending.spendThisPeriod * (Decimal.valueOf(reimbursementRate.replace('%','')) / 100));
                tacticSpendingList.add(tacticSpending);
            }

            return tacticSpendingList;

        }else if(String.isNotBlank(activityId)){

            //Calculate Previous Period Spend
            Map<String, Decimal> tacticToPreviousPeriodSpendAmount = new Map<String, Decimal>();
            List<String> notAllowedCancelStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimAllowedCancelStatuses').split(';');
            //Id latestActiveClaimId;
            /*Boolean isFirstRecord = true;
            for(Core_MDF_Claim_Attributes__c claimAttribute : [SELECT Id, Core_MDF_Claim_Id__c, Core_MDF_Tactics_nm__c, Core_MDF_Type_nm__c, Core_MDF_Field_Value_nbr__c, Core_MDF_Claim_Id__r.RequestId FROM Core_MDF_Claim_Attributes__c WHERE Core_MDF_Type_nm__c IN ('Spend This Period', 'Previous Period Spends' ) AND Core_MDF_Claim_Id__r.RequestId =: activityId AND Core_MDF_Is_Active_Ind__c = true ORDER BY Core_MDF_Claim_Id__r.Core_MDF_Claim_Ref_Number__c DESC, Core_MDF_Tactics_nm__c]){
                if(isFirstRecord){
                    latestActiveClaimId = claimAttribute.Core_MDF_Claim_Id__c;
                    isFirstRecord = false;
                }

                if(latestActiveClaimId == claimAttribute.Core_MDF_Claim_Id__c){
                    if(!tacticToPreviousPeriodSpendAmount.containsKey(claimAttribute.Core_MDF_Tactics_nm__c)){
                        tacticToPreviousPeriodSpendAmount.put(claimAttribute.Core_MDF_Tactics_nm__c, claimAttribute.Core_MDF_Field_Value_nbr__c);
                    }else{
                        Decimal previousPeriodSpend = tacticToPreviousPeriodSpendAmount.get(claimAttribute.Core_MDF_Tactics_nm__c);
                        tacticToPreviousPeriodSpendAmount.put(claimAttribute.Core_MDF_Tactics_nm__c, (previousPeriodSpend + claimAttribute.Core_MDF_Field_Value_nbr__c));
                    }  
                }else{
                    break;
                }
            }*/
            for( Core_MDF_Claim_Attributes__c claimAttribute : [Select Core_MDF_Tactics_nm__c,Core_MDF_Field_Value_nbr__c,Core_MDF_Claim_Id__c,Core_MDF_Claim_Id__r.Core_MDF_Status__c from Core_MDF_Claim_Attributes__c where Core_MDF_Type_nm__c = 'Spend This Period' and Core_MDF_Is_Active_Ind__c = true and Core_MDF_Claim_Id__r.RequestId = :activityId and Core_MDF_Claim_Id__r.Core_MDF_Status__c NOT IN :notAllowedCancelStatuses]){
               String tactic = claimAttribute.Core_MDF_Tactics_nm__c;
               Decimal value = claimAttribute.Core_MDF_Field_Value_nbr__c;
               if(tacticToPreviousPeriodSpendAmount.containsKey(tactic)){
                Decimal existingValue = tacticToPreviousPeriodSpendAmount.get(tactic); 
                tacticToPreviousPeriodSpendAmount.put(tactic,existingValue + value);
               }else{
                tacticToPreviousPeriodSpendAmount.put(tactic,value); 
               } // indu defect fix
            }
            Decimal reimbursementRateDecimal ;

            for(Core_MDF_Activity_Attributes__c activityAttribute : [SELECT Id, Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c, Core_MDF_Co_Marketing_Activity__r.Core_MDF_ActivityCategory__c, Core_MDF_Co_Marketing_Activity__r.RequestedAmount, Core_MDF_Co_Marketing_Activity__r.Core_MDF_Reimbursement_Rate__c, Core_MDF_Type_nm__c, Core_MDF_Tactics_nm__c, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c, Core_MDF_Co_Marketing_Activity__c, Core_MDF_Is_Active_Ind__c, Core_MDF_Spending_Amount_amt__c FROM Core_MDF_Activity_Attributes__c WHERE Core_MDF_Co_Marketing_Activity__c =: activityId AND Core_MDF_Type_nm__c ='Percentage' AND Core_MDF_Field_Value_nbr__c > 0 AND Core_MDF_Is_Active_Ind__c = true AND Core_MDF_Tactics_nm__c != null ORDER BY Core_MDF_Tactics_nm__c]){
                
                if(!ipaOutcomeBased){
                    ipaOutcomeBased = (programList.contains(activityAttribute.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Program__c) && activityAttribute.Core_MDF_Co_Marketing_Activity__r.Core_MDF_ActivityCategory__c == 'Outcome-Based') ? true : false;
                    requestedAmount = activityAttribute.Core_MDF_Co_Marketing_Activity__r.RequestedAmount;
                    reimbursementRate = activityAttribute.Core_MDF_Co_Marketing_Activity__r.Core_MDF_Reimbursement_Rate__c;
                }

                //Calculate Previous Period Spend
                Decimal previousPeriodSpend = 0.0;
                if(tacticToPreviousPeriodSpendAmount.containsKey(activityAttribute.Core_MDF_Tactics_nm__c)){
                    previousPeriodSpend = tacticToPreviousPeriodSpendAmount.get(activityAttribute.Core_MDF_Tactics_nm__c);
                }

                TacticSpendingWrpper spendingWrapper = new TacticSpendingWrpper();
                spendingWrapper.tactic = activityAttribute.Core_MDF_Tactics_nm__c;
                spendingWrapper.tacticLabel = picklistValueToLocalizedLabelMap.containsKey(activityAttribute.Core_MDF_Tactics_nm__c) ? picklistValueToLocalizedLabelMap.get(activityAttribute.Core_MDF_Tactics_nm__c) : activityAttribute.Core_MDF_Tactics_nm__c;
                //For new records(where spending amount is not blank), Calculate TotalPlannedSpend based on Core_MDF_Spending_Amount_amt__c and RR%
                //For older records(where spending amount is blank), Calculate TotalPlannedSpend based on requestedAmount, RR% and spending percentage
                reimbursementRateDecimal = Decimal.valueOf(reimbursementRate.replace('%',''));
                spendingWrapper.totalPlannedSpend = activityAttribute.Core_MDF_Spending_Amount_amt__c != null ? (activityAttribute.Core_MDF_Spending_Amount_amt__c * 100) / reimbursementRateDecimal : (requestedAmount * activityAttribute.Core_MDF_Field_Value_nbr__c) / 100;
                spendingWrapper.totalPlannedSpend = spendingWrapper.totalPlannedSpend.setScale(2); 
				//spendingWrapper.totalPlannedSpend = String.isNotBlank(String.valueOf(activityAttribute.Core_MDF_Spending_Amount_amt__c)) ? activityAttribute.Core_MDF_Spending_Amount_amt__c : (requestedAmount * activityAttribute.Core_MDF_Field_Value_nbr__c) / 100;
                spendingWrapper.previousSpend = previousPeriodSpend.setScale(2);
                spendingWrapper.remainingSpend = spendingWrapper.totalPlannedSpend - spendingWrapper.previousSpend;
                spendingWrapper.reimbursementRate = Decimal.valueOf(reimbursementRate.replace('%',''));
                spendingWrapper.editable = editable;
                spendingWrapper.ipaOutcomeBased = ipaOutcomeBased;

                tacticToTacticSpendingMap.put(activityAttribute.Core_MDF_Tactics_nm__c, spendingWrapper);
            }
        }

        return tacticToTacticSpendingMap.values();
    }

    public class TacticSpendingWrpper{
        @AuraEnabled public String tactic { get; set; }
        @AuraEnabled public String tacticLabel { get; set; }
        @AuraEnabled public Decimal totalPlannedSpend { get; set; }
        @AuraEnabled public Id totalPlannedSpendRecordId { get; set; }
        @AuraEnabled public Decimal previousSpend { get; set; }
        @AuraEnabled public Id previousSpendRecordId { get; set; }
        @AuraEnabled public Decimal remainingSpend { get; set; }
        @AuraEnabled public Decimal spendThisPeriod { get; set; }
        @AuraEnabled public Id spendThisPeriodRecordId { get; set; }
        @AuraEnabled public Boolean editable { get; set; }
        @AuraEnabled public Decimal intelContribution { get; set; }
        @AuraEnabled public Decimal reimbursementRate { get; set; }
        @AuraEnabled public Boolean ipaOutcomeBased { get; set; }
    }

    //Test Class: Core_MDF_PFC_IPAClaim_Test
    @AuraEnabled
    public static void updateClaimAttributes(Map<String, String> claimIdToClaimRefNumberMap, Map<String, Map<String, Decimal>> claimIdToTacticDiffMap, String operation) {
        try {
            if (claimIdToClaimRefNumberMap == null || claimIdToClaimRefNumberMap.isEmpty()) return;
            
            // Step 1: Fetch all involved claims
            List<PartnerFundClaim> claimList = [
                SELECT Id, RequestId, Core_MDF_Status__c, Core_MDF_Claim_Ref_Number__c 
                FROM PartnerFundClaim 
                WHERE Id IN: claimIdToClaimRefNumberMap.keySet()
            ];
            
            Map<Id, PartnerFundClaim> cancelledClaims = new Map<Id, PartnerFundClaim>();
            Map<Id, String> claimIdToPrefix = new Map<Id, String>();
            Map<Id, Integer> claimIdToSuffix = new Map<Id, Integer>();
            Set<Id> activityIdSet = new Set<Id>();
            
            for (PartnerFundClaim claim : claimList) {
                String ref = claim.Core_MDF_Claim_Ref_Number__c;
                if (String.isNotBlank(ref) && ref.contains('-')) {
                    String[] parts = ref.split('-');
                    cancelledClaims.put(claim.Id, claim);
                    claimIdToPrefix.put(claim.Id, parts[0]);
                    claimIdToSuffix.put(claim.Id, Integer.valueOf(parts[1]));
                    activityIdSet.add(claim.RequestId);
                }
            }
            if (cancelledClaims.isEmpty()) return;
            
            // Step 2: Fetch all claims for same activity
            List<PartnerFundClaim> allRelatedClaimList = [
                SELECT Id, Core_MDF_Status__c, Core_MDF_Claim_Ref_Number__c 
                FROM PartnerFundClaim 
                WHERE RequestId IN: activityIdSet
            ];
            
            // Step 3: Fetch all claim attributes
            List<Core_MDF_Claim_Attributes__c> claimAttributeList = [
                SELECT Id, Core_MDF_Claim_Id__c, Core_MDF_Tactics_nm__c, Core_MDF_Field_Value_nbr__c, 
                    Core_MDF_Type_nm__c, Core_MDF_Is_Active_Ind__c, 
                    Core_MDF_Claim_Id__r.Core_MDF_Claim_Ref_Number__c, 
                    Core_MDF_Claim_Id__r.Core_MDF_Status__c
                FROM Core_MDF_Claim_Attributes__c
                WHERE Core_MDF_Is_Active_Ind__c = true
                AND Core_MDF_Type_nm__c IN ('Previous Period Spends', 'Spend This Period')
                AND Core_MDF_Claim_Id__r.RequestId IN: activityIdSet
            ];
            
            // Step 4: Organize attributes by claimId + tactic
            Map<Id, Map<String, Core_MDF_Claim_Attributes__c>> claimAttrByTypeAndTactic = new Map<Id, Map<String, Core_MDF_Claim_Attributes__c>>();
            for (Core_MDF_Claim_Attributes__c attr : claimAttributeList) {
                Id claimId = attr.Core_MDF_Claim_Id__c;
                if (!claimAttrByTypeAndTactic.containsKey(claimId)) {
                    claimAttrByTypeAndTactic.put(claimId, new Map<String, Core_MDF_Claim_Attributes__c>());
                }
                String key = attr.Core_MDF_Type_nm__c + '::' + attr.Core_MDF_Tactics_nm__c;
                claimAttrByTypeAndTactic.get(claimId).put(key, attr);
            }
            
            List<Core_MDF_Claim_Attributes__c> claimAttributeUpdateList = new List<Core_MDF_Claim_Attributes__c>();
            List<String> allowedStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllowedStatsTacticMetric').split(',');
            List<String> notAllowedCancelStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimAllowedCancelStatuses').split(';');
            allowedStatuses.addAll(notAllowedCancelStatuses); // Indu - Added for including cancelled and RWC statuses
            
            // Step 5: For each cancelled claim
            for (Id cancelledId : cancelledClaims.keySet()) {
                PartnerFundClaim cancelledClaim = cancelledClaims.get(cancelledId);
                String prefix = claimIdToPrefix.get(cancelledId);
                Integer suffix = claimIdToSuffix.get(cancelledId);
                
                // --- Collect tactics & STP values from cancelled claim ---
                Map<String, Decimal> spendThisPeriodAmounts = new Map<String, Decimal>();
                Map<String, Core_MDF_Claim_Attributes__c> cancelledAttrs = claimAttrByTypeAndTactic.get(cancelledId);
                if (cancelledAttrs != null && operation == 'Cancel') {
                    for (String key : cancelledAttrs.keySet()) {
                        if (key.startsWith('Spend This Period::')) {
                            String tactic = key.split('::')[1];
                            Core_MDF_Claim_Attributes__c attr = cancelledAttrs.get(key);
                            spendThisPeriodAmounts.put(tactic, attr.Core_MDF_Field_Value_nbr__c);
                            // always set STP to 0 for cancelled claim
                            claimAttributeUpdateList.add(
                                new Core_MDF_Claim_Attributes__c(Id = attr.Id, Core_MDF_Field_Value_nbr__c = 0)
                            );
                        }
                    }
                }
                
                // --- Branch by operation ---
                if (operation == 'Edit' && claimIdToTacticDiffMap != null && claimIdToTacticDiffMap.containsKey(cancelledId)) {
                    // CASE 1: Edit → Use per-tactic diffs
                    Map<String, Decimal> tacticDiffs = claimIdToTacticDiffMap.get(cancelledId);
                    if (tacticDiffs == null || tacticDiffs.isEmpty()) continue;
                    
                    for (PartnerFundClaim other : allRelatedClaimList) {
                        if (other.Id == cancelledId || !allowedStatuses.contains(other.Core_MDF_Status__c)) continue;
                        if (String.isBlank(other.Core_MDF_Claim_Ref_Number__c) || !other.Core_MDF_Claim_Ref_Number__c.contains('-')) continue;
                        
                        List<String> otherParts = other.Core_MDF_Claim_Ref_Number__c.split('-');
                        if (otherParts.size() != 2) continue;
                        if (otherParts[0] != prefix || Integer.valueOf(otherParts[1]) <= suffix) continue;
                        
                        Map<String, Core_MDF_Claim_Attributes__c> otherAttrs = claimAttrByTypeAndTactic.get(other.Id);
                        if (otherAttrs == null) continue;
                        
                        for (String tactic : tacticDiffs.keySet()) {
                            String ppsKey = 'Previous Period Spends::' + tactic;
                            if (otherAttrs.containsKey(ppsKey)) {
                                Decimal diffValue = tacticDiffs.get(tactic);
                                if (diffValue != null && diffValue != 0) {
                                    diffValue = diffValue * -1;
                                    Core_MDF_Claim_Attributes__c targetAttr = otherAttrs.get(ppsKey);
                                    targetAttr.Core_MDF_Field_Value_nbr__c += diffValue; // add if -, subtract if +
                                    /*if (diffValue > 0) {
                                        targetAttr.Core_MDF_Field_Value_nbr__c -= diffValue;
                                    } else {
                                        targetAttr.Core_MDF_Field_Value_nbr__c += diffValue;
                                    }*/
                                    claimAttributeUpdateList.add(targetAttr);
                                }
                            }
                        }
                    }
                } 
                else if (operation == 'Cancel') {
                    // CASE 2: Cancel → Fallback to original "reduction" logic
                    for (PartnerFundClaim other : allRelatedClaimList) {
                        if (other.Id == cancelledId || !allowedStatuses.contains(other.Core_MDF_Status__c)) continue;
                        if (String.isBlank(other.Core_MDF_Claim_Ref_Number__c) || !other.Core_MDF_Claim_Ref_Number__c.contains('-')) continue;
                        
                        List<String> otherParts = other.Core_MDF_Claim_Ref_Number__c.split('-');
                        if (otherParts.size() != 2) continue;
                        if (otherParts[0] != prefix || Integer.valueOf(otherParts[1]) <= suffix) continue;
                        
                        Map<String, Core_MDF_Claim_Attributes__c> otherAttrs = claimAttrByTypeAndTactic.get(other.Id);
                        if (otherAttrs == null) continue;
                        
                        for (String tactic : spendThisPeriodAmounts.keySet()) {
                            String ppsKey = 'Previous Period Spends::' + tactic;
                            if (otherAttrs.containsKey(ppsKey)) {
                                Core_MDF_Claim_Attributes__c targetAttr = otherAttrs.get(ppsKey);
                                targetAttr.Core_MDF_Field_Value_nbr__c -= spendThisPeriodAmounts.get(tactic);
                                claimAttributeUpdateList.add(targetAttr);
                            }
                        }
                    }
                }
            }
            
            if (!claimAttributeUpdateList.isEmpty()) {
                update claimAttributeUpdateList;
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

}