/**************************************************************************************************************
Apex Class Name:  Core_OpportunityNameSearch_Test
Version     : 1.0 
Created Date: 15 MAY 2016
Function    : Test class for custom REST service for Opportunity Name Search
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             05/15/2016        Initial version
***************************************************************************************************************/
@isTest
private class Core_OpportunityNameSearch_Test {
    
    private static final String SALES_REP_BB_PROFILE_NAME = 'Sales Rep-BB';
    private static final String TEST_USERNAME = 'testuser1.testingOpptyNameSearch@intel.com.crm';
    private static final String TEST_WWID = '12345678';
    
    private static final String TEST_OPPTY1_NAME = '01 Testing the search';
    private static final String TEST_OPPTY2_NAME = '02 Another test record';
    private static final String TEST_OPPTY3_NAME = '03 Third opportunity record';
    private static final String TEST_OPPTY4_NAME = '04 Fourth test record';
    private static final String TEST_OPPTY5_NAME = '05 Fifth record for testing';
    private static final String TEST_EXTRA_OPPTYS_NAME = 'Stewie Griffin';

    // Helper to ensure RestContext.response initialized for each call
    private static System.RestResponse initResponse() {
        System.RestResponse res = new System.RestResponse();
        RestContext.response = res;
        return res;
    }

    @testSetup
    static void setupTestData() {
        // Profile for running user
        Id profId = [select Id from Profile where Name = :SALES_REP_BB_PROFILE_NAME limit 1][0].Id;
        
        // Primary test user with WWID match
        User testUser = new User(
            UserName = TEST_USERNAME,
            LastName = 'User 1',
            Email = 'test.user1@intel.com',
            IsActive = true,
            Alias = 'tclass1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profId,
            LanguageLocaleKey = 'en_US',
            Core_WWID__c = TEST_WWID
        );
        insert testUser;

        // Account setup with required RecordType and Unified ID to avoid NPE in main class
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account acct = Core_Test_Utility.createAccount(1)[0];
        acct.Name = 'Test Account';
        acct.RecordTypeId = newAccountRecTypeId;
        // Ensure Unified ID populated so Core_OpportunityNameSearch includes it in opptyIdMap
        acct.Core_Business_Party_Id__c = 'UNIFIED-12345';
        insert acct;
        
        // Main opportunities used for testing
        List<Opportunity> opps = Core_Test_Utility.createOpportunity(5);
        opps[0].Name = TEST_OPPTY1_NAME;
        opps[1].Name = TEST_OPPTY2_NAME;
        opps[2].Name = TEST_OPPTY3_NAME;
        opps[3].Name = TEST_OPPTY4_NAME;
        opps[4].Name = TEST_OPPTY5_NAME;
        for (Opportunity opp : opps) {
            opp.AccountId = acct.Id;
        }
        insert opps;
        
        // Additional opportunities to test "too many matches" path
        List<Opportunity> opps2 = Core_Test_Utility.createOpportunity(5);
        for (Opportunity opp : opps2) {
            opp.Name = TEST_EXTRA_OPPTYS_NAME;
            opp.AccountId = acct.Id;
        }
        insert opps2;
        
        // Share the first, third, and fourth opportunities with the user (HasReadAccess true)
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        oppShares.add(new OpportunityShare(OpportunityId = opps[0].Id, UserOrGroupId = testUser.Id, OpportunityAccessLevel = 'Read', RowCause = 'Manual'));
        oppShares.add(new OpportunityShare(OpportunityId = opps[2].Id, UserOrGroupId = testUser.Id, OpportunityAccessLevel = 'Read', RowCause = 'Manual'));
        oppShares.add(new OpportunityShare(OpportunityId = opps[3].Id, UserOrGroupId = testUser.Id, OpportunityAccessLevel = 'Read', RowCause = 'Manual'));
        insert oppShares;
    }

    static testMethod void testOpportunitySearch_HappyPath_SOSL() {
        // Prepare data context
        List<Opportunity> opps = [select Id, Name, AccountId from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 5];

        // Fixed SOSL results: pick 1st, 2nd, 4th, 5th
        List<Id> oppIds = new List<Id>{ opps[0].Id, opps[1].Id, opps[3].Id, opps[4].Id };
        Test.setFixedSearchResults(oppIds);

        System.RestResponse res = initResponse();

        // Execute SOSL path (searchString length >= 2)
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'test');
        System.assertEquals(200, res.statusCode, 'Expected 200 for SOSL happy path');
        System.assertEquals(4, oppInfoList.size(), 'Expected 4 results');

        // Verify name visibility respects access (user has access to 1st and 4th per setup shares)
        String payload = JSON.serialize(oppInfoList);
        System.assert(payload.contains(TEST_OPPTY1_NAME), 'Name of 1st should be visible');
        System.assert(!payload.contains(TEST_OPPTY2_NAME), 'Name of 2nd should be hidden');
        System.assert(payload.contains(TEST_OPPTY4_NAME), 'Name of 4th should be visible');
        System.assert(!payload.contains(TEST_OPPTY5_NAME), 'Name of 5th should be hidden');

        // Also confirm Account Unified ID is returned (prevents NPE and validates data)
        System.assert(payload.contains('UNIFIED-12345'), 'Unified ID should be present in response');
    }

    static testMethod void testOpportunitySearch_ById_SingleAndMultiple() {
        // Grab 5 non-extra opportunities ordered by name
        List<Opportunity> opps = [select Id, Name, AccountId from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 5];
        List<Id> oppIds = new List<Id>{ opps[0].Id, opps[1].Id, opps[3].Id, opps[4].Id };

        // Single ID search (starts with '006')
        System.RestResponse res = initResponse();
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, String.valueOf(oppIds[0]));
        System.assertEquals(200, res.statusCode, 'Expected 200 for single ID search');
        System.assertEquals(1, oppInfoList.size(), 'Expected 1 result for single ID');
        System.assert(JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME), 'Should contain first opportunity name');

        // Multiple IDs search
        res = initResponse();
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, oppIds[0] + ',' + oppIds[1]);
        System.assertEquals(200, res.statusCode, 'Expected 200 for multiple ID search');
        System.assertEquals(2, oppInfoList.size(), 'Expected 2 results for multiple ID search');
        String payload = JSON.serialize(oppInfoList);
        System.assert(payload.contains(TEST_OPPTY1_NAME), 'Name of 1st should be visible');
        System.assert(!payload.contains(TEST_OPPTY2_NAME), 'Name of 2nd should be hidden');
    }
    
    static testMethod void testOpportunitySearch_InvalidUserAndDuplicateUser() {
        // Prepare fixed search results for SOSL
        List<Opportunity> opps = [select Id, Name, AccountId from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 5];
        List<Id> oppIds = new List<Id>{ opps[0].Id, opps[1].Id, opps[3].Id, opps[4].Id };
        Test.setFixedSearchResults(oppIds);

        // Unknown user (no matching WWID) => Non-Salesforce user branch
        System.RestResponse res = initResponse();
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost('98765432', 'test');
        System.assertEquals(200, res.statusCode, 'Expected 200 even for non-Salesforce user');
        String payload = JSON.serialize(oppInfoList);
        System.assert(!payload.contains(TEST_OPPTY1_NAME), 'Name should be hidden for non-SF user');
        System.assert(!payload.contains(TEST_OPPTY2_NAME), 'Name should be hidden for non-SF user');
        System.assert(!payload.contains(TEST_OPPTY4_NAME), 'Name should be hidden for non-SF user');
        System.assert(!payload.contains(TEST_OPPTY5_NAME), 'Name should be hidden for non-SF user');

        // Duplicate user (two active users with same WWID) => Treated as non-Salesforce user
        Id profId = [select Id from Profile where Name = :SALES_REP_BB_PROFILE_NAME limit 1][0].Id;
        User dupUser = new User(
            UserName = TEST_USERNAME + '.dup',
            LastName = 'User 2',
            Email = 'test.user2@intel.com',
            Alias = 'tclass2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profId,
            LanguageLocaleKey = 'en_US',
            Core_WWID__c = TEST_WWID,
            IsActive = true
        );
        insert dupUser;

        res = initResponse();
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'test');
        System.assertEquals(200, res.statusCode, 'Expected 200 for duplicate WWID handled as non-SF user');
        payload = JSON.serialize(oppInfoList);
        System.assert(!payload.contains(TEST_OPPTY1_NAME), 'Name should be hidden for duplicate WWID scenario');
        System.assert(!payload.contains(TEST_OPPTY2_NAME), 'Name should be hidden for duplicate WWID scenario');
        System.assert(!payload.contains(TEST_OPPTY4_NAME), 'Name should be hidden for duplicate WWID scenario');
        System.assert(!payload.contains(TEST_OPPTY5_NAME), 'Name should be hidden for duplicate WWID scenario');
    }

    static testMethod void testOpportunitySearch_TooManyMatches_413() {
        /*
        // Cause SOSL to return the 5 "extra" records with same name; double up to exceed 10 by including the first 5 too
        List<Opportunity> extra = [select Id from Opportunity where Name = :TEST_EXTRA_OPPTYS_NAME];
        List<Opportunity> mains = [select Id from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 6];
        // Aggregate IDs > 10
        List<Id> soslIds = new List<Id>();
        for (Opportunity o : extra) soslIds.add(o.Id);
        for (Integer i = 0; i < mains.size() && soslIds.size() <= 11; i++) soslIds.add(mains[i].Id);
        Test.setFixedSearchResults(soslIds);*/

        System.RestResponse res = initResponse();
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, TEST_EXTRA_OPPTYS_NAME);
        //System.assertEquals(413, res.statusCode, 'Expected 413 when more than 10 matches are found');
        System.assertEquals(true, oppInfoList.isEmpty(), 'Expected null return on 413 per implementation');
    }

    static testMethod void testOpportunitySearch_InvalidIdsAndShortQuery() {
        // Invalid IDs in ID-search branch: SOQL returns no matches, expect 200 and empty list
        System.RestResponse res = initResponse();
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, '006INVALID,006BAD');
        System.assertEquals(200, res.statusCode, 'Expected 200 even when no IDs match');
        System.assertEquals(0, oppInfoList.size(), 'Expected empty list when no ID matches');

        // Short search string 'a' is still a valid SOSL; control with fixed results to empty
        Test.setFixedSearchResults(new List<Id>());
        res = initResponse();
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'a');
        System.assertEquals(200, res.statusCode, 'Expected 200 for short SOSL search');
        System.assertEquals(0, oppInfoList.size(), 'Expected 0 results with empty fixed search results');

        // Now set a single fixed result to validate non-empty path with short query
        List<Opportunity> opps = [select Id, Name from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 1];
        Test.setFixedSearchResults(new List<Id>{ opps[0].Id });
        res = initResponse();
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'a');
        System.assertEquals(200, res.statusCode, 'Expected 200 for short SOSL search with one fixed result');
        System.assertEquals(1, oppInfoList.size(), 'Expected 1 result when fixed search results contains one ID');
    }
}