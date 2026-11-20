/**************************************************************************************
Apex Class Name:  Core_FeatureSet
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object Feature Set
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version
*************************************************************************************/
trigger Core_FeatureSet on Core_Feature_Set__c(after insert, after update) {

Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

 if(mapFunctionalityNameTriggerExecution.containsKey('featureSetBeforeHandler') && 
                mapFunctionalityNameTriggerExecution.get('featureSetBeforeHandler').Core_Active__c)      
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        Core_FeatureSetHandler.featureSetBeforeHandler(Trigger.oldMap,Trigger.newMap);
    }

}