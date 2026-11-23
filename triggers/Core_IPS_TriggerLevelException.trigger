trigger Core_IPS_TriggerLevelException on Core_IPS_Backend_TriggerLevel_Exception__e (after Insert) {
  if(Core_IPS_BES_RecursionHandler.stopRecursion == true){
    List<Core_IPS_BES_Error_Log__c> erroLogList = new List<Core_IPS_BES_Error_Log__c>();
    for(Core_IPS_Backend_TriggerLevel_Exception__e excepiton: Trigger.new){
        Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
        errorLog.Core_IPS_Error_Description__c  = excepiton.Core_IPS_Description__c;
        errorLog.Core_IPS_Status__c= excepiton.Core_IPS_Status__c;
        erroLogList.add(errorLog);
    }
    insert erroLogList;
    Core_IPS_BES_RecursionHandler.stopRecursion = false;
    }

}