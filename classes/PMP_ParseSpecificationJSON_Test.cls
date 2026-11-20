/****************************************************************************************************************************************
* Class Name  : PMP_ParseSpecificationJSON_Test 
* Version     : 1.0 
* Created Date: 11-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     11/13/2018                    Test class for Core_PMP_ParseSpecificationJSON.
*****************************************************************************************************************************************/
@isTest
public class PMP_ParseSpecificationJSON_Test {

    public static testMethod void parseEnglishSpecificationJSONTest(){
        //Variable Declaration
        List<PMP_Category__c> CatList = new List<PMP_Category__c>();
        
        Test.startTest();
        //Create a category
        
        PMP_Category__c test_category_Categories = new PMP_Category__c();
        test_category_Categories.Name = 'Categories';
        test_category_Categories.PMP_Active_Ind__c = true;
        test_category_Categories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_Categories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        test_category_Categories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        test_category_Categories.PMP_Display_Type_Nm__c = 'Label';
        test_category_Categories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert test_category_Categories;
        
        PMP_Category__c test_category_System = new PMP_Category__c();
        test_category_System.Name = 'System';
        test_category_System.PMP_Active_Ind__c = true;
        test_category_System.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_System.PMP_Parent_Category_Id__c = test_category_Categories.id;
        test_category_System.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        test_category_System.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        test_category_System.PMP_Display_Type_Nm__c = 'Radiobutton';
        test_category_System.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert test_category_System;
        
        //Create Test Specification :
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'NPP_Test_npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = 'Test';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'Test';
        //spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        //spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;
        
        PMP_Specification__c spec_IntelTech = new PMP_Specification__c();
        spec_IntelTech.Name = 'Intel® Technologies';
        spec_IntelTech.PMP_Partner_Product_Specification_Id__c= 'NPP_IntelTechnologies';
        spec_IntelTech.PMP_Specification_Type_Nm__c = 'Other';
        spec_IntelTech.PMP_Active_Ind__c = true;
        spec_IntelTech.PMP_Display_Type_Nm__c = 'Label';
        spec_IntelTech.PMP_Partner_Product_Specification_Key__c = 'NPP_IntelTechnologies_npp_inteltechnologies';
        spec_IntelTech.PMP_Partner_Product_Display_Sequence_Nbr__c = 800;
        spec_IntelTech.PMP_Specification_Chinese_Nm__c = '英特尔® 技术';
        spec_IntelTech.PMP_Specification_Japanese_Nm__c = 'インテル® テクノロジー';
        
        insert spec_IntelTech;
        
        
        PMP_Specification__c spec_Avail = new PMP_Specification__c();
        spec_Avail.Name = 'Availability and Pricing';
        spec_Avail.PMP_Partner_Product_Specification_Id__c= 'AvailabilityandPricingLevel1';
        spec_Avail.PMP_Specification_Type_Nm__c = 'Other';
        spec_Avail.PMP_Active_Ind__c = true;
        spec_Avail.PMP_Display_Type_Nm__c = 'Label';
        spec_Avail.PMP_Partner_Product_Specification_Key__c = 'AvailabilityandPricingLevel1_availabilityandpricinglevel1';
        //spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Avail.PMP_Specification_Chinese_Nm__c = '上市时间与定价';
        spec_Avail.PMP_Specification_Japanese_Nm__c = '可用性と価格';
        
        insert spec_Avail;
        
        PMP_Specification__c spec_minOrd = new PMP_Specification__c();
        spec_minOrd.Name = 'Minimum Order Quantity (Unit)';
        spec_minOrd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MinOrderQtUnit';
        spec_minOrd.PMP_Specification_Type_Nm__c = 'Other';
        spec_minOrd.PMP_Active_Ind__c = true;
        spec_minOrd.PMP_Display_Type_Nm__c = 'Integer';
        spec_minOrd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MinOrderQtUnit_npp_availabilityandpricing_minorderqtunit';
        spec_minOrd.PMP_Partner_Product_Display_Sequence_Nbr__c = 100;
        spec_minOrd.PMP_Specification_Chinese_Nm__c = '最低订购数量（单位）';
        spec_minOrd.PMP_Specification_Japanese_Nm__c = '最小注文数量 (ユニット)';
        spec_minOrd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_minOrd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        insert spec_minOrd;
        
        
        PMP_Specification__c spec_massProd = new PMP_Specification__c();
        spec_massProd.Name = 'Mass Production Schedule';
        spec_massProd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MassProductionSchedule';
        spec_massProd.PMP_Specification_Type_Nm__c = 'Other';
        spec_massProd.PMP_Active_Ind__c = true;
        spec_massProd.PMP_Display_Type_Nm__c = 'Date';
        spec_massProd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MassProductionSchedule_npp_availabilityandpricing_massproductionschedule';
        spec_massProd.PMP_Partner_Product_Display_Sequence_Nbr__c = 300;
        spec_massProd.PMP_Specification_Chinese_Nm__c = '批量生产计划';
        spec_massProd.PMP_Specification_Japanese_Nm__c = '大量生産スケジュール';
        spec_massProd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_massProd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        spec_massProd.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        insert spec_massProd;
        
        PMP_Specification__c spec_Main_Proc = new PMP_Specification__c();
        spec_Main_Proc.Name = 'Processors';
        spec_Main_Proc.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main_Proc.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main_Proc.PMP_Active_Ind__c = true;
        spec_Main_Proc.PMP_Display_Type_Nm__c = 'Label';
        spec_Main_Proc.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main_Proc.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main_Proc.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main_Proc.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main_Proc.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_npp_processors';
        insert spec_Main_Proc;
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Processor Socketed';
        spec_Core.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors_ProcessorSocketed';
        spec_Core.PMP_Specification_Type_Nm__c = 'Other';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 516;
        spec_Core.PMP_Specification_Chinese_Nm__c = '处理器已插入插槽';
        spec_Core.PMP_Specification_Japanese_Nm__c = 'ソケット搭載プロセッサー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main_Proc.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        
        PMP_Specification__c spec_USB1 = new PMP_Specification__c();
        spec_USB1.Name = 'USB1 Quantity';
        spec_USB1.PMP_Partner_Product_Specification_Id__c= 'NPP_DevicesAndInterfaces_USB_USB1Quantity';
        spec_USB1.PMP_Specification_Type_Nm__c = 'Other';
        spec_USB1.PMP_Active_Ind__c = true;
        spec_USB1.PMP_Display_Type_Nm__c = 'Integer';
        spec_USB1.PMP_Partner_Product_Specification_Key__c = 'NPP_DevicesAndInterfaces_USB_USB1Quantity_npp_devicesandinterfaces_usb_usb1quantity';
        spec_USB1.PMP_Partner_Product_Display_Sequence_Nbr__c = 3100;
        spec_USB1.PMP_Specification_Chinese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Specification_Japanese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Parent_Specification_Id__c = spec_Core.id;
        spec_USB1.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors_ProcessorSocketed';
        
        insert spec_USB1;
        
        //Create Test Specification Value :
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'Test_test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        //Intel RealSense Technology Spec Value
        
        PMP_Specification_Value__c spec_value_reals = new PMP_Specification_Value__c();
        spec_value_reals.Name = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Active_Ind__c = true;
        spec_value_reals.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_reals.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_reals.PMP_Product_Specification_Value_Cd__c = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Product_Specification_Value_Key__c = 'NPP_IntelTechnologies_intelrealsensetechnology';
        spec_value_reals.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_reals.PMP_Specification_Value_Chinese_Cd__c = '实感';
        spec_value_reals.PMP_Specification_Value_Japanese_Cd__c = 'インテル® RealSense™';
        spec_value_reals.PMP_Specification_Value_Nm__c = 'Intel® RealSense™ Technology';
        
        insert spec_value_reals;
        
        //Create a spec value record with indentifier and value as 'Yes'
        
        PMP_Specification_Value__c spec_value_Yes = new PMP_Specification_Value__c();
        spec_value_Yes.Name = 'Processor Socketed';
        spec_value_Yes.PMP_Active_Ind__c = true;
        spec_value_Yes.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Yes.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Yes.PMP_Product_Specification_Value_Cd__c = 'Processor Socketed';
        spec_value_Yes.PMP_Product_Specification_Value_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_value_Yes.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Yes.PMP_Specification_Value_Chinese_Cd__c = '处理器已插入插槽';
        spec_value_Yes.PMP_Specification_Value_Japanese_Cd__c = 'ソケット搭載プロセッサー';
        spec_value_Yes.PMP_Specification_Value_Nm__c = 'Processor Socketed';
        
        insert spec_value_Yes;        
        system.assertNotEquals(spec_value_Yes.Id,null);
        PMP_ParseSpecificationJSON.strBaseKey = 'en_US';
        PMP_ParseSpecificationJSON.ParseSpecificationJSON('PMP_Attributes_Test');
        
        Test.stopTest();
    }
    
    public static testMethod void parseChineseSpecificationJSONTest(){
        //Variable Declaration
        List<PMP_Category__c> CatList = new List<PMP_Category__c>();
        
        Test.startTest();
        //Create a category
        
        PMP_Category__c test_category_Categories = new PMP_Category__c();
        test_category_Categories.Name = 'Categories';
        test_category_Categories.PMP_Active_Ind__c = true;
        test_category_Categories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_Categories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        test_category_Categories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        test_category_Categories.PMP_Display_Type_Nm__c = 'Label';
        test_category_Categories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert test_category_Categories;
        
        PMP_Category__c test_category_System = new PMP_Category__c();
        test_category_System.Name = 'System';
        test_category_System.PMP_Active_Ind__c = true;
        test_category_System.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_System.PMP_Parent_Category_Id__c = test_category_Categories.id;
        test_category_System.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        test_category_System.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        test_category_System.PMP_Display_Type_Nm__c = 'Radiobutton';
        test_category_System.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert test_category_System;
        
        //Create Test Specification :
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'NPP_Test_npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = 'Test';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'Test';
        //spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        //spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;
        
        PMP_Specification__c spec_IntelTech = new PMP_Specification__c();
        spec_IntelTech.Name = 'Intel® Technologies';
        spec_IntelTech.PMP_Partner_Product_Specification_Id__c= 'NPP_IntelTechnologies';
        spec_IntelTech.PMP_Specification_Type_Nm__c = 'Other';
        spec_IntelTech.PMP_Active_Ind__c = true;
        spec_IntelTech.PMP_Display_Type_Nm__c = 'Label';
        spec_IntelTech.PMP_Partner_Product_Specification_Key__c = 'NPP_IntelTechnologies_npp_inteltechnologies';
        spec_IntelTech.PMP_Partner_Product_Display_Sequence_Nbr__c = 800;
        spec_IntelTech.PMP_Specification_Chinese_Nm__c = '英特尔® 技术';
        spec_IntelTech.PMP_Specification_Japanese_Nm__c = 'インテル® テクノロジー';
        
        insert spec_IntelTech;
        
        
        PMP_Specification__c spec_Avail = new PMP_Specification__c();
        spec_Avail.Name = 'Availability and Pricing';
        spec_Avail.PMP_Partner_Product_Specification_Id__c= 'AvailabilityandPricingLevel1';
        spec_Avail.PMP_Specification_Type_Nm__c = 'Other';
        spec_Avail.PMP_Active_Ind__c = true;
        spec_Avail.PMP_Display_Type_Nm__c = 'Label';
        spec_Avail.PMP_Partner_Product_Specification_Key__c = 'AvailabilityandPricingLevel1_availabilityandpricinglevel1';
        //spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Avail.PMP_Specification_Chinese_Nm__c = '上市时间与定价';
        spec_Avail.PMP_Specification_Japanese_Nm__c = '可用性と価格';
        
        insert spec_Avail;
        
        PMP_Specification__c spec_minOrd = new PMP_Specification__c();
        spec_minOrd.Name = 'Minimum Order Quantity (Unit)';
        spec_minOrd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MinOrderQtUnit';
        spec_minOrd.PMP_Specification_Type_Nm__c = 'Other';
        spec_minOrd.PMP_Active_Ind__c = true;
        spec_minOrd.PMP_Display_Type_Nm__c = 'Integer';
        spec_minOrd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MinOrderQtUnit_npp_availabilityandpricing_minorderqtunit';
        spec_minOrd.PMP_Partner_Product_Display_Sequence_Nbr__c = 100;
        spec_minOrd.PMP_Specification_Chinese_Nm__c = '最低订购数量（单位）';
        spec_minOrd.PMP_Specification_Japanese_Nm__c = '最小注文数量 (ユニット)';
        spec_minOrd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_minOrd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        insert spec_minOrd;
        
        
        PMP_Specification__c spec_massProd = new PMP_Specification__c();
        spec_massProd.Name = 'Mass Production Schedule';
        spec_massProd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MassProductionSchedule';
        spec_massProd.PMP_Specification_Type_Nm__c = 'Other';
        spec_massProd.PMP_Active_Ind__c = true;
        spec_massProd.PMP_Display_Type_Nm__c = 'Date';
        spec_massProd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MassProductionSchedule_npp_availabilityandpricing_massproductionschedule';
        spec_massProd.PMP_Partner_Product_Display_Sequence_Nbr__c = 300;
        spec_massProd.PMP_Specification_Chinese_Nm__c = '批量生产计划';
        spec_massProd.PMP_Specification_Japanese_Nm__c = '大量生産スケジュール';
        spec_massProd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_massProd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        spec_massProd.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        insert spec_massProd;
        
        PMP_Specification__c spec_Main_Proc = new PMP_Specification__c();
        spec_Main_Proc.Name = 'Processors';
        spec_Main_Proc.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main_Proc.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main_Proc.PMP_Active_Ind__c = true;
        spec_Main_Proc.PMP_Display_Type_Nm__c = 'Label';
        spec_Main_Proc.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main_Proc.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main_Proc.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main_Proc.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main_Proc.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_npp_processors';
        insert spec_Main_Proc;
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Processor Socketed';
        spec_Core.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors_ProcessorSocketed';
        spec_Core.PMP_Specification_Type_Nm__c = 'Other';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 516;
        spec_Core.PMP_Specification_Chinese_Nm__c = '处理器已插入插槽';
        spec_Core.PMP_Specification_Japanese_Nm__c = 'ソケット搭載プロセッサー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main_Proc.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        
        PMP_Specification__c spec_USB1 = new PMP_Specification__c();
        spec_USB1.Name = 'USB1 Quantity';
        spec_USB1.PMP_Partner_Product_Specification_Id__c= 'NPP_DevicesAndInterfaces_USB_USB1Quantity';
        spec_USB1.PMP_Specification_Type_Nm__c = 'Other';
        spec_USB1.PMP_Active_Ind__c = true;
        spec_USB1.PMP_Display_Type_Nm__c = 'Integer';
        spec_USB1.PMP_Partner_Product_Specification_Key__c = 'NPP_DevicesAndInterfaces_USB_USB1Quantity_npp_devicesandinterfaces_usb_usb1quantity';
        spec_USB1.PMP_Partner_Product_Display_Sequence_Nbr__c = 3100;
        spec_USB1.PMP_Specification_Chinese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Specification_Japanese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Parent_Specification_Id__c = spec_Core.id;
        spec_USB1.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors_ProcessorSocketed';
        
        insert spec_USB1;
        
        //Create Test Specification Value :
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'Test_test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        //Intel RealSense Technology Spec Value
        
        PMP_Specification_Value__c spec_value_reals = new PMP_Specification_Value__c();
        spec_value_reals.Name = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Active_Ind__c = true;
        spec_value_reals.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_reals.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_reals.PMP_Product_Specification_Value_Cd__c = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Product_Specification_Value_Key__c = 'NPP_IntelTechnologies_intelrealsensetechnology';
        spec_value_reals.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_reals.PMP_Specification_Value_Chinese_Cd__c = '实感';
        spec_value_reals.PMP_Specification_Value_Japanese_Cd__c = 'インテル® RealSense™';
        spec_value_reals.PMP_Specification_Value_Nm__c = 'Intel® RealSense™ Technology';
        
        insert spec_value_reals;
        
        //Create a spec value record with indentifier and value as 'Yes'
        
        PMP_Specification_Value__c spec_value_Yes = new PMP_Specification_Value__c();
        spec_value_Yes.Name = 'Processor Socketed';
        spec_value_Yes.PMP_Active_Ind__c = true;
        spec_value_Yes.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Yes.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Yes.PMP_Product_Specification_Value_Cd__c = 'Processor Socketed';
        spec_value_Yes.PMP_Product_Specification_Value_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_value_Yes.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Yes.PMP_Specification_Value_Chinese_Cd__c = '处理器已插入插槽';
        spec_value_Yes.PMP_Specification_Value_Japanese_Cd__c = 'ソケット搭載プロセッサー';
        spec_value_Yes.PMP_Specification_Value_Nm__c = 'Processor Socketed';
        
        insert spec_value_Yes;        
        system.assertNotEquals(spec_value_Yes.Id,null);
        PMP_ParseSpecificationJSON.strBaseKey = 'zh_CN';
        PMP_ParseSpecificationJSON.ParseSpecificationJSON('PMP_Attributes_Test');
        
        Test.stopTest();
    }
    
    public static testMethod void parseJapaneseSpecificationJSONTest(){
        //Variable Declaration
        List<PMP_Category__c> CatList = new List<PMP_Category__c>();
        
        Test.startTest();
        //Create a category
        
        PMP_Category__c test_category_Categories = new PMP_Category__c();
        test_category_Categories.Name = 'Categories';
        test_category_Categories.PMP_Active_Ind__c = true;
        test_category_Categories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_Categories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        test_category_Categories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        test_category_Categories.PMP_Display_Type_Nm__c = 'Label';
        test_category_Categories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert test_category_Categories;
        
        PMP_Category__c test_category_System = new PMP_Category__c();
        test_category_System.Name = 'System';
        test_category_System.PMP_Active_Ind__c = true;
        test_category_System.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_System.PMP_Parent_Category_Id__c = test_category_Categories.id;
        test_category_System.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        test_category_System.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        test_category_System.PMP_Display_Type_Nm__c = 'Radiobutton';
        test_category_System.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert test_category_System;
        
        //Create Test Specification :
        PMP_Specification__c spec_Test = new PMP_Specification__c();
        spec_Test.Name = 'Test';
        spec_Test.PMP_Partner_Product_Specification_Id__c= 'NPP_Test';
        spec_Test.PMP_Specification_Type_Nm__c = 'Other';
        spec_Test.PMP_Active_Ind__c = true;
        spec_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Test.PMP_Partner_Product_Specification_Key__c = 'NPP_Test_npp_test';
        spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Test.PMP_Specification_Chinese_Nm__c = 'Test';
        spec_Test.PMP_Specification_Japanese_Nm__c = 'Test';
        //spec_Test.PMP_Parent_Specification_Id__c = spec_Main.id;
        //spec_Test.PMP_Product_Parent_Specification_Id__c = 'npp_processors';
        insert spec_Test;
        
        PMP_Specification__c spec_IntelTech = new PMP_Specification__c();
        spec_IntelTech.Name = 'Intel® Technologies';
        spec_IntelTech.PMP_Partner_Product_Specification_Id__c= 'NPP_IntelTechnologies';
        spec_IntelTech.PMP_Specification_Type_Nm__c = 'Other';
        spec_IntelTech.PMP_Active_Ind__c = true;
        spec_IntelTech.PMP_Display_Type_Nm__c = 'Label';
        spec_IntelTech.PMP_Partner_Product_Specification_Key__c = 'NPP_IntelTechnologies_npp_inteltechnologies';
        spec_IntelTech.PMP_Partner_Product_Display_Sequence_Nbr__c = 800;
        spec_IntelTech.PMP_Specification_Chinese_Nm__c = '英特尔® 技术';
        spec_IntelTech.PMP_Specification_Japanese_Nm__c = 'インテル® テクノロジー';
        
        insert spec_IntelTech;
        
        
        PMP_Specification__c spec_Avail = new PMP_Specification__c();
        spec_Avail.Name = 'Availability and Pricing';
        spec_Avail.PMP_Partner_Product_Specification_Id__c= 'AvailabilityandPricingLevel1';
        spec_Avail.PMP_Specification_Type_Nm__c = 'Other';
        spec_Avail.PMP_Active_Ind__c = true;
        spec_Avail.PMP_Display_Type_Nm__c = 'Label';
        spec_Avail.PMP_Partner_Product_Specification_Key__c = 'AvailabilityandPricingLevel1_availabilityandpricinglevel1';
        //spec_Test.PMP_Partner_Product_Display_Sequence_Nbr__c = 520;
        spec_Avail.PMP_Specification_Chinese_Nm__c = '上市时间与定价';
        spec_Avail.PMP_Specification_Japanese_Nm__c = '可用性と価格';
        
        insert spec_Avail;
        
        PMP_Specification__c spec_minOrd = new PMP_Specification__c();
        spec_minOrd.Name = 'Minimum Order Quantity (Unit)';
        spec_minOrd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MinOrderQtUnit';
        spec_minOrd.PMP_Specification_Type_Nm__c = 'Other';
        spec_minOrd.PMP_Active_Ind__c = true;
        spec_minOrd.PMP_Display_Type_Nm__c = 'Integer';
        spec_minOrd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MinOrderQtUnit_npp_availabilityandpricing_minorderqtunit';
        spec_minOrd.PMP_Partner_Product_Display_Sequence_Nbr__c = 100;
        spec_minOrd.PMP_Specification_Chinese_Nm__c = '最低订购数量（单位）';
        spec_minOrd.PMP_Specification_Japanese_Nm__c = '最小注文数量 (ユニット)';
        spec_minOrd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_minOrd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        insert spec_minOrd;
        
        
        PMP_Specification__c spec_massProd = new PMP_Specification__c();
        spec_massProd.Name = 'Mass Production Schedule';
        spec_massProd.PMP_Partner_Product_Specification_Id__c= 'NPP_AvailabilityAndPricing_MassProductionSchedule';
        spec_massProd.PMP_Specification_Type_Nm__c = 'Other';
        spec_massProd.PMP_Active_Ind__c = true;
        spec_massProd.PMP_Display_Type_Nm__c = 'Date';
        spec_massProd.PMP_Partner_Product_Specification_Key__c = 'NPP_AvailabilityAndPricing_MassProductionSchedule_npp_availabilityandpricing_massproductionschedule';
        spec_massProd.PMP_Partner_Product_Display_Sequence_Nbr__c = 300;
        spec_massProd.PMP_Specification_Chinese_Nm__c = '批量生产计划';
        spec_massProd.PMP_Specification_Japanese_Nm__c = '大量生産スケジュール';
        spec_massProd.PMP_Parent_Specification_Id__c = spec_Avail.id;
        spec_massProd.PMP_Product_Parent_Specification_Id__c = 'AvailabilityandPricingLevel1';
        spec_massProd.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        insert spec_massProd;
        
        PMP_Specification__c spec_Main_Proc = new PMP_Specification__c();
        spec_Main_Proc.Name = 'Processors';
        spec_Main_Proc.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors';
        spec_Main_Proc.PMP_Specification_Type_Nm__c = 'Other';
        spec_Main_Proc.PMP_Active_Ind__c = true;
        spec_Main_Proc.PMP_Display_Type_Nm__c = 'Label';
        spec_Main_Proc.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Sys';
        spec_Main_Proc.PMP_Partner_Product_Display_Sequence_Nbr__c = 510;
        spec_Main_Proc.PMP_Specification_Chinese_Nm__c = '处理器';
        spec_Main_Proc.PMP_Specification_Japanese_Nm__c = 'プロセッサー';
        spec_Main_Proc.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_npp_processors';
        insert spec_Main_Proc;
        
        PMP_Specification__c spec_Core = new PMP_Specification__c();
        spec_Core.Name = 'Processor Socketed';
        spec_Core.PMP_Partner_Product_Specification_Id__c= 'NPP_Processors_ProcessorSocketed';
        spec_Core.PMP_Specification_Type_Nm__c = 'Other';
        spec_Core.PMP_Active_Ind__c = true;
        spec_Core.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_Core.PMP_Partner_Product_Specification_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_Core.PMP_Partner_Product_Display_Sequence_Nbr__c = 516;
        spec_Core.PMP_Specification_Chinese_Nm__c = '处理器已插入插槽';
        spec_Core.PMP_Specification_Japanese_Nm__c = 'ソケット搭載プロセッサー';
        spec_Core.PMP_Parent_Specification_Id__c = spec_Main_Proc.id;
        spec_Core.PMP_Product_Parent_Specification_Id__c = 'npp_processors';    
        insert spec_Core;
        
        
        PMP_Specification__c spec_USB1 = new PMP_Specification__c();
        spec_USB1.Name = 'USB1 Quantity';
        spec_USB1.PMP_Partner_Product_Specification_Id__c= 'NPP_DevicesAndInterfaces_USB_USB1Quantity';
        spec_USB1.PMP_Specification_Type_Nm__c = 'Other';
        spec_USB1.PMP_Active_Ind__c = true;
        spec_USB1.PMP_Display_Type_Nm__c = 'Integer';
        spec_USB1.PMP_Partner_Product_Specification_Key__c = 'NPP_DevicesAndInterfaces_USB_USB1Quantity_npp_devicesandinterfaces_usb_usb1quantity';
        spec_USB1.PMP_Partner_Product_Display_Sequence_Nbr__c = 3100;
        spec_USB1.PMP_Specification_Chinese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Specification_Japanese_Nm__c = 'USB1 数量';
        spec_USB1.PMP_Parent_Specification_Id__c = spec_Core.id;
        spec_USB1.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors_ProcessorSocketed';
        
        insert spec_USB1;
        
        //Create Test Specification Value :
        
        PMP_Specification_Value__c spec_value_Proc_Test = new PMP_Specification_Value__c();
        spec_value_Proc_Test.Name = 'Test';
        spec_value_Proc_Test.PMP_Active_Ind__c = true;
        spec_value_Proc_Test.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Proc_Test.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Proc_Test.PMP_Product_Specification_Value_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Product_Specification_Value_Key__c = 'Test_test';
        spec_value_Proc_Test.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Proc_Test.PMP_Specification_Value_Chinese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Japanese_Cd__c = 'Test';
        spec_value_Proc_Test.PMP_Specification_Value_Nm__c = 'Test';
        
        insert spec_value_Proc_Test;
        
        //Intel RealSense Technology Spec Value
        
        PMP_Specification_Value__c spec_value_reals = new PMP_Specification_Value__c();
        spec_value_reals.Name = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Active_Ind__c = true;
        spec_value_reals.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_reals.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_reals.PMP_Product_Specification_Value_Cd__c = 'Intel® RealSense™ Technology';
        spec_value_reals.PMP_Product_Specification_Value_Key__c = 'NPP_IntelTechnologies_intelrealsensetechnology';
        spec_value_reals.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_reals.PMP_Specification_Value_Chinese_Cd__c = '实感';
        spec_value_reals.PMP_Specification_Value_Japanese_Cd__c = 'インテル® RealSense™';
        spec_value_reals.PMP_Specification_Value_Nm__c = 'Intel® RealSense™ Technology';
        
        insert spec_value_reals;
        
        //Create a spec value record with indentifier and value as 'Yes'
        
        PMP_Specification_Value__c spec_value_Yes = new PMP_Specification_Value__c();
        spec_value_Yes.Name = 'Processor Socketed';
        spec_value_Yes.PMP_Active_Ind__c = true;
        spec_value_Yes.PMP_Display_Type_Nm__c = 'Checkbox';
        spec_value_Yes.PMP_Partner_Off_Roadmap_Ind__c = false;
        spec_value_Yes.PMP_Product_Specification_Value_Cd__c = 'Processor Socketed';
        spec_value_Yes.PMP_Product_Specification_Value_Key__c = 'NPP_Processors_ProcessorSocketed_npp_processors_processorsocketed';
        spec_value_Yes.PMP_Spec_Value_Type_Nm__c = 'Other';
        spec_value_Yes.PMP_Specification_Value_Chinese_Cd__c = '处理器已插入插槽';
        spec_value_Yes.PMP_Specification_Value_Japanese_Cd__c = 'ソケット搭載プロセッサー';
        spec_value_Yes.PMP_Specification_Value_Nm__c = 'Processor Socketed';
        
        insert spec_value_Yes;        
        system.assertNotEquals(spec_value_Yes.Id,null);
        PMP_ParseSpecificationJSON.strBaseKey = 'ja_JP';
        PMP_ParseSpecificationJSON.ParseSpecificationJSON('PMP_Attributes_Test');
        
        Test.stopTest();
    }
}