public class PMP_CompanyAutoFill_TriggerHandler extends TriggerHandler {
    Map<Id,PMP_CompanyAutoFill__C> oldMap = (Map<Id,PMP_CompanyAutoFill__C>) Trigger.oldMap;
    Map<Id,PMP_CompanyAutoFill__C> newMap = (Map<Id,PMP_CompanyAutoFill__C>) Trigger.newMap;
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    
    public override void afterInsert() {
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Autofill_Handler') && mapFunctionalityNameTriggerExecution.get('Company_Autofill_Handler').Core_Active__c){ 
        PMP_CompanyAutoFill_Helper.publishStagedCompanies(Trigger.new);
        }
    }
    
    public override void afterUpdate() {
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Autofill_Handler') && mapFunctionalityNameTriggerExecution.get('Company_Autofill_Handler').Core_Active__c){ 
        PMP_CompanyAutoFill_Helper.processStagingRecords(Trigger.new,oldMap);
        PMP_CompanyAutoFill_Helper.processLogos(Trigger.new,oldMap);
        }
    }

}