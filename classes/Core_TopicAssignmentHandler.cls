/**************************************************************************************
Apex Class Name : Core_TopicAssignmentHandler
Version     : 1.0 
Created Date: 29th April, 2022
Description : Trigger handler for TopicAssignment
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sathish                  29/04/2022               Original Version
*************************************************************************************/

public class Core_TopicAssignmentHandler extends TriggerHandler{
    public static Boolean isWorking() {
        return true;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    

    
    public override void afterInsert(){
        
        // boolean parameter added to sync events
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_AutoAssignHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_AutoAssignHandler').Core_Active__c)){
            PMP_TopicAssignmentHelper.autoAssignTopics((Map<Id,TopicAssignment>)Trigger.newMap,mapFunctionalityNameTriggerExecution.containsKey('PMP_AutoSyncAssignmentsToEvent') && 
            mapFunctionalityNameTriggerExecution.get('PMP_AutoSyncAssignmentsToEvent').Core_Active__c);
        }
        
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_TopicCountHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_TopicCountHandler').Core_Active__c)){
            List<TopicAssignment> newList = (List<TopicAssignment>) Trigger.new;
            PMP_TopicAssignmentHelper.syncTopicCountToOffAndPartner(newList);
        }
        
        
        
    }

    
    
    public override void beforeInsert(){
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_ValidationHandler') && 
            mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_ValidationHandler').Core_Active__c)){
                List<TopicAssignment> newList = (List<TopicAssignment>) Trigger.new;
                PMP_TopicAssignmentHelper.validateTopicAssignment(newList);
            }   
    }


    public override void afterDelete(){

        // boolean parameter added to sync events
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_AutoRemovalHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_AutoRemovalHandler').Core_Active__c)){
            PMP_TopicAssignmentHelper.autoRemoveTopicAssignment((Map<Id,TopicAssignment>)Trigger.oldMap,mapFunctionalityNameTriggerExecution.containsKey('PMP_AutoRemoveAssignmentsOnEvent') && 
            mapFunctionalityNameTriggerExecution.get('PMP_AutoRemoveAssignmentsOnEvent').Core_Active__c);
        }
        
        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_TopicAssignment_TopicCountHandler') && 
        mapFunctionalityNameTriggerExecution.get('PMP_TopicAssignment_TopicCountHandler').Core_Active__c)){
            PMP_TopicAssignmentHelper.syncTopicCountToOffAndPartner((List<TopicAssignment>)Trigger.old);
        }

       

       
    }*/
}