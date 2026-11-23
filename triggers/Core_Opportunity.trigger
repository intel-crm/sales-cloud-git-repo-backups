/******************************************************************************************************************************************
Trigger Name:  Core_Opportunity
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object opportunity
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version
* Dave Hood                 11/12/2014              Added opportunity approval code
* Kunal Mehta               11/18/2014              Opportunity Team Member Trigger
* Dave Hood                 12/19/2014              Opportunity Geo population
* Srikant Joshi             01/14/2015              DEACTIVATED THE BLOCK OF CODE SINCE THE FUNCTIONALITY IS NOW REVERTED BACK
* Derek Lindblom            01/27/2015              Taking out duplicate opportunity 
* Harshith M L              02/05/2015              Added Custom setting map ( for trigger execution ) null check - Line No 21
* Dave Hood                 03/24/2015              Opportunity Stage update (for Lost/Cancelled) and removal of dead Opportunity Geo code
* Venu Karumuru             07/13/2015              Added call to UpdateActivityLineItems to copy Amount, Volume data from Opportunity to Activities
* Kalpana Choudhary         09/01/2015              Added Call for UpdateTerritoryInfoOnOppty to update territory information on opportunity
* Ashwin Dash               10/01/2017              US83104 - Calling Forecast updation method to update the Forecast records and recalculate the quantity and quarter when Opportunity is being changed
* Laxmana Lenka             01/15/2018              US90483 - Commented the lines of code.since three territory field on opporutnity no more required to update
*****************************************************************************************************************************************/
trigger Core_Opportunity on Opportunity(before insert, before update, after insert, after update, before delete) {

    map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    System.debug('>>>>Trigger Start:');
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if(Trigger.isBefore) {
           
            if(Trigger.isInsert) {    
                   
                // call method to populate territory information on opportunity
                if(mapFunctionalityNameTriggerExecution.containsKey('UpdateTerritoryInfoOnOppty') && 
                   mapFunctionalityNameTriggerExecution.get('UpdateTerritoryInfoOnOppty').Core_Active__c){
                      
                    Core_OpportunityHandler.UpdateTerritoryInfoOnOppty(trigger.new,null,False);
                   System.debug('>>>>UpdateTerritoryInfoOnOppty:');
                       
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionDetailLOV') && 
                   mapFunctionalityNameTriggerExecution.get('RestrictSolutionDetailLOV').Core_Active__c){                       
                    Core_OpportunityHandler.validateAllActiveLOV(Trigger.New,Trigger.OldMap,true);
                   }
                
                 if(mapFunctionalityNameTriggerExecution.containsKey('CombineSolutionDetailFields') && 
                   mapFunctionalityNameTriggerExecution.get('CombineSolutionDetailFields').Core_Active__c){                       
                    Core_OpportunityHandler.SolutionDetailCombine(Trigger.New,Trigger.OldMap);
                   }
     
            } else if (Trigger.isUpdate) {
                 
                  //Soluton detail LOV check
                 if(mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionDetailLOV') && 
                   mapFunctionalityNameTriggerExecution.get('RestrictSolutionDetailLOV').Core_Active__c){                       
                    Core_OpportunityHandler.validateAllActiveLOV(Trigger.New,Trigger.OldMap,false);
                   }
                //DE63809 : Not getting an error message when user tries to update an historical data with old Solution area field LOV's
              if(mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionAreaInactiveLOV') && 
                   mapFunctionalityNameTriggerExecution.get('RestrictSolutionAreaInactiveLOV').Core_Active__c){                       
                    Core_OpportunityHandler.validateSolutionAreaInActiveLOV(Trigger.New);
                   }
                
                 if(mapFunctionalityNameTriggerExecution.containsKey('CombineSolutionDetailFields') && 
                   mapFunctionalityNameTriggerExecution.get('CombineSolutionDetailFields').Core_Active__c){                       
                    Core_OpportunityHandler.SolutionDetailCombine(Trigger.New,Trigger.OldMap); 
                   } 
               
                //Block user to select an existing opportunity while lead conversion
                if(mapFunctionalityNameTriggerExecution.containsKey('BlockExistingOppOnLeadConversion') && 
                   mapFunctionalityNameTriggerExecution.get('BlockExistingOppOnLeadConversion').Core_Active__c){
                       if(Core_OpportunityHandler.isExistingOpp){
                           Core_OpportunityHandler.isExistingOpp = false;
                           Core_OpportunityHandler.BlockExistingOppOnLeadConversion(Trigger.New,Trigger.OldMap);
                           
                       }
                   }
                if(mapFunctionalityNameTriggerExecution.containsKey('determineApprovers') && 
                    mapFunctionalityNameTriggerExecution.get('determineApprovers').Core_Active__c)
     
                    Core_OppApproval.determineApprovers(Trigger.oldMap, Trigger.new);
                    
                // call method to populate territory information on opportunity               
                if(mapFunctionalityNameTriggerExecution.containsKey('UpdateTerritoryInfoOnOppty') && 
                   mapFunctionalityNameTriggerExecution.get('UpdateTerritoryInfoOnOppty').Core_Active__c){
                     
                     Core_OpportunityHandler.UpdateTerritoryInfoOnOppty(trigger.new,trigger.oldmap,True);
                       
                   }
                
            } else if (Trigger.isDelete) {
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityOppFactDelete') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityOppFactDelete').Core_Active__c)
                    Core_OpportunityHandler.opportunityOppFactDelete(Trigger.Old); 
            }
        }
        
        if (Trigger.isAfter) {
            if(Trigger.isInsert) {
                //Call the method to update the technical owner on a opportunity
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityTechnicalOwnerUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityTechnicalOwnerUpdate').Core_Active__c)
                    Core_OpportunityHandler.opportunityTechnicalOwnerUpdate(new Map<Id,Opportunity>{}, Trigger.Newmap);
                
            } else if (Trigger.isUpdate) {
                if(mapFunctionalityNameTriggerExecution.containsKey('POPCheckOnUpdate') && 
                   mapFunctionalityNameTriggerExecution.get('POPCheckOnUpdate').Core_Active__c)
                    Core_POP_Handler.popCheckOnApproval(Trigger.New, Trigger.oldMap);
                
                if(mapFunctionalityNameTriggerExecution.containsKey('updateProductLineItems') && 
                    mapFunctionalityNameTriggerExecution.get('updateProductLineItems').Core_Active__c)
                    Core_OppApproval.updateProductLineItems(Trigger.oldMap, Trigger.new);
                
                //Call the method to update the technical owner on a opportunity
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityTechnicalOwnerUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityTechnicalOwnerUpdate').Core_Active__c)
                    Core_OpportunityHandler.opportunityTechnicalOwnerUpdate(Trigger.Oldmap, Trigger.Newmap);
                
                //Call the method to update Pending line items to Lost/Cancelled if opportunity is Lost/Cancelled
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityStageUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityStageUpdate').Core_Active__c)
                    Core_OpportunityHandler.opportunityStageUpdate(Trigger.Oldmap, Trigger.Newmap);
                
                // Call the method to update the Amount, Volume of all the related marketing activites
                if(mapFunctionalityNameTriggerExecution.containsKey('updateActivityLineItems') && 
                    mapFunctionalityNameTriggerExecution.get('updateActivityLineItems').Core_Active__c)
                    Core_OpportunityHandler.UpdateActivityLineItems(Trigger.New);
                
                //US83104 - Calling Forecast updation method to update the Forecast records and recalculate the quantity and quarter when Opportunity is being changed
                if(mapFunctionalityNameTriggerExecution.containsKey('forecastUpdateFromOppty') && mapFunctionalityNameTriggerExecution.get('forecastUpdateFromOppty').Core_Active__c){
                    Core_OpportunityHandler.updateForecastRecs(Trigger.New, Trigger.oldMap);
                }
                
            }
        }
    }
}