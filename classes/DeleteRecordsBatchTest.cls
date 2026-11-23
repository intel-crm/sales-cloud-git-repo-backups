@isTest
private class DeleteRecordsBatchTest {
    @testSetup
    static void setup() {
        // Insert test records for Object1__c
        List<Product_Inbound_Staging__c> object1Records = new List<Product_Inbound_Staging__c>();
        for (Integer i = 0; i < 100; i++) {
            Product_Inbound_Staging__c obj1 = new Product_Inbound_Staging__c();
            obj1.CreatedDate = Date.today().addDays(-10);
            object1Records.add(obj1);
        }
        insert object1Records;
        
        // Insert test records for Object2__c
        List<Core_Products_Staging__c> object2Records = new List<Core_Products_Staging__c>();
        for (Integer i = 0; i < 100; i++) {
            Core_Products_Staging__c obj2 = new Core_Products_Staging__c();
            obj2.Core_Unique_ID__c = 'Test Object1 Record ' + i;
            obj2.Unique_Value__c = 'Test Object1 Record ' + i;
            obj2.CreatedDate = Date.today().addDays(-10);
            object2Records.add(obj2);
        }
        insert object2Records;
    }
    
    @isTest
    static void testDeleteRecordsBatch() {
        // Set up the test data
        Integer ageThreshold = Integer.valueOf(Label.DeleteStagingRecordsAgeThreshold);
        // Verify that the records were deleted
        // Execute the batch Apex job
        Test.startTest();
        DeleteRecordsInboundStagingBatch batch = new DeleteRecordsInboundStagingBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the records were deleted
        Integer object1RecordCount = [SELECT COUNT() FROM Product_Inbound_Staging__c WHERE CreatedDate < :Date.today().addDays(-ageThreshold)];
        Integer object2RecordCount = [SELECT COUNT() FROM Core_Products_Staging__c WHERE CreatedDate < :Date.today().addDays(-ageThreshold)];
        System.assertEquals(0, object1RecordCount);
        System.assertEquals(0, object2RecordCount);
    }
}