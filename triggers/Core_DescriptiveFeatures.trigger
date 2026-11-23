/**************************************************************************************
Apex Class Name:  Core_DescriptiveFeatures
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object DescriptiveFeatures
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version 
* Dave Hood                 09/21/2015              Added parameter to method calls to bypass multiselect field
*************************************************************************************/
trigger Core_DescriptiveFeatures on Core_Opportunity_Features__c (after delete, after insert, after update) {

// Get the Trigger Execution variables
Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
 
    // COnditional entering of the loop based on the type ofevent
    if(Trigger.isAfter)
    {
        //If the operation is insert
        if(Trigger.isInsert)
        {
             if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityFactsUpdate') && 
                mapFunctionalityNameTriggerExecution.get('OpportunityFactsUpdate').Core_Active__c)
                Core_DescriptiveFeatureHandler.OpportunityFactsUpdate(Trigger.New,NULL,Trigger.NewMap,NULL,false);
        }//If the operation is update
        if(Trigger.isUpdate)
        {
            if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityFactsUpdate') && 
                mapFunctionalityNameTriggerExecution.get('OpportunityFactsUpdate').Core_Active__c)
                Core_DescriptiveFeatureHandler.OpportunityFactsUpdate(Trigger.New,Trigger.Old,Trigger.NewMap,Trigger.OldMap,false);
        }//If the operation is delete
        if(Trigger.isDelete)
        {
            if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityFactsUpdate') && 
                mapFunctionalityNameTriggerExecution.get('OpportunityFactsUpdate').Core_Active__c)
                Core_DescriptiveFeatureHandler.OpportunityFactsUpdate(NULL,Trigger.Old,NULL,Trigger.OldMap,false);
        }
     }
}