@isTest
public class SWS_6SenseIntegrationBatchTest {
    
    @testSetup 
    private static void setup(){
        User u = SWS_TestUtilty.createUser();
        System.runAs(u){ 
            Account acc = new Account();
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            acc.Name = 'Test Account'+ math.random();
            acc.Core_Account_Type__c = 'Distributor;End Customer';
            acc.Industry = 'Banking';
            acc.BillingCity = 'Texas';
            acc.BillingCountry = 'USA';
            acc.BillingStreet = 'G-2101'; 
            acc.Core_Sales_Groups__c = 'EMEA Sales Group'; 
            acc.Core_Geo__c = 'APJ';
            acc.Core_Sub_Geo__c = 'IJKK';
            acc.Core_PSG_Account__c = true;
            acc.Core_Account_Tier__c ='PSG-Tier 4';
            acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
            acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
            acc.Core_Is_Active__c = true;
            acc.Core_Account_Primary_Coverage__c = 'Intel Covered';
            acc.Core_Account_Category__c = 'Distributors (IA)';
            acc.Is_6Sense_Integration_Enabled__c = true;
            acc.Core_Export_Compliance_Block__c = false;
            insert acc;
            
            Account accDisabled = acc.clone(false, false, false, false);
            accDisabled.Name = 'Test Account Disabled' + math.random();
            accDisabled.Is_6Sense_Integration_Enabled__c = false;
            insert accDisabled;
            
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            
            List<Opportunity> opportunities = new List<Opportunity>();
            
            Opportunity opportunity1 = new Opportunity(
                Name = 'Test Opportunity1', 
                RecordTypeId = newOppRecTypeId, 
                AccountId = acc.Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today(),
                Core_Military_Aerospace_Govmt_End_Use__c = 'No',
                Core_Consumption_Market__c = 'Education',
                Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                Core_Opportunity_Type__c = 'Design: Original',
                Core_Design_Registration_Id__c = null
            );
            opportunities.add(opportunity1);
            
            Opportunity opportunity2 = new Opportunity(
                Name = 'Test Opportunity2', 
                RecordTypeId = newOppRecTypeId, 
                AccountId = acc.Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today(),
                Core_Military_Aerospace_Govmt_End_Use__c = 'No',
                Core_Consumption_Market__c = 'Education',
                Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                Core_Opportunity_Type__c = 'Design: Original',
                Core_Design_Registration_Id__c = null
            );
            opportunities.add(opportunity2);
            
            Opportunity opportunity3 = new Opportunity(
                Name = 'Test Opportunity3', 
                RecordTypeId = newOppRecTypeId, 
                AccountId = accDisabled.Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today(),
                Core_Military_Aerospace_Govmt_End_Use__c = 'No',
                Core_Consumption_Market__c = 'Education',
                Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                Core_Opportunity_Type__c = 'Design: Original',
                Core_Design_Registration_Id__c = null
            );
            opportunities.add(opportunity3);
            
            insert opportunities;
        }
    }
    
    @isTest 
    private static void SWS_6SenseIntegrationTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Account> acc = [SELECT Id FROM Account WHERE Is_6Sense_Integration_Enabled__c = true];
            
            Test.startTest();
            SWS_6SenseIntegrationBatch.IntegrationWrapper wrapper = new SWS_6SenseIntegrationBatch.IntegrationWrapper();
            wrapper.accountId = acc[0].Id;
            List<SWS_6SenseIntegrationBatch.IntegrationWrapper> wrapperList = new List<SWS_6SenseIntegrationBatch.IntegrationWrapper>();
            wrapperList.add(wrapper);
            SWS_6SenseIntegrationBatch.SWS_6SenseIntegration(wrapperList);
            Test.stopTest();
            
            Group sixSenseGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SWS_6Sense_Admin_Group' LIMIT 1];
            List<OpportunityShare> createdShares = [
                SELECT Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel 
                FROM OpportunityShare 
                WHERE UserOrGroupId = :sixSenseGroup.Id 
                AND Opportunity.AccountId = :acc[0].Id
            ];
            
            System.assert(createdShares.size() > 0, 'OpportunityShare records should be created');
        }
    }
    
    @isTest 
    private static void testBatchWithExistingShares(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Account> acc = [SELECT Id FROM Account WHERE Is_6Sense_Integration_Enabled__c = true];
            List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId = :acc[0].Id];
            Group sixSenseGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SWS_6Sense_Admin_Group' LIMIT 1];
            
            List<OpportunityShare> existingShares = new List<OpportunityShare>();
            for(Opportunity opp : opportunities) {
                existingShares.add(new OpportunityShare(
                    OpportunityId = opp.Id,
                    UserOrGroupId = sixSenseGroup.Id,
                    OpportunityAccessLevel = 'Read',
                    RowCause = Schema.OpportunityShare.RowCause.Manual
                ));
            }
            insert existingShares;
            
            Integer initialShareCount = [
                SELECT COUNT() FROM OpportunityShare 
                WHERE UserOrGroupId = :sixSenseGroup.Id 
                AND Opportunity.AccountId = :acc[0].Id
            ];
            
            Test.startTest();
            SWS_6SenseIntegrationBatch batchJob = new SWS_6SenseIntegrationBatch(acc[0].Id);
            Database.executeBatch(batchJob, 200);
            Test.stopTest();
            
            Integer finalShareCount = [
                SELECT COUNT() FROM OpportunityShare 
                WHERE UserOrGroupId = :sixSenseGroup.Id 
                AND Opportunity.AccountId = :acc[0].Id
            ];
            
            System.assertEquals(initialShareCount, finalShareCount, 
                'No additional sharing records should be created when they already exist');
        }
    }
    
    @isTest 
    private static void testBatchDirectExecution(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Account> acc = [SELECT Id FROM Account WHERE Is_6Sense_Integration_Enabled__c = true];
            
            // Query the existing SWS_6Sense_Admin_Group
            Group sixSenseGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SWS_6Sense_Admin_Group' LIMIT 1];
            
            // Ensure no existing shares to guarantee else block execution
            List<OpportunityShare> existingShares = [
                SELECT Id FROM OpportunityShare 
                WHERE UserOrGroupId = :sixSenseGroup.Id 
                AND Opportunity.AccountId = :acc[0].Id
            ];
            if(!existingShares.isEmpty()) {
                delete existingShares;
            }
            
            Test.startTest();
            SWS_6SenseIntegrationBatch batchJob = new SWS_6SenseIntegrationBatch(acc[0].Id);
            Database.executeBatch(batchJob, 200);
            Test.stopTest();
            
            List<OpportunityShare> createdShares = [
                SELECT Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause
                FROM OpportunityShare 
                WHERE UserOrGroupId = :sixSenseGroup.Id 
                AND Opportunity.AccountId = :acc[0].Id
            ];
            
            System.assert(createdShares.size() > 0, 'New OpportunityShare records should be created');
            
            for(OpportunityShare share : createdShares) {
                System.assertEquals('Read', share.OpportunityAccessLevel, 'Access level should be Read');
                System.assertEquals(Schema.OpportunityShare.RowCause.Manual, share.RowCause, 'Row cause should be Manual');
            }
        }
    }
    
    @isTest 
    private static void testBatchConstructorAndMethods(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Account> acc = [SELECT Id FROM Account WHERE Is_6Sense_Integration_Enabled__c = true];
            
            Test.startTest();
            SWS_6SenseIntegrationBatch batchJob = new SWS_6SenseIntegrationBatch(acc[0].Id);
            System.assertEquals(acc[0].Id, batchJob.accountId, 'Account ID should be set correctly');
            Database.QueryLocator ql = batchJob.start(null);
            System.assertNotEquals(null, ql, 'QueryLocator should not be null');
            Test.stopTest();
        }
    }
}