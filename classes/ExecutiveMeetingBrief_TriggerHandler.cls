public class ExecutiveMeetingBrief_TriggerHandler extends TriggerHandler {
    
    /*@description : Method to execute the actions in after insert context of ExecutiveMeetingBrief_Trigger*/
    public override void afterInsert(){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('EnableAccount360SharingForEMB') &&  mapFunctionalityNameTriggerExecution.get('EnableAccount360SharingForEMB').Core_Active__c)
        {   
            system.debug('inside trigger if');
        	ExecutiveMeetingBrief_ServiceHandler.account360Sharing((List<Executive_Meeting_Brief__c>) Trigger.NEW);
        }
    }
    
     /*@description : Method to execute the actions in after update context of ExecutiveMeetingBrief_Trigger*/
    public override void afterUpdate(){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('CRM_EMB_Sharing') &&  mapFunctionalityNameTriggerExecution.get('CRM_EMB_Sharing').Core_Active__c)
        {   
            // Call your service handler method for update logic
            CRM_ExecutiveMeetingBrief_Utility.createSharingRecords((List<Executive_Meeting_Brief__c>) Trigger.NEW, (Map<Id, Executive_Meeting_Brief__c>) Trigger.oldMap);
        }
    }

}