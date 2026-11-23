/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExceptionCaseMap_TriggerHandler
* Created Date      : 24-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture NZ        24-06-2019          Exception Case Mapping Trigger Handler    
*****************************************************************************************************************************************/   
public with sharing class Core_MDF_ExceptionCaseMap_TriggerHandler extends TriggerHandler {
    /**
        * @description              : Method for processing the Exception Case Mapping before Update
        * @param Trigger.newMap     : Map of Exception Case Mapping that have been Updated  
    */
    public override void beforeDelete(){
        if (isActive('Core_MDF_ECMBeforeDelete')) {
            Core_MDF_ExpCaseMp_TriggerServiceHandler.ecmStatusOnDelete( (Map<Id,Core_MDF_Exception_Case_Mapping__c>) Trigger.oldMap );
        }
    }
   
}