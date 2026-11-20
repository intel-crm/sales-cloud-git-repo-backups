@isTest
public class AI_OpportunityDataAPIV2_Test {
    
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
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;   
            // Create test Account
            Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            // Create a new account        
            Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Core_Sales_Groups__c = 'APJ Hosted Sales Group',
                                       BillingPostalCode = '12345', RecordTypeId = accDealID);
            insert acct;
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            // Create test data for Opportunity
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                AccountId = acct.Id,
                StageName = 'Qualify',
                CloseDate = Date.today().addMonths(-10),
                Amount = 10000,
                OwnerId = adminUser.Id,
                RecordTypeId = newOppRecTypeId
            );
            insert testOpportunity;
            
            Product2 testProduct = new Product2(Name = 'Lunar Lake', IsActive = true);
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
            
            Core_Opportunity_Partner__c testPartner = new Core_Opportunity_Partner__c(
                Core_Opportunity__c=testOpportunity.Id, Core_Partner__c=acct.Id,
                Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'
            );
            insert testPartner;
            
            // Create test data for FeedItem
            FeedItem testFeedItem = new FeedItem(
                ParentId = testOpportunity.Id,
                Body = 'Test Chatter Post',
                CreatedById = UserInfo.getUserId()
            );
            insert testFeedItem;
            
            // Create test data for Task
            Task testTask = new Task(
                WhatId = testOpportunity.Id,
                Subject = 'Test Task',
                Description = 'Test Task Description',
                Status = 'Not Started',
                Priority = 'Normal'
            );
            insert testTask;
        }
    }
    
    @isTest
    static void testGetOpportunityData() {
        System.runAs(Core_Test_Utility.systemAdminUser){
            Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
            // Set up the mock request
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/OpportunityAIDataV2';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"AccountId": "'+testAccount.id+'","Stage": "Qualify"}');
            RestContext.request = req;
            
            // Set up the mock response
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            // Call the method
            Pricing_RestAPI_Response response = AI_OpportunityDataAPIV2.getOpportunityData();
            
            // Verify the response
            System.assertNotEquals(null, response);
            System.assertEquals(1, response.totalRecords);
            System.assertEquals(1, response.successContent.size());
            
            // Verify the opportunity data
            AI_OpportunityDataWrapper.OpportunityWrapper oppWrapper = (AI_OpportunityDataWrapper.OpportunityWrapper) response.successContent[0];
            System.assertEquals(1, oppWrapper.opportunities.size());
            System.assertEquals(1, oppWrapper.opportunityProducts.size());
            System.assertEquals(1, oppWrapper.opportunityPartners.size());
        }        
    }
    
    @isTest
    static void testGetOpportunityDataWithNoFilters() {
        // Set up the mock request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/OpportunityAIDataV2';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        
        // Set up the mock response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        Pricing_RestAPI_Response response = AI_OpportunityDataAPIV2.getOpportunityData();
        
        // Verify the response
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.totalRecords);
        System.assertEquals(1, response.successContent.size());
        
        // Verify the opportunity data
        AI_OpportunityDataWrapper.OpportunityWrapper oppWrapper = (AI_OpportunityDataWrapper.OpportunityWrapper) response.successContent[0];
        System.assertEquals(1, oppWrapper.opportunities.size());
        System.assertEquals(0, oppWrapper.opportunityProducts.size());
        System.assertEquals(0, oppWrapper.opportunityPartners.size());
    }
    
    @isTest
    static void testGetOpportunityDataWithDifferentFilters() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        // Set up the mock request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/OpportunityAIDataV2';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"AccountId": "'+testAccount.id+'"}');
        RestContext.request = req;
        
        // Set up the mock response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method
        Pricing_RestAPI_Response response = AI_OpportunityDataAPIV2.getOpportunityData();
        
        // Verify the response
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.totalRecords);
        System.assertEquals(1, response.successContent.size());
        
        // Verify the opportunity data
        AI_OpportunityDataWrapper.OpportunityWrapper oppWrapper = (AI_OpportunityDataWrapper.OpportunityWrapper) response.successContent[0];
        System.assertEquals(1, oppWrapper.opportunities.size());
        System.assertEquals(1, oppWrapper.opportunityProducts.size());
        System.assertEquals(1, oppWrapper.opportunityPartners.size());
    }
}