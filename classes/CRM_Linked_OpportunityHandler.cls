public class CRM_Linked_OpportunityHandler extends TriggerHandler {
 map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

 public override void beforeInsert() {
     if (mapFunctionalityNameTriggerExecution.containsKey('LinkedOpportunity') && mapFunctionalityNameTriggerExecution.get('LinkedOpportunity').Core_Active__c){CRM_Linked_OpportunityServiceHandler.CheckValidation(Trigger.New);}
}
 public override void beforeUpdate() {
     if (mapFunctionalityNameTriggerExecution.containsKey('LinkedOpportunity') && mapFunctionalityNameTriggerExecution.get('LinkedOpportunity').Core_Active__c)
     {CRM_Linked_OpportunityServiceHandler.CheckValidation(Trigger.New);}
 }
}