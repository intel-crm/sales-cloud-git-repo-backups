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
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Partner_Sort_By_Name_Asc',PMP_Value__c='Name ASC NULLS LAST'));
        
        insert stList;
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
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
        ind0.PMP_Partner_Product_Category_Key__c = 'npp_01_industry';
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
        
        PMP_Specification__c spec = new PMP_Specification__c();
        spec.name = 'test';
        spec.PMP_Specification_Name__c = 'test1';
        //spec.PMP_Partner_Product_Specification_Id__c = 'Test|Test1';
        spec.PMP_Partner_Product_Specification_Id__c = 'NPP|03|TYPE|Sys';
        insert spec;
        specList.add(spec);
        
        PMP_Specification__c spec1 = new PMP_Specification__c();
        spec1.name = 'test1';
        spec1.PMP_Specification_Name__c = 'test1';
        spec1.PMP_Parent_Specification_Id__c = spec.Id; 
        spec1.PMP_Mandatory_Offering_Category_Nm__c = 'All'; 
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP';
        //Spec1.Id = Spec.Id;
        insert spec1;
        specList.add(spec1);
        
       
/*
         ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        		        system.debug('cpTest value is:'+cpTest);

		
		PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        insert pbTest4;
        		        system.debug('pbTest4 value is:'+pbTest4);

       
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = testAccount.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        update abassociationTest2;
        system.debug('abassociationTest2 value is:'+abassociationTest2);*/




        //Topics Test Data
        list<Topic> listTopics = new List<Topic>();                                                                                 
        Topic topic = new Topic(Name='My Random Test Topic1');
        listTopics.add(topic);

        Topic topic2 = new Topic(Name='My Random Test Topic2');
        listTopics.add(topic2);
        insert listTopics;


        List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
        PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
        topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
        topicdata1.PMP_Is_Active_Ind__c = true;
        topicdata1.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
        topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
        topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
        topicdata2.PMP_Is_Active_Ind__c = true;
        topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
        topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        listTopicData.add(topicdata1);
        listTopicData.add(topicdata2);

        insert listTopicData;


    }
    
    @isTest static void getSelectedFiltersTest(){
        PMP_Category__c child = [SELECT id from PMP_Category__c where Name='Healthcare' limit 1];
        
        Test.startTest();
        PMP_SearchMarketplaceController.getSelectedFilters(child.id);
        system.assertNotEquals(null, PMP_SearchMarketplaceController.getSelectedFilters(child.id),'Failed');
        Test.stopTest();
    }
    
    @isTest static void getSelectedSpecificationFiltersTest(){
        PMP_Specification__c child = [SELECT id from PMP_Specification__c where Name='test1' limit 1];
        
        Test.startTest();
        PMP_SearchMarketplaceController.getSelectedFilters(child.id);
        //system.assertEquals(PMP_SearchMarketplaceController.getSelectedFilters(child.id), null,'Failed');
        Test.stopTest();
    } 
    
  /*  @isTest static void categorySearch_Test(){
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
    }*/
    
  /*  @isTest static void search_Test(){
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
    }*/
    
   /* @isTest static void searchAutoComplete_Test(){
        
        Test.startTest();
        String result = PMP_SearchMarketplaceController.searchAutoComplete('test','all', 'en_US');
        system.assert(String.isNotEmpty(result));
        Test.stopTest();
    }*/
    
    /*@isTest static void getSearchFilterDataTest(){
        
        Test.startTest();
        List<Option> result = PMP_SearchMarketplaceController.getSearchFilterData('product', 'en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }*/
    
    @isTest static void getPartnerDetailsTest(){
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
        system.assert(result != null,'Failed');
        Test.stopTest();
    }
    
    @isTest static void getPartnerArticlesTest(){
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);        
        PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
        
        Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyArticlesMock()); 
        Test.startTest();
        ArticleData result = PMP_SearchMarketplaceController.getPartnerArticles(partner.Id, 'en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }
    
    /*@isTest static void getFeaturedTabsTest(){
        
        Test.startTest();
        List<FeaturedProductTab> result = PMP_SearchMarketplaceController.getFeaturedTabs('en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }
    
    @isTest static void getCategoryDataTest(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getCategoryData('product','en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }
    
    @isTest static void getPartnerProgramsTest(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getPartnerPrograms('en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }
    
    @isTest static void getSpecialistGroupListDataTest(){
        
        Test.startTest();
        List<Listing> result = PMP_SearchMarketplaceController.getSpecialistGroupListData('partner','en_US');
        system.assert(result != null,'Failed');
        Test.stopTest();
    }*/
    
    /*@isTest static void fetchMultipleOfferings_Test(){
        List<String> offIds = new List<String>();
        Test.startTest();
      //  Map<String, String> result = PMP_SearchMarketplaceController.fetchMultipleOfferings(offIds,false,false,false,'en_US');/*Commented since this is not as part of WW22*//*
        Map<String, String> result = PMP_SearchMarketplaceController.fetchMultipleOfferings(offIds,false,false,false,'en_US');
        system.assert(result != null);
        Test.stopTest();
    }*/
    
    @isTest static void getUserInfoTest(){
        Test.startTest();
        String name=PMP_SearchMarketplaceController.getUserInfo(); 
        System.assert(name != '','Failed');
        Test.stopTest();
    }
    
   /* @isTest static void getFeaturedOfferingTest(){
        PMP_Category__c cat = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        
        Test.startTest();
        List<Product> result = PMP_SearchMarketplaceController.getFeaturedOfferings(cat.Id,null,null,'en_US'); 
        System.assert(result != null,'Failed');
        Test.stopTest();
    }*/
    
    /*@isTest static void getPromotionLanguageOptionsTest(){
        
        Test.startTest();
        
        List<Object> langs = PMP_SearchMarketplaceController.getPromotionLanguageOptions();
        
        Test.stopTest();
        
        system.assert(langs != null,'Failed');
    }*/
    
    /*@isTest static void getPromotionDataTest(){
        
        Test.startTest();
        
        List<Object> promos = PMP_SearchMarketplaceController.getPromotionData('en_US');
        
        Test.stopTest();
        
        system.assert(promos != null,'Failed');
    }*/
    
   /* @isTest static void getAllCategoriesTest(){
        
        Test.startTest();
        system.assertNotEquals(null,PMP_SearchMarketplaceController.getAllCategories('en_US'),'Failed');
        Test.stopTest();
  }*/
    
    @isTest static void getTabsTest()
    {
       
        Test.startTest();
        
        system.assertNotEquals(true,PMP_SearchMarketplaceController.isMarketingSpecialistAndOfferingEditor(),'Failed');//IPA 2.0 Offering EOL
        system.assertNotEquals(true,PMP_SearchMarketplaceController.isBasicProfileBenefitForOE(),'Failed');
        system.assertNotEquals(true,PMP_SearchMarketplaceController.isBasicProfileBenefit(),'Failed');
        system.assertNotEquals(false,PMP_SearchMarketplaceController.isMPAdmin(),'Failed');
        system.assertNotEquals(true,PMP_SearchMarketplaceController.isEmployee(),'Failed');
        system.assertNotEquals(false,PMP_SearchMarketplaceController.isLeadTabforAdminsAndLDR(),'Failed');
        
        Test.stopTest();
        
    }
    
    @isTest static void updatePartnerInfoTest() {
       
       
        
        Account acc = PMP_TestDataUtility.createIntelAccount('TestAccount', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con1 = PMP_TestDataUtility.createContact(acc.id,true);
        //system.debug('con1 ' + con1);
        Test.startTest();
        User adminUser = [Select Id, UserRoleId From User where Id=:userinfo.getUserId() Limit 1];
        System.runAs(adminUser){
        adminUser.UserRoleId = [Select Id, DeveloperName From UserRole where DeveloperName='Admin' Limit 1].Id;
        //system.debug('adminUser.UserRoleId ' +adminUser.UserRoleId);
        update adminUser;
        }
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Partner' Limit 1].Id;
		//system.debug('profileId ' + profileId); 
        //system.debug('adminUser ' + adminUser);
        System.runAs(adminUser){
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                Alias = 'jliv',
                                Email = 'jason3@gmail.com',
                                Username = 'testUser3'+String.valueOf(Math.random())+'@CoreMDF.com',
                                ProfileId = profileId, 
                                ContactId = con1.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'ja',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'ja'
                               );  
            insert usr; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Offering_Editor' Limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = usr.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
           
            Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
            Contact con2 = PMP_TestDataUtility.createContact(acc1.id,true);
            User usr2 = new User(LastName = 'LIVESTON2',
                                FirstName='JASON2',
                                Alias = 'jliv2',
                                Email = 'jason52@example.com',
                                Username = 'testUser32'+String.valueOf(Math.random())+'@CoreMDF.com',
                                ProfileId = profileId, 
                                ContactId = con2.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'ja',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'ja'
                               );  
            insert usr2; 
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'PRM_External_Employee' Limit 1];
            PermissionSetAssignment psa1 = new PermissionSetAssignment();
            psa1.AssigneeId = usr2.Id;
            psa1.PermissionSetId = ps1.Id;
            insert psa1;
            
        }
        User u =[Select Id from User where Email ='jason3@gmail.com' Limit 1];
        User u1 =[Select Id from User where Email ='jason52@example.com' Limit 1];
        //system.debug('User details:'+u);
       
        System.runAs(u){
            
        PMP_Company__c partner3=new PMP_Company__c();
        partner3.Name='Working copy';
        partner3.PMP_Benefit_Update_Ind__c=False;
        partner3.PMP_Partner_Inactive_Ind__c = False;
        partner3.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        partner3.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner3.PMP_Is_Published_Ind__c=true;
        insert partner3;
        
        PMP_Company__c partner4=new PMP_Company__c();
        partner4.Name='TestCompany11';
        partner4.PMP_Benefit_Update_Ind__c=False;
        partner4.PMP_Partner_Inactive_Ind__c = False;
        partner4.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        partner4.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner4.PMP_Is_Published_Ind__c=true;
        partner4.PMP_Working_Copy_Id__c=partner3.Id;
        insert partner4;
            
        system.assertNotEquals(NULL,PMP_SearchMarketplaceController.updatePartnerInfo(partner4.Id),'Failed');
        PMP_SearchMarketplaceController.checkValidPartner(partner4.Id);
       
    }
        system.runAs(u1){
        PMP_Company__c partner3=new PMP_Company__c();
        partner3.Name='Working copy';
        partner3.PMP_Benefit_Update_Ind__c=False;
        partner3.PMP_Partner_Inactive_Ind__c = False;
        partner3.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        partner3.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner3.PMP_Is_Published_Ind__c=false;
        insert partner3;
        
        PMP_Company__c partner4=new PMP_Company__c();
        partner4.Name='TestCompany11';
        partner4.PMP_Benefit_Update_Ind__c=False;
        partner4.PMP_Partner_Inactive_Ind__c = False;
        partner4.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        partner4.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner4.PMP_Is_Published_Ind__c=true;
        partner4.PMP_Working_Copy_Id__c=partner3.Id;
        insert partner4;
            
            PMP_SearchMarketplaceController.checkValidPartner(partner4.Id);
            PMP_SearchMarketplaceController.checkValidPartner(partner3.Id);
        }
        
        PMP_Company__c partner5=new PMP_Company__c();
        partner5.Name='Working copy1';
        partner5.PMP_Benefit_Update_Ind__c=False;
        partner5.PMP_Partner_Inactive_Ind__c = False;
        partner5.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //partner5.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        partner5.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner5.PMP_Is_Published_Ind__c=false;
        insert partner5;
        //system.debug('partner5 inserted-->'+partner5);
        
        PMP_Company__c partner6=new PMP_Company__c();
        partner6.Name='TestCompany111';
        partner6.PMP_Benefit_Update_Ind__c=False;
        partner6.PMP_Partner_Inactive_Ind__c = False;
        partner6.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //partner6.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        partner6.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        partner6.PMP_Is_Published_Ind__c=true;
        partner6.PMP_Working_Copy_Id__c=partner5.Id;
        insert partner6;
        PMP_SearchMarketplaceController.checkValidPartner(partner6.Id);
        partner6.PMP_Is_Published_Ind__c=False;
        update partner6;
        PMP_SearchMarketplaceController.checkValidPartner(partner6.Id);

        Test.stopTest();
  }

  /*static testMethod void getEventTopicType(){
    test.startTest();
    PMP_Marketplace_Topic__c tpData = [SELECT Id FROM PMP_Marketplace_Topic__c LIMIT 1];

    PMP_SearchMarketplaceController.getEventTopicType(String.valueOf(tpData.id));
    test.stopTest();
 }*/

/*static testMethod void getCloneImageToEvent(){
    test.startTest();
    PMP_Marketplace_Topic__c tpData = [SELECT Id FROM PMP_Marketplace_Topic__c LIMIT 1];

    PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c(Name='Test Event',PMP_Event_Banner_Language__c='English',
                                                                  
                                                                 PMP_Marketplace_Event_Tagline__c='tag',PMP_Marketplace_Event_Start_Dt__c=System.today(),
                                                                 PMP_Marketplace_Event_End_Dt__c=SYSTEM.today());
    insert event;
    tpData.PMP_Marketplace_Event_Id__c = event.id;

    update tpData;
    PMP_SearchMarketplaceController.getCloneImageToEvents(String.valueOf(tpData.id));
    test.stopTest();
 }*/
    
    /*static testMethod void getEventIdForTopics(){
    test.startTest();
    PMP_Marketplace_Topic__c tpData = [SELECT Id FROM PMP_Marketplace_Topic__c LIMIT 1];

    PMP_SearchMarketplaceController.getEventIdForTopics(String.valueOf(tpData.id));
    test.stopTest();
 }*/


}