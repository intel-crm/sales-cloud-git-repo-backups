trigger Core_MDF_SchedulerFrequency_Trigger on Core_MDF_Scheduler_Frequency__c (before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete) 
{
    Core_MDF_SchFrequency_TriggerHandler handlerObject = new Core_MDF_SchFrequency_TriggerHandler();
    handlerObject.run();                                                       

}