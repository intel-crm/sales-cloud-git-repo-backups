trigger Core_Opp_KPI on Core_Opportunity_KPI__c (after insert, after delete, before insert, before update, before delete) {
    
    map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    //US245648 : SMG 2019: Build logic to capture history on KPI
    Core_KPI_FullRefresh_Check__c fullRefreshSetting = Core_KPI_FullRefresh_Check__c.getInstance();
    Core_KPI_History_Handler handler = Core_KPI_History_Handler.getInstance();
    if(trigger.isInsert && trigger.isAfter && fullRefreshSetting.IsFullRefresh__c == false){
        handler.createKpiHistory(trigger.new, 'Insert');
    }
    if(trigger.isDelete && trigger.isAfter && fullRefreshSetting.IsFullRefresh__c == false){
        handler.createKpiHistory(trigger.old, 'Delete');
    }
    
    //US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
    if(trigger.isBefore){
        if(trigger.isInsert){
            if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(trigger.new, trigger.oldMap, false);
            }
        }
        if(trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(trigger.new, trigger.oldMap, false);
            }
        }
        if(trigger.isDelete){
            if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(trigger.new, trigger.oldMap, true);
            }
        }
    }
}