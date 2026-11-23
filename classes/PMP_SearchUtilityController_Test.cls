/**
 * @description       : 
 * @author            : Balaji M
 * @group             : 
 * @last modified on  : 09-09-2020
 * @last modified by  : Balaji M
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   09-09-2020   Balaji M   Initial Version
**/
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
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
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
        Id cvId = [select id from ContentVersion limit 10].Id; 
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
        PMP_Company_Info_TriggerHandler.offeringSharingOpidRecursive = true;
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
        update cat2;/*
        
        PMP_Company__c comp = new PMP_Company__c();
        comp.Name = 'testCompany';
        comp.PMP_Account_Industry__c = 'Agriculture';
        comp.PMP_Company_Information_Language_Nm__c = PMP_StaticConstants_Partner.English;
        comp.PMP_Account_Dsc__c = 'test Desc';
        comp.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        comp.PMP_Account_Tag_Line__c = 'test tagline';
        insert comp;*/

      /*  Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        User user2 = new User(/**UserRoleId  = ur.Id,Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert user2;
        
        PermissionSet ps2 = [SELECT id, Name from PermissionSet where Name ='PMP_Internal_Intel_Read_Only'];
    
       
        PermissionSetAssignment perm2 = new PermissionSetAssignment();
        perm2.AssigneeId = user2.Id;
        perm2.PermissionSetId = ps2.Id;
        insert perm2;*/
        
        
          
        
    }
    
  /*  @isTest static void searchAutoComplete_Test(){
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
        System.assertEquals(0, resAct.size());
        
        fixedSearchResults= new Id[1];          
        fixedSearchResults.add(transOff.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        res = PMP_SearchUtilityController.searchAutoComplete('test' , 'all','en_US');
        resAct = (List<AutoCompleteOption>)JSON.deserialize(res, List<AutoCompleteOption>.class);
        System.assertEquals(1, resAct.size());
        
        Test.stopTest();
    }*/
    
  /*  @isTest static void categorySearchTest(){
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
//        System.assertEquals(1, resAct.productCategories.size());
        
        sr.searchType = 'partner';
        res = PMP_SearchUtilityController.categorySearch(JSON.serialize(sr));
        resAct = (CategorySearchResponse)JSON.deserialize(res, CategorySearchResponse.class);
        
        System.assertNotEquals(null, resAct.partnerCategories.size());
        
        sr.searchType = 'all';
        res = PMP_SearchUtilityController.categorySearch(JSON.serialize(sr));
        resAct = (CategorySearchResponse)JSON.deserialize(res, CategorySearchResponse.class);
        
        System.assertNotEquals(null, resAct.partnerCategories.size());
        Test.stopTest(); 
        
    }   */
    
    
 /*   @isTest static void searchTest(){
        String catId = [SELECT Id FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c = 'test1'].Id;
        Map<String,List<String>> filters = new Map<String,List<String>>();
        List<PMP_Category__c> category = [SELECT id FROM PMP_Category__c];
        List<String> catList = new List<String>();
        for (PMP_Category__c cat : category){
            catList.add(cat.id);
        }
        
        PMP_Partner_Specialty__c specialty = new PMP_Partner_Specialty__c ();
        specialty.PMP_Is_Active_Ind__c = true;
        specialty.Name = 'Device as a Service Specialist';
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
    }  */ 
    
    @isTest
    static void isSamePartnerUserTest(){
         Test.startTest();
        Account acc3 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount3', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
        Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        List<String> accList = new List<String>();
        accList.add(acc3.Id);
        accList.add(acc2.Id);
        
        Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
        pagMem.Core_Partner_Account_Id__c = acc3.Id;
        pagMem.Core_Intel_Account_Id__c = acc2.Id;
        insert pagMem;
       
        
//        PMP_SearchUtilityController.isSamePartnerUser(accL);
        
        system.assertNotEquals(PMP_SearchUtilityController.isSamePartnerUser(accList), null);
        
        Test.stopTest();
    }
    @isTest
    static void isSysAdminTest(){
        Test.startTest();
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];*/
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        User testUser = new User(/**UserRoleId  = ur.Id,*/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert testUser;
        Boolean isSysAdmin = false;
        isSysAdmin = PMP_SearchUtilityController.isSysAdmin();
        String assertMessage = 'Not a System Admin';
        System.assertEquals(isSysAdmin, true, assertMessage);
        Test.stopTest();
        
    }

     @isTest
    static void getCompanyInfoTypeTest(){
        // System.debug('===>1Limits:'+Limits.getQueries());
        // Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
       //    Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
         //  PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
          // PMP_Company__c cmp1 =[Select Id,Name,PMP_Company__c.PMP_Account_Id__c from PMP_Company__c Limit 1]; SHIVA COMMENTED THIS LINE.
          /* cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
           cmp1.PMP_Is_Published_Ind__c = true;
           cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
           cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
           cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
           update cmp1; */
           Test.startTest();
           prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
           rec.Name = 'ABA_Trigger';
           rec.inactive__c = false;
           insert rec;
           
           PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
           cust.Name='BatchFieldValues';
           cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
           cust.PRM_PartnerRole__c= 'Service Provider';
           cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
           insert cust;
           
           ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
           cpIPA.Name='Intel Partner Alliance';
           cpIPA.PRM_programCode__c='IPA';
           insert cpIPA;
   
           ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
           cplTitanium.Name='Titanium';
           cplTitanium.ProgramId=cpIPA.Id;
           insert cplTitanium;
           
           PMP_Static_Constants__c p = new PMP_Static_Constants__c();
           p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
           p.PMP_Value__c = 'BNFTSMBA';
           insert p;
   
           Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
           Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
           Account accObj = PMP_TestDataUtility.createIntelAccount('TestAccount',devRecordTypeId,true);
                   
           List<Account> accts = new List<Account>();
           Account newPagAccount = new Account();//Account
           newPagAccount.RecordTypeId = recordTypeIdPagAccount;
           newPagAccount.Name='Greg Thomas';
           newPagAccount.BillingCity='City';
           newPagAccount.BillingStreet='Street';
           newPagAccount.BillingCountry='India';
           newPagAccount.BillingPostalCode='Postal code';
           newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
           accts.add(newPagAccount);
           insert accts;
           
           PMP_Company__c company=new PMP_Company__c();
           company.Name=accObj.Name;
           //company.PMP_Account_Id__c=accObj.id;
           //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
           company.PMP_Benefit_Update_Ind__c=False;
           company.PMP_Partner_Inactive_Ind__c = False;
           company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
           //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
           company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
           company.PMP_Is_Published_Ind__c=true;
           company.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
           insert company;
           System.assertNotEquals(company, Null);
   
           // System.debug('===>1Limits:'+Limits.getQueries());
           PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                        'TestDuplicate',company.Id, true,'Draft','');
           offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
           offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
           offering1.PMP_Offering_Status_Update_Dt__c = System.now();
           offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
           offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
           offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
           //offering1.PMP_Offering_Language_Nm__c = 'English';
           update offering1;
           
           PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
           acm.PRM_Account_Id__c=newPagAccount.id;
           acm.PRM_Status_Nm__c='Approved';
           acm.PRM_Channel_Program_Id__c=cpIPA.Id;
           acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
           acm.PRM_Partner_Role__c='Service Provider';
           acm.PRM_Status_Reason_Txt__c='Test';
           insert acm;
           
          /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
           coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
           coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
           insert coreAccnt;*/
           
         PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
         pb.Name = 'Partner University';
         pb.PRM_Channel_Program_Id__c = cpIPA.id;
         pb.PRM_Benefit_Cd__c = PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE;
         pb.PRM_Account_Type_Nm__c = 'Both'; 
         insert pb;
        
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cpIPA.Id;
      insert pt;
        
      PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem2.PRM_Approval_Type_Nm__c='Automatic';
      bem2.PRM_Channel_Program_Id__c=cpIPA.Id;
      bem2.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
      bem2.PRM_Covered_Account_Ind__c=True;
      bem2.PRM_IsActive_Ind__c=True;
      bem2.PRM_Partner_Benefit_Id__c=pb.Id;
      bem2.PRM_Partner_Type_Id__c=pt.Id;
      bem2.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem2;
        
         // System.debug('===>1Limits:'+Limits.getQueries());
           PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
         aba.PRM_Account_Id__c = newPagAccount.Id;
         aba.PRM_Partner_Benefit_Id__c = pb.id;
         aba.PRM_Status_Nm__c = 'Active';
         aba.PRM_Status_Reason_Txt__c='Test';
         insert aba;
         // System.debug('===>1Limits:'+Limits.getQueries());
           PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
           jun.PMP_One_Partner_ID__c= newPagAccount.Id;
           jun.PMP_Marketing_Profile_Id__c= company.Id;
           jun.Is_Active__c=true;     
           insert jun;
           
           // System.debug('===>1Limits:'+Limits.getQueries());  
           String benefit = PMP_SearchUtilityController.getCompanyInfoType(company);
           String v1 = 'Storefront';
           String v2 = 'Profile';
           if(benefit != null && benefit !=''){
               System.assertEquals((benefit==v1 || benefit==v2) , true, 'benefit is not equals to Storefront or Profile '+benefit);
               
           
           }
           String newPagAccountId = newPagAccount.Id;
           PMP_SearchUtilityController.getMdaId(newPagAccountId);
           
           // For isContactPartnerVisible Method.
           // System.debug('===>1Limits:'+Limits.getQueries());
           List<PMP_Company__c> partners = new List<PMP_Company__c>();
           partners.add(company);
           
           system.assertNotEquals( PMP_SearchUtilityController.isContactPartnerVisible(partners), null);
           
           company.PMP_Is_Lead_Gen_Limited_Nm__c = 'False';
           update company;
           Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
           contactVisMap =PMP_SearchUtilityController.isContactPartnerVisible(new List<PMP_Company__c>{ company });
           
           //System.debug('===>1Limits:'+Limits.getQueries());
           // For isContactButtonVisible Method.
            
           
          
           Test.stopTest();
           // System.debug('===>1Limits:'+Limits.getQueries());
       
    

    }

    @isTest
    static void getCompanyInfoTypeTest1(){
        // System.debug('===>1Limits:'+Limits.getQueries());
        // Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
       //    Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
         //  PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
          // PMP_Company__c cmp1 =[Select Id,Name,PMP_Company__c.PMP_Account_Id__c from PMP_Company__c Limit 1]; SHIVA COMMENTED THIS LINE.
          /* cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
           cmp1.PMP_Is_Published_Ind__c = true;
           cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
           cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
           cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
           update cmp1; */
           Test.startTest();
           prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
           rec.Name = 'ABA_Trigger';
           rec.inactive__c = false;
           insert rec;
           
           PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
           cust.Name='BatchFieldValues';
           cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
           cust.PRM_PartnerRole__c= 'Service Provider';
           cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
           insert cust;
           
           ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
           cpIPA.Name='Intel Partner Alliance';
           cpIPA.PRM_programCode__c='IPA';
           insert cpIPA;
   
           ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
           cplTitanium.Name='Titanium';
           cplTitanium.ProgramId=cpIPA.Id;
           insert cplTitanium;
           
           PMP_Static_Constants__c p = new PMP_Static_Constants__c();
           p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
           p.PMP_Value__c = 'BNFTSMBA';
           insert p;
   
           Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
           Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
           Account accObj = PMP_TestDataUtility.createIntelAccount('TestAccount',devRecordTypeId,true);
                   
           List<Account> accts = new List<Account>();
           Account newPagAccount = new Account();//Account
           newPagAccount.RecordTypeId = recordTypeIdPagAccount;
           newPagAccount.Name='Greg Thomas';
           newPagAccount.BillingCity='City';
           newPagAccount.BillingStreet='Street';
           newPagAccount.BillingCountry='India';
           newPagAccount.BillingPostalCode='Postal code';
           newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
           accts.add(newPagAccount);
           insert accts;
           
           PMP_Company__c company=new PMP_Company__c();
           company.Name=accObj.Name;
           //company.PMP_Account_Id__c=accObj.id;
           //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
           company.PMP_Benefit_Update_Ind__c=False;
           company.PMP_Partner_Inactive_Ind__c = False;
           company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
           //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
           company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
           company.PMP_Is_Published_Ind__c=true;
           company.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
           insert company;
           System.assertNotEquals(company, Null);
   
           // System.debug('===>1Limits:'+Limits.getQueries());
           PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                        'TestDuplicate',company.Id, true,'Draft','');
           offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
           offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
           offering1.PMP_Offering_Status_Update_Dt__c = System.now();
           offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
           offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
           offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
           //offering1.PMP_Offering_Language_Nm__c = 'English';
           update offering1;
           
           PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
           acm.PRM_Account_Id__c=newPagAccount.id;
           acm.PRM_Status_Nm__c='Approved';
           acm.PRM_Channel_Program_Id__c=cpIPA.Id;
           acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
           acm.PRM_Partner_Role__c='Service Provider';
           acm.PRM_Status_Reason_Txt__c='Test';
           insert acm;
           
          /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
           coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
           coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
           insert coreAccnt;*/
           
       /*  PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
         pb.Name = 'Partner University';
         pb.PRM_Channel_Program_Id__c = cpIPA.id;
         pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
         pb.PRM_Account_Type_Nm__c = 'Both'; 
         insert pb;
        
         PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cpIPA.Id;
      insert pt;
        
      PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem2.PRM_Approval_Type_Nm__c='Automatic';
      bem2.PRM_Channel_Program_Id__c=cpIPA.Id;
      bem2.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
      bem2.PRM_Covered_Account_Ind__c=True;
      bem2.PRM_IsActive_Ind__c=True;
      bem2.PRM_Partner_Benefit_Id__c=pb.Id;
      bem2.PRM_Partner_Type_Id__c=pt.Id;
      bem2.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem2;
     
        
         System.debug('===>1Limits:'+Limits.getQueries());
           PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
         aba.PRM_Account_Id__c = newPagAccount.Id;
         aba.PRM_Partner_Benefit_Id__c = pb.id;
         aba.PRM_Status_Nm__c = 'Active';
         insert aba;*/
         // System.debug('===>1Limits:'+Limits.getQueries());
           PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
           jun.PMP_One_Partner_ID__c= newPagAccount.Id;
           jun.PMP_Marketing_Profile_Id__c= company.Id;
           jun.Is_Active__c=true;     
           insert jun;
           
           // System.debug('===>1Limits:'+Limits.getQueries());  
           String benefit = PMP_SearchUtilityController.getCompanyInfoType(company);
           String v1 = 'Storefront';
           String v2 = 'Profile';
           if(benefit != null && benefit !=''){
               System.assertEquals((benefit==v1 || benefit==v2) , true, 'benefit is not equals to Storefront or Profile '+benefit);
               
           
           }
           String newPagAccountId = newPagAccount.Id;
           PMP_SearchUtilityController.getMdaId(newPagAccountId);
           
           // System.debug('===>1Limits:'+Limits.getQueries());
           
           company.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
           update company;
           PMP_SearchUtilityController.isContactPartnerVisible(new List<PMP_Company__c>{ company });
           
        
           
          
           Test.stopTest();
           // System.debug('===>1Limits:'+Limits.getQueries());
       
    }
    
    @isTest
    static void getCompanyInfoTypeTest2()
    { // System.debug('===>1Limits:'+Limits.getQueries());
     // Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
    //    Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
      //  PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
       // PMP_Company__c cmp1 =[Select Id,Name,PMP_Company__c.PMP_Account_Id__c from PMP_Company__c Limit 1]; SHIVA COMMENTED THIS LINE.
       /* cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        update cmp1; */
        Test.startTest();
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('TestAccount',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        company.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        insert company;
        System.assertNotEquals(company, Null);

        // System.debug('===>1Limits:'+Limits.getQueries());
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                     'TestDuplicate',company.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.now();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        //offering1.PMP_Offering_Language_Nm__c = 'English';
        update offering1;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        
       /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;*/
        
     /* PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cpIPA.id;
      pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
      System.debug('===>1Limits:'+Limits.getQueries());
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newPagAccount.Id;
      aba.PRM_Partner_Benefit_Id__c = pb.id;
      aba.PRM_Status_Nm__c = 'Active';
      insert aba;*/
      // System.debug('===>1Limits:'+Limits.getQueries());
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        // For isContactButtonVisible Method.
         Boolean result = false;
        
        result = PMP_SearchUtilityController.isContactButtonVisible(company);
        PMP_Partner_Offering__c offering = [Select id,
                                            PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
                                            PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
                                            PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,
                                            PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
                                            PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,
                                            PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,PMP_Pre_Release_Check_Nm__c,PMP_Pre_Release_Item_Count_Num__c,
                                            PMP_Category_nm__c, PMP_Sub_Category_nm__c         
                                            from PMP_Partner_Offering__c where id = :offering1.Id];
        
        PMP_SearchUtilityController.isContactButtonVisible(offering);
        
        company.PMP_Is_Lead_Gen_Limited_Nm__c = 'False';
        update company;
        PMP_SearchUtilityController.isContactButtonVisible(company);
        PMP_Partner_Offering__c offering2 = [Select id,
                                            PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_End_Dt__c,PMP_Offering_Language_Nm__c,
                                            PMP_Partner_Offering_Id__c,PMP_Partner_Offering_Start_Dt__c,PMP_Offering_Status_Update_Dt__c,PMP_Translated_Languages__c,
                                            PMP_Partner_Revision_Comment_Txt__c,PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Working_Copy_Id__c,
                                            PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,Name,PMP_Partner_Offering_Nm__c,
                                            PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,
                                            PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Is_Notified_Ind__c,PMP_Pre_Release_Check_Nm__c,PMP_Pre_Release_Item_Count_Num__c,
                                            PMP_Category_nm__c, PMP_Sub_Category_nm__c         
                                            from PMP_Partner_Offering__c where id = :offering1.Id];
        PMP_SearchUtilityController.isContactButtonVisible(offering2);
        System.assertEquals(result, true, 'Contact  visiblity is false');
        
        // System.debug('===>1Limits:'+Limits.getQueries());
        Test.stopTest();
        // System.debug('===>1Limits:'+Limits.getQueries());
    }
   /* @isTest
    static void isContactPartnerVisibleTest(){
        
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        
        
        List<PMP_Company__c> partners = new List<PMP_Company__c>();
        partners.add(partner);
        
        Test.startTest();
        // PMP_SearchUtilityController.isContactPartnerVisible(partners);
        system.assertNotEquals( PMP_SearchUtilityController.isContactPartnerVisible(partners), null);
        
        partner.PMP_Is_Lead_Gen_Limited_Nm__c = 'False';
        update partner;
        Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
        contactVisMap =PMP_SearchUtilityController.isContactPartnerVisible(new List<PMP_Company__c>{ partner });
        
        partner.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        update partner;
        System.assertEquals(contactVisMap.size()>0, true, 'Contact Partner map is empty');
        PMP_SearchUtilityController.isContactPartnerVisible(new List<PMP_Company__c>{ partner });
        Test.stopTest();
    }*/
    
    @isTest
    static void getUserLocaleTest(){
               
        
        Test.startTest();
        System.assertNotEquals(PMP_SearchUtilityController.getUserLocale(),null);
        Test.stopTest();
    }
    
    @isTest
    static void getCategoryTreeTest(){
        
        Test.startTest();
        List<Option> ret  = new List<Option>();
        ret = PMP_SearchUtilityController.getCategoryTree('NPP_01_APP', true,'en_US');
        System.assertEquals(ret.size()>0, true, 'category tree map lessthan is empty');
        Test.stopTest(); 
    }
    
    @isTest
    static void getLocalisedNameTest(){
        Test.startTest();
        PMP_Category__c cat = [SELECT id, Name,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Nm__c,PMP_Category_Chinese_Dsc__c,PMP_Category_Japanese_Dsc__c, PMP_Category_Japanese_Nm__c from PMP_Category__c where Name='Component'];
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
        
        PMP_Partner_Segment__c partnerSegment = new PMP_Partner_Segment__c();
        partnerSegment.PMP_Partner_Segment_Value_Txt__c = 'compTransTest';
        partnerSegment.PMP_Partner_Segment_Japanese_Name_Txt__c='JAPNAME';
        partnerSegment.PMP_Partner_Segment_Chinese_Name_Txt__c='CHNNAME';
        partnerSegment.PMP_Partner_Segment_English_Dsc_Txt__c='ENGDESC';
        partnerSegment.PMP_Partner_Segment_Japanese_Dsc_Txt__c='JAPDESC';
        partnerSegment.PMP_Partner_Segment_Chinese_Dsc_Txt__c='CHNDESC';
        insert partnerSegment;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_NAME_FIELD, ''), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'en-US'), null) ; 
         System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN'), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'zh-CN'), null) ; 
          System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja'), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerSegment, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'ja'), null) ;
        PMP_Partner_Program__c partnerrole = new PMP_Partner_Program__c();
        partnerrole.PMP_Partner_Program_Value_Txt__c = 'compTransTest';
        partnerrole.PMP_Partner_Program_Name_Japanese__c='JAPNAME';
        partnerrole.PMP_Partner_Program_Name_Chinese__c='CHNNAME';
        partnerrole.PMP_Partner_Program_Desc__c='ENGDESC';
        partnerrole.PMP_Partner_Program_Desc_Japanese__c='JAPDESC';
        partnerrole.PMP_Partner_Program_Desc_Chinese__c='CHNDESC';
        insert partnerrole;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_NAME_FIELD, ''), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'en-US'), null) ; 
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN'), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'zh-CN'), null) ; 
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja'), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(partnerrole, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'ja'), null) ;
        
        PMP_Partner_Tier__c bizOrg = new PMP_Partner_Tier__c();
        bizOrg.PMP_Partner_Tier_Chinese_Nm__c = 'alsjhcl';
        bizOrg.PMP_Partner_Tier_Name_Japanese__c = 'aljaslkc';
        insert bizOrg;
        PMP_SearchUtilityController.getLocalisedName(bizOrg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        PMP_SearchUtilityController.getLocalisedName(bizOrg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(bizOrg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');

        
        
        PMP_Specification__c spec = [SELECT id from PMP_Specification__c where Name='Geo1']; 
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.Name = 'Test';
        offCat.PMP_Category_Id__c = cat.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        offCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c, PMP_Category_Id__r.Name from PMP_Partner_Offering_Category__c where id=:offCat.Id];
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', ''), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', 'zh_CN'), null) ;
        System.assertNotEquals(PMP_SearchUtilityController.getLocalisedName(offCat, '', 'ja'), null) ;
        
        
        
        PMP_Partner_Category__c pCat = new PMP_Partner_Category__c();
        pCat.PMP_Category_Id__c = cat.Id;
        pCat.PMP_Partner_Id__c = partner.Id;
        insert pCat;
         pCat = [SELECT PMP_Category_Id__r.PMP_Category_Chinese_Nm__c, PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name from PMP_Partner_Category__c where id=:pCat.Id];
         PMP_SearchUtilityController.getLocalisedName(pCat, '', '');
         PMP_SearchUtilityController.getLocalisedName(pCat, '', 'zh_CN');
         PMP_SearchUtilityController.getLocalisedName(pCat, '', 'ja');
        
        PMP_Partner_Offering_Specification__c offSpec = new PMP_Partner_Offering_Specification__c();
        offSpec.PMP_Specification_Id__c = spec.Id;
        offSpec.PMP_Offering_Id__c = off.Id;
        insert offSpec;
        offSpec = [SELECT Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Partner_Offering_Specification__c where id=:offSpec.Id];
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
        cReg = [SELECT Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
       
        PMP_SearchUtilityController.getLocalisedName(offSpec, '', '');
        
        // PMP_SearchUtilityController.getLocalisedName(spec, '', '');
        
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        //PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');
        // PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        //PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'zh_CN');
         //PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
       // PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'ja');
        
         PMP_SearchUtilityController.getLocalisedName(cReg, '', '');
        
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.PMP_Category_Id__c = cat.Id;
        catSpec.PMP_Specification_Id__c = spec.Id;
        insert catSpec;
        catSpec = [SELECT Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Category_Specification_Association__c where id=:catSpec.Id];
       
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', '');
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', 'ja');
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        
        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
        PMP_SearchUtilityController.getLocalisedName(specVal, '', '');
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_English_Txt__c,PMP_Chinese_Txt__c,PMP_Japanese_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
       // PMP_SearchUtilityController.getLocalisedName(offTrans, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        //PMP_SearchUtilityController.getLocalisedName(offTrans, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        
        PMP_SearchUtilityController.getLocalisedName(compTrans, '', '');
        //PMP_SearchUtilityController.getLocalisedName(compTrans, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
       // PMP_SearchUtilityController.getLocalisedName(compTrans, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        
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
        cat.PMP_Category_Chinese_Dsc__c = 'kajskjsbc';// shiva
        cat.PMP_Category_Japanese_Nm__c = 'sdsd';
        cat.PMP_Category_Japanese_Dsc__c = 'kjs';// shiva
        update cat;
        
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');// SHIVA
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'zh-CN');// SHIVA
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA
        //PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');// SHIVA
        cat.PMP_Partner_Offering_Category_Dsc__c = 'kasscn';
        update cat;
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');// SHIVA
        cat.PMP_Partner_Offering_Category_Dsc__c = '';
        update cat;
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');// SHIVA
        
        
        PMP_Partner_Offering__c off = [SELECT id, Name from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = 'TestDuplicateOffering1'];
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        PMP_Specification__c spec = [SELECT id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c where Name='Geo1']; 
        PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');// SHIVA 
        PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA
       
       
        
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
        PMP_SearchUtilityController.getLocalisedName(offSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');// SHIVA 
        PMP_SearchUtilityController.getLocalisedName(offSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA
        
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
        cReg = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
        PMP_SearchUtilityController.getLocalisedName(cReg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(cReg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA

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
        PMP_SearchUtilityController.getLocalisedName(catSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(catSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA
        PMP_SearchUtilityController.getLocalisedName(catSpec, '', '');
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        PMP_SearchUtilityController.getLocalisedName(sValue, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(sValue, '', '');
        

        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// SHIVA
          PMP_SearchUtilityController.getLocalisedName(specVal, '', '');
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_Chinese_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans, '', 'zh_CN');
        PMP_SearchUtilityController.getLocalisedName(compTrans, '', 'zh_CN');
        Test.stopTest();
    }
    
     @isTest
    static void getLocalisedNameTestJapanese(){
          User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
                    
             user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
             update user;
                             
        Test.startTest();
        PMP_Category__c cat = [SELECT id, Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Offering_Category_Dsc__c from PMP_Category__c where Name='Component'];
        cat.PMP_Category_Chinese_Nm__c = 'eeerer';
        cat.PMP_Category_Chinese_Dsc__c = 'kajskjsbc';// shiva
        cat.PMP_Category_Japanese_Nm__c = 'sdsd';
        cat.PMP_Category_Japanese_Dsc__c = 'kjs';// shiva
        update cat;
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');// JOYDEEP
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        //PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');
        
        PMP_Partner_Offering__c off = [SELECT id, Name from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = 'TestDuplicateOffering1'];
        PMP_Company__c partner = [SELECT id, PMP_Account_Id__c, Name, PMP_Is_Enabled_Lead_Gen_Nm__c, PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Company__c where Name='TestCompany1'];
        PMP_Specification__c spec = [SELECT id, Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c where Name='Geo1']; 
        PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// JOYDEEP
        
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
        
        PMP_SearchUtilityController.getLocalisedName(offSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(offSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// JOYDEEP
        
        PMP_Company_Region__c cReg = new PMP_Company_Region__c();
        cReg.PMP_Company_Id__c = partner.Id;
        cReg.PMP_Specification_Id__c = spec.Id;
        insert cReg;
         cReg = [SELECT PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Company_Region__c where id=:cReg.Id ];
       PMP_SearchUtilityController.getLocalisedName(cReg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(cReg, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// JOYDEEP
        
        PMP_SearchUtilityController.getLocalisedName(offSpec,'','');
        
         PMP_SearchUtilityController.getLocalisedName(spec,'','');
        
        PMP_SearchUtilityController.getLocalisedName(cat,PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
        PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, '');        
         PMP_SearchUtilityController.getLocalisedName(cReg,'','');
        
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.PMP_Category_Id__c = cat.Id;
        catSpec.PMP_Specification_Id__c = spec.Id;
        insert catSpec;
        catSpec = [SELECT Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.Name from PMP_Category_Specification_Association__c where id=:catSpec.Id];
        PMP_SearchUtilityController.getLocalisedName(catSpec,'','');
        PMP_SearchUtilityController.getLocalisedName(catSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(catSpec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// JOYDEEP
        
        PMP_Specification_Value__c sValue = PMP_SearchTestDataFactory.getSpecVals();
        PMP_SearchUtilityController.getLocalisedName(sValue, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        
        PMP_Specification_Value_Association__c specVal = new PMP_Specification_Value_Association__c();
        specVal.PMP_Specification_Id__c = spec.Id;
        specVal.PMP_Specification_Value_Id__c = sValue.Id;
        insert specVal;
        specVal = [SELECT Name,PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c, PMP_Specification_Value_Id__r.Name from PMP_Specification_Value_Association__c where id=:specVal.Id];
         PMP_SearchUtilityController.getLocalisedName(specVal,'','');
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'ja');
        PMP_SearchUtilityController.getLocalisedName(specVal, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');// JOYDEEP
        
        PMP_Partner_Offering_Translation__c offTrans = [SELECT id, name,PMP_English_Txt__c,PMP_Japanese_Txt__c from PMP_Partner_Offering_Translation__c where name = 'test'];
        PMP_SearchUtilityController.getLocalisedName(offTrans,'','ja');
        PMP_SearchUtilityController.getLocalisedName(compTrans,'','ja');
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
        
        List<Options> langPref1 = new List<Options>();
        Options lang1 = new Options();
        lang1.label = 'English';
        lang1.selected = true;
        langPref1.add(lang1);
        //PMP_SearchUtilityController.getLanguageMessage(langPref);
        System.assertNotEquals( PMP_SearchUtilityController.getLanguageMessage(langPref), null);
         System.assertNotEquals( PMP_SearchUtilityController.getLanguageMessage(langPref1), null);
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
      /* PermissionSet ps = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.INTEL_ADMIN];
   
        
        User user = [SELECT id from User where FirstName='TestUtility'];
       
        PermissionSetAssignment perm = new PermissionSetAssignment();
        perm.AssigneeId = user.Id;
        perm.PermissionSetId = ps.Id;
        insert perm;*/

         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        Test.startTest();
        User user2 = new User(/**UserRoleId  = ur.Id,*/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert user2;
        
       PermissionSet ps2 = [SELECT id, Name from PermissionSet where Name ='PMP_Internal_Intel_Read_Only'];
        
       // User user2 = [SELECT id from User where FirstName='TestUtility'];
       System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSetAssignment perm2 = new PermissionSetAssignment();
            perm2.AssigneeId = user2.Id;
            perm2.PermissionSetId = ps2.Id;
            insert perm2; 
        }
        
    
        
        system.runAs(user2){
            PMP_SearchUtilityController.isIntelAdmin();
            }
        System.assertNotEquals(PMP_SearchUtilityController.isIntelAdmin(), null);
        Test.stopTest();
    }
    
    @isTest
    static void isIntelAdminTest2(){
      /* PermissionSet ps = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.INTEL_ADMIN];
   
        
        User user = [SELECT id from User where FirstName='TestUtility'];
       
        PermissionSetAssignment perm = new PermissionSetAssignment();
        perm.AssigneeId = user.Id;
        perm.PermissionSetId = ps.Id;
        insert perm;*/

         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        Test.startTest();
        User user2 = new User(/**UserRoleId  = ur.Id,*/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert user2;
        
       PermissionSet ps2 = [SELECT id, Name from PermissionSet where Name ='PMP_Internal_Intel_Admin'];
        
       // User user2 = [SELECT id from User where FirstName='TestUtility'];
       System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSetAssignment perm2 = new PermissionSetAssignment();
            perm2.AssigneeId = user2.Id;
            perm2.PermissionSetId = ps2.Id;
            insert perm2; 
        }
        
    
        
        system.runAs(user2){
            PMP_SearchUtilityController.isIntelAdmin();
            }
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
        String keyword2 = 'Intel';
        Test.startTest();
        String escapedText = '';
        escapedText = PMP_SearchUtilityController.escapeSosl(keyword);
        System.assertEquals(!escapedText.contains(keyword), false, 'escapedText  contains escapeSequence'+escapedText);
        PMP_SearchUtilityController.escapeSosl(keyword1);
         PMP_SearchUtilityController.escapeSosl(keyword2);
        Test.stopTest();
    }
    
   /* @isTest
    static void isContactButtonVisibleTest(){
        Test.startTest();
        Boolean result = false;
        PMP_Company__c partner = [SELECT id,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Account_Id__c from PMP_Company__c where Name='TestCompany1' LIMIT 1];
        PMP_Partner_Offering__c offering = [SELECT id, PMP_Company_Id__r.PMP_Account_Id__c,PMP_Company_Id__r.PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Id__r.PMP_Is_Lead_Gen_Limited_Nm__c from PMP_Partner_Offering__c where PMP_Company_Id__r.Name = 'TestCompany1' LIMIT 1];
        
        result = PMP_SearchUtilityController.isContactButtonVisible(partner);
        PMP_SearchUtilityController.isContactButtonVisible(offering);
        System.assertEquals(result, true, 'Contact  visiblity is false');
        Test.stopTest();
    }*/
    
    @isTest
    static void getFieldApiNameTest(){
    
    PMP_Language_to_Field_API_Mapping__mdt dat = [SELECT PMP_Field_APINm__c,PMP_Language_Cd__c,PMP_Object_Nm__c,PMP_Field_Nm__c FROM PMP_Language_to_Field_API_Mapping__mdt LIMIT 1];
        
            Test.startTest();
            String fieldAPI ='';   
            fieldAPI = PMP_SearchUtilityController.getFieldApiName(dat.PMP_Object_Nm__c,dat.PMP_Field_Nm__c,dat.PMP_Language_Cd__c);
            PMP_SearchUtilityController.getFieldApiName(dat.PMP_Object_Nm__c,dat.PMP_Field_Nm__c,'en-US');
        PMP_SearchUtilityController.getFieldApiName(dat.PMP_Object_Nm__c,dat.PMP_Field_Nm__c,'zh-CN');
            System.assertEquals(fieldAPI != '', true, 'fieldAPI  is not empty');
            Test.stopTest();
    }
    
 /*   @isTest
    static void getPartnerTest(){
         PMP_Company__c part=[Select Id,Name from PMP_Company__c where PMP_Partner_Benefit_Type__c !=: PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access AND
                              PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published AND PMP_Benefit_Update_Ind__c=False LIMIT 1];  
                      
            Test.startTest();   
            PMP_SearchUtilityController.getPartner(part.Name,'partner','en_US');
            Test.stopTest();
         
    }
    
    
     @isTest
    static void getOfferingTest(){
        
        Test.startTest();
        PMP_SearchUtilityController.getOffering('Intel','searchType','en_US');
        Test.stopTest();
    }*/
    
    
    
    
    
    
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