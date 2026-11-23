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
    
    public override void beforeInsert() {
        // Send budgets for duplicate check process
        Core_MDF_PMBServiceHandler.checkPMBDuplicateRecords((List<PartnerMarketingBudget>) Trigger.new);
        
    }
    public override void beforeUpdate() {
        // Send budgets for duplicate check process, if relevant fields are changed
        Core_MDF_PMBServiceHandler.checkPMBDuplicateRecordsOnUpdate((List<PartnerMarketingBudget>) Trigger.new,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
        // Validate PMB on decrease budget amount change
        Core_MDF_PMBServiceHandler.validateDecreasedBudgetAmount((Map<Id,PartnerMarketingBudget>) Trigger.newMap,(Map<Id,PartnerMarketingBudget>) Trigger.oldMap);
    }
    /*
public override void beforeDelete(){
Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old);
}

public override void afterInsert(){

}

public override void afterUpdate(){

}*/
    
    /*public override void afterDelete(){        
}*/
    
    /*  public override void afterUndelete(){        
}*/
}