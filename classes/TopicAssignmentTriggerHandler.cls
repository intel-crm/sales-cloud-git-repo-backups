/**************************************************************************************
Apex Class Name : TopicAssignmentTriggerHandler
Version     : 1.0 
Created Date: 29th April, 2022
Description : Trigger handler for TopicAssignment
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sathish                  29/04/2022               Original Version
*************************************************************************************/

public class TopicAssignmentTriggerHandler extends TriggerHandler{
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    
    public override void afterUpdate(){
        
    }
    
    
    public override void afterInsert(){


        try{
            String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
            String langKeys=PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
            Map<String,String> langMap= new Map<string,string>();
            for(String languageCode : langKeys.split('\\;')){
                langMap.put(languageCode,languageCode.replace('_', '').replace('-', ''));
            }
            for(String langCode: langMap.values()){
                String key = 'TopicDetails'+langCode;
                Cache.Org.remove(partitionInput+'.'+key);
            }
        } catch(Exception error){
            PMP_Utility.logError(error,'TopicDetailsPlatformCacheDeletion');   
        }
        
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_AutoAssignHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_AutoAssignHandler').Core_Active__c)){
            PMP_TopicAssignmentHandler.autoAssignTopics((Map<Id,TopicAssignment>)Trigger.newMap);
        }
        
        
    }
    
    public override void beforeUpdate(){
        
    }
    
    
    public override void beforeInsert(){
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_ValidationHandler') && 
            mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_ValidationHandler').Core_Active__c)){
                List<TopicAssignment> newList = (List<TopicAssignment>) Trigger.new;
                PMP_TopicAssignmentHandler.validateTopicAssignment(newList);
            }   
    }


    public override void afterDelete(){
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_AutoRemovalHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_AutoRemovalHandler').Core_Active__c)){
            PMP_TopicAssignmentHandler.autoRemoveTopicAssignment((Map<Id,TopicAssignment>)Trigger.oldMap);
        }   
       
    }
}