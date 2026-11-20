/**************************************************************************************
Apex Class Name:  Core_OppSupportTeamTriggerHandler
Version     : 1.0 
Created Date: 15 March 2023
Function    : methods to handle Core_Opportunity_Support_Team__c Trigger functions related to Opportuntiy Support
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykumar S             15/03/2023             Original Version 
*************************************************************************************/
public class Core_OppSupportTeamTriggerHandler  extends TriggerHandler {
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Boolean firstcall=true;
    public override void beforeInsert() { 
        //check user already present in the Support request
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSupportToOpprotunityTeam') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c){ 
            Core_OppSupportTeam.checkDuplicateOppSupTeamMem(Trigger.new,(Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap);
         	Core_OppSupportTeam.updateOppSupteamStatus(Trigger.new,(Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap);
        }
    }
    
    public override void beforeUpdate() {   
        //check user already present in the Support request
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSupportToOpprotunityTeam') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c){
            Core_OppSupportTeam.checkDuplicateOppSupTeamMem(Trigger.new,(Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap);
            Core_OppSupportTeam.updateOppSupteamStatus(Trigger.new,(Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap);
        }
    }
    
    public override void afterInsert(){
        if(mapFunctionalityNameTriggerExecution.containsKey('captureOppSupportTeamMemberName') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c){
            Core_OppSupportTeam.captureOppSupportTeamMemberName(Trigger.new);}
        //add user to Opportunity team, if user added to Opportunity support team after the approve of Opportunity support request.
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSupportToOpprotunityTeam') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c)
            Core_OppSupportTeam.updateSupportToOpprotunityTeam((Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap, Trigger.new,false);     
    		
    }
    
    public override void afterUpdate(){
         //add user to Opportunity team, if user updated in Opportunity support team after the approve of Opportunity support request.
        if(mapFunctionalityNameTriggerExecution.containsKey('captureOppSupportTeamMemberName') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c){
            Core_OppSupportTeam.captureOppSupportTeamMemberName(Trigger.new);}
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSupportToOpprotunityTeam') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c)
            Core_OppSupportTeam.updateSupportToOpprotunityTeam((Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap, Trigger.new,false); 
        }
    
    public override void afterDelete(){
       //Delete the user from Opportunity Support, if user removed from Opportunity support team.
        if(mapFunctionalityNameTriggerExecution.containsKey('captureOppSupportTeamMemberName') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c){
            Core_OppSupportTeam.captureOppSupportTeamMemberName(Trigger.Old);}
		//Delete the user from Opportunity team, if user removed from Opportunity support team after the approve of Opportunity support request.
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSupportToOpprotunityTeam') && mapFunctionalityNameTriggerExecution.get('updateSupportToOpprotunityTeam').Core_Active__c)
            Core_OppSupportTeam.updateSupportToOpprotunityTeam((Map<Id,Core_Opportunity_Support_Team__c>)Trigger.oldMap, Trigger.old,true);
    }


    public override void beforeDelete(){
        if(mapFunctionalityNameTriggerExecution.containsKey('stopOppSupportDeletion') && mapFunctionalityNameTriggerExecution.get('stopOppSupportDeletion').Core_Active__c){
             Core_OppSupportTeam.deleteSupportToOpprotunityTeam(Trigger.old);}
     }
}