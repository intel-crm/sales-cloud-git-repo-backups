/**
 * Fires on every insert/update of Core_MDF_CCP_Custom_Metadata_Utility__c, a
 * heavily shared generic utility object used by ~49 different features (KPI,
 * BU Splits, CheckList, etc.). To avoid impacting those unrelated categories
 * or burning future-call limits, Core_MDF_RevenueSegmentGVSSync.handleMappingRecordChange
 * only enqueues the Global Value Set sync when a changed record's
 * Core_MDF_Category__c = 'Revenue_Segment_Mapping' - i.e. a Rev Segment
 * mapping row (including bulk loads via Data Import Wizard/Data Loader from
 * Excel). This keeps the Revenue Segment dropdown on PartnerMarketingBudget in
 * sync automatically, with no manual picklist maintenance required.
 */
trigger Core_MDF_RevenueSegmentMappingSyncTrigger on Core_MDF_CCP_Custom_Metadata_Utility__c (after insert, after update) {
    Core_MDF_RevenueSegmentGVSSync.handleMappingRecordChange(Trigger.new);
}