@isTest
public class SWS_OpportunityContactRoleCIActionTest {

    @testSetup
    static void setup() {
        SWS_TestUtilty.createLabel('CI - Eligible Campaign Member Status', 'Responded;Attended');
        SWS_TestUtilty.createLabel('CI-Excluded Campaign Types', 'Internal');

        Account acc = SWS_TestUtilty.createAccount();
        Contact con = SWS_TestUtilty.createContact(acc.Id);

        Opportunity opp = new Opportunity(
            Name = 'OCR Trigger Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Qualify',
            CloseDate = System.today().addDays(30)
        );
        insert opp;

        Campaign camp = new Campaign(
            Name = 'OCR Action Campaign',
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
    static void executeCreatesCampaignInfluenceWhenOcrCreated() {
        System.assertNotEquals(null, getEvenDistributionModelId(), 'EvenDistribution Campaign Influence Model must exist in the org for this test to run');

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Role = 'Business User'
        );
        insert ocr;

        Test.startTest();
        SWS_OpportunityContactRoleCIAction.execute(new List<Id>{ ocr.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [SELECT Id FROM CampaignInfluence WHERE OpportunityId = :opp.Id];
        System.assert(!ciList.isEmpty(), 'Campaign Influence should be created after OCR is processed');
    }

    @isTest
    static void executeHandlesEmptyInputGracefully() {
        Test.startTest();
        SWS_OpportunityContactRoleCIAction.execute(new List<Id>());
        Test.stopTest();

        System.assert(true, 'Method should return without error for an empty OCR Id list');
    }

    @isTest
    static void executeHandlesNullInputGracefully() {
        Test.startTest();
        SWS_OpportunityContactRoleCIAction.execute(null);
        Test.stopTest();

        System.assert(true, 'Method should return without error for a null OCR Id list');
    }

    @isTest
    static void executeSkipsWhenOcrHasNoQualifyingCampaignMember() {
        Account acc = SWS_TestUtilty.createAccount();

        Contact newContact = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId(),
            FirstName = 'NoMember',
            LastName = 'Contact',
            Email = 'noMemberContact' + Math.random() + '@intel.com',
            AccountId = acc.Id,
            Core_Primary_Contact__c = true,
            MailingCountry = 'USA'
        );
        insert newContact;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = newContact.Id,
            Role = 'Business User'
        );
        insert ocr;

        Test.startTest();
        SWS_OpportunityContactRoleCIAction.execute(new List<Id>{ ocr.Id });
        Test.stopTest();

        List<CampaignInfluence> ciList = [
            SELECT Id FROM CampaignInfluence WHERE OpportunityId = :opp.Id AND ContactId = :newContact.Id
        ];
        System.assert(ciList.isEmpty(), 'No Campaign Influence should be created for a Contact without a qualifying Campaign Member');
    }
}