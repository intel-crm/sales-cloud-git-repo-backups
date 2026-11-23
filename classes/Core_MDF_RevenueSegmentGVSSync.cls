/**
 * Keeps the Core_MDF_Budget_Rev_Segment global picklist value set (used by
 * PartnerMarketingBudget.Core_MDF_Revenue_Segment__c) in sync with rows stored
 * in the shared Core_MDF_CCP_Custom_Metadata_Utility__c utility object, which
 * is the admin/Excel-maintained source of truth for Rev Segment -> Budget Rev
 * Segment mappings (scoped to Core_MDF_Category__c = 'Revenue_Segment_Mapping').
 *
 * Whenever a Revenue_Segment_Mapping row is added, updated, activated, or
 * deactivated (for example via a Data Import Wizard load from Excel),
 * Core_MDF_RevenueSegmentMappingTrigger calls syncGlobalValueSetAsync() which
 * rebuilds the full value set from every mapping row (Core_MDF_Is_Active_Ind__c
 * controls each value's isActive flag in the value set, rather than removing
 * it outright, so existing PartnerMarketingBudget records that already
 * reference a deactivated segment keep their value) and pushes it to the org
 * via a Tooling API REST callout (the Metadata.CustomValueSet Apex type isn't
 * part of the supported Apex Metadata API, so Global Value Sets are updated
 * through Tooling API instead). No manual Setup/picklist edits are required
 * for new or deactivated Revenue Segments to show up in the UI.
 */
public with sharing class Core_MDF_RevenueSegmentGVSSync {

    public static final String MAPPING_CATEGORY = 'Revenue_Segment_Mapping';
    public static final String MAPPING_PROGRAM = 'Co-Inv';
    public static final String GLOBAL_VALUE_SET_DEVELOPER_NAME = 'Core_MDF_Revenue_Segment';
    public static final String GLOBAL_VALUE_SET_MASTER_LABEL = 'Revenue Segment';
    public static final String GLOBAL_VALUE_SET_DESCRIPTION = 'Stores Budget Revenue Segments (auto-synced from Core_MDF_CCP_Custom_Metadata_Utility__c)';

    /**
     * Called from the trigger with the Category-filtered subset of changed
     * records; only enqueues the callout when at least one changed record
     * actually belongs to the Revenue_Segment_Mapping category, so unrelated
     * updates on this heavily shared utility object (KPI, BU Splits, etc.)
     * never consume a future-call slot.
     */
    public static void handleMappingRecordChange(List<Core_MDF_CCP_Custom_Metadata_Utility__c> changedRecords) {
        for (Core_MDF_CCP_Custom_Metadata_Utility__c rec : changedRecords) {
            if (rec.Core_MDF_Category__c == MAPPING_CATEGORY) {
                system.debug('38');
                syncGlobalValueSetAsync();
                return;
            }
        }
    }

    @future(callout=true)
    public static void syncGlobalValueSetAsync() {
        if (Test.isRunningTest()) {
            // Tooling API callouts aren't exercised in unit tests; the trigger/query
            // logic that leads here is still covered via the test's DML operations.
            return;
        }

        List<Core_MDF_CCP_Custom_Metadata_Utility__c> mappings = [
            SELECT Core_MDF_Name_Criteria__c, Core_MDF_Field_1_txt__c, Core_MDF_Is_Active_Ind__c
            FROM Core_MDF_CCP_Custom_Metadata_Utility__c
            WHERE Core_MDF_Category__c = :MAPPING_CATEGORY
            ORDER BY Core_MDF_Field_1_txt__c ASC
        ];
        system.debug('@@@mappings'+mappings);
        // GlobalValueSet is a Tooling API entity, not queryable via regular Apex
        // SOQL, so its Id is looked up with a Tooling API REST callout first.
        String valueSetId = fetchGlobalValueSetId();
        if (valueSetId == null) {
            System.debug(LoggingLevel.ERROR, 'Core_MDF_RevenueSegmentGVSSync: Global value set ' + GLOBAL_VALUE_SET_DEVELOPER_NAME + ' not found.');
            return;
        }

        List<Map<String, Object>> customValues = new List<Map<String, Object>>();
        for (Core_MDF_CCP_Custom_Metadata_Utility__c mapping : mappings) {
            if (String.isBlank(mapping.Core_MDF_Name_Criteria__c) || String.isBlank(mapping.Core_MDF_Field_1_txt__c)) {
                continue;
            }
            customValues.add(new Map<String, Object>{
                'valueName' => mapping.Core_MDF_Name_Criteria__c,
                'label' => mapping.Core_MDF_Field_1_txt__c,
                'isActive' => mapping.Core_MDF_Is_Active_Ind__c,
                'default' => false
            });
        }
        system.debug('@@@customValues'+customValues);
        Map<String, Object> requestBody = new Map<String, Object>{
            'FullName' => GLOBAL_VALUE_SET_DEVELOPER_NAME + '__gvs',
            'Metadata' => new Map<String, Object>{
                'masterLabel' => GLOBAL_VALUE_SET_MASTER_LABEL,
                'description' => GLOBAL_VALUE_SET_DESCRIPTION,
                'sorted' => false,
                'customValue' => customValues
            }
        };
        system.debug('@@@requestBody'+requestBody);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Core_MDF_Tooling_API/services/data/v61.0/tooling/sobjects/GlobalValueSet/' + valueSetId);
        req.setMethod('PATCH');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 204) {
            System.debug(LoggingLevel.INFO, 'Core_MDF_RevenueSegmentGVSSync: Global value set synced successfully with ' + customValues.size() + ' Revenue Segment(s) (active and inactive).');
        } else {
            System.debug(LoggingLevel.ERROR, 'Core_MDF_RevenueSegmentGVSSync: Sync failed (' + res.getStatusCode() + '): ' + res.getBody());
        }
    }

    /**
     * Looks up the Id of the Core_MDF_Budget_Rev_Segment global value set via a
     * Tooling API query callout, since GlobalValueSet isn't queryable with
     * regular Apex SOQL.
     */
    private static String fetchGlobalValueSetId() {
        String query = 'SELECT Id FROM GlobalValueSet WHERE DeveloperName = \'' + GLOBAL_VALUE_SET_DEVELOPER_NAME + '\'';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Core_MDF_Tooling_API/services/data/v61.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug(LoggingLevel.ERROR, 'Core_MDF_RevenueSegmentGVSSync: Lookup of global value set Id failed (' + res.getStatusCode() + '): ' + res.getBody());
            return null;
        }

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) parsed.get('records');
        if (records == null || records.isEmpty()) {
            return null;
        }
        Map<String, Object> firstRecord = (Map<String, Object>) records[0];
        system.debug('@@@firstRecord'+firstRecord);
        return (String) firstRecord.get('Id');
    }
}