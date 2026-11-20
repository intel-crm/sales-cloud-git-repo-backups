trigger Core_KPI_Staging on Core_KPI_Staging__c (after insert, after update) {
    public static boolean KPIDeltaLoadCheck = true;
    public static boolean KPIFullLoadCheck = true;
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(trigger.isAfter){
        if(trigger.isInsert){

            // Delete the dummy staging records for Opp Stage KPI which used for refresh status - when corresponding AZURE records received
            Core_RefreshKPI.deleteDummyRefreshRecord((List<Core_KPI_Staging__c>)Trigger.new);

            Core_KPIDeltaLoadHandler.seprateRefreshTypes(trigger.new,KPIDeltaLoadCheck,KPIFullLoadCheck);

          
        }
    }
    if(trigger.isAfter){
        if(trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('updateOldStageRecords') && mapFunctionalityNameTriggerExecution.get('updateOldStageRecords').Core_Active__c) {
                Core_AzureKPIStageHandler.updateOldStageRecords(trigger.new,trigger.old);
            }        
        }
    }
}