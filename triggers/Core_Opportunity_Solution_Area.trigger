trigger Core_Opportunity_Solution_Area on Opportunity_Solution_Area__c (after insert, after delete, before delete) {
    
    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(Trigger.isAfter) {         
        if(Trigger.isInsert) {  
            
              if(mapFunctionalityNameTriggerExecution.containsKey('createJSONSolutionArea') && 
                 mapFunctionalityNameTriggerExecution.get('createJSONSolutionArea').Core_Active__c){
                   
                    Core_Solution_Area_Controller.AddOpportunitySolutionArea(trigger.new);
            		Core_OpportunityHandler.createJSONSolutionArea(trigger.new);
                 }
            	if(mapFunctionalityNameTriggerExecution.containsKey('addSolutionRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addSolutionRelatedRecords').Core_Active__c){
                    
            		Core_AddSolutionArea.addOppPartner(trigger.new);
                 }
            
        }
        if(Trigger.isUpdate || Test.isRunningTest()) {  
            
              if(mapFunctionalityNameTriggerExecution.containsKey('addSolutionRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addSolutionRelatedRecords').Core_Active__c){
                    
            		Core_AddSolutionArea.addOppPartner(trigger.new);
                 }
            
        }
    }
    if(Trigger.isBefore || Test.isRunningTest()){
        if(Trigger.isDelete) {
            if(mapFunctionalityNameTriggerExecution.containsKey('createJSONSolutionArea') && 
                 mapFunctionalityNameTriggerExecution.get('createJSONSolutionArea').Core_Active__c){
                     
            		Core_OpportunityHandler.createJSONSolutionArea(trigger.old);
                     
                 }
            if(mapFunctionalityNameTriggerExecution.containsKey('addSolutionRelatedRecords') && 
               mapFunctionalityNameTriggerExecution.get('addSolutionRelatedRecords').Core_Active__c){
                    
                   Core_AddSolutionArea.checkSolutions(trigger.old);
               }
        }
    }

}