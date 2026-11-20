public without sharing class SWS_OpportunityContactRoleCIAction {

    @InvocableMethod(
        label='Create Campaign Influence From OCR'
        description='Evaluates a created/updated Opportunity Contact Role and recalculates Campaign Influence based on qualifying Campaign Member engagement.'
    )
    public static void execute(List<Id> ocrIds) {
        if (ocrIds == null || ocrIds.isEmpty()) {
            return;
        }

        Set<Id> oppIds = getOpportunityIds(ocrIds);
        if (oppIds.isEmpty()) {
            return;
        }

        SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);
    }

    private static Set<Id> getOpportunityIds(List<Id> ocrIds) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityContactRole ocr : [
            SELECT OpportunityId FROM OpportunityContactRole
            WHERE Id IN :ocrIds AND OpportunityId != null
        ]) {
            oppIds.add(ocr.OpportunityId);
        }
        return oppIds;
    }
}