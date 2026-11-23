/******************************************************************************************************************************************
Trigger Name:  Core_SolutionAreas
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object Core_Solution_Areas__c
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             18/11/2022              Original Version
*****************************************************************************************************************************************/


trigger Core_SolutionAreas on Core_Solution_Areas__c (Before update, After update, After Insert, Before Insert) {
    
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(Trigger.isBefore) {         
        if(Trigger.isInsert) { 
            if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
                   Core_Solution_Area_Controller.addValuesToSolution(trigger.new);
               }
            
        }
    }
    
    if(Trigger.isBefore) {         
        if(Trigger.isUpdate) { 
            if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
                   Core_Solution_Area_Controller.updatedValuesToSolution(trigger.new, trigger.oldMap);
                   Core_Solution_Area_Controller.restrictPicklists(trigger.new, trigger.oldMap);
               }
            
        }
    }
    
    if(Trigger.isAfter) {         
        if(Trigger.isUpdate) { 
       
            
            if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
                     // For updating OPTY Solution areas based on Solution update             		

            		Core_Solution_Area_Controller.updateOpportunitySolutionArea(trigger.new, trigger.oldMap);
                   Core_OpportunityHandler.updateJSONSolutionArea(trigger.new, trigger.oldMap);
                   
               }                   

        }
        
    }
}