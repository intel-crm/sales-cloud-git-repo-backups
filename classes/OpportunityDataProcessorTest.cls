@isTest
public class OpportunityDataProcessorTest {
    @isTest
    static void testGetAccountOpportunityData() {
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
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExec25 = new Core_Trigger_Executions__c();
            triggerExec25.Name='Tech_CIMID_Validation'; 
            triggerExec25.Core_Class_Name__c='Core_POP_Handler';
            triggerExec25.Core_Object__c='Opportunity';
            triggerExec25.Core_Trigger_Events__c='before insert'; 
            triggerExec25.Core_Active__c=true; 
            triggerExec25.Core_Description__c = 'blah blah';
            triggerExecList.add(triggerExec25);
            insert triggerExecList;
            Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            // Create a new account        
            Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Core_CIM_ID__c = '123456',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);
            insert acct;
            Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
            insert testProduct;
            
            PricebookEntry testPricebookEntry = new PricebookEntry(
                Pricebook2Id =  Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert testPricebookEntry;
            // Create test Opportunity
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity 1',
                StageName = 'Qualify',
                CloseDate = Date.today().addMonths(-5),
                AccountId = acct.Id,
                OwnerId = adminUser.Id,
                Amount = 10000,
                Description = 'Test Description',
                Core_Status_Update__c = 'Test Status Update',
                Core_Risk_Reason__c = 'Test Risk Reason',
                RecordTypeId = newOppRecTypeId
            );
            insert testOpportunity;
            
            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = testPricebookEntry.Id
            );
            insert testOpportunityLineItem;
            
            Opportunity testOpportunity2 = new Opportunity(
                Name = 'Test Opportunity 2',
                StageName = 'Qualify',
                CloseDate = Date.today().addMonths(-10),
                AccountId = acct.Id,
                OwnerId = adminUser.Id,
                Amount = 10000,
                Description = 'Test Description',
                Core_Status_Update__c = 'Test Status Update',
                Core_Risk_Reason__c = 'Test Risk Reason',
                RecordTypeId = newOppRecTypeId
            );
            insert testOpportunity2;
            testOpportunity2.StageName = 'Design Win';
            Update testOpportunity2;
            OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
                OpportunityId = testOpportunity2.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = testPricebookEntry.Id
            );
            insert testOpportunityLineItem2;
            
            Opportunity testOpportunity3 = new Opportunity(
                Name = 'Test Opportunity 3',
                StageName = 'Lost',
                CloseDate = Date.today().addMonths(-2),
                AccountId = acct.Id,
                OwnerId = adminUser.Id,
                Amount = 10000,
                Description = 'Test Description',
                Core_Status_Update__c = 'Test Status Update',
                Core_Risk_Reason__c = 'Test Risk Reason',
                RecordTypeId = newOppRecTypeId
            );
            insert testOpportunity3;
            
            OpportunityLineItem testOpportunityLineItem3 = new OpportunityLineItem(
                OpportunityId = testOpportunity3.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = testPricebookEntry.Id
            );
            insert testOpportunityLineItem3;
            
            // Set up the REST request and response
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/productdetails/' + testProduct.Id;
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        OpportunityDataProcessor.getAccountOpportunityData();

        // Verify the response
        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, res.responseBody);

        // Deserialize the response
        List<OpportunityDataProcessor.AccountOpportunityData> responseData = 
            (List<OpportunityDataProcessor.AccountOpportunityData>) JSON.deserialize(res.responseBody.toString(), List<OpportunityDataProcessor.AccountOpportunityData>.class);
        
        }  
    }
}