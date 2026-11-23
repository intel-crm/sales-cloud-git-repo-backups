public with sharing class Sales_NonEventFeedbackController {
    /*public static Map<String,boolean> capabilityMap=new Map<String,boolean>();
    static{
        for(Sales_feedbackCapability__mdt metadataCap:[SELECT Id ,Label,Active__c FROM Sales_feedbackCapability__mdt WHERE Active__c=true]){
                capabilityMap.put(metadataCap.Label,metadataCap.Active__c);
        }
    System.debug('capabilityMap>>>>'+capabilityMap);
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
       
        feed.Feedback_Date__c=Date.today();
        feed.Rating__c=numtoratingMap.get(rating);
        feed.Sales_Contact__c=conId;
        feed.Capability__c=capability;
        insert feed;
        return feed.Id;
    }
   // @AuraEnabled (cacheable=true)
   // public static Sales_Feedback__c getFeedRecord(){
   //    Sales_Feedback__c latestrecord=[SELECT id,Last_Feedback_Captured__c,Feedback_Date__c,CreatedBy.Id from Sales_Feedback__c WHERE CreatedBy.Id=:userinfo.getUserId() order by CreatedDate desc LIMIT 1];
   //    return latestrecord;
   // }
        
   @AuraEnabled (cacheable=true)    
    public static boolean checkCapability(String capability){
        boolean istrue=false;
        System.debug(capability+'capability value');
         if(capabilityMap.containsKey(capability)){
           istrue=true;
         }
        return istrue;
    }*/
}