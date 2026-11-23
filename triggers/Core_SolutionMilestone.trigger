/**************************************************************************************
Apex Class Name:  Core_SolutionMilestone
Version     : 1.0 
Created Date: 04 NOV 2015
Function    : Trigger for the object Solution Milestone
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David Wong                  11/04/2014             Original Version
* Ashwin Dash                 01/AUG/2017            Added a field update for before update using method Core_SolutionMilestoneHandler.--
*************************************************************************************/
trigger Core_SolutionMilestone on Core_Solution_Milestone__c (after insert, after update, before insert, before update) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        if(mapFunctionalityNameTriggerExecution.containsKey('solutionMilestoneAddCommissionableTxns') && 
           mapFunctionalityNameTriggerExecution.get('solutionMilestoneAddCommissionableTxns').Core_Active__c){
            //Core_SolutionMilestoneHandler.addCommissionableTransactions(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);        
    }
    }
    if(Trigger.isBefore && Trigger.isInsert){
        if(mapFunctionalityNameTriggerExecution.containsKey('solutionMilestoneFieldUpdate') && mapFunctionalityNameTriggerExecution.get('solutionMilestoneFieldUpdate').Core_Active__c){
            Core_SolutionMilestoneHandler.udpdateLookupField(Trigger.new);
        }
    }
}