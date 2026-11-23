// ATHR fix With sharing 16/Dec/2024 Shubham Sharma
public with sharing class ICS_FRM_AutoRelTopicsUtil {
    
    
    //public static string communityId = Label.ICS_FRM_Forums_ID; 
    public static string communityId = 'Test';
    
    public static void fetchRelTopicsInsert(List<TopicAssignment> topicAssign,Boolean isTestRunning){
        
        if(isTestRunning==false){
            try{
                Set<Id> topicIds = new Set<Id>();
                String feedId='';
                List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
                
                if(topicAssign != null && !topicAssign.isEmpty()){
                    if(communityId.equals(topicAssign[0].NetworkId)){
                        feedId= topicAssign[0].EntityId ;
                    } 
                    for(TopicAssignment tObj : topicAssign){
                        topicIds.add(tObj.TopicId);
                    }
                }
                /*
                List<ICS_FRM_TopicMapping__c> topicMappingObj = [Select AllTopicId__c from ICS_FRM_TopicMapping__c where NavTopicId__c IN :topicIds];

                for(ICS_FRM_TopicMapping__c obj:topicMappingObj){
                    TopicAssignment taObj = New TopicAssignment();
                    taObj.TopicId = obj.AllTopicId__c;
                    taObj.EntityId = feedId;
                    taObj.NetworkId = communityId;
                    TopicAssignmentList.add(taObj);            
                }            
                insert TopicAssignmentList; 
*/
            }catch(Exception e){
                System.debug('Exception Occured'+e.getMessage());
            }  
        }
        
        
    }
    
    public static void fetchRelTopicsDelete(List<TopicAssignment> topicAssign,Boolean isTestRunning){
       
        if(isTestRunning==false){
            try{
                Set<Id> topicIds = new Set<Id>();
                Set<Id> allTopicIds = new Set<Id>();
                Set<Id> feedIds = new Set<Id>();
                
                if(topicAssign != null && !topicAssign.isEmpty()){
                    for(TopicAssignment tObj : topicAssign){
                        topicIds.add(tObj.TopicId);
                        feedIds.add(tobj.EntityId);
                    }
                }
                /*
                List<ICS_FRM_TopicMapping__c> topicMappingList = [Select AllTopicId__c from ICS_FRM_TopicMapping__c where NavTopicId__c IN: topicIds];
                
                if(topicMappingList != null && !topicMappingList.isEmpty()){
                    for(ICS_FRM_TopicMapping__c tObj : topicMappingList){
                        allTopicIds.add(tObj.AllTopicId__c);
                    }
                }  */          
                List<TopicAssignment> taList = [select TopicId,EntityId from TopicAssignment where TopicId IN : allTopicIds AND EntityId IN : feedIds];
                delete taList;            
            }catch(Exception e){
                System.debug('Exception Occured'+e.getMessage());
            }
        }
    }
}