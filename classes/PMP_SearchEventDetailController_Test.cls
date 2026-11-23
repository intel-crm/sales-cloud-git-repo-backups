@isTest
public class PMP_SearchEventDetailController_Test extends PMP_SearchWrapperStore {
    @testSetup static void setup (){
        
        PMP_Company__c testPartner1 =  new PMP_Company__c();
        testPartner1.PMP_Account_Specialty__c = 'Video Specialty';       
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
        
        
    }
    
    @isTest static void getPromotionLanguageOptions_Test(){
        Schema.DescribeFieldResult fieldResult = PMP_Marketplace_Event__c.PMP_Event_Banner_Language__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        Test.startTest();
        List<Object> langs= PMP_SearchEventDetailController.getPromotionLanguageOptions();
        Test.stopTest();
        
        system.assertEquals(ple.size(), langs.size());
    }
    
    @isTest static void getPromotionData_Test(){
        
        PMP_Marketplace_Event__c event = [SELECT id,PMP_Event_Banner_Language_Mapping__c, PMP_Event_Banner_Language__c from PMP_Marketplace_Event__c WHERE Name='Test Event' LIMIT 1];
        
        Test.startTest();
        List<Object> promos = PMP_SearchEventDetailController.getPromotionData('en_US');
        
        Map<String,String> langMap = new Map<String,String>{'en_US'=>'test'};
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        update event;
        
        promos = PMP_SearchEventDetailController.getPromotionData('zh_CN');
        
        langMap = new Map<String,String>{'zh_CN'=>'test'};
        event.PMP_Event_Banner_Language_Mapping__c = JSON.serialize(langMap);
        event.PMP_Event_Banner_Language__c = 'Simplified Chinese';
        update event;
        
        promos = PMP_SearchEventDetailController.getPromotionData('ja');
        Test.stopTest();
        
        system.assert(promos!=null);
    }
    
    @isTest static void getEvents_Test()
    {
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        List<String> eventList=new List<String>();
        eventList.add('Marketplace_event');
        selectedFilters.put('Marketplace_event', eventList);
        List<String> offIds=new List<String>();
        List<Id> parIds=new List<Id>();
        Test.startTest();
        PMP_SearchEventDetailController.getEvents(selectedFilters,'',offIds,parIds);
        Test.stopTest();
        
    }
    @isTest static void getEventOfferings_Test()
    {
        List<PMP_Partner_Offering__c> Off=[Select Id,Name from PMP_Partner_Offering__c];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:Off)
        {
            offIds.add(offLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c];
        List<Id> eveIds=new List<Id>();
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        
        
        Test.startTest();
        PMP_SearchEventDetailController.getEventOfferings(eveIds,offIds);
        Test.stopTest();
    }
    @isTest static void getEventPartners_Test()
    {
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c];
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c];
        List<Id> eveIds=new List<Id>();
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        Test.startTest();
        PMP_SearchEventDetailController.getEventPartners(eveIds,parIds);
        
        
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
        PMP_SearchEventDetailController.getEventOffCount(eventTag,eveIds);
        PMP_SearchEventDetailController.getEventCount('',eventTag,parIds,offIds);
        PMP_SearchEventDetailController.getEventPartnerCount(eventTag,parIds);
        Test.stopTest();
        
    }
    
    
    
    
    
}