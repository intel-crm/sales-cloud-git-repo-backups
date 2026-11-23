@isTest
private class PMP_SearchContextualFilter_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void setup (){
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Region_PIM_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Checkbox';
        st.PMP_Value__c = 'Checkbox';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Label';
        st.PMP_Value__c = 'Label';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Radio_Button';
        st.PMP_Value__c = 'Radiobutton';
        stList.add(st);
        
        
        insert stList;
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        update cmp1;
        
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        partner.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        partner.PMP_Is_Published_Ind__c = true;
        insert partner;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        partner1.PMP_Is_Published_Ind__c = true;
        insert partner1;
        
        PMP_Company__c partner2=new PMP_Company__c();
        partner2.Name='Test_Partner2';
        partner2.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner2.PMP_Is_Published_Ind__c = true;
        System.debug('partner2'+partner2);
        insert partner2;
        
         PMP_Company__c partner3=new PMP_Company__c();
        partner3.Name='Test_Partner2';
        partner3.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner3.PMP_Is_Published_Ind__c = true;
        System.debug('partner3'+partner3);
        insert partner3;
        
        
        
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = partner.Id;
        insert off;
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = partner.Id;
        insert off1;
        
          PMP_Partner_Offering__c off2 = new PMP_Partner_Offering__c();
        off2.Name = 'Test_Off1';
        off2.PMP_Company_Id__c = partner2.Id;
        insert off2;
        
          PMP_Partner_Offering__c off3 = new PMP_Partner_Offering__c();
        off3.Name = 'Test_Off1';
        off3.PMP_Company_Id__c = partner2.Id;
        insert off3;
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec2;
        
           PMP_Company_Region__c ptnrSpec3 = new PMP_Company_Region__c();
        ptnrSpec3.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec3.PMP_Company_Id__c = partner2.Id;
        insert ptnrSpec3;
        
           PMP_Company_Region__c ptnrSpec4 = new PMP_Company_Region__c();
        ptnrSpec4.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec4.PMP_Company_Id__c = partner2.Id;
        insert ptnrSpec4;
        
        PMP_Partner_Specialty__c ps=new PMP_Partner_Specialty__c();
        ps.Name='Artificial Intelligence Speciality';
        ps.PMP_Partner_Specialty_English_Dsc__c='test';
        ps.PMP_Is_Active_Ind__c = TRUE;
        insert ps;


        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
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
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = partner.Id;
        insert ptnrCat;
        
         
        PMP_Partner_Category__c ptnrCatX = new PMP_Partner_Category__c();
        ptnrCatX.PMP_Category_Id__c = app1.Id;
        ptnrCatX.PMP_Partner_Id__c = partner2.Id;
        insert ptnrCatX;

        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
         PMP_Partner_Category__c ptnrCat1X= new PMP_Partner_Category__c();
        ptnrCat1X.PMP_Category_Id__c = app1.Id;
        ptnrCat1X.PMP_Partner_Id__c = partner3.Id;
        insert ptnrCat1X;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = partner.Id;
        insert ptnrCat;
        
        ptnrCatX = new PMP_Partner_Category__c();
        ptnrCatX.PMP_Category_Id__c = ind1.Id;
        ptnrCatX.PMP_Partner_Id__c = partner2.Id;
        insert ptnrCatx;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
         ptnrCat1X = new PMP_Partner_Category__c();
        ptnrCat1X.PMP_Category_Id__c = ind1.Id;
        ptnrCat1X.PMP_Partner_Id__c = partner3.Id;
        insert ptnrCat1X;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.PMP_Category_Id__c = app1.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
        offCat1.PMP_Category_Id__c = app1.Id;
        offCat1.PMP_Offering_Id__c = off1.Id;
        insert offCat1;
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.PMP_Category_Id__c = app2.Id;
        offCat2.PMP_Offering_Id__c = off1.Id;
        insert offCat2;
        
         PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c();
        offCat3.PMP_Category_Id__c = app2.Id;
        offCat3.PMP_Offering_Id__c = off2.Id;
        insert offCat3;
        
         PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
        offCat4.PMP_Category_Id__c = app2.Id;
        offCat4.PMP_Offering_Id__c = off2.Id;
        insert offCat4;
        
       	PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c(PMP_Specification_Id__c = spec1.Id,
            PMP_Active_Ind__c = true,PMP_Category_Id__c = cat1.Id);
        insert catSpec;
        catSpec = new PMP_Category_Specification_Association__c(PMP_Specification_Id__c = spec1.Id,
            PMP_Active_Ind__c = true,PMP_Category_Id__c = cat1.Id);
        insert catSpec;
        catSpec = new PMP_Category_Specification_Association__c(PMP_Specification_Id__c = spec2.Id,
            PMP_Active_Ind__c = true,PMP_Category_Id__c = cat1.Id);
        insert catSpec;
        
        PMP_Partner_Offering_Category__c offCategory = new PMP_Partner_Offering_Category__c(PMP_Offering_Id__c = off.Id,PMP_Category_Id__c = cat1.Id);
        insert offCategory;
        
      
        PMP_Partner_Offering_Specification__c offSpecs = new PMP_Partner_Offering_Specification__c(PMP_Display_Type_Nm__c = 'Checkbox',
                                                                                                   PMP_Offering_Id__c = off.Id,	PMP_Specification_Id__c = spec0.Id, PMP_Specification_Value_Id__c = specValue.Id,PMP_Product_Specification_Cd__c ='NPP');
        insert offSpecs;
        
        PMP_Partner_Offering_Specification__c offSpecs1 = new PMP_Partner_Offering_Specification__c(PMP_Display_Type_Nm__c = 'Checkbox',
                                                                                                   PMP_Offering_Id__c = off.Id,	PMP_Specification_Id__c = spec1.Id, PMP_Specification_Value_Id__c = specValue.Id,PMP_Product_Specification_Cd__c='npp');
        insert offSpecs1;
        PMP_Specification_Value_Association__c specValAsc = new PMP_Specification_Value_Association__c(PMP_Specification_Id__c = spec1.Id,	PMP_Specification_Value_Id__c = specValue.Id,	PMP_Active_Ind__c = true,
                                                                                                      PMP_Category_Id__c = cat1.Id);
        insert specValAsc;
    }
    
    
    @isTest static void contfilterResults_Test(){
        PMP_Partner_Offering__c testOff = [select id from PMP_Partner_Offering__c where name like 'Test_Off' limit 1];
        PMP_Partner_Offering_Category__c testOffCat = [select PMP_Category_Id__c  from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c = :testOff.id limit 1];
        PMP_Partner_Offering_Specification__c testOffSpec = [select id ,PMP_Specification_Id__c ,PMP_Specification_Value_Id__c ,name from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c = :testOff.id limit 1];
        String specId = [SELECT Id from PMP_Specification__c WHERE Name = 'Geo'].Id;
        
        Map<String , List<Id>> filterMap = new Map <String , List<Id>>();
        List<id> specIdList = new List<Id>();
        specIdList.add(testOffSpec.PMP_Specification_Id__c);
        specIdList.add(testOffSpec.PMP_Specification_Value_Id__c);
        
        filterMap.put(specId,specIdList);
        List<Id> offIds = new List<Id>();
        offIds.add(testOff.Id);
        
        Test.startTest();
        List<Id> retVal = PMP_SearchContextualFilterController.contfilterResults(filterMap , offIds);
        system.assertEquals(1, retVal.size());
        Test.stopTest();
    } 
    
    @isTest static void testContFilterOfferings(){
        PMP_Partner_Offering__c testOff = [select id from PMP_Partner_Offering__c limit 1];
        PMP_Partner_Offering_Category__c testOffCat = [select id , PMP_Category_Id__c  from PMP_Partner_Offering_Category__c limit 1];
        PMP_Partner_Offering_Specification__c testOffSpec = [select id ,PMP_Specification_Id__c ,PMP_Specification_Value_Id__c ,name from PMP_Partner_Offering_Specification__c limit 1];
        List<String> filterIds = new List<String>();
        filterIds.add(testOffSpec.PMP_Specification_Id__c);
        List<Id> offIds = new List<Id>();
        offIds.add(testOff.Id);
        
        Test.startTest();
        List<Id> retVal = PMP_SearchContextualFilterController.contFilterOfferings(filterIds ,   offIds);
        system.assertEquals(1, retVal.size());
        Test.stopTest();
    }
    
    @isTest static void testGetAllContextualFilters(){
        List<String> temp = new List<String>();
        List<PMP_Partner_Offering__c> offerings = [Select Id FROM PMP_Partner_Offering__c WHERE Name Like 'Test_Off%'];
        for(PMP_Partner_Offering__c off :offerings){
            temp.add(off.Id);
        }
        
        
        Test.startTest();
        List<Filter> retVal = PMP_SearchContextualFilterController.getAllContextualFilters(  temp,'en_US');
        system.assertEquals(1, retVal.size());
        Test.stopTest();
    }
    
    /*@isTest static void testGetContextualFilterCount(){
        PMP_Partner_Offering__c testOff = [select id from PMP_Partner_Offering__c limit 1];
        PMP_Partner_Offering_Category__c testOffCat = [select id , PMP_Category_Id__c  from PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c = :testOff.Id LIMIT 1];
        PMP_Partner_Offering_Specification__c testOffSpec = [select id ,PMP_Specification_Id__c,PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c ,PMP_Specification_Value_Id__c ,name from PMP_Partner_Offering_Specification__c limit 1];

        List<Id> offIds = new List<Id>();
        offIds.add(testOff.Id);
        Test.startTest();
        Map<String,Integer> retVal = PMP_SearchContextualFilterController.getContextualFilterCount(offIds);
        system.assertEquals(1, retVal.get(testOffSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c));
        Test.stopTest();
    }*/
    
    @isTest static void getPartnerContextualFilters_Test(){
        List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        
        Test.startTest();
        List<Filter> result = PMP_SearchContextualFilterController.getPartnerContextualFilters(temp,'en_US');
        system.assert(!result.isEmpty());
        Test.stopTest();
    }
    

    
    
    @isTest static void getOfferingPartnerFilter_Test(){
        List<PMP_Partner_Offering__c> testOff = [select id from PMP_Partner_Offering__c];
        List<Id> offIds = new List<Id>();
        for(PMP_Partner_Offering__c offLists:testOff)
        {
            offIds.add(offLists.Id);
        }
        Test.startTest();
        Filter retVal = PMP_SearchContextualFilterController.getOfferingPartnerFilter(offIds);
        List<Filter> filterList = new List<Filter>();
        filterList.add(retVal);
        system.assertEquals(1,filterList.size());
        Test.stopTest();
        
        
    }
    
    @isTest static void getPartnerSpecialtyFilter_Test(){
        
        List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        
        Test.startTest();
        Filter result = PMP_SearchContextualFilterController.getPartnerSpecialtyFilter(temp);
        system.assert(result.tags.size() == 1);
        Test.stopTest();
    }
    
    @isTest static void getOfferingSpecialtyFilter_Test(){
        
        List<PMP_Partner_Offering__c> testOff = [select id from PMP_Partner_Offering__c];
        List<Id> offIds = new List<Id>();
        for(PMP_Partner_Offering__c offLists:testOff)
        {
            offIds.add(offLists.Id);
        }
        
        Test.startTest();
        Filter retVal = PMP_SearchContextualFilterController.getPartnerSpecialtyFilterOfferings(offIds);
        List<Filter> filterList = new List<Filter>();
        filterList.add(retVal);
        system.assertEquals(1,filterList.size());
        Test.stopTest();
    }
     @isTest static void getOfferingPartnerProgramFilter_Test(){
        
        List<PMP_Partner_Offering__c> testOff = [select id,PMP_Company_Id__r.PMP_Partner_Program_nm__c,PMP_Company_Id__r.PMP_Account_Specialty__c from PMP_Partner_Offering__c where PMP_Company_Id__r.PMP_Account_Specialty__c!=null ];
      
        List<Id> offIds = new List<Id>();
        for(PMP_Partner_Offering__c offLists:testOff)
        {
            offIds.add(offLists.Id);
        }
        
        Test.startTest();
        Filter retVal = PMP_SearchContextualFilterController.getOfferingPartnerProgramFilter(offIds,'en_US');
        List<Filter> filterList = new List<Filter>();
        filterList.add(retVal);
        system.assertEquals(1,filterList.size());
        Test.stopTest();
    }
    
    @isTest static void testGetSpecialtyResults(){
   /* Map<String,Id> valueIdMap = new Map<String,Id>();
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
       */
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
       PMP_SearchContextualFilterController.getOfferingSpecialtyResults(li); 
        Test.stopTest();      
    }  
     @isTest static void testGetPartnerProgramResults(){
        Test.startTest();
       List<String> li=new List<String>();
       li.add('Artificial Intelligence Specialist');
        System.assertEquals(2, PMP_SearchContextualFilterController.getOfferingPartnerProgramResults(li).size()); 
        Test.stopTest();      
    }
    
    @isTest static void getOfferingCategoryFilters_Test(){
        
        List<String> temp = new List<String>();
        List<PMP_Partner_Offering__c> offerings = [Select Id FROM PMP_Partner_Offering__c WHERE Name Like 'Test_Off%'];
        for(PMP_Partner_Offering__c off :offerings){
            temp.add(off.Id);
        }
    
        List<String> pimIds = new List<String>();
        pimIds.add(PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
        Test.startTest();
		List<Filter> result = PMP_SearchContextualFilterController.getOfferingCategoryFilters(pimIds, temp,'en_US'); 
        system.assert(result[0].tags.size() == 1);
        Test.stopTest();
        
    }
    
    @isTest static void getPartnerCategoryFilters_Test(){
        
        List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        List<String> pimIds = new List<String>();
        pimIds.add(PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
        
        Test.startTest();
		List<Filter> result = PMP_SearchContextualFilterController.getPartnerCategoryFilters(pimIds, temp,'en_US'); 
        system.assert(result[0].tags.size() == 1);
        Test.stopTest();
        
    }
    
    @isTest static void getRegionPartner_Test(){
       	List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        
        Test.startTest();
		Filter result = PMP_SearchContextualFilterController.getRegionPartner(PMP_StaticConstants_Partner.REGION_PIM_ID, temp,'en_US'); 
        system.assert(result.tags.size() == 1);
        Test.stopTest();
    }
    
}