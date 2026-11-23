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
    
    @testSetup
    static void setupTestData() {
        
        Id profId = [select Id from Profile where Name = :SALES_REP_BB_PROFILE_NAME limit 1][0].Id;
        
        User testUser = new User(UserName=TEST_USERNAME, LastName='User 1', Email='test.user1@intel.com',
                                 Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                 ProfileId=profId, LanguageLocaleKey='en_US', Core_WWID__c=TEST_WWID);
        insert testUser;
        
        Account acct = Core_Test_Utility.createAccount(1)[0];
        acct.Name = 'Test Account';
        insert acct;
        
        // Main opportunities we'll use for testing
        List<Opportunity> opps = Core_Test_Utility.createOpportunity(5);
        opps[0].Name = TEST_OPPTY1_NAME;
        opps[1].Name = TEST_OPPTY2_NAME;
        opps[2].Name = TEST_OPPTY3_NAME;
        opps[3].Name = TEST_OPPTY4_NAME;
        opps[4].Name = TEST_OPPTY5_NAME;
        
        for (Opportunity opp : opps)
            opp.AccountId = acct.Id;
        
        insert opps;
        
        // Some more opportunities to trigger "too many matches"
        List<Opportunity> opps2 = Core_Test_Utility.createOpportunity(205);
        for (Opportunity opp : opps2) {
            opp.Name = TEST_EXTRA_OPPTYS_NAME;
            opp.AccountId = acct.Id;
        }
        insert opps2;
        
        // Share the first, third, and fourth opportunities with the user
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        oppShares.add(new OpportunityShare(OpportunityId=opps[0].Id, UserOrGroupId=testUser.Id, OpportunityAccessLevel='Read', RowCause='Manual'));
        oppShares.add(new OpportunityShare(OpportunityId=opps[2].Id, UserOrGroupId=testUser.Id, OpportunityAccessLevel='Read', RowCause='Manual'));
        oppShares.add(new OpportunityShare(OpportunityId=opps[3].Id, UserOrGroupId=testUser.Id, OpportunityAccessLevel='Read', RowCause='Manual'));
        insert oppShares;
    }

    static private testMethod void testOpportunitySearch() {
        
        User testUser = [select Id from User where UserName = :TEST_USERNAME];
        Account testAccount = [select Id, Name from Account limit 1][0];
        List<Opportunity> opps = [select Id, Name, AccountId from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 5];
        
        // For testing SOSL, we need to define a fixed list of ID values to be returned
        List<Id> oppIds = new List<Id>{opps[0].Id, opps[1].Id, opps[3].Id, opps[4].Id};
        Test.setFixedSearchResults(oppIds);
        
        System.RestResponse res = new System.RestResponse();
        RestContext.response = res;
        
        // Execute a search... we should get back the 1st, 2nd, 4th, and 5th records out of the 5, but only the 1st and 4th
        // should have Names returned, since that's all the user should have access to
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'test');
        System.assertEquals(200, res.statusCode);
        System.assertEquals(4, oppInfoList.size());
        
        System.debug('11111: ' + oppInfoList);
        System.debug('22222: ' + JSON.serialize(oppInfoList));
        
        // Count the # of Opportunity Names populated - it should be 2
        System.assert(JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY2_NAME));
        System.assert(JSON.serialize(oppInfoList).contains(TEST_OPPTY4_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY5_NAME));
        /*Integer numNamesPopulated = 0;
        Integer numNamesBlank = 0;
        for (Core_OpportunityNameSearch.OpportunityInfo oppInfo : oppInfoList) {
            if (oppInfo.Name == '') numNamesBlank++;
            else numNamesPopulated++;
        }
        System.assertEquals(2, numNamesPopulated);
        System.assertEquals(2, numNamesBlank);*/
        /*
        // Count the # of Account Names populated - it should be 2
        numNamesPopulated = 0;
        numNamesBlank = 0;
        for (Core_OpportunityNameSearch.OpportunityInfo oppInfo : oppInfoList) {
            if (oppInfo.AccountName == '') numNamesBlank++;
            else numNamesPopulated++;
        }
        System.assertEquals(2, numNamesPopulated);
        System.assertEquals(2, numNamesBlank);*/
        
        // Execute a search on 1 opp ID
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, oppIds[0]);
        System.assertEquals(200, res.statusCode);
        System.assertEquals(1, oppInfoList.size());
        System.assert(JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME));
        
        // Execute a search based on multiple opp IDs... we should get back the 1st & 2nd, but only the 1st should have Name returned,
        // since that's all the user should have access to
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, oppIds[0] + ',' + oppIds[1]);
        System.assertEquals(200, res.statusCode);
        System.assertEquals(2, oppInfoList.size());
        System.assert(JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY2_NAME));
    }
    
    static private testMethod void testOpportunitySearchInvalidUser() {
        
        User testUser = [select Id from User where UserName = :TEST_USERNAME];
        Account testAccount = [select Id, Name from Account limit 1][0];
        List<Opportunity> opps = [select Id, Name, AccountId from Opportunity where Name != :TEST_EXTRA_OPPTYS_NAME order by Name limit 5];
        
        // For testing SOSL, we need to define a fixed list of ID values to be returned
        List<Id> oppIds = new List<Id>{opps[0].Id, opps[1].Id, opps[3].Id, opps[4].Id};
        Test.setFixedSearchResults(oppIds);
        
        // Execute a search... we should get back the 1st, 2nd, 4th, and 5th records out of the 5, but only the 1st and 4th
        // should have Names returned, since that's all the user should have access to
        List<Core_OpportunityNameSearch.OpportunityInfo> oppInfoList;
        
        // User doesn't exist - check to make sure results are returned, but no names
        System.RestResponse res = new System.RestResponse();
        RestContext.response = res;
        oppInfoList = Core_OpportunityNameSearch.doPost('98765432', 'test');
        System.assertEquals(200, res.statusCode);
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY2_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY4_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY5_NAME));
        
        // Duplicate user - check to make sure results are returned, but no names
        Id profId = [select Id from Profile where Name = :SALES_REP_BB_PROFILE_NAME limit 1][0].Id;
        User testUser2 = new User(UserName=TEST_USERNAME+'2', LastName='User 2', Email='test.user2@intel.com',
                                  Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                  ProfileId=profId, LanguageLocaleKey='en_US', Core_WWID__c=TEST_WWID);
        insert testUser2;
        
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, 'test');
        System.assertEquals(200, res.statusCode);
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY1_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY2_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY4_NAME));
        System.assert(!JSON.serialize(oppInfoList).contains(TEST_OPPTY5_NAME));
        
        // Too many opptys returned
        opps = [select Id, Name, AccountId from Opportunity where Name = :TEST_EXTRA_OPPTYS_NAME];
        oppIds = new List<Id>();
        for (Opportunity opp : opps)
            oppIds.add(opp.Id);
        Test.setFixedSearchResults(oppIds);
        
        oppInfoList = Core_OpportunityNameSearch.doPost(TEST_WWID, TEST_EXTRA_OPPTYS_NAME);
        System.assertEquals(413, res.statusCode);
        System.assertEquals(null, oppInfoList);
    }
}