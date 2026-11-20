/**********************************************************************************************
* Class Name  :   PMP_FPGA_CreateJunctionData_Test
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------
* Sangeetha                 09/01/2019               Test class for Core_PMP_FPGA_CreateJunctionData
*************************************************************************************************/
@isTest
public class PMP_FPGA_CreateJunctionData_Test {
//IPA 2.0- US-TWC729-7980
/*@isTest
    public static void fpgaCreateJunctionDataTestMet(){
        Test.startTest();
        
        //Create a category
        
        PMP_Category__c testCategoryCategories = new PMP_Category__c();
        testCategoryCategories.Name = 'Categories';
        testCategoryCategories.PMP_Active_Ind__c = true;
        testCategoryCategories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryCategories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryCategories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        testCategoryCategories.PMP_Display_Type_Nm__c = 'Label';
        testCategoryCategories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert testCategoryCategories;
        
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = true;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert testCategorySystem;
        
        //Create FPGA Specification record
        PMP_Specification__c fpgaSpecMain = new PMP_Specification__c();
        fpgaSpecMain.Name = 'FPGA';
        fpgaSpecMain.PMP_Partner_Product_Specification_Id__c= 'NPP_FPGA';
        fpgaSpecMain.PMP_Specification_Type_Nm__c = 'Other';
        fpgaSpecMain.PMP_Active_Ind__c = true;
        fpgaSpecMain.PMP_Display_Type_Nm__c = 'Label';
        fpgaSpecMain.PMP_Partner_Product_Specification_Key__c = 'npp_fpga';
        
        insert fpgaSpecMain;
       
        PMP_Specification__c fpgaSpecCycloneV = new PMP_Specification__c();
        fpgaSpecCycloneV.Name = 'Cyclone® V';
        fpgaSpecCycloneV.PMP_Partner_Product_Specification_Id__c= 'Cyclone V';
        fpgaSpecCycloneV.PMP_Specification_Type_Nm__c = 'FPGA';
        fpgaSpecCycloneV.PMP_Active_Ind__c = true;
        fpgaSpecCycloneV.PMP_Display_Type_Nm__c = 'Checkbox';
        fpgaSpecCycloneV.PMP_Partner_Product_Specification_Key__c = 'cyclonev';
        fpgaSpecCycloneV.PMP_Parent_Specification_Id__c = fpgaSpecMain.ID;
        
        insert fpgaSpecCycloneV;
        
        PMP_Specification__c fpgaSpecTest = new PMP_Specification__c();
        fpgaSpecTest.Name = 'Test_Spec';
        fpgaSpecTest.PMP_Partner_Product_Specification_Id__c= '194690';
        fpgaSpecTest.PMP_Specification_Type_Nm__c = 'FPGA';
        fpgaSpecTest.PMP_Active_Ind__c = true;
        fpgaSpecTest.PMP_Display_Type_Nm__c = 'Checkbox';
        fpgaSpecTest.PMP_Partner_Product_Specification_Key__c = '194690';
        fpgaSpecTest.PMP_Parent_Specification_Id__c = fpgaSpecMain.ID;
        
        insert fpgaSpecTest;
        
        PMP_Specification__c fpgaSpec2 = new PMP_Specification__c();
        fpgaSpec2.Name = 'Test_Spec2';
        fpgaSpec2.PMP_Partner_Product_Specification_Id__c= '194275';
        fpgaSpec2.PMP_Specification_Type_Nm__c = 'FPGA';
        fpgaSpec2.PMP_Active_Ind__c = true;
        fpgaSpec2.PMP_Display_Type_Nm__c = 'Checkbox';
        fpgaSpec2.PMP_Partner_Product_Specification_Key__c = '194275';
        fpgaSpec2.PMP_Parent_Specification_Id__c = fpgaSpecTest.ID;
        
        insert fpgaSpec2;
        
        PMP_Specification_Value__c specValueFPGATest = new PMP_Specification_Value__c();
        specValueFPGATest.Name = 'Test';
        specValueFPGATest.PMP_Active_Ind__c = true;
        specValueFPGATest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueFPGATest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueFPGATest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueFPGATest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueFPGATest.PMP_Spec_Value_Type_Nm__c = 'Other';
        specValueFPGATest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueFPGATest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueFPGATest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueFPGATest;
        
        PMP_Specification_Value__c specValueFPGATest2 = new PMP_Specification_Value__c();
        specValueFPGATest2.Name = 'Test2';
        specValueFPGATest2.PMP_Active_Ind__c = true;
        specValueFPGATest2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueFPGATest2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueFPGATest2.PMP_Product_Specification_Value_Cd__c = '194277';
        specValueFPGATest2.PMP_Product_Specification_Value_Key__c = '194277';
        specValueFPGATest2.PMP_Spec_Value_Type_Nm__c = 'FPGA';
        specValueFPGATest2.PMP_Specification_Value_Chinese_Cd__c = 'Test2';
        specValueFPGATest2.PMP_Specification_Value_Japanese_Cd__c = 'Test2';
        specValueFPGATest2.PMP_Specification_Value_Nm__c = 'Test2';
        
        insert specValueFPGATest2;
        
        //Create Category Specification Association record
        PMP_Category_Specification_Association__c testFPGACSA = new PMP_Category_Specification_Association__c();
        testFPGACSA.Name = 'System:FPGA';
        testFPGACSA.PMP_Active_Ind__c = true;
        testFPGACSA.PMP_Category_Id__c = testCategorySystem.id;
        testFPGACSA.PMP_Specification_Id__c = fpgaSpecMain.id;
        testFPGACSA.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_fpga';
        insert testFPGACSA;
        
        //Create Category Specification Association record
        PMP_Category_Specification_Association__c testFPGACSA1 = new PMP_Category_Specification_Association__c();
        testFPGACSA1.Name = 'System:Cyclone® V';
        testFPGACSA1.PMP_Active_Ind__c = true;
        testFPGACSA1.PMP_Category_Id__c = testCategorySystem.id;
        testFPGACSA1.PMP_Specification_Id__c = fpgaSpecCycloneV.id;
        testFPGACSA1.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|cyclonev';
        insert testFPGACSA1;
        
        PMP_Specification_Value_Association__c Obj1 = new PMP_Specification_Value_Association__c();
        Obj1.PMP_Category_Spec_Value_External_Key__c  = 'Technology1';
        Obj1.PMP_Specification_Id__c = fpgaSpecCycloneV.id;
        Obj1.PMP_Specification_Value_Id__c = specValueFPGATest2.id;
        insert Obj1;
        PMP_FPGA_CreateJunctionData.languageCode = 'en_US';
        PMP_FPGA_CreateJunctionData.createAssociationRecords();
        System.assertEquals(testFPGACSA.PMP_Category_Id__c, testCategorySystem.id);
        System.assertEquals(testFPGACSA.PMP_Specification_Id__c, fpgaSpecMain.id);
        Test.stopTest();
    }*/
}