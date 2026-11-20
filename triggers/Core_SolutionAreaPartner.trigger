/**************************************************************************************
Apex Class Name:  Core_SolutionAreaPartner
Version     : 1.0
Created Date: 19 JUN 2023
Function    : Trigger for the object Solution Partner
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Shijas KM             06/19/2023              Original Version

*************************************************************************************/
trigger Core_SolutionAreaPartner on Core_Solution_Area_Partner__c (before insert, before update, after delete,after update,after insert) {
    
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();  
    

    try{
        
   
    
    if(Trigger.isAfter) {  

        if(Trigger.isUpdate) {
            
          
          if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
         Core_Solution_Area_Partner_Controller.updatePartnerValuesToSolution(trigger.new, trigger.oldMap);
         }
               
        }
        }
        
    if(Trigger.isAfter) {         
        if(Trigger.isInsert) {
          
          if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
            
         Core_Solution_Area_Partner_Controller.UpsertPartnerValuesToSolution(trigger.new);
         }
        
      
        }
        }
    
    if(Trigger.isAfter) {         
        if(Trigger.isDelete) {
          
          if(mapFunctionalityNameTriggerExecution.containsKey('updateJSONSolutionArea') && 
               mapFunctionalityNameTriggerExecution.get('updateJSONSolutionArea').Core_Active__c){
                   
         Core_Solution_Area_Partner_Controller.UpsertPartnerValuesToSolution(trigger.old);
         }
        
        
        }
        }
        
    }catch(Exception ex){
        PMP_Utility.logError(ex, 'Core_SolutionAreaPartner');
    }finally{
       
    }
}