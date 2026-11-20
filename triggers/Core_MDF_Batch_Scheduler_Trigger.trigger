trigger Core_MDF_Batch_Scheduler_Trigger on Core_MDF_Batch_Scheduler__c (before insert,before update, after insert,after update,after delete) {
    Core_MDF_Batch_Scheduler_TriggerHandler batchSchTriggerHandler = new Core_MDF_Batch_Scheduler_TriggerHandler();
    batchSchTriggerHandler.run();
}