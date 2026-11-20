@isTest
public class SWS_CampaignMemberCIActionTest {

    @testSetup
    static void setup() {
        SWS_TestUtilty.createLabel('CI - Eligible Campaign Member Status', 'Responded;Attended');
        SWS_TestUtilty.createLabel('CI-Excluded Campaign Types', 'Internal');

        Account acc = SWS_TestUtilty.createAccount();
        Contact con = SWS_TestUtilty.createContact(acc.Id);

        Opportunity opp = new Opportunity(
            Name = 'CM Trigger Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert opp;

        insert new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Role = 'Business User'
        );

        insert new Campaign(
            Name = 'CM Action Campaign',
            IsActive = true,
            RecordTypeId = getMarketingCampaignRecordTypeId()
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
    static void executeCreatesCampaignInfluenceForQualifyingMember() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        CampaignMember cm = new CampaignMember(
            CampaignId = camp.Id,
            ContactId = con.Id,
            Status = 'Responded'
        );
        insert cm;

        Test.startTest();
        SWS_CampaignMemberCIAction.execute(new List<Id>{ cm.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [SELECT Id FROM CampaignInfluence WHERE CampaignId = :camp.Id];
        System.assert(!ciList.isEmpty(), 'Campaign Influence should be created after qualifying Campaign Member is processed');
    }

    @isTest
    static void executeHandlesEmptyInputGracefully() {
        Test.startTest();
        SWS_CampaignMemberCIAction.execute(new List<Id>());
        Test.stopTest();

        System.assert(true, 'Method should return without error for an empty Campaign Member Id list');
    }

    @isTest
    static void executeHandlesNullInputGracefully() {
        Test.startTest();
        SWS_CampaignMemberCIAction.execute(null);
        Test.stopTest();

        System.assert(true, 'Method should return without error for a null Campaign Member Id list');
    }

    @isTest
    static void executeSkipsWhenContactHasNoOpportunityContactRole() {
        Account acc = SWS_TestUtilty.createAccount();

        Contact orphanContact = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId(),
            FirstName = 'Orphan',
            LastName = 'Contact',
            Email = 'orphanContact' + Math.random() + '@intel.com',
            AccountId = acc.Id,
            Core_Primary_Contact__c = true,
            MailingCountry = 'USA'
        );
        insert orphanContact;

        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        CampaignMember cm = new CampaignMember(
            CampaignId = camp.Id,
            ContactId = orphanContact.Id,
            Status = 'Responded'
        );
        insert cm;

        Test.startTest();
        SWS_CampaignMemberCIAction.execute(new List<Id>{ cm.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id FROM CampaignInfluence WHERE ContactId = :orphanContact.Id
        ];
        System.assert(ciList.isEmpty(), 'No Campaign Influence should be created when Contact has no OCR-linked Opportunity');
    }
}