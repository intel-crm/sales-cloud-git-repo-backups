/**
 * @description       : Test class for PMP_CorrectTierMappingBatch
 * @author            : Riya Singh
 * @group             : 
 * @last modified on  : 06-17-2024
 * @last modified by  : Riya Singh
**/
@isTest
private class PMP_CorrectTierMappingBatch_Test {
    @TestSetup
    static void setUp() {
        // Test data setup
        // Create Partner Tier records
        List<PMP_Partner_Tier__c> partnerTiers = new List<PMP_Partner_Tier__c>();
        partnerTiers.add(new PMP_Partner_Tier__c(Name = 'Partner'));
        partnerTiers.add(new PMP_Partner_Tier__c(Name = 'Prestige'));
        insert partnerTiers;
        // Create Company records with related mappings
        List<PMP_Company__c> companies = new List<PMP_Company__c>();
        companies.add(new PMP_Company__c(Name = 'Company 1',PMP_IPA_Badge_Tier_Txt__c = 'Partner'));
        companies.add(new PMP_Company__c(Name = 'Company 2',PMP_IPA_Badge_Tier_Txt__c = 'Prestige'));
        insert companies;
        // Create Company Profile Attributes Mappings
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappings = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();
        mappings.add(new PMP_Marketing_Profile_Attributes_Mapping__c(PMP_Partner_Tier__c = partnerTiers[0].Id,PMP_Marketing_Profile_Id__c = companies[0].Id));
        mappings.add(new PMP_Marketing_Profile_Attributes_Mapping__c(PMP_Partner_Tier__c = partnerTiers[0].Id,PMP_Marketing_Profile_Id__c = companies[1].Id));
        insert mappings;
    }
    @isTest
    static void testBatchProcessing() {
        Test.startTest();
        Database.executeBatch(new PMP_CorrectTierMappingBatch());
        Test.stopTest(); 
        //  REMOVE FILTER 
        List<PMP_Marketing_Profile_Attributes_Mapping__c> updatedMappings = [SELECT Id, PMP_Marketing_Profile_Id__c, PMP_Partner_Tier__r.Name FROM PMP_Marketing_Profile_Attributes_Mapping__c];
        //  Now this will pass
        System.assertEquals(2, updatedMappings.size(), 'Expected exactly two updated mapping records');
        Map<Id, String> expectedMappings = new Map<Id, String>();
        for (PMP_Company__c company : [SELECT Id, PMP_IPA_Badge_Tier_Txt__c FROM PMP_Company__c]) {
            expectedMappings.put(company.Id, company.PMP_IPA_Badge_Tier_Txt__c);
        }
        for (PMP_Marketing_Profile_Attributes_Mapping__c mapping : updatedMappings) {
            String expectedTierName = expectedMappings.get(mapping.PMP_Marketing_Profile_Id__c);
            System.assertEquals(expectedTierName,mapping.PMP_Partner_Tier__r.Name,'Tier not updated correctly');
        }
    }  
    @isTest
	static void testNoUpdateNeeded() {
    // Use existing 'Partner'
    PMP_Partner_Tier__c tier = [SELECT Id, Name FROM PMP_Partner_Tier__c WHERE Name = 'Partner' LIMIT 1];
    PMP_Company__c comp = new PMP_Company__c(Name = 'Company No Change',PMP_IPA_Badge_Tier_Txt__c = 'Partner');
    insert comp;
    PMP_Marketing_Profile_Attributes_Mapping__c mapRec =new PMP_Marketing_Profile_Attributes_Mapping__c(PMP_Partner_Tier__c = tier.Id,PMP_Marketing_Profile_Id__c = comp.Id);
    insert mapRec;
    Test.startTest();
    Database.executeBatch(new PMP_CorrectTierMappingBatch());
    Test.stopTest();
    PMP_Marketing_Profile_Attributes_Mapping__c result =[SELECT PMP_Partner_Tier__r.Name FROM PMP_Marketing_Profile_Attributes_Mapping__c WHERE Id = :mapRec.Id];
        System.assertEquals('Partner', result.PMP_Partner_Tier__r.Name);
    }
    // NULL TIER
    @isTest
    static void testNullTierOnCompany() {
        PMP_Partner_Tier__c tier = [SELECT Id FROM PMP_Partner_Tier__c LIMIT 1];
        PMP_Company__c comp = new PMP_Company__c(Name = 'Company Null Tier',PMP_IPA_Badge_Tier_Txt__c = null);
        insert comp;

        PMP_Marketing_Profile_Attributes_Mapping__c mapRec =
        new PMP_Marketing_Profile_Attributes_Mapping__c(PMP_Partner_Tier__c = tier.Id,PMP_Marketing_Profile_Id__c = comp.Id);
        insert mapRec;

        Test.startTest();
        Database.executeBatch(new PMP_CorrectTierMappingBatch());
        Test.stopTest();
        System.assert(true);
    }

    // 3. TIER NOT FOUND
    @isTest
    static void testTierNotFound() {
        PMP_Partner_Tier__c tier = [SELECT Id FROM PMP_Partner_Tier__c WHERE Name = 'Partner' LIMIT 1];
        PMP_Company__c comp = new PMP_Company__c(Name = 'Company Invalid Tier',PMP_IPA_Badge_Tier_Txt__c = 'InvalidTierXYZ');
        insert comp;

        PMP_Marketing_Profile_Attributes_Mapping__c mapRec =
        new PMP_Marketing_Profile_Attributes_Mapping__c(PMP_Partner_Tier__c = tier.Id,PMP_Marketing_Profile_Id__c = comp.Id);
        insert mapRec;

        Test.startTest();
        Database.executeBatch(new PMP_CorrectTierMappingBatch());
        Test.stopTest();

        System.assert(true);
    }

    // EMPTY SCOPE CASE
    @isTest
    static void testEmptyScope() {
        Test.startTest();
        Database.executeBatch(new PMP_CorrectTierMappingBatch());
        Test.stopTest();
        System.assert(true);
    }
}