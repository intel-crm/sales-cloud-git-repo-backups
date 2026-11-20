/****************************************************************************************************************************************
* Class Name  : PMP_CreateJunctionData_Test 
* Version     : 1.0 
* Created Date: 11-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     11/13/2018                    Test class for Core_PMP_CreateJunctionData.
*****************************************************************************************************************************************/
@isTest
public class PMP_CreateJunctionData_Test{
public static testMethod void createJunctionDataTestMet(){
        
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
        
        //Create Test Specification :
        PMP_Specification__c specTest = new PMP_Specification__c();
        specTest.Name = 'Test';
        specTest.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        specTest.PMP_Specification_Type_Nm__c = 'Other';
        specTest.PMP_Active_Ind__c = true;
        specTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specTest.PMP_Partner_Product_Specification_Key__c = 'npp_test';
        specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specTest.PMP_Specification_Chinese_Nm__c = 'Test';
        specTest.PMP_Specification_Japanese_Nm__c = 'Test';
        //specTest.PMP_Parent_Specification_Id__c = spec_Main.id;
        //specTest.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert specTest;
        
        PMP_Specification__c specIntelTech = new PMP_Specification__c();
        specIntelTech.Name = 'Intel® Technologies';
        specIntelTech.PMP_Partner_Product_Specification_Id__c= 'NPP_IntelTechnologies';
        specIntelTech.PMP_Specification_Type_Nm__c = 'Other';
        specIntelTech.PMP_Active_Ind__c = true;
        specIntelTech.PMP_Display_Type_Nm__c = 'Label';
        specIntelTech.PMP_Partner_Product_Specification_Key__c = 'npp_inteltechnologies';
        specIntelTech.PMP_Partner_Product_Display_Sequence_Nbr__c = 800;
        specIntelTech.PMP_Specification_Chinese_Nm__c = '英特尔® 技术';
        specIntelTech.PMP_Specification_Japanese_Nm__c = 'インテル® テクノロジー';
        
        insert specIntelTech;
        
        
        PMP_Specification__c specAvail = new PMP_Specification__c();
        specAvail.Name = 'Availability and Pricing';
        specAvail.PMP_Partner_Product_Specification_Id__c= 'AvailabilityandPricingLevel1';
        specAvail.PMP_Specification_Type_Nm__c = 'Other';
        specAvail.PMP_Active_Ind__c = true;
        specAvail.PMP_Display_Type_Nm__c = 'Label';
        specAvail.PMP_Partner_Product_Specification_Key__c = 'availabilityandpricinglevel1';
        //specTest.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        specAvail.PMP_Specification_Chinese_Nm__c = '上市时间与定价';
        specAvail.PMP_Specification_Japanese_Nm__c = '可用性と価格';
        
        insert specAvail;
        
        PMP_Specification__c specMinOrd = new PMP_Specification__c();
        specMinOrd.Name = 'Minimum Order Quantity (Unit)';
        specMinOrd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MinOrderQtUnit';
        specMinOrd.PMP_Specification_Type_Nm__c = 'Other';
        specMinOrd.PMP_Active_Ind__c = true;
        specMinOrd.PMP_Display_Type_Nm__c = 'Integer';
        specMinOrd.PMP_Partner_Product_Specification_Key__c = 'npp_availabilityandpricing_minorderqtunit';
        specMinOrd.PMP_Partner_Product_Display_Sequence_Nbr__c = 100;
        specMinOrd.PMP_Specification_Chinese_Nm__c = '最低订购数量（单位）';
        specMinOrd.PMP_Specification_Japanese_Nm__c = '最小注文数量 (ユニット)';
        specMinOrd.PMP_Parent_Specification_Id__c = specAvail.id;
        specMinOrd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        insert specMinOrd;
        
        
        PMP_Specification__c specMassProd = new PMP_Specification__c();
        specMassProd.Name = 'Mass Production Schedule';
        specMassProd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MassProductionSchedule';
        specMassProd.PMP_Specification_Type_Nm__c = 'Other';
        specMassProd.PMP_Active_Ind__c = true;
        specMassProd.PMP_Display_Type_Nm__c = 'Date';
        specMassProd.PMP_Partner_Product_Specification_Key__c = 'npp_availabilityandpricing_massproductionschedule';
        specMassProd.PMP_Partner_Product_Display_Sequence_Nbr__c = 300;
        specMassProd.PMP_Specification_Chinese_Nm__c = '批量生产计划';
        specMassProd.PMP_Specification_Japanese_Nm__c = '大量生産スケジュール';
        specMassProd.PMP_Parent_Specification_Id__c = specAvail.id;
        specMassProd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        specMassProd.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        insert specMassProd;
        
        PMP_Specification__c specMainProc = new PMP_Specification__c();
        specMainProc.Name = 'Processors';
        specMainProc.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        specMainProc.PMP_Specification_Type_Nm__c = 'Other';
        specMainProc.PMP_Active_Ind__c = true;
        specMainProc.PMP_Display_Type_Nm__c = 'Label';
        specMainProc.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        specMainProc.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        specMainProc.PMP_Specification_Chinese_Nm__c = '处理器';
        specMainProc.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        specMainProc.PMP_Partner_Product_Specification_Key__c = 'npp_processors';
        insert specMainProc;
        
        PMP_Specification__c specCore = new PMP_Specification__c();
        specCore.Name = 'Processor Socketed';
        specCore.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors_ProcessorSocketed';
        specCore.PMP_Specification_Type_Nm__c = 'Other';
        specCore.PMP_Active_Ind__c = true;
        specCore.PMP_Display_Type_Nm__c = 'Checkbox';
        specCore.PMP_Partner_Product_Specification_Key__c = 'npp_processors_processorsocketed';
        specCore.PMP_Partner_Product_Display_Sequence_Nbr__c = 516;
        specCore.PMP_Specification_Chinese_Nm__c = '处理器已插入插槽';
        specCore.PMP_Specification_Japanese_Nm__c = 'ソケット搭載プロセッサー';
        specCore.PMP_Parent_Specification_Id__c = specMainProc.id;
        specCore.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert specCore;
        
        
        PMP_Specification__c specUSB1 = new PMP_Specification__c();
        specUSB1.Name = 'USB1 Quantity';
        specUSB1.PMP_Partner_Product_Specification_Id__c= 'NPP_DevicesAndInterfaces_USB_USB1Quantity';
        specUSB1.PMP_Specification_Type_Nm__c = 'Other';
        specUSB1.PMP_Active_Ind__c = true;
        specUSB1.PMP_Display_Type_Nm__c = 'Integer';
        specUSB1.PMP_Partner_Product_Specification_Key__c = 'npp_devicesandinterfaces_usb_usb1quantity';
        specUSB1.PMP_Partner_Product_Display_Sequence_Nbr__c = 3100;
        specUSB1.PMP_Specification_Chinese_Nm__c = 'USB1 数量';
        specUSB1.PMP_Specification_Japanese_Nm__c = 'USB1 数量';
        specUSB1.PMP_Parent_Specification_Id__c = specCore.id;
        specUSB1.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors_ProcessorSocketed';
        
        insert specUSB1;
        
        //Create Test Specification Value :
        
        PMP_Specification_Value__c specValueProcTest = new PMP_Specification_Value__c();
        specValueProcTest.Name = 'Test';
        specValueProcTest.PMP_Active_Ind__c = true;
        specValueProcTest.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueProcTest.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueProcTest.PMP_Product_Specification_Value_Cd__c = 'Test';
        specValueProcTest.PMP_Product_Specification_Value_Key__c = 'test';
        specValueProcTest.PMP_Spec_Value_Type_Nm__c = 'Other';
        specValueProcTest.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        specValueProcTest.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        specValueProcTest.PMP_Specification_Value_Nm__c = 'Test';
        
        insert specValueProcTest;
        
        //Intel RealSense Technology Spec Value
        
        PMP_Specification_Value__c specValueReals = new PMP_Specification_Value__c();
        specValueReals.Name = 'Intel® RealSense™ Technology';
        specValueReals.PMP_Active_Ind__c = true;
        specValueReals.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueReals.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueReals.PMP_Product_Specification_Value_Cd__c = 'Intel® RealSense™ Technology';
        specValueReals.PMP_Product_Specification_Value_Key__c = 'NPP_IntelTechnologies_intelrealsensetechnology';
        specValueReals.PMP_Spec_Value_Type_Nm__c = 'Other';
        specValueReals.PMP_Specification_Value_Chinese_Cd__c = '实感';
        specValueReals.PMP_Specification_Value_Japanese_Cd__c = 'インテル® RealSense™';
        specValueReals.PMP_Specification_Value_Nm__c = 'Intel® RealSense™ Technology';
        
        insert specValueReals;
        
        //Create a spec value record with indentifier and value as 'Yes'
        
        PMP_Specification_Value__c specValueYes = new PMP_Specification_Value__c();
        specValueYes.Name = 'Processor Socketed';
        specValueYes.PMP_Active_Ind__c = false;
        specValueYes.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueYes.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueYes.PMP_Product_Specification_Value_Cd__c = 'Processor Socketed';
        specValueYes.PMP_Product_Specification_Value_Key__c = 'npp_processors_processorsocketed';
        specValueYes.PMP_Spec_Value_Type_Nm__c = 'Other';
        specValueYes.PMP_Specification_Value_Chinese_Cd__c = '处理器已插入插槽';
        specValueYes.PMP_Specification_Value_Japanese_Cd__c = 'ソケット搭載プロセッサー';
        specValueYes.PMP_Specification_Value_Nm__c = 'Processor Socketed';
        
        insert specValueYes;
    
    //Create Category Specification Association record
        PMP_Category_Specification_Association__c test_Proc_CSA = new PMP_Category_Specification_Association__c();
        test_Proc_CSA.Name = 'System:NUC';
        test_Proc_CSA.PMP_Active_Ind__c = true;
        test_Proc_CSA.PMP_Category_Id__c = testCategoryCategories.id;
        test_Proc_CSA.PMP_Specification_Id__c = specTest.id;
        test_Proc_CSA.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_nuc';
        
        insert test_Proc_CSA;
    
    //Create Specification Value Association records
    
    PMP_Specification_Value_Association__c svaPrcSoc = new PMP_Specification_Value_Association__c();
    svaPrcSoc.Name = 'Processor Socketed';
    svaPrcSoc.PMP_Active_Ind__c = true;
    svaPrcSoc.PMP_Category_Id__c = testCategorySystem.id;
    svaPrcSoc.PMP_Specification_Id__c = specCore.id;
    svaPrcSoc.PMP_Specification_Value_Id__c = specValueYes.id;
    svaPrcSoc.PMP_Category_Spec_Value_External_Key__c = 'npp_02_type_sys|npp_processors_processorsocketed|npp_processors_processorsocketed';
    insert svaPrcSoc;
    
    PMP_Specification_Value_Association__c svaTest = new PMP_Specification_Value_Association__c();
    svaTest.Name = 'Test';
    svaTest.PMP_Active_Ind__c = true;
    svaTest.PMP_Category_Id__c = testCategorySystem.id;
    svaTest.PMP_Specification_Id__c = specTest.id;
    svaTest.PMP_Specification_Value_Id__c = specValueProcTest.id;
    svaTest.PMP_Category_Spec_Value_External_Key__c = 'npp_02_type_sys|test|test';
    insert svaTest;
     
        PMP_CreateJunctionData.createJunctionObjData();
        System.assertEquals(svaTest.PMP_Specification_Value_Id__c, specValueProcTest.id);
        System.assertEquals(svaTest.PMP_Specification_Id__c, specTest.id);
        Test.stopTest();
    }
}