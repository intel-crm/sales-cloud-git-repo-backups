@isTest
public class PMP_SearchUtilityNewTest extends PMP_SearchWrapperStore {
    /*@testSetup static void testSetUp(){
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
     
       
      
        stList.add(new PMP_Static_Constants__c(Name='PMP_Partner_Sort_By_Name_Asc',PMP_Value__c='Name ASC NULLS LAST'));
        
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
        //ContentDistribution cd = new ContentDistribution(name = 'cdTest', contentVersionId = cvId);
        //insert cd;
        //Id cdId = [select id from ContentDistribution].Id;
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        acc1.Core_Account_Type__c = 'Intel Approved Component Supplier (IACS);Intel Approved Device Supplier (IADS)';
        update acc1;
        Account acc2 = PMP_SearchTestDataFactory.createIntelAccount('OnePartnerAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'Distributor';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
       // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        cmp1.PMP_IPA_Badge_Tier_Txt__c='Gold';
        update cmp1;
        
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
        offering2.PMP_Offering_Language_Nm__c = 'English';
        upsert offering2;
        
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
        
       
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
        eve.PMP_Marketplace_Desc__c = 'desc';
        eve.PMP_Event_Banner_Language__c = 'English';        
        insert eve;
        
        PMP_Company__c comp = new PMP_Company__c();
        comp.Name = 'testCompany';
        comp.PMP_Account_Industry__c = 'Agriculture';
        comp.PMP_Company_Information_Language_Nm__c = PMP_StaticConstants_Partner.English;
        comp.PMP_Account_Dsc__c = 'test Desc';
        comp.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        comp.PMP_Account_Tag_Line__c = 'test tagline';
        //comp.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
        comp.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        comp.PMP_Partner_Segment_Nm__c = 'Client Computing';
        comp.PMP_Partner_Program_nm__c = 'Manufacturer';
       // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        insert comp;
        
            Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
       // Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
       // Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
       // User testUser = new User(UserRoleId  = ur.Id,Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                // EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                // LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                // TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
       // insert testUser;                                        
    //}
    

    // @isTest public static void testOfferingSectionScenarios(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     cmp1.PMP_IPA_Badge_Tier_Txt__c='Member';
    //     update cmp1;
        
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
        
    //     PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
    //     newPMPOfferingCat.Name='2-in-1';
    //     newPMPOfferingCat.PMP_Offering_Id__c=offering1.Id;
    //     newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
    //     newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
    //     newPMPOfferingCat.PMP_Category_Id__c = category.Id;
    //     insert newPMPOfferingCat;
        
    //     PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
    //     pp.Name = 'Manufacturer';
    //     pp.PMP_Is_Active_Ind__c = true;
    //     pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
    //     insert pp;
        
        
        
    //     List<String> listSt = new List<String>();
    //     listSt.add('OfferingCategories');
    //     Map<String, List<String>> mapFilter = new Map<String, List<String>>();
        
    //     mapFilter.put('name', listSt);
    //     mapFilter.put('PartnerTier', new List<String> {'Member'});
        
    //     SearchRequest req = new SearchRequest();
    //     req.keyword = 'Test';
    //     req.searchType = 'pmp-category';
    //     req.currentPage = 4;
    //     req.pageSize = 2;
    //     req.category =category.Id;
    //     req.filters = mapFilter;
    //     req.page =3;
    //     req.sortType= 'Name';
        
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.newSearch(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getResultCountsForFilters(JSON.serialize(req)),'FAILED');//getPartnerTierResults
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getPartnerRoleResults(new List<String> {pp.Id},new List<String> {offering1.Id},'pmp-category' ),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getPartnerTierResults(new List<String> {'Member'},new List<String> {offering1.Id},'pmp-category' ),'FAILED');

    //     Test.stopTest();
        
    // }
    
    // @isTest public static void testPartnerRoleSectionScenarios(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
        
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
        
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
       
    //     PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
    //     pp.Name = 'Manufacturer';
    //     pp.PMP_Is_Active_Ind__c = true;
    //     pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
    //     insert pp;
        
    //     PMP_Partner_Program__c pp1 = new PMP_Partner_Program__c();
    //     pp1.Name = 'Service Integrator';
    //     pp1.PMP_Is_Active_Ind__c = true;
    //     pp1.PMP_Partner_Program_Value_Txt__c = 'Service Integrator';
    //     insert pp1;
        
    //     PMP_Partner_Program__c pp2 = new PMP_Partner_Program__c();
    //     pp2.Name = 'Solution provider';
    //     pp2.PMP_Is_Active_Ind__c = true;
    //     pp2.PMP_Partner_Program_Value_Txt__c = 'Solution provider';
    //     pp2.PMP_Partner_Role_Parent_Id__c=pp1.Id;
    //     insert pp2;
        
        
        
    //     PMP_Partner_Specialty__c ps= new PMP_Partner_Specialty__c();
    //     ps.name='Cloud Data Center Specialist';
    //     ps.PMP_Is_Active_Ind__c=true;
    //     insert ps;
        
    //     PMP_Partner_Segment__c segment= new  PMP_Partner_Segment__c();
    //     segment.name='Client Computing';
    //     segment.PMP_Is_Active_Ind__c= true;
    //     segment.PMP_Partner_Segment_Value_Txt__c='Client Computing';
    //     insert segment;
        
    //     SearchRequest req = new SearchRequest();
    //     req.keyword = 'Test';        
    //     req.currentPage = 4;
    //     req.pageSize = 2;
    //     req.filters = new Map<String, List<String>>();
    //     req.page =3;
    //     req.sortType= 'SORT_BY_MOST_RECENT';
    //     //req.filters=
    //     req.filters.put('PartnerA-Z', new String[]{cmp1.Id});
    //     req.filters.put('PartnerSegments', new String[]{segment.Id});

    //     req.filters.put('PartnerSpecialties',new String[]{ps.Id});
    //     req.filters.put('PartnerTier',new String[]{'Member','Titanium'});
    //     req.filters.put('Solutions_Software_And_Services_Provider_Type',new String[]{pp1.Id});
        
    //     //Partner role
    //     req.searchType = 'pmp-partner-program';
    //     req.category = pp.Id;
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.newSearch(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getResultCountsForFilters(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.filterPartnersByRole(pp.Id,null ),'FAILED');
    //     Test.stopTest();     
        
    // }
    
    // @isTest public static void testPartnerIndustrySectionScenario(){
    //             Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
        
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
        
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
        
    //     PMP_Partner_Category__c pCat = new PMP_Partner_Category__c();
    //     pCat.PMP_Category_Id__c = category.Id;
    //     pCat.PMP_Partner_Id__c = cmp1.Id;
    //     insert pCat;
        
    //     PMP_Category_Partner__c pc = new PMP_Category_Partner__c();
    //     pc.Name = 'catPartner';
    //     pc.PMP_Category_Id__c = category.Id;
    //     insert pc;
        
    //     SearchRequest req = new SearchRequest();
    //     req.keyword = 'Test';        
    //     req.currentPage = 4;
    //     req.pageSize = 2;
    //     req.filters = new Map<String, List<String>>();
    //     req.page =3;
    //     req.sortType= 'Name';
        
        

    //     //Partner Industry
    //     req.searchType = 'pmp-partner-category';
    //     req.category = pc.Id;
    //    // system.assertNotEquals(null, PMP_SearchUtilityNew.newSearch(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getResultCountsForFilters(JSON.serialize(req)),'FAILED');

    //     Test.stopTest();
    // }
    
    // @isTest public static void testPartnerSpecialtyScenario(){
    //     Test.startTest();
    //    Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
        
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
        
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
        
    //     PMP_Partner_Specialty__c sp = new PMP_Partner_Specialty__c();
    //     sp.Name = 'Cloud Data Center Specialist';
    //     sp.PMP_Is_Active_Ind__c = true;
    //     insert sp;
        
    //     SearchRequest req = new SearchRequest();
    //     req.keyword = 'Test';        
    //     req.currentPage = 4;
    //     req.pageSize = 2;
    //     req.filters = new Map<String, List<String>>();
    //     req.page =3;
    //     req.sortType= 'Name';
        
        
        
    //     //Partner Specialty
    //     req.searchType = 'pmp-partner-specialty';
    //     req.category = sp.Id;
    //   //  system.assertNotEquals(null, PMP_SearchUtilityNew.newSearch(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getResultCountsForFilters(JSON.serialize(req)),'FAILED');

    //     Test.stopTest();
    // }
    
    // @isTest public static void testPartnerSegmentScenario(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
        
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
        
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
        
    //     PMP_Partner_Segment__c ps = new PMP_Partner_Segment__c();
    //     ps.Name = 'Client Computing';
    //     ps.PMP_Is_Active_Ind__c = true;
    //     ps.PMP_Partner_Segment_Value_Txt__c = 'Client Computing';
    //     insert ps;
        
    //     SearchRequest req = new SearchRequest();
    //     req.keyword = 'Test';        
    //     req.currentPage = 4;
    //     req.pageSize = 2;
    //     req.filters = new Map<String, List<String>>();
    //     req.page =3;
    //     req.sortType= 'Name';
        
        
        
    //     //Partner Specialty
    //     req.searchType = 'pmp-partner-segment';
    //     req.category = ps.Id;
    //    // system.assertNotEquals(null, PMP_SearchUtilityNew.newSearch(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.getResultCountsForFilters(JSON.serialize(req)),'FAILED');
    //     system.assertNotEquals(NULL,PMP_SearchUtilityNew.filterPartnersSeg(new List<String> {ps.Id}, new List<String> {cmp1.Id}, 'pmp-partner-segment'),'FAILED');

    //     //filterPartnersSeg

    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersOfferingCategory(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
    //     filters.put('OfferingCategories', new String[]{category.Id});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-partner-program'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersOfferingApplication(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
    //     filters.put('OfferingApplications', new String[]{category.Id});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersOfferingIndustry(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
    //     PMP_Category__c category = [SELECT id from PMP_Category__c where PMP_Partner_Product_Category_Cd__c = 'test1'];
    //     filters.put('OfferingIndustries', new String[]{category.Id});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersOfferingSpecialty(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //   //  cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
    //     PMP_Partner_Specialty__c sp = new PMP_Partner_Specialty__c();
    //     sp.Name = 'Cloud Data Center Specialist';
    //     sp.PMP_Is_Active_Ind__c = true;
    //     insert sp;
    //     filters.put('PartnerSpecialties', new String[]{sp.Id});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersOfferingSegment(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
        
    //     filters.put('OfferingSegments', new String[]{'Client Computing'});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, ''),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFilterPartnerRole(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
        
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(cmp1.Id);
    //      PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
    //     pp.Name = 'Manufacturer';
    //     pp.PMP_Is_Active_Ind__c = true;
    //     pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
    //     insert pp;
        
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
        
    //     List<String> off = new List<String>();
    //     off.add(offering1.Id);
        
    //     //Partner directory
    //     filters.put('PartnerDirectory', new String[]{pp.Id});
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-partner-program'),'FAILED'); 
    //     //system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(off, filters, 'pmp-category'),'FAILED'); 

        
    // //    system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(new String[]{cmp1.Id}, filters, 'pmp-category'));  
        
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFitersPartnerTier(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Account_Program_Membership__c = 'Manufacturer - Titanium';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
        
    //     filters.put('PartnerTier', new String[]{'Titanium'});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(new String[]{cmp1.Id}, filters, 'pmp-partner-program'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFilterEvents(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
    //     PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
    //     eve.Name='Test Event';
    //     eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
    //     eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
    //     eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
    //     eve.PMP_Marketplace_Desc__c = 'desc';
    //     eve.PMP_Event_Banner_Language__c = 'English';        
    //     insert eve;
    //     filters.put('IntelPartnerEvents', new String[]{eve.Id});
        
        
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(new String[]{cmp1.Id}, filters, 'pmp-partner-program'),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFilterPartnerAZ(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client computing';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //    // cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(offering1.Id);
         
    //     //Partner directory
    //     filters.put('PartnerA-Z', new String[]{cmp1.Id});
    //     filters.put('PartnerSegments', new String[]{'Client computing'});
     
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-category'),'FAILED');   
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, ''),'FAILED');
    //     Test.stopTest();
    // }
    
    // @isTest public static void testSelectedFiltersDisti(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
    //     acc1.Core_Account_Type__c = 'Intel Authorized Distributor (IAD)';
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Distributor';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client computing';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //     cmp1.PMP_Disti_Components_Nm__c = 'Data Center';
    //     //cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                                  'TestDuplicate',cmp1.Id, true,'Draft','');
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
    //     offering1.PMP_Offering_Status_Update_Dt__c = System.now();
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today();
    //     offering1.PMP_Business_Segment_Nm__c = 'Personal Computers';
    //     offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
    //     offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagsfsfsline';
    //     //offering1.PMP_Offering_Language_Nm__c = 'English';
    //     update offering1;
    //     Map<String, List<String>> filters = new Map<String, List<String>>();
    //     List<String> offIds = new List<String>();
    //     offIds.add(cmp1.Id);
         
    //     //Partner directory
    //     filters.put('Distributor', new String[]{'Intel Authorized Distributor (IAD)'});
    //     filters.put('DistributorComponents', new String[]{'Data Center'});
    //     filters.put('DistributorSystems&Solutions', new String[]{'Data Center'});
    //     filters.put('Country', new String[]{'USA'});
     
    //     system.assertNotEquals(null, PMP_SearchUtilityNew.filterOfferingsBySelectedFilters(offIds, filters, 'pmp-partner-program'),'FAILED');  
    //     system.assertNotEquals(null,PMP_SearchUtilityNew.getPartnerIndustries(new List<String>(), new List<String>(), ''),'FAILED');//getDistiSysSolutionResults
    //     system.assertNotEquals(null,PMP_SearchUtilityNew.getDistiComponentResults(new List<String>{'Data Center'}, new List<String> {cmp1.Id}),'FAILED');
    //     system.assertNotEquals(null,PMP_SearchUtilityNew.getDistiSysSolutionResults(new List<String>{'Client_Computing'}, new List<String> {cmp1.Id}),'FAILED');
    //     system.assertNotEquals(null,PMP_SearchUtilityNew.getDistiCountryResults(new List<String> {'USA'}, new List<String> {cmp1.Id}),'FAILED');

    //     Test.stopTest();
    // }

    // @isTest public static void testCheckIfDistiOrServiceProvider(){
    //     Test.startTest();
    //     Account acc1 = [SELECT id from Account where name= 'TestAccount1'];
        
    //     PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
    //     cmp1.PMP_Is_Published_Ind__c = true;
    //     cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
    //     cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
    //     cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    //     cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
    //     cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
    //   //  cmp1.PMP_Disti_Country_Coverage_Txt__c = 'USA';
    //     cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     update cmp1;

    //     PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
    //     pp.Name = 'Manufacturer';
    //     pp.PMP_Is_Active_Ind__c = true;
    //     pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
    //     insert pp;
        
    //     system.assertEquals('Manufacturer', PMP_SearchUtilityNew.checkIfDistiOrServiceProvider(pp.Id),'FAILED');
    //     Test.stopTest();
    // }
    
      @isTest public static void getPartnerTiertest(){
          List<PMP_Company__c> testAccount1= [select id , name from PMP_Company__c where name='TestAccount1' limit 1];
          String partnerId;
          if(testAccount1.size()>0){
              partnerId=testAccount1[0].Id;
          }
          Test.startTest();
    //      system.assertNotEquals(NULL, PMP_SearchUtilityNew.getPartnerTierResults(new List<String> {'Gold'},new List<String> {partnerId},'pmp'),'FAILED');
         PMP_SearchUtilityNew searchutil = new PMP_SearchUtilityNew();
          Test.stopTest();
     }
   */
    
}