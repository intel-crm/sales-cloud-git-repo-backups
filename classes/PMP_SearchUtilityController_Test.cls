@isTest
private class PMP_SearchUtilityController_Test extends PMP_SearchWrapperStore{
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
        insert stList;
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert cv;
        Id cvId = [select id from ContentVersion].Id; 
        ContentDistribution cd = new ContentDistribution(name = 'cdTest', contentVersionId = cvId);
        insert cd;
        Id cdId = [select id from ContentDistribution].Id;
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        update cmp1;
        
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
        
       
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.now();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        //offering1.PMP_Offering_Language_Nm__c = 'English';
        update offering1;
        
        PMP_Partner_Offering_Translation__c offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'chinese';
        offTrans.PMP_English_Txt__c = 'English';
        offTrans.PMP_Japanese_Txt__c = 'japanese';
        offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.TAGLINE;
        offTrans.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans;
        
        PMP_Partner_Offering__c offering2 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering2.PMP_Offering_Status_Update_Dt__c = System.now();
        offering2.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering2.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering2.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        //offering2.PMP_Offering_Language_Nm__c = 'English';
        //update offering2;
        
        offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'chinese';
        offTrans.PMP_English_Txt__c = 'English';
        offTrans.PMP_Japanese_Txt__c = 'japanese';
        offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.TAGLINE;
        offTrans.PMP_Partner_Offering_Id__c = offering2.Id;
        //insert offTrans;
        
        
        
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        offCategory.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test1';
        offCategory.PMP_Offering_Category_External_Key__c = 'test1'; 
        update offCategory;
        
        PMP_Category__c cat = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory.PMP_Category_Id__c];
        cat.PMP_Parent_Category_Id__c= cat0.id;
        cat.PMP_Partner_Product_Category_Cd__c = 'test1';
        update cat;
        
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering2.id);
        offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test2';
        offCategory2.PMP_Offering_Category_External_Key__c = 'test2'; 
        update offCategory2;
        
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= cat0.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'test2';
        update cat2;
        
        PMP_Company__c comp = new PMP_Company__c();
        comp.Name = 'testCompany';
        comp.PMP_Account_Industry__c = 'Agriculture';
        comp.PMP_Company_Information_Language_Nm__c = PMP_StaticConstants_Partner.English;
        comp.PMP_Account_Dsc__c = 'test Desc';
        comp.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        comp.PMP_Account_Tag_Line__c = 'test tagline';
        insert comp;
        
            Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert testUser;
        
    }
    
    @isTest static void searchAutoComplete_Test(){
        PMP_Partner_Offering__c off = [SELECT Id FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published' LIMIT 1];
        PMP_Partner_Offering_Translation__c transOff = new PMP_Partner_Offering_Translation__c();
        transOff.Name = 'test';
        transOff.PMP_English_Txt__c = 'test';
        transOff.PMP_Japanese_Txt__c = 'test';
        transOff.PMP_Chinese_Txt__c = 'test';
        transOff.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_NAME;
        transOff.PMP_Partner_Offering_Id__c = off.Id;
        insert transOff;
        
        PMP_Company__c comp = [SELECT Id FROM PMP_Company__c WHERE PMP_Is_Published_Ind__c = true LIMIT 1];
        
        PMP_Company_Translation__c transComp = new PMP_Company_Translation__c();
        transComp.Name = 'test';
        transComp.PMP_English_Txt__c = 'test';
        transComp.PMP_Japanese_Txt__c = 'test';
        transComp.PMP_Chinese_Txt__c = 'test';
        transComp.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Tagline;
        transComp.PMP_Company_Information_Id__c = comp.Id;
        insert transComp;
        
        Id [] fixedSearchResults= new Id[1];        
        fixedSearchResults.add(transOff.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        String res = PMP_SearchUtilityController.searchAutoComplete('test' , 'product','en_US');
        List<AutoCompleteOption> resAct = (List<AutoCompleteOption>)JSON.deserialize(res, List<AutoCompleteOption>.class);
        System.assertEquals(1, resAct.size());
        
        fixedSearchResults= new Id[1];          
        fixedSearchResults.add(transComp.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        
        res = PMP_SearchUtilityController.searchAutoComplete('test' , 'partner','en_US');
        resAct = (List<AutoCompleteOption>)JSON.deserialize(res, List<AutoCompleteOption>.class);
        System.assertEquals(1, resAct.size());
        
        fixedSearchResults= new Id[1];          
        fixedSearchResults.add(transOff.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        res = PMP_SearchUtilityController.searchAutoComplete('test' , 'all','en_US');
        resAct = (List<AutoCompleteOption>)JSON.deserialize(res, List<AutoCompleteOption>.class);
        System.assertEquals(1, resAct.size());
        
        Test.stopTest();
    }
    
    @isTest static void categorySearchTest(){
        String catId = [SELECT Id FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c = 'test1'].Id;
        Map<String,List<String>> filters = new Map<String,List<String>>();
        List<PMP_Category__c> category = [SELECT id FROM PMP_Category__c];
        List<String> catList = new List<String>();
        for (PMP_Category__c cat : category){
            catList.add(cat.id);
        }
        filters.put('Application',catList);
        filters.put('Industry',catList);
        SearchRequest sr = new SearchRequest();
        sr.keyword = 'test';
        sr.category = catId;
        sr.searchType = 'product';
        sr.selectedFilters = filters;
        sr.pageSize = 9;
        sr.currentPage = 1;
        Test.startTest();
        
        String res = PMP_SearchUtilityController.categorySearch(JSON.serialize(sr));
        CategorySearchResponse resAct = (CategorySearchResponse)JSON.deserialize(res, CategorySearchResponse.class);
        System.assertEquals(1, resAct.productCategories.size());
        
        sr.searchType = 'partner';
        res = PMP_SearchUtilityController.categorySearch(JSON.serialize(sr));
        resAct = (CategorySearchResponse)JSON.deserialize(res, CategorySearchResponse.class);
        
        System.assertNotEquals(null, resAct.partnerCategories.size());
        
        sr.searchType = 'all';
        res = PMP_SearchUtilityController.categorySearch(JSON.serialize(sr));
        resAct = (CategorySearchResponse)JSON.deserialize(res, CategorySearchResponse.class);
        
        System.assertNotEquals(null, resAct.partnerCategories.size());
        Test.stopTest(); 
        
    }   
    
    @isTest static void searchTest(){
        String catId = [SELECT Id FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c = 'test1'].Id;
        Map<String,List<String>> filters = new Map<String,List<String>>();
        List<PMP_Category__c> category = [SELECT id FROM PMP_Category__c];
        List<String> catList = new List<String>();
        for (PMP_Category__c cat : category){
            catList.add(cat.id);
        }
        
        PMP_Partner_Specialty__c specialty = new PMP_Partner_Specialty__c ();
        specialty.PMP_Is_Active_Ind__c = true;
        specialty.Name = 'test specialty';
        insert specialty ;
        
        filters.put('Application',catList);
        filters.put('Industry',catList);
        SearchRequest sr = new SearchRequest();
        sr.keyword = 'test';
        sr.category = catId;
        sr.searchType = 'product';
        sr.selectedFilters = filters;
        sr.pageSize = 9;
        sr.currentPage = 1;
        sr.sortField = 'Featured';
        sr.specialty = specialty.Id ;
        Test.startTest();
        
        String res = PMP_SearchUtilityController.search(JSON.serialize(sr));
        SearchResponse resAct = (SearchResponse)JSON.deserialize(res, SearchResponse.class);
        System.assertEquals(0, resAct.productResults.size());
        sr.sortField = 'PartnerDescending';
        sr.searchType = 'partner';
        res = PMP_SearchUtilityController.search(JSON.serialize(sr));
        resAct = (SearchResponse)JSON.deserialize(res, SearchResponse.class);
        System.assertEquals(0, resAct.partnerResults.size());
        
        sr.searchType = 'all';
        res = PMP_SearchUtilityController.search(JSON.serialize(sr));
        resAct = (SearchResponse)JSON.deserialize(res, SearchResponse.class);
        System.assertEquals(0, resAct.productResults.size());
        System.assertEquals(0, resAct.partnerResults.size());
        
        Test.stopTest();    
    }   
    
    @isTest
    static void isSamePartnerUserTest(){
         Test.startTest();
        Account acc3 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount3', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
        Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
        List<String> accList = new List<String>();
        accList.add(acc3.Id);
        accList.add(acc2.Id);
        
        Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
        pagMem.Core_Partner_Account_Id__c = acc3.Id;
        pagMem.Core_Intel_Account_Id__c = acc2.Id;
        insert pagMem;
        
       
        //PMP_SearchUtilityController.isSamePartnerUser(accList, false);
        
        system.assertNotEquals(PMP_SearchUtilityController.isSamePartnerUser(accList), null);
        
        Test.stopTest();
    }
    @isTest
    static void isSysAdminTest(){
        Test.startTest();
        PMP_SearchUtilityController.isSysAdmin();
        Test.stopTest();
        
    }
    
    @isTest
    static void getCompanyInfoTypeTest()
    {
     	Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
       /* cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        update cmp1; */
        Test.startTest();
        
        PMP_SearchUtilityController.getCompanyInfoType(cmp1);
        Test.stopTest();
    }
    @isTest
    static void isContactPartnerVisibleTest(){
        
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        
        List<PMP_Company__c> partners = new List<PMP_Company__c>();
        partners.add(partner);
        
        
        Test.startTest();
       // PMP_SearchUtilityController.isContactPartnerVisible(partners);
        system.assertNotEquals( PMP_SearchUtilityController.isContactPartnerVisible(partners), null);
        Test.stopTest();
    }
    
    @isTest
    static void getUserLocaleTest(){
        Test.startTest();
        System.assertNotEquals(PMP_SearchUtilityController.getUserLocale(),null);
        Test.stopTest();
    }
    
    @isTest
    static void getCategoryTreeTest(){
        Test.startTest();
       // PMP_SearchUtilityController.getCategoryTree('NPP_01_APP', true);
        System.assertNotEquals(PMP_SearchUtilityController.getCategoryTree('NPP_01_APP', true,'en_US'), null);
        Test.stopTest();
    }
    
    @isTest
    static void getLocalisedNameTest(){
        Test.startTest();
        PMP_Category__c cat = [SELECT id, Name from PMP_Category__c where Name='Component'];
        PMP_Partner_Offering__c off = [SELECT id, Name from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = 'TestDuplicateOffering1'];
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        
        PMP_Company_Translation__c compTrans = new PMP_Company_Translation__c();
        compTrans.Name = 'compTransTest';
        compTrans.PMP_Company_Information_Id__c = partner.Id;
        compTrans.PMP_Chinese_Txt__c = 'chinese';
        compTrans.PMP_Japanese_Txt__c = 'japanese';
        compTrans.PMP_English_Txt__c = 'english';
        compTrans.PMP_Field_Nm__c = 'Name';
        insert compTrans;    
        
        PMP_Specification__c spec = [SELECT id from PMP_Specification__c where Name='Geo1']; 
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.Name = 'Test';
        offCat.PMP_Category_Id__c = cat.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        offCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c, PMP_Category_Id__r.Name from PMP_Partner_Offering_Category__c where id=:offCat.Id];
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', ''), null) ;
        
        
        PMP_Partner_Category__c pCat = new PMP_Partner_Category__c();
        pCat.PMP_Category_Id__c = cat.Id;
        pCat.PMP_Partner_Id__c = partner.Id;
        insert pCat;
         pCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name from PMP_Partner_Category__c where id=:pCat.Id];
         PMP_SearchUtilityController.getLocalisedName(pCat, '', '');
        
        PMP_Partner_Offering_Specification__c offSpec = new PMP_Partner_Offering_Specification__c();
        offSpec.PMP_Specification_Id__c = spec.Id;
        offSpec.PMP_Offering_Id__c = off.Id;
        insert offSpec;
        offSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Partner_Offering_Specification__c where id=:offSpec.Id];
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
        cReg = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
       
        PMP_SearchUtilityController.getLocalisedName(offSpec, '', '');
        
         PMP_SearchUtilityController.getLocalisedName(spec, '', '');
        
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');
        
         PMP_SearchUtilityController.getLocalisedName(cReg, '', '');
        
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.PMP_Category_Id__c = cat.Id;
        catSpec.PMP_Specification_Id__c = spec.Id;
        insert catSpec;
        catSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Category_Specification_Association__c where id=:catSpec.Id];
       
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', '');
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        
        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
         PMP_SearchUtilityController.getLocalisedName(specVal, '', '');
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_English_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans, '', '');
        
        PMP_SearchUtilityController.getLocalisedName(compTrans, '', '');
        
        Test.stopTest();
    }
    
    @isTest
    static void getLocalisedNameTestChinese(){
          User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
                    
             user.LanguageLocaleKey = PMP_StaticConstants_Partner.ZH_CN;
             update user;
                             
        Test.startTest();
        PMP_Category__c cat = [SELECT id, Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c from PMP_Category__c where Name='Component'];
        cat.PMP_Category_Chinese_Nm__c = 'eeerer';
        cat.PMP_Category_Japanese_Nm__c = 'sdsd';
        update cat;
        PMP_Partner_Offering__c off = [SELECT id, Name from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = 'TestDuplicateOffering1'];
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        PMP_Specification__c spec = [SELECT id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c where Name='Geo1']; 
        
        PMP_Company_Translation__c compTrans = new PMP_Company_Translation__c();
        compTrans.Name = 'compTransTest';
        compTrans.PMP_Company_Information_Id__c = partner.Id;
        compTrans.PMP_Chinese_Txt__c = 'chinese';
        compTrans.PMP_Japanese_Txt__c = 'japanese';
        compTrans.PMP_English_Txt__c = 'english';
        compTrans.PMP_Field_Nm__c = 'Name';
        insert compTrans;
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.Name = 'Test';
        offCat.PMP_Category_Id__c = cat.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        offCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c, PMP_Category_Id__r.Name from PMP_Partner_Offering_Category__c where id=:offCat.Id];
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', ''), null);
        
        
        PMP_Partner_Category__c pCat = new PMP_Partner_Category__c();
        pCat.PMP_Category_Id__c = cat.Id;
        pCat.PMP_Partner_Id__c = partner.Id;
        insert pCat;
        pCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name from PMP_Partner_Category__c where id=:pCat.Id];
        
         PMP_SearchUtilityController.getLocalisedName(pCat, '', '');
        
        PMP_Partner_Offering_Specification__c offSpec = new PMP_Partner_Offering_Specification__c();
        offSpec.PMP_Specification_Id__c = spec.Id;
        offSpec.PMP_Offering_Id__c = off.Id;
        insert offSpec;
        offSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Partner_Offering_Specification__c where id=:offSpec.Id];
        
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
        cReg = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
        PMP_SearchUtilityController.getLocalisedName(offSpec, '', '');
        
         PMP_SearchUtilityController.getLocalisedName(spec, '', '');
        
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');
         PMP_SearchUtilityController.getLocalisedName(cReg, '', '');
        
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.PMP_Category_Id__c = cat.Id;
        catSpec.PMP_Specification_Id__c = spec.Id;
        insert catSpec;
        catSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Category_Specification_Association__c where id=:catSpec.Id];
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', '');
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        
        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
        
          PMP_SearchUtilityController.getLocalisedName(specVal, '', '');
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_Chinese_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans, '', '');
        PMP_SearchUtilityController.getLocalisedName(compTrans, '', '');
        Test.stopTest();
    }
    
     @isTest
    static void getLocalisedNameTestJapanese(){
          User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
                    
             user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
             update user;
                             
        Test.startTest();
        PMP_Category__c cat = [SELECT id, Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c from PMP_Category__c where Name='Component'];
        cat.PMP_Category_Chinese_Nm__c = 'eeerer';
        cat.PMP_Category_Japanese_Nm__c = 'sdsd';
        update cat;
        PMP_Partner_Offering__c off = [SELECT id, Name from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = 'TestDuplicateOffering1'];
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        PMP_Specification__c spec = [SELECT id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c where Name='Geo1']; 
        
        PMP_Company_Translation__c compTrans = new PMP_Company_Translation__c();
        compTrans.Name = 'compTransTest';
        compTrans.PMP_Company_Information_Id__c = partner.Id;
        compTrans.PMP_Chinese_Txt__c = 'chinese';
        compTrans.PMP_Japanese_Txt__c = 'japanese';
        compTrans.PMP_English_Txt__c = 'english';
        compTrans.PMP_Field_Nm__c = 'Name';
        insert compTrans;
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.Name = 'Test';
        offCat.PMP_Category_Id__c = cat.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        offCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c, PMP_Category_Id__r.Name from PMP_Partner_Offering_Category__c where id=:offCat.Id];
       
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', ''), null);
        
        
        PMP_Partner_Category__c pCat = new PMP_Partner_Category__c();
        pCat.PMP_Category_Id__c = cat.Id;
        pCat.PMP_Partner_Id__c = partner.Id;
        insert pCat;
        pCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name from PMP_Partner_Category__c where id=:pCat.Id];
         PMP_SearchUtilityController.getLocalisedName(pCat,'','');
        
        PMP_Partner_Offering_Specification__c offSpec = new PMP_Partner_Offering_Specification__c();
        offSpec.PMP_Specification_Id__c = spec.Id;
        offSpec.PMP_Offering_Id__c = off.Id;
        insert offSpec;
        offSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Partner_Offering_Specification__c where id=:offSpec.Id];
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
         cReg = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
        PMP_SearchUtilityController.getLocalisedName(offSpec,'','');
        
         PMP_SearchUtilityController.getLocalisedName(spec,'','');
        
        PMP_SearchUtilityController.getLocalisedName(cat,PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');        
         PMP_SearchUtilityController.getLocalisedName(cReg,'','');
        
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.PMP_Category_Id__c = cat.Id;
        catSpec.PMP_Specification_Id__c = spec.Id;
        insert catSpec;
        catSpec = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Category_Specification_Association__c where id=:catSpec.Id];
        PMP_SearchUtilityController.getLocalisedName(catSpec,'','');
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        
        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
         PMP_SearchUtilityController.getLocalisedName(specVal,'','');
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_Japanese_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans,'','');
        PMP_SearchUtilityController.getLocalisedName(compTrans,'','');
        Test.stopTest();
    }   


    
    @isTest
    static void getLanguageMessageTest(){
        Test.startTest();
            
        List<Options> langPref = new List<Options>();
        Options lang = new Options();
        lang.label = 'English';
        lang.value = 'English';
        lang.selected = true;
        langPref.add(lang);
        //PMP_SearchUtilityController.getLanguageMessage(langPref);
        System.assertNotEquals( PMP_SearchUtilityController.getLanguageMessage(langPref), null);
        Test.stopTest();
    }
    
     @isTest
    static void getLanguageMessageTwoLangTest(){
        Test.startTest();
            
        List<Options> langPref = new List<Options>();
        Options lang = new Options();
        lang.label = 'English';
        lang.value = 'English';
        lang.selected = true;
        Options lang2 = new Options();
        lang2.label = 'Simplified Chinese';
        lang2.value = 'Simplified Chinese';
        lang2.selected = true;
        langPref.add(lang);
        langPref.add(lang2);
        System.assertNotEquals( PMP_SearchUtilityController.getLanguageMessage(langPref), null);
        
        Test.stopTest();
    }
    
     @isTest
    static void getLanguageMessageThreeLangTest(){
        Test.startTest();
            
        List<Options> langPref = new List<Options>();
        
        PMP_SearchUtilityController.getLanguageMessage(langPref);
        
        Options lang = new Options();
        lang.label = 'English';
        lang.value = 'English';
        lang.selected = true;
        Options lang2 = new Options();
        lang2.label = 'Simplified Chinese';
        lang2.value = 'Simplified Chinese';
        lang2.selected = true;
        Options lang3 = new Options();
        lang3.label = 'Chinese';
        lang3.value = 'Chinese';
        lang3.selected = true;
        langPref.add(lang);
        langPref.add(lang2);
        langPref.add(lang3);
        System.assertNotEquals( PMP_SearchUtilityController.getLanguageMessage(langPref), null);
        
        Test.stopTest();
    }
    
   
    @isTest
    static void isIntelAdminTest(){
        
        PermissionSet ps = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.INTEL_ADMIN];
        
        User user = [SELECT id from User where FirstName='TestUtility'];
       
        PermissionSetAssignment perm = new PermissionSetAssignment();
        perm.AssigneeId = user.Id;
        perm.PermissionSetId = ps.Id;
        insert perm;
        
        
        Test.startTest();
        //PMP_SearchUtilityController.isIntelAdmin();
        System.assertNotEquals(PMP_SearchUtilityController.isIntelAdmin(), null);
        Test.stopTest();
    }
    
    @isTest
    static void getMdaIdTest(){
        Test.startTest();
        Account acc = [Select id from Account where name='OnePartnerAccount'];
        Account partnerAcc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount9', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
        
        
        
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name= 'testPartner';
        partner.PMP_One_Partner_ID__c=partnerAcc.Id;
        partner.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert partner;
         partner.PMP_Account_Id__c=acc.Id;
        update partner;
        
        system.assertNotEquals(null, PMP_SearchUtilityController.getMdaId(acc.Id));
        Test.stopTest();
        
        
    }
    
    @isTest
    static void escapeSoslTest(){
        String keyword = '?';
        String keyword1 = '*?';
        Test.startTest();
        PMP_SearchUtilityController.escapeSosl(keyword);
        PMP_SearchUtilityController.escapeSosl(keyword1);
        Test.stopTest();
    }
    
    @isTest
    static void isContactButtonVisibleTest(){
        Test.startTest();
        PMP_Company__c partner = [SELECT id,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Account_Id__c from PMP_Company__c where Name='TestCompany1' LIMIT 1];
        PMP_Partner_Offering__c offering = [SELECT id, PMP_Company_Id__r.PMP_Account_Id__c,PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Partner_Offering__c where PMP_Company_Id__r.Name = 'TestCompany1' LIMIT 1];
        
        PMP_SearchUtilityController.isContactButtonVisible(partner);
        PMP_SearchUtilityController.isContactButtonVisible(offering);
        
        Test.stopTest();
    }
   /* @isTest
    static void getCompanyInfoTypeTest() {
        Id pagRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();  
        Account intelAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',pagRecordTypeId , false);
       
        ChannelProgram cProg = new ChannelProgram(Name = 'Intel Partner Alliance');
        Database.insert(cProg);
        PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
                                                                                PRM_Benefit_Cd__c = 'SMEN',
                                                                                PRM_Channel_Program_Id__c = cProg.Id);
        Database.insert(prmPartnerBenefit);
            
        PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
                                                                PRM_Account_Id__c = intelAcc1.Id,
                                                                PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
                                                                PRM_Status_Nm__c = 'Active');
        Database.insert(prmAccBenefitAssoc);
        PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('Test', intelAcc1.id,true);
        test.startTest();
        string responseString = PMP_SearchUtilityController.getCompanyInfoType(companyInfo);
        test.stopTest();
        system.assertEquals(responseString , 'Profile');
        
    } */
}