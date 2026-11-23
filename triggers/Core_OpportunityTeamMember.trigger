/******************************************************************************************************************************************
Trigger Name: Core_OpportunityTeamMember
Version     : 1.0 
Created Date: May 18, 2015
Function    : Trigger for the object OpportunityTeamMember
Modification Log :
*------------------------------------------------------------------------------
* Developer         Date          Description
*------------------------------------------------------------------------------
* Dave Hood         05/18/2015    Original version
* Shailaja Gandam   06/02/2015    Added logic to update OSC Collaboration type 
*                                 reporting field on updates to team member
* -----------------------------------------------------------------------------
*****************************************************************************************************************************************/
trigger Core_OpportunityTeamMember on OpportunityTeamMember (after insert, after update, after delete) {

    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if(Trigger.isAfter) {
            if((Trigger.isInsert) || (Trigger.isUpdate) || (Trigger.isDelete)) {
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityTeamMemberHandler') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityTeamMemberHandler').Core_Active__c) {
                    Core_OpportunityTeamMemberHandler.updateGeoFlags(Trigger.old, Trigger.oldMap, Trigger.new);
                    
                    if (Trigger.isDelete) {
                        Core_OpportunityTeamMemberHandler.updateOSCType(Trigger.old);
                    } else {
                        Core_OpportunityTeamMemberHandler.updateOSCType(Trigger.new);
                    } 
                }
            }
        }
    }
}