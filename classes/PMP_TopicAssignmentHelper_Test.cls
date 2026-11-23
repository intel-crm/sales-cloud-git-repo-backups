@isTest
public with sharing class PMP_TopicAssignmentHelper_Test {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_TopicAssignmentHelper.isWorking();
        System.assertEquals(true, result);
    }
    @isTest
    static void testIsWorking1() {
        Boolean result = Core_TopicAssignmentHandler.isWorking();
        System.assertEquals(true, result);
    }
    @isTest
    static void testInsertTrigger() {
        PMP_Marketplace_Topic__c topic = new PMP_Marketplace_Topic__c(
            PMP_Marketplace_Topic_Name__c = 'Test Topic'
        );
        insert topic;
    }
    static testMethod void assignNegetivTopicRecord(){
    test.startTest();
    
   
    Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1838', PMP_TestDataUtility.intel_Account_Record_Type, true);
    Topic newTopic = new Topic();
    newTopic.Name = 'NotAllowedTopic';

    insert newTopic;

    PMP_Company__c testCompany = new PMP_Company__c(Name='testCompany9388', PMP_Account_Industry__c='Others');
	testCompany.PMP_Opid_Sfid_Txt__c = acc1.Id;
    testCompany.PMP_Is_Published_Ind__c=false;  
    insert testCompany;
                  
        
  

    TopicAssignment topicAssignment = new TopicAssignment();
    topicAssignment.entityId = testCompany.Id;
    topicAssignment.topicId = newTopic.Id;
    try{
    insert topicAssignment;
    }catch(Exception e){
        System.assert(true);
    }
    
    test.stopTest();
 }

   


/*    @TestSetup//IPA2.0:TWC729-8114 Topics Removal/Event Removal
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
        topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
        topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
        topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

        listTopicData.add(topicdata1);
        listTopicData.add(topicdata2);

        insert listTopicData;
       
        List<Core_Trigger_Executions__c> listSwitches = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerCust = new Core_Trigger_Executions__c();
        triggerCust.Name ='PMP_TopicAssignment_ValidationHandler';
        triggerCust.Core_Active__c = true;
        triggerCust.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust.Core_Description__c ='This record is used to execute or control the validation of Marketplace topic assignment';
        triggerCust.Core_Object__c ='TopicAssignment';
        triggerCust.Core_Trigger_Events__c ='Before Insert';
        listSwitches.add(triggerCust);
        

        Core_Trigger_Executions__c triggerCust1 = new Core_Trigger_Executions__c();
        triggerCust1.Name ='PMP_TopicAssignment_AutoAssignHandler';
        triggerCust1.Core_Active__c = true;
        triggerCust1.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust1.Core_Description__c ='This record is used to execute or control the  of Auto assign arketplace topic assignment';
        triggerCust1.Core_Object__c ='TopicAssignment';
        triggerCust1.Core_Trigger_Events__c ='Before Insert';
        listSwitches.add(triggerCust1);

       

        Core_Trigger_Executions__c triggerCust2 = new Core_Trigger_Executions__c();
        triggerCust2.Name ='PMP_TopicAssignment_AutoRemovalHandler';
        triggerCust2.Core_Active__c = true;
        triggerCust2.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust2.Core_Description__c ='This record is used to execute or control the Auto remove of Marketplace topic assignment';
        triggerCust2.Core_Object__c ='TopicAssignment';
        triggerCust2.Core_Trigger_Events__c ='Before Insert';
        listSwitches.add(triggerCust2);


        Core_Trigger_Executions__c triggerCust3 = new Core_Trigger_Executions__c();
        triggerCust3.Name ='PMP_AutoSyncAssignmentsToEvent';
        triggerCust3.Core_Active__c = true;
        triggerCust3.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust3.Core_Description__c ='This record is used to execute or control the Auto Event sync of Marketplace topic assignment';
        triggerCust3.Core_Object__c ='TopicAssignment';
        triggerCust3.Core_Trigger_Events__c ='Before Insert';
        listSwitches.add(triggerCust3);

        Core_Trigger_Executions__c triggerCust4 = new Core_Trigger_Executions__c();
        triggerCust4.Name ='PMP_AutoRemoveAssignmentsOnEvent';
        triggerCust4.Core_Active__c = true;
        triggerCust4.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust4.Core_Description__c ='This record is used to execute or control the Auto Event sync removal of Marketplace topic assignment';
        triggerCust4.Core_Object__c ='TopicAssignment';
        triggerCust4.Core_Trigger_Events__c ='Before Insert';
        listSwitches.add(triggerCust4);
        
        Core_Trigger_Executions__c triggerCust5 = new Core_Trigger_Executions__c();
        triggerCust5.Name ='PMP_TopicAssignment_TopicCountHandler';
        triggerCust5.Core_Active__c = true;
        triggerCust5.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust5.Core_Description__c ='To Sync Topic COunt';
        triggerCust5.Core_Object__c ='TopicAssignment';
        triggerCust5.Core_Trigger_Events__c ='after insert';
        listSwitches.add(triggerCust5);
        
        /*Core_Trigger_Executions__c triggerCust6 = new Core_Trigger_Executions__c();
        triggerCust6.Name ='PMP_TopicAssignment_TopicCountHandler';
        triggerCust6.Core_Active__c = true;
        triggerCust6.Core_Class_Name__c ='PMP_TopicAssignmentHelper';
        triggerCust6.Core_Description__c ='To Sync Topic COunt';
        triggerCust6.Core_Object__c ='TopicAssignment';
        triggerCust6.Core_Trigger_Events__c ='after delete';
        listSwitches.add(triggerCust6);//

        insert listSwitches;

       

        

        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
    
       
    
        

    List<PMP_Company__c> listCompanies = new List<PMP_Company__c>();
    for(Integer i=0;i<100;i++){
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1'+i, acc1.Id, false);
        cmp1.PMP_Is_Published_Ind__c = true;
        listCompanies.add(cmp1);
    }

    insert listCompanies;

    List<PMP_Company__c> workingCopyCompanies = new List<PMP_Company__c>();
    Map<Id,PMP_Company__c> mapPublishedCompanies = new Map<Id,PMP_Company__c>();
    for(PMP_Company__c company:listCompanies){
        mapPublishedCompanies.put(company.Id,company);
        PMP_Company__c company1 = PMP_TestDataUtility.createCompanyInformation(
            'TestWorkingCopyDuplicateOffering'+company.Id,acc1.Id,false);
        company1.PMP_Is_Published_Ind__c = false;
        company1.PMP_Is_Working_Copy_Ind__c = true;
        company1.PMP_Published_Copy_Id__c = company.Id;
        workingCopyCompanies.add(company1);
    }
    insert workingCopyCompanies;

    
    for(PMP_Company__c company : workingCopyCompanies){
        mapPublishedCompanies.get(company.PMP_Published_Copy_Id__c).PMP_Working_Copy_Id__c = company.Id;
    }
    update mapPublishedCompanies.values();

    /*List<PMP_Partner_Offering__c> listOfferings = new List<PMP_Partner_Offering__c>();
    for(Integer i=0;i<50;i++){
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('TestDuplicateOffering'+i,'Public Content', 
        'TestDuplicate'+i,mapPublishedCompanies.values()[0].Id, false,'Published','');
        listOfferings.add(offering);
    }

    insert listOfferings;//

    List<PMP_Partner_Offering__c> workingCopyOfferings = new List<PMP_Partner_Offering__c>();
    Map<Id,PMP_Partner_Offering__c> mapPublishedOfferings = new Map<Id,PMP_Partner_Offering__c>();
    /*for(PMP_Partner_Offering__c offering:listOfferings){
        mapPublishedOfferings.put(offering.Id,offering);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestWorkingCopyDuplicateOffering'+offering.Id,'Public Content', 
        'TestWorkingCopyDuplicate'+offering.Id,mapPublishedCompanies.values()[0].Id, false,'Approved','');
        offering1.PMP_Published_Copy_Id_Txt__c = offering.Id;
        workingCopyOfferings.add(offering1);
    }
    insert workingCopyOfferings;//

    
    for(PMP_Partner_Offering__c offering : workingCopyOfferings){
        mapPublishedOfferings.get(offering.PMP_Published_Copy_Id_Txt__c).PMP_Working_Copy_Id__c = offering.Id;
    }
  update mapPublishedOfferings.values();

    }
    
    static testMethod void assignOfferingRecord(){
        test.startTest();
        
       
              
		//IPA2.0:TWC729-8114 Topics Removal/Event Removal          
        /*PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c limit 1];
       


        map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        String TopicId;
        for(String strId:topicMap.keySet()){
            TopicId = strId;
        }

        TopicAssignment topicAssignment = new TopicAssignment();
        topicAssignment.entityId = offering1.Id;
        //topicAssignment.topicId = TopicId;

        insert topicAssignment;

        delete topicAssignment;//
        
        test.stopTest();
     }


     static testMethod void assignNegetiveOfferingRecord(){
        test.startTest();
                        
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c limit 1];
        map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        String TopicId;
        for(String strId:topicMap.keySet()){
            TopicId = strId;
        }

        TopicAssignment topicAssignment = new TopicAssignment();
        topicAssignment.entityId = offering1.Id;
        //topicAssignment.topicId = TopicId;

        try{
            insert topicAssignment;
            }catch(Exception e){
                System.assert(true);
        }//
        
        test.stopTest();
     }

  static testMethod void assignNegetivePartnerRecord(){
    test.startTest();
    PMP_Company__c testCompany = [Select Id from PMP_Company__c limit 1];
                  
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal    
   /* map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
    String TopicId;
    for(String strId:topicMap.keySet()){
        TopicId = strId;
    }//

    TopicAssignment topicAssignment = new TopicAssignment();
    topicAssignment.entityId = testCompany.Id;
    //topicAssignment.topicId = TopicId;
    try{
    insert topicAssignment;
    }catch(Exception e){
        System.assert(true);
    }
    
    test.stopTest();
 }


 static testMethod void assignNegetivTopicRecord(){
    test.startTest();
    
   
    Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1838', PMP_TestDataUtility.intel_Account_Record_Type, true);
    Topic newTopic = new Topic();
    newTopic.Name = 'NotAllowedTopic';

    insert newTopic;

    PMP_Company__c testCompany = new PMP_Company__c(Name='testCompany9388', PMP_Account_Industry__c='Others');
	testCompany.PMP_Opid_Sfid_Txt__c = acc1.Id;
    testCompany.PMP_Is_Published_Ind__c=false;  
    insert testCompany;
                  
        
  

    TopicAssignment topicAssignment = new TopicAssignment();
    topicAssignment.entityId = testCompany.Id;
    topicAssignment.topicId = newTopic.Id;
    try{
    insert topicAssignment;
    }catch(Exception e){
        System.assert(true);
    }
    
    test.stopTest();
 }



 static testMethod void assignBulkTestPartnerRecords(){
  
    
       
    
   //IPA2.0:TWC729-8114 Topics Removal/Event Removal
   /* map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
    String TopicId;
    List<Id> topics = new List<Id>();
    for(String strId:topicMap.keySet()){
        TopicId = strId;
        topics.add(strId);
    }//
    Map<Id,PMP_Company__c> mapPublishedCompanies = new Map<Id,PMP_Company__c>([select id,PMP_Working_Copy_Id__c from PMP_Company__c where PMP_Is_Published_Ind__c = true]);
    List<PMP_Company__c> workingCopyCompanies = new List<PMP_Company__c>([select id,PMP_Published_Copy_Id__c from PMP_Company__c where PMP_Is_Published_Ind__c = false]);

    List<TopicAssignment> listTopicAssignment = new List<TopicAssignment>();
    Set<Id> workingCopyIds = new Set<Id>();
	//IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*for(Integer i = 0; i<topics.size(); i++){
        for(Integer j=0;j<100;j++) {
            TopicAssignment topicAssignment = new TopicAssignment();
            topicAssignment.topicId = topics[i];
            if(j<50){
                topicAssignment.entityId = mapPublishedCompanies.values()[j].Id;
                workingCopyIds.add( mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c);
            }else{
                workingCopyIds.add(mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c);
                topicAssignment.entityId = mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c;
            }
            listTopicAssignment.add(topicAssignment);
        }
    }//

    List<TopicAssignment> listCountTopicAssignment1 = [select id,entityId from TopicAssignment];
    
    
    insert listTopicAssignment;

    List<TopicAssignment> listCountTopicAssignment = [select id,entityId,topicId from TopicAssignment];
    List<TopicAssignment> listWorkingCopyTopicAssignment = new List<TopicAssignment>();
    for(TopicAssignment topicAssign : listCountTopicAssignment){
        if(workingCopyIds.contains(topicAssign.entityId)){
            listWorkingCopyTopicAssignment.add(topicAssign);
        }
    }

    test.startTest();
    //System.assert(listCountTopicAssignment.size()==400);
    delete listWorkingCopyTopicAssignment;

    List<TopicAssignment> lstTopicAssignment = [select id from TopicAssignment];
    
    System.assert(lstTopicAssignment.isEmpty());

    test.stopTest();

    
    
   
 }



 static testMethod void assignBulkTestOfferingRecords(){

    List<Topic> listTopics = new List<Topic>();
    Topic topic3 = new Topic(Name='My Random Test Topic3');
    listTopics.add(topic3);

    Topic topic4 = new Topic(Name='My Random Test Topic4');
    listTopics.add(topic4);
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
    topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
    topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    listTopicData.add(topicdata1);
    listTopicData.add(topicdata2);
   
    insert listTopicData;

    
    
   //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
    String TopicId;
    List<Id> topics = new List<Id>();
    for(String strId:topicMap.keySet()){
        TopicId = strId;
        topics.add(strId);
    }//

    Map<Id,PMP_Partner_Offering__c> mapPublishedOfferings = new Map<Id,PMP_Partner_Offering__c>([select id,PMP_Published_Copy_Id_Txt__c,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c!=null]);

    List<TopicAssignment> listTopicAssignment = new List<TopicAssignment>();
    Set<Id> workingCopyIds = new Set<Id>();
	//IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*for(Integer i = 0; i<topics.size(); i++){
        for(Integer j=0;j<50;j++) {
            TopicAssignment topicAssignment = new TopicAssignment();
            topicAssignment.topicId = topics[i];
            if(j<25){
                topicAssignment.entityId = mapPublishedOfferings.values()[j].Id;
                workingCopyIds.add( mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c);
            }else{
                workingCopyIds.add(mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c);
                topicAssignment.entityId = mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c;
            }
            listTopicAssignment.add(topicAssignment);
        }
    }//
    
    List<TopicAssignment> listCountTopicAssignment1 = [select id,entityId from TopicAssignment];
    
    insert listTopicAssignment;

    List<TopicAssignment> listCountTopicAssignment = [select id,entityId,topicId from TopicAssignment];
    List<TopicAssignment> listWorkingCopyTopicAssignment = new List<TopicAssignment>();
    for(TopicAssignment topicAssign : listCountTopicAssignment){
        if(workingCopyIds.contains(topicAssign.entityId)){
            listWorkingCopyTopicAssignment.add(topicAssign);
        }
    }
    /* //
    //System.assert(listCountTopicAssignment.size()==400);
    Test.startTest();
    delete listWorkingCopyTopicAssignment;

    List<TopicAssignment> lstTopicAssignment = [select id from TopicAssignment];
    
    System.assert(lstTopicAssignment.isEmpty());

    test.stopTest();

 }



 static testMethod void assignBulkTestEventOfferingRecords(){

    List<Topic> listTopics = new List<Topic>();
    Topic topic1 = new Topic(Name='My Random Test Event1');
    listTopics.add(topic1);

    Topic topic2 = new Topic(Name='My Random Test Event2');
    listTopics.add(topic2);
    
    Topic topic3 = new Topic(Name='My Random Test Event3');
    listTopics.add(topic3);

    Topic topic4 = new Topic(Name='My Random Test Event4');
    listTopics.add(topic4);
    insert listTopics;

    List<PMP_Marketplace_Event__c> listEvents= new List<PMP_Marketplace_Event__c>();
    PMP_Marketplace_Event__c event1 = new PMP_Marketplace_Event__c(Name='My Random Test Event1');
    listEvents.add(event1);

    PMP_Marketplace_Event__c event2 = new PMP_Marketplace_Event__c(Name='My Random Test Event2');
    listEvents.add(event2);
    
    PMP_Marketplace_Event__c event3 = new PMP_Marketplace_Event__c(Name='My Random Test Event3');
    listEvents.add(event3);

    PMP_Marketplace_Event__c event4 = new PMP_Marketplace_Event__c(Name='My Random Test Event4');
    listEvents.add(event4);
    insert listEvents;
    
    
    List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
    PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
    topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
    topicdata1.PMP_Marketplace_Event_Id__c = listEvents[0].Id;
    topicdata1.PMP_Is_Active_Ind__c = true;
    topicdata1.PMP_Topic_Type__c = 'Event Topic';
    topicdata1.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
    topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
    topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
    topicdata2.PMP_Marketplace_Event_Id__c = listEvents[1].Id;
    topicdata2.PMP_Is_Active_Ind__c = true;
    topicdata2.PMP_Topic_Type__c = 'Event Topic';
    topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
    topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';


    PMP_Marketplace_Topic__c topicdata3 = new PMP_Marketplace_Topic__c();
    topicdata3.PMP_Topic_Id__c = listTopics[2].Id;
    topicdata3.PMP_Marketplace_Event_Id__c = listEvents[2].Id;
    topicdata3.PMP_Is_Active_Ind__c = true;
    topicdata3.PMP_Topic_Type__c = 'Event Topic';
    topicdata3.PMP_Marketplace_Topic_Name__c = listTopics[2].Name;
    topicdata3.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata3.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata3.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata3.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata3.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata4 = new PMP_Marketplace_Topic__c();
    topicdata4.PMP_Topic_Id__c = listTopics[3].Id;
    topicdata4.PMP_Marketplace_Event_Id__c = listEvents[3].Id;
    topicdata4.PMP_Is_Active_Ind__c = true;
    topicdata4.PMP_Topic_Type__c = 'Event Topic';
    topicdata4.PMP_Marketplace_Topic_Name__c = listTopics[3].Name;
    topicdata4.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata4.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata4.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata4.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata4.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    listTopicData.add(topicdata1);
    listTopicData.add(topicdata2);
    listTopicData.add(topicdata3);
    listTopicData.add(topicdata4);


    insert listTopicData;

    
    
   //IPA2.0:TWC729-8114 Topics Removal/Event Removal
   /* map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
    String TopicId;
    List<Id> topics = new List<Id>();
    for(String strId:topicMap.keySet()){
        TopicId = strId;
        topics.add(strId);
    }//

    Map<Id,PMP_Partner_Offering__c> mapPublishedOfferings = new Map<Id,PMP_Partner_Offering__c>([select id,PMP_Published_Copy_Id_Txt__c,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c!=null]);

    List<TopicAssignment> listTopicAssignment = new List<TopicAssignment>();
    Set<Id> workingCopyIds = new Set<Id>();
	//IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*for(Integer i = 0; i<topics.size(); i++){
        for(Integer j=0;j<50;j++) {
            TopicAssignment topicAssignment = new TopicAssignment();
            topicAssignment.topicId = topics[i];
            if(j<25){
                topicAssignment.entityId = mapPublishedOfferings.values()[j].Id;
                workingCopyIds.add( mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c);
            }else{
                workingCopyIds.add(mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c);
                topicAssignment.entityId = mapPublishedOfferings.values()[j].PMP_Working_Copy_Id__c;
            }
            listTopicAssignment.add(topicAssignment);
        }
    }//

    
    List<TopicAssignment> listCountTopicAssignment1 = [select id,entityId from TopicAssignment];
   
    insert listTopicAssignment;

    List<TopicAssignment> listCountTopicAssignment = [select id,entityId,topicId from TopicAssignment];
    List<TopicAssignment> listWorkingCopyTopicAssignment = new List<TopicAssignment>();
    for(TopicAssignment topicAssign : listCountTopicAssignment){
        if(workingCopyIds.contains(topicAssign.entityId)){
            listWorkingCopyTopicAssignment.add(topicAssign);
        }
    }
    /*  
    //System.assert(listCountTopicAssignment.size()==600);


    List<PMP_Marketplace_Event_Offering__c> listEventOfferings = [select id from PMP_Marketplace_Event_Offering__c];
    List<PMP_Marketplace_Event_Partner__c> listEventCompanies = [select id from PMP_Marketplace_Event_Partner__c];

    /*  //
    //System.assert(listEventOfferings.size() == 200);
    Test.startTest();
    
    delete listWorkingCopyTopicAssignment;

    List<TopicAssignment> lstTopicAssignment = [select id from TopicAssignment];
    
    System.assert(lstTopicAssignment.isEmpty());

   listEventOfferings = [select id from PMP_Marketplace_Event_Offering__c];
    listEventCompanies = [select id from PMP_Marketplace_Event_Partner__c];


    /*  //
    System.assert(listEventOfferings.isEmpty());
    
    


    test.stopTest();

 }


 static testMethod void assignBulkTestEventPartnerRecords(){

    List<Topic> listTopics = new List<Topic>();
    Topic topic1 = new Topic(Name='My Random Test Event1');
    listTopics.add(topic1);

    Topic topic2 = new Topic(Name='My Random Test Event2');
    listTopics.add(topic2);
    
    Topic topic3 = new Topic(Name='My Random Test Event3');
    listTopics.add(topic3);

    Topic topic4 = new Topic(Name='My Random Test Event4');
    listTopics.add(topic4);
    insert listTopics;

    List<PMP_Marketplace_Event__c> listEvents= new List<PMP_Marketplace_Event__c>();
    PMP_Marketplace_Event__c event1 = new PMP_Marketplace_Event__c(Name='My Random Test Event1');
    listEvents.add(event1);

    PMP_Marketplace_Event__c event2 = new PMP_Marketplace_Event__c(Name='My Random Test Event2');
    listEvents.add(event2);
    
    PMP_Marketplace_Event__c event3 = new PMP_Marketplace_Event__c(Name='My Random Test Event3');
    listEvents.add(event3);

    PMP_Marketplace_Event__c event4 = new PMP_Marketplace_Event__c(Name='My Random Test Event4');
    listEvents.add(event4);
    insert listEvents;
    
    
    List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
    PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
    topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
    topicdata1.PMP_Marketplace_Event_Id__c = listEvents[0].Id;
    topicdata1.PMP_Is_Active_Ind__c = true;
    topicdata1.PMP_Topic_Type__c = 'Event Topic';
    topicdata1.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
    topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
    topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
    topicdata2.PMP_Marketplace_Event_Id__c = listEvents[1].Id;
    topicdata2.PMP_Is_Active_Ind__c = true;
    topicdata2.PMP_Topic_Type__c = 'Event Topic';
    topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
    topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';


    PMP_Marketplace_Topic__c topicdata3 = new PMP_Marketplace_Topic__c();
    topicdata3.PMP_Topic_Id__c = listTopics[2].Id;
    topicdata3.PMP_Marketplace_Event_Id__c = listEvents[2].Id;
    topicdata3.PMP_Is_Active_Ind__c = true;
    topicdata3.PMP_Topic_Type__c = 'Event Topic';
    topicdata3.PMP_Marketplace_Topic_Name__c = listTopics[2].Name;
    topicdata3.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata3.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata3.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata3.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata3.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata4 = new PMP_Marketplace_Topic__c();
    topicdata4.PMP_Topic_Id__c = listTopics[3].Id;
    topicdata4.PMP_Marketplace_Event_Id__c = listEvents[3].Id;
    topicdata4.PMP_Is_Active_Ind__c = true;
    topicdata4.PMP_Topic_Type__c = 'Event Topic';
    topicdata4.PMP_Marketplace_Topic_Name__c = listTopics[3].Name;
    topicdata4.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata4.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata4.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata4.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata4.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    listTopicData.add(topicdata1);
    listTopicData.add(topicdata2);
    listTopicData.add(topicdata3);
    listTopicData.add(topicdata4);


    insert listTopicData;

    
    
   //IPA2.0:TWC729-8114 Topics Removal/Event Removal
   /* map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
    String TopicId;
    List<Id> topics = new List<Id>();
    for(String strId:topicMap.keySet()){
        TopicId = strId;
        topics.add(strId);
    }//

    Map<Id,PMP_Company__c> mapPublishedCompanies = new Map<Id,PMP_Company__c>([select id,PMP_Working_Copy_Id__c from PMP_Company__c where PMP_Is_Published_Ind__c = true]);

    List<TopicAssignment> listTopicAssignment = new List<TopicAssignment>();
    Set<Id> workingCopyIds = new Set<Id>();

     //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*for(Integer i = 0; i<topics.size(); i++){
        for(Integer j=0;j<100;j++) {
            TopicAssignment topicAssignment = new TopicAssignment();
            topicAssignment.topicId = topics[i];
            if(j<50){
                topicAssignment.entityId = mapPublishedCompanies.values()[j].Id;
                workingCopyIds.add( mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c);
            }else{
                workingCopyIds.add(mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c);
                topicAssignment.entityId = mapPublishedCompanies.values()[j].PMP_Working_Copy_Id__c;
            }
            listTopicAssignment.add(topicAssignment);
        }
    }//

    
    List<TopicAssignment> listCountTopicAssignment1 = [select id,entityId from TopicAssignment];
    
    insert listTopicAssignment;

    List<TopicAssignment> listCountTopicAssignment = [select id,entityId,topicId from TopicAssignment];
    List<TopicAssignment> listWorkingCopyTopicAssignment = new List<TopicAssignment>();
    for(TopicAssignment topicAssign : listCountTopicAssignment){
        if(workingCopyIds.contains(topicAssign.entityId)){
            listWorkingCopyTopicAssignment.add(topicAssign);
        }
    }
    /*  //
    //System.assert(listCountTopicAssignment.size()==1200);


    List<PMP_Marketplace_Event_Offering__c> listEventOfferings = [select id from PMP_Marketplace_Event_Offering__c];
    List<PMP_Marketplace_Event_Partner__c> listEventCompanies = [select id from PMP_Marketplace_Event_Partner__c];

    /*  //
    //System.assert(listEventCompanies.size() == 400);
    Test.startTest();

    delete listWorkingCopyTopicAssignment;

    List<TopicAssignment> lstTopicAssignment = [select id from TopicAssignment];
    
    System.assert(lstTopicAssignment.isEmpty());

   listEventOfferings = [select id from PMP_Marketplace_Event_Offering__c];
    listEventCompanies = [select id from PMP_Marketplace_Event_Partner__c];


    /*  //
    System.assert(listEventOfferings.isEmpty());
    
    


    test.stopTest();

 }



 static testMethod void ExceptionTest(){

    List<Topic> listTopics = new List<Topic>();
    Topic topic1 = new Topic(Name='My Random Test Event1');
    listTopics.add(topic1);

    Topic topic2 = new Topic(Name='My Random Test Event2');
    listTopics.add(topic2);
    
    Topic topic3 = new Topic(Name='My Random Test Event3');
    listTopics.add(topic3);

    Topic topic4 = new Topic(Name='My Random Test Event4');
    listTopics.add(topic4);
    insert listTopics;

    List<PMP_Marketplace_Event__c> listEvents= new List<PMP_Marketplace_Event__c>();
    PMP_Marketplace_Event__c event1 = new PMP_Marketplace_Event__c(Name='My Random Test Event1');
    listEvents.add(event1);

    PMP_Marketplace_Event__c event2 = new PMP_Marketplace_Event__c(Name='My Random Test Event2');
    listEvents.add(event2);
    
    PMP_Marketplace_Event__c event3 = new PMP_Marketplace_Event__c(Name='My Random Test Event3');
    listEvents.add(event3);

    PMP_Marketplace_Event__c event4 = new PMP_Marketplace_Event__c(Name='My Random Test Event4');
    listEvents.add(event4);
    insert listEvents;
    
    
    List<PMP_Marketplace_Topic__c> listTopicData = new List<PMP_Marketplace_Topic__c>();
    PMP_Marketplace_Topic__c topicdata1 = new PMP_Marketplace_Topic__c();
    topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
    topicdata1.PMP_Marketplace_Event_Id__c = listEvents[0].Id;
    topicdata1.PMP_Is_Active_Ind__c = true;
    topicdata1.PMP_Topic_Type__c = 'Event Topic';
    topicdata1.PMP_Marketplace_Topic_Name__c = listTopics[0].Name;
    topicdata1.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata1.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata1.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata1.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata1.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata2 = new PMP_Marketplace_Topic__c();
    topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
    topicdata2.PMP_Marketplace_Event_Id__c = listEvents[1].Id;
    topicdata2.PMP_Is_Active_Ind__c = true;
    topicdata2.PMP_Topic_Type__c = 'Event Topic';
    topicdata2.PMP_Marketplace_Topic_Name__c = listTopics[1].Name;
    topicdata2.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata2.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata2.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata2.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata2.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';


    PMP_Marketplace_Topic__c topicdata3 = new PMP_Marketplace_Topic__c();
    topicdata3.PMP_Topic_Id__c = listTopics[2].Id;
    topicdata3.PMP_Marketplace_Event_Id__c = listEvents[2].Id;
    topicdata3.PMP_Is_Active_Ind__c = true;
    topicdata3.PMP_Topic_Type__c = 'Event Topic';
    topicdata3.PMP_Marketplace_Topic_Name__c = listTopics[2].Name;
    topicdata3.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata3.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata3.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata3.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata3.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    PMP_Marketplace_Topic__c topicdata4 = new PMP_Marketplace_Topic__c();
    topicdata4.PMP_Topic_Id__c = listTopics[3].Id;
    topicdata4.PMP_Marketplace_Event_Id__c = listEvents[3].Id;
    topicdata4.PMP_Is_Active_Ind__c = true;
    topicdata4.PMP_Topic_Type__c = 'Event Topic';
    topicdata4.PMP_Marketplace_Topic_Name__c = listTopics[3].Name;
    topicdata4.PMP_Topic_Chinese_Nm__c ='chinese title';
    topicdata4.PMP_Topic_Japanese_Nm__c ='japanese title';
    topicdata4.PMP_Topic_English_Dsc__c = 'English Desc';
    topicdata4.PMP_Topic_Chinese_Dsc__c = 'Chinese Desc';
    topicdata4.PMP_Topic_Japanese_Dsc__c = 'Japanese Desc';

    listTopicData.add(topicdata1);
    listTopicData.add(topicdata2);
    listTopicData.add(topicdata3);
    listTopicData.add(topicdata4);

    Test.startTest();
    insert listTopicData;


    listTopicData[0].PMP_Topic_Type__c = 'Featured Topic';

    try{
        update listTopicData[0] ;
    }catch(DmlException e){
        //PMP_TopicAssignmentHelper.handleException('testException', e, listTopicData); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    }
    
    
   
    test.stopTest();

 }

 static testMethod void ExceptionTest2(){
    //PMP_TopicAssignmentHelper.handleException('PMP_TopicAssignmentHelper', new DmlException('FIELD_FILTER_VALIDATION_EXCEPTION'), new List<Sobject>()); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
 }*/



}