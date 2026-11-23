@isTest
public class BatchClassforDR_Test {

    @isTest
    static void testBatchClassforDR() {
        DR_field_mapping_stored__c testDrMapping = new DR_field_mapping_stored__c();
        testDrMapping.Name='DR_field_mapping_to_main_object_info';
testDrMapping.DR_Are_Intel_items_used_mapped_with__c = 'Are_Intel_items_used_for_MINDS__c';
testDrMapping.DR_End_Customer_Name_mapped_with__c = 'End_Customer_Name__c';
testDrMapping.DR_External_Id_mapped_with__c = 'External_Id__c';
testDrMapping.DR_First_Customer_Ship_Date_mapped_with__c = 'First_Customer_Ship_Date__c';
        testDrMapping.DR_Decision_Date_mapped_with__c='Decision_Date__c';
        testDrMapping.DR_City_mapped_with__c='City__c';
        testDrMapping.DR_Country_mapped_with__c='Country__c';
        testDrMapping.DR_Description_mapped_with__c='Description__c';        
testDrMapping.DR_Mapped_to_Rec_Id__c = 'Id';
testDrMapping.DR_Name_mapped_with__c = 'Name';
testDrMapping.DR_Opportunity_Volume_mapped_with__c = 'Opportunity_Volume__c';
testDrMapping.DR_Partner_FAE_Email_mapped_with__c = 'Partner_FAE_Email__c';
testDrMapping.DR_Partner_FAE_mapped_with__c = 'Partner_FAE__c';
testDrMapping.DR_Product_Application_mapped_with__c = 'Product_Application__c';
testDrMapping.DR_Product_Segment_mapped_with__c = 'Product_Segment__c';
testDrMapping.DR_Production_End_Date_mapped_with__c = 'Production_End_Date__c';
testDrMapping.DR_State_Province_mapped_with__c = 'State_Province__c';
testDrMapping.DR_Street1_mapped_with__c = 'Street1__c';
testDrMapping.DR_Vertical_Market_mapped_with__c = 'Vertical_Market__c';
testDrMapping.Object_to_be_mapped__c = 'Design_Registration_Stage__c';
testDrMapping.DR_Zip_Postal_Code_mapped_with__c = 'Zip_Postal_Code__c';
insert testDrMapping;

Design_Registration_Stage__c testDR = new Design_Registration_Stage__c(
        Are_Intel_items_used_for_MINDS__c='Yes',
        City__c='test',
        Country__c='test',
        
        Description__c='test',
        	Name='test class',
            End_Customer_Name__c='Test Electronics Account',
            External_Id__c='1111',
            
            Opportunity_Volume__c=2.0,
            Partner_FAE__c='apjnonodr1@mailinator.com',
            Partner_FAE_Email__c='apjnonodr1@mailinator.com',
            Product_Application__c='Business Desktop',
            Product_Segment__c='Client Computing',
            
            Record_Id_from_main_object__c='1234',//add dr id
            	State_Province__c='test',
            Street1__c='test',
            Vertical_Market__c='Automotive',
            Zip_Postal_Code__c='123',
            Decision_Date__c=Date.valueOf('2025-01-01'), 
    First_Customer_Ship_Date__c=Date.valueOf('2025-02-02'),
    Production_End_Date__c=Date.newInstance(2025, 3, 3)
        );
        insert testDR;
        
        
        
        Test.setMock(HttpCalloutMock.class, new BatchDRUtilityHttpMock());

        // Start the batch job for creation
        Test.startTest();
        BatchClassforDR batchJob = new BatchClassforDR();
        Database.executeBatch(batchJob);

        // Test updating Design_Registration_Stage__c records
        updateDesignRegistrationStageRecords();
        Test.stopTest();
    }

        // Set up mock response for HTTP callouts
       

  

    static void updateDesignRegistrationStageRecords() {
        // Update test records
        Design_Registration_Stage__c[] existingRecords = [SELECT Id,Name FROM Design_Registration_Stage__c where Name='test class 1' LIMIT 1];
        // Modify fields as needed
        for (Design_Registration_Stage__c record : existingRecords) {
            record.name='testing';
        }
        update existingRecords;

        // Set up mock response for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new BatchDRUtilityHttpMock());

        // Start the batch job for update
        
        BatchClassforDR batchJob = new BatchClassforDR();
        Database.executeBatch(batchJob);
        

        // Add assertions if needed
    }

    // Mock class for HTTP callouts
    private class BatchDRUtilityHttpMock implements HttpCalloutMock {
      public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"RecordId": "1234"}');
            return res;
        }
    }
}