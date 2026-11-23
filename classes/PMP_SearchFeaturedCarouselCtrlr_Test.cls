@isTest
public class PMP_SearchFeaturedCarouselCtrlr_Test extends PMP_SearchWrapperStore {
    
    @testSetup static void setup(){
        /*Id testOfferingId =  PMP_TestDataUtility.getOffering();
        PMP_Category__c parCat= PMP_SearchTestDataFactory.getCategory('Category' , 'NPP_01_TYPE' , 'NPP_Taxonomy' , 'en_us');
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(testOfferingId);
        PMP_Category__c cat = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory.PMP_Category_Id__c];
        cat.PMP_Parent_Category_Id__c= parCat.id;
        cat.PMP_Partner_Product_Category_Cd__c = 'TPS_900038';
        update cat;
        PMP_Category__c parCat2= PMP_SearchTestDataFactory.getCategory('Application' , 'NPP_01_App' , 'NPP_Taxonomy' , 'en_us');
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(testOfferingId);
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= parCat.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'TPS_900036';
        update cat2;*/
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
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
        System.debug('parCat '+parCat);
        
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        System.debug('offCategory '+ offCategory);
        offCategory.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test1';
        offCategory.PMP_Offering_Category_External_Key__c = 'test1'; 
        update offCategory;
        
        PMP_Category__c cat = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory.PMP_Category_Id__c];
        cat.PMP_Parent_Category_Id__c= parCat.id;
        cat.PMP_Partner_Product_Category_Cd__c = 'TPS_900038';
        update cat;
        
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering2.id);
        offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test2';
        offCategory2.PMP_Offering_Category_External_Key__c = 'test2'; 
        update offCategory2;
        
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= parCat.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'TPS_900036';
        update cat2; 
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        //eve.PMP_Marketplace_Event_Start_Dt__c=System.today()-1;
        //eve.PMP_Marketplace_Event_End_Dt__c=System.today()+1;
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now().addHours(-24);
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now().addHours(+24);
        eve.PMP_Marketplace_Event_Tagline__c='Tagline';
        insert eve;
        
        PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
        //eveOff.Name='Test Event Offering';
        eveOff.PMP_Offering_Id__c=offering1.Id;
        eveOff.PMP_Event_Id__c=eve.Id;
        insert eveOff;
        
        PMP_Partner_Offering_Translation__c offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'chinese';
        offTrans.PMP_English_Txt__c = 'English';
        offTrans.PMP_Japanese_Txt__c = 'japanese';
        offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name;
        offTrans.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans;
        
        offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'chinese';
        offTrans.PMP_English_Txt__c = 'English';
        offTrans.PMP_Japanese_Txt__c = 'japanese';
        offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description;
        offTrans.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans;
        
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
        resource.PMP_Offering_Id__c=offering1.Id;
        resource.PMP_Partner_Offering_Image__c=document.Id;
        resource.PMP_Resource_Type_Nm__c='Image';
        resource.PMP_Resource_Sequence_Nbr__c=0;
        insert resource;    
    }
    
    @isTest static void getFeaturedTabsTest(){
        List<FeaturedProductTab> li=new List<FeaturedProductTab>();
        FeaturedProductTab fpTab = new FeaturedProductTab();
        fpTab.label ='test';
        SearchParams catPar = new SearchParams();
        catPar.cat = '';
        catPar.type = 'product';
        fpTab.searchParams = catPar;
        //fpTab.products=cat2;
        fpTab.ctaTitle='View All "'+'Intel MRS'+'" solutions';
        li.add(fpTab);
        Test.startTest();
        PMP_SearchFeaturedCarouselController.getFeaturedTabs('en_US');
       	System.assertEquals(1, li.size());
        Test.stopTest();
          
    }
    
    @isTest static void getEventOfferings_Test(){
        
            Test.startTest();
             
            
            system.assert(PMP_SearchFeaturedCarouselController.getFeaturedOfferings(PMP_StaticConstants_Partner.EVENT_TAB_ID, null , 4, 'en_US').size() == 1);
            
            
            Test.stopTest();
        
        
    }
    
    @isTest static void getFeaturedOfferings_Test(){
        //String catId = [SELECT PMP_Category_Id__c from PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c LIKE 'TestDuplicateOffering1%' LIMIT 1].PMP_Category_Id__c;
        String catId = [SELECT PMP_Category_Id__c from PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c LIKE 'TestDuplicateOffering1%' LIMIT 1].PMP_Category_Id__c;
        Test.startTest();
        List<Product> result = PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, null , 4, 'en_US');
        // List<Product> result1= PMP_SearchFeaturedCarouselController.getFeaturedOfferings(null, null , 4, 'en_US');
        //Integer offset=4;
        system.assert(result.size() == 1);
         //  system.assert(result1.size() == 0);
        
        Test.stopTest();
    }
        @isTest static void testGetContentAssetUrlMap(){
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        
        List<String> conDocIds = new List<String>();
        conDocIds.add(contentVersion_2.ContentDocumentId);
        
        Test.startTest();
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds));
        Test.stopTest();
    }
    
    @isTest static void testGetContentAssetUrlMapException(){
        Test.startTest();
        
        
        List<String> conDocIds = new List<String>();
        conDocIds.add('121313');
        
        
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds));
        Test.stopTest();
    }
   
    @isTest static void getEvents_Test() {
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        List<String> eventList=new List<String>();
        eventList.add('Marketplace_event');
        selectedFilters.put('Marketplace_event', eventList);
        List<String> offIds=new List<String>();
        List<Id> parIds=new List<Id>();
        Test.startTest();
        PMP_SearchFeaturedCarouselController.getEvents(selectedFilters,'',offIds);
        Test.stopTest();
        
    }
    @isTest static void getEventOffCount_test()
    {
        Map<String,Tag> eventTag=new Map<String,Tag>();
        Tag tag = new Tag();
        tag.label ='';
        tag.count = 3;
        tag.value ='';
        tag.parent ='';
        tag.children = new List<Tag>();
        tag.pimId = '';
        eventTag.put('IPC Connect',tag);
        List<PMP_Marketplace_Event_Offering__c> eveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where Name LIKE 'Test Event Partner%'];
        List<Id> eveIds=new List<Id>();
        for(PMP_Marketplace_Event_Offering__c eveoffLists:eveOff)
        {
            eveIds.add(eveoffLists.PMP_Event_Id__c);
        }
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c];
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c];
        
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        List<PMP_Partner_Offering__c> Off=[Select Id,Name from PMP_Partner_Offering__c];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:Off)
        {
            offIds.add(offLists.Id);
        }
        
        
        Test.startTest();
        PMP_SearchFeaturedCarouselController.getEventOffCount(eventTag,eveIds);
        Test.stopTest();
        
    }
}