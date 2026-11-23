/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_BudgetOffset_Trigger 
* Version           : 1.0 
* Created Date      : 04-17-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       04-17-2020        Trigger on Budget Offset object.
*****************************************************************************************************************************************/
trigger Core_MDF_BudgetOffset_Trigger on Core_MDF_Budget_Offset__c (before insert, after insert) {
    Core_MDF_BudgetOffset_TriggerHandler budgetOffsetTriggerHandler = new Core_MDF_BudgetOffset_TriggerHandler();
    budgetOffsetTriggerHandler.run();
}