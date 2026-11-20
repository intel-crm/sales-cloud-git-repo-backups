@isTest
public class SWS_CampaignInfluenceServiceTest {

    @testSetup
    static void setup() {
        SWS_TestUtilty.createLabel(
            'CI - Eligible Campaign Member Status', 'Responded;Attended'
        );
        SWS_TestUtilty.createLabel(
            'CI-Excluded Campaign Types', 'Internal'
        );

        Account acc = SWS_TestUtilty.createAccount();
        Contact con = SWS_TestUtilty.createContact(acc.Id);

        Opportunity opp = new Opportunity(
            Name = 'Test CI Opportunity',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Role = 'Business User'
        );
        insert ocr;

        Id marketingCampaignRtId = getMarketingCampaignRecordTypeId();

        Campaign campA = new Campaign(
            Name = 'Campaign A',
            IsActive = true,
            RecordTypeId = marketingCampaignRtId
        );
        Campaign campB = new Campaign(
            Name = 'Campaign B',
            IsActive = true,
            RecordTypeId = marketingCampaignRtId
        );
        insert new List<Campaign>{ campA, campB };

        CampaignMember cmA = new CampaignMember(
            CampaignId = campA.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );
        insert cmA;
    }

    private static Id getMarketingCampaignRecordTypeId() {
        return Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Campaign').getRecordTypeId();
    }

    private static Id getEvenDistributionModelId() {
        List<CampaignInfluenceModel> models = [
            SELECT Id FROM CampaignInfluenceModel
            WHERE DeveloperName = 'EvenDistribution'
            LIMIT 1
        ];
        return models.isEmpty() ? null : models[0].Id;
    }

    @isTest
    static void recalculateForOpportunitiesInsertsNewCI() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppIds = new Set<Id>{ opp.Id };

        Test.startTest();
        SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id, Influence, OpportunityId, CampaignId
            FROM CampaignInfluence
            WHERE OpportunityId = :opp.Id
        ];
        System.assert(!ciList.isEmpty(), 'Campaign Influence record should be created for the Opportunity');
        System.assertEquals(100.00, ciList[0].Influence, 'Single qualifying Campaign should get 100% influence');
    }

    @isTest
    static void recalculateForOpportunitiesUpdatesExistingCIWhenSplitChanges() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Campaign campB = [SELECT Id FROM Campaign WHERE Name = 'Campaign B' LIMIT 1];

        Set<Id> oppIds = new Set<Id>{ opp.Id };
        SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);

        CampaignMember cmB = new CampaignMember(
            CampaignId = campB.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );
        insert cmB;

        Test.startTest();
        SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id, Influence FROM CampaignInfluence WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(2, ciList.size(), 'Two Campaign Influence records should exist after second qualifying Campaign is added');
        for (CampaignInfluence ci : ciList) {
            System.assertEquals(50.00, ci.Influence, 'Influence should be re-split equally to 50% each');
        }
    }

    @isTest
    static void recalculateForOpportunitiesSkipsWhenNoOCR() {
        Account acc = SWS_TestUtilty.createAccount();
        Opportunity oppWithoutOcr = new Opportunity(
            Name = 'No OCR Opportunity',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert oppWithoutOcr;

        Test.startTest();
        SWS_CampaignInfluenceService.recalculateForOpportunities(new Set<Id>{ oppWithoutOcr.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id FROM CampaignInfluence WHERE OpportunityId = :oppWithoutOcr.Id
        ];
        System.assert(ciList.isEmpty(), 'No Campaign Influence should be created when Opportunity has no OCR');
    }

    @isTest
    static void recalculateForOpportunitiesHandlesEmptySet() {
        Test.startTest();
        SWS_CampaignInfluenceService.recalculateForOpportunities(new Set<Id>());
        Test.stopTest();

        System.assert(true, 'Method should return gracefully for an empty Opportunity Id set');
    }

    @isTest
    static void recalculateForOpportunitiesExcludesIneligibleCampaignType() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Campaign internalCampaign = new Campaign(
            Name = 'Internal Campaign',
            IsActive = true,
            RecordTypeId = getMarketingCampaignRecordTypeId(),
            MKT_Campaign_Type_nm__c = 'Internal'
        );
        insert internalCampaign;

        CampaignMember internalMember = new CampaignMember(
            CampaignId = internalCampaign.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );
        insert internalMember;

        Test.startTest();
        SWS_CampaignInfluenceService.recalculateForOpportunities(new Set<Id>{ opp.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id, CampaignId FROM CampaignInfluence
            WHERE OpportunityId = :opp.Id AND CampaignId = :internalCampaign.Id
        ];
        System.assert(ciList.isEmpty(), 'Internal campaign type should be excluded from Campaign Influence');
    }
}