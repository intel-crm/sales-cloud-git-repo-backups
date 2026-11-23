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
trigger Core_OpportunityTeamMember on OpportunityTeamMember (before insert, after insert, after update, after delete,before delete, before update) {
    
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if(Trigger.isAfter) {
            if(Trigger.isInsert || Trigger.isUpdate|| Trigger.isDelete) {  
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityTeamMemberQuoteSharing') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityTeamMemberQuoteSharing').Core_Active__c){
                       if(Trigger.isInsert || Trigger.isUpdate){
                         Core_OpportunityTeamMemberHandler.shareOpptyTeamMembertoQuote(Trigger.new);
						}
                       if(Trigger.isDelete){
                         Core_OpportunityTeamMemberHandler.shareOpptyTeamMembertoQuote(Trigger.old);
						}                       
                      }
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityTeamMemberHandler') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityTeamMemberHandler').Core_Active__c) {
                       Core_OpportunityTeamMemberHandler.updateGeoFlags(Trigger.old, Trigger.oldMap, Trigger.new);
                       
                       if (Trigger.isDelete) {
                           Core_OpportunityTeamMemberHandler.updateOSCType(Trigger.old);
                       } 
                       else if(Trigger.isInsert) {
                           boolean check = mapFunctionalityNameTriggerExecution.containsKey('sendEmailtoNewTeamMember') && mapFunctionalityNameTriggerExecution.get('sendEmailtoNewTeamMember').Core_Active__c && !system.label.get('','Core_CRM_L3_Bypass_Users').contains(UserInfo.getUserEmail());
                           if(check) { 
                               Core_OpportunityTeamMemberHandler.sendEmailtoNewTeamMember((Map<Id,OpportunityTeamMember>)Trigger.Newmap);
                           }
                           Core_OpportunityTeamMemberHandler.updateOSCType(Trigger.new);
                       }
                       else {
                           Core_OpportunityTeamMemberHandler.updateOSCType(Trigger.new);
                       }
                   }
            }
            
        }
        
        if(Trigger.isBefore && Trigger.isInsert) {
            if(mapFunctionalityNameTriggerExecution.containsKey('IsAccessibleOppoObj') && mapFunctionalityNameTriggerExecution.get('IsAccessibleOppoObj').Core_Active__c) {
                Core_OpportunityTeamMemberHandler.check_OppObjAccessibility(Trigger.new);
            } 
            //For PCC Oppty, Lock the Opportunity when related Quote's any Quote Line Item is in PFIR status - TWC3123-5659-Devashish
            if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') &&
                mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c){
                Core_OpportunityTeamMemberHandler.checkPCCLock(Trigger.new);
            }
        }
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            //For PCC Oppty, Lock the Opportunity when related Quote's any Quote Line Item is in PFIR status - TWC3123-5659-Devashish
            if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') &&
                mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c){
                Core_OpportunityTeamMemberHandler.checkPCCLock(Trigger.new);
            } 
        }
    }
}