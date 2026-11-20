/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_HoldCriteriaList_Trigger 
* Version           : 1.0 
* Created Date      : 10-05-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       10/05/2019        Trigger on Hold Criteria List object.
*****************************************************************************************************************************************/
trigger Core_MDF_HoldCriteriaList_Trigger on Core_MDF_Hold_Criteria__c (before delete,before insert,before update) 
{ 
    Core_MDF_HoldCriteriaList_TriggerHandler handlerObject = new Core_MDF_HoldCriteriaList_TriggerHandler();
    handlerObject.run();
}