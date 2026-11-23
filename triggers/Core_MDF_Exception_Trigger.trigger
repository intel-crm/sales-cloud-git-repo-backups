/****************************************************************************************************************************************
* Trigger Name        : Core_MDF_Exception_Trigger
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger on after insert and update        
*****************************************************************************************************************************************/
trigger Core_MDF_Exception_Trigger on Core_MDF_Exception__c (after insert, after update, before insert) {
     new Core_MDF_Exception_TriggerHandler().run();
}