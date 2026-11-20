/****************************************************************************************************************************************
* Class Name  : Core_MDF_Budget_Utility
* Version     : 1.0 
* Created Date: 10-16-2018
* Descirption : This class is in WITHOUT SHARING mode , kindly do not update
* Developer            Date               Description
* Modified by: Mohit   31/05/2024         Added condition for IPA Account Plan Budgets Date update to fire validation based on start date of activity associated 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AH      10/16/2018          Utility Class for Budget functionalities.
*****************************************************************************************************************************************/

public without sharing class Core_MDF_Budget_Utility{
    
/**************************************************************************************************************************  
Method Name:        unlockBudget
@return  :          void
@parameters:        budgetList - Budget List
Description:        This method is used to unlock the Pending Review budget, Update the Budget and Lock it again
Added By:           Accenture - JV - 10/16/2018
Intel - SM - 07/04/2020
****************************************************************************************************************************/
    @AuraEnabled
    public static void unlockBudget(List<PartnerMarketingBudget> budgetList){
        try
        {	
            Approval.unlock(budgetList, true);
            update budgetList; Approval.lock(budgetList, true);
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }  
/*************************************************************************** 
    Method Name:       validateBudgetDatesChange
    @return  :          
    @parameters:        budget
    Description:        On Budget date change
*********************************************************************************/
    public static void validateBudgetDateChangeAgainstAct(List<PartnerMarketingBudget> newPMBList,Map<Id,PartnerMarketingBudget> oldPMBMap) {
        try{
            Map<Id,Date> mapofBudgetIdActyStartDate = new Map<Id,Date>(); 
            Map<Id,Date> mapofBudgetIdActyEndDate = new Map<Id,Date>();
            Map<Id,Date> mapofBudgetIdMaxActyStartDate = new Map<Id,Date>(); // Added specifically for IPA 
			List<PartnerMarketingBudget> eligibleBudgets = new List<PartnerMarketingBudget>(); 
			Set<Id> eligibleBudgetIds = new Set<Id>();
			for(PartnerMarketingBudget pmbRecord : newPMBList){
                 if( oldPMBMap !=null && (pmbRecord.StartDate != oldPMBMap.get(pmbRecord.Id).StartDate || pmbRecord.EndDate != oldPMBMap.get(pmbRecord.Id).EndDate)){
                           eligibleBudgetIds.add(pmbRecord.Id);
                    	   eligibleBudgets.add(pmbRecord);
                       } 
                }
            if(!eligibleBudgetIds.isEmpty()) {
               //Get the eligible activities start date and end date based on budget
                List<AggregateResult> existingActyDetails = [SELECT BudgetId budgetId,MIN(Core_MDF_Start_Date__c) MinActyStartDate, MAX(Core_MDF_End_Date__c) MaxActyEndDate, MAX(Core_MDF_Start_Date__c) MaXActyStartDate 
                                                             from PartnerFundRequest WHERE BudgetId In :eligibleBudgetIds and Core_MDF_Fund_Request_Status__c NOT IN ('Cancelled') group by BudgetId ];
              
                if(existingActyDetails!= null && existingActyDetails.size() > 0){ 
                    for(AggregateResult agg:existingActyDetails){ 
                        Date minActyStartDate = (Date)agg.get('MinActyStartDate');
                        Date maxActyEndDate = (Date)agg.get('MaxActyEndDate');
                        Date maxActyStartDate = (Date)agg.get('MaXActyStartDate');
                        Id budgetId =(Id)agg.get('budgetId');
                        mapofBudgetIdActyStartDate.put(budgetId, minActyStartDate);
                        mapofBudgetIdActyEndDate.put(budgetId, maxActyEndDate);
                        mapofBudgetIdMaxActyStartDate.put(budgetId, maxActyStartDate);
                    }
                }
                //compare the new budget dates against activity dates
                //below condition in (else if) has been added for IPA Budgets to fire validation if budget date range is beyond associated activity start date 
                for(PartnerMarketingBudget pmb : eligibleBudgets){
                    if(pmb.Core_MDF_Program_Nm__c != Core_MDF_CCP_ConstantClass.IPA_PROGRAM && mapofBudgetIdActyStartDate != null && mapofBudgetIdActyEndDate != null && mapofBudgetIdActyStartDate.containsKey(pmb.Id)
                       && mapofBudgetIdActyEndDate.containsKey(pmb.Id) && (pmb.StartDate > mapofBudgetIdActyStartDate.get(pmb.Id) || pmb.EndDate < mapofBudgetIdActyEndDate.get(pmb.Id))){
                           pmb.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Date_Change_Error'));
                           
                       }else if(pmb.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && mapofBudgetIdActyStartDate != null && mapofBudgetIdMaxActyStartDate != null && mapofBudgetIdActyStartDate.containsKey(pmb.Id) 
                                && mapofBudgetIdMaxActyStartDate.containsKey(pmb.Id) && (pmb.StartDate > mapofBudgetIdActyStartDate.get(pmb.Id) || pmb.EndDate < mapofBudgetIdMaxActyStartDate.get(pmb.Id))){
                                    pmb.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Date_Change_Error'));
                                }
                }
           }       
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
}