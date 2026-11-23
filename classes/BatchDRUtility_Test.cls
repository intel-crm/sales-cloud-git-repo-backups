@isTest
public class BatchDRUtility_Test {
   
    @isTest
    static void testBatchDRUtility() {
       
         DR_field_mapping_stored__c testDrMapping = new DR_field_mapping_stored__c();
        testDrMapping.Name='DR_field_mapping_to_main_object_info';
testDrMapping.DR_Are_Intel_items_used_mapped_with__c = 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c';
testDrMapping.DR_End_Customer_Name_mapped_with__c = 'Core_End_Customer_Nm__c';
testDrMapping.DR_External_Id_mapped_with__c = 'Core_Internal_Comment_Txt__c';
testDrMapping.DR_First_Customer_Ship_Date_mapped_with__c = 'Core_First_Customer_Ship_Dt__c';
testDrMapping.DR_Mapped_to_Rec_Id__c = 'Id';
testDrMapping.DR_Name_mapped_with__c = 'Core_Design_Registration_Nm__c';
testDrMapping.DR_Opportunity_Volume_mapped_with__c = 'Core_Opportunity_Volume_Cnt__c';
testDrMapping.DR_Partner_FAE_Email_mapped_with__c = 'DDR_Partner_FAE_Email__c';
testDrMapping.DR_Partner_FAE_mapped_with__c = 'Core_Partner_FAE_Nm__c';
testDrMapping.DR_Product_Application_mapped_with__c = 'Core_Product_Application_Nm__c';
testDrMapping.DR_Product_Segment_mapped_with__c = 'Core_Product_Segment_Nm__c';
testDrMapping.DR_Production_End_Date_mapped_with__c = 'Core_Production_End_Dt__c';
testDrMapping.DR_State_Province_mapped_with__c = 'Core_End_Customer_Country_Subdivision_Nm__c';
testDrMapping.DR_Street1_mapped_with__c = 'Core_End_Customer_Street_Addr_Line1_Txt__c';
testDrMapping.DR_Vertical_Market_mapped_with__c = 'Core_Vertical_Market_Nm__c';
testDrMapping.Object_to_be_mapped__c = 'Core_Design_Registration__c';
testDrMapping.DR_Zip_Postal_Code_mapped_with__c = 'Core_End_Customer_Postal_Cd__c';
insert testDrMapping;

        DRP_field_mapping_stored__c testDrpMapping=new DRP_field_mapping_stored__c();
        testDrpMapping.Name='DRP_field_mapping_to_main_object_info';
testDrpMapping.DRP_Design_Registration_ID_mapped_with__c = 'Core_Design_Registration_Id__c';
testDrpMapping.DRP_Mapped_to_Rec_Id__c = 'Id';
testDrpMapping.DRP_MMID_mapped_with__c = 'Core_Comment_Txt__c';
testDrpMapping.DRP_Name_mapped_with__c = 'Name';
testDrpMapping.DRP_Old_MMID_mapped_with__c = '';  // Please provide the actual value
testDrpMapping.DRP_Ordering_Code_mapped_with__c = '';  // Please provide the actual value
testDrpMapping.DRP_Quantity_mapped_with__c = 'Core_Full_Year_Qty__c';
testDrpMapping.DRP_Target_Resale_Price_mapped_with__c = 'Core_Target_Resale_Amt__c';
testDrpMapping.Object_to_be_mapped__c = 'Core_Design_Registration_Product__c';
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
            Record_Id_from_main_object__c='',//add dr id
            	State_Province__c='test',
            Street1__c='test',
            Vertical_Market__c='Automotive',
            Zip_Postal_Code__c='123'
                       
        );
        insert testDR;

// Get the Id of the inserted Design_Registration_Stage__c record
String drId = testDR.Id;
        Design_Registration_Product_M2M_Stage__c testDRP = new Design_Registration_Product_M2M_Stage__c(
        Design_Registration_dummy__c=drId,//add dr stage rec id
         Name='test',
          MMID__c='99CFFC',
            Quantity__c=2.0,
            Record_Id_from_main_object__c='',//add drp id
            Target_Resale_Price__c=3
        );
        insert testDRP;
		//Initialize BatchDRUtility and test initialization
       Test.setMock(HttpCalloutMock.class, new BatchDRUtilityHttpMockPost());

        Test.startTest();

        // Initialize BatchDRUtility and test initialization
        BatchDRUtility batchDRUtility1 = new BatchDRUtility();
        batchDRUtility1.initialize();
        String objectName = batchDRUtility1.getObjectName();

        // Test DRP initialization
        batchDRUtility1.initializeDRP();
        String drpObjectName = batchDRUtility1.getDRPObjectName();

        // Test create methods
        batchDRUtility.calloutCreateDR(testDR);
        batchDRUtility.calloutCreateDRP(testDRP);

        // Set up mock response for HTTP PUT callout
        Test.setMock(HttpCalloutMock.class, new BatchDRUtilityHttpMockPut());

        // Test update methods
        batchDRUtility.calloutUpdateDR(testDR);
        batchDRUtility.calloutUpdateDRP(testDRP);

        // End the callout transaction
        Test.stopTest();
    }
    public class BatchDRUtilityHttpMockPost implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"RecordId": "1234"}');
            return res;
        }
    }

    // Inner class for HTTP PUT mock implementation
    public class BatchDRUtilityHttpMockPut implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"RecordId": "1234"}');
            return res;
        }
    }
    
}