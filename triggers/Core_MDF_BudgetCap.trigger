/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_BudgetCap 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Description:                                                US106392 - Change External Campaign Visibility Date
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Harika P                    5/09/2019                     Trigger to handle budget cap functionalities. 
*****************************************************************************************************************************************/
trigger Core_MDF_BudgetCap on Core_MDF_Budget_Cap__c (before insert, before update) {
    
	new Core_MDF_BudgetCapTriggerHandler().run();
    
}