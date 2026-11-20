public class Core_MDF_Target_Setting_TriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_TargetSetngValidations')){
            Core_MDF_Target_Setting_ServiceHandler.validateRecords((List<Core_MDF_Target_Setting__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting__c>) Trigger.oldMap, Trigger.isInsert);
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_PopulateBackendFlds')){
            Core_MDF_Target_Setting_ServiceHandler.populateBackendFields((List<Core_MDF_Target_Setting__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting__c>) Trigger.oldMap, Trigger.isInsert);
        }
    } 
    
    public override void afterInsert(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassTargetSetngRecCreation')){
            Core_MDF_Target_Setting_ServiceHandler.createSpendingTargetsVersion((List<Core_MDF_Target_Setting__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting__c>) Trigger.oldMap, Trigger.isInsert);
            Core_MDF_Target_Setting_ServiceHandler.createTargetSettingLineItems((List<Core_MDF_Target_Setting__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting__c>) Trigger.oldMap, Trigger.isInsert);
        }
    }
    
    public override void beforeUpdate(){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_TargetSetngValidations')){
            Core_MDF_Target_Setting_ServiceHandler.validateRecordsOnUpdate((List<Core_MDF_Target_Setting__c>) Trigger.new, (Map<Id,Core_MDF_Target_Setting__c>) Trigger.oldMap, Trigger.isInsert);
        }
    }
}