/****************************************************************************************************************************************
* Class Name  : PMP_OfferingCategoryHelper_Test 
* Version     : 1.0 
* Created Date: Jun-03-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj                 Aug-06-2019                    Test class for PMP_OfferingCategoryHelper
****************************************************************************************************************************************************************/
@isTest
public class PMP_OfferingCategoryHelper_Test {

    static testMethod void createOfferingCategoriesTestPositiveScenario(){//test method for the scenario when there is no existing offering categories
        
        Intel_FormData formData = new Intel_FormData();
        List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
        List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
        List<Intel_SpecificationDataWrapper> catSubCat = new List<Intel_SpecificationDataWrapper>();
        List<Intel_SpecificationDataWrapper> industries = new List<Intel_SpecificationDataWrapper>();
        List<Intel_SpecificationDataWrapper> applications = new List<Intel_SpecificationDataWrapper>();
        Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeIndApp = new Map<String,List<Intel_SpecificationDataWrapper>>();
        Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeCat = new Map<String,List<Intel_SpecificationDataWrapper>>();
		Test.startTest();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
        System.assertEquals('Component', cat1.Name);
        PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Retail', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us');
        System.assertEquals('Retail', ind2.Name);
        
        cat0.PMP_Parent_Category_Id__c = null;
        cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        app0.PMP_Parent_Category_Id__c = null;
        app0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        ind0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        cat2.PMP_Parent_Category_Id__c = cat1.Id;
        cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        app1.PMP_Parent_Category_Id__c = app0.Id;
        app1.PMP_Business_Segment_Nm__c = 'IoT';
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        ind1.PMP_Business_Segment_Nm__c = 'IoT';
        ind2.PMP_Parent_Category_Id__c = ind0.Id;
        ind2.PMP_Business_Segment_Nm__c = 'IoT';
        
        updateCategories.add(cat0);
        updateCategories.add(app0);
        updateCategories.add(ind0);
        updateCategories.add(cat1);
        updateCategories.add(cat2);
        updateCategories.add(app1);
        updateCategories.add(ind1);
        updateCategories.add(ind2);
        
        update updateCategories;
        
        Intel_SpecificationDataWrapper specDataWrapper1 = new Intel_SpecificationDataWrapper();
        specDataWrapper1.id = cat1.Id;
        catSubCat.add(specDataWrapper1);
        Intel_SpecificationDataWrapper specDataWrapper2 = new Intel_SpecificationDataWrapper();
        specDataWrapper2.id = cat2.Id;
        catSubCat.add(specDataWrapper2);
        Intel_SpecificationDataWrapper specDataWrapper3 = new Intel_SpecificationDataWrapper();
        specDataWrapper3.id = app1.Id;
        industries.add(specDataWrapper3);
        Intel_SpecificationDataWrapper specDataWrapper4 = new Intel_SpecificationDataWrapper();
        specDataWrapper4.id = ind1.Id;
        applications.add(specDataWrapper4);
        Intel_SpecificationDataWrapper specDataWrapper5 = new Intel_SpecificationDataWrapper();
        specDataWrapper5.id = ind2.Id;
        applications.add(specDataWrapper5);
        
        valueByTypeCat.put('Tab1DropdownRadioCombo', catSubCat);
        valueByTypeIndApp.put('industryValues', industries);
        valueByTypeIndApp.put('applicationValues', applications);
        formData.categoryAndSubCategory = valueByTypeCat;
        formData.industryAndApplication = valueByTypeIndApp;
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.Name = 'Categories';
        offCat2.PMP_Offering_Id__c = off1.Id;
        offCat2.PMP_Category_Id__c = cat0.Id;
        
        PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
        offCat4.Name = 'Industry';
        offCat4.PMP_Offering_Id__c = off1.Id;
        offCat4.PMP_Category_Id__c = ind0.Id;
        
        insertOffCategories.add(offCat2);
        insertOffCategories.add(offCat4);
        
        insert insertOffCategories;
        
        PMP_OfferingCategoryHelper.createOfferingCategories(formData,off1,1,1);
        Test.stopTest();
        
    }
    
    static testMethod void populateSpecificationDataWrapperTest(){
        List<PMP_Specification__c> specList = New List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> specValList = New List<PMP_Specification_Value__c>();
        PMP_Specification__c spec1 = New PMP_Specification__c(name='Intel Technologies',
                                                            PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies',
                                                            PMP_Partner_Product_Specification_Key__c='npp_inteltechnologies');
        System.assertEquals( 'Intel Technologies',spec1.name);                                                   
        PMP_Specification__c spec2 = New PMP_Specification__c(name='End Customer Type',
                                                            PMP_Partner_Product_Specification_Id__c = 'NPP_EndCustomerType',
                                                            PMP_Partner_Product_Specification_Key__c='npp_endcustomertype');
        System.assertEquals('End Customer Type',spec2.name);
        PMP_Specification__c spec3 = New PMP_Specification__c(name='Displays',PMP_Partner_Product_Specification_Id__c = 'DisplaysLevel1',
                                                            PMP_Partner_Product_Specification_Key__c='displayslevel1');
        System.assertEquals( 'Displays',spec3.name);
        specList.add(spec1);
        specList.add(spec2);
        specList.add(spec3);
        
        PMP_Specification_Value__c specVal1 = New PMP_Specification_Value__c (Name='TestSpec', PMP_Product_Specification_Value_Cd__c='Test');
        PMP_Specification_Value__c specVal2 = New PMP_Specification_Value__c (Name='TestSpec12', PMP_Product_Specification_Value_Cd__c='Test21');
        PMP_Specification_Value__c specVal3 = New PMP_Specification_Value__c (Name='TestSpec132', PMP_Product_Specification_Value_Cd__c='Test23');
        specValList.add(specVal1);
        specValList.add(specVal2);
        specValList.add(specVal3);
        
        insert specList;
        insert specValList;
        
        Map<string, List<string>> specification_smplTab2 = New Map<string, List<string>>();
        List<string> specificaions = new List<string>{'TestSpec','TestSpec12','TestSpec132'};
        Map<string, string> specification_txtTab2 = New  Map<string, string> ();
        Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab2 = new Map<string, List<Intel_SpecificationDataWrapper>>();
        
        List<Intel_SpecificationDataWrapper> wrapperList = New List<Intel_SpecificationDataWrapper>();
        Intel_SpecificationDataWrapper specWrapper1 = New Intel_SpecificationDataWrapper();
        specWrapper1.id = specVal1.id+ '|'+spec1.id;
        Intel_SpecificationDataWrapper specWrapper2 = New Intel_SpecificationDataWrapper();
        specWrapper2.id = specVal3.id+ '|'+spec1.id;
        Intel_SpecificationDataWrapper specWrapper3 = New Intel_SpecificationDataWrapper();
        specWrapper3.id = spec1.id;
        wrapperList.add(specWrapper1);
        wrapperList.add(specWrapper2);
        wrapperList.add(specWrapper3);
        specification_cmplxTab2.put('NPP_IntelTechnologies',wrapperList);
        specification_smplTab2.put('Specifications',specificaions);
        PMP_OfferingCategoryHelper.populateSpecificationDataWrapper(specification_cmplxTab2,specification_smplTab2,specification_cmplxTab2);
    }
    
}