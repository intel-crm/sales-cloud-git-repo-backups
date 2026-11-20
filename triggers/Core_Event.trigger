/**************************************************************************************
Apex Class Name:  Core_Event
Version     : 1.0 
Created Date: 03 SEP 2014
Function    : Trigger for Event object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             09/30/2014              Original Version
*************************************************************************************/
trigger Core_Event on Event (after insert, after update,after delete) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            // calling method to update last activity date and passing task data to task handler class
            if(mapFunctionalityNameTriggerExecution.containsKey('eventlastActivityUpdateOnLeadUpsert') && 
                    mapFunctionalityNameTriggerExecution.get('eventlastActivityUpdateOnLeadUpsert').Core_Active__c) {
                Core_EventHandler.eventlastActivityUpdateOnLeadUpsert(Trigger.oldMap,Trigger.newMap);
            }
        } 
        
        if(Trigger.isUpdate) {
            // calling method to update last activity date and passing task data to task handler class
            if(mapFunctionalityNameTriggerExecution.containsKey('eventlastActivityUpdateOnLeadUpsert') && 
                    mapFunctionalityNameTriggerExecution.get('eventlastActivityUpdateOnLeadUpsert').Core_Active__c){
                Core_EventHandler.eventlastActivityUpdateOnLeadUpsert(Trigger.oldMap,Trigger.newMap);
            }
        }
        
        if(Trigger.isDelete) {
            // calling method to update last activity date and passing task data to task handler class
            if(mapFunctionalityNameTriggerExecution.containsKey('eventlastActivityUpdateOnLeadDelete') && 
                    mapFunctionalityNameTriggerExecution.get('eventlastActivityUpdateOnLeadDelete').Core_Active__c){
                Core_EventHandler.eventlastActivityUpdateOnLeadDelete(Trigger.oldMap);
            }
        } 
    }
}