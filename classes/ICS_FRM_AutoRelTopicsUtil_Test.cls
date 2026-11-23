//Test Class for ICS_FRM_AutoRelTopicsUtil
@isTest
public class ICS_FRM_AutoRelTopicsUtil_Test {

    public static string communityId = Label.ICS_FRM_Forums_ID;
    private static testmethod void insertData_Test(){
        List<topic> topicList = New List<topic>();
        List<FeedItem> flist = new List<FeedItem>();
        
        Topic t1=new Topic();
        t1.Name='topic 1';
        t1.NetworkId=communityId;
        topicList.add(t1);
        
        Topic t2=new Topic();
        t2.Name='topic 2';
        t2.NetworkId=communityId;
        topicList.add(t2);
        
        insert topicList;
        
        
        FeedItem feed1= new FeedItem();
        feed1.Title = 'Test Feed';
        feed1.Body='Test Body';
        feed1.ParentId=UserInfo.getUserId();
        feed1.NetworkScope=communityId;
        flist.add(feed1);
        
        FeedItem feed2= new FeedItem();
        feed2.Title = 'Test Feed 1';
        feed2.Body='Test Body 1';
        feed2.ParentId=UserInfo.getUserId();
        feed2.NetworkScope=communityId;
        flist.add(feed2);
        
        insert flist;
        
        List<topicAssignment> taList = new List<topicAssignment>();
        
        TopicAssignment ta1= new TopicAssignment();
        ta1.EntityId=feed1.Id;
        ta1.TopicId=t1.Id;
        ta1.NetworkId=communityId;
        taList.add(ta1);
        
        TopicAssignment ta2= new TopicAssignment();
        ta2.EntityId=feed2.Id;
        ta2.TopicId=t2.Id;
        ta2.NetworkId=communityId;
        taList.add(ta2);
        
        insert taList;
        /*
        ICS_FRM_AllTopic__c all = new ICS_FRM_AllTopic__c();
        all.Name=t1.Name;
        insert all;
        
        ICS_FRM_NavigationTopic__c nav = new ICS_FRM_NavigationTopic__c();
        nav.Name= t2.Name;
        insert nav;
        
        ICS_FRM_TopicMapping__c topMap = new ICS_FRM_TopicMapping__c();
        topMap.Topics__c = all.Id;
        topMap.NavigationalTopic__c = nav.Id;
        topMap.NavTopicId__c = topicList[0].Id;
        topMap.AlltopicId__c = taList[0].Id;
        insert topMap;
        
        ICS_FRM_TopicMapping__c topMap1 = new ICS_FRM_TopicMapping__c();
        topMap1.Topics__c = all.Id;
        topMap1.NavigationalTopic__c = nav.Id;
        topMap1.NavTopicId__c = topicList[1].Id;
        topMap1.AlltopicId__c = taList[1].Id;
        insert topMap1;
        */
       ICS_FRM_AutoRelTopicsUtil.fetchRelTopicsInsert(taList,false);
       ICS_FRM_AutoRelTopicsUtil.fetchRelTopicsDelete(taList,false);
        //System.assert(all.Id != null);
    }
}