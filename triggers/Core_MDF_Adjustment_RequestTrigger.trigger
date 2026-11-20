trigger Core_MDF_Adjustment_RequestTrigger on Core_MDF_Adjustment_Request__c (before insert,before update,after insert,after update) {
                                                   
    Core_MDF_AdjustmentReq_TriggerHandler handlerObject = new Core_MDF_AdjustmentReq_TriggerHandler();
     handlerObject.run();
}