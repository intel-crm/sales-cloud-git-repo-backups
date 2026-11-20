@IsTest
public with sharing class PMP_MarketplaceTopics_Test {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_MarketplaceTopics.isWorking();
        System.assertEquals(true, result);
    }


/*    @TestSetup //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    static void makeData(){
    
        list<Topic> listTopics = new List<Topic>();                                                                                 
        Topic topic = new Topic(Name='My Random Test Topic1');
        listTopics.add(topic);

        Topic topic2 = new Topic(Name='My Random Test Topic2');
        listTopics.add(topic2);
        insert listTopics;


        List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
        PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
        topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
        topicdata1.PMP_Is_Active_Ind__c = true;
        topicdata1.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
        topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
        topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
        topicdata2.PMP_Is_Active_Ind__c = true;
        topicdata2.PMP_Topic_Type__c = 'Event Topic';
        topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
        topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        listTopicData.add(topicdata1);
        listTopicData.add(topicdata2);

        insert listTopicData;
        

       

        
    }
    /*static testMethod void assignTaxonomyEnglish(){
        test.startTest();
        map<Id,PMP_Marketplace_Topic__c> topicMetadata=PMP_MarketplaceTopics.getTopicMetadata();
        PMP_MarketplaceTopics.getAllEventTopicsMetadata();
        System.assertNotEquals(null, topicMetadata, 'Expected topic metadata should not be null');

        test.stopTest();
     }*/

   /*static testMethod void getEventTopicType(){
        test.startTest();
        PMP_Marketplace_Topic__c tpData = [SELECT Id FROM PMP_Marketplace_Topic__c LIMIT 1];

        PMP_MarketplaceTopics.getEventTopicType(String.valueOf(tpData.id));
        test.stopTest();
     }*/

   /*static testMethod void getCloneImageToEvent(){
        test.startTest();
        PMP_Marketplace_Topic__c tpData = [SELECT Id FROM PMP_Marketplace_Topic__c LIMIT 1];

        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c(Name='Test Event',PMP_Event_Banner_Language__c='English',
                                                                      
                                                                     PMP_Marketplace_Event_Tagline__c='tag',PMP_Marketplace_Event_Start_Dt__c=System.today(),
                                                                     PMP_Marketplace_Event_End_Dt__c=SYSTEM.today());
        insert event;
        tpData.PMP_Marketplace_Event_Id__c = event.id;

        update tpData;
        PMP_MarketplaceTopics.cloneImageToEvents(String.valueOf(tpData.id));
        test.stopTest();
     }*/

}