trigger Core_opptyTeamAccessTrigger on Core_Oppty_Team_Access__c (after update) {

    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(Trigger.isAfter){
        if (mapFunctionalityNameTriggerExecution.containsKey('opptyTeamAccess') && mapFunctionalityNameTriggerExecution.get('opptyTeamAccess').Core_Active__c){
            Core_opptyTeamAccessHandler.createOpptyTeamMember(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
    }    
}