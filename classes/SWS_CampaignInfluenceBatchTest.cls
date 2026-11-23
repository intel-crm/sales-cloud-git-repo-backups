@isTest
public class SWS_CampaignInfluenceBatchTest {

    @testSetup
    static void setup() {
        SWS_TestUtilty.createLabel('CI - Eligible Campaign Member Status', 'Responded;Attended');
        SWS_TestUtilty.createLabel('CI-Excluded Campaign Types', 'Internal');

        Account acc = SWS_TestUtilty.createAccount();
        Contact con = SWS_TestUtilty.createContact(acc.Id);

        Opportunity opp2025 = new Opportunity(
            Name = 'Batch Test Opportunity 2025',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert opp2025;

        insert new OpportunityContactRole(
            OpportunityId = opp2025.Id,
            ContactId = con.Id,
            Role = 'Business User'
        );

        Campaign camp = new Campaign(
            Name = 'Batch Test Campaign',
            IsActive = true,
            RecordTypeId = getMarketingCampaignRecordTypeId()
        );
        insert camp;

        insert new CampaignMember(
            CampaignId = camp.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );
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
    static void batchCreatesCampaignInfluenceForEligibleOpportunities() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Test.startTest();
        Database.executeBatch(new SWS_CampaignInfluenceBatch(), 100);
        Test.stopTest();

        List<CampaignInfluence> ciList = [SELECT Id FROM CampaignInfluence];
        System.assert(!ciList.isEmpty(), 'Batch should create Campaign Influence records for qualifying Opportunities created in 2025');
    }

    @isTest
    static void batchHandlesOpportunityWithNoOcrGracefully() {
        Account acc = SWS_TestUtilty.createAccount();
        Opportunity oppNoOcr = new Opportunity(
            Name = 'Batch Test Opportunity No OCR',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert oppNoOcr;

        Test.startTest();
        Database.executeBatch(new SWS_CampaignInfluenceBatch(), 100);
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id FROM CampaignInfluence WHERE OpportunityId = :oppNoOcr.Id
        ];
        System.assert(ciList.isEmpty(), 'No Campaign Influence should be created for an Opportunity without OCR');
    }

    @isTest
    static void batchProcessesClosedOpportunitiesToo() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Account acc = SWS_TestUtilty.createAccount();

        Contact con = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId(),
            FirstName = 'ClosedOpp',
            LastName = 'Contact',
            Email = 'closedOppContact' + Math.random() + '@intel.com',
            AccountId = acc.Id,
            Core_Primary_Contact__c = true,
            MailingCountry = 'USA'
        );
        insert con;

        Opportunity closedOpp = new Opportunity(
            Name = 'Closed Batch Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Define',
            CloseDate = System.today().addDays(-1)
        );
        insert closedOpp;

        insert new OpportunityContactRole(
            OpportunityId = closedOpp.Id,
            ContactId = con.Id,
            Role = 'Business User'
        );

        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        insert new CampaignMember(
            CampaignId = camp.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );

        Test.startTest();
        Database.executeBatch(new SWS_CampaignInfluenceBatch(), 100);
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id FROM CampaignInfluence WHERE OpportunityId = :closedOpp.Id
        ];
        System.assert(!ciList.isEmpty(), 'Batch should process closed Opportunities as well, since IsClosed filter was removed');
    }
}