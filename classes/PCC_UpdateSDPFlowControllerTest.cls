@isTest
private class PCC_UpdateSDPFlowControllerTest {

    @isTest
    static void testBulkUpdateDRPRecords_SuccessAndFiltering() {
        // 1. Setup Parent Test Data to fulfill the required field constraint
        // Note: Replace 'Core_Design_Registration__c' with the actual API name of the Parent Object if it is different
        SObject parentRecord = Schema.getGlobalDescribe().get('Core_Design_Registration__c').newSObject();
        // If the parent object has its own required fields, populate them here: e.g., parentRecord.put('Name', 'Test Reg');
        insert parentRecord;
        
        List<Core_Design_Registration_Product__c> testRecords = new List<Core_Design_Registration_Product__c>();
        
        // Record 1: Valid record that SHOULD be updated
        Core_Design_Registration_Product__c validRecord = new Core_Design_Registration_Product__c(
            Core_Design_Product_Status_Nm__c = 'Pending',
            PCC_Standard_Distributor_Price__c = null,
            Core_Design_Registration_Id__c = parentRecord.Id // 🔗 Linked to parent
        );
        testRecords.add(validRecord);
        
        // Record 2: Invalid record (Status is not Pending) - SHOULD be ignored by the filter
        Core_Design_Registration_Product__c wrongStatusRecord = new Core_Design_Registration_Product__c(
            Core_Design_Product_Status_Nm__c = 'Approved',
            PCC_Standard_Distributor_Price__c = 0,
            Core_Design_Registration_Id__c = parentRecord.Id // 🔗 Linked to parent
        );
        testRecords.add(wrongStatusRecord);
        
        // Record 3: Invalid record (Price is already set) - SHOULD be ignored by the filter
        Core_Design_Registration_Product__c pricedRecord = new Core_Design_Registration_Product__c(
            Core_Design_Product_Status_Nm__c = 'Pending',
            PCC_Standard_Distributor_Price__c = 150.00,
            Core_Design_Registration_Id__c = parentRecord.Id // 🔗 Linked to parent
        );
        testRecords.add(pricedRecord);
        
        // Insert test records into the database (this will now pass!)
        insert testRecords;
        
        // Add a duplicate item of the valid record to test the duplicate-proofing Map engine
        List<Core_Design_Registration_Product__c> requestList = new List<Core_Design_Registration_Product__c>();
        requestList.add(validRecord);
        requestList.add(wrongStatusRecord);
        requestList.add(pricedRecord);
        requestList.add(validRecord); // Duplicate intentional to cover line-level deduplication code
        
        // 2. Prepare the Invocable Request payload
        PCC_UpdateSDPFlowController.BulkUpdateRequest req = new PCC_UpdateSDPFlowController.BulkUpdateRequest();
        req.drpRecords = requestList;
        req.standardDistiPrice = 250.50;
        
        List<PCC_UpdateSDPFlowController.BulkUpdateRequest> requests = new List<PCC_UpdateSDPFlowController.BulkUpdateRequest>();
        requests.add(req);
        
        // 3. Execute the Invocable Method
        Test.startTest();
        List<PCC_UpdateSDPFlowController.BulkUpdateResponse> responses = PCC_UpdateSDPFlowController.bulkUpdateDRPRecords(requests);
        Test.stopTest();
        
        // 4. Validate Results (Asserts)
        System.assertEquals(1, responses.size(), 'Should return exactly one response wrapper back to Flow');
        PCC_UpdateSDPFlowController.BulkUpdateResponse res = responses[0];
        
        // Verify the valid record was successfully processed and counted
        System.assertEquals(1, res.successCount, 'Exactly 1 record should have been updated successfully');
        System.assertEquals(0, res.errorCount, 'Zero data exceptions should have been logged for valid records');
        System.assert(res.successIds.contains(validRecord.Id), 'Success list must contain the valid record ID');
        
        // Query the database to verify the field change was physically committed
        Core_Design_Registration_Product__c updatedDbRecord = [
            SELECT PCC_Standard_Distributor_Price__c 
            FROM Core_Design_Registration_Product__c 
            WHERE Id = :validRecord.Id
        ];
        System.assertEquals(250.50, updatedDbRecord.PCC_Standard_Distributor_Price__c, 'Price field was not modified in database');
    }

    @isTest
    static void testBulkUpdateDRPRecords_EmptyRequest() {
        PCC_UpdateSDPFlowController.BulkUpdateRequest req = new PCC_UpdateSDPFlowController.BulkUpdateRequest();
        req.drpRecords = new List<Core_Design_Registration_Product__c>();
        req.standardDistiPrice = 100.00;
        
        List<PCC_UpdateSDPFlowController.BulkUpdateRequest> requests = new List<PCC_UpdateSDPFlowController.BulkUpdateRequest>();
        requests.add(req);
        
        Test.startTest();
        List<PCC_UpdateSDPFlowController.BulkUpdateResponse> responses = PCC_UpdateSDPFlowController.bulkUpdateDRPRecords(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size());
        System.assertEquals(0, responses[0].successCount);
        System.assertEquals(0, responses[0].errorCount);
    }
}