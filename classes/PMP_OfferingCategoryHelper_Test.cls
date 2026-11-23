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
    
    // @TestSetup  
    // static void createData(){
        
        
        
    //     insertCategories();
    // }
    
    
    // static void insertCategories(){
    //     List<PMP_Category__c> insertCategories = new List<PMP_Category__c>();
    //     PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us',false);
    //     PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us',false); // value change from Application to Use Cases
    //     PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us',false);
    //     PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Test 1', 'TPS_900002','NPP_01_TYPE', 'en_us',false);
        
    //     PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Test 2', 'TPS_900022','TPS_900002', 'en_us',false);
    //     PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Test 3', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us',false);
    //     PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Test 3', 'IPA_APP_ConnectedWorker2','NPP_01_APP', 'en_us',false);
    //     PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Test 4', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us',false);
    //     PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Test 5', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us',false);
        
        
    //     cat0.PMP_Parent_Category_Id__c = null;
    //     cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
       
    //     app0.PMP_Parent_Category_Id__c = null;
    //     app0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
    //     ind0.PMP_Parent_Category_Id__c = null;
    //     ind0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
       
    //     cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        
    //     cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        
    //     app1.PMP_Business_Segment_Nm__c = 'IoT';
        
    //     ind1.PMP_Business_Segment_Nm__c = 'IoT';
     
    //     ind2.PMP_Business_Segment_Nm__c = 'IoT';
        
    //     insertCategories.add(cat0);
    //     insertCategories.add(app0);
    //     insertCategories.add(ind0);
    //     insertCategories.add(cat1);
    //     insertCategories.add(cat2);
    //     insertCategories.add(app1);
    //     insertCategories.add(app2);
    //     insertCategories.add(ind1);
    //     insertCategories.add(ind2);
        
    //     insert insertCategories;
    //     List<PMP_Category__c> updateList = New List<PMP_Category__c>();
    //     // system.debug('id--'+cat0.id);
    //     cat1.PMP_Parent_Category_Id__c = cat0.id;
    //     cat2.PMP_Parent_Category_Id__c = cat1.id;
    //     app1.PMP_Parent_Category_Id__c = app0.id;
    //     app2.PMP_Parent_Category_Id__c = app0.id;
    //     ind1.PMP_Parent_Category_Id__c = ind0.id;
    //     ind2.PMP_Parent_Category_Id__c = ind0.id;
    //     // system.debug('parentid--'+cat2.PMP_Parent_Category_Id__c );
    //     updateList.add(cat1);
        
    //     updateList.add(cat2);
    //     updateList.add(app1);
    //     updateList.add(app2);
    //     updateList.add(ind1);
    //     updateList.add(ind2);
    //     update updateList;
        
    // }
    
    // static testMethod void createOfferingCategoriesTestPositiveScenario(){//test method for the scenario when there is no existing offering categories
        
    //     Intel_FormData formData = new Intel_FormData();
        
    //     List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
    //     List<Intel_SpecificationDataWrapper> catSubCat = new List<Intel_SpecificationDataWrapper>();
    //     List<Intel_SpecificationDataWrapper> industries = new List<Intel_SpecificationDataWrapper>();
    //     List<Intel_SpecificationDataWrapper> applications = new List<Intel_SpecificationDataWrapper>();
    //     Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeIndApp = new Map<String,List<Intel_SpecificationDataWrapper>>();
    //     Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeCat = new Map<String,List<Intel_SpecificationDataWrapper>>();
    //     Map<string,PMP_Category__c> categoryNameMap= New Map<string,PMP_Category__c>();
    //     List<PMP_Category__c> catList = ([Select id,PMP_Ancestor_Category_Cd__c, Name,
    //                                       PMP_Parent_Category_Id__c,Type__c,
    //                                       PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c, PMP_Partner_Product_Parent_Category_Cd__c,
    //                                       PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c, 
    //                                       PMP_Business_Segment_Nm__c from PMP_Category__c LIMIT 10]);
        
    //     string strCatList = '';
    //     for (PMP_Category__c cat : catList){
    //         categoryNameMap.put(cat.Name, cat);
    //         strCatList = strCatList+';'+cat.Id;
            
    //     }
        
        
    //     Intel_SpecificationDataWrapper specDataWrapper1 = new Intel_SpecificationDataWrapper();
    //     //specDataWrapper1.id = cat1.Id;
    //     specDataWrapper1.id = categoryNameMap.get('Test 1').id;
    //     catSubCat.add(specDataWrapper1);
    //     Intel_SpecificationDataWrapper specDataWrapper2 = new Intel_SpecificationDataWrapper();
    //     specDataWrapper2.id = categoryNameMap.get('Test 2').id; //cat2.Id;
    //     catSubCat.add(specDataWrapper2);
    //     Intel_SpecificationDataWrapper specDataWrapper3 = new Intel_SpecificationDataWrapper();
    //     specDataWrapper3.id = categoryNameMap.get('Test 3').id; //app1.Id;
    //     industries.add(specDataWrapper3);
    //     Intel_SpecificationDataWrapper specDataWrapper4 = new Intel_SpecificationDataWrapper();
    //     specDataWrapper4.id = categoryNameMap.get('Test 4').id; //ind1.Id;
    //     applications.add(specDataWrapper4);
    //     Intel_SpecificationDataWrapper specDataWrapper5 = new Intel_SpecificationDataWrapper();
    //     specDataWrapper5.id = categoryNameMap.get('Test 5').id; //ind2.Id;
    //     applications.add(specDataWrapper5);
        
    //     valueByTypeCat.put('Tab1DropdownRadioCombo', catSubCat);
    //     valueByTypeIndApp.put('industryValues', industries);
    //     valueByTypeIndApp.put('applicationValues', applications);
    //     formData.categoryAndSubCategory = valueByTypeCat;
    //     formData.industryAndApplication = valueByTypeIndApp;
        
    //     Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
    //     PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
    //     PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
    //     PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
    //     offCat2.Name = 'Categories';
    //     offCat2.PMP_Offering_Category_External_Key__c = 'NPP_01_TYPE';
    //     offCat2.PMP_Offering_Id__c = off1.Id;
    //     offCat2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|NPP_01_TYPE';
    //     offCat2.PMP_Category_Id__c = categoryNameMap.get('Categories').id;//cat0.Id;
        
        
    //     PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
    //     offCat4.Name = 'Industry';
    //     offCat4.PMP_Offering_Category_External_Key__c = System.Label.PMP_NPP_01_Industry;
    //     offCat4.PMP_Offering_Id__c = off1.Id;
    //     offCat4.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
    //     offCat4.PMP_Category_Id__c = categoryNameMap.get('Industry').id;//ind0.Id;
        
    //     PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Test 3', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us',false);
    //     app1.PMP_Parent_Category_Id__c = categoryNameMap.get(system.label.PMP_application).id; // value change from Application to Use Cases
        
    //     insert app1;
        
        
    //     PMP_Category__c app2 = [select id,Name,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Parent_Category_Cd__c,PMP_Active_Ind__c,PMP_Ancestor_Category_Cd__c from PMP_Category__c where id=:app1.Id];
    //     PMP_Partner_Offering_Category__c offCat5 = new PMP_Partner_Offering_Category__c();
    //     offCat5.Name = 'Test';
    //     offCat5.PMP_Offering_Category_External_Key__c = 'IPA_APP_ConnectedWorker';
    //     offCat5.PMP_Offering_Id__c = off1.Id;
    //     offCat5.PMP_Category_Id__c = app2.Id;
    //     offCat5.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        
    //     insertOffCategories.add(offCat2);
    //     insertOffCategories.add(offCat4);
    //     insertOffCategories.add(offCat5);
        
    //     insert insertOffCategories;
        
    //     strCatList = strCatList+';'+app1.Id;
    //     Test.startTest();
        
    //     PMP_OfferingCategoryHelper.createOfferingCategories(formData,off1,1,1);
    //     PMP_OfferingCategoryHelper.saveGetmCategories(strCatList,off1.Id,formData.industryAndApplication);
    //     Test.stopTest();
    //     System.assertNotEquals(app2.Id, null);
    // }
    
    // static testMethod void populateSpecificationDataWrapperTest(){
    //     test.startTest();
    //     List<PMP_Specification__c> specList = New List<PMP_Specification__c>();
    //     List<PMP_Specification_Value__c> specValList = New List<PMP_Specification_Value__c>();
    //     PMP_Specification__c spec1 = New PMP_Specification__c(name='Intel Technologies',
    //                                                         PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies',
    //                                                         PMP_Partner_Product_Specification_Key__c='npp_inteltechnologies');
    //     System.assertEquals( 'Intel Technologies',spec1.name,'Specification name not Matched');                                                   
    //     PMP_Specification__c spec2 = New PMP_Specification__c(name='End Customer Type',
    //                                                         PMP_Partner_Product_Specification_Id__c = 'NPP_EndCustomerType',
    //                                                         PMP_Partner_Product_Specification_Key__c='npp_endcustomertype');
    //     System.assertEquals('End Customer Type',spec2.name,'Specification name not Matched');
    //     PMP_Specification__c spec3 = New PMP_Specification__c(name='Displays',PMP_Partner_Product_Specification_Id__c = 'DisplaysLevel1',
    //                                                         PMP_Partner_Product_Specification_Key__c='displayslevel1');
    //     System.assertEquals( 'Displays',spec3.name,'Specification name not Matched');
    //     specList.add(spec1);
    //     specList.add(spec2);
    //     specList.add(spec3);
        
    //     PMP_Specification_Value__c specVal1 = New PMP_Specification_Value__c (Name='TestSpec', PMP_Product_Specification_Value_Cd__c='Test');
    //     PMP_Specification_Value__c specVal2 = New PMP_Specification_Value__c (Name='TestSpec12', PMP_Product_Specification_Value_Cd__c='Test21');
    //     PMP_Specification_Value__c specVal3 = New PMP_Specification_Value__c (Name='TestSpec132', PMP_Product_Specification_Value_Cd__c='Test23');
    //     specValList.add(specVal1);
    //     specValList.add(specVal2);
    //     specValList.add(specVal3);
        
    //     insert specList;
    //     insert specValList;
        
    //     Map<string, List<string>> specification_smplTab2 = New Map<string, List<string>>();
    //     List<string> specificaions = new List<string>{'TestSpec','TestSpec12','TestSpec132'};
    //     Map<string, string> specification_txtTab2 = New  Map<string, string> ();
    //     Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab2 = new Map<string, List<Intel_SpecificationDataWrapper>>();
        
    //     List<Intel_SpecificationDataWrapper> wrapperList = New List<Intel_SpecificationDataWrapper>();
    //     Intel_SpecificationDataWrapper specWrapper1 = New Intel_SpecificationDataWrapper();
    //     specWrapper1.id = specVal1.id+ '|'+spec1.id;
    //     Intel_SpecificationDataWrapper specWrapper2 = New Intel_SpecificationDataWrapper();
    //     specWrapper2.id = specVal3.id+ '|'+spec1.id;
    //     Intel_SpecificationDataWrapper specWrapper3 = New Intel_SpecificationDataWrapper();
    //     specWrapper3.id = spec1.id;
    //     wrapperList.add(specWrapper1);
    //     wrapperList.add(specWrapper2);
    //     wrapperList.add(specWrapper3);
    //     specification_cmplxTab2.put('NPP_IntelTechnologies',wrapperList);
    //     specification_smplTab2.put('Specifications',specificaions);
    //     PMP_OfferingCategoryHelper.populateSpecificationDataWrapper(specification_cmplxTab2,specification_smplTab2,specification_cmplxTab2);
        
        
    //     Intel_Dropdown dropDown = new Intel_Dropdown();
    //     dropDown.solutionOffering = true;
    //     test.stopTest();
    //     system.assertNotEquals(specWrapper3.id, null);
        
    // }
    
}