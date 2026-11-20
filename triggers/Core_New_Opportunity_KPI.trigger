trigger Core_New_Opportunity_KPI on Core_Oppty_KPI_New__c (after insert, after update, after delete) {
    
    map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    Core_KPI_FullRefresh_Check__c fullRefreshSetting = Core_KPI_FullRefresh_Check__c.getInstance();
    Core_New_KPI_History_Handler handler = new Core_New_KPI_History_Handler();
    public List<Core_Oppty_KPI_New__c> KPITriggerNewList = new List<Core_Oppty_KPI_New__c>();
    if(trigger.isAfter){
        if(trigger.isInsert){
            /* commented below if condition as part of TWC4767-2118
             * if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueAndAchievedOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueAndAchievedOnDWG').Core_Active__c){
                Core_Opportunity_KPI_Handler.updateDWGOnInstUpdtDelOpportunityKPI(trigger.new, trigger.oldMap, 'insert');
            }*/
            
            if(fullRefreshSetting.IsFullRefresh__c == false){
                handler.createKpiHistory(trigger.new, 'Insert');
            }
            //Add Commissionable Transactions based on approved Opportunity - By Biswa
            if(Trigger.New.size() > 0 && mapFunctionalityNameTriggerExecution.containsKey('opportunityAddCommTxnsFromKPI') &&
               mapFunctionalityNameTriggerExecution.get('opportunityAddCommTxnsFromKPI').Core_Active__c){
                   if(Trigger.new != null && Trigger.new.size() <= 100){
                       for(Core_Oppty_KPI_New__c kpi : (List<Core_Oppty_KPI_New__c>)Trigger.new){
                           if(kpi.Core_Refresh_Type__c == 'Incremental'){
                               KPITriggerNewList.add(kpi);
                           }
                       }
                   }
                   if(KPITriggerNewList.size() > 0){
                       Core_CommissionableTransactions.addCommissionableTransactionsFromKPI(Trigger.oldMap , KPITriggerNewList , true, false);
                   }
               }
        }
        if(trigger.isUpdate){
            /* commented below if condition as part of TWC4767-2118
             * if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueAndAchievedOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueAndAchievedOnDWG').Core_Active__c){
                Core_Opportunity_KPI_Handler.updateDWGOnInstUpdtDelOpportunityKPI(trigger.new, trigger.oldMap, 'update');
            }*/
            
            if(fullRefreshSetting.IsFullRefresh__c == false){
                handler.createKpiHistory(trigger.new, 'Update');
            }
            
            //Add Commissionable Transactions based on approved Opportunity - By Biswa
            /*if(Trigger.New.size() > 0 && mapFunctionalityNameTriggerExecution.containsKey('opportunityAddCommTxnsFromKPI') &&
                      mapFunctionalityNameTriggerExecution.get('opportunityAddCommTxnsFromKPI').Core_Active__c){
                Core_CommissionableTransactions.addCommissionableTransactionsFromKPI(Trigger.oldMap , Trigger.New , false, true);
            }*/
        }
        if(trigger.isDelete){
            /*commented below if condition as part of TWC4767-2118
             * if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueAndAchievedOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueAndAchievedOnDWG').Core_Active__c && trigger.old[0].Core_IsActive__c){
                Core_Opportunity_KPI_Handler.updateDWGOnInstUpdtDelOpportunityKPI(trigger.new, trigger.oldMap, 'delete');
            }*/
            
            if(fullRefreshSetting.IsFullRefresh__c == false && trigger.old[0].Core_IsActive__c){
                handler.createKpiHistory(trigger.old, 'Delete');
            }
        }
    }
}