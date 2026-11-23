@isTest
public class PMP_SearchFeaturedCarouselCtrlr_Test extends PMP_SearchWrapperStore {
   
    /*@testSetup static void setup(){
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c = 'English';
        update cmp1;
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.today();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        offering1.PMP_Sub_Category_nm__c = 'Intel® IoT Market Ready Solutions';
        offering1.PMP_Category_nm__c ='Solution';
        update offering1;
     
        
        PMP_Partner_Offering__c offering2 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering2.PMP_Offering_Status_Update_Dt__c = System.today();
        offering2.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering2.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering2.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
         offering2.PMP_Sub_Category_nm__c = 'Intel® IoT Market Ready Solutions';
        update offering2;
        
        
        
        PMP_Category__c parCat= PMP_SearchTestDataFactory.getCategory('Category' , 'NPP_01_TYPE' , 'NPP_Taxonomy' , 'en_us');
        
        PMP_Partner_Offering_Category__c offCategory2 = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering2.id);
        offCategory2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|test2';
        offCategory2.PMP_Offering_Category_External_Key__c = 'test2'; 
        update offCategory2;
        
        PMP_Category__c cat2 = [select PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where id = :offCategory2.PMP_Category_Id__c];
        cat2.PMP_Parent_Category_Id__c= parCat.id;
        cat2.PMP_Partner_Product_Category_Cd__c = 'TPS_900036';
        cat2.PMP_Active_Ind__c=True;
        update cat2;
        
        //New categories
        List<PMP_Category__c> catList =New List<PMP_Category__c>();
        PMP_Category__c newcat1 = New PMP_Category__c(Name = 'Categories',PMP_Partner_Product_Parent_Category_Cd__c= 'Solution_Marketplace_Hierarchy',
                                                      PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE',PMP_Partner_Product_Category_Key__c = 'npp_01_type',
													  PMP_Active_Ind__c=true);
        catList.add(newcat1);
        
        PMP_Category__c newcat2 = New PMP_Category__c(Name = 'Solution',PMP_Parent_Category_Id__c= newcat1.id,PMP_Partner_Product_Category_Cd__c = 'TPS_900002',
                                                      PMP_Partner_Product_Category_Key__c = 'tps_900002',PMP_Partner_Product_Parent_Category_Cd__c ='NPP_01_TYPE',
													  PMP_Active_Ind__c=true);
        catList.add(newcat2);
        
        PMP_Category__c newcat3 = New PMP_Category__c(Name = 'FPGA Boards',PMP_Parent_Category_Id__c= newcat2.id,PMP_Partner_Product_Category_Cd__c = 'TPS_900214',
													  PMP_Partner_Product_Category_Key__c = 'tps_900214',PMP_Partner_Product_Parent_Category_Cd__c ='TPS_900002',
													  PMP_Active_Ind__c=true);
        catList.add(newcat3);
        
        PMP_Category__c newcat4 = New PMP_Category__c(Name = 'Cat4',PMP_Parent_Category_Id__c= newcat3.id,PMP_Partner_Product_Category_Cd__c = 'TPS_900314',
										              PMP_Partner_Product_Category_Key__c = 'tps_900314',PMP_Partner_Product_Parent_Category_Cd__c ='TPS_900214',
													  PMP_Active_Ind__c=true);
        catList.add(newcat4);
        
        PMP_Category__c newcat5 = New PMP_Category__c(Name = 'Cat5',PMP_Parent_Category_Id__c= newcat4.id,PMP_Partner_Product_Category_Cd__c = 'TPS_900414',
								                      PMP_Partner_Product_Category_Key__c = 'tps_900414',PMP_Partner_Product_Parent_Category_Cd__c ='TPS_900314',
													  PMP_Active_Ind__c=true);
        catList.add(newcat5);
        
        insert catList;
        
        PMP_Partner_Offering_Category__c partOff1 = New PMP_Partner_Offering_Category__c();
        partOff1.PMP_Category_Id__c=newcat5.Id;
        partOff1.PMP_Offering_Id__c=offering1.Id;
        insert partOff1;
        
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
        
        PMP_Partner_Offering_Translation__c offTrans1 = new PMP_Partner_Offering_Translation__c();
        offTrans1.Name = 'test';
        offTrans1.PMP_Chinese_Txt__c = 'chinese';
        offTrans1.PMP_English_Txt__c = 'English';
        offTrans1.PMP_Japanese_Txt__c = 'japanese';
        offTrans1.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description;
        offTrans1.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans1;
        
         PMP_Partner_Offering_Translation__c offTrans2 = new PMP_Partner_Offering_Translation__c();
        offTrans2.Name = 'test';
        offTrans2.PMP_Chinese_Txt__c = 'chinese';
        offTrans2.PMP_English_Txt__c = 'English';
        offTrans2.PMP_Japanese_Txt__c = 'japanese';
        offTrans2.PMP_Field_Nm__c = 'Tagline';
        offTrans2.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans2;
        
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
        resource.PMP_Offering_Id__c=offering1.Id;
        resource.PMP_Partner_Offering_Image__c=document.Id;
        resource.PMP_Resource_Type_Nm__c='Thumbnail Image';
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
        PMP_SearchFeaturedCarouselController feturecoro = new PMP_SearchFeaturedCarouselController();
        //PMP_SearchFeaturedCarouselController.getFeaturedTabList('en_US');
        //PMP_SearchFeaturedCarouselController.getFeaturedTabs('ja');
        //PMP_SearchFeaturedCarouselController.getFeaturedTabList('ja');
        //System.assertEquals(1, li.size(),'Failure');
        Test.stopTest();
          
    }
    
    /* @isTest static void getFeaturedTabsLocaleTest(){
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
        PMP_SearchFeaturedCarouselController.getFeaturedTabs('zh_CN');
        PMP_SearchFeaturedCarouselController.getFeaturedTabList('zh_CN');
        PMP_SearchFeaturedCarouselController.getFeaturedTabs('zh-CN');
        PMP_SearchFeaturedCarouselController.getFeaturedTabList('zh-CN');
        System.assertEquals(1, li.size(),'Failure');
        Test.stopTest();
          
    }
    
    
    @isTest static void getFeaturedOfferingsTest(){
    
        String catId = [SELECT PMP_Category_Id__c from PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c LIKE 'TestDuplicateOffering1%' LIMIT 1].PMP_Category_Id__c;
        Test.startTest();
        List<Product> result = PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, null , 4, 'en_US');
        List<Product> result1= PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, 4 , 4, 'ja');
        List<Product> result2= PMP_SearchFeaturedCarouselController.getFeaturedOfferings(catId, null , 4, 'zh_CN');
        //Integer offset=4;
        system.assert(result.size() == 1,'Failure');
   //     system.assert(result1.size() >0);
        system.assert(result2.size() >0,'Failure');
        
        Test.stopTest();
    }
        @isTest static void testGetContentAssetUrlMap(){
        ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        
        List<String> conDocIds = new List<String>();
        conDocIds.add(contentVersion2.ContentDocumentId);
        
        Test.startTest();
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds),'Failure');
        Test.stopTest();
    }
    
    @isTest static void testGetContentAssetUrlMapException(){
        Test.startTest();
        
        
        List<String> conDocIds = new List<String>();
        conDocIds.add('121313');
        
        
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds),'Failure');
        Test.stopTest();
    }
   
    @isTest static void getEventsTest() {
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        List<String> eventList=new List<String>();
        eventList.add('Marketplace_event');
        selectedFilters.put('Marketplace_event', eventList);
        List<String> offIds=new List<String>();
        List<Id> parIds=new List<Id>();
        Test.startTest();
        Filter filter = new Filter();
         filter =PMP_SearchFeaturedCarouselController.getEvents(selectedFilters,'',offIds);
         System.assertEquals(filter!= null, true, 'filter wrapper record is null');
        Test.stopTest();
        
    }
    @isTest static void getEventOffCounttest()
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
        List<PMP_Marketplace_Event_Offering__c> eveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c limit 10];
        List<Id> eveIds=new List<Id>();
        for(PMP_Marketplace_Event_Offering__c eveoffLists:eveOff)
        {
            eveIds.add(eveoffLists.PMP_Event_Id__c);
            eveIds.add(eveoffLists.PMP_Offering_Id__c);
        }
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c limit 10];
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c limit 10];
        
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
           
        }
        
        List<PMP_Partner_Offering__c> off=[Select Id,Name from PMP_Partner_Offering__c limit 10];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:off)
        {
            offIds.add(offLists.Id);
        }
        
          Map<String, List<Attribute>> response = new Map<String, List<Attribute>>();
        Test.startTest();
        eventTag = PMP_SearchFeaturedCarouselController.getEventOffCount(eventTag,eveIds);
          System.assertEquals(eventTag!= null, true, 'EventOff Count  is null');
        response = PMP_SearchFeaturedCarouselController.getProductAttribute(par[0].Id,'en_US');
          System.assertEquals(response!= null, true, 'attribute  is null');
        Test.stopTest();
        
        
    }*/
}