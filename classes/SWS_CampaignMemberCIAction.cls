public without sharing class SWS_CampaignMemberCIAction {

    @InvocableMethod(
        label='Create Campaign Influence From Campaign Member'
        description='Evaluates a newly created Campaign Member and recalculates Campaign Influence for related Opportunities via OCR.'
    )
    public static void execute(List<Id> campaignMemberIds) {
        if (campaignMemberIds == null || campaignMemberIds.isEmpty()) {
            return;
        }

        Set<Id> contactIds = getContactIds(campaignMemberIds);
        if (contactIds.isEmpty()) {
            return;
        }

        Set<Id> oppIds = getOpportunityIdsForContacts(contactIds);
        if (oppIds.isEmpty()) {
            return; // No OCR — do not force attribution
        }

        SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);
    }

    private static Set<Id> getContactIds(List<Id> campaignMemberIds) {
        Set<Id> contactIds = new Set<Id>();
        for (CampaignMember cm : [
            SELECT ContactId FROM CampaignMember
            WHERE Id IN :campaignMemberIds AND ContactId != null
        ]) {
            contactIds.add(cm.ContactId);
        }
        return contactIds;
    }

    private static Set<Id> getOpportunityIdsForContacts(Set<Id> contactIds) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityContactRole ocr : [
            SELECT OpportunityId FROM OpportunityContactRole
            WHERE ContactId IN :contactIds
        ]) {
            oppIds.add(ocr.OpportunityId);
        }
        return oppIds;
    }
}