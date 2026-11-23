/******************************************************
Component Name    : Sales_FeedbackController
Created Date  : Jul 2021
Function      : US1051027
Modification Log :
Developer                       Date                    Description
mohanx.ananga@intel.com  19/07/2021               US1051027
*****************************************************/
public with sharing class Sales_FeedbackController {
    public static Map<String,boolean> capablityMap=new Map<String,boolean>();
    static{
        for(Sales_feedbackCapability__mdt metadataCap:[SELECT Id, DeveloperName, MasterLabel, 
                                                       Language, NamespacePrefix, Label, 
                                                       QualifiedApiName, Capability__c, Active__c 
                                                       FROM Sales_feedbackCapability__mdt WHERE Active__c=true]){
                                                           capablityMap.put(metadataCap.Label,metadataCap.Active__c);
                                                       }
        
    }    
    @AuraEnabled
    public static id createFeedBack(Integer rating,String textinput, String capablity, String recID,Boolean feedbackchatbot){
        Map<Integer,String>  numtoratingMap=new  Map<Integer,String>();
        numtoratingMap.put(0,'No Rating');
        numtoratingMap.put(1,'Extremely Unsatisfied');
        numtoratingMap.put(2,'Dissatisfied');
        numtoratingMap.put(3,'Neutral');
        numtoratingMap.put(4,'Satisfied');
        numtoratingMap.put(5,'Extremely Satisfied');
        id userId = UserInfo.getUserId();
        User loginUser = [Select id,ContactId,contact.accountid from User where Id = :userId and IsActive=true];
        id conId=loginUser.contactid;
        
        Sales_Feedback__c feed=new Sales_Feedback__c();
        feed.Event_Type__c='Event Feedback';
        feed.Feedback_Text__c=textinput;
        feed.Feedback_Date__c=Date.today();
        feed.Chatbot_Feedback__c=feedbackchatbot;
        
        feed.Rating__c=numtoratingMap.get(rating);
        feed.Sales_Contact__c=conId;
        feed.Capability__c=capablity;
        feed.Reference_Id__c=recID;
        insert feed;
        return feed.Id;
    }
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                    'value' => f.getValue()
                    };
                        options.add(values);
        }
        
        return options;
    }
    @AuraEnabled (cacheable=true)
    public static Sales_Feedback__c getFeedRecord(String capablity){
        List<Sales_Feedback__c> latestRecordList=new List<Sales_Feedback__c>(); 
        latestRecordList=[SELECT id,Last_Feedback_Captured__c,Event_Type__c,Chatbot_Feedback__c,Feedback_Date__c,CreatedBy.Id from Sales_Feedback__c WHERE (CreatedBy.Id=:userinfo.getUserId() and Capability__c=:capablity and Event_Type__c='Event Feedback' and Chatbot_Feedback__c=false) order by createddate desc LIMIT 1];
        if(!latestRecordList.isempty()){
            return latestRecordList[0];
        }
        else{
            return null;
        }
            
    }
    @AuraEnabled (cacheable=true)
    public static Sales_Feedback__c getFeedRecordchatbot(Boolean feedbackchatbot){
        List<Sales_Feedback__c> latestRecordList=new List<Sales_Feedback__c>(); 
        latestRecordList=[SELECT id,Last_Feedback_Captured__c,Feedback_Date__c,CreatedBy.Id,Chatbot_Feedback__c from Sales_Feedback__c WHERE CreatedBy.Id=:userinfo.getUserId() and Chatbot_Feedback__c=:feedbackchatbot order by createddate desc LIMIT 1];
        if(!latestRecordList.isempty()){
        return latestRecordList[0];
        }
        else{
            return null;
        }
    }
    @AuraEnabled (cacheable=true)    
    public static boolean checkCapablity(String capablity){
        boolean istrue=false;
        if(capablityMap.containsKey(capablity)){
            istrue=true;
        }
        return istrue;
    }
    
    @AuraEnabled
    public static id createFeedBack_NonEvent(Integer rating,String textinput,String capability){
        Map<Integer,String>  numtoratingMap=new  Map<Integer,String>();
        numtoratingMap.put(1,'Extremely Unsatisfied');
        numtoratingMap.put(2,'Dissatisfied');
        numtoratingMap.put(3,'Neutral');
        numtoratingMap.put(4,'Satisfied');
        numtoratingMap.put(5,'Extremely Satisfied');
        id userId = UserInfo.getUserId();
        User loginUser = [Select id,ContactId,contact.accountid from User where Id = :userId and IsActive=true];
        id conId=loginUser.contactid;
        Sales_Feedback__c feed=new Sales_Feedback__c();
        feed.Event_Type__c='Non Event Feedback';
        feed.Feedback_Text__c=textinput;
        feed.Feedback_Date__c=Date.today();
        feed.Rating__c=numtoratingMap.get(rating);
        feed.Sales_Contact__c=conId;
        feed.Capability__c=capability;
        insert feed;
        return feed.Id;
    }
    @AuraEnabled (cacheable=true)    
    public static boolean checkCapability_NonEvent(String capability){
        boolean istrue=false;
        
        if(capablityMap.containsKey(capability)){
            
            istrue=true;
        }
        return istrue;
    }
    
}