/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapTriggerHandler 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Harika P                    5/09/2019                    Created for extending Trigger framework to process budget cap business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_BudgetCapTriggerHandler extends TriggerHandler {
    public override void beforeInsert() { 
        boolean insertFlag = isActive('Core_MDF_budgetCapProcessOnBeforeInsert');
        if(insertFlag){
            Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount((List<Core_MDF_Budget_Cap__c>) Trigger.new, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
    }
    public override void beforeUpdate() {
        boolean updateFlag = isActive('Core_MDF_budgetCapProcessOnBeforeUpdate');
        if(updateFlag){
            Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount((List<Core_MDF_Budget_Cap__c>) Trigger.new, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
    }
}