/**************************************************************************************
Apex Class Name:  Core_FeatureSet
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object Feature Set
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version
* Dave Hood                 09/21/2015              After Update code added to handle single->multiselect
* Dave Hood                 10/13/2015              After Update code added to handle Feature value change
* Dave Hood                 10/20/2015              After Update code added to handle multiselect->single-select
*************************************************************************************/
trigger Core_Feature on Core_Feature__c (after insert, after update) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        
        if(mapFunctionalityNameTriggerExecution.containsKey('featureEnsureConsistentMultiselect') && 
           mapFunctionalityNameTriggerExecution.get('featureEnsureConsistentMultiselect').Core_Active__c)
            Core_FeatureHandler.ensureConsistentMultiselect(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        
        if(mapFunctionalityNameTriggerExecution.containsKey('featureCheckForSingleToMultiselect') && 
           mapFunctionalityNameTriggerExecution.get('featureCheckForSingleToMultiselect').Core_Active__c)
            Core_FeatureHandler.checkForSingleToMultiselect(Trigger.old, Trigger.newMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        
        if(mapFunctionalityNameTriggerExecution.containsKey('featureCheckForMultiToSingleSelect') && 
           mapFunctionalityNameTriggerExecution.get('featureCheckForMultiToSingleSelect').Core_Active__c)
            Core_FeatureHandler.checkForMultiToSingleSelect(Trigger.old, Trigger.newMap);
    }
        
    if (Trigger.isAfter && Trigger.isUpdate) {
        
        if(mapFunctionalityNameTriggerExecution.containsKey('featureCheckForValueChange') && 
           mapFunctionalityNameTriggerExecution.get('featureCheckForValueChange').Core_Active__c) {
               Core_FeatureHandler.checkForValueChange(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
           }
    }
}