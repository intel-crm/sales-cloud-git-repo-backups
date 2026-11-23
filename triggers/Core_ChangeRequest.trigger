/**************************************************************************************
Apex Class Name:  Core_ChangeRequest
Version     : 1.0 
Created Date: 03 SEP 2014
Function    : Trigger for Change Request object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             09/30/2014              Original Version
*************************************************************************************/
trigger Core_ChangeRequest on Core_Change_Request__c(before insert, before update, after update, after Insert) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) { 
            // Calling changeRequestOwnerPopulation method to populate owner on Change Request record 
            if (mapFunctionalityNameTriggerExecution.containsKey('changeRequestOwnerPopulation') &&
                mapFunctionalityNameTriggerExecution.get('changeRequestOwnerPopulation').Core_Active__c)
                Core_ChangeRequestHandler.changeRequestOwnerPopulation(trigger.new, trigger.newMap);
            	Core_ChangeRequestHandler.checkRequestor(Trigger.new);
        } else if (Trigger.isUpdate) {
            // Calling changeRequestOwnerPopulation method to populate owner on Change Request record
            if (mapFunctionalityNameTriggerExecution.containsKey('changeRequestOwnerPopulation') &&
                mapFunctionalityNameTriggerExecution.get('changeRequestOwnerPopulation').Core_Active__c)
                Core_ChangeRequestHandler.changeRequestOwnerPopulation(trigger.new, trigger.newMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            System.debug('after insert');
            UCD_ACM_Logger.error('Core_ChangeRequest','accountNameUpdate',JSON.serialize(Trigger.oldMap) , null);
            UCD_ACM_Logger.setLogDetails();   
   
            Core_ChangeRequestHandler.accountNameUpdate(Trigger.oldMap, Trigger.new);
            Core_ChangeRequestHandler.accountAddressUpdate(Trigger.oldMap, Trigger.new);
        } else if (Trigger.isUpdate) {
            // Calling accountTeamMemberCreation method to add Account Team Member related to Account
            if (mapFunctionalityNameTriggerExecution.containsKey('accountTeamMemberCreation') &&
                mapFunctionalityNameTriggerExecution.get('accountTeamMemberCreation').Core_Active__c)
                UCD_ACM_Logger.error('Core_ChangeRequest','accountNameUpdate',JSON.serialize(Trigger.oldMap) , null);
            UCD_ACM_Logger.setLogDetails();
                Core_ChangeRequestHandler.accountTeamMemberCreation(Trigger.oldMap, Trigger.newMap);
            Core_ChangeRequestHandler.accountNameUpdate(Trigger.oldMap, Trigger.new);
            Core_ChangeRequestHandler.accountAddressUpdate(Trigger.oldMap, Trigger.new);
        }
    }
    
}