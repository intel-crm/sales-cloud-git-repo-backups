@isTest
private class PMP_SearchPartnerController_Test extends PMP_SearchWrapperStore {
    
    @testSetup static void testDataFactory(){
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
        stList.add(st7);
        insert stList;
        
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null;       
        ind1.PMP_Parent_Category_Id__c = cat0.Id;
        app0.PMP_Parent_Category_Id__c = null;
        app1.PMP_Parent_Category_Id__c = app0.Id;
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
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        
        testPartner1.PMP_Account_Specialty__c = 'Video Specialty';       
        testPartner1.PMP_Partner_Program_nm__c = 'ISA';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner1; 
        
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
        testPartner2.PMP_Account_Specialty__c = 'Video Specialty';        
        testPartner2.PMP_Partner_Program_nm__c = 'ISA';
        testPartner2.PMP_Account_Dsc__c = 'test';
        testPartner2.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner2.PMP_Is_Published_Ind__c = true;
        insert testPartner2;
        
        
        
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Description;
        trans.PMP_Company_Information_Id__c = testPartner1.Id;
        trans.PMP_Field_Nm__c = 'test';
        insert trans;
        
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
        pm.Name='ODM_LOEM';
        pm.PMP_Partner_Program_Value_Txt__c='ODM_LOEM';
        pm.PMP_Is_Active_Ind__c = TRUE;
        insert pm;
        
        PMP_Partner_Program__c pm1=new PMP_Partner_Program__c();
        pm1.Name='ISA';
        pm1.PMP_Partner_Program_Value_Txt__c='ISA';
        pm1.PMP_Is_Active_Ind__c = TRUE;
        insert pm1;
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
        eve.PMP_Marketplace_Desc__c = 'desc';
        eve.PMP_Event_Banner_Language__c = 'English';
       // eve.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        insert eve;

        
       /*  User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
         System.runAs(user)   {
             user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
             update user;
        } */
        
        
        
    }
    
  
    
    @isTest static void testGetPartnerList(){
        Test.startTest();
        PMP_Company_Translation__c trans = [select id from PMP_Company_Translation__c where Name='test'];
        
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = trans.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        system.assertEquals( 1 , PMP_SearchPartnerController.getPartnerList('test').size());
        
        Test.stopTest();
    }
    
    @isTest static void testGetPartnerListforRLpage(){
        Test.startTest();
        PMP_Company_Translation__c trans = [select id from PMP_Company_Translation__c where Name='test'];
        
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = trans.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        system.assertEquals( 1 , PMP_SearchPartnerController.SerachPartnersByName('test').size());
        
        Test.stopTest();
    }
    
    @isTest static void testGetPartnerListForEmptyKeyword(){
        Test.startTest();        
        System.assertEquals(1, PMP_SearchPartnerController.getPartnerList('').size());
        Test.stopTest();
    }
    
    @isTest static void testGetRegionResults(){
         List<String> options = new List<String>();
        
         PMP_Specification__c spec = [SELECT id from PMP_Specification__c where Name = 'Geo1' limit 1];
         options.add(spec.Id);
         Test.startTest();
        
         System.assertEquals(1,  PMP_SearchPartnerController.getRegionResults(options).size());
         Test.stopTest();
       
    }
    
    @isTest
    static void testGetCategoryResults(){
        List<String> options = new List<String>();
        PMP_Category__c cat = [select id from PMP_Category__c where Name='Healthcare'];
        options.add(cat.Id);
        Test.startTest();        
        System.assertEquals(1,  PMP_SearchPartnerController.getPartnerCategoryResults('NPP_01_Industry',options).size());
        Test.stopTest();
    }
    
  
    
    @isTest static void testGetSpecialtyResults(){
    /*Map<String,Id> valueIdMap = new Map<String,Id>();
        List<PMP_Specialty__mdt> spec = [Select id, MasterLabel from PMP_Specialty__mdt];
        for(PMP_Specialty__mdt specData: spec){
            valueIdMap.put(specData.MasterLabel, specData.Id); 
        }

     Map<String,String> labelValueMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            labelValueMap.put(pickListVal.getLabel(),pickListVal.getValue());
        } 
        Test.startTest();
        List<String> li=new List<String>();
        //li.add('Video Specialty');
        for(String special: labelValueMap.values()){
        li.add(valueIdMap.get(labelValueMap.get(special)));
            }
        System.assertEquals(2, PMP_SearchPartnerController.getSpecialtyResults(li).size()); 
        Test.stopTest(); */
         List<String> li=new List<String>();
          List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
        for(PMP_Partner_Specialty__c ps:specialtyList)
        {
            li.add(ps.Id);
        }
        Test.startTest();
      
        li.add('Artificial Intelligence Specialist');
       // for(String special: labelValueMap.values()){
        //li.add(valueIdMap.get(labelValueMap.get(special)));
          //  }
       // System.assertEquals(1, PMP_SearchContextualFilterController.getOfferingSpecialtyResults(li).size());
       PMP_SearchPartnerController.getSpecialtyResults(li); 
        Test.stopTest();     
    }
    
  
    
    @isTest static void testGetPartnerProgramResults(){
        Test.startTest();
        PMP_Partner_Program__c pp = [SELECT id, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'ISA' limit 1];
        System.assertEquals(2, PMP_SearchPartnerController.getPartnerProgramResults(pp.Id).size()); 
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
        PMP_Partner_Program__c pp = [SELECT id, PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Partner_Program_Value_Txt__c = 'ISA' limit 1];
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
         List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c];
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        selectedFilters.put(eve[0].Id, eveIds);
        
        
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
           PMP_SearchPartnerController.partnerQuickSearchResults(selectedFilters, '', partnerIds);
        Test.stopTest();    
    }   
    
    @isTest static void testGetPartners(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        Test.startTest();
        System.assertEquals(2, PMP_SearchPartnerController.getPartners(partnerIds,1,9,null,'en_US').size()); 
        Test.stopTest();       
    }
    
    @isTest static void testGetPartnersForPartnerAscending(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        Test.startTest();
        System.assertEquals(2, PMP_SearchPartnerController.getPartners(partnerIds,1,9,'PartnerAscending','en_US').size());
        Test.stopTest();       
    }
    
    @isTest static void testGetPartnersForPartnerDescending(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        Test.startTest();
       
        System.assertEquals(2, PMP_SearchPartnerController.getPartners(partnerIds,1,9,'PartnerDescending','en_US').size());
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
        system.assertEquals(2 , PMP_SearchPartnerController.getPartnerCount(partnerIds).get('ISA'));
        Test.stopTest();
        
    }
    
     @isTest static void testFilterPartners(){
        
        Id accId = [SELECT id from Account where Name = 'testAccount'].id;
        List<PMP_Company__c> partnerList = [SELECT id from PMP_Company__c where PMP_Account_Id__c =: accId];
        List<Id> partnerIds = new List<Id>();
        for(PMP_Company__c partner : partnerList){
            partnerIds.add(partner.id);
        }
        PMP_SearchPartnerProgram_Config__mdt pp = [SELECT id from PMP_SearchPartnerProgram_Config__mdt where PMP_Partner_Program_value__c = 'ISA' limit 1]; 
           List<String> options = new List<String>();
        PMP_Category__c cat = [select id from PMP_Category__c LIMIT 1];
        options.add(cat.Id);

             
              // List<String> li=new List<String>();
         List<PMP_Partner_Program__c> partnerList1 = [SELECT id from PMP_Partner_Program__c];
        /*for(PMP_Partner_Program__c pp1:partnerList1)
       {
            li.add(pp1.Id);
        }*/
             Test.startTest();
        PMP_SearchPartnerController.filterPartners(cat.Id,partnerIds);
        Test.stopTest();
        //system.assertEquals(2 , PMP_SearchPartnerController.filterPartners(pp.Id,partnerIds).size());
        
    }    
}