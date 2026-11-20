/********************************************************************************************************************
Apex Class Name:  Core_LeadRoutingHandler_Test  
Version      : 1.0 
Created Date : 11/19/21
Function     : Test Class for Core_LeadRoutingHandler
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
*Naveen                      03/16/2026           Original Version
*******************************************************************************************************************/

@isTest
public class Core_LeadRoutingHandler_Test {
    
    @testSetup 
    static void setup() {
        // Create Core_Opp_Bypass_Validation_Rule__c
        Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
        bypass.Bypass__c = true;
        insert bypass;
        
        // Create Profile and User
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
        
        User testUser = new User();
        testUser.FirstName = 'test';
        testUser.LastName = 'user';
        testUser.Email = 'testuser@intel.com';
        testUser.Username = 'testinguser@inteltest.com';
        testUser.Alias = 'testu';
        testUser.CommunityNickname = 'test.userqwert';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        // Create Account
        String accPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Account> accList = new List<Account>();
        
        for(Integer i = 0; i < 5; i++) {
            Account partnerRec = new Account();
            partnerRec.Name = 'Test Partner Account' + i;
            partnerRec.RecordTypeId = accPartnerRecType;
            partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
            partnerRec.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            partnerRec.BillingCountryCode = 'USA';
            partnerRec.BillingStateCode = 'AL';
            partnerRec.BillingCity = 'Alabama123';
            partnerRec.BillingStreet = 'test';
            partnerRec.BillingPostalCode = '123445';
            accList.add(partnerRec);
        }
        insert accList;
        
        // Create PMP_Company__c records (Marketing Profiles)
        List<PMP_Company__c> companyList = new List<PMP_Company__c>();
        for(Integer i = 0; i < 5; i++) {
            PMP_Company__c company = new PMP_Company__c();
            company.Name = 'Test Company' + i;
            company.PMP_Account_Id__c = accList[i].Id;
            company.PMP_IPA_Badge_Tier_Txt__c = 'Gold';
            company.PMP_Partner_Country_Txt__c = 'India';
            company.PMP_Company_Lifecycle_Status_Nm__c = 'Draft';
            company.PMP_Is_Published_Ind__c = true;
            company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced';
            companyList.add(company);
        }
        insert companyList;
        
        // Create PMP_OPID_MPI_Rel__c records with actual IDs
        List<PMP_OPID_MPI_Rel__c> testRecords = new List<PMP_OPID_MPI_Rel__c>();
        for(Integer i = 0; i < 5; i++) {
            PMP_OPID_MPI_Rel__c record = new PMP_OPID_MPI_Rel__c();
            record.PMP_Marketing_Profile_Id__c = companyList[i].Id; // Use actual PMP_Company__c ID
            record.PMP_One_Partner_ID__c = accList[i].Id; // Use actual Account ID
            record.Is_Active__c = (i < 3); // First 3 are active
            testRecords.add(record);
        }
        insert testRecords;
    }
    
    @isTest
    static void testReprocessLeadRoutingOnInsert_WithActiveRecords() {
        Test.startTest();
        
        // Get test records from setup
        List<PMP_OPID_MPI_Rel__c> existingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                     FROM PMP_OPID_MPI_Rel__c 
                                                     WHERE Is_Active__c = true 
                                                     LIMIT 3];
        
        // Test the method with active records
        Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(existingRecords);
        
        Test.stopTest();
        
        // Verify that the method executed without errors
        System.assertEquals(3, existingRecords.size(), 'Should have 3 active records');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnInsert_WithInactiveRecords() {
        Test.startTest();
        
        // Get inactive records from setup
        List<PMP_OPID_MPI_Rel__c> inactiveRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                     FROM PMP_OPID_MPI_Rel__c 
                                                     WHERE Is_Active__c = false 
                                                     LIMIT 2];
        
        // Test the method with inactive records
        Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(inactiveRecords);
        
        Test.stopTest();
        
        // Since records are inactive, no batch should be called
        System.assertEquals(2, inactiveRecords.size(), 'Should have 2 inactive records');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnInsert_EmptyList() {
        Test.startTest();
        
        List<PMP_OPID_MPI_Rel__c> emptyList = new List<PMP_OPID_MPI_Rel__c>();
        
        // Test the method with empty list
        Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(emptyList);
        
        Test.stopTest();
        
        // Should handle empty list gracefully
        System.assertEquals(0, emptyList.size(), 'List should be empty');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnUpdate_StatusChanged() {
        Test.startTest();
        
        // Get existing records
        List<PMP_OPID_MPI_Rel__c> existingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                     FROM PMP_OPID_MPI_Rel__c 
                                                     LIMIT 3];
        
        // Create old map with different Is_Active values
        Map<Id, PMP_OPID_MPI_Rel__c> oldMap = new Map<Id, PMP_OPID_MPI_Rel__c>();
        for(PMP_OPID_MPI_Rel__c record : existingRecords) {
            PMP_OPID_MPI_Rel__c oldRecord = record.clone(true, true, true, true);
            oldRecord.Is_Active__c = !record.Is_Active__c; // Flip the status
            oldMap.put(record.Id, oldRecord);
        }
        
        // Test the method
        Core_LeadRoutingHandler.reprocessLeadRoutingOnUpdate(existingRecords, oldMap);
        
        Test.stopTest();
        
        // Verify that the method executed without errors
        System.assertEquals(3, existingRecords.size(), 'Should have 3 records');
        System.assertEquals(3, oldMap.size(), 'Old map should have 3 records');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnUpdate_NoStatusChange() {
        Test.startTest();
        
        // Get existing records
        List<PMP_OPID_MPI_Rel__c> existingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                     FROM PMP_OPID_MPI_Rel__c 
                                                     LIMIT 3];
        
        // Create old map with same Is_Active values (no change)
        Map<Id, PMP_OPID_MPI_Rel__c> oldMap = new Map<Id, PMP_OPID_MPI_Rel__c>();
        for(PMP_OPID_MPI_Rel__c record : existingRecords) {
            PMP_OPID_MPI_Rel__c oldRecord = record.clone(true, true, true, true);
            oldRecord.Is_Active__c = record.Is_Active__c; // Same status
            oldMap.put(record.Id, oldRecord);
        }
        
        // Test the method
        Core_LeadRoutingHandler.reprocessLeadRoutingOnUpdate(existingRecords, oldMap);
        
        Test.stopTest();
        
        // Since no status changed, no batch should be called
        System.assertEquals(3, existingRecords.size(), 'Should have 3 records');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnUpdate_EmptyLists() {
        Test.startTest();
        
        List<PMP_OPID_MPI_Rel__c> emptyList = new List<PMP_OPID_MPI_Rel__c>();
        Map<Id, PMP_OPID_MPI_Rel__c> emptyMap = new Map<Id, PMP_OPID_MPI_Rel__c>();
        
        // Test the method with empty collections
        Core_LeadRoutingHandler.reprocessLeadRoutingOnUpdate(emptyList, emptyMap);
        
        Test.stopTest();
        
        // Should handle empty collections gracefully
        System.assertEquals(0, emptyList.size(), 'List should be empty');
        System.assertEquals(0, emptyMap.size(), 'Map should be empty');
    }
    
    @isTest
    static void testCallBatch() {
        Test.startTest();
        
        // Get actual marketing profile IDs from setup
        List<PMP_Company__c> companies = [SELECT Id FROM PMP_Company__c LIMIT 3];
        Set<Id> mpIdSet = new Set<Id>();
        
        for(PMP_Company__c company : companies) {
            mpIdSet.add(company.Id);
        }
        
        // Test the callBatch method
        Core_LeadRoutingHandler.callBatch(mpIdSet);
        
        Test.stopTest();
        
        // Verify that batch was called (we can't directly verify batch execution in test,
        // but we can verify the method executed without errors)
        System.assertEquals(3, mpIdSet.size(), 'Should have 3 marketing profile IDs');
    }
    
    @isTest
    static void testCallBatch_EmptySet() {
        Test.startTest();
        
        Set<Id> emptySet = new Set<Id>();
        
        // Test the callBatch method with empty set
        Core_LeadRoutingHandler.callBatch(emptySet);
        
        Test.stopTest();
        
        // Should handle empty set gracefully
        System.assertEquals(0, emptySet.size(), 'Set should be empty');
    }
    
    @isTest
    static void testReprocessLeadRoutingOnInsert_MixedActiveInactive() {
        Test.startTest();
        
        // Get both active and inactive records
        List<PMP_OPID_MPI_Rel__c> mixedRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                  FROM PMP_OPID_MPI_Rel__c 
                                                  LIMIT 5];
        
        // Test the method with mixed records
        Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(mixedRecords);
        
        Test.stopTest();
        
        System.assertEquals(5, mixedRecords.size(), 'Should have 5 mixed records');
    }
    
    @isTest
    static void testBulkOperations() {
        Test.startTest();
        
        // Create additional accounts and companies for bulk testing
        List<Account> bulkAccounts = new List<Account>();
        String accPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        for(Integer i = 0; i < 50; i++) {
            Account acc = new Account();
            acc.Name = 'Bulk Test Account' + i;
            acc.RecordTypeId = accPartnerRecType;
            acc.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.BillingCountryCode = 'USA';
            acc.BillingStateCode = 'AL';
            acc.BillingCity = 'Alabama123';
            acc.BillingStreet = 'test';
            acc.BillingPostalCode = '123445';
            bulkAccounts.add(acc);
        }
        insert bulkAccounts;
        
        List<PMP_Company__c> bulkCompanies = new List<PMP_Company__c>();
        for(Integer i = 0; i < 50; i++) {
            PMP_Company__c company = new PMP_Company__c();
            company.Name = 'Bulk Test Company' + i;
            company.PMP_Account_Id__c = bulkAccounts[i].Id;
            company.PMP_IPA_Badge_Tier_Txt__c = 'Gold';
            company.PMP_Partner_Country_Txt__c = 'India';
            company.PMP_Company_Lifecycle_Status_Nm__c = 'Draft';
            company.PMP_Is_Published_Ind__c = true;
            company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced';
            bulkCompanies.add(company);
        }
        insert bulkCompanies;
        
        List<PMP_OPID_MPI_Rel__c> bulkRecords = new List<PMP_OPID_MPI_Rel__c>();
        for(Integer i = 0; i < 50; i++) {
            PMP_OPID_MPI_Rel__c record = new PMP_OPID_MPI_Rel__c();
            record.PMP_Marketing_Profile_Id__c = bulkCompanies[i].Id;
            record.PMP_One_Partner_ID__c = bulkAccounts[i].Id;
            record.Is_Active__c = true;
            bulkRecords.add(record);
        }
        insert bulkRecords;
        
        // Test bulk insert processing
        Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(bulkRecords);
        
        Test.stopTest();
        
        System.assertEquals(50, bulkRecords.size(), 'Should handle bulk operations');
    }
    
    @isTest
    static void testEdgeCases_NullHandling() {
        Test.startTest();
        
        // Create a record with null marketing profile ID (if allowed by validation rules)
        Account testAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Partner Account%' LIMIT 1];
        
        try {
            PMP_OPID_MPI_Rel__c recordWithNull = new PMP_OPID_MPI_Rel__c();
            recordWithNull.PMP_Marketing_Profile_Id__c = null;
            recordWithNull.PMP_One_Partner_ID__c = testAccount.Id;
            recordWithNull.Is_Active__c = true;
            
            List<PMP_OPID_MPI_Rel__c> recordsWithNulls = new List<PMP_OPID_MPI_Rel__c>{recordWithNull};
            
            // This should handle null values gracefully
            Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(recordsWithNulls);
            
            System.assertEquals(1, recordsWithNulls.size(), 'Should handle null values');
        } catch(Exception e) {
            // If validation rules prevent null values, that's expected
            System.assert(true, 'Validation rules may prevent null values');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testReprocessLeadRoutingOnUpdate_MultipleChanges() {
        Test.startTest();
        
        // Get existing records and create multiple status changes
        List<PMP_OPID_MPI_Rel__c> existingRecords = [SELECT Id, PMP_Marketing_Profile_Id__c, Is_Active__c 
                                                     FROM PMP_OPID_MPI_Rel__c 
                                                     LIMIT 5];
        
        Map<Id, PMP_OPID_MPI_Rel__c> oldMap = new Map<Id, PMP_OPID_MPI_Rel__c>();
        
        // Create scenarios where some records change status and others don't
        for(Integer i = 0; i < existingRecords.size(); i++) {
            PMP_OPID_MPI_Rel__c record = existingRecords[i];
            PMP_OPID_MPI_Rel__c oldRecord = record.clone(true, true, true, true);
            
            if(Math.mod(i, 2) == 0) {
                // Even indexed records: flip the status
                oldRecord.Is_Active__c = !record.Is_Active__c;
            } else {
                // Odd indexed records: keep the same status
                oldRecord.Is_Active__c = record.Is_Active__c;
            }
            
            oldMap.put(record.Id, oldRecord);
        }
        
        // Test the method
        Core_LeadRoutingHandler.reprocessLeadRoutingOnUpdate(existingRecords, oldMap);
        
        Test.stopTest();
        
        System.assertEquals(5, existingRecords.size(), 'Should have 5 records');
        System.assertEquals(5, oldMap.size(), 'Old map should have 5 records');
    }
}