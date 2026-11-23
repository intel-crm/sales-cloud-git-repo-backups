@isTest
public class PMP_SearchMarketplaceController_Test extends PMP_SearchWrapperStore {
    @testSetup static void setup(){
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st.PMP_Value__c = 'Name DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'BENEFIT_BASIC_PROFILE';
        st.PMP_Value__c = 'BFTMKTPLBC';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = ' IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP - All Intel Admin Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Partner_Sort_By_Name_Asc',PMP_Value__c='Name ASC NULLS LAST'));
        
        insert stList;
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat3 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','NPP_02_Comp', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        cat3.PMP_Parent_Category_Id__c = cat1.Id;
        
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        catList.add(cat3);
        update catList;  
        
        
        List<PMP_specification__c> specList = new List<PMP_Specification__c>();
        
        /*PMP_Specification__c specData = new PMP_Specification__c();
        specData.Name = 'Americas';
        specData.PMP_Parent_Specification_Id__c = '';
        specData.PMP_Partner_Product_Specification_Key__c = '';
        //specData.PMP_Ancestor_Specification_Cd__c = '';
        insert specData;
        specList.add(specData); */
        
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'test';
        Spec.PMP_Specification_Name__c = 'test1';
        Spec.PMP_Partner_Product_Specification_Id__c = 'Test|Test1';
        Spec.PMP_Partner_Product_Specification_Id__c = 'NPP|03|TYPE|Sys';
        insert Spec;
        specList.add(Spec);
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.name = 'test1';
        Spec1.PMP_Specification_Name__c = 'test1';
        Spec1.PMP_Parent_Specification_Id__c = Spec.Id; 
        Spec1.PMP_Mandatory_Offering_Category_Nm__c = 'All';  
        //Spec1.Id = Spec.Id;
        insert Spec1;
        specList.add(Spec1); 
    }
    
    @isTest static void getSelectedFiltersTest(){
        PMP_Category__c child = [SELECT id from PMP_Category__c where Name='Healthcare' limit 1];
        
        Test.startTest();
        system.assertNotEquals(PMP_SearchMarketplaceController.getSelectedFilters(child.id), null);
        Test.stopTest();
    }
    
    @isTest static void getSelectedSpecificationFiltersTest(){
        PMP_Specification__c child = [SELECT id from PMP_Specification__c where Name='test1' limit 1];
        
        Test.startTest();
        system.assertEquals(PMP_SearchMarketplaceController.getSelectedFilters(child.id), null);
        Test.stopTest();
    } 
    
    @isTest static void categorySearch_Test(){
        SearchRequest req = new SearchRequest();
        req.keyword = 'Test';
        req.searchType = 'all';
        req.currentPage = 0;
        req.pageSize = 9;
        req.selectedFilters = new Map<String, List<String>>();
        Test.startTest();
        String result = PMP_SearchMarketplaceController.categorySearch(JSON.serialize(req));
        system.assert(String.isNotEmpty(result));
        Test.stopTest();
    }
    
    @isTest static void search_Test(){
        SearchRequest req = new SearchRequest();
        req.keyword = 'Test';
        req.searchType = 'all';
        req.currentPage = 0;
        req.pageSize = 0;
        req.selectedFilters = new Map<String, List<String>>();
        Test.startTest();
        String result = PMP_SearchMarketplaceController.search(JSON.serialize(req));
        system.assert(String.isNotEmpty(result));
        Test.stopTest();
    }
    
    @isTest static void searchAutoComplete_Test(){
        
        Test.startTest();
        String result = PMP_SearchMarketplaceController.searchAutoComplete('test','all', 'en_US');
        system.assert(String.isNotEmpty(result));
        Test.stopTest();
    }
    
    @isTest static void getSearchFilterData_Test(){
        
        Test.startTest();
        List<Option> result = PMP_SearchMarketplaceController.getSearchFilterData('product', 'en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getPartnerDetails_Test(){
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        insert partner;
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec;
        
        Test.startTest();
        PartnerDetail result = PMP_SearchMarketplaceController.getPartnerDetails(partner.Id,'en_US');
        //system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getPartnerArticles_Test(){
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);        
        PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
        
        Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyArticlesMock()); 
        Test.startTest();
        ArticleData result = PMP_SearchMarketplaceController.getPartnerArticles(partner.Id, 'en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getFeaturedTabs_Test(){
        
        Test.startTest();
        List<FeaturedProductTab> result = PMP_SearchMarketplaceController.getFeaturedTabs('en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getCategoryData_Test(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getCategoryData('product','en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getPartnerPrograms_Test(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getPartnerPrograms('en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getSpecialistGroupListData_Test(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getSpecialistGroupListData('partner','en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void fetchMultipleOfferings_Test(){
        List<String> offIds = new List<String>();
        Test.startTest();
        Map<String, String> result = PMP_SearchMarketplaceController.fetchMultipleOfferings(offIds,false,false,false,'en_US');
        system.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getUserInfo_Test(){
        Test.startTest();
        String name=PMP_SearchMarketplaceController.getUserInfo(); 
        System.assert(name != '');
        Test.stopTest();
    }
    
    @isTest static void getFeaturedOffering_Test(){
        PMP_Category__c cat = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        
        Test.startTest();
        List<Product> result = PMP_SearchMarketplaceController.getFeaturedOfferings(cat.Id,null,null,'en_US'); 
        System.assert(result != null);
        Test.stopTest();
    }
    
    @isTest static void getPromotionLanguageOptions_Test(){
        
        Test.startTest();
        
        List<Object> langs = PMP_SearchMarketplaceController.getPromotionLanguageOptions();
        
        Test.stopTest();
        
        system.assert(langs != null);
    }
    
    @isTest static void getPromotionData_Test(){
        
        Test.startTest();
        
        List<Object> promos = PMP_SearchMarketplaceController.getPromotionData('en_US');
        
        Test.stopTest();
        
        system.assert(promos != null);
    }
    @isTest static void getTabs_Test()
    {
        Test.startTest();
        PMP_SearchMarketplaceController.isMarketingSpecialistAndOfferingEditor();
        PMP_SearchMarketplaceController.isBasicProfileBenefitForOE();
        PMP_SearchMarketplaceController.isBasicProfileBenefit();
        PMP_SearchMarketplaceController.isMPAdmin();
        PMP_SearchMarketplaceController.isEmployee();
        PMP_SearchMarketplaceController.isLeadTabforAdminsAndLDR();
       
        Test.stopTest();
        
    }
    
    @isTest static void updatePartnerInfo_Test() {
        
        PMP_Company__c partner1 = new PMP_Company__c(Name = 'Working copy');
        insert partner1;
        
        PMP_Company__c partner = new PMP_Company__c(Name = 'Test_Partner', PMP_Working_Copy_Id__c=partner1.Id);
        insert partner;
        
        Test.startTest();
        PMP_SearchMarketplaceController.updatePartnerInfo(partner.Id);
        Test.stopTest();
    }
}