/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_BudgetOffset_TriggerHandler 
* Version           : 1.0 
* Created Date      : 04-17-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       04-17-2020        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_BudgetOffset_TriggerHandler extends TriggerHandler{
     /**
    * @description : Method to execute the actions in before insert context of Core_MDF_BudgetOffset_Trigger
    */
    public override void beforeInsert() {
        if (isActive('Core_MDF_AssignDecreaseAmtAndClaimStatus')) {
            Core_MDF_BudgetOffset_ServiceHandler.assignDecreasebudgetAmntAndClaimStatus((List<Core_MDF_Budget_Offset__c>) Trigger.NEW);
        }
    }
     /**
    * @description : Method to execute the actions in after insert context of Core_MDF_BudgetOffset_Trigger
    */
    public override void afterInsert() {
        if (isActive('Core_MDF_UpdateBudgetAndClaimsToPaid')) {
            Core_MDF_BudgetOffset_ServiceHandler.updateBudgetAndRelatedClaimsToPaid();
        }
    }
}