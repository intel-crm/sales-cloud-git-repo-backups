/**************************************************************************************************************
Apex Class Name:  Core_Batch_Delete_Dup_Accounts_Test
Version     : 1.1 
Created Date: 08 APR 2016
Function    : Test class for batch classes that delete duplicate accounts
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Anand Sharma             04/08/2016        Initial version
* Anand Sharma             04/11/2016        Added method to test the schedulable class
***************************************************************************************************************/

@isTest
public class Core_Batch_Delete_Dup_Accounts_Test {
    
    private static Id GetAccountId(){
        List<Account> dupAcList = [SELECT Id FROM Account WHERE Name =  'Dup Test1'] ;
        return dupAcList[0].Id ; 
    }
    
    private static Id GetOrgAccountId(){
        List<Account> dupAcList = [SELECT Id FROM Account WHERE Name =  'Dup Test'] ;
        return dupAcList[0].Id ; 
    }
    
    public Id dupId ;
    @testSetup 
    static void setupFixture() {
        Account acOrig = new Account(Name='Dup Test', BillingStreet = '1222 NE 15th Av.', BillingCity = 'Hillsboro', BillingCountryCode = 'USA' ) ;
        insert acOrig ;
        Account acDup = new Account(Name='Dup Test1', BillingStreet = '1221 NE 15th Av.', BillingCity = 'Hillsboro', BillingCountryCode = 'USA', Core_Is_Duplicate__c = acOrig.Id,CreatedById = System.Label.Core_CRM_Integration_User_ID, OwnerId=System.Label.Core_Uncovered_Account_ID ) ;
        insert acDup ;
        Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'Delete_Dup_Accounts';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c = 'Delete_Dup_Accounts';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted');   
    }
        
        //--------------------------------------------------------------------------------------------
        // Test the method when Account has no transaction records
        // 
        static testMethod void testDeleteNoRecords() {
            
            Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
            Test.StartTest() ;
            DataBase.executeBatch(dupBatch) ;
            Test.stopTest() ;
            Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
            //System.assertEquals(0, numAc);    
            
        }
        
        // Test method to test when Account has Lead records
        /*static testMethod void testNoDeleteLeadRecords() {

Lead leadWithAc = new Lead(FirstName = 'Lead', LastName = 'Test', Email = 'lead.test@intel.com', Phone = '503-645-7222', Company = 'Test Lead Intel',LeadSource = 'BANT Form', CountryCode = 'USA', Core_Existing_Covered_Account__c = GetAccountId()) ;
insert leadWithAc ;
Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
Test.StartTest() ;
DataBase.executeBatch(dupBatch) ;
Test.stopTest() ;
Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
System.assertEquals(1, numAc);    
}*/
        
        // Test method to test when Account has Opportunity records
        /* static testMethod void testNoDeleteOppRecords() {

Opportunity oppWithAc = new Opportunity(AccountId = GetAccountId(), Name = 'Test Opp', StageName = 'Qualify', Type = 'New Business', CloseDate= date.ValueOf('2017-09-21')) ;
insert oppWithAc ;
Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
Test.StartTest() ;
DataBase.executeBatch(dupBatch) ;
Test.stopTest() ;
Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
System.assertEquals(1, numAc);    
}*/
        
        // Test method to test when Account has Opportunity Partner records
        /*    static testMethod void testNoDeleteOppPartnerRecords() {

Opportunity oppWithAc = new Opportunity(AccountId = GetOrgAccountId(), Name = 'Test Opp', StageName = 'Qualify', Type = 'New Business', CloseDate= date.ValueOf('2017-09-21')) ;
insert oppWithAc ;
Core_Opportunity_Partner__c oppPartner = new Core_Opportunity_Partner__c(Core_Partner__c = GetAccountId(),Core_Opportunity__c = oppWithAc.Id ) ;
insert oppPartner ;
Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
Test.StartTest() ;
DataBase.executeBatch(dupBatch) ;
Test.stopTest() ;
Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
System.assertEquals(1, numAc);    
}
*/
        // Test method to test when Account has contact records
        /*  static testMethod void testNoDeleteContactRecords() {

Contact contactWithAc = new Contact(AccountId = GetAccountId(), FirstName = 'Test',  LastName = 'Contact', Title = 'Contact Title', Email = 'contact.title@intel.com') ;
insert contactWithAc ;
Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
Test.StartTest() ;
DataBase.executeBatch(dupBatch) ;
Test.stopTest() ;
Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
System.assertEquals(1, numAc);    
}*/
        
        // Test method to test when Account has Channel Sales Out records
        static testMethod void testNoDeleteChannelSoRecords() {
            
            Core_Channel_Salesout__c channelSoWithAc = new Core_Channel_Salesout__c(Core_Account_Name__c = GetAccountId(), Name = 'Test Channel Sales Out') ;
            insert channelSoWithAc ;
            Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
            Test.StartTest() ;
            DataBase.executeBatch(dupBatch) ;
            Test.stopTest() ;
            Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
            System.assertEquals(1, numAc);    
        }
        
        // Test method to test when Account has Training records
        static testMethod void testNoDeleteTrainingRecords() {
            
            Core_Training__c trainingWithAc = new Core_Training__c(Core_Account__c = GetAccountId(), Name = 'Test Training') ;
            insert trainingWithAc ;
            Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
            Test.StartTest() ;
            DataBase.executeBatch(dupBatch) ;
            Test.stopTest() ;
            Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
            System.assertEquals(1, numAc);    
        }
        
        // Test method to test when Account has Redepmtion Points records
        static testMethod void testNoDeleteRedemptionPointsRecords() {
            
            Core_Redemption_Points__c rpWithAc = new Core_Redemption_Points__c(Core_Account__c = GetAccountId(), Name = 'Test Redemption Points') ;
            insert rpWithAc ;
            Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
            Test.StartTest() ;
            DataBase.executeBatch(dupBatch) ;
            Test.stopTest() ;
            Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
            System.assertEquals(1, numAc);    
        }
        
        // Test method to test when Account has Object2TerritoryAssociation Records
        /* static testMethod void testNoDeleteObjectTer2AssociationRecords() {

ObjectTerritory2Association obt2WithAc = new ObjectTerritory2Association (ObjectId = GetAccountId(), AssociationCause = 'Territory2Manual', Territory2Id = '0MIo0000000CaarGAC' ) ;
insert obt2WithAc ;
Core_Batch_Delete_Dup_Accounts dupBatch = new Core_Batch_Delete_Dup_Accounts() ;
Test.StartTest() ;
DataBase.executeBatch(dupBatch) ;
Test.stopTest() ;
Integer numAc = [select count() from Account where Name = 'Dup Test1' ];
System.assertEquals(1, numAc);    
} */
        
        // Test method to test scheduling
        static testMethod void testScheduling() {
            
            Test.startTest();
            // Schedule the test job
            String jobId = System.schedule('Schedule_Batch_Delete_Dup_Accounts_Test', '0 0 0 12 4 ? 2025', new Core_Schedule_Batch_Delete_Dup_Accounts());
            Test.stopTest();
        } 
        
        
    }