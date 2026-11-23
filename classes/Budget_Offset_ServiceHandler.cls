public with sharing class Budget_Offset_ServiceHandler {

    public void UpdateBudgetRecords(List<Core_MDF_Budget_Offset__C> newBudgetOffsetList){

        List<PartnerFundClaim> claimsTobeUpdatedToPaid = new List<PartnerFundClaim>();
        Map<ID, Decimal> mapBudgetIdToAmountToUpdated = new Map<ID, Decimal>();
        Map<ID, PartnerMarketingBudget> mapBudgetIdToBdgtAmountToUpdated = new Map<ID, PartnerMarketingBudget>();
        Decimal newBudgetRedutionAmt = 0;
        //Go through the list of Budget offset and identify the amount to be updated on each Budgets
        for(Core_MDF_Budget_Offset__C budgetOffsetRec : newBudgetOffsetList){

            if(mapBudgetIdToAmountToUpdated.containsKey(budgetOffsetRec.Core_MDF_Budget_Id__c))
                    newBudgetRedutionAmt = mapBudgetIdToAmountToUpdated.get(budgetOffsetRec.Core_MDF_Budget_Id__c) + budgetOffsetRec.Core_MDF_Amount__c;
                else {
                    newBudgetRedutionAmt  = budgetOffsetRec.Core_MDF_Amount__c;
                }
           
            mapBudgetIdToAmountToUpdated.put(budgetOffsetRec.Core_MDF_Budget_Id__c,newBudgetRedutionAmt);
            mapBudgetIdToBdgtAmountToUpdated.put(budgetOffsetRec.Core_MDF_Budget_Id__c, new PartnerMarketingBudget(Id = budgetOffsetRec.Core_MDF_Budget_Id__c, Core_MDF_Decrease_Budget_Amount_Amt__c = newBudgetRedutionAmt));
            claimsTobeUpdatedToPaid.add(new PartnerFundClaim(Id= budgetOffsetRec.Core_MDF_Adjustment_Claim_Id__c, Amount = 0, core_mdf_status__C = 'Paid'));
        }
   
        update mapBudgetIdToBdgtAmountToUpdated.values();
        update claimsTobeUpdatedToPaid;
    }

}