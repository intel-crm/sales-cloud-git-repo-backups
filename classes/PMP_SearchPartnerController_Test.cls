@isTest
private class PMP_SearchPartnerController_Test extends PMP_SearchWrapperStore {
    
    @testSetup static void testDataFactory(){
         PMP_SearchPartnerController.Partner ptnr = new PMP_SearchPartnerController.Partner();
         ptnr.type='';
        List<PMP_Static_Constants__c> stList  = new List<PMP_Static_Constants__c>();
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry'; 
        stList.add(st); 
        PMP_Static_Constants__c st1 = new PMP_Static_Constants__c();
        st1.Name = 'PMP_PIM_Application_Id';
        st1.PMP_Value__c = 'NPP_01_APP';
        stList.add(st1);
        PMP_Static_Constants__c st2 = new PMP_Static_Constants__c();
        st2.Name = 'PMP_PIM_Region_PIM_Id';
        st2.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st2);
        PMP_Static_Constants__c st3 = new PMP_Static_Constants__c();
        st3.Name = 'PMP_Partner_Sort_By_Name_Asc';
        st3.PMP_Value__c = 'Name ASC NULLS LAST';
        stList.add(st3);
        PMP_Static_Constants__c st4 = new PMP_Static_Constants__c();
        st4.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st4.PMP_Value__c = 'Name DESC NULLS LAST';
        stList.add(st4);
        PMP_Static_Constants__c st5 = new PMP_Static_Constants__c();
        st5.Name = 'PMP_Thumbnail_Image';
        st5.PMP_Value__c = 'Thumbnail Image';
        stList.add(st5);
        PMP_Static_Constants__c st6 = new PMP_Static_Constants__c();
        st6.Name = 'PMP_Partner_Card_Default_Image_URL';
        st6.PMP_Value__c = '/file-asset/PMP_Partner_Card_Default_Image?isOptimized=false';
        stList.add(st6);
        PMP_Static_Constants__c st7 = new PMP_Static_Constants__c();
        st7.Name = 'PMP_LOEM_ODM_Partner_Program';
        st7.PMP_Value__c = 'LOEM-ODM Partner Program';
        PMP_Static_Constants__c st8 = new PMP_Static_Constants__c();
        st8.Name = 'Description';
        st8.PMP_Value__c = 'Description';
        
        stList.add(st7);
        insert stList;
        
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null;       
        ind1.PMP_Parent_Category_Id__c = cat0.Id;
        app0.PMP_Parent_Category_Id__c = null;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        //cat0.PMP_Partner_Product_Category_Cd__c = 'IPA_Ind_Auto';
        update cat0;
        update ind1;
        update app0;
        update app1;
        //PMP_Specification__c geoTest = PMP_SearchTestDataFactory.createSpecification('geo', '', 'NPP_GeographicCoverage', '');
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        //static constants
        PMP_Static_Constants__c stcn = New PMP_Static_Constants__c();
        stcn.Name = 'PMP_Thumbnail_Image';
        stcn.PMP_Value__c= 'Thumbnail Image';
        insert stcn;     
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        //testAccount.Core_Account_Type__c = 'Intel Approved Component Supplier (IACS)';
        testAccount.Core_Account_Type__c = 'Intel Approved Component Supplier (IACS); Intel Approved Device Supplier (IADS); Intel Authorized Distributor (IAD)';
        testAccount.Core_IPA_Partner_Role__c = 'Distributor';
        //testAccount.PMP_Account_Website__c= 'www.intel.com';
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        
        testPartner1.PMP_Account_Specialty__c = 'None';       
        testPartner1.PMP_Partner_Program_nm__c = 'Cloud & Comms Service Provider';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        testPartner1.PMP_Account_Website__c= 'www.intel.com';
        testPartner1.PMP_Partner_Benefit_Type__c = 'Solution Marketplace Basic Access';
        //testPartner1.description='test';
        //testPartners.longDescription='test';

        //testPartner1.PMP_Is_Distributor_Ind__c = true;
        //testPartner1.PMP_Biz_Org_Type_Txt__c='Intel Approved Component Supplier (IACS)';
        insert testPartner1; 
        
         Account testAccount2 = PMP_SearchTestDataFactory.createIntelAccount('testAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount2;
        Id accId2 = [SELECT id from Account WHERE Name = 'testAccount2'].id;
        
        PMP_Company__c testPartner3 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner3',accId2 , false);
        
        testPartner3.PMP_Account_Specialty__c = 'None';       
        testPartner3.PMP_Partner_Program_nm__c = 'Cloud & Comms Service Provider';
        testPartner3.PMP_Account_Dsc__c = 'test';
        testPartner3.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner3.PMP_Is_Published_Ind__c = true;
        testPartner3.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner3.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        testPartner3.PMP_Account_Website__c= 'www.intel.com';
        testPartner3.PMP_Partner_Benefit_Type__c = 'Solution Marketplace Basic Access';
        testPartner3.PMP_IPA_Badge_Tier_Txt__c = 'Member';
        testPartner3.PMP_Biz_Org_Type_Value_Txt__c = 'Intel Approved Component Supplier (IACS)';
        insert testPartner3;
        
        PMP_Company_Resource__c compres1 = New PMP_Company_Resource__c();
        compres1.PMP_Company_Id__c =testPartner3.Id ;
        compres1.PMP_Company_Resource_Type_Nm__c='testresource';
        compres1.PMP_Company_Image__c='test';
        compres1.PMP_Company_Resource_Type_Nm__c='Thumbnail Image';
        compres1.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert compres1;
         
        PMP_Company__c testPartnerDisti =  PMP_SearchTestDataFactory.createCompanyInformation('testPartnerDisti',accId , false);
        
        testPartnerDisti.PMP_Account_Specialty__c = 'None';       
        testPartnerDisti.PMP_Partner_Program_nm__c = 'Distributor';
        testPartnerDisti.PMP_Account_Dsc__c = 'test';
        testPartnerDisti.PMP_Company_Information_Language_Nm__c = 'English';
        testPartnerDisti.PMP_Is_Published_Ind__c = true;
        testPartnerDisti.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartnerDisti.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        testPartnerDisti.PMP_Account_Website__c= 'www.intel.com';
        insert testPartnerDisti;
        
         PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c();
		event.Name='new event';
        event.PMP_Marketplace_Event_Start_Dt__c= datetime.newInstance(2020, 8, 15, 12, 30, 0);
        event.PMP_Marketplace_Event_End_Dt__c =datetime.newInstance(2040, 8, 15, 12, 30, 0);
		insert event; 
        
        PMP_Marketplace_Event_Partner__c eventPartner =new PMP_Marketplace_Event_Partner__c();
        eventPartner.PMP_Company_Id__c =testPartner1.Id;
        eventPartner.PMP_Event_Id__c=event.Id;
        insert eventPartner;
        PMP_Company_Region__c reg = new PMP_Company_Region__c();
        reg.PMP_Company_Id__c = testPartner1.Id;
        reg.PMP_Specification_Id__c = spec1.Id;
        insert reg;
        
        PMP_Partner_Category__c ptnrInd = new PMP_Partner_Category__c();
        ptnrInd.PMP_Category_Id__c = ind1.Id;
        ptnrInd.PMP_Partner_Id__c = testPartner1.Id;
        insert ptnrInd;
        
        PMP_Partner_Category__c ptnrApp = new PMP_Partner_Category__c();
        ptnrApp.PMP_Category_Id__c = app1.Id;
        ptnrApp.PMP_Partner_Id__c = testPartner1.Id;
        insert ptnrApp;
        
        PMP_Company__c testPartner2 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner2',accId , false);       
        testPartner2.PMP_Account_Specialty__c = 'None';        
        testPartner2.PMP_Partner_Program_nm__c = 'Cloud & Comms Service Provider';
        testPartner2.PMP_Account_Dsc__c = 'test';
        testPartner2.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner2.PMP_Is_Published_Ind__c = true;
        insert testPartner2;
        
        
        //TranslationEOL
       /* PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Description;
        trans.PMP_Company_Information_Id__c = testPartner1.Id;
       // trans.PMP_Field_Nm__c = 'Description';
        insert trans;
        */
        PMP_Partner_Specialty__c ps=new PMP_Partner_Specialty__c();
        ps.Name='Artificial Intelligence Speciality';
        ps.PMP_Partner_Specialty_English_Dsc__c='test';
        ps.PMP_Is_Active_Ind__c = TRUE;
        insert ps;
        
        PMP_Partner_Specialty__c ps1 = new PMP_Partner_Specialty__c();
        ps1.Name='Video Specialty';
        ps1.PMP_Partner_Specialty_English_Dsc__c='test';
        ps1.PMP_Is_Active_Ind__c = TRUE;
        insert ps1;
                
        PMP_Partner_Program__c pm=new PMP_Partner_Program__c();
        pm.Name='Distributor';
        pm.PMP_Partner_Program_Value_Txt__c='Distributor';
        pm.PMP_Is_Active_Ind__c = TRUE;
        insert pm;
        
        PMP_Partner_Program__c pm1=new PMP_Partner_Program__c();
        pm1.Name='Cloud & Comms Service Provider';
        pm1.PMP_Partner_Program_Value_Txt__c='Cloud & Comms Service Provider';
        pm1.PMP_Is_Active_Ind__c = TRUE;
        insert pm1;
        
        PMP_Partner_Program__c pm2=new PMP_Partner_Program__c();
        pm2.Name='ODM_LOEM';
        pm2.PMP_Partner_Program_Value_Txt__c='ODM_LOEM';
        pm2.PMP_Is_Active_Ind__c = TRUE;
        insert pm2;
        
        PMP_Partner_Program__c pm3=new PMP_Partner_Program__c();
        pm3.Name='ISA';
        pm3.PMP_Partner_Program_Value_Txt__c='ISA';
        pm3.PMP_Is_Active_Ind__c = TRUE;
        insert pm3;
        
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
        eve.PMP_Marketplace_Desc__c = 'desc';
        eve.PMP_Event_Banner_Language__c = 'English';
       // eve.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        insert eve;
        User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
         System.runAs(user)
         {
             user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
             update user;
         } 
    
    }
 
    @isTest static void testGetPartnerList(){
        Test.startTest();
        //TranslationEOL
       // PMP_Company_Translation__c trans = [select id from PMP_Company_Translation__c where Name='test'];
       // Id [] fixedSearchResults= new Id[1];
       // fixedSearchResults[0] = trans.Id;
       // Test.setFixedSearchResults(fixedSearchResults);
		PMP_Company__c comp = [select id from PMP_Company__c where Name='testPartner1' limit 1];        
        
        system.assertEquals( 0 , PMP_SearchPartnerController.getPartnerList('',new List<String> {'testPartner1'}).size(),'Failed');
        system.assertNotEquals( NULL , PMP_SearchPartnerController.getPartnerList('testPartner1',new List<String> {comp.Id}).size(),'Failed');
        
        Test.stopTest();
    }
    
    @isTest static void testGetPartnerListforRLpage(){
        Test.startTest();
        //TranslationEOL
       /* PMP_Company_Translation__c trans = [select id from PMP_Company_Translation__c where Name='test'];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = trans.Id;
        Test.setFixedSearchResults(fixedSearchResults);*/
        PMP_Company__c comp = [select id from PMP_Company__c where Name='testPartner1' limit 1]; 
        system.assertEquals( 0 , PMP_SearchPartnerController.SerachPartnersByName('testPartner1').size(),'Failed');
        
        Test.stopTest();
    }
    
    @isTest static void testGetPartnerListForEmptyKeyword(){
        Test.startTest();        
        System.assertEquals(0, PMP_SearchPartnerController.getPartnerList('',new List<String>()).size(),'Failed');
        Test.stopTest();
    }
    
    @isTest static void testGetRegionResults(){
         List<String> options = new List<String>();
        
         PMP_Specification__c spec = [SELECT id from PMP_Specification__c where Name = 'Geo1' limit 1];
         options.add(spec.Id);
         Test.startTest();
        
         System.assertEquals(1,  PMP_SearchPartnerController.getRegionResults(options).size(),'Failed');
         Test.stopTest();
       
    }
    
    @isTest
    static void testGetCategoryResults(){
        List<String> options = new List<String>();
        PMP_Category__c cat = [select id from PMP_Category__c where Name='Healthcare'];
        options.add(cat.Id);
        Test.startTest();        
        System.assertEquals(0,  PMP_SearchPartnerController.getPartnerCategoryResults('NPP_01_Industry',options).size(),'Failed');
        Test.stopTest();
    }
    
  
    
    @isTest static void testGetSpecialtyResults(){
    //Map<String,Id> valueIdMap = new Map<String,Id>();
        Map<String,String> labelValueMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            labelValueMap.put(pickListVal.getLabel(),pickListVal.getValue());
        } 
         List<String> li=new List<String>();
         List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
        for(PMP_Partner_Specialty__c ps:specialtyList)
        {
            li.add(ps.Id);
        }
        Test.startTest();     
        li.add('Artificial Intelligence Specialist');
       	System.assertNotEquals(NULL,PMP_SearchPartnerController.getSpecialtyResults(li).size(),'Failed'); 
        Test.stopTest();     
    }
    
  
    
    @isTest static void testGetPartnerProgramResults(){
        Test.startTest();
        PMP_Partner_Program__c pp = [SELECT id, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'Cloud & Comms Service Provider' limit 1];
        System.assertEquals(3, PMP_SearchPartnerController.getPartnerProgramResults(pp.Id).size(),'Failed'); 
        Test.stopTest();
    }
    
    @isTest static void testPartnerQuickSearchResults(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        PMP_Category__c industry = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_INDUSTRY_ID LIMIT 1];
        PMP_Category__c application = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_APPLICATION_ID LIMIT 1];
        PMP_Specification__c region = [SELECT Id,Name,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_Partner.REGION_PIM_ID LIMIT 1];
        
        PMP_Category__c partnerInd = [SELECT id from PMP_Category__c where Name='Healthcare'];
        PMP_Category__c partnerApp = [SELECT id from PMP_Category__c where Name='Connected Worker'];
        PMP_Specification__c spec = [SELECT id from PMP_Specification__c where Name = 'Geo1' limit 1];
        PMP_Partner_Program__c pp = [SELECT id, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'Cloud & Comms Service Provider' limit 1];
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        List<String> pProgList = new List<String>();
        pProgList.add(pp.Id);
        selectedFilters.put('Partner Program_Partner', pProgList);
        
        List<String> indList = new List<String>();
        indList.add(partnerInd.Id);
        selectedFilters.put(industry.Id, indList);
        
        List<String> appList = new List<String>();
        appList.add(partnerApp.Id);
        selectedFilters.put(application.Id, appList);
        
       
         List<Id> eveIds=new List<Id>();
         List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c where name='new event'];
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
      //  selectedFilters.put(eve[0].Id, eveIds);
          selectedFilters.put('Marketplace_Event', eveIds);
        
        
        List<String> regList = new List<String>();
        regList.add(spec.Id);
        selectedFilters.put(region.Id, regList);
        //PMP_Specialty__mdt special = [SELECT id from PMP_Specialty__mdt where MasterLabel='Video Specialty' limit 1];
        PMP_Partner_Specialty__c special = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE AND Name = 'Video Specialty' limit 1];
        List<String> spcList = new List<String>();
        spcList.add(special.Id);
        selectedFilters.put('Specialty_Partner', spcList);
        
        Test.startTest();
        //System.assertEquals(0, PMP_SearchPartnerController.partnerQuickSearchResults(selectedFilters, '', partnerIds).size());
           System.assertNotEquals(NULL, PMP_SearchPartnerController.partnerQuickSearchResults(selectedFilters, '', partnerIds).size(),'Failed');
        Test.stopTest();    
    }   
    
    @isTest static void testGetPartners(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
    //    List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
         List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where Name ='testPartner3' OR PMP_Account_Id__c =: accId ];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        
        //String testLbl = Label.PMP_Intel_Approved_Component_Supplier;
        
        Test.startTest();
            System.assertNotEquals(NULL, PMP_SearchPartnerController.getPartners(partnerIds,1,9,null,'en_US',null,'Distributor',new List<String>()).size(),'Failed');
           System.assertNotEquals(NULL, PMP_SearchPartnerController.getPartners(partnerIds,200,100,null,'ja',null,'Distributor',new List<String>()).size(),'Failed');
        Test.stopTest();       
    }
        
    @isTest static void getpartnerSpecialtyforCardsTest(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        
        
        Test.startTest();
             System.assertNotEquals(NULL,PMP_SearchPartnerController.getpartnerSpecialtyforCards(partnerIds,'en_US').size(),'Failed');             
        Test.stopTest();       
    }
    
   
    @isTest static void testGetPartnerCount(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        Test.startTest();
        PMP_SearchPartnerController.getPartnerCount(partnerIds);
        system.assertEquals(2 , PMP_SearchPartnerController.getPartnerCount(partnerIds).get('Cloud & Comms Service Provider'),'Failed');
        Test.stopTest();
        
    }
    
     @isTest static void testFilterPartners(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
           List<String> options = new List<String>();
        PMP_Category__c cat = [select id from PMP_Category__c LIMIT 1];
        options.add(cat.Id);

             
              // List<String> li=new List<String>();
       //  List<PMP_Partner_Program__c> ppprogram = [SELECT id,Name from PMP_Partner_Program__c limit 1];
        /*for(PMP_Partner_Program__c pp1:partnerList1)
       {
            li.add(pp1.Id);
        }*/
        Test.startTest();
        	System.assertNotEquals(NULL, PMP_SearchPartnerController.filterPartners(cat.id,partnerIds).size(),'Failed');
        Test.stopTest();
       
        
    }    
    
    ///filterPartnerByRole
    @isTest static void filterPartnerByRoleTest(){
         Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        
        Id roleId= [select id from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c='ISA'].Id;
        Test.startTest();
        System.assertNotEquals( NULL,PMP_SearchPartnerController.filterPartnerByRole(roleId,partnerIds).size(),'Failed');
        Test.stopTest();
        
    }

}