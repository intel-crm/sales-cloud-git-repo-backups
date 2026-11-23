public without sharing class Core_MDF_AdjustmentOverrideHelper {
    //Filter Budget from claims
    //Create Map of Budget/Claims
    //count claim amount and set into budget
    //Update budget
    //if budget update nproperly, creaet claim list and return
    @InvocableMethod(label='Update Budget' description='This method will be execute the flow')    
    public static List<List<PartnerFundClaim>> executeBatch(List<List<PartnerFundClaim>> pfcList) {
        List<List<PartnerFundClaim>> finalLstOfPfcToUpdate = new List<List<PartnerFundClaim>>();
         List<PartnerFundClaim> listOfPfcToUpdate = new List<PartnerFundClaim>();
        Map<Id,Decimal> budgetIdToTotalCLaimAmountMap = new Map<Id,Decimal>();
        if(pfcList!=null && pfcList[0]!=null && pfcList[0].size()>0){
            List<PartnerFundClaim> existingPfcRecords  = pfcList[0];
            system.debug('newPfcList '+existingPfcRecords);
            for(PartnerFundClaim pfcRec : existingPfcRecords){             
                if(budgetIdToTotalCLaimAmountMap.containsKey(pfcRec.BudgetId)){
                    budgetIdToTotalCLaimAmountMap.put(pfcRec.BudgetId,budgetIdToTotalCLaimAmountMap.get(pfcRec.BudgetId) + pfcRec.Amount);
                }else{
                    budgetIdToTotalCLaimAmountMap.put(pfcRec.BudgetId,pfcRec.Amount);
                }
            }
            system.debug('budgetIdToTotalCLaimAmountMap - '+budgetIdToTotalCLaimAmountMap);
            Map<Id,PartnerMarketingBudget> existingBudgetMap =
                new Map<Id,PartnerMarketingBudget>([Select Id,Core_MDF_Budget_Status__c,Core_MDF_IsApprovalProcessBypassed_Ind__c,Core_MDF_Decrease_Budget_Amount_Amt__c from PartnerMarketingBudget where Id IN:(budgetIdToTotalCLaimAmountMap.keySet())]);
            system.debug('existingBudgetMap before - '+existingBudgetMap);
            Map<Id,List<PartnerFundClaim>> budgetIdToPfcListMap = new Map<Id,List<PartnerFundClaim>>();
            for(PartnerFundClaim pfcRec : existingPfcRecords){
                (existingBudgetMap.get(pfcRec.BudgetId)).Core_MDF_IsApprovalProcessBypassed_Ind__c = TRUE;
                (existingBudgetMap.get(pfcRec.BudgetId)).Core_MDF_Decrease_Budget_Amount_Amt__c = Math.abs(budgetIdToTotalCLaimAmountMap.get(pfcRec.BudgetId));
                (existingBudgetMap.get(pfcRec.BudgetId)).Core_MDF_Budget_Status__c = 'Released';
                if(budgetIdToPfcListMap.containsKey(pfcRec.BudgetId)){
                    budgetIdToPfcListMap.get(pfcRec.BudgetId).add(pfcRec);
                }else{
                    budgetIdToPfcListMap.put(pfcRec.BudgetId, new List<PartnerFundClaim>{pfcRec});
                }
            }
            system.debug('existingBudgetMap after - '+existingBudgetMap);
            system.debug('budgetIdToPfcListMap - '+budgetIdToPfcListMap);
            List<PartnerFundClaim> newListOfPfc = new List<PartnerFundClaim>();
            if(existingBudgetMap!=null && existingBudgetMap.size()>0){
                Database.saveResult[] budgetResultList = database.update(existingBudgetMap.values(), false);
                system.debug('budgetResultList - '+budgetResultList);
                for(Integer index=0;index<budgetResultList.size();index++){
                    if(budgetResultList[index] !=null){
                        Database.saveResult budgetResult = budgetResultList[index];
                        if (budgetResult.Id !=null && budgetResult.isSuccess()){
                            for(PartnerFundClaim pfcRec : budgetIdToPfcListMap.get(budgetResult.Id)){
                                pfcRec.Amount = 0;
                                pfcRec.Core_MDF_Status__c = 'Paid';
                                newListOfPfc.add(pfcRec);
                                }                
                        }
                    }
                }
                finalLstOfPfcToUpdate.add(newListOfPfc);
            }
            system.debug('newPfcList '+pfcList);
            system.debug('newPfcList '+pfcList.size());
            system.debug('listOfPfcToUpdate '+finalLstOfPfcToUpdate);
            system.debug('listOfPfcToUpdate '+finalLstOfPfcToUpdate.size());
            
        }
        return finalLstOfPfcToUpdate;
    }
    
}