@isTest
public class PMP_SearchEventDetailController_Test extends PMP_SearchWrapperStore {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_SearchEventDetailController.isWorking();
        System.assertEquals(true, result);
    }

    
/*    @testSetup static void setup (){//IPA2.0:TWC729-8114 Topics Removal/Event Removal
        
        PMP_Company__c testPartner1 =  new PMP_Company__c();
        testPartner1.PMP_Account_Specialty__c = 'None';       
        testPartner1.PMP_Partner_Program_nm__c = 'ISA';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner1; 
        
        
        List<String> ss=new List<String>();
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = testPartner1.Id;
        off.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        off.PMP_Partner_Offering_Start_Dt__c=System.today();
        insert off;
        ss.add(off.Id);
        
        
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = testPartner1.Id;
        off1.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        off.PMP_Partner_Offering_Start_Dt__c=System.today();
        insert off1;
        ss.add(off1.Id);
        
        ContentDocument doc1 = PMP_SearchTestDataFactory.createContentDocument(true)[0];
        ContentAsset ca1= new ContentAsset();
        ca1.DeveloperName = 'en_US' + doc1.Id;
        ca1.MasterLabel = 'en_US'  + doc1.Id;
        ca1.isVisibleByExternalUsers = TRUE;
        ca1.language = 'en_US';
        insert ca1;
        doc1.ContentAssetId = ca1.Id;
        update doc1;
        
        ContentDocument doc2 = PMP_SearchTestDataFactory.createContentDocument(true)[0];
        ContentAsset ca2= new ContentAsset();
        ca2.DeveloperName = 'en_US' + doc2.Id;
        ca2.MasterLabel = 'en_US'  + doc2.Id;
        ca2.isVisibleByExternalUsers = TRUE;
        ca2.language = 'en_US';
        insert ca2;
        doc2.ContentAssetId = ca2.Id;
        update doc2;
        
        ContentDocument doc3 = PMP_SearchTestDataFactory.createContentDocument(true)[0];
        ContentAsset ca3= new ContentAsset();
        ca3.DeveloperName = 'en_US' + doc3.Id;
        ca3.MasterLabel = 'en_US'  + doc3.Id;
        ca3.isVisibleByExternalUsers = TRUE;
        ca3.language = 'en_US';
        insert ca3;
        doc3.ContentAssetId = ca3.Id;
        update doc3;
        
        Map<String,String> langMap = new Map<String,String>{'en_US'=>ca1.DeveloperName,'ja'=>ca2.DeveloperName,'zh_CN'=>ca3.DeveloperName};
        List<Id> eveIds=new List<Id>();
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
        eve.PMP_Marketplace_Desc__c = 'desc';
        eve.PMP_Event_Banner_Language__c = 'English';
        eve.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        eve.PMP_Event_Learn_More_Link_Txt__c = 'www.google.com';
        eve.PMP_Event_Marquee_Desc_Txt__c = 'marquee';
        insert eve;
        eveIds.add(eve.Id);
        
        
        
        PMP_Marketplace_Event__c eve1=new PMP_Marketplace_Event__c();
        eve1.Name='Test Event1';
        eve1.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve1.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve1.PMP_Marketplace_Event_Tagline__c = 'tagline';
        eve1.PMP_Marketplace_Desc__c = 'desc';
        eve1.PMP_Event_Banner_Language__c = 'English';
        eve1.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
      //  eve1.PMP_Event_Learn_More_Link_Txt__c = 'www.google.com';
      //  eve1.PMP_Event_Marquee_Desc_Txt__c_ = 'marquee';
        insert eve1;
        eveIds.add(eve1.Id);
        
        
        PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
        eveOff.PMP_Offering_Id__c=ss[0];
        eveOff.PMP_Event_Id__c=eveIds[0];
        insert eveoff;
        
        PMP_Marketplace_Event_Offering__c eveOff1=new PMP_Marketplace_Event_Offering__c();
        eveOff1.PMP_Offering_Id__c=ss[1];
        eveOff1.PMP_Event_Id__c=eveIds[1];
        insert eveoff1;
        
        PMP_Marketplace_Event_Partner__c  evePar=new PMP_Marketplace_Event_Partner__c ();
        evePar.PMP_Company_Id__c=testPartner1.Id;
        evePar.PMP_Event_Id__c=eve.Id;
        insert evePar;
        
        PMP_Marketplace_Event_Translation__c  trans=new PMP_Marketplace_Event_Translation__c();
        trans.PMP_Marketplace_Event_Id__c=eve.Id;
        trans.PMP_Field_Nm__c='Tagline';
        trans.PMP_English_Txt__c='Tagline';
        trans.PMP_Chinese_Txt__c = 'tag';
        trans.PMP_Japanese_Txt__c = 'tag';
        insert trans;
        
        trans=new PMP_Marketplace_Event_Translation__c();
        trans.PMP_Marketplace_Event_Id__c=eve.Id;
        trans.PMP_Field_Nm__c='Description';
        trans.PMP_English_Txt__c='Desc';
        trans.PMP_Chinese_Txt__c = 'desc';
        trans.PMP_Japanese_Txt__c = 'desc';
        insert trans;
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Supported_Languages';
        st.PMP_Value__c = 'en_US;ja;zh-Hans-CN'; 
        insert st;
        
    }
    
    /*@isTest static void getPromotionLanguageOptionsTest(){
        Schema.DescribeFieldResult fieldResult = PMP_Marketplace_Event__c.PMP_Event_Banner_Language__c.getDescribe();      
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        Test.startTest();
        system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getPromotionLanguageOptions().size(),'Test Failed');
        Test.stopTest();
    }*/
    
    /*@isTest static void getPromotionDataTest(){
        
        PMP_Marketplace_Event__c event = [SELECT id,PMP_Event_Banner_Language_Mapping__c, PMP_Event_Banner_Language__c from PMP_Marketplace_Event__c WHERE Name='Test Event' LIMIT 1];
        
        Test.startTest();
        system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getPromotionData('en_US').size(),'Test Data is wrong.');
        
        Map<String,String> langMap = new Map<String,String>{'en_US'=>'test'};
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        update event;
        
        system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getPromotionData('zh_CN').size(),'Test Failed');
        
        langMap = new Map<String,String>{'zh_CN'=>'test'};
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        event.PMP_Event_Banner_Language__c = 'Simplified Chinese';
        update event;
        
        system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getPromotionData('ja').size(),'Test Failed');
        Test.stopTest();
    }*/
    
    /*@isTest static void getEventsTest()
    {
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        List<String> eventList=new List<String>();
        Filter filters= New Filter();
        eventList.add('Marketplace_event');
        selectedFilters.put('Marketplace_event', eventList);
        List<String> offIds=new List<String>();
        List<Id> parIds=new List<Id>();
        Test.startTest();
        filters = PMP_SearchEventDetailController.getEvents(selectedFilters,'',offIds,parIds);
        Test.stopTest();
        System.assert(filters!=null,'Test Failed');
        
    }//
    @isTest static void getEventOfferingsTest()
    {
        List<PMP_Partner_Offering__c> off=[Select Id,Name from PMP_Partner_Offering__c LIMIT 10];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:off)
        {
            offIds.add(offLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c LIMIT 10];
        List<Id> eveIds=new List<Id>();
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        
        
        Test.startTest();
        	//system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventOfferings(eveIds,offIds).size(),'Test Failed');
        Test.stopTest();
       
    }
    /*@isTest static void getEventPartnersTest()
    {
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c LIMIT 10]; 
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c LIMIT 10];
        List<Id> eveIds=new List<Id>();
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        Test.startTest();
      		system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventPartners(eveIds,parIds).size(),'Test Failed');        
        Test.stopTest();
        
        
    }//
    @isTest static void getEventOffCountTest()
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
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c LIMIT 10];
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c LIMIT 10];
        
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        List<PMP_Partner_Offering__c> off=[Select Id,Name from PMP_Partner_Offering__c LIMIT 10];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:off)
        {
            offIds.add(offLists.Id);
        }
        
        
        Test.startTest();
        //system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventOffCount(eventTag,eveIds).size(),'Test Failed');
        //system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventCount('Partner',eventTag,parIds,offIds).size(),'Test Failed');
        //system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventCount('Product',eventTag,parIds,offIds).size(),'Test Failed');
        //system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getEventPartnerCount(eventTag,parIds).size(),'Test Failed');
        Test.stopTest();
        
    }
    
     @isTest 
     static void getEventOfferingsIdTest(){
         PMP_Marketplace_Event__c eve=[Select Id,Name from PMP_Marketplace_Event__c Limit 1];
         
         Test.startTest();
         	//system.assertNotEquals( NULL , PMP_SearchEventDetailController.getEventOfferingsId(eve.Id).size(),'Test Failed');
         Test.stopTest();
     }
    
    /*@isTest 
     static void getEventPartnerIdTest(){
         PMP_Marketplace_Event__c eve=[Select Id,Name from PMP_Marketplace_Event__c Limit 1];
         
         Test.startTest();
         	PMP_SearchEventDetailController.getEventPartnerId(eve.Id);
            system.assertNotEquals( NULL , PMP_SearchEventDetailController.getEventPartnerId(eve.Id).size(),'Test Failed');
         Test.stopTest();
     }*/
    
     /*@isTest 
     static void getCampaignMarqueeDetailsTest(){
         PMP_Marketplace_Event__c eve=[Select Id,Name from PMP_Marketplace_Event__c Limit 1];
         CampaignEvents camp = new CampaignEvents();
         Test.startTest();
         	camp = PMP_SearchEventDetailController.getCampaignMarqueeDetails(eve.Id);
         Test.stopTest();
         system.assert(camp!=Null,'Test Failed');
     }*/

     /*@isTest 
     static void getCampaignCardDetailsTest(){
         PMP_Marketplace_Event__c eve=[Select Id,Name from PMP_Marketplace_Event__c Limit 1];
         CampaignEvents camp = new CampaignEvents();
         Test.startTest();
         	camp = PMP_SearchEventDetailController.getCampaignCardDetails(eve.Id,'partner','en_US',1,8);
         Test.stopTest();
           system.assert(camp!=Null,'Test Failed');
     } //
    
     @isTest 
    static void getCampaignBannerDetailsTest(){
         PMP_Company__c par=[Select Id,Name from PMP_Company__c Limit 1];
         PMP_Partner_Offering__c off=[Select Id,Name from PMP_Partner_Offering__c Limit 1];
         String lang = 'en_US';
         Test.startTest();
         	//system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getCampaignBannerDetails(par.Id,true,lang).size(),'Test Failed');
        	//system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getCampaignBannerDetails(par.Id,true,NULL).size(),'Test Failed');
            //system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getCampaignBannerDetails(off.Id,false,NULL).size(),'Test Failed');
        	//system.assertNotEquals( NULL ,PMP_SearchEventDetailController.getCampaignBannerDetails(off.Id,false,lang).size(),'Test Failed');
         Test.stopTest();
    }*/
    
    
}