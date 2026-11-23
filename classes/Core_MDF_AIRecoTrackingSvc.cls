public with sharing class Core_MDF_AIRecoTrackingSvc {
    // public static void saveTracking(Id activityId, Object rawEntries, PartnerFundRequest pfr) {
    //     if (rawEntries == null) {
    //         return;
    //     }

    //     List<Object> entries = (List<Object>)JSON.deserializeUntyped(JSON.serialize(rawEntries));
    //     if (entries == null || entries.isEmpty()) {
    //         return;
    //     }

    //     List<Core_MDF_AI_Recommendation_Tracking__c> recordsToInsert = new List<Core_MDF_AI_Recommendation_Tracking__c>();
    //     Datetime decisionTimestamp = System.now();

    //     for (Object rawEntry : entries) {
    //         if (!(rawEntry instanceof Map<String, Object>)) {
    //             continue;
    //         }

    //         Map<String, Object> entry = (Map<String, Object>)rawEntry;
    //         Core_MDF_AI_Recommendation_Tracking__c trackingRecord = new Core_MDF_AI_Recommendation_Tracking__c();
    //         trackingRecord.Core_MDF_Activity__c = activityId;
    //         trackingRecord.Core_MDF_User__c = UserInfo.getUserId();
    //         trackingRecord.Core_MDF_AI_Recommendation__c = truncate(valueAsString(entry.get('fieldLabel')), 255);
    //         trackingRecord.Core_MDF_AI_Recommendation_Details__c = buildDetails(entry);
    //         trackingRecord.Core_MDF_Recommendation_Used__c = valueAsBoolean(entry.get('recommendationUsed'));
    //         trackingRecord.Core_MDF_User_Decision__c = truncate(valueAsString(entry.get('userDecision')), 255);
    //         trackingRecord.Core_MDF_Decision_Date__c = decisionTimestamp;
    //         trackingRecord.Core_MDF_Activity_Last_Modified_Date__c = decisionTimestamp;
    //         trackingRecord.Core_MDF_Approval_Stage__c = pfr != null ? pfr.Core_MDF_Approval_Stage__c : null;
    //         trackingRecord.Core_MDF_Field_API_Name__c = truncate(valueAsString(entry.get('fieldApiName')), 255);
    //         trackingRecord.Core_MDF_Field_Label__c = truncate(valueAsString(entry.get('fieldLabel')), 255);
    //         trackingRecord.Core_MDF_Target_Object__c = truncate(valueAsString(entry.get('targetObject')), 100);
    //         trackingRecord.Core_MDF_Target_Record_Key__c = truncate(valueAsString(entry.get('targetRecordKey')), 255);
    //         trackingRecord.Core_MDF_Pre_AI_Value__c = truncate(valueAsString(entry.get('preAiValue')), 32768);
    //         trackingRecord.Core_MDF_AI_Suggested_Value__c = truncate(valueAsString(entry.get('aiSuggestedValue')), 32768);
    //         trackingRecord.Core_MDF_Applied_Value__c = truncate(valueAsString(entry.get('appliedValue')), 32768);
    //         trackingRecord.Core_MDF_Final_Saved_Value__c = truncate(valueAsString(entry.get('finalSavedValue')), 32768);
    //         trackingRecord.Core_MDF_Is_Modified_After_Apply__c = valueAsBoolean(entry.get('isModifiedAfterApply'));
    //         trackingRecord.Core_MDF_Modification_Type__c = truncate(valueAsString(entry.get('modificationType')), 255);
    //         trackingRecord.Core_MDF_AI_Request_Group_Id__c = truncate(valueAsString(entry.get('groupId')), 80);
    //         trackingRecord.Core_MDF_AI_Source_Type__c = truncate(valueAsString(entry.get('sourceType')), 255);
    //         trackingRecord.Core_MDF_AI_Source_Files__c = truncate(valueAsString(entry.get('sourceFiles')), 32768);
    //         trackingRecord.Core_MDF_Field_Path__c = truncate(valueAsString(entry.get('fieldPath')), 255);
    //         recordsToInsert.add(trackingRecord);
    //     }

    //     if (!recordsToInsert.isEmpty()) {
    //         insert recordsToInsert;
    //     }
    // }

    // private static String buildDetails(Map<String, Object> entry) {
    //     Map<String, Object> details = new Map<String, Object>{
    //         'groupId' => entry.get('groupId'),
    //         'sourceType' => entry.get('sourceType'),
    //         'fieldPath' => entry.get('fieldPath'),
    //         'targetObject' => entry.get('targetObject'),
    //         'targetRecordKey' => entry.get('targetRecordKey')
    //     };
    //     return truncate(JSON.serialize(details), 32768);
    // }

    // private static String valueAsString(Object value) {
    //     if (value == null) {
    //         return null;
    //     }
    //     if (value instanceof String) {
    //         return (String)value;
    //     }
    //     if (value instanceof Decimal || value instanceof Integer || value instanceof Long || value instanceof Double || value instanceof Boolean) {
    //         return String.valueOf(value);
    //     }
    //     return JSON.serialize(value);
    // }

    // private static Boolean valueAsBoolean(Object value) {
    //     if (value == null) {
    //         return false;
    //     }
    //     if (value instanceof Boolean) {
    //         return (Boolean)value;
    //     }
    //     return String.valueOf(value).toLowerCase() == 'true';
    // }

    // private static String truncate(String value, Integer maxLength) {
    //     if (value == null) {
    //         return null;
    //     }
    //     if (value.length() <= maxLength) {
    //         return value;
    //     }
    //     return value.substring(0, maxLength);
    // }
}