@isTest
public class Account_PulseTest {
    
    @testSetup
    static void setupTestData() {
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User adminUser = new User(Alias = 'admin',
                                  Email='adminTest010@intel.com', 
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing01',
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = prf.Id, 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName='adminTest010@intel.com');
        insert adminUser;
        System.RunAs(adminUser){
            // Create test Account
            Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            // Create a new account        
            Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);
            insert acct;
            
            // Create test User
            User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];
            
            // Create test Opportunity
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Qualify',
                CloseDate = Date.today().addDays(30),
                AccountId = acct.Id,
                OwnerId = adminUser.Id,
                Amount = 10000,
                Description = 'Test Description',
                Core_Status_Update__c = 'Test Status Update',
                Core_Risk_Reason__c = 'Test Risk Reason',
                RecordTypeId = newOppRecTypeId
            );
            insert testOpportunity;
            
            // Create test OpportunityLineItem
            Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
            insert testProduct;
            
            PricebookEntry testPricebookEntry = new PricebookEntry(
                Pricebook2Id =  Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert testPricebookEntry;
            
            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = testPricebookEntry.Id
            );
            insert testOpportunityLineItem;
            
            // Create test Core_Opportunity_Partner__c
            Core_Opportunity_Partner__c testPartner = new Core_Opportunity_Partner__c(
                Core_Opportunity__c=testOpportunity.Id, Core_Partner__c=acct.Id,
                Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'
            );
            insert testPartner;
            
            // Create test Task
            Task testTask = new Task(
                WhatId = testOpportunity.Id,
                Subject = 'Test Task',
                Description = 'Test Task Description',
                Status = 'Not Started'
            );
            insert testTask;
            
            // Create test FeedItem
            FeedItem testFeedItem = new FeedItem(
                ParentId = testOpportunity.Id,
                Body = 'Test Feed Item',
                CreatedById = testUser.Id
            );
            insert testFeedItem;
        }        
    }
    
    
    @isTest
    static void testGetAccountPulseWithAccountId() {
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/accountpulse/' + testAccount.Id;
        RestContext.request = req;
        
        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        Pricing_RestAPI_Response response = Account_Pulse.getAccountPulse();
        Test.stopTest();
        
        // Validate the response
        System.assertNotEquals(null, response);
        System.assertEquals(0, response.totalRecords); // Assuming no opportunities are returned
    }
    
    @isTest
    static void testGetAccountPulseWithOpportunityId() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id LIMIT 1];
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/accountpulse/' + testOpportunity.Id;
        RestContext.request = req;
        
        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        Pricing_RestAPI_Response response = Account_Pulse.getAccountPulse();
        Test.stopTest();
        
        // Validate the response
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.totalRecords); // Assuming no opportunities are returned
    }
    
    @isTest
    static void testRunExample() {
        Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        // Create test users and roles
        UserRole role1 = new UserRole(Name = 'Admin');
        insert role1;
        
        UserRole role2 = new UserRole(Name = 'Admin-1', ParentRoleId = role1.Id);
        insert role2;
        
        User user1 = new User(ProfileId = prf.Id, Core_WWID__c = '12345678',LastName = 'User 1', Email = 'user12@intel.com', Username = 'user12@intel.com', Alias = 'user99', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', UserRoleId = role1.Id);
        insert user1;
        
        User user2 = new User(ProfileId = prf.Id, Core_WWID__c = '12345679',LastName = 'User 2', Email = 'user22@intel.com', Username = 'user22@intel.com', Alias = 'user97', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', UserRoleId = role2.Id);
        insert user2;
        
        // Call the method
        Test.startTest();
        List<User> hierarchy = Account_Pulse.runExample(user1.Core_WWID__c);
        Test.stopTest();
        
        // Validate the response
        System.assertNotEquals(null, hierarchy);
        System.assertEquals(1, hierarchy.size());
        System.assertEquals(user1.Id, hierarchy[0].Id);
    }
}