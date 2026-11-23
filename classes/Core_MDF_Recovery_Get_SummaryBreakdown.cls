public class Core_MDF_Recovery_Get_SummaryBreakdown {
 @AuraEnabled(cacheable=true)
    public static List<Core_MDF_Partnership_Score_Detail__c> Get_SummaryBreakdown(String program,Id account,String quarter) {
        return [SELECT Id, Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Total_Recovery_Amt__c, Core_MDF_Carry_Over_Amt__c,Core_MDF_Recovered_Amt__c 
            FROM Core_MDF_Partnership_Score_Detail__c where  Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c=:Program and Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c=:account  and Core_MDF_Quarter_Year_Nm__c =:quarter];
    }
}