trigger Core_MDF_InternalAudit_Trigger on Core_MDF_InternalAudit__c (before insert,before update,after insert,after update) {
    Core_MDF_InternalAudit_TriggerHandler handlerObject = new Core_MDF_InternalAudit_TriggerHandler();
    handlerObject.run();
}