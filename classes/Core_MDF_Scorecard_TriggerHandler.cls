public class Core_MDF_Scorecard_TriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        Core_MDF_Scorecard_ServiceHandler.clearOutValues((List<Core_MDF_Scorecard__c>) Trigger.new,(Map<id,Core_MDF_Scorecard__c>) Trigger.oldMap);
    }
    
    public override void afterUpdate() {
        Core_MDF_Scorecard_ServiceHandler.refreshPage((List<Core_MDF_Scorecard__c>) Trigger.new,(Map<id,Core_MDF_Scorecard__c>) Trigger.oldMap);
    }
}