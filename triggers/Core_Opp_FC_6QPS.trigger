/******************************************************************************************************************************************
Trigger Name:  Core_Opp_FC_6QPS
Version     : 1.0 
Created Date: 13 OCT 2017
Function    : Trigger for the object Forecast Product Schedule
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash               10/13/2017              Original Version
********************************************************************************************************************************************/
trigger Core_Opp_FC_6QPS on Core_Opp_FC_Prod_Schedule__c (before update, after update) {
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            if(mapFunctionalityNameTriggerExecution.containsKey('beforeFCUpdate') && mapFunctionalityNameTriggerExecution.get('forecastUpdateFromOppty').Core_Active__c){
                Core_Opp_FC_6QPSHandler.beforeUpdateMethod(Trigger.New, Trigger.oldMap);
            }
        }
        if(Trigger.isAfter){
            if(mapFunctionalityNameTriggerExecution.containsKey('afterFCUpdate') && mapFunctionalityNameTriggerExecution.get('forecastUpdateFromOppty').Core_Active__c){
                Core_Opp_FC_6QPSHandler.afterUpdateMethod(Trigger.New, Trigger.oldMap);
            }
        }
    }
}