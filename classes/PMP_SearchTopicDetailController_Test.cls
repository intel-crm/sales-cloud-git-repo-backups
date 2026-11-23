//test class for the class PMP_SearchTopicDetailController

@isTest
public class PMP_SearchTopicDetailController_Test extends PMP_SearchWrapperStore {
    @TestSetup
    static void makeData(){
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = new PMP_Company__c(Name='Testcmp1', PMP_Account_Industry__c='Others');
        cmp1.PMP_Opid_Sfid_Txt__c = acc1.Id;
        cmp1.PMP_Is_Published_Ind__c=true;  
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Benefit_Update_Ind__c = false;
        insert cmp1;
        
        PMP_Company__c cmp2 = new PMP_Company__c(Name='Testcmp2', PMP_Account_Industry__c='Others');
        cmp2.PMP_Opid_Sfid_Txt__c = acc1.Id;
        cmp2.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp2.PMP_Is_Published_Ind__c=false;  
        cmp2.PMP_Benefit_Update_Ind__c = false;
        insert cmp2;
        
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Published','');
        offering1.PMP_Is_Not_Available_On_MP_Ind__c=false;
        offering1.PMP_Partner_Offering_Start_Dt__c=System.today()-1;
        offering1.PMP_Partner_Offering_End_Dt__c=System.today()+1;
        
        update offering1;
        
        System.debug('Test - offering1:'+offering1);
        PMP_Partner_Offering_Translation__c trans= new PMP_Partner_Offering_Translation__c();
        trans.PMP_Partner_Offering_Id__c=offering1.Id;
        trans.PMP_English_Txt__c='TestDuplicateOffering';
        trans.PMP_Chinese_Txt__c='TestDuplicateOffering';
        trans.PMP_Japanese_Txt__c='TestDuplicateOffering';
        trans.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        
        PMP_Partner_Offering_Translation__c trans1= new PMP_Partner_Offering_Translation__c();
        trans1.PMP_Partner_Offering_Id__c=offering1.Id;
        trans1.PMP_English_Txt__c='TestDuplicateOffering';
        trans1.PMP_Chinese_Txt__c='TestDuplicateOffering';
        trans1.PMP_Japanese_Txt__c='TestDuplicateOffering';
        trans1.PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c';
        
        insert trans1;
        insert trans;

        list<Topic> listTopics = new List<Topic>();                                                                                 
        Topic topic = new Topic(Name='My Random Test Topic1');
        listTopics.add(topic);

        Topic topic2 = new Topic(Name='My Random Test Topic2');
        listTopics.add(topic2);
        insert listTopics;


        List<PMP_Marketplace_Topics_Data__c> listTopicData = new List<PMP_Marketplace_Topics_Data__c>();
        PMP_Marketplace_Topics_Data__c topicdata1 = new PMP_Marketplace_Topics_Data__c();
        topicdata1.PMP_Topic_Id__c = listTopics[0].Id;
        topicdata1.PMP_Is_Active__c = true;
        topicdata1.PMP_Topic_English_Title__c = listTopics[0].Name;
        topicdata1.PMP_Topic_Chinese_Title__c ='chinese title';
        topicdata1.PMP_Topic_Japanese_Title__c ='japanese title';
        topicdata1.PMP_Topic_English_Desc__c = 'English Desc';
        topicdata1.PMP_Topic_Chinese_Desc__c = 'Chinese Desc';
        topicdata1.PMP_Topic_Japanese_Desc__c = 'Japanese Desc';

        PMP_Marketplace_Topics_Data__c topicdata2 = new PMP_Marketplace_Topics_Data__c();
        topicdata2.PMP_Topic_Id__c = listTopics[1].Id;
        topicdata2.PMP_Is_Active__c = true;
        topicdata2.PMP_Topic_English_Title__c = listTopics[1].Name;
        topicdata2.PMP_Topic_Chinese_Title__c ='chinese title';
        topicdata2.PMP_Topic_Japanese_Title__c ='japanese title';
        topicdata2.PMP_Topic_English_Desc__c = 'English Desc';
        topicdata2.PMP_Topic_Chinese_Desc__c = 'Chinese Desc';
        topicdata2.PMP_Topic_Japanese_Desc__c = 'Japanese Desc';

        listTopicData.add(topicdata1);
        listTopicData.add(topicdata2);

        insert listTopicData;
       
        
                
        //map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        List<TopicAssignment> listTopicAssignments = new List<TopicAssignment>();
        list<Id> topicIds = new List<Id>();
        //topicIds.addAll(topicMap.keySet());
        TopicAssignment topicAssignment = new TopicAssignment();
        topicAssignment.entityId = offering1.Id;
        topicAssignment.topicId =  '0TO2i000000I2qSGAS';
        
        listTopicAssignments.add(topicAssignment);
        
        TopicAssignment topicAssignment1 = new TopicAssignment();
        topicAssignment1.entityId = cmp1.Id;
        topicAssignment1.topicId = '0TO2i000000I2qSGAS';
        listTopicAssignments.add(topicAssignment1);
        
        TopicAssignment topicAssignment2 = new TopicAssignment();
        topicAssignment2.entityId = cmp2.Id;
        topicAssignment2.topicId = '0TO2i000000I2qSGAS';
        listTopicAssignments.add(topicAssignment2);
        
        insert listTopicAssignments;
        
        PMP_Specification__c spec = new PMP_Specification__c();
        spec.name= 'Other Processors';
        spec.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors';
        spec.PMP_Active_Ind__c=true;
        spec.PMP_Partner_Product_Specification_Id__c = '122309';
        insert spec;
        
        PMP_Specification__c spec1 = new PMP_Specification__c();
        spec1.name= 'Processors';
        spec1.PMP_Active_Ind__c=TRUE;
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_Processors';
        insert spec1;
        
        spec.PMP_Parent_Specification_Id__c=spec1.Id;
        update spec;
        
        
        PMP_Category__c cattt= new PMP_Category__c();
        cattt.PMP_Active_Ind__c=true;
        cattt.PMP_Partner_Product_Category_Cd__c='NPP_01_Industry';
        cattt.PMP_Partner_Product_Category_Key__c = 'npp_01_industry';
        cattt.PMP_Partner_Product_Parent_Category_Cd__c  ='Solution_Marketplace_Hierarchy';
        cattt.Name='Industry';
        insert cattt;
        
        PMP_Category__c cattt1= new PMP_Category__c();
        cattt1.PMP_Active_Ind__c=true;
        cattt1.PMP_Partner_Product_Category_Cd__c='IPA_Ind_HealthCare';
        cattt.PMP_Partner_Product_Category_Key__c = 'ipa_ind_healthcare';
        cattt1.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_Industry';
        cattt1.PMP_Parent_Category_Id__c = cattt.Id;
        cattt1.Name='Healthcare';
        insert cattt1;
       
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='2-in-1';
        newPMPOfferingCat.PMP_Offering_Id__c=offering1.Id;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
        newPMPOfferingCat.PMP_Category_Id__c = cattt1.Id;
        insert newPMPOfferingCat;
        System.debug('Test newPMPOfferingCat'+newPMPOfferingCat);
        
        
        
        PMP_Partner_Category__c parCat = New PMP_Partner_Category__c();
        parCat.PMP_Category_Id__c = cattt1.Id;
        parCat.PMP_Partner_Id__c = cmp1.Id;
        insert parCat;
        system.debug('Test: parCat'+parCat);
        
        
    }
    
    @isTest
    public static void  getTopicDetailswithFiltersAndKeywordTest(){
        test.startTest();
        
        List<PMP_Partner_Offering_Translation__c> listTrans = [select id from PMP_Partner_Offering_Translation__c limit 2];
        list<Id> ids = new List<Id>();
        for(PMP_Partner_Offering_Translation__c trans:listTrans ){
            ids.add(trans.id);
        }
        Test.setFixedSearchResults(ids);
        map<Id,PMP_Marketplace_Topic__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        list<Id> topicIds = new List<Id>();
        topicIds.addAll(topicMap.keySet());
        //PMP_Marketplace_Topic__c topicData=topicMap.get(topicIds[0]);
        List<PMP_Specification__c> specs= [select id,name from PMP_Specification__c where name='Processors'];
        List<PMP_Partner_Offering_Category__c> categories= [select id,name,PMP_Category_Id__c from PMP_Partner_Offering_Category__c limit 1];
        Id cat=categories[0].PMP_Category_Id__c;
        Id spec=specs[0].Id;
        PMP_SearchTopicDetailController.TopicCardParams params= new PMP_SearchTopicDetailController.TopicCardParams();
        params.langCode='en_US';
        params.topicId='aE02i000000CbCRCA0';
        params.keyword='Offering';
        params.cardType='product';
        params.currentPage=1;
        params.pageSize=8;
        params.categories=new List<Id>();
        params.specifications=new List<Id>();
        String JSONstr = JSON.serialize(params);
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstr), 'Test failed');
		params.keyword='';
        params.categories=new List<Id>{cat};
        params.specifications=new List<Id>{spec};
        String JSONstr2 = JSON.serialize(params);
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstr2), 'Test failed');
        params.cardType='partner';
        String JSONstrpartner = JSON.serialize(params);
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstrpartner), 'Test failed');        
        test.stopTest();   
    }
    
    @isTest
    public static void  getTopicDetailsWithoutFilterAndKeywordTest(){
        test.startTest();
        //map<Id,PMP_Marketplace_Topics_data__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        list<Id> topicIds = new List<Id>();
        //topicIds.addAll(topicMap.keySet());
        //PMP_Marketplace_Topics_data__c topicData=topicMap.get(topicIds[0]);
        PMP_SearchTopicDetailController.TopicCardParams params= new PMP_SearchTopicDetailController.TopicCardParams();
        params.langCode='en_US';
        params.topicId='aE02i000000CbCRCA0';
        params.keyword='';
        params.cardType='product';
        params.currentPage=1;
        params.pageSize=8;
        params.categories=new List<Id>();
        params.specifications=new List<Id>();
        String JSONstr = JSON.serialize(params);

        //String  params = '{"topicId":topicData.PMP_Community_Topic_Id__c,"langCode":"en_US","currentPage":1,"pageSize":8,"keyword":null,"categories":[],"specifications":[],"cardType":"product"}';
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstr), 'Test failed');
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstr), 'Test failed');
        params.cardType='partner';
        String JSONstr2 = JSON.serialize(params);

        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(JSONstr2), 'Test failed');

        /*system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(topicData.PMP_Community_Topic_Id__c,'en_US',1,12,null,new List<Id>(),new List<Id>()), 'Test failed');
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicDetails(topicData.PMP_Community_Topic_Id__c,'en_US',1,12,null,new List<Id>(),new List<Id>()), 'Test failed');*/
        test.stopTest();   
    }
    
    @isTest
    public static void  getTopicMarqueeDetailsTest(){
        test.startTest();
        //map<Id,PMP_Marketplace_Topics_data__c> topicMap = PMP_MarketplaceTopics.getTopicMetadata();
        list<Id> topicIds = new List<Id>();
        //topicIds.addAll(topicMap.keySet());
        //PMP_Marketplace_Topic__c topicData=topicMap.get('aE02i000000CbCRCA0');
        system.assertNotEquals(NULL,PMP_SearchTopicDetailController.getTopicMarqueeDetails('aE02i000000CbCRCA0','en_US'), 'Test Failed');
        test.stopTest();   
    }
 
}