/*********************************************************************************************
On finish of PRM_ProcessRollUpDownOPIDRecords Batch, SF inbound records will get updated

Based on OPID_Sync_Request__c, Status We are calling the Handler Class method
***************************************************************************************************/
trigger  Core_OnePartner_Inbound_Message on Core_OnePartner_Inbound_Message__c (After Update) {
    //TWC729-7912TriggerExecution record for retry mechanism
    Core_Trigger_Executions__c retryBypass = Core_Trigger_Executions__c.getInstance('PRM_InboundRetryMechanism');
    Set<Id> onDemandSyncrecIds = new Set<Id>();
    for(Core_OnePartner_Inbound_Message__c cim: trigger.new){
        //Should have On Demand Sync Request Record associated, Status should not Load Complete, Old Status should not NEW
        if(cim.OPID_Sync_Request__c != null && cim.Core_Status__c != trigger.oldMap.get(cim.id).Core_Status__c && trigger.oldMap.get(cim.id).Core_Status__c != System.label.PRM_INBOUNDMSG_NEW && cim.Core_Status__c != System.label.PRM_INBOUNDMSG_LOAD_COMPLETE){
            onDemandSyncrecIds.add(cim.OPID_Sync_Request__c);
        } 
    }
    if(onDemandSyncrecIds != null){
        Core_InboundMsg_TriggerHandler.updateOnDemandSyncRecords(onDemandSyncrecIds);
    }
    //TWC729-7912Trigger execiton record can be made inactive to skip the logic
    if(retryBypass.Core_Active__c ==true){
        Core_InboundMsg_TriggerHandler.retryInboundProcessing(Trigger.new);
    }
}