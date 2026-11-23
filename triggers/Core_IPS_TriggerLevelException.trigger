trigger Core_IPS_TriggerLevelException on Core_IPS_Backend_TriggerLevel_Exception__e (after Insert) {
    List<String> caseIds = new List<String>();
    try{
      if(Core_IPS_BES_RecursionHandler.stopRecursion == true){
        List<Core_IPS_BES_Error_Log__c> erroLogList = new List<Core_IPS_BES_Error_Log__c>();
            for(Core_IPS_Backend_TriggerLevel_Exception__e excepiton: Trigger.new){
                Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
                errorLog.Core_IPS_Error_Description__c  = excepiton.Core_IPS_Description__c;
                errorLog.Core_IPS_Status__c= excepiton.Core_IPS_Status__c;
                errorLog.Core_IPS_Error_Code__c = 500;
                errorLog.Core_IPS_ObjectIds__c = excepiton.Core_IPS_caseId__c;
                caseIds.add(excepiton.Core_IPS_caseId__c);
                erroLogList.add(errorLog);
            }
          if(erroLogList.size()>0){
                insert erroLogList;   
          }
          Core_IPS_BES_RecursionHandler.stopRecursion = false;
        }
     } catch(Exception e) {
         Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,String.join(caseIds, ','));
     }

}