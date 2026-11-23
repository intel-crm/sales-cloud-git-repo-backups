/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTransferLogTriggerHandler 
* Version     : 1.0 
* Created Date: 4-29-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna Kulkarni       4/29/2018          Created for extending Trigger framework to process 
										  Account Transfer Log Mapping business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_BudgetTransferLogTriggerHandler extends TriggerHandler{
	

   public override void beforeUpdate() {
       if (isActive('Core_MDF_BudgetTransferLogUniqueField')) {
           Core_MDF_BudgetTransferServiceHandler.populateUniqueField((List<Core_MDF_Budget_Transfer_Log__c>) Trigger.new, (Map<Id,Core_MDF_Budget_Transfer_Log__c>) Trigger.oldMap);
       }
   }
    
    public override void beforeInsert() {     
        if (isActive('Core_MDF_BudgetTransferLogUniqueField')) {
           Core_MDF_BudgetTransferServiceHandler.populateUniqueField((List<Core_MDF_Budget_Transfer_Log__c>) Trigger.new, (Map<Id,Core_MDF_Budget_Transfer_Log__c>) Trigger.oldMap);
       }
    }
    
   /* public override void beforeDelete(){
        }*/

    public override void afterInsert(){
        Core_MDF_ManualSharing.sharingAccountTransfer((List<Core_MDF_Budget_Transfer_Log__c>) Trigger.new);
    }
    
    public override void afterUpdate(){
        //Resharing of Account Transfer after Owner Change
        Core_MDF_ManualSharing.recalculateShareAccountTransferWhenOwnerChange((List<Core_MDF_Budget_Transfer_Log__c>) Trigger.NEW,(Map<Id,Core_MDF_Budget_Transfer_Log__c>) Trigger.oldMap); // Accenture - Krishna Kulkarni Date - 04-30-2019    
    
		}
    
   /* public override void afterDelete(){        
    	}*/

   /* public override void afterUndelete(){        
    	}*/
}