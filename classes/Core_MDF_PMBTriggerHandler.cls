/****************************************************************************************************************************************
* Class Name  : Core_MDF_PMBTriggerHandler 
* Version     : 1.0 
* Created Date: 09-03-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       09/03/2018          Created for extending Trigger framework to process 
Partner Marketing Budget business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_PMBTriggerHandler extends TriggerHandler{
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void beforeInsert() {
        //By pass unwanted Query execution in Test Classes 
        if(!Core_MDF_Utility.byPassFeature('Bypass_Duplicate_Budget_Check')){
            // Send budgets for duplicate check process
            Core_MDF_PMBServiceHandler.checkPMBDuplicateRecords((List<PartnerMarketingBudget>) Trigger.new);
        }
        //Method to restrict legacy budget creation
        if(!Core_MDF_Utility.byPassFeature('ByPass_BlockLegacyBudgetCreation')){
            // Send budgets for duplicate check process
            Core_MDF_PMBServiceHandler.restrictLegacyBudgetCreation((List<PartnerMarketingBudget>) Trigger.new);
        }
        
        //method to restrict the budget creation based on custom permission and budget types
        if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Budget_Access')){
            Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess((List<PartnerMarketingBudget>) Trigger.new,NULL,Trigger.isInsert);
        }
        //method to restrict budget creation based on user's access
        if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Budget_Access_Validation')){
            Core_MDF_PMBServiceHandler.validateRoleBudgetTypeAccess((List<PartnerMarketingBudget>) Trigger.new);
        }
        //method to update budget fields
        Core_MDF_PMBServiceHandler.updateBudgetFields((List<PartnerMarketingBudget>) Trigger.new,NULL);
    }
    public override void beforeUpdate() {
       // Send budgets for duplicate check process, if relevant fields are changed
        if(!Core_MDF_Utility.byPassFeature('Bypass_Duplicate_Budget_Check'))
            Core_MDF_PMBServiceHandler.checkPMBDuplicateRecordsOnUpdate((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Budget_Act_Date_Validation') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_Budget_Act_Date_Validation').Core_Active__c){
               
               Core_MDF_Budget_Utility.validateBudgetDateChangeAgainstAct((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
           }
        // Validate PMB on decrease budget amount change
        Core_MDF_PMBServiceHandler.validateDecreasedBudgetAmount((Map<Id,PartnerMarketingBudget>) Trigger.newMap,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        //method to update budget fields
        Core_MDF_PMBServiceHandler.updateBudgetFields((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
         //method to restrict the budget creation based on custom permission and budget types
        if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Budget_Access')){
            Core_MDF_PMBServiceHandler.validatePMBCreationOrUpdateAccess((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap, false);
        }
        //method to restrict the budget sttaus update for managers/approvers
        if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Budget_Status_Validation')){
            Core_MDF_PMBServiceHandler.validateBudgetStatusOnUpdate((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        }
        
    }
    /*
public override void beforeDelete(){
Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old);
}*/

    public override void afterInsert(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_BudgetApvrNotification')){
            Core_MDF_PMBServiceHandler.notifyApprovers((List<PartnerMarketingBudget>) Trigger.new,
                                                        (Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        }
    }
    
    public override void afterUpdate(){
        //Core_MDF_PMBServiceHandler.checkLimits((List<PartnerMarketingBudget>) Trigger.new);
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_BudgetApvrNotification')){
            Core_MDF_PMBServiceHandler.notifyApprovers((List<PartnerMarketingBudget>) Trigger.new, 
                                                       (Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        }
    }
    
    /*public override void afterDelete(){        
}*/
    
    /*  public override void afterUndelete(){        
}*/
}