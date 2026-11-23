/**************************************************************************************
Apex Class Name:  Core_Task
Version     : 1.0 
Created Date: 03 SEP 2014
Function    : Trigger for Task object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             09/30/2014              Original Version
*************************************************************************************/
trigger Core_Task on Task(after insert, after update, after delete) {

    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();


    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadUpsert') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadUpsert').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadUpsert(Trigger.oldMap, Trigger.newMap);

        }

        if (Trigger.isUpdate) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadUpsert') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadUpsert').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadUpsert(Trigger.oldMap, Trigger.newMap);

        }

        iF(Trigger.isDelete) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadDelete') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadDelete').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadDelete(Trigger.oldMap);

        }
    }

}