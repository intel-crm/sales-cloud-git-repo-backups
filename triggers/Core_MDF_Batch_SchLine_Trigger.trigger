trigger Core_MDF_Batch_SchLine_Trigger on Core_MDF_Batch_Scheduler_Line_Item__c (after insert,after update,after delete) {
    Core_MDF_Batch_SchLine_TriggerHandler batchSchTriggerHandler = new Core_MDF_Batch_SchLine_TriggerHandler();
    batchSchTriggerHandler.run();
}