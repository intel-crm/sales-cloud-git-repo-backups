trigger Core_Goal on Core_Goal__c (before insert, before update, after insert, after update, before delete) {
    
    map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(mapFunctionalityNameTriggerExecution.containsKey('goalAddCommissionableTxns') && 
               mapFunctionalityNameTriggerExecution.get('goalAddCommissionableTxns').Core_Active__c) {
                    Core_GoalHandler.addCommissionableTransactions(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate);        
               }
            }
        
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                //Core_GoalHandler.PopulateOpportunityStage(Trigger.old, Trigger.new);
                //US108336 : Calling method to update the OpportunityIdentified field on creation of DWG - Ashwin
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeGoalUpdateAcptDate') && mapFunctionalityNameTriggerExecution.get('beforeGoalUpdateAcptDate').Core_Active__c){
                    Core_GoalHandler.updateOpptyIdentified(Trigger.new, Trigger.oldMap);
                }
                //US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                    Core_GoalHandler.updateGoalforKPIChange(Trigger.new, Trigger.oldMap);
                }
            }
            
            if(Trigger.isUpdate) {
                //Core_GoalHandler.PopulateOpportunityStage(Trigger.old, Trigger.new);                
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeGoalUpdateAcptDate') && mapFunctionalityNameTriggerExecution.get('beforeGoalUpdateAcptDate').Core_Active__c){
                    Core_GoalHandler.updateGoalonApproval(Trigger.New, Trigger.oldMap);
                    //US108336 : Calling method to update the OpportunityIdentified field on creation of DWG - Ashwin
                    Core_GoalHandler.updateOpptyIdentified(Trigger.new, Trigger.oldMap);
                }
                //US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
                if(mapFunctionalityNameTriggerExecution.containsKey('beforeupdateinsertGoalKPI') && mapFunctionalityNameTriggerExecution.get('beforeupdateinsertGoalKPI').Core_Active__c){
                    System.debug('***Calling DWG Update***');
                    Core_GoalHandler.updateGoalforKPIChange(Trigger.new, Trigger.oldMap);
                }
            }
        }
    }
}