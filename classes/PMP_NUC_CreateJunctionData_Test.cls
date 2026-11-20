/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_CreateJunctionData_Test
* Version     : 1.0 
* Created Date: 12th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/12/2019               Test Class for PMP_NUC_CreateJunctionData.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_NUC_CreateJunctionData_Test {
    //IPA 2.0- US-TWC729-7980
    /*public testMethod static void createNUCJunctionDataMetTest(){
        
        List<PMP_Specification__c> uploadableSpecifications = new List<PMP_Specification__c>();//list containing specifications to be uploaded
        List<PMP_Specification_Value__c> uploadableSpecificationValues = new List<PMP_Specification_Value__c>();//list containing specificationValues to be uploaded
        List<PMP_Category__c> uploadableCategories = new List<PMP_Category__c>();//list containing categories to be uploaded
        Test.startTest();
        PMP_Category__c test_category_Categories = new PMP_Category__c();
        test_category_Categories.Name = 'Categories';
        test_category_Categories.PMP_Active_Ind__c = true;
        test_category_Categories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_Categories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        test_category_Categories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        test_category_Categories.PMP_Display_Type_Nm__c = 'Label';
        test_category_Categories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        PMP_Category__c test_category_System = new PMP_Category__c();
        test_category_System.Name = 'System';
        test_category_System.PMP_Active_Ind__c = true;
        test_category_System.PMP_Business_Segment_Nm__c = 'IoT;Server';
        test_category_System.PMP_Parent_Category_Id__c = test_category_Categories.id;
        test_category_System.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        test_category_System.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        test_category_System.PMP_Display_Type_Nm__c = 'Radiobutton';
        test_category_System.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        uploadableCategories.add(test_category_Categories);
        uploadableCategories.add(test_category_System);
        insert uploadableCategories;
        
        PMP_Specification__c mainSpec = new PMP_Specification__c();
        mainSpec.Name = 'NUC';
        mainSpec.PMP_Specification_Name__c = 'NUC';
        mainSpec.PMP_Partner_Product_Specification_Id__c= 'NPP_NUC';
        mainSpec.PMP_Specification_Type_Nm__c = 'Other';
        mainSpec.PMP_Active_Ind__c = true;
        mainSpec.PMP_Display_Type_Nm__c = 'Label';
        mainSpec.PMP_Mandatory_Offering_Category_Nm__c = 'Not minimum requirement. Optional';
        mainSpec.PMP_Partner_Product_Display_Sequence_Nbr__c = 750;
        mainSpec.PMP_Specification_Chinese_Nm__c = 'NUC';
        mainSpec.PMP_Specification_Japanese_Nm__c = 'NUC';
        mainSpec.PMP_Partner_Product_Specification_Key__c = 'npp_nuc';
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.Name = 'Intel® NUC Elements';
        Spec1.PMP_Specification_Name__c = 'Intel® NUC Elements';
        Spec1.PMP_Partner_Product_Specification_Id__c= '197864';
        Spec1.PMP_Product_Parent_Specification_Id__c = 'NPP_NUC';
        Spec1.PMP_Specification_Type_Nm__c = 'NUC';
        Spec1.PMP_Active_Ind__c = true;
        Spec1.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = 120;
        Spec1.PMP_Specification_Chinese_Nm__c = '英特尔® NUC 元件';
        Spec1.PMP_Specification_Japanese_Nm__c = 'インテル® NUC エレメント';
        Spec1.PMP_Partner_Product_Specification_Key__c = '197864';
        
        PMP_Specification__c Spec2 = new PMP_Specification__c();
        Spec2.Name = 'Intel® NUC Compute Elements';
        Spec2.PMP_Specification_Name__c = 'Intel® NUC Compute Elements';
        Spec2.PMP_Partner_Product_Specification_Id__c= '198080';
        Spec2.PMP_Product_Parent_Specification_Id__c = '197864';
        Spec2.PMP_Specification_Type_Nm__c = 'NUC';
        Spec2.PMP_Active_Ind__c = true;
        Spec2.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec2.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        Spec2.PMP_Specification_Chinese_Nm__c = '英特尔® NUC 计算元件';
        Spec2.PMP_Specification_Japanese_Nm__c = 'インテル® NUC コンピュート・エレメント';
        Spec2.PMP_Partner_Product_Specification_Key__c = '198080';
        
        PMP_Specification__c Spec3 = new PMP_Specification__c();
        Spec3.Name = 'Intel® Compute Sticks';
        Spec3.PMP_Specification_Name__c = 'Intel® Compute Sticks';
        Spec3.PMP_Partner_Product_Specification_Id__c= '84815';
        Spec3.PMP_Product_Parent_Specification_Id__c = 'NPP_NUC';
        Spec3.PMP_Specification_Type_Nm__c = 'NUC';
        Spec3.PMP_Active_Ind__c = true;
        Spec3.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec3.PMP_Partner_Product_Display_Sequence_Nbr__c = 126;
        Spec3.PMP_Specification_Chinese_Nm__c = '英特尔® 电脑棒';
        Spec3.PMP_Specification_Japanese_Nm__c = 'インテル® Compute Stick';
        Spec3.PMP_Partner_Product_Specification_Key__c = '84815';
        
        PMP_Specification__c Spec4 = new PMP_Specification__c();
        Spec4.Name = 'Intel® Compute Cards';
        Spec4.PMP_Specification_Name__c = 'Intel® Compute Cards';
        Spec4.PMP_Partner_Product_Specification_Id__c= '121325';
        Spec4.PMP_Product_Parent_Specification_Id__c = 'NPP_NUC';
        Spec4.PMP_Specification_Type_Nm__c = 'NUC';
        Spec4.PMP_Active_Ind__c = true;
        Spec4.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec4.PMP_Partner_Product_Display_Sequence_Nbr__c = 125;
        Spec4.PMP_Specification_Chinese_Nm__c = '英特尔® 电脑卡';
        Spec4.PMP_Specification_Japanese_Nm__c = 'インテル® Compute Card';
        Spec4.PMP_Partner_Product_Specification_Key__c = '121325';
        
        uploadableSpecifications.add(mainSpec);
        uploadableSpecifications.add(Spec1);
        uploadableSpecifications.add(Spec2);
        uploadableSpecifications.add(Spec3);
        uploadableSpecifications.add(Spec4);
        insert uploadableSpecifications;
        
        PMP_Specification_Value__c specValueNUC1 = new PMP_Specification_Value__c();
        specValueNUC1.Name = 'Intel® NUC 9 Extreme Compute Element - NUC9i9QNB(formerly Ghost Canyon)';
        specValueNUC1.PMP_Active_Ind__c = true;
        specValueNUC1.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC1.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC1.PMP_Product_Specification_Value_Cd__c = '199870';
        specValueNUC1.PMP_Product_Specification_Value_Key__c = '199870';
        specValueNUC1.PMP_Spec_Value_Type_Nm__c = 'NUC';
        //specValueNUC1.PMP_Specification_Value_Chinese_Cd__c = '英特尔® NUC 9 至尊版计算元件 - NUC9i9QNB(先前产品为  Ghost Canyon)';
        //specValueNUC1.PMP_Specification_Value_Japanese_Cd__c = 'インテル® NUC 9 Extreme コンピュート・エレメント - NUC9i9QNB(製品の開発コード名  Ghost Canyon)';
        specValueNUC1.PMP_Specification_Value_Nm__c = 'Intel® NUC 9 Extreme Compute Element - NUC9i9QNB(formerly Ghost Canyon)';
        
        PMP_Specification_Value__c specValueNUC2 = new PMP_Specification_Value__c();
        specValueNUC2.Name = 'Intel® NUC 8 Pro Compute Element(formerly Chandler Bay)';
        specValueNUC2.PMP_Active_Ind__c = true;
        specValueNUC2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC2.PMP_Product_Specification_Value_Cd__c = '197822';
        specValueNUC2.PMP_Product_Specification_Value_Key__c = '197822';
        specValueNUC2.PMP_Spec_Value_Type_Nm__c = 'NUC';
        //specValueNUC2.PMP_Specification_Value_Chinese_Cd__c = '英特尔® NUC 8 专业计算元件(先前产品为  Chandler Bay)';
        //specValueNUC2.PMP_Specification_Value_Japanese_Cd__c = 'インテル® NUC 8 Pro コンピュート・エレメント(製品の開発コード名  Chandler Bay)';
        specValueNUC2.PMP_Specification_Value_Nm__c = 'Intel® NUC 8 Pro Compute Element(formerly Chandler Bay)';
        
        PMP_Specification_Value__c specValueNUC3 = new PMP_Specification_Value__c();
        specValueNUC3.Name = 'Intel® NUC 8 Essential Compute Element(formerly Chandler Bay)';
        specValueNUC3.PMP_Active_Ind__c = true;
        specValueNUC3.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC3.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC3.PMP_Product_Specification_Value_Cd__c = '197828';
        specValueNUC3.PMP_Product_Specification_Value_Key__c = '197828';
        specValueNUC3.PMP_Spec_Value_Type_Nm__c = 'NUC';
        specValueNUC3.PMP_Specification_Value_Nm__c = 'Intel® NUC 8 Essential Compute Element(formerly Chandler Bay)';
        
        uploadableSpecificationValues.add(specValueNUC1);
        uploadableSpecificationValues.add(specValueNUC2);
        uploadableSpecificationValues.add(specValueNUC3);
        insert uploadableSpecificationValues;
        
        //Create Category Specification Association record
        PMP_Category_Specification_Association__c test_Proc_CSA = new PMP_Category_Specification_Association__c();
        test_Proc_CSA.Name = 'System:NUC';
        test_Proc_CSA.PMP_Active_Ind__c = true;
        test_Proc_CSA.PMP_Category_Id__c = test_category_System.id;
        test_Proc_CSA.PMP_Specification_Id__c = mainSpec.id;
        test_Proc_CSA.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_nuc';
        
        insert test_Proc_CSA;
        
        PMP_Category_Specification_Association__c nucCatAssoc = new PMP_Category_Specification_Association__c();
        nucCatAssoc.Name = 'System:Intel® NUC Elements';
        nucCatAssoc.PMP_Active_Ind__c = true;
        nucCatAssoc.PMP_Category_Id__c = test_category_System.id;
        nucCatAssoc.PMP_Specification_Id__c = Spec1.id;
        nucCatAssoc.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|197864';
        insert nucCatAssoc;
        
        //Create Spec-SpecValue association records
        PMP_Specification_Value_Association__c specValueAssoc = new PMP_Specification_Value_Association__c ();
        specValueAssoc.Name = 'Intel® NUC 9 Extreme Compute Element - NUC9i9QNB(formerly Ghost Canyon)';
        specValueAssoc.PMP_Active_Ind__c = true;
        specValueAssoc.PMP_Category_Id__c = test_category_System.id;
        specValueAssoc.PMP_Specification_Id__c = Spec1.id;
        specValueAssoc.PMP_Specification_Value_Id__c = specValueNUC1.id;
        specValueAssoc.PMP_Category_Spec_Value_External_Key__c = 'npp_02_type_sys|199870|197864';
        insert specValueAssoc;
        
        PMP_NUC_CreateJunctionData.createAssociationRecords();
        PMP_Category_Specification_Association__c csa = [SELECT Id, PMP_Category_Id__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__c =: Spec1.Id];
        System.assertEquals(test_category_System.Id, csa.PMP_Category_Id__c);
        Test.stopTest();
        
    }*/
    
}