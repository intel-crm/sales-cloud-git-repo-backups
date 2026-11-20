/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_OS_CreateJunctionData_Test
* Version     : 1.0 
* Created Date: 24th Jul, 2020
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            07/24/2020              Test Class for PMP_OS_CreateJunctionData.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_OS_CreateJunctionData_Test {
//IPA 2.0- US-TWC729-7980
     /*public testMethod static void createOSJunctionDataMetTest(){
        
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
        mainSpec.Name = 'Operating Systems';
        mainSpec.PMP_Specification_Name__c = 'Operating Systems';
        mainSpec.PMP_Partner_Product_Specification_Id__c= 'NPP_OperationSystems';
        mainSpec.PMP_Specification_Type_Nm__c = 'Other';
        mainSpec.PMP_Active_Ind__c = true;
        mainSpec.PMP_Display_Type_Nm__c = 'Label';
        mainSpec.PMP_Mandatory_Offering_Category_Nm__c = 'IPA_TYPE_Sys,TPS_900003';
        mainSpec.PMP_Partner_Product_Display_Sequence_Nbr__c = 750;
        mainSpec.PMP_Specification_Chinese_Nm__c = 'Operating Systems';
        mainSpec.PMP_Specification_Japanese_Nm__c = 'Operating Systems';
        mainSpec.PMP_Partner_Product_Specification_Key__c = 'npp_operationsystems';
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.Name = 'OS Independent';
        Spec1.PMP_Specification_Name__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Id__c= '203701';
        Spec1.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec1.PMP_Specification_Type_Nm__c = 'OS';
        Spec1.PMP_Active_Ind__c = true;
        Spec1.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = 120;
        Spec1.PMP_Specification_Chinese_Nm__c = 'OS Independent';
        Spec1.PMP_Specification_Japanese_Nm__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Key__c = '203701';
        
        PMP_Specification__c Spec2 = new PMP_Specification__c();
        Spec2.Name = 'Microsoft Windows Client*';
        Spec2.PMP_Specification_Name__c = 'Microsoft Windows Client*';
        Spec2.PMP_Partner_Product_Specification_Id__c= '203699';
        Spec2.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec2.PMP_Specification_Type_Nm__c = 'OS';
        Spec2.PMP_Active_Ind__c = true;
        Spec2.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec2.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        Spec2.PMP_Specification_Chinese_Nm__c = 'Microsoft Windows Client*';
        Spec2.PMP_Specification_Japanese_Nm__c = 'Microsoft Windows Client*';
        Spec2.PMP_Partner_Product_Specification_Key__c = '203699';
        
        PMP_Specification__c Spec3 = new PMP_Specification__c();
        Spec3.Name = 'OS Independent family';
        Spec3.PMP_Specification_Name__c = 'OS Independent family';
        Spec3.PMP_Partner_Product_Specification_Id__c= '21479';
        Spec3.PMP_Product_Parent_Specification_Id__c = '203701';
        Spec3.PMP_Specification_Type_Nm__c = 'OS';
        Spec3.PMP_Active_Ind__c = true;
        Spec3.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec3.PMP_Partner_Product_Display_Sequence_Nbr__c = 126;
        Spec3.PMP_Specification_Chinese_Nm__c = 'OS Independent family';
        Spec3.PMP_Specification_Japanese_Nm__c = 'OS Independent family';
        Spec3.PMP_Partner_Product_Specification_Key__c = '21479';
        
        PMP_Specification__c Spec4 = new PMP_Specification__c();
        Spec4.Name = 'Windows 10 family*';
        Spec4.PMP_Specification_Name__c = 'Windows 10 family*';
        Spec4.PMP_Partner_Product_Specification_Id__c= '88003';
        Spec4.PMP_Product_Parent_Specification_Id__c = '203699';
        Spec4.PMP_Specification_Type_Nm__c = 'OS';
        Spec4.PMP_Active_Ind__c = true;
        Spec4.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec4.PMP_Partner_Product_Display_Sequence_Nbr__c = 125;
        Spec4.PMP_Specification_Chinese_Nm__c = 'Windows 10 family*';
        Spec4.PMP_Specification_Japanese_Nm__c = 'Windows 10 family*';
        Spec4.PMP_Partner_Product_Specification_Key__c = '88003';
        
        uploadableSpecifications.add(mainSpec);
        uploadableSpecifications.add(Spec1);
        uploadableSpecifications.add(Spec2);
        uploadableSpecifications.add(Spec3);
        uploadableSpecifications.add(Spec4);
        insert uploadableSpecifications;
        
        PMP_Specification_Value__c specValueNUC1 = new PMP_Specification_Value__c();
        specValueNUC1.Name = 'OS Independent';
        specValueNUC1.PMP_Active_Ind__c = true;
        specValueNUC1.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC1.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC1.PMP_Product_Specification_Value_Cd__c = '46435';
        specValueNUC1.PMP_Product_Specification_Value_Key__c = '46435';
        specValueNUC1.PMP_Spec_Value_Type_Nm__c = 'OS';
        //specValueNUC1.PMP_Specification_Value_Chinese_Cd__c = '英特尔® NUC 9 至尊版计算元件 - NUC9i9QNB(先前产品为  Ghost Canyon)';
        //specValueNUC1.PMP_Specification_Value_Japanese_Cd__c = 'インテル® NUC 9 Extreme コンピュート・エレメント - NUC9i9QNB(製品の開発コード名  Ghost Canyon)';
        specValueNUC1.PMP_Specification_Value_Nm__c = 'OS Independent';
        
        PMP_Specification_Value__c specValueNUC2 = new PMP_Specification_Value__c();
        specValueNUC2.Name = 'Windows 10*';
        specValueNUC2.PMP_Active_Ind__c = true;
        specValueNUC2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC2.PMP_Product_Specification_Value_Cd__c = '96534';
        specValueNUC2.PMP_Product_Specification_Value_Key__c = '96534';
        specValueNUC2.PMP_Spec_Value_Type_Nm__c = 'OS';
        //specValueNUC2.PMP_Specification_Value_Chinese_Cd__c = '英特尔® NUC 8 专业计算元件(先前产品为  Chandler Bay)';
        //specValueNUC2.PMP_Specification_Value_Japanese_Cd__c = 'インテル® NUC 8 Pro コンピュート・エレメント(製品の開発コード名  Chandler Bay)';
        specValueNUC2.PMP_Specification_Value_Nm__c = 'Windows 10*';
        
        PMP_Specification_Value__c specValueNUC3 = new PMP_Specification_Value__c();
        specValueNUC3.Name = 'Windows 8.1*';
        specValueNUC3.PMP_Active_Ind__c = true;
        specValueNUC3.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueNUC3.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueNUC3.PMP_Product_Specification_Value_Cd__c = '77650';
        specValueNUC3.PMP_Product_Specification_Value_Key__c = '77650';
        specValueNUC3.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueNUC3.PMP_Specification_Value_Nm__c = 'Windows 8.1*';
        
        uploadableSpecificationValues.add(specValueNUC1);
        uploadableSpecificationValues.add(specValueNUC2);
        uploadableSpecificationValues.add(specValueNUC3);
        insert uploadableSpecificationValues;
        
        //Create Category Specification Association record
        PMP_Category_Specification_Association__c test_Proc_CSA = new PMP_Category_Specification_Association__c();
        test_Proc_CSA.Name = 'System:Operating Systems';
        test_Proc_CSA.PMP_Active_Ind__c = true;
        test_Proc_CSA.PMP_Category_Id__c = test_category_System.id;
        test_Proc_CSA.PMP_Specification_Id__c = mainSpec.id;
        test_Proc_CSA.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|npp_operationsystems';
        
        insert test_Proc_CSA;
        
        PMP_Category_Specification_Association__c nucCatAssoc = new PMP_Category_Specification_Association__c();
        nucCatAssoc.Name = 'System:OS Independent';
        nucCatAssoc.PMP_Active_Ind__c = true;
        nucCatAssoc.PMP_Category_Id__c = test_category_System.id;
        nucCatAssoc.PMP_Specification_Id__c = Spec1.id;
        nucCatAssoc.PMP_Category_Specification_External_Key__c = 'npp_02_type_sys|203701';
        insert nucCatAssoc;
        
        //Create Spec-SpecValue association records
        PMP_Specification_Value_Association__c specValueAssoc = new PMP_Specification_Value_Association__c ();
        specValueAssoc.Name = 'OS Independent';
        specValueAssoc.PMP_Active_Ind__c = true;
        specValueAssoc.PMP_Category_Id__c = test_category_System.id;
        specValueAssoc.PMP_Specification_Id__c = Spec1.id;
        specValueAssoc.PMP_Specification_Value_Id__c = specValueNUC1.id;
        specValueAssoc.PMP_Category_Spec_Value_External_Key__c = 'npp_02_type_sys|46435|203701';
        insert specValueAssoc;
        
        PMP_OS_CreateJunctionData.createAssociationRecords();
        PMP_Category_Specification_Association__c csa = [SELECT Id, PMP_Category_Id__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__c =: Spec1.Id];
        System.assertEquals(test_category_System.Id, csa.PMP_Category_Id__c);
        Test.stopTest();
        
    }*/
}