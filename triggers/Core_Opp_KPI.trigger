trigger Core_Opp_KPI on Core_Opportunity_KPI__c (after insert, after update,after delete, before insert, before update, before delete) {
    
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
    if(trigger.isUpdate && trigger.isAfter && fullRefreshSetting.IsFullRefresh__c == false){
        handler.createKpiHistory(trigger.new, 'Update');
    }
  	/*
  	 * Commented as per this story [TWC4767-2118]
    if(trigger.isAfter){
        if(trigger.isInsert){
        if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueOnDWG').Core_Active__c){
            Core_Opp_KPI_Handler.updateDWGOnInstUpdtDelOppKPI(trigger.new, trigger.oldMap, 'insert');
          
            }
        }
        if(trigger.isUpdate){
          if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueOnDWG').Core_Active__c){
            Core_Opp_KPI_Handler.updateDWGOnInstUpdtDelOppKPI(trigger.new, trigger.oldMap, 'update');
           
            }
        }
        if(trigger.isDelete){
             
          if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueOnDWG').Core_Active__c){
            Core_Opp_KPI_Handler.updateDWGOnInstUpdtDelOppKPI(trigger.new, trigger.oldMap, 'delete');
          
            }
        }
        
    }*/
}