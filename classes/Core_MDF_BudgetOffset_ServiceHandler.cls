/******************************************************************************************************
* Class Name  : Core_MDF_BudgetOffset_ServiceHandler 
* Version     : 1.0 
* Created Date: 04-17-2020 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AD      04/17/2020          It is a service handler class                                   
*******************************************************************************************************/
public without sharing class Core_MDF_BudgetOffset_ServiceHandler {
    //List of adjustment claims to be updated
    Public static List<PartnerFundClaim> adjClaimsTobeUpdated;
    //Map of budget id and list of adjustment claims
    Public static Map<Id,List<PartnerFundClaim>> mapOfBudgetIdToAdjClaims;
    //Map of existing budget to be updated
    Public static Map<Id,PartnerMarketingBudget> existingBudgetMap;
    /*****************************************************************************************************************************************
Method Name: assignDecreasebudgetAmntAndClaimStatus
@return    :  N/A                                         
@parameters: list of budget offset
Description: Preparing list of  budget and Claims that need to be update                                            
Added By   : AD  -  15-04-2020
Modified By:                  Date:                      Changes: 
*****************************************************************************************************************************************/
    public static void assignDecreasebudgetAmntAndClaimStatus(List<Core_MDF_Budget_Offset__c> budgetOffsetList){ 
        //Set of budget Ids
        Set<Id> budgetIdsSet = new Set<Id>();
        //Set of adjustment claim Ids
        Set<Id> adjClaimIdsSet = new Set<Id>();
        //Map of budget id and sum of adjustment claim amount
        Map<Id,Decimal> mapOfBudgetIdAmount = new Map<Id,Decimal>();
        //Map of budget id and list of adjustment claims
        mapOfBudgetIdToAdjClaims = new Map<Id,List<PartnerFundClaim>>();
        //Creating new instance of adjustment claim list
        adjClaimsTobeUpdated = new List<PartnerFundClaim>();
        //Looping incoming budget offsets        
        for(Core_MDF_Budget_Offset__c budgetOffset : budgetOffsetList){
            //preparing set of budget ids
            budgetIdsSet.add(budgetOffset.Core_MDF_Budget_Id__c);
            //preparing set of adjustment claim ids
            adjClaimIdsSet.add(budgetOffset.Core_MDF_Adjustment_Claim_Id__c);
            //hold absolute amount
            Decimal budgetOffsetAmount = budgetOffset.Core_MDF_Amount__c !=null ? ((budgetOffset.Core_MDF_Amount__c) * (-1)) : 0;
            if(mapOfBudgetIdAmount.containsKey(budgetOffset.Core_MDF_Budget_Id__c)){
                mapOfBudgetIdAmount.put(budgetOffset.Core_MDF_Budget_Id__c,mapOfBudgetIdAmount.get(budgetOffset.Core_MDF_Budget_Id__c) + budgetOffsetAmount);
            }else{
                mapOfBudgetIdAmount.put(budgetOffset.Core_MDF_Budget_Id__c,budgetOffsetAmount);
            }
        }
        //Map of existing adjustment claims
        Map<Id,PartnerFundClaim> existingPfcMap  = 
            new Map<Id,PartnerFundClaim>([Select Id,BudgetId,Core_MDF_Status__c,Amount from PartnerFundClaim where Id IN:(adjClaimIdsSet)]);
        //Map of existing budgets
        existingBudgetMap = new Map<Id,PartnerMarketingBudget>([Select Id,Core_MDF_IsApprovalProcessBypassed_Ind__c,Core_MDF_Decrease_Budget_Amount_Amt__c
                                                                                               from PartnerMarketingBudget where Id IN:(budgetIdsSet)]);
        //Looping incoming budget offsets
        //Creating map of budget Id to adjustment claims
        for(Core_MDF_Budget_Offset__c budgetOffset : budgetOffsetList){
            if(existingPfcMap.containsKey(budgetOffset.Core_MDF_Adjustment_Claim_Id__c)){
                //Assignment of claims status = PAID and amount = 0
                existingPfcMap.get(budgetOffset.Core_MDF_Adjustment_Claim_Id__c).Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid;
                existingPfcMap.get(budgetOffset.Core_MDF_Adjustment_Claim_Id__c).Amount = 0;
            }
            if(mapOfBudgetIdToAdjClaims.containsKey(budgetOffset.Core_MDF_Budget_Id__c)){
                if(existingPfcMap.containsKey(budgetOffset.Core_MDF_Adjustment_Claim_Id__c)){
                    mapOfBudgetIdToAdjClaims.get(budgetOffset.Core_MDF_Budget_Id__c).add(existingPfcMap.get(budgetOffset.Core_MDF_Adjustment_Claim_Id__c));
                }
            }else{
                if(existingPfcMap.containsKey(budgetOffset.Core_MDF_Adjustment_Claim_Id__c)){
                    mapOfBudgetIdToAdjClaims.put(budgetOffset.Core_MDF_Budget_Id__c, new List<PartnerFundClaim>{existingPfcMap.get(budgetOffset.Core_MDF_Adjustment_Claim_Id__c)});
                }
            }
        }
        //Looping budget Ids
        for(Id budgetId : mapOfBudgetIdToAdjClaims.KeySet()){
            if(existingBudgetMap.containsKey(budgetId)){
                //Assignment of budget decrease amount = sum of all adjustemnt claims and approval bypass flag = TRUE
                existingBudgetMap.get(budgetId).Core_MDF_IsApprovalProcessBypassed_Ind__c = TRUE;
                existingBudgetMap.get(budgetId).Core_MDF_Decrease_Budget_Amount_Amt__c = mapOfBudgetIdAmount.get(budgetId);
            }
        }
        system.debug('budgetsTobeUpdated - '+existingBudgetMap);
    }
    
    /*****************************************************************************************************************************************
Method Name: updateBudgetAndRelatedClaimsToPaid
@return    :  N/A                                         
@parameters:  N/A
Description: Update list of  budget and Claims                                            
Added By   : AD  -  15-04-2020
Modified By:                  Date:                      Changes: 
*****************************************************************************************************************************************/
    public static void updateBudgetAndRelatedClaimsToPaid(){
        if(existingBudgetMap!=null && 
           existingBudgetMap.values()!=null &&
           existingBudgetMap.values().size() >0){
               //Update Budgets
               Database.saveResult[] budgetResultList = database.update(existingBudgetMap.values(), false);
               for(Database.saveResult budgetResult : budgetResultList){
                   if (budgetResult.Id !=null && budgetResult.isSuccess()){
                       if(mapOfBudgetIdToAdjClaims.containsKey(budgetResult.Id)){
                           //Creating list of claims to be updated
                           adjClaimsTobeUpdated.addAll(mapOfBudgetIdToAdjClaims.get(budgetResult.Id));
                       }
                   }
               }
               system.debug('adjClaimsTobeUpdated - '+adjClaimsTobeUpdated);
               if(adjClaimsTobeUpdated!=null &&
                  adjClaimsTobeUpdated.size() >0){
                      //Update related claims to Paid
                      Database.update(adjClaimsTobeUpdated);
                  }
           }
    }
}