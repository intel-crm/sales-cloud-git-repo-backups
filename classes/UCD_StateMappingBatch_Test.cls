@isTest
public class UCD_StateMappingBatch_Test {

    @testSetup
    static void setupTestData() {
        // Create test Record Types
        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id inactiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();

        // Create Account records with Core_Reltio_Address_Status__c = 'Pending'
        Account account1 = new Account(
            Name = 'Test Account 1',
            Core_Reltio_Address_Status__c = 'Pending',
            RecordTypeId = intelRecordTypeId,
            BillingCountry='IND',
            BillingCity='Bangalore',
            BillingStreet='Test Data',
            Core_MDM_Location_State_Nm__c = 'IN_KA',
            Core_Unified_Customer_Address__CountryCode__s = 'IND',
            Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST'
        );
        insert account1;

        Account account2 = new Account(
            Name = 'Test Account 2',
            Core_Reltio_Address_Status__c = 'Pending',
            RecordTypeId = inactiveRecordTypeId,
            BillingCountry='IND',
            BillingCity='Mumbai',
            BillingStreet='Test Data1',
            Core_MDM_Secondary_State_Cd__c = 'IN_MH',
            Core_Unified_Customer_Address__CountryCode__s = 'IND',
            Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST'
        );
        insert account2;

        insert new Core_ACM_Control_Execution__c(Name='MapReltioAddressToPrimaryAddress',IsActive__c = true,
        ProcessName__c='UCD_StateMappingBatch');
    }

    @isTest
    static void testBatchExecution() {
        // Initialize the batch class
        UCD_StateMappingBatch batch = new UCD_StateMappingBatch();

        // Execute the batch with test data
        Test.startTest();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Verify that the accounts were updated as expected
        Account updatedAccount1 = [SELECT Id, Core_Unified_Customer_Address__StateCode__s, Core_Reltio_Address_Status__c FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        System.assertEquals('KA', updatedAccount1.Core_Unified_Customer_Address__StateCode__s);
        System.assertEquals('COMPLETED', updatedAccount1.Core_Reltio_Address_Status__c);

        Account updatedAccount2 = [SELECT Id, Core_Unified_Customer_Address__StateCode__s, Core_Reltio_Address_Status__c FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        System.assertEquals('MH', updatedAccount2.Core_Unified_Customer_Address__StateCode__s);
        System.assertEquals('COMPLETED', updatedAccount2.Core_Reltio_Address_Status__c);
    }
}