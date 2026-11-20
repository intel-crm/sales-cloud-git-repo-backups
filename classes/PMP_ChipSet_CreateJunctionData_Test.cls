/**********************************************************************************************
* Class Name  :   PMP_ChipSet_CreateJunctionData_Test
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Manasa                  02/01/2019               Test class for PMP_ChipSet_CreateJunctionData.apxc
* Infosys - Sangeetha     09/01/2019               Updated test class
*************************************************************************************************/
@isTest
public class PMP_ChipSet_CreateJunctionData_Test {
//IPA 2.0- US-TWC729-7980
   /* @isTest
    public static void chipSetCreateJunctionDataTestMet(){
        
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
        
        //Create test Specifications:
        
        PMP_Specification__c specMain = new PMP_Specification__c();
        specMain.Name = 'Chipsets';
        specMain.PMP_Partner_Product_Specification_Id__c= 'NPP_Chipsets';
        specMain.PMP_Specification_Type_Nm__c = 'Other';
        specMain.PMP_Active_Ind__c = true;
        specMain.PMP_Display_Type_Nm__c = 'Label';
        specMain.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        specMain.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specMain.PMP_Specification_Chinese_Nm__c = '芯片组';
        specMain.PMP_Specification_Japanese_Nm__c = 'チップセット';
        specMain.PMP_Partner_Product_Specification_Key__c = 'npp_chipsets';
        insert specMain; 
        
        PMP_Specification__c specTest = new PMP_Specification__c();
        specTest.Name = 'Test';
        specTest.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        specTest.PMP_Specification_Type_Nm__c = 'Chipset';
        specTest.PMP_Active_Ind__c = true;
        specTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specTest.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 530;
        specTest.PMP_Specification_Chinese_Nm__c = '芯片';
        specTest.PMP_Specification_Japanese_Nm__c = 'チップセッ';
        specTest.PMP_Parent_Specification_Id__c = specMain.id;
        specTest.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specTest;     
        
        PMP_Specification__c specConsumer = new PMP_Specification__c();
        specConsumer.Name = 'Consumer Chipsets';
        specConsumer.PMP_Partner_Product_Specification_Id__c= '98455';
        specConsumer.PMP_Specification_Type_Nm__c = 'Chipset';
        specConsumer.PMP_Active_Ind__c = true;
        specConsumer.PMP_Display_Type_Nm__c = 'Checkbox';
        specConsumer.PMP_Partner_Product_Specification_Key__c = '98455';
        specConsumer.PMP_Partner_Product_Display_Sequence_Nbr__c = 160;
        specConsumer.PMP_Specification_Chinese_Nm__c = '消费级芯片组';
        specConsumer.PMP_Specification_Japanese_Nm__c = 'コンシューマー・チップセット';
        specConsumer.PMP_Parent_Specification_Id__c = specMain.id;
        specConsumer.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';    
        insert specConsumer;
        
        PMP_Specification__c specServer = new PMP_Specification__c();
        specServer.Name = 'Server Chipsets';
        specServer.PMP_Partner_Product_Specification_Id__c= '46652';    
        specServer.PMP_Specification_Type_Nm__c = 'Chipset';
        specServer.PMP_Active_Ind__c = true;
        specServer.PMP_Display_Type_Nm__c = 'Checkbox';
        specServer.PMP_Partner_Product_Specification_Key__c = '46652';
        specServer.PMP_Partner_Product_Display_Sequence_Nbr__c = 161;
        specServer.PMP_Specification_Chinese_Nm__c = '服务器芯片组';
        specServer.PMP_Specification_Japanese_Nm__c = 'サーバー向けチップセット';
        specServer.PMP_Parent_Specification_Id__c = specMain.id; 
        specServer.PMP_Product_Parent_Specification_Id__c = 'npp_chipsets';
        insert specServer;
        
        
        PMP_Specification__c spec300Series = new PMP_Specification__c();
        spec300Series.Name = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Partner_Product_Specification_Id__c= '126380';
        spec300Series.PMP_Product_Parent_Specification_Id__c = '98455';    
        spec300Series.PMP_Specification_Type_Nm__c = 'Chipset';
        spec300Series.PMP_Active_Ind__c = true;
        spec300Series.PMP_Display_Type_Nm__c = 'Checkbox';
        spec300Series.PMP_Partner_Product_Specification_Key__c = '126380';
        spec300Series.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        spec300Series.PMP_Specification_Chinese_Nm__c = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Specification_Japanese_Nm__c = 'Intel® 300 Series Chipsets';
        spec300Series.PMP_Parent_Specification_Id__c = specConsumer.id;  
        insert spec300Series;
        
        //Create Specification Values
        
        PMP_Specification_Value__c specValueChip = new PMP_Specification_Value__c();
        specValueChip.Name = 'Intel® Z370 Chipset';
        specValueChip.PMP_Active_Ind__c = true;
        specValueChip.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChip.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChip.PMP_Product_Specification_Value_Cd__c = '125903';
        specValueChip.PMP_Product_Specification_Value_Key__c = '125903';
        specValueChip.PMP_Spec_Value_Type_Nm__c = 'Chipset';
        specValueChip.PMP_Specification_Value_Chinese_Cd__c = 'Intel® Z370 Chipset';
        specValueChip.PMP_Specification_Value_Japanese_Cd__c = 'Intel® Z370 Chipset';
        specValueChip.PMP_Specification_Value_Nm__c = 'Intel® Z370 Chipset';
        insert specValueChip;
        
        PMP_Specification_Value__c specValueChipTest = new PMP_Specification_Value__c();
        specValueChipTest.Name = 'Test';
        specValueChipTest.PMP_Active_Ind__c = true;
        specValueChipTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueChipTest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueChipTest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueChipTest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueChipTest.PMP_Spec_Value_Type_Nm__c = 'Chipset';
        specValueChipTest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueChipTest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueChipTest;
        
        //Create Category Specification Association record
        PMP_Category_Specification_Association__c testChipsetCSA = new PMP_Category_Specification_Association__c();
        testChipsetCSA.Name = 'System:Chipsets';
        testChipsetCSA.PMP_Active_Ind__c = true;
        testChipsetCSA.PMP_Category_Id__c = testCategorySystem.id;
        testChipsetCSA.PMP_Specification_Id__c = specMain.id;
        testChipsetCSA.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_chipsets';
        insert testChipsetCSA;
        
        PMP_Category_Specification_Association__c ChipsetCSA1 = new PMP_Category_Specification_Association__c();
        ChipsetCSA1.Name = 'System:Test';
        ChipsetCSA1.PMP_Active_Ind__c = true;
        ChipsetCSA1.PMP_Category_Id__c = testCategorySystem.id;
        ChipsetCSA1.PMP_Specification_Id__c = specTest.id;
        ChipsetCSA1.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_test';
        insert ChipsetCSA1;
        
        //Create Spec-SpecValue association records
        PMP_Specification_Value_Association__c specValueAssoc = new PMP_Specification_Value_Association__c ();
        specValueAssoc.Name = 'Intel® Z370 Chipset';
        specValueAssoc.PMP_Active_Ind__c = true;
        specValueAssoc.PMP_Category_Id__c = testCategorySystem.id;
        specValueAssoc.PMP_Specification_Id__c = spec300Series.id;
        specValueAssoc.PMP_Specification_Value_Id__c = specValueChip.id;
        specValueAssoc.PMP_Category_Spec_Value_External_Key__c = 'npp_02_type_sys|125903|126380';
        insert specValueAssoc;
        
        PMP_ChipSet_CreateJunctionData.createAssociationRecords();
        
        System.assertEquals(testChipsetCSA.PMP_Specification_Id__c, specMain.id);
        System.assertEquals(testChipsetCSA.PMP_Category_Id__c, testCategorySystem.id);
        Test.stopTest(); 
    }*/
}