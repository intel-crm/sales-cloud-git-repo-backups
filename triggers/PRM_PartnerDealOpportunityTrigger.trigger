trigger PRM_PartnerDealOpportunityTrigger on PRM_Partner_Deal_Opportunity__c (
    after insert, after update
) {
    if (Trigger.isAfter && Trigger.isInsert || Trigger.isUpdate) {
        PRM_PartnerDealOpportunitySharingService.createSharesForNewOpportunities(Trigger.new);
        PRM_PartnerDealOpportunitySharingService.shareWithOpportunityOwner(Trigger.new,Trigger.isUpdate ? Trigger.oldMap : null);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        PRM_PartnerDealOpportunitySharingService.shareWithOpportunityOwner(Trigger.new,Trigger.isUpdate ? Trigger.oldMap : null);
        PRM_PartnerDealOpportunitySharingService.handleEndCustomerAccountChange(Trigger.new,Trigger.oldMap);
        PRM_PartnerDealOpportunitySharingService.removeOpportunityOwnerSharing(Trigger.new,Trigger.oldMap);
    }
}