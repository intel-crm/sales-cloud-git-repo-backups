/**
 * Fires whenever Revenue_Segment_Mapping__c rows are inserted or updated
 * (including bulk loads via Data Import Wizard/Data Loader from Excel) and
 * re-syncs the Core_MDF_Budget_Rev_Segment global picklist value set so the
 * Revenue Segment dropdown on PartnerMarketingBudget reflects the change
 * automatically, with no manual picklist maintenance required.
 */
trigger Core_MDF_RevenueSegmentMappingTrigger on Revenue_Segment_Mapping__c (after insert, after update) {
    Core_MDF_RevenueSegmentGVSSync.syncGlobalValueSetAsync();
}