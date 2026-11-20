/****************************************************************************************************************************************
* Trigger Name        : Core_MDF_Exception_Trigger
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger on after insert and update        
*****************************************************************************************************************************************/
trigger Core_MDF_Exception_Case_Mapping on Core_MDF_Exception_Case_Mapping__c (after insert, before delete) {

     new Core_MDF_ExceptionCaseMap_TriggerHandler().run();
}