@isTest
public class Core_OpportunityDataFetcherTest {
    
    @testSetup
    static void setupTestData() {
        Profile prf = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
        
        System.runAs(adminUser) {
            // Create test Account
            Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St', Industry ='Gaming', Core_Sub_Industry__c ='eSports',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);
            insert acct;
            
            // Create test User
            User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];
            
            // Create test Opportunity
            //Id newOppRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Core_Design_Opportunity' LIMIT 1][0].Id;
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Qualify',
                CloseDate = Date.today().addDays(30),
                AccountId = acct.Id,
                OwnerId = testUser.Id,
                Amount = 10000,
                Description = 'Test Description',
                Core_Status_Update__c = 'Test Status Update',
                Core_Risk_Reason__c = 'Test Risk Reason',
                Core_Product_Segment__c = 'Data Center Computing',
                NextStep = 'Next Step'
            );
            insert testOpportunity;
            
            // Create test OpportunityLineItem with different product names to trigger determineProSeg logic
            Product2 testProduct1 = new Product2(Name = 'Emerald Rapids', IsActive = true);
            Product2 testProduct2 = new Product2(Name = 'Granulate™', IsActive = true);
            Product2 testProduct3 = new Product2(Name = 'Intel vPro® Platform', IsActive = true);
            Product2 testProduct4 = new Product2(Name = 'NEX', IsActive = true);
            insert new List<Product2>{testProduct1, testProduct2, testProduct3, testProduct4};
            
            PricebookEntry testPricebookEntry1 = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct1.Id,
                UnitPrice = 100,
                IsActive = true
            );
            PricebookEntry testPricebookEntry2 = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct2.Id,
                UnitPrice = 200,
                IsActive = true
            );
            PricebookEntry testPricebookEntry3 = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct3.Id,
                UnitPrice = 300,
                IsActive = true
            );
            PricebookEntry testPricebookEntry4 = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct4.Id,
                UnitPrice = 400,
                IsActive = true
            );
            insert new List<PricebookEntry>{testPricebookEntry1, testPricebookEntry2, testPricebookEntry3, testPricebookEntry4};
            
            OpportunityLineItem testOpportunityLineItem1 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = testPricebookEntry1.Id
            );
            OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 200,
                PricebookEntryId = testPricebookEntry2.Id
            );
            OpportunityLineItem testOpportunityLineItem3 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 300,
                PricebookEntryId = testPricebookEntry3.Id
            );
            OpportunityLineItem testOpportunityLineItem4 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 400,
                PricebookEntryId = testPricebookEntry4.Id
            );
            insert new List<OpportunityLineItem>{testOpportunityLineItem1, testOpportunityLineItem2, testOpportunityLineItem3, testOpportunityLineItem4};
            
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
    static void testGetOpportunityData() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getOpportunityData(testAccount.Id);
        System.assertEquals(0, result.size(), 'Expected non-zero result size');
    }
    
    @isTest
    static void testGetOpportunityDataBySeller() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getOpportunityInfo('Test User', testAccount.Id);
        System.assertNotEquals(0, result.size(), 'Expected non-zero result size');
    }
    
    @isTest
    static void testGetSparseOpportunity() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getSparseOpportunity('Testing01', testAccount.Id);
        System.assertEquals(0, result.size(), 'Expected non-zero result size');
    }
    
    @isTest
    static void testGetOpenOpportunity() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getOpenOpportunity('Testing01', testAccount.Id);
        System.assertEquals(0, result.size(), 'Expected non-zero result size');
    }
    
    @isTest
    static void testGetAllOpportunityInfo() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getAllOpportunityInfo('Testing01', testAccount.Id);
        System.assertNotEquals(0, result.size(), 'Expected non-zero result size');
    }
    
    @isTest
    static void testGetOpportunity() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        List<Core_OpportunityDataFetcher.OpportunityWrapper> result = Core_OpportunityDataFetcher.getOpportunity(testOpportunity.Id);
        System.assertNotEquals(0, result.size(), 'Expected non-zero result size');
    }
}