trigger Core_Goal on Core_Goal__c (before insert, before update, after insert, after update, before delete) {
    
    map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    Core_KPI_FullRefresh_Check__c fullRefreshSetting = Core_KPI_FullRefresh_Check__c.getInstance();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(mapFunctionalityNameTriggerExecution.containsKey('goalAddCommissionableTxns') && 
               mapFunctionalityNameTriggerExecution.get('goalAddCommissionableTxns').Core_Active__c) {
                   //Core_GoalHandler.addCommissionableTransactions(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);        
                   Core_GoalHandler.createCommissionableTransactions(Trigger.new, Trigger.oldMap);
               }
            
            //Added by Megha(Infosys Team) for the TWC3123-2303 on 26/9/2022
                    if(mapFunctionalityNameTriggerExecution.containsKey('delegateApproverRoleChange') &&
                       mapFunctionalityNameTriggerExecution.get('delegateApproverRoleChange').Core_Active__c){
                       Core_DelegateApproverOppShare.postDealWinGoalShare(Trigger.oldMap,Trigger.newMap);
                   }
        }
        
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                //Added by Kavyashree HR(Infosys Team) for the US853240 to remove the tab spaces from the DWG Name field
                if(mapFunctionalityNameTriggerExecution.containsKey('removeSplCharacterinDWGName') && mapFunctionalityNameTriggerExecution.get('removeSplCharacterinDWGName').Core_Active__c){
                    Core_GoalHandler.removeSplCharacterinDWGName(Trigger.oldMap, Trigger.new, Trigger.isInsert, Trigger.isUpdate);
                }
            
                //Core_GoalHandler.PopulateOpportunityStage(Trigger.old, Trigger.new);
                //US108336 : Calling method to update the OpportunityIdentified field on creation of DWG - Ashwin
                
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeGoalUpdateAcptDate') && mapFunctionalityNameTriggerExecution.get('beforeGoalUpdateAcptDate').Core_Active__c){
                    Core_GoalHandler.updateOpptyIdentified(Trigger.new, Trigger.oldMap);
                }
                //US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                   // Core_GoalHandler.updateGoalforKPIChange(Trigger.new, Trigger.oldMap);
                    Core_GoalHandler.validateKPIAchievedFlag(Trigger.new);
                  
                }
                if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueOnDWG').Core_Active__c){
                   
                 Core_GoalHandler.updateGoalRevenueKPI(Trigger.new, Trigger.oldMap);
                
                }
               
            }
            
            if(Trigger.isUpdate) {
                
                //Added by Kavyashree HR(Infosys Team) for the TWC3123-87
                if(mapFunctionalityNameTriggerExecution.containsKey('updateKPIFieldsonMatch') && mapFunctionalityNameTriggerExecution.get('updateKPIFieldsonMatch').Core_Active__c && fullRefreshSetting.IsFullRefresh__c == false){
                    //Core_GoalHandler.sendNotificationonChangeofMatchOppKPI(Trigger.new, Trigger.oldMap);
                } 
                
                //Added by Kavyashree HR(Infosys Team) for the US853240 to remove the tab spaces from the DWG Name field
                if(mapFunctionalityNameTriggerExecution.containsKey('removeSplCharacterinDWGName') && mapFunctionalityNameTriggerExecution.get('removeSplCharacterinDWGName').Core_Active__c){
                    Core_GoalHandler.removeSplCharacterinDWGName(Trigger.oldMap, Trigger.new, Trigger.isInsert, Trigger.isUpdate);
                }
                
                   
                
              if(mapFunctionalityNameTriggerExecution.containsKey('UpdateKPIRevenueOnDWG') && mapFunctionalityNameTriggerExecution.get('UpdateKPIRevenueOnDWG').Core_Active__c){
                  
                 Core_GoalHandler.updateGoalRevenueKPI(Trigger.new, Trigger.oldMap);
                   
                }
                //Core_GoalHandler.PopulateOpportunityStage(Trigger.old, Trigger.new);                
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeGoalUpdateAcptDate') && mapFunctionalityNameTriggerExecution.get('beforeGoalUpdateAcptDate').Core_Active__c){
                    Core_GoalHandler.updateGoalonApproval(Trigger.New, Trigger.oldMap);
                    //US108336 : Calling method to update the OpportunityIdentified field on creation of DWG - Ashwin
                    Core_GoalHandler.updateOpptyIdentified(Trigger.new, Trigger.oldMap);
                   
                    
                
                }
                //US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                    System.debug('***Calling DWG Update***');
                    //Core_GoalHandler.updateGoalforKPIChange(Trigger.new, Trigger.oldMap);
                    Core_GoalHandler.UpdateGoalOnKPIChange(Trigger.new, Trigger.oldMap);
                    
                }
                
            }
        }
    }
}