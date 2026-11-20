public without sharing class SWS_CampaignInfluenceService {

    private static final String LABEL_ELIGIBLE_STATUSES = 'CI - Eligible Campaign Member Status';
    private static final String LABEL_EXCLUDED_CAMPAIGN_TYPES = 'CI-Excluded Campaign Types';
    private static final String VALUE_DELIMITER = ';';

    private static final Integer ATTRIBUTION_WINDOW_DAYS = 365;
    private static final String ATTRIBUTION_MODEL_DEVELOPER_NAME = 'EvenDistribution';

    private static Set<String> eligibleStatuses;
    private static Set<String> excludedCampaignTypes;

    private class CIBatchContext {
        Id modelId;
        List<CampaignInfluence> toInsert = new List<CampaignInfluence>();
        List<CampaignInfluence> toUpdate = new List<CampaignInfluence>();

        CIBatchContext(Id modelId) {
            this.modelId = modelId;
        }
    }

    private class NewCampaignInfluenceRequest {
        Id opportunityId;
        Id campaignId;
        Id contactId;
        Decimal influencePercent;
        Id modelId;
    }

    public static void recalculateForOpportunities(Set<Id> opportunityIds) {
        if (isEmpty(opportunityIds)) {
            return;
        }

        Id modelId = getEvenDistributionModelId();
        if (modelId == null) {
            return;
        }

        Map<Id, Opportunity> oppMap = getOpportunities(opportunityIds);
        if (oppMap.isEmpty()) {
            return;
        }

        Map<Id, Set<Id>> oppToContacts = getOpportunityContactMap(oppMap.keySet());
        if (oppToContacts.isEmpty()) {
            return;
        }

        Map<Id, List<CampaignMember>> contactToCms = getEligibleCampaignMembersByContact(oppToContacts);
        if (contactToCms.isEmpty()) {
            return;
        }

        Map<Id, Map<Id, CampaignMember>> oppToCampaignWinners =
            buildCampaignWinnersByOpportunity(oppMap, oppToContacts, contactToCms);
        if (oppToCampaignWinners.isEmpty()) {
            return;
        }

        upsertCampaignInfluence(oppToCampaignWinners, modelId);
    }

    private static Map<Id, Opportunity> getOpportunities(Set<Id> opportunityIds) {
        return new Map<Id, Opportunity>(
            [SELECT Id, CreatedDate FROM Opportunity WHERE Id IN :opportunityIds]
        );
    }

    private static Map<Id, Set<Id>> getOpportunityContactMap(Set<Id> opportunityIds) {
        Map<Id, Set<Id>> oppToContacts = new Map<Id, Set<Id>>();

        List<OpportunityContactRole> ocrList = [
            SELECT OpportunityId, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId IN :opportunityIds
            AND ContactId != null
        ];

        for (OpportunityContactRole ocr : ocrList) {
            addToSetMap(oppToContacts, ocr.OpportunityId, ocr.ContactId);
        }
        return oppToContacts;
    }

    private static Map<Id, List<CampaignMember>> getEligibleCampaignMembersByContact(Map<Id, Set<Id>> oppToContacts) {
        Set<Id> allContactIds = flattenContactIds(oppToContacts);
        if (allContactIds.isEmpty()) {
            return new Map<Id, List<CampaignMember>>();
        }

        List<CampaignMember> cms = [
            SELECT Id, ContactId, CampaignId, Status, CreatedDate, Campaign.IsActive, Campaign.MKT_Campaign_Type_nm__c
            FROM CampaignMember
            WHERE ContactId IN :allContactIds
            AND Status IN :getEligibleStatuses()
            AND Campaign.IsActive = true
        ];

        Map<Id, List<CampaignMember>> contactToCms = new Map<Id, List<CampaignMember>>();
        for (CampaignMember cm : cms) {
            if (isCampaignTypeEligible(cm.Campaign.MKT_Campaign_Type_nm__c)) {
                addToListMap(contactToCms, cm.ContactId, cm);
            }
        }
        return contactToCms;
    }

    private static Boolean isCampaignTypeEligible(String campaignType) {
        if (String.isBlank(campaignType)) {
            return true;
        }
        return !getExcludedCampaignTypes().contains(campaignType.trim().toLowerCase());
    }

    private static Set<Id> flattenContactIds(Map<Id, Set<Id>> oppToContacts) {
        Set<Id> allContactIds = new Set<Id>();
        for (Set<Id> contacts : oppToContacts.values()) {
            allContactIds.addAll(contacts);
        }
        return allContactIds;
    }

    private static Map<Id, Map<Id, CampaignMember>> buildCampaignWinnersByOpportunity(
        Map<Id, Opportunity> oppMap,
        Map<Id, Set<Id>> oppToContacts,
        Map<Id, List<CampaignMember>> contactToCms
    ) {
        Map<Id, Map<Id, CampaignMember>> result = new Map<Id, Map<Id, CampaignMember>>();

        for (Id oppId : oppToContacts.keySet()) {
            Map<Id, CampaignMember> winners = getCampaignWinnersForOpportunity(
                oppMap.get(oppId), oppToContacts.get(oppId), contactToCms
            );
            if (!winners.isEmpty()) {
                result.put(oppId, winners);
            }
        }
        return result;
    }

    private static Map<Id, CampaignMember> getCampaignWinnersForOpportunity(
        Opportunity opp,
        Set<Id> contacts,
        Map<Id, List<CampaignMember>> contactToCms
    ) {
        Map<Id, CampaignMember> campaignWinners = new Map<Id, CampaignMember>();
        if (opp == null || opp.CreatedDate == null) {
            return campaignWinners;
        }

        Date oppCreatedDate = opp.CreatedDate.date();
        for (Id contactId : contacts) {
            applyQualifyingMembers(contactToCms.get(contactId), oppCreatedDate, campaignWinners);
        }
        return campaignWinners;
    }

    private static void applyQualifyingMembers(
        List<CampaignMember> members,
        Date oppCreatedDate,
        Map<Id, CampaignMember> campaignWinners
    ) {
        if (members == null) {
            return;
        }
        for (CampaignMember cm : members) {
            if (isWithinAttributionWindow(cm.CreatedDate, oppCreatedDate)) {
                keepEarliestWinner(campaignWinners, cm);
            }
        }
    }

    private static Boolean isWithinAttributionWindow(DateTime cmCreatedDateTime, Date oppCreatedDate) {
        if (cmCreatedDateTime == null) {
            return false;
        }
        Date cmCreatedDate = cmCreatedDateTime.date();
        Integer daysDiff = cmCreatedDate.daysBetween(oppCreatedDate);
        return Math.abs(daysDiff) < ATTRIBUTION_WINDOW_DAYS;
    }

    private static void keepEarliestWinner(Map<Id, CampaignMember> campaignWinners, CampaignMember candidate) {
        CampaignMember current = campaignWinners.get(candidate.CampaignId);
        if (current == null || candidate.CreatedDate < current.CreatedDate) {
            campaignWinners.put(candidate.CampaignId, candidate);
        }
    }

    private static void upsertCampaignInfluence(Map<Id, Map<Id, CampaignMember>> oppToCampaignWinners, Id modelId) {
        Map<Id, Map<Id, CampaignInfluence>> oppToExistingCI = getExistingCampaignInfluence(oppToCampaignWinners.keySet(), modelId);

        CIBatchContext ctx = new CIBatchContext(modelId);

        for (Id oppId : oppToCampaignWinners.keySet()) {
            collectCIChangesForOpportunity(
                oppId, oppToCampaignWinners.get(oppId), oppToExistingCI.get(oppId), ctx
            );
        }

        if (!ctx.toInsert.isEmpty()) {
            insert ctx.toInsert;
        }
        if (!ctx.toUpdate.isEmpty()) {
            update ctx.toUpdate;
        }
    }

    private static Map<Id, Map<Id, CampaignInfluence>> getExistingCampaignInfluence(Set<Id> opportunityIds, Id modelId) {
        Map<Id, Map<Id, CampaignInfluence>> oppToExistingCI = new Map<Id, Map<Id, CampaignInfluence>>();

        List<CampaignInfluence> existingCIs = [
            SELECT Id, OpportunityId, CampaignId, ContactId, Influence
            FROM CampaignInfluence
            WHERE OpportunityId IN :opportunityIds
            AND ModelId = :modelId
        ];

        for (CampaignInfluence ci : existingCIs) {
            addToMapMap(oppToExistingCI, ci);
        }
        return oppToExistingCI;
    }

    private static void collectCIChangesForOpportunity(
        Id oppId,
        Map<Id, CampaignMember> campaignWinners,
        Map<Id, CampaignInfluence> existingForOpp,
        CIBatchContext ctx
    ) {
        
        Set<Id> allCampaignIds = new Set<Id>(campaignWinners.keySet());
        if (existingForOpp != null) {
            allCampaignIds.addAll(existingForOpp.keySet());
        }

        Integer campaignCount = allCampaignIds.size();
        if (campaignCount == 0) {
            return;
        }

        Decimal influencePct = calculateEqualSplit(campaignCount);

        for (Id campaignId : allCampaignIds) {
            CampaignInfluence existing = (existingForOpp != null) ? existingForOpp.get(campaignId) : null;
            if (existing != null) {
                addForUpdateIfChanged(existing, influencePct, ctx.toUpdate);
            } else {
                CampaignMember winner = campaignWinners.get(campaignId);
                NewCampaignInfluenceRequest request = new NewCampaignInfluenceRequest();
                request.opportunityId = oppId;
                request.campaignId = campaignId;
                request.contactId = winner.ContactId;
                request.influencePercent = influencePct;
                request.modelId = ctx.modelId;
                ctx.toInsert.add(buildNewCampaignInfluence(request));
            }
        }
    }

    private static Decimal calculateEqualSplit(Integer campaignCount) {
        return (100.0 / campaignCount).setScale(2, System.RoundingMode.HALF_UP);
    }

    private static void addForUpdateIfChanged(CampaignInfluence existing, Decimal influencePct, List<CampaignInfluence> toUpdate) {
        if (existing.Influence != influencePct) {
            CampaignInfluence ciToUpdate = new CampaignInfluence(
                Id = existing.Id,
                Influence = influencePct
            );
            toUpdate.add(ciToUpdate);
        }
    }

    private static CampaignInfluence buildNewCampaignInfluence(NewCampaignInfluenceRequest request) {
        return new CampaignInfluence(
            OpportunityId = request.opportunityId,
            CampaignId = request.campaignId,
            ContactId = request.contactId,
            Influence = request.influencePercent,
            ModelId = request.modelId
        );
    }

    private static Id getEvenDistributionModelId() {
        List<CampaignInfluenceModel> models = [
            SELECT Id
            FROM CampaignInfluenceModel
            WHERE DeveloperName = :ATTRIBUTION_MODEL_DEVELOPER_NAME
            LIMIT 1
        ];
        return models.isEmpty() ? null : models[0].Id;
    }

    private static Set<String> getEligibleStatuses() {
        if (eligibleStatuses == null) {
            eligibleStatuses = loadDelimitedLabelValues(LABEL_ELIGIBLE_STATUSES, false);
        }
        return eligibleStatuses;
    }

    private static Set<String> getExcludedCampaignTypes() {
        if (excludedCampaignTypes == null) {
            excludedCampaignTypes = loadDelimitedLabelValues(LABEL_EXCLUDED_CAMPAIGN_TYPES, true);
        }
        return excludedCampaignTypes;
    }

    private static Set<String> loadDelimitedLabelValues(String labelName, Boolean toLowerCase) {
        Set<String> values = new Set<String>();
        for (SWS_Core_CRM_Labels__c config : getLabelConfigs(labelName)) {
            values.addAll(parseDelimitedValue(config.SWS_Value__c, toLowerCase));
        }
        return values;
    }

    private static List<SWS_Core_CRM_Labels__c> getLabelConfigs(String labelName) {
        return [
            SELECT Name, SWS_Value__c
            FROM SWS_Core_CRM_Labels__c
            WHERE Name = :labelName
            OR Name LIKE :(labelName + ' %')
        ];
    }

    private static Set<String> parseDelimitedValue(String rawValue, Boolean toLowerCase) {
        Set<String> values = new Set<String>();
        if (String.isBlank(rawValue)) {
            return values;
        }
        for (String token : rawValue.split(VALUE_DELIMITER)) {
            String trimmedValue = token.trim();
            if (String.isNotBlank(trimmedValue)) {
                values.add(toLowerCase ? trimmedValue.toLowerCase() : trimmedValue);
            }
        }
        return values;
    }

    private static Boolean isEmpty(Set<Id> ids) {
        return ids == null || ids.isEmpty();
    }

    private static void addToSetMap(Map<Id, Set<Id>> mapOfSets, Id key, Id value) {
        if (!mapOfSets.containsKey(key)) {
            mapOfSets.put(key, new Set<Id>());
        }
        mapOfSets.get(key).add(value);
    }

    private static void addToListMap(Map<Id, List<CampaignMember>> mapOfLists, Id key, CampaignMember value) {
        if (!mapOfLists.containsKey(key)) {
            mapOfLists.put(key, new List<CampaignMember>());
        }
        mapOfLists.get(key).add(value);
    }

    private static void addToMapMap(Map<Id, Map<Id, CampaignInfluence>> mapOfMaps, CampaignInfluence ci) {
        if (!mapOfMaps.containsKey(ci.OpportunityId)) {
            mapOfMaps.put(ci.OpportunityId, new Map<Id, CampaignInfluence>());
        }
        mapOfMaps.get(ci.OpportunityId).put(ci.CampaignId, ci);
    }
}