@isTest
public class ScheduleBatchforDRandDRP_Test {
@TestSetup
    static void setupTestData() {
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
        
        Design_Registration_Product_M2M_Stage__c testDRP = new Design_Registration_Product_M2M_Stage__c(
            Design_Registration_dummy__c=testDR.Id,
            MMID__c='99CFFC',
            Name='test drp',

            Quantity__c=2.0,
            Record_Id_from_main_object__c='1111',
            
            Target_Resale_Price__c=3
        );
        insert testDRP;
        
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
    }
    @isTest
    static void testExecute() {
        Test.startTest();
        // Create a mock SchedulableContext
        SchedulableContext mockContext = new SchedulableContextMock();

        // Call the execute method
        ScheduleBatchforDRandDRP scheduler = new ScheduleBatchforDRandDRP();
        scheduler.execute(mockContext);
        Test.stopTest();

        // Optionally, perform assertions based on the expected behavior of the execute method
    }

    @isTest
    static void testFindAndAbortJob() {
        Test.startTest();
        // Create a mock SchedulableContext
        SchedulableContext mockContext = new SchedulableContextMock();

        // Call the findAndAbortJob method
        ScheduleBatchforDRandDRP scheduler = new ScheduleBatchforDRandDRP();
        scheduler.findAndAbortJob(mockContext);
        Test.stopTest();

        // Optionally, perform assertions based on the expected behavior of the findAndAbortJob method
    }

    @isTest
    static void testRescheduleJob() {
        Test.startTest();
        // Call the rescheduleJob method
        ScheduleBatchforDRandDRP scheduler = new ScheduleBatchforDRandDRP();
        scheduler.rescheduleJob();
        Test.stopTest();

        // Optionally, perform assertions based on the expected behavior of the rescheduleJob method
    }

    // Mock class to simulate SchedulableContext
    private class SchedulableContextMock implements SchedulableContext {
        // Implement necessary methods based on the context you want to simulate
public Id getTriggerId() {
            // Return a dummy Id for testing purposes
            return '0123456789abcdef';
        }
        
    }
}