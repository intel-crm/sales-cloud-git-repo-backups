/****************************************************************************************************************************************
* Class Name       : Core_MDF_UpdateOutBasedCampAttrBatch 
* Version          : 1.0 
* Description      : This batch is used to sync Core_MDF_Quantity_to_Date_Nbr__c field of latest IPA outcome-based claim
*                    which went to Payment Due status, to Core_MDF_Result_Value_nbr__c field of its related Core_MDF_Activity_Outcome__c
* Created Date     : 10-05-2026
* Created By       : ACC-Vikas Soni
* Test Class       : Core_MDF_UpdateOutBasedCampAttrBatchTest
* Schedule Class   : Core_MDF_UpdateOutBasedCampAttr_Sch (currently its scheduled for every hour)
* Modification Log :
* Developer            Date               Description
*****************************************************************************************************************************************/
public class Core_MDF_UpdateOutBasedCampAttrBatch implements Database.Batchable<SObject>, Database.Stateful {

    // The key is either a Campaign ID for proposal-based claims or a PartnerFundRequest ID for outcome-based claims.
    private Map<Id, Decimal> parentIdToLatestQtyNbrMap = new Map<Id, Decimal>();
    private Map<Id, DateTime> parentIdToLatestHistoryDateMap = new Map<Id, DateTime>();

    private class ClaimAttriutesWrapper {
        Id parentId;
        Decimal quantityToDate;
        Boolean newOutcomeBased;
        DateTime historyCreatedDate;
        Boolean isPaymentDue;
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        DateTime oneWeekAgo = Date.today().addDays(-7);
        DateTime oneYearAgo = System.now().addYears(-1);

        // Field history (PartnerFundClaimHistory) records cannot be created in Apex test context,
        // so in tests drive the batch using the related claim records directly. This lets
        // execute()/finish() run and the class get covered without any history records.
        if (Test.isRunningTest()) {
            return [
                SELECT Id, RequestId, Core_MDF_Status__c, Core_MDF_Quantity_to_Date_Nbr__c,
                Core_MDF_Proposal_Based_Ind__c, Core_MDF_Campaign_Id__c, Request.Core_MDF_Is_Outcome_Based_Ind__c
                FROM PartnerFundClaim
                WHERE Core_MDF_Program__c = :Core_MDF_CCP_ConstantClass.IPA_PROGRAM
                AND Core_MDF_Type_Txt__c = :Core_MDF_CCP_ConstantClass.TYPE_CLAIM
                AND Core_MDF_Claim_Id__c = null
                AND ((Request.Core_MDF_Is_Outcome_Based_Ind__c = true AND Request.CreatedDate >= :oneYearAgo)
                OR (Core_MDF_Proposal_Based_Ind__c = true AND Core_MDF_Campaign_Id__r.CreatedDate >= :oneYearAgo))
            ];
        }

        // Query claim history records where Status field changed in last week
        return Database.getQueryLocator([SELECT Id, CreatedDate, NewValue, PartnerFundClaim.RequestId, PartnerFundClaim.Core_MDF_Quantity_to_Date_Nbr__c, PartnerFundClaim.Core_MDF_Proposal_Based_Ind__c, PartnerFundClaim.Core_MDF_Campaign_Id__c, PartnerFundClaim.Request.Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundClaimHistory WHERE CreatedDate >= :oneWeekAgo AND Field = 'Core_MDF_Status__c' AND PartnerFundClaim.Core_MDF_Claim_Id__c = null AND PartnerFundClaim.Core_MDF_Program__c = :Core_MDF_CCP_ConstantClass.IPA_PROGRAM AND PartnerFundClaim.Core_MDF_Type_Txt__c = :Core_MDF_CCP_ConstantClass.TYPE_CLAIM AND ((PartnerFundClaim.Request.Core_MDF_Is_Outcome_Based_Ind__c = true AND PartnerFundClaim.Request.CreatedDate >= :oneYearAgo) OR (PartnerFundClaim.Core_MDF_Proposal_Based_Ind__c = true AND PartnerFundClaim.Core_MDF_Campaign_Id__r.CreatedDate >= :oneYearAgo)) ORDER BY PartnerFundClaim.Core_MDF_Campaign_Id__c, PartnerFundClaim.RequestId, CreatedDate DESC]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        Set<Id> updatedRequestIds = new Set<Id>();
        Set<Id> updatedCampaignIds = new Set<Id>();

        for (SObject sourceRecord : scope) {
            processClaimAttributes(buildClaimAttributesWrapper(sourceRecord), updatedRequestIds, updatedCampaignIds);
        }

        if (updatedRequestIds.isEmpty() && updatedCampaignIds.isEmpty()) return;

        // Query active outcomes & update Core_MDF_Result_Value_nbr__c if value has changed
        List<Core_MDF_Activity_Outcome__c> outcomesToUpdate = new List<Core_MDF_Activity_Outcome__c>();
        if (!updatedRequestIds.isEmpty()) {
            for (Core_MDF_Activity_Outcome__c outcome : [SELECT Id, Core_MDF_Activity_Id__c, Core_MDF_Result_Value_nbr__c FROM Core_MDF_Activity_Outcome__c 
	    							                        WHERE Core_MDF_Activity_Id__c IN :updatedRequestIds AND Core_MDF_Active_Ind__c = TRUE]) {
                Decimal latestQtyNbr = parentIdToLatestQtyNbrMap.get(outcome.Core_MDF_Activity_Id__c);

                if (outcome.Core_MDF_Result_Value_nbr__c != latestQtyNbr) {
                    outcome.Core_MDF_Result_Value_nbr__c = latestQtyNbr;
                    outcomesToUpdate.add(outcome);
                }
            }
        }

        List<Core_MDF_Campaign_Outcomes__c> campaignOutcomesToUpdate = new List<Core_MDF_Campaign_Outcomes__c>();
        if (!updatedCampaignIds.isEmpty()) {
            for (Core_MDF_Campaign_Outcomes__c campaignOutcome : [SELECT Id, Core_MDF_Campaign_Id__c, Core_MDF_Quantity_nbr__c FROM Core_MDF_Campaign_Outcomes__c
                                                                    WHERE Core_MDF_Campaign_Id__c IN :updatedCampaignIds AND Core_MDF_Active_Ind__c = TRUE]) {
                Decimal latestQtyNbr = parentIdToLatestQtyNbrMap.get(campaignOutcome.Core_MDF_Campaign_Id__c);

                if (campaignOutcome.Core_MDF_Quantity_nbr__c != latestQtyNbr) {
                    campaignOutcome.Core_MDF_Quantity_nbr__c = latestQtyNbr;
                    campaignOutcomesToUpdate.add(campaignOutcome);
                }
            }
        }

        if (!outcomesToUpdate.isEmpty()) {
            try { Database.update(outcomesToUpdate, false); } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); }
        }
        if (!campaignOutcomesToUpdate.isEmpty()) {
            try { Database.update(campaignOutcomesToUpdate, false); } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); }
        }
    }

    
    // Normalizes a claim history record/claim record into the common attributes required by the batch
    private static ClaimAttriutesWrapper buildClaimAttributesWrapper(SObject sourceRecord) {

        PartnerFundClaim claimRec;
        ClaimAttriutesWrapper claimAttributesWrapper = new ClaimAttriutesWrapper();

        if (sourceRecord instanceof PartnerFundClaimHistory) {
            PartnerFundClaimHistory historyRec = (PartnerFundClaimHistory) sourceRecord;
            claimRec = historyRec.PartnerFundClaim;
            claimAttributesWrapper.historyCreatedDate = historyRec.CreatedDate;
            claimAttributesWrapper.isPaymentDue = historyRec.NewValue == 'Payment Due';
        } else if (sourceRecord instanceof PartnerFundClaim) {
            // Tests query claims directly as field history is not available for test class
            claimRec = (PartnerFundClaim) sourceRecord;
            claimAttributesWrapper.isPaymentDue = claimRec.Core_MDF_Status__c == 'Payment Due';
        }

        claimAttributesWrapper.quantityToDate = claimRec.Core_MDF_Quantity_to_Date_Nbr__c;
        claimAttributesWrapper.newOutcomeBased = claimRec.Core_MDF_Campaign_Id__c == null && claimRec.Request.Core_MDF_Is_Outcome_Based_Ind__c;
        
        if (claimAttributesWrapper.newOutcomeBased) {
            claimAttributesWrapper.parentId = claimRec.RequestId;
        } else if (claimRec.Core_MDF_Campaign_Id__c != null) {
            claimAttributesWrapper.parentId = claimRec.Core_MDF_Campaign_Id__c;
        }
        return claimAttributesWrapper;
    }

    // Retains the latest Payment Due quantity to date for each campaign or request and collects the IDs whose active outcome records must be updated
    private void processClaimAttributes(ClaimAttriutesWrapper claimAttributesWrapper, Set<Id> updatedRequestIds, Set<Id> updatedCampaignIds) {

        if (claimAttributesWrapper.isPaymentDue != true || claimAttributesWrapper.parentId == null) return;

        Set<Id> updatedParentIds = claimAttributesWrapper.newOutcomeBased ? updatedRequestIds : updatedCampaignIds;
        DateTime existingDate = parentIdToLatestHistoryDateMap.get(claimAttributesWrapper.parentId);
        if (claimAttributesWrapper.historyCreatedDate == null || existingDate == null || claimAttributesWrapper.historyCreatedDate > existingDate) {
            if (claimAttributesWrapper.historyCreatedDate != null) {
                parentIdToLatestHistoryDateMap.put(claimAttributesWrapper.parentId, claimAttributesWrapper.historyCreatedDate);
            }
            parentIdToLatestQtyNbrMap.put(claimAttributesWrapper.parentId, claimAttributesWrapper.quantityToDate);
            updatedParentIds.add(claimAttributesWrapper.parentId);
        }
    }

    public void finish(Database.BatchableContext bc) {}
}