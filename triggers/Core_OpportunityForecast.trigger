trigger Core_OpportunityForecast on Core_Opportunity_Forecast__c (before insert, before update, after insert, after update, before delete) {
    If(!Core_ScheduledOppForecast_Batch.OppForbypassTriggers){
        map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(Trigger.isBefore) { 
            if(mapFunctionalityNameTriggerExecution.containsKey('updateOpportunityForecast') && mapFunctionalityNameTriggerExecution.get('updateOpportunityForecast').Core_Active__c){
                   if(Trigger.isInsert) { 
                      
                       Core_OpportunityForecastController.createOppForecastAmount(trigger.new);
                   }
                   if(Trigger.isUpdate) { 
                     
                       Core_OpportunityForecastController.uniqueOppForecastAmount(trigger.new, trigger.oldMap);
                   }  
                   
                   if(Trigger.isDelete) { 
                       Core_OpportunityForecastController.restrictDeleteOppForecast(trigger.old);
                   }
               }
        }
        if(Trigger.isAfter) {    
        }  
    }
}