@isTest
private class PMP_TaxonomyStore_Test {
    
    @testSetup static void testDataFactory(){
        //create the test account
        String accountRecordTypeId=PMP_SearchTestDataFactory.intel_Account_Record_Type;
        Account testAccount = new Account(Name = 'testAccount' , RecordTypeId = accountRecordTypeId,Core_Account_Type__c='Other',
                                          BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet');
        
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        
        //create the partner having account speciality
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        testPartner1.PMP_Account_Region__c = 'EMEA';
        testPartner1.PMP_Account_Sub_Region__c = 'TAIWAN';
        testPartner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        testPartner1.PMP_Account_Industry__c = 'Energy';
        testPartner1.PMP_Account_Application__c = 'Storage';
        testPartner1.PMP_Partner_Program_nm__c = 'Cloud & Comms Service Provider;ODM-LOEM;Distributor';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        testPartner1.PMP_Disti_Country_Coverage_Txt__c='USA;India';
        testPartner1.PMP_Partner_Segment_Nm__c='Client Computing';
        testPartner1.PMP_Benefit_Update_Ind__c=False;
        insert testPartner1;
        
        
        //create speciality that the partner belongs to
        PMP_Partner_Specialty__c ps= new PMP_Partner_Specialty__c();
        ps.name='Artificial Intelligence Specialist';
        ps.PMP_Is_Active_Ind__c= true;
        ps.PMP_Partner_Specialty_English_Dsc__c='Description';
        insert ps;
        
        
        //create the partner segment records
        PMP_Partner_Segment__c partnerSegment= new PMP_Partner_Segment__c();
        partnerSegment.Name='Client Computing';
        partnerSegment.PMP_Partner_Segment_Value_Txt__c='Client Computing';
        partnerSegment.PMP_Is_Active_Ind__c=true;
        insert partnerSegment;
       
        //Create MP Event
        PMP_Marketplace_Event__c mpEvent= new PMP_Marketplace_Event__c();
        mpEvent.Name='Intel MP Event';
        mpEvent.PMP_Marketplace_Event_Start_Dt__c=System.now();
        mpEvent.PMP_Marketplace_Event_End_Dt__c=System.now()+1;
        insert mpEvent;
        
        
        PMP_Specification__c spec = new PMP_Specification__c();
        spec.name= 'Other Processors';
        spec.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors';
        spec.PMP_Active_Ind__c=true;
        spec.PMP_Partner_Product_Specification_Id__c = '122309';
        insert spec;
        
        PMP_Specification__c spec1 = new PMP_Specification__c();
        spec1.name= 'Processors';
        spec1.PMP_Active_Ind__c=TRUE;
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_Processors';
        insert spec1;
        
        spec.PMP_Parent_Specification_Id__c=spec1.Id;
        update spec;
        
        PMP_Partner_Program__c partProg = new PMP_Partner_Program__c();
        partProg.Name ='Distributor';
        partProg.PMP_Is_Active_Ind__c = true;
        partProg.PMP_Partner_Program_Value_Txt__c ='Distributor';
        insert partProg;
        
        PMP_Partner_Program__c partProg2 = new PMP_Partner_Program__c();
        partProg2.Name ='Solution, Software, and Service Providers';
        partProg2.PMP_Is_Active_Ind__c = true;
        partProg2.PMP_Partner_Program_Value_Txt__c ='Solution, Software, and Service Providers';
        insert partProg2;
        
        PMP_Partner_Program__c partProg1 = new PMP_Partner_Program__c();
        partProg1.Name ='Cloud & Comms Service Provider';
        partProg1.PMP_Is_Active_Ind__c = true;
        partProg1.PMP_Partner_Program_Value_Txt__c ='Cloud & Comms Service Provider';
        partProg1.PMP_Partner_Role_Parent_Id__c =partProg2.id;
        insert partProg1;  
        
        //PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        //PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        //PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        //cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        app0.PMP_Active_Ind__c=true;
        ind0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Active_Ind__c=true;
        
        //cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        app1.PMP_Active_Ind__c=true;
        
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        ind1.PMP_Active_Ind__c=true;
        
        app2.PMP_Parent_Category_Id__c = app1.Id;
        app2.PMP_Active_Ind__c=true;

        //ind2.PMP_Parent_Category_Id__c = ind1.Id;
       
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        catList.add(app0);
        catList.add(ind0);
        catList.add(app1);
        
        catList.add(ind1);
        catList.add(app2);
        update catList;
        
        PMP_Category__c category= new PMP_Category__c();
        category.PMP_Active_Ind__c=true;
        category.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
        category.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_APP';
        //category.PMP_Ancestor_Category_Cd__c='NPP_01_APP';
        category.Name='Robotic Process Automation';
        
        
        /*PMP_Category__c category= new PMP_Category__c();
        category.PMP_Active_Ind__c=true;
        category.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
        category.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_APP';
        //category.PMP_Ancestor_Category_Cd__c='NPP_01_APP';
        category.Name='Robotic Process Automation'; */
        insert category;
                              
        
        //create offering
        PMP_Partner_Offering__c offering= new PMP_Partner_Offering__c();
        offering.Name='test publish';
        offering.PMP_Company_Id__c=testPartner1.Id;
        offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        //offering.PMP_Business_Segment_Nm__c='IoT;Server;Personal Computers';
        insert offering;
        
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='2-in-1';
        newPMPOfferingCat.PMP_Offering_Id__c=offering.Id;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
        newPMPOfferingCat.PMP_Category_Id__c = app1.Id;
        insert newPMPOfferingCat;
        
        PMP_Partner_Tier__c partnerTierval = new PMP_Partner_Tier__c ();
        partnerTierval.Name ='Gold';
        partnerTierval.PMP_Is_Biz_Org_Type_Ind__c = false;
        //partnerTierval.PMP_Partner_Program_Value_Txt__c ='Solution, Software, and Service Providers';
        insert partnerTierval;
        
        PMP_Partner_Tier__c partnerBizorg = new PMP_Partner_Tier__c ();
        partnerBizorg.Name ='Intel Authorized Distributor (IAD)';
        partnerBizorg.PMP_Is_Biz_Org_Type_Ind__c = true;
        //partnerTierval.PMP_Partner_Program_Value_Txt__c ='Solution, Software, and Service Providers';
        insert partnerBizorg;
        
        
        //spec value
        PMP_Specification_Value__c specVal= New PMP_Specification_Value__c();
        specVal.Name = 'DDR3';
        specVal.PMP_Specification_Value_Chinese_Cd__c = 'DDR3';
        specVal.PMP_Specification_Value_Japanese_Cd__c = 'DDR3';
        specVal.PMP_Specification_Value_Nm__c = 'DDR3';
        specVal.PMP_Specification_Product_Cd__c= 'NPP_Processors';
        specVal.PMP_Active_Ind__c = true;
        insert specVal;
        
        PMP_Specification_Value__c specVal1= New PMP_Specification_Value__c();
        specVal1.Name = 'Distiller';
        specVal1.PMP_Specification_Value_Chinese_Cd__c = 'Distiller';
        specVal1.PMP_Specification_Value_Japanese_Cd__c = 'Distiller';
        specVal1.PMP_Specification_Value_Nm__c = 'Distiller';
        specVal1.PMP_Specification_Product_Cd__c= '122309';
        specVal1.PMP_Active_Ind__c = true;
        insert specVal1;
        
        PMP_Specification_Value__c specVal2= New PMP_Specification_Value__c();
        specVal2.Name = 'WIFI';
        specVal2.PMP_Specification_Value_Chinese_Cd__c = 'WIFI';
        specVal2.PMP_Specification_Value_Japanese_Cd__c = 'WIFI';
        specVal2.PMP_Specification_Value_Nm__c = 'WIFI';
        specVal2.PMP_Specification_Product_Cd__c= '122309';
        specVal2.PMP_Active_Ind__c = true;
        insert specVal2;        
                        
    }
    

    // below methods are WIP    
  /*  @isTest
    public static void fetchTaxonomyTest(){
        test.startTest();
        try 
        {
        String params = '{"baseTaxonomy":true,"langCode":"en-US"}';
        system.assertNotEquals(NULL,PMP_TaxonomyStore.fetchTaxonomy(params),'Test failed');
        params = '{"baseTaxonomy":false,"langCode":"en-US"}';
        system.assertNotEquals(NULL,PMP_TaxonomyStore.fetchTaxonomy(params),'Test failed');
        params = '{"baseTaxonomy":false,"langCode":"zh-Hans-CN"}';
        system.assertNotEquals(NULL,PMP_TaxonomyStore.fetchTaxonomy(params),'Test failed');
        
        } catch(Exception e) {
            System.debug('Error occured');
        }
        test.stopTest();
    } */   
     
  /*  @isTest
    public static void   getTaxonomyRecordTest(){
        List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Program_nm__c from PMP_Company__c where name='testPartner1'];
        String label='Test record';
        String viewAllLabel= 'View All Test records';
        String recId=String.valueOf(testPartner1[0].Id);
        List<String> children= new List<String>();
        String icon='';
        String parentId= null;
        String taxonomyName='PartnerDirectory';
        String description='Test Description';
        Boolean isFeatured=false;
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getTaxonomyRecord(label,label,viewAllLabel,recId,children,icon,parentId,taxonomyName,description,isFeatured),'Test Failed');
        test.stopTest();
        
        
    }
    
  
    @isTest
    public static void   getOfferingSegmentContextualFiltersTest(){
        String langCode='en_US';
        
        test.startTest();
            System.assertNotEquals(NULL,PMP_TaxonomyStore.getOfferingSegmentContextualFilters(langCode,'OfferingSegments'),'Test failed');
        test.stopTest();
        
    }
    
    @isTest
    public static void   getMarketplaceEventsTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getMarketplaceEvents('IntelPartnerEvents','PMP_Marketplace_Event__c'),'Test failed');
        test.stopTest();
        
    }

    @isTest
    public static void  getPartnertierFiltersTest(){
        
        String langCode='en_US';
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnertierFilters(langCode,'PartnerTier'),'Test failed');
        test.stopTest();
        
    }
    
  
    @isTest
    public static void  getPartnerSegmentFiltersTest(){
        List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Program_nm__c,PMP_Account_Specialty__c,PMP_Partner_Segment_Nm__c  from PMP_Company__c where name='testPartner1'];

        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerSegmentFilters('en_US','PartnerSegments',testPartner1), 'Test failed') ;
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerSegmentFilters('ja','PartnerSegments',testPartner1), 'Test failed') ;
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerSegmentFilters('zh-Hans-CN','PartnerSegments',testPartner1), 'Test failed') ;
        test.stopTest();
    }  
    
  
    @isTest
    public static void  fetchSearchFilterGroupingsTest(){
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.fetchSearchFilterGroupings('PartnerSegments'), 'Test failed');
        system.assertNotEquals(NULL,PMP_TaxonomyStore.fetchSearchFilterGroupings('PartnerDirectory'), 'Test failed');
        test.stopTest();
        
        
    }
  
    @isTest
    public static void  getpartnerSpecialtiesTest(){
        //27k fix start
        List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Program_nm__c,PMP_Account_Specialty__c  from PMP_Company__c where name='testPartner1'];
        //27k fix end
        String langCode='en_US';
        test.startTest();
        System.assertNotEquals(NULL,PMP_TaxonomyStore.getpartnerSpecialties(langCode,'PartnerSpecialties',testPartner1), 'Test failed');
        test.stopTest();
        
    }
    
    @isTest
    public static void  getPartnerIndustriesTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerIndustries('en_US','PartnerIndustries'), 'Test failed');
        test.stopTest();   
    }
    
     @isTest
    public static void  getPartnerAPplicationsTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerApplications('en_US','PartnerApplications'), 'Test failed');
        test.stopTest();   
    }
    
    @isTest
    public static void  getPartnerContextualFiltersTest(){
        //List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c from PMP_Company__c where name='testPartner1'];
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerContextualFilters('en_US','PartnerIndustries'), 'Test failed');
        test.stopTest();   
    }
    
    
    @isTest
    public static void  getDistiBizOrgTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getDistiBizOrg('en_US','Distributor'),'Test failed');
        test.stopTest();   
    }
    
     
    @isTest
    public static void  getDistiComponentsTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getDistiComponents('en_US','DistributorComponents'), 'Test failed');
        test.stopTest();   
    }
    
     
    @isTest
    public static void  getDistiCountriesTest(){
       // List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c from PMP_Company__c where name='testPartner1'];
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getDistiCountries('en_US','Country'),'Test failed');
        test.stopTest();   
    }
    
    
    @isTest
    public static void  getDistiSysSolutionsTest(){
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getDistiSysSolutions('en_US','DistributorSystems&Solutions'),'Test failed');
        test.stopTest();   
    }
    //getPartnerRoles
    
       @isTest
    public static void  getPartnerRolesTest(){
        test.startTest();
        //27k fix
        List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Program_nm__c from PMP_Company__c where name='testPartner1'];
        //27k fix end
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerRoles('en_US','PartnerDirectory',testPartner1), 'Test failed');
        test.stopTest();   
    }
    
    
     @isTest
    public static void  getServicesProviderTypeRolesTest(){
        //List<PMP_Company__c> testPartner1= [select id, name,PMP_Disti_Country_Coverage_Txt__c,PMP_Partner_Program_nm__c from PMP_Company__c where name='testPartner1'];
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getServicesProviderTypeRoles('en_US','Solutions_Software_And_Services_Provider_Type'), 'Test failed');
        test.stopTest();   
    }
    
    //getOfferingCategoryTaxonomy 
    @isTest
    public static void  getOfferingCategoryTaxonomyTest(){
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getOfferingCategoryTaxonomy('en_US','offeringApplications'), 'Test failed');
        test.stopTest();   
    }
    
    //getTechnicalSpecsTaxonomy
    @isTest
    public static void  getTechnicalSpecsTaxonomyTest(){
        test.startTest();
        try 
        {
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getTechnicalSpecsTaxonomy('en_US'),'Test failed');
        } catch(Exception e) {
            System.debug('Error occured');
        }
        test.stopTest();   
    }
    
    @isTest
    public static void  getPartnerIndustriesTest2(){
        
        PMP_Category__c cattt= new PMP_Category__c();
        cattt.PMP_Active_Ind__c=true;
        cattt.PMP_Partner_Product_Category_Cd__c='NPP_01_Industry';
        cattt.PMP_Partner_Product_Category_Key__c = 'npp_01_industry';
        cattt.PMP_Partner_Product_Parent_Category_Cd__c  ='Solution_Marketplace_Hierarchy';
        cattt.Name='Industry';
        insert cattt;
        
        PMP_Category__c cattt1= new PMP_Category__c();
        cattt1.PMP_Active_Ind__c=true;
        cattt1.PMP_Partner_Product_Category_Cd__c='IPA_Ind_HealthCare';
        cattt.PMP_Partner_Product_Category_Key__c = 'ipa_ind_healthcare';
        cattt1.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_Industry';
        cattt1.PMP_Parent_Category_Id__c = cattt.Id;
        cattt1.Name='Healthcare';
        insert cattt1;
        
        PMP_Company__c testPartner1 = [SELECT Id FROM PMP_Company__c WHERE Name = 'testPartner1' LIMIT 1];
        
        PMP_Partner_Category__c parCat = New PMP_Partner_Category__c();
        parCat.PMP_Category_Id__c = cattt1.Id;
        parCat.PMP_Partner_Id__c = testPartner1.Id;
        insert parCat;
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerIndustries('en_US','PartnerIndustries'), 'Test failed');
        test.stopTest();   
    }
    
    @isTest
    public static void  getPartnerApplicationsTest2(){
        
        PMP_Category__c cattt= new PMP_Category__c();
        cattt.PMP_Active_Ind__c=true;
        cattt.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
        cattt.PMP_Partner_Product_Category_Key__c = 'npp_01_app';
        cattt.PMP_Partner_Product_Parent_Category_Cd__c  ='Solution_Marketplace_Hierarchy';
        cattt.Name='Industry';
        insert cattt;
        
        PMP_Category__c cattt1= new PMP_Category__c();
        cattt1.PMP_Active_Ind__c=true;
        cattt1.PMP_Partner_Product_Category_Cd__c='IPA_APP_CloudComp';
        cattt.PMP_Partner_Product_Category_Key__c = 'ipa_app_cloudcomp_public';
        cattt1.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_APP';
        cattt1.PMP_Parent_Category_Id__c = cattt.Id;
        cattt1.Name='Public Cloud';
        insert cattt1;
        
        PMP_Company__c testPartner1 = [SELECT Id FROM PMP_Company__c WHERE Name = 'testPartner1' LIMIT 1];
        
        PMP_Partner_Category__c parCat = New PMP_Partner_Category__c();
        parCat.PMP_Category_Id__c = cattt1.Id;
        parCat.PMP_Partner_Id__c = testPartner1.Id;
        insert parCat;
        
        test.startTest();
        system.assertNotEquals(NULL,PMP_TaxonomyStore.getPartnerApplications('en_US','PartnerApplications'), 'Test failed');
        test.stopTest();   
    }*/
    
    @isTest
    public static void  getActivePartnersTest(){
        
        test.startTest();
        PMP_TaxonomyStore.getActivePartners();
        test.stopTest();   
    }
    
    
}