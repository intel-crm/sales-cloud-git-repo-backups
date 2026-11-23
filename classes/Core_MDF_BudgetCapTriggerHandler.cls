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
    
    /***************************************************************************************************** 
    Method Name   :        afterUpdate
    @return       :        void
    @parameters   :        No parameters
    Added By      :        Accenture - VK - 12/16/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/
    public override void afterUpdate() {
        boolean afterUpdateFlag = isActive('Core_MDF_budgetCapProcessOnAfterUpdate');
        if(afterUpdateFlag){
            Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr((List<Core_MDF_Budget_Cap__c>) Trigger.new, 
                                                          (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                                                          Trigger.isInsert,
                                                          Trigger.isUpdate);
        }
    }
    
    /***************************************************************************************************** 
    Method Name   :        afterInsert
    @return       :        void
    @parameters   :        No parameters
    Added By      :        Accenture - VK - 12/16/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/
    public override void afterInsert() {
        boolean afterInsertFlag = isActive('Core_MDF_budgetCapProcessOnAfterInsert');
        if(afterInsertFlag){
            Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr((List<Core_MDF_Budget_Cap__c>) Trigger.new, 
                                                          (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                                                          Trigger.isInsert,
                                                          Trigger.isUpdate);
        }
    }
}