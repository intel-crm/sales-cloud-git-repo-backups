@isTest
public class ObjectFieldMappingController_Test {

    @isTest
    static void testGetAllObjects() {
        List<String> objectList = ObjectFieldMappingController.getAllObjects();

        System.assert(!objectList.isEmpty(), 'Object list should not be empty');

    }

    @isTest
    static void testGetObjectFields() {
        List<String> fields = ObjectFieldMappingController.getObjectFields('Account');

        System.assert(!fields.isEmpty(), 'Fields list should not be empty');

    }
    @isTest
    static void testGetDRFields() {
        List<String> fields = ObjectFieldMappingController.getDRFields();

        System.assert(!fields.isEmpty(), 'Fields list should not be empty');

    }
    @isTest
    static void testGetDRPFields() {
        List<String> fields = ObjectFieldMappingController.getDRPFields();

        System.assert(!fields.isEmpty(), 'Fields list should not be empty');

    }
    @isTest
    static void testSaveMapping() {
        // Create test data for comboDataArray
        List<Map<String, String>> comboDataArray = new List<Map<String, String>>();
        
        // Example 1: Valid combo data
        Map<String, String> comboData1 = new Map<String, String>{
            'label' => 'Design Registration Stage Name',
            'selectedValue' => 'Core_Design_Registration_Nm__c'
        };
        comboDataArray.add(comboData1);

        // Example 2: Another valid combo data
        Map<String, String> comboData2 = new Map<String, String>{
            'label' => 'City',
            'selectedValue' => 'Core_End_Customer_City_Nm__c'
        };
        comboDataArray.add(comboData2);

        // Example 3: Invalid combo data (missing selectedValue)
        Map<String, String> comboData3 = new Map<String, String>{
            'label' => 'Are Intel items used for MINDS?',
            'selectedValue' => 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c'
                // 'selectedValue' is intentionally missing
        };
        comboDataArray.add(comboData3);

        // Example 4: Invalid combo data (missing label)
        Map<String, String> comboData4 = new Map<String, String>{
            // 'label' is intentionally missing
            'label' => 'Country',
            'selectedValue' => 'Core_End_Customer_Country_Nm__c'
        };
        comboDataArray.add(comboData4);
Map<String, String> comboData5 = new Map<String, String>{
            'label' => 'Decision Date',
            'selectedValue' => 'Core_Opportunity_Decision_Dt__c'
        };
        comboDataArray.add(comboData5);

        Map<String, String> comboData6 = new Map<String, String>{
            'label' => 'Description',
            'selectedValue' => 'Core_Design_Registration_Dsc__c'
        };
        comboDataArray.add(comboData6);

        Map<String, String> comboData7 = new Map<String, String>{
            'label' => 'End Customer Name',
            'selectedValue' => 'Core_End_Customer_Nm__c'
        };
        comboDataArray.add(comboData7);

        Map<String, String> comboData8 = new Map<String, String>{
            'label' => 'External Id',
            'selectedValue' => 'Core_Internal_Comment_Txt__c'
        };
        comboDataArray.add(comboData8);

        Map<String, String> comboData9 = new Map<String, String>{
            'label' => 'First Customer Ship Date',
            'selectedValue' => 'Core_First_Customer_Ship_Dt__c'
        };
        comboDataArray.add(comboData9);

        Map<String, String> comboData10 = new Map<String, String>{
            'label' => 'Record Id from main object',
            'selectedValue' => 'Id'
        };
        comboDataArray.add(comboData10);

        Map<String, String> comboData11 = new Map<String, String>{
            'label' => 'Opportunity Volume',
            'selectedValue' => 'Core_Opportunity_Volume_Cnt__c'
        };
        comboDataArray.add(comboData11);

        Map<String, String> comboData12 = new Map<String, String>{
            'label' => 'Partner FAE',
            'selectedValue' => 'Core_Partner_FAE_Nm__c'
        };
        comboDataArray.add(comboData12);
        Map<String, String> comboData13 = new Map<String, String>{
            'label' => 'Partner FAE Email',
            'selectedValue' => 'DDR_Partner_FAE_Email__c'
        };
        comboDataArray.add(comboData13);

        Map<String, String> comboData14 = new Map<String, String>{
            'label' => 'Product Application',
            'selectedValue' => 'Core_Product_Application_Nm__c'
        };
        comboDataArray.add(comboData14);

        Map<String, String> comboData15 = new Map<String, String>{
            'label' => 'Product Segment',
            'selectedValue' => 'Core_Product_Segment_Nm__c'
        };
        comboDataArray.add(comboData15);

        Map<String, String> comboData16 = new Map<String, String>{
            'label' => 'Production End Date',
            'selectedValue' => 'Core_Production_End_Dt__c'
        };
        comboDataArray.add(comboData16);

        Map<String, String> comboData17 = new Map<String, String>{
            'label' => 'State/Province',
            'selectedValue' => 'Core_End_Customer_Country_Subdivision_Nm__c'
        };
        comboDataArray.add(comboData17);

        Map<String, String> comboData18 = new Map<String, String>{
            'label' => 'Street1',
            'selectedValue' => 'Core_End_Customer_Street_Addr_Line1_Txt__c'
        };
        comboDataArray.add(comboData18);

        Map<String, String> comboData19 = new Map<String, String>{
            'label' => 'Vertical Market',
            'selectedValue' => 'Core_Vertical_Market_Nm__c'
        };
        comboDataArray.add(comboData19);
        Test.startTest();
        ObjectFieldMappingController.saveMapping(comboDataArray, 'Core_Design_Registration__c');
        // Create a test record for existingMetadataList
DR_field_mapping_stored__c testDrMapping = new DR_field_mapping_stored__c();
        testDrMapping.Name='DR_field_mapping_to_main_object_info';
testDrMapping.DR_Are_Intel_items_used_mapped_with__c = 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c';
testDrMapping.DR_End_Customer_Name_mapped_with__c = 'Core_End_Customer_Nm__c';
testDrMapping.DR_External_Id_mapped_with__c = 'Core_Internal_Comment_Txt__c';
testDrMapping.DR_First_Customer_Ship_Date_mapped_with__c = 'Core_First_Customer_Ship_Dt__c';
        testDrMapping.DR_Decision_Date_mapped_with__c='Core_Opportunity_Decision_Dt__c';
        testDrMapping.DR_City_mapped_with__c='Core_End_Customer_City_Nm__c';
        testDrMapping.DR_Country_mapped_with__c='Core_End_Customer_Country_Nm__c';
        testDrMapping.DR_Description_mapped_with__c='Core_Design_Registration_Dsc__c';
        
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

        // Call the method with the test data

        ObjectFieldMappingController.saveMapping(comboDataArray, 'Core_Design_Registration__c');
        Test.stopTest();

        // Retrieve the updated record and assert the changes
        
    }
     @isTest
    static void testSaveDRPMapping() {
        // Create test data for comboDataArray
        List<Map<String, String>> comboDataArray1 = new List<Map<String, String>>();

        // Example 1: Valid combo data for each label
        Map<String, String> comboData1 = new Map<String, String>{
            'label' => 'Design Registration M2M Stage',
            'selectedValue' => 'Core_Design_Registration_Id__c'
        };
        comboDataArray1.add(comboData1);

        Map<String, String> comboData2 = new Map<String, String>{
            'label' => 'Design Registration Product M2M Stage Name',
            'selectedValue' => 'Name'
        };
        comboDataArray1.add(comboData2);

        Map<String, String> comboData3 = new Map<String, String>{
            'label' => 'MMID',
            'selectedValue' => 'Core_Comment_Txt__c'
        };
        comboDataArray1.add(comboData3);

        // Add six more comboData entries
        Map<String, String> comboData4 = new Map<String, String>{
            'label' => 'Ordering Code',
            'selectedValue' => ''
        };
        comboDataArray1.add(comboData4);

        Map<String, String> comboData5 = new Map<String, String>{
            'label' => 'Quantity',
            'selectedValue' => 'Core_Full_Year_Qty__c'
        };
        comboDataArray1.add(comboData5);

        Map<String, String> comboData6 = new Map<String, String>{
            'label' => 'Record Id from main object',
            'selectedValue' => 'Id'
        };
        comboDataArray1.add(comboData6);

        Map<String, String> comboData7 = new Map<String, String>{
            'label' => 'Target Resale Price',
            'selectedValue' => 'Core_Target_Resale_Amt__c'
        };
        comboDataArray1.add(comboData7);

        Map<String, String> comboData8 = new Map<String, String>{
            'label' => 'Old MMID',
            'selectedValue' => ''
        };
        comboDataArray1.add(comboData8);

        // Create a test record for existingMetadataList
        DRP_field_mapping_stored__c testRecord = new DRP_field_mapping_stored__c(
            Name = 'DRP_field_mapping_to_main_object_info'
            // Add other required fields here
        );
        insert testRecord;

        // Call the method with the test data
        Test.startTest();
        ObjectFieldMappingController.saveDRPMapping(comboDataArray1, 'Core_Design_Registration_Product__c');
        
        DRP_field_mapping_stored__c testDrpMapping = new DRP_field_mapping_stored__c(
            Name='DRP_field_mapping_to_main_object_info',
            DRP_Design_Registration_ID_mapped_with__c = 'Core_Design_Registration_Id__c',
            DRP_Mapped_to_Rec_Id__c = 'Id',
            DRP_MMID_mapped_with__c = 'Core_Comment_Txt__c',
            DRP_Name_mapped_with__c = 'Name',
            DRP_Old_MMID_mapped_with__c = '',
            DRP_Ordering_Code_mapped_with__c = '',
            DRP_Quantity_mapped_with__c = 'Core_Full_Year_Qty__c',
            DRP_Target_Resale_Price_mapped_with__c = 'Core_Target_Resale_Amt__c',
            Object_to_be_mapped__c = 'Core_Design_Registration_Product__c'
        );
        insert testDrpMapping;
        ObjectFieldMappingController.saveDRPMapping(comboDataArray1, 'Core_Design_Registration_Product__c');
        Test.stopTest();
    }

}