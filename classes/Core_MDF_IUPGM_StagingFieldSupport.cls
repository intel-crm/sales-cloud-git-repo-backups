public with sharing class Core_MDF_IUPGM_StagingFieldSupport {
    /** Returns true when the staging object exposes the requested field at runtime. */
    public static Boolean hasField(String fieldApiName) {
        return String.isNotBlank(fieldApiName)
            && Schema.getGlobalDescribe()
                .get('Core_MDF_IUPGM_Request_Staging__c')
                .getDescribe().fields.getMap().containsKey(fieldApiName);
    }

    /** Sets a staging field only when it exists in the current org schema. */
    public static void putIfPresent(SObject record, String fieldApiName, Object value) {
        if (record == null || String.isBlank(fieldApiName)) {
            return;
        }
        Schema.SObjectField fieldRef =
            Schema.getGlobalDescribe()
                .get('Core_MDF_IUPGM_Request_Staging__c')
                .getDescribe()
                .fields.getMap()
                .get(fieldApiName);
        if (fieldRef == null || !fieldRef.getDescribe().isCreateable()) {
            return;
        }
        try {
            record.put(fieldApiName, value);
        } catch (SObjectException e) {
            // Optional staging field not available in this org; keep fallback behavior.
        }
    }

    /** Reads a staging field as text only when it exists in the current org schema. */
    public static String getStringIfPresent(SObject record, String fieldApiName) {
        if (record == null || String.isBlank(fieldApiName)) {
            return null;
        }
        Schema.SObjectField fieldRef =
            Schema.getGlobalDescribe()
                .get('Core_MDF_IUPGM_Request_Staging__c')
                .getDescribe()
                .fields.getMap()
                .get(fieldApiName);
        if (fieldRef == null || !fieldRef.getDescribe().isAccessible()) {
            return null;
        }
        try {
            Object value = record.get(fieldApiName);
            return value == null ? null : String.valueOf(value);
        } catch (SObjectException e) {
            return null;
        }
    }
}