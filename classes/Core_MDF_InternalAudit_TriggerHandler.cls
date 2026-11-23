public class Core_MDF_InternalAudit_TriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        //Core_MDF_InternalAudit_ServiceHandler.validateAuditDates((List<Core_MDF_InternalAudit__c>)Trigger.NEW,(Map<Id,Core_MDF_InternalAudit__c>) Trigger.OldMap);
        Core_MDF_InternalAudit_ServiceHandler.populateCloseDate((List<Core_MDF_InternalAudit__c>)Trigger.NEW,(Map<Id,Core_MDF_InternalAudit__c>) Trigger.OldMap);
    }
    public override void beforeInsert() {
        //Core_MDF_InternalAudit_ServiceHandler.populateStatus((List<Core_MDF_InternalAudit__c>)Trigger.NEW,(Map<Id,Core_MDF_InternalAudit__c>) Trigger.OldMap);
        //Core_MDF_InternalAudit_ServiceHandler.setupAuditorbeforeInsert((List<Core_MDF_InternalAudit__c>)Trigger.NEW);
    }
    public override void afterInsert() {
        //Core_MDF_InternalAudit_ServiceHandler.populateStatus((List<Core_MDF_InternalAudit__c>)Trigger.NEW,(Map<Id,Core_MDF_InternalAudit__c>) Trigger.OldMap);
        //Core_MDF_InternalAudit_ServiceHandler.setupAuditor((List<Core_MDF_InternalAudit__c>)Trigger.NEW);
    }
    public override void afterUpdate() {
        Core_MDF_InternalAudit_ServiceHandler.createNewRecord((List<Core_MDF_InternalAudit__c>)Trigger.NEW,(Map<Id,Core_MDF_InternalAudit__c>) Trigger.OldMap);
    }

}