@IsTest
public with sharing class PMP_Marketplace_Topic_Helper_Test {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_Marketplace_Topic_Helper.isWorking();
        System.assertEquals(true, result);
    }
	@isTest
    static void testIsWorking1() {
        Boolean result = PMP_Marketplace_Topic_Handler.isWorking();
        System.assertEquals(true, result);
    }
    @isTest
    static void testInsertTrigger() {
        PMP_Marketplace_Topic__c topic = new PMP_Marketplace_Topic__c(
            PMP_Marketplace_Topic_Name__c = 'Test Topic'
        );
        insert topic;
    }

    /*static testMethod void createMarketplaceTopicRecord(){//IPA2.0:TWC729-8114 Topics Removal/Event Removal
        
        Core_Trigger_Executions__c triggerCust = new Core_Trigger_Executions__c();
        triggerCust.Name ='PMP_Marketplace_AutoTopic_Insert';
        triggerCust.Core_Active__c = true;
        triggerCust.Core_Class_Name__c ='PMP_TopicAssignmentHandler';
        triggerCust.Core_Description__c ='This record is used to execute or control the validation of Marketplace topic assignment';
        triggerCust.Core_Object__c ='PMP_Marketplace_Topic__c';
        triggerCust.Core_Trigger_Events__c ='Before Insert';

        Core_Trigger_Executions__c triggerCust1 = new Core_Trigger_Executions__c();
        triggerCust1.Name ='PMP_Marketplace_AutoEvent_Upsert';
        triggerCust1.Core_Active__c = true;
        triggerCust1.Core_Class_Name__c ='PMP_TopicAssignmentHandler';
        triggerCust1.Core_Description__c ='This record is used to execute or control the validation of Marketplace topic Event assignment';
        triggerCust1.Core_Object__c ='PMP_Marketplace_Topic__c';
        triggerCust1.Core_Trigger_Events__c ='Before Insert,Before Update';

        List<Core_Trigger_Executions__c> listTriggerExecutions = new List<Core_Trigger_Executions__c>();
        listTriggerExecutions.add(triggerCust);
        listTriggerExecutions.add(triggerCust1);

        insert listTriggerExecutions;
                    
        list<Topic> listTopics = new List<Topic>();                                                                                 
        Topic topic = new Topic(Name='topic1');
        listTopics.add(topic);
        insert listTopics;
       
        Test.startTest();
        List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();

        //for(Integer i = 0 ;i<200; i++){
        PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
        topicdata1.PMP_Is_Active_Ind__c = true;
        topicdata1.PMP_Topic_Type__c = 'Featured Topic';
        topicdata1.PMP_Marketplace_Topic_Name__c = 'topic1';
        topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        /*PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
        topicdata2.PMP_Is_Active_Ind__c = true;
        topicdata2.PMP_Marketplace_Topic_Name__c = 'topicE'+i;
        topicdata2.PMP_Topic_Type__c = 'Event Topic';
        topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';//

        listTopicData.add(topicdata1);
        //listTopicData.add(topicdata2);
        

        insert listTopicData;

        Test.stopTest();



        List<PMP_Marketplace_Topic__c> featuredTopics = [select id from PMP_Marketplace_Topic__c where PMP_Topic_Type__c = 'Featured Topic'];

        List<PMP_Marketplace_Topic__c> eventTopics= [select id from PMP_Marketplace_Topic__c where PMP_Topic_Type__c = 'Event Topic'];

        List<PMP_Marketplace_Event__c>  events = [select id from PMP_Marketplace_Event__c];

        List<PMP_Marketplace_Event_Translation__c> eventTrans = [select id from PMP_Marketplace_Event_Translation__c];
        
        List<Topic> topics = [select id from topic];
        
        //System.assert(featuredTopics.size()== 200);
        //System.assert(eventTopics.size()==200);
        //System.assert(events.size()==200);
        //System.assert(topics.size()==400);
        //System.assert(eventTrans.size()==400);

    
        
     }


     static testMethod void UpdateDuplicateTopicRecord(){
        test.startTest();
        
        Core_Trigger_Executions__c triggerCust = new Core_Trigger_Executions__c();
        triggerCust.Name ='PMP_Marketplace_AutoTopic_Insert';
        triggerCust.Core_Active__c = true;
        triggerCust.Core_Class_Name__c ='PMP_TopicAssignmentHandler';
        triggerCust.Core_Description__c ='This record is used to execute or control the validation of Marketplace topic assignment';
        triggerCust.Core_Object__c ='PMP_Marketplace_Topic__c';
        triggerCust.Core_Trigger_Events__c ='Before Insert';

        Core_Trigger_Executions__c triggerCust1 = new Core_Trigger_Executions__c();
        triggerCust1.Name ='PMP_Marketplace_AutoEvent_Upsert';
        triggerCust1.Core_Active__c = true;
        triggerCust1.Core_Class_Name__c ='PMP_TopicAssignmentHandler';
        triggerCust1.Core_Description__c ='This record is used to execute or control the validation of Marketplace topic Event assignment';
        triggerCust1.Core_Object__c ='PMP_Marketplace_Topic__c';
        triggerCust1.Core_Trigger_Events__c ='Before Insert,Before Update';

        List<Core_Trigger_Executions__c> listTriggerExecutions = new List<Core_Trigger_Executions__c>();
        listTriggerExecutions.add(triggerCust);
        listTriggerExecutions.add(triggerCust1);

        insert listTriggerExecutions;
                        
        list<Topic> listTopics = new List<Topic>();                                                                                 
        Topic topic = new Topic(Name='TestClassTopicOk');
        listTopics.add(topic);
                                                                              
        Topic topic2 = new Topic(Name='Test Test');
        listTopics.add(topic2);
        insert listTopics;
       
        List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
        PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
        topicdata1.PMP_Is_Active_Ind__c = true;
        topicdata1.PMP_Marketplace_Topic_Name__c = 'TestClassTopicOk';
        topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata1.PMP_Topic_Type__c = 'Event Topic';
        topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';


        PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
        topicdata2.PMP_Is_Active_Ind__c = true;
        topicdata2.PMP_Marketplace_Topic_Name__c = 'test test2';
        topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';


        insert topicdata1;
        

        try{
            insert topicdata2;
        }catch(Exception e){
                System.assert(true);
        }


       topicdata1.PMP_Topic_Type__c = 'Featured Topic';
        try{
         update topicdata1;
        }catch(DmlException e){
            System.assert(true);
        }

        topicdata1.PMP_Topic_Type__c = 'Event Topic';
        topicdata1.PMP_Topic_Chinese_Nm__c ='chinese name';
        update topicdata1;


        // insert duplicate topic
        PMP_Marketplace_Topic__c dupTopic = new PMP_Marketplace_Topic__c();
        dupTopic.PMP_Is_Active_Ind__c = true;
        dupTopic.PMP_Marketplace_Topic_Name__c = 'testtest';
        dupTopic.PMP_Topic_Chinese_Nm__c ='chinese title';
        dupTopic.PMP_Topic_Type__c = 'Event Topic';
        dupTopic.PMP_Topic_Japanese_Nm__c ='japanese title';
        dupTopic.PMP_Topic_English_Dsc__c = 'English Desc';
        dupTopic.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        dupTopic.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';
        try{
            insert dupTopic;
        }catch(DmlException e){
            system.assert(true);
        }

        topicdata1.PMP_Marketplace_Event_Start_Dt__c = Date.today();
        topicdata1.PMP_Marketplace_Event_End_Dt__c = Date.today()-1;
       try{
        //PMP_Marketplace_Topic_Helper.upsertEventRecords(new List<PMP_Marketplace_Topic__c>{topicdata1}); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
       }catch(DmlException e){
            system.assert(true);
       }
        
        test.stopTest();
    }*/

}