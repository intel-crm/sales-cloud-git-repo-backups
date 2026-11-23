public without sharing class Core_OpportunitySupportTriggerHandler extends TriggerHandler {
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Boolean firstcall=true;
    public override void beforeInsert() { 
        
        if(mapFunctionalityNameTriggerExecution.containsKey('addSupportTeamToOpp') && mapFunctionalityNameTriggerExecution.get('addSupportTeamToOpp').Core_Active__c){
            Core_OpportunitySupportServiceHandler.determineApprovers(Trigger.new);
        }
       
    }
    
    public override void beforeUpdate() {
        // if(mapFunctionalityNameTriggerExecution.containsKey('determineApprovers') && mapFunctionalityNameTriggerExecution.get('determineApprovers').Core_Active__c)
        //  Core_OpportunitySupportServiceHandler.determineApprovers((Map<Id,Core_Opportunity_Support__c>)Trigger.oldMap, Trigger.new);
        //  
        //Core_OpportunitySupportServiceHandler.Core_marketingsupportStatuschange(Trigger.new ,  (Map<Id,Core_Opportunity_Support__c>)trigger.newMap,(Map<Id,Core_Opportunity_Support__c>)Trigger.oldMap);
        
        if(mapFunctionalityNameTriggerExecution.containsKey('addSupportTeamToOpp') && mapFunctionalityNameTriggerExecution.get('addSupportTeamToOpp').Core_Active__c)  {          
            Core_OpportunitySupportServiceHandler.checkOppSupportTeam(Trigger.new ,  (Map<Id,Core_Opportunity_Support__c>)trigger.newMap,(Map<Id,Core_Opportunity_Support__c>)Trigger.oldMap);
        }
        
        // here call for warning msg apex
    }
    
    public override void afterInsert(){
        
    }
    
    public override void afterUpdate(){
      
        if(mapFunctionalityNameTriggerExecution.containsKey('addSupportTeamToOpp') && mapFunctionalityNameTriggerExecution.get('addSupportTeamToOpp').Core_Active__c && firstcall)
        {
            if(!Test.IsRunningTest())
                firstcall = false;
            Core_OpportunitySupportServiceHandler.updateApproveOrRejectComents(Trigger.new ,(Map<Id,Core_Opportunity_Support__c>)Trigger.oldMap);
            Core_OpportunitySupportServiceHandler.addSupportToOpprotunityTeam((Map<Id,Core_Opportunity_Support__c>)Trigger.oldMap, Trigger.new);
        }        
    }
    
}