/****************************************************************************************************************************************
* Class Name  		: Core_MDF_OPAL_Budget_Validation
* Version     		: 1.0
* Created Date		: 12-03-2021
* Modification Log :
* Developer            	Date               	Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel :Areefa Banu       12/03/2021          Class to handle Opal Budget Validation
*****************************************************************************************************************************************/
public without sharing class Core_MDF_OPAL_Budget_Validation {
    public static void validateOpalBudgetDates(List<PartnerMarketingBudget> newPMBList) {
        try{
            Map<Id,Date> mapofBudgetIdActyStartDate = new Map<Id,Date>(); 
            Map<Id,Date> mapofBudgetIdActyEndDate = new Map<Id,Date>();
            Id coMarketingRecordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_Co_Marketing_Record_Type_Developer_Name).getRecordTypeId(); 
            //Get the opal budget types
            List<string> validbudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_OPAL_BudgetTypes');           
            List<PartnerMarketingBudget> eligibleBudgets = new List<PartnerMarketingBudget>();
            //Filterig our only Opal Budgets
            for(PartnerMarketingBudget pmbRecord :newPMBList) {
                if(pmbRecord.RecordTypeId == coMarketingRecordtype && (validbudgetTypes.contains(string.valueof(pmbRecord.Core_MDF_Budget_Type_Txt__c)))){
                    eligibleBudgets.add(pmbRecord);
                }                
            }
            if(eligibleBudgets != null && eligibleBudgets.size()>0)
            {
                //Get the eligible activities start date and end date based on budget
                List<AggregateResult> existingActyDetails = [SELECT BudgetId budgetId,MIN(Core_MDF_Start_Date__c) MinActyStartDate, MAX(Core_MDF_End_Date__c) MaxActyEndDate 
                                                             from PartnerFundRequest WHERE Core_MDF_Fund_Request_Status__c NOT IN ('Cancelled') and
                                                             BudgetId In :eligibleBudgets group by BudgetId ];
              
                if(existingActyDetails!= null && existingActyDetails.size() > 0){ 
                    for(AggregateResult agg:existingActyDetails){ 
                        Date minActyStartDate = (Date)agg.get('MinActyStartDate');
                        Date maxActyEndDate = (Date)agg.get('MaxActyEndDate');
                        Id budgetId =(Id)agg.get('budgetId');
                        mapofBudgetIdActyStartDate.put(budgetId, minActyStartDate);
                        mapofBudgetIdActyEndDate.put(budgetId, maxActyEndDate);
                    }
                } 
                //compare the new budget dates against activity dates
                for(PartnerMarketingBudget pmb : eligibleBudgets){
                    if(mapofBudgetIdActyStartDate != null && mapofBudgetIdActyEndDate != null && mapofBudgetIdActyStartDate.containsKey(pmb.Id) && mapofBudgetIdActyEndDate.containsKey(pmb.Id)
                       && (pmb.StartDate > mapofBudgetIdActyStartDate.get(pmb.Id) || pmb.EndDate < mapofBudgetIdActyEndDate.get(pmb.Id))){
                           pmb.addError('This Budget has existing activities which are beyond the new date range selected. Select different start and end dates before saving.');
                       } 
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
}