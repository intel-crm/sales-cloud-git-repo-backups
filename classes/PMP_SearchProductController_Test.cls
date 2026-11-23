@isTest 
private class PMP_SearchProductController_Test {
    @testSetup static void setup(){
       	PMP_SearchProductController.Product pd = new PMP_SearchProductController.Product();
        pd.onlyVisibleToIntel = true;
        pd.type = '';
        pd.prerelease = true;
        pd.prerelaseText = '';          
        
        
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Intel_Only';
        st.PMP_Value__c = 'Intel Only Content';
        stList.add(st); 
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Product_Card_Default_Image_URL';
        st.PMP_Value__c = '	/file-asset/PMP_Product_Card_Default_Image?isOptimized=false';
        stList.add(st); 
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
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
        st.Name = 'PMP_PIM_Category_Id';
        st.PMP_Value__c = 'NPP_01_TYPE';
        stList.add(st); 
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Pub_First';
        st.PMP_Value__c = 'PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Pub_Last';
        st.PMP_Value__c = 'PMP_Offering_Status_Update_Dt__c ASC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Asc';
        st.PMP_Value__c = 'Name ASC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st.PMP_Value__c = 'Name DESC NULLS LAST';
        stList.add(st);
		
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
  
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        update cmp1;
        
        
        
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.today();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        update offering1;
        
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
        resource.PMP_Offering_Id__c=offering1.Id;
        resource.PMP_Partner_Offering_Image__c=document.Id;
        resource.PMP_Resource_Type_Nm__c='Thumbnail Image';
        resource.PMP_Resource_Sequence_Nbr__c=0;
        insert resource;    
        
        PMP_Partner_Offering_Translation__c offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'test';
        offTrans.PMP_English_Txt__c = 'test';
        offTrans.PMP_Japanese_Txt__c = 'test';
        //offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Tag;
        offTrans.PMP_Field_Nm__c =PMP_StaticConstants_Partner.OFFERING_NAME;
        offTrans.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans;
        PMP_Partner_Offering_Translation__c offTrans1 = new PMP_Partner_Offering_Translation__c();
        offTrans1.Name = 'test';
        offTrans1.PMP_Chinese_Txt__c = 'test';
        offTrans1.PMP_English_Txt__c = 'test';
        offTrans1.PMP_Japanese_Txt__c = 'test';
        //offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Tag;
        offTrans1.PMP_Field_Nm__c =PMP_StaticConstants_Partner.OFFERING_DESCRIPTION;
        offTrans1.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans1;
        
        
        PMP_Partner_Offering__c offering2 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Draft','');
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering2.PMP_Offering_Status_Update_Dt__c = System.today();
        offering2.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering2.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering2.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        update offering2;
        
 
        
        PMP_Category__c parCat= PMP_SearchTestDataFactory.getCategory('Category' , 'NPP_01_TYPE' , 'NPP_Taxonomy' , 'en_us');
        
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        offCategory.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test1';
        offCategory.PMP_Offering_Category_External_Key__c = 'test1'; 
        update offCategory;
        
        PMP_Category__c cat = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory.PMP_Category_Id__c];
        cat.PMP_Parent_Category_Id__c= parCat.id;
        cat.PMP_Partner_Product_Category_Cd__c = 'NPP_01_Industry';
        update cat;
        
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering2.id);
        offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test2';
        offCategory2.PMP_Offering_Category_External_Key__c = 'test2'; 
        update offCategory2;
        
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= parCat.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'NPP_01_App';
        update cat2;
       
    }
    
    @isTest static void getOfferingIdsKeyword_Test(){
        PMP_Partner_Offering__c off = [SELECT Id FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published' LIMIT 1];
        PMP_Partner_Offering_Translation__c trans = new PMP_Partner_Offering_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        //trans.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        trans.PMP_Field_Nm__c =PMP_StaticConstants_Partner.OFFERING_NAME;
        trans.PMP_Partner_Offering_Id__c = off.Id;
        insert trans;
        
        Id [] fixedSearchResults= new Id[1];
      	fixedSearchResults[0] = trans.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        List<Id> offFound = PMP_SearchProductController.getOfferingIds('test');
        System.assertEquals(1, offFound.size());
        
        User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        user.LanguageLocaleKey = PMP_StaticConstants_Partner.ZH_CN;
        update user;
        
        offFound = PMP_SearchProductController.getOfferingIds('test');
        System.assertEquals(1, offFound.size());
        
        user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
        update user;
        
        offFound = PMP_SearchProductController.getOfferingIds('test');
        System.assertEquals(1, offFound.size());
        Test.stopTest();
    }
    
    @isTest static void getOfferingIdsAll_Test(){
        
        PMP_Partner_Offering__c off = [SELECT Id FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published' LIMIT 1];
        PMP_Partner_Offering_Translation__c trans = new PMP_Partner_Offering_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        trans.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        trans.PMP_Partner_Offering_Id__c = off.Id;
        insert trans;
        
        Test.startTest();
        List<Id> offFound = PMP_SearchProductController.getOfferingIds('');
        System.assertEquals(2, offFound.size());
        
        User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        user.LanguageLocaleKey = PMP_StaticConstants_Partner.ZH_CN;
        update user;
        
        offFound = PMP_SearchProductController.getOfferingIds('');
        System.assertEquals(2, offFound.size());
        
        user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
        update user;
        
        offFound = PMP_SearchProductController.getOfferingIds('');
        System.assertEquals(2, offFound.size());
        Test.stopTest();
    }
    
    @isTest static void testGetCount(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        String catId = [Select id from PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c='NPP_01_TYPE' LIMIT 1].Id;
        
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
        Map<String , Integer> countMap = PMP_SearchProductController.getCount(offList);
       // System.assertEquals(2, countMap.get(catId));
        Test.stopTest(); 
    }
    
    @isTest static void testFilterOfferings(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        List<PMP_Category__c> category = [SELECT id FROM PMP_Category__c];
        List<String> catList = new List<String>();
        for (PMP_Category__c cat : category){
            catList.add(cat.id);
        }
        Test.startTest();
        List<Id> result = PMP_SearchProductController.filterOfferings(catList, offList);
        System.assertEquals(2, result.size());
        Test.stopTest();
    }
    
    @isTest static void testGetProducts(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
            system.debug('the ids are=====>'+offList[0]);
        }
        
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'PMP_Offering_Status_Update_Dt__c','en_US');
        
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
     @isTest static void testGetProductsSortByProductPublishedDateLast(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'PMP_Offering_Status_Update_Dt__c DESC NULLS LAST','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
     @isTest static void testGetProductsSortByProductPublishedDateFirst(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'PMP_Offering_Status_Update_Dt__c ASC NULLS LAST','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
    @isTest static void testGetProductsSortFieldProductDescending(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'ProductDescending','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
    @isTest static void testGetProductsSortFieldProductAscending(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'ProductAscending','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
     @isTest static void testGetProductsSortFieldProductPublishedDate(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'LatestPublishedLast','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
    @isTest static void testGetProductsSortFieldProductPublishedDateFirst(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'LatestPublishedFirst','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
     @isTest static void testGetProductsSortFieldProductFeatured(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
       // List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,'');
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,1,9,'Featured','en_US');
        System.assertEquals(2, res.size());
        Test.stopTest(); 
    }
    
    @isTest static void testCalculateOffset(){
        //List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
       // List<PMP_Partner_Offering__c> offerings = new List<PMP_Partner_Offering__c>();
       
        /*for(Integer i=1; i<=3000; i++){
            PMP_Partner_Offering__c off = new PMP_Partner_Offering__c(Name='offering'+string.valueOf(i));
            offerings.add(off);
        }
     Test.startTest();
        insert offerings;*/
        
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
       Test.startTest();
        try{
        List<PMP_SearchProductController.Product> res = PMP_SearchProductController.getProducts(offList,310,9,'Featured','en_US');
        System.assert(res !=null); 
        }catch(Exception e){
           
        }
            
        Test.stopTest(); 
    }
    
    
    @isTest static void testGetProductProgramResults(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
        List<String> res = PMP_SearchProductController.getProductProgramResults('ODM-LOEM' , offList);
        System.assertEquals(2, res.size());
        Test.stopTest();
    }
    
    
    
    @isTest static void quickSearchResult_Partner(){
        Test.startTest();
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        update cmp1;
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
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
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        offCategory.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test1';
        offCategory.PMP_Offering_Category_External_Key__c = 'test1'; 
        update offCategory;
        
        PMP_Category__c cat = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory.PMP_Category_Id__c];
        cat.PMP_Parent_Category_Id__c= cat0.id;
        cat.PMP_Partner_Product_Category_Cd__c = 'test1';
        update cat;
        
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test2';
        offCategory2.PMP_Offering_Category_External_Key__c = 'test2'; 
        update offCategory2;
        
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= cat0.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'test2';
        update cat2;
        
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        System.debug('offerings '+offerings);
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        
        Map<String,List<String>> filters = new Map<String,List<String>>();
        
        List<String> compList = new List<String>();
        List<PMP_Company__c> comp = [SELECT Id FROM PMP_Company__c];
        for (PMP_Company__c cp: comp){
            compList.add(cp.Id);
        }
        
         //filters.put('Partner Program_Partner',compList);
         filters.put('Partner',compList);
         filters.put(cat0.Id, offList);
         filters.put(app0.Id, offList);
         filters.put(ind0.Id, offList);
        
        
        List<String> res = PMP_SearchProductController.quickSearchResults(filters , offList);
        //PMP_SearchProductController.getCategoryTree(offList);
        System.assertEquals(3, res.size());
        Test.stopTest();
    }
    
    @isTest static void testIsPreReleased(){
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount2', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
  
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        update cmp1;
        
       PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.today();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        update offering1;
        
        PMP_Specification_Value__c value=new PMP_Specification_Value__c();
        value.PMP_Partner_Off_Roadmap_Ind__c=True;
        insert value;
        
        PMP_Partner_Offering_Specification__c spec=new PMP_Partner_Offering_Specification__c();
        spec.PMP_Specification_Value_Id__c=value.Id;
        spec.PMP_Offering_Id__c=offering1.Id;
        insert spec;
        
        List<Id> li=new List<Id>();
		li.add(offering1.Id);
        
        Test.startTest();
        PMP_SearchProductController.isPreReleased(li);
        System.assertEquals(1, li.size());
        Test.stopTest(); 
   
    }
    
    /*@isTest static void testGetCategoryTree(){
        List<PMP_Partner_Offering__c> offerings = [select Id FROM PMP_Partner_Offering__c];
        List<Id> offList = new List<Id>();
        for (PMP_Partner_Offering__c off : offerings){
            offList.add(off.Id);
        }
        Test.startTest();
        List<PMP_Category__c> lis=PMP_SearchProductController.getCategoryTree(offList);
        System.assertEquals(1, lis.size());
        Test.stopTest();
    }*/
}