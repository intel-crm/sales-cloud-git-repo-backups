@isTest
public class BatchClassforDRP_Test {
    public static Id DRPId;

    @testSetup
    static void setupTestData() {
        // Create test data...
        
        // Insert DRP field mapping
        DRP_field_mapping_stored__c testDrpMapping = new DRP_field_mapping_stored__c(
            Name='DRP_field_mapping_to_main_object_info',
            DRP_Design_Registration_ID_mapped_with__c = 'Design_Registration_dummy__c',
            DRP_Mapped_to_Rec_Id__c = 'Record_Id_from_main_object__c',
            DRP_MMID_mapped_with__c = 'MMID__c',
            DRP_Name_mapped_with__c = 'Name',
            DRP_Old_MMID_mapped_with__c = '',
            DRP_Ordering_Code_mapped_with__c = '',
            DRP_Quantity_mapped_with__c = 'Quantity__c',
            DRP_Target_Resale_Price_mapped_with__c = 'Target_Resale_Price__c',
            Object_to_be_mapped__c = 'Design_Registration_Product_M2M_Stage__c'
        );
        insert testDrpMapping;

        Design_Registration_Stage__c testDR = new Design_Registration_Stage__c(
        Are_Intel_items_used_for_MINDS__c='Yes',
        City__c='test',
        Country__c='test',
        Decision_Date__c=Date.newInstance(2025, 1, 1),
        Description__c='test',
        	Name='test class',
            End_Customer_Name__c='Test Electronics Account',
            External_Id__c='1111',
            First_Customer_Ship_Date__c=Date.newInstance(2025, 2, 2),
            Opportunity_Volume__c=2.0,
            Partner_FAE__c='apjnonodr1@mailinator.com',
            Partner_FAE_Email__c='apjnonodr1@mailinator.com',
            Product_Application__c='Business Desktop',
            Product_Segment__c='Client Computing',
            Production_End_Date__c=Date.newInstance(2025, 3, 3),
            Record_Id_from_main_object__c='1234',//add dr id
            	State_Province__c='test',
            Street1__c='test',
            Vertical_Market__c='Automotive',
            Zip_Postal_Code__c='123'
                       
        );
        insert testDR;
        Design_Registration_Stage__c[] existingRecords1 = [SELECT Id,Name FROM Design_Registration_Stage__c where Name='test class' LIMIT 1];
        // Modify fields as needed
        for (Design_Registration_Stage__c record : existingRecords1) {
            record.Record_Id_from_main_object__c=record.Id;
        }
        update existingRecords1;
        
        Design_Registration_Product_M2M_Stage__c testDRP = new Design_Registration_Product_M2M_Stage__c(
            Design_Registration_dummy__c=testDR.Id,
            MMID__c='99CFFC',
            Name='test drp',

            Quantity__c=2.0,
            Record_Id_from_main_object__c='1111',
            
            Target_Resale_Price__c=3
        );
        insert testDRP;
                 Design_Registration_Product_M2M_Stage__c testDRP1 = new Design_Registration_Product_M2M_Stage__c(
            Design_Registration_dummy__c=testDR.Id,
            MMID__c='99CFFC',
            Name='test drp1',

            Quantity__c=2.0,
            Record_Id_from_main_object__c=(String)testDRP.Id,
            
            Target_Resale_Price__c=3
        );
        insert testDRP1;
    }

    @isTest
    static void testBatchClassforDRP() {
        Test.setMock(HttpCalloutMock.class, new BatchDRPUtilityHttpMock());

        // Start the batch job for creation
        Test.startTest();
        system.debug('batch started ');
        BatchClassforDRP batchJobdrp = new BatchClassforDRP();
        Database.executeBatch(batchJobdrp);
        system.debug('batch ended ');

        updateDRPRecords();
        Test.stopTest();

        // Test updating Design_Registration_Stage__c records
       
    }

    static void updateDRPRecords() {
        Design_Registration_Product_M2M_Stage__c[] existingRecords = [SELECT Id,Name FROM Design_Registration_Product_M2M_Stage__c where Name='test drp1' LIMIT 1];
        // Modify fields as needed
        for (Design_Registration_Product_M2M_Stage__c record : existingRecords) {
            record.Name='test batch class for DRP updated';
        }
        update existingRecords;

        // Set up mock response for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new BatchDRPUtilityHttpMock());

        // Start the batch job for update
        
        BatchClassforDRP batchJobdrp = new BatchClassforDRP();
        Database.executeBatch(batchJobdrp);
        
    }

    private class BatchDRPUtilityHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"RecordId": "1234"}');
            return res;
        }
    }
}