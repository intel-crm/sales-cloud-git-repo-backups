/******************************************************************************************************************************************
Trigger Name:  Core_OpportunityLineItem
Version     : 1.0 
Created Date: ?
Function    : Trigger for the object OpportunityLineItem
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------  
* Ashwin Dash               12/05/2017              US89448, US88961 - Stamp "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity
                                                    Product on Approval and remove it on rejection or recall.
* Ashwin Dash               10/01/2017              US83104 - Added changes for forecast records creation, updation and deletion on after insert, after update and before delete of OLI
* Ajay DS                   7/12/2017                Added BU Mapping functionality               
* ??                        ??                      (many changes made by developers before this header section was added)
* Dave Hood                 07/25/2016              Added code for tracking field history, including "before update", "before delete"
*****************************************************************************************************************************************/
trigger Core_OpportunityLineItem on OpportunityLineItem (before insert, before update, before delete,
                                                         after insert, after update, after delete) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if (trigger.isAfter) {
            if(mapFunctionalityNameTriggerExecution.containsKey('opportunityLineItemAfterHandler') && 
               mapFunctionalityNameTriggerExecution.get('opportunityLineItemAfterHandler').Core_Active__c) {
                   Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
               }
             
            if (trigger.isInsert) {
                if (mapFunctionalityNameTriggerExecution.containsKey('insertPartners') && mapFunctionalityNameTriggerExecution.get('insertPartners').Core_Active__c) {
                    Core_OpportunityLineItemHandler.insertPartners(trigger.new);
                    
                }
                //US83104 - Adding logic for creating forecast records -- Ashwin
                if(mapFunctionalityNameTriggerExecution.containsKey('insertForecast') && mapFunctionalityNameTriggerExecution.get('insertForecast').Core_Active__c){
                    Core_OpportunityLineItemHandler.insertForecastRecords(Trigger.new, true);
                }
            }
            if (trigger.isDelete) {
                if (mapFunctionalityNameTriggerExecution.containsKey('deletePartners') && mapFunctionalityNameTriggerExecution.get('deletePartners').Core_Active__c) {
                    Core_OpportunityLineItemHandler.deletePartners(trigger.old);
                }
            }
            if (trigger.isUpdate) {
                if (mapFunctionalityNameTriggerExecution.containsKey('updatePartners') && mapFunctionalityNameTriggerExecution.get('updatePartners').Core_Active__c) {
                    Core_OpportunityLineItemHandler.updatePartners(trigger.new, trigger.oldmap);
                }
                //US83104 - Adding logic for updating the forecast to blank quantities if LineItem is update to Cancelled or Deleted Status and update vendor information-- Ashwin
                if (mapFunctionalityNameTriggerExecution.containsKey('updateForecast') && mapFunctionalityNameTriggerExecution.get('updateForecast').Core_Active__c) {
                    Core_OpportunityLineItemHandler.updateForecastRecords(trigger.new, trigger.oldmap);
                }
            }
        }
        
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                if (mapFunctionalityNameTriggerExecution.containsKey('populateGroup') && mapFunctionalityNameTriggerExecution.get('populateGroup').Core_Active__c) {
                    Core_OpportunityLineItemHandler.populateGroup(trigger.new);
                }
                
                //US83104 - Adding logic for creating forecast records -- Ashwin
                if(mapFunctionalityNameTriggerExecution.containsKey('insertForecast') && mapFunctionalityNameTriggerExecution.get('insertForecast').Core_Active__c){
                    Core_OpportunityLineItemHandler.beforeInsertForecastRecords(Trigger.new);
                }
                
                //BU Shortname Calculation
                if (mapFunctionalityNameTriggerExecution.containsKey('set_BUShortName') && mapFunctionalityNameTriggerExecution.get('set_BUShortName').Core_Active__c) {
                    Core_OpportunityLineItemHandler.setBUShortName(trigger.new);
                }
                
            }
            if (trigger.isUpdate || trigger.isDelete) {               
                if (mapFunctionalityNameTriggerExecution.containsKey('trackOpportunityProductHistory') && mapFunctionalityNameTriggerExecution.get('trackOpportunityProductHistory').Core_Active__c) {
                    Core_OpportunityLineItemHandler.trackHistory(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                }      
                
                //US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin
                if(Trigger.isUpdate){
                    if (mapFunctionalityNameTriggerExecution.containsKey('updateOpportunityLineItem') && mapFunctionalityNameTriggerExecution.get('updateOpportunityLineItem').Core_Active__c) {
                        Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isUpdate);
                    }  
                }
                                
                //US83104 - Adding logic for deleting forecast before deleting the OpptyLineItem -- Ashwin
                if(Trigger.isDelete){
                    if(mapFunctionalityNameTriggerExecution.containsKey('deleteForecast') && mapFunctionalityNameTriggerExecution.get('deleteForecast').Core_Active__c){
                        Core_OpportunityLineItemHandler.deleteForecastRecords(Trigger.oldMap);
                    }      
                }
            }
        }
    }
}