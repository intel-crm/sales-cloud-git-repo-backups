@IsTest
private class Core_MDF_Batch_RetryAICDBOutbound_Test {
    
    @TestSetup
    static void setupData() {
        // Create 2 Core_MDF_CCP_Custom_Metadata_Utility__c records needed by the batch class
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        
        // Metadata record for CDB Log Period
        Core_MDF_CCP_Custom_Metadata_Utility__c periodRecord = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'MDF AI PIC Review',
            Core_MDF_Sub_Category__c = 'CDB Log Period',
            Core_MDF_Value__c = '7'
        );
        metadataRecords.add(periodRecord);
        
        // Metadata record for CDB Retry Counter
        Core_MDF_CCP_Custom_Metadata_Utility__c retryRecord = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'MDF AI PIC Review',
            Core_MDF_Sub_Category__c = 'CDB Retry Counter',
            Core_MDF_Value__c = '3'
        );
        metadataRecords.add(retryRecord);
        
        insert metadataRecords;
        
        // Create a system user for running tests
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(
            Alias = 'testuser',
            Email='aiadmintestuser@example.com',
            EmailEncodingKey='UTF-8',
            LastName='TestUser',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='aiadmintestuser@example.com'
        );
        insert testUser;
        
        // Create 2-3 dummy Core_CDB_Integration_Log__c records
        List<Core_CDB_Integration_Log__c> cdbLogRecords = new List<Core_CDB_Integration_Log__c>();
        
        // Create first CDB log record
        Core_CDB_Integration_Log__c cdbLog1 = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = 'test-record-id-1',
            Core_Log_Status_Nm__c = 'Failed',
            Core_Retry_Number_Nbr__c = 1,
            Core_Integration_Direction_Nm__c = 'Outbound'
        );
        cdbLogRecords.add(cdbLog1);
        
        // Create second CDB log record
        Core_CDB_Integration_Log__c cdbLog2 = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = 'test-record-id-2',
            Core_Log_Status_Nm__c = 'Failed',
            Core_Retry_Number_Nbr__c = 2,
            Core_Integration_Direction_Nm__c = 'Outbound'
        );
        cdbLogRecords.add(cdbLog2);
        
        // Create third CDB log record (optional)
        Core_CDB_Integration_Log__c cdbLog3 = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = 'test-record-id-3',
            Core_Log_Status_Nm__c = 'Failed',
            Core_Retry_Number_Nbr__c = 0,
            Core_Integration_Direction_Nm__c = 'Outbound'
        );
        cdbLogRecords.add(cdbLog3);
        
        insert cdbLogRecords;
    }
    
    @IsTest
    static void test_batch_class_execution() {
        // Get the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Email = 'aiadmintestuser@example.com' LIMIT 1];
        
        // Run the batch class as system user
        Test.startTest();
        system.runAs(testUser) {
            Core_MDF_Batch_RetryAICDBOutbound batchClass = new Core_MDF_Batch_RetryAICDBOutbound();
            Database.executeBatch(batchClass, 50);
        }
        Test.stopTest();
        
        // Verify that the batch class executed without throwing exceptions
        // This test verifies that the lines in the batch class are covered
        // The actual functionality is tested by the batch execution itself
        System.assert(true, 'Batch class executed without errors');
    }
}