/***************************************************************************************************
Apex Class Name:  Core_lead
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object lead
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version
* Harshith M L              11/13/2014              Lead Conversion logic, Trigger structure
* Kunal Mehta               11/18/2014              Sales Segment logic
* Venu Karumuru             05/15/2016              Added Method to assign Partner Leads to correct Partner Queues
* Venu Karumuru             09/13/2016              Deleted the use of Sales Segment field, replaced it with Sales Group
****************************************************************************************************/
trigger Core_Lead on Lead(before insert, before update, after insert, after update) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    // Handle before trigger operations
    if (Trigger.isBefore) {
        Core_LeadTriggerHandler.handleBeforeTrigger(mapFunctionalityNameTriggerExecution);
    }
    
    // Handle after trigger operations
    if (Trigger.isAfter) {
        Core_LeadTriggerHandler.handleAfterTrigger(mapFunctionalityNameTriggerExecution);
    }
}