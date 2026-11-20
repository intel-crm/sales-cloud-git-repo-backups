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
        partnerTiers.add(new PMP_Partner_Tier__c(Name = 'Tier 1'));
        partnerTiers.add(new PMP_Partner_Tier__c(Name = 'Tier 2'));
        partnerTiers.add(new PMP_Partner_Tier__c(Name = 'Tier 3'));
        insert partnerTiers;

        // Create Company records with related mappings
        List<PMP_Company__c> companies = new List<PMP_Company__c>();
        companies.add(new PMP_Company__c(
            Name = 'Company 1',
            PMP_IPA_Badge_Tier_Txt__c = 'Tier 1',
            PMP_Is_Published_Ind__c = true
        ));
        companies.add(new PMP_Company__c(
            Name = 'Company 2',
            PMP_IPA_Badge_Tier_Txt__c = 'Tier 2',
            PMP_Is_Published_Ind__c = true
        ));
         companies.add(new PMP_Company__c(
            Name = 'Company 3',
            PMP_IPA_Badge_Tier_Txt__c = 'Tier 3',
            PMP_Is_Published_Ind__c = true
        ));
        insert companies;

        // Create Company Profile Attributes Mappings
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappings = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();
        mappings.add(new PMP_Marketing_Profile_Attributes_Mapping__c(
            PMP_Partner_Tier__c = partnerTiers[0].Id,
            PMP_Marketing_Profile_Id__c = companies[0].Id
        ));
        mappings.add(new PMP_Marketing_Profile_Attributes_Mapping__c(
            PMP_Partner_Tier__c = partnerTiers[0].Id,
            PMP_Marketing_Profile_Id__c = companies[1].Id
        ));
        mappings.add(new PMP_Marketing_Profile_Attributes_Mapping__c(
            PMP_Partner_Tier__c = partnerTiers[2].Id,
            PMP_Marketing_Profile_Id__c = companies[1].Id
        ));
        insert mappings;
    }

    @isTest
    static void testBatchProcessing() {
        Test.startTest();
        // Execute the batch job
        PMP_CorrectTierMappingBatch batchJob = new PMP_CorrectTierMappingBatch();
        Database.executeBatch(batchJob);
        Test.stopTest(); 
        // Validate the results
        // Verify that mappings were updated correctly
        List<PMP_Marketing_Profile_Attributes_Mapping__c> updatedMappings = [SELECT Id, PMP_Partner_Tier__c,PMP_Marketing_Profile_Id__r.Name,PMP_Partner_Tier__r.Name FROM PMP_Marketing_Profile_Attributes_Mapping__c limit 10];
        System.assertEquals(3, updatedMappings.size(), 'Expected exactly three updated mapping records');    
    }   
}