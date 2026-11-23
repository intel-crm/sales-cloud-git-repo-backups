public with sharing class AccountPlanKPIController {
    @AuraEnabled(cacheable=true)
    public static AccountPlanKPIData getKPIs(Id recordId) {
        AccountPlanKPIData kpiData = new AccountPlanKPIData();

        // Fetch Account Plan Data
        AccountPlan accountPlan = [
            SELECT AccountId,Account.Name,name
            FROM accountPlan 
            WHERE Id = :recordId
            LIMIT 1
        ];

     
		id accountId = accountPlan.AccountId;
        // Fetch Opportunity Data
        List<AggregateResult> opportunityStages = [
            SELECT StageName, COUNT(Id) totalcount FROM Opportunity 
            WHERE AccountId = :accountId 
            GROUP BY StageName
        ];
        
        for (AggregateResult result : opportunityStages) {
            kpiData.opportunityStages.add(new OpportunityStageData(
                String.valueOf(result.get('StageName')),
                Integer.valueOf(result.get('totalcount'))
            ));
        }

        // Mock Revenue & Win Rate (Replace with Actual Fields)
      //  kpiData.lastQuarterRevenue = 9000000; // Replace with actual calculation
      //  kpiData.thisQuarterRevenue = 0;
        kpiData.lastQuarterWinRate = 83; // Replace with actual calculation
        kpiData.thisQuarterWinRate = 0;

        return kpiData;
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountName(Id recordId) {
        
          AccountPlan accountPlan = [
            SELECT AccountId,Account.Name
            FROM accountPlan 
            WHERE Id = :recordId
            LIMIT 1
        ];
        return accountPlan.Account.Name;
    }
    public class AccountPlanKPIData {
        @AuraEnabled public Decimal lastQuarterRevenue;
        @AuraEnabled public Integer lastQuarterWinRate;
        @AuraEnabled public Integer thisQuarterWinRate;
        @AuraEnabled public List<OpportunityStageData> opportunityStages = new List<OpportunityStageData>();
    }

    public class OpportunityStageData {
        @AuraEnabled public String stage;
        @AuraEnabled public Integer count;
        public OpportunityStageData(String stage, Integer count) {
            this.stage = stage;
            this.count = count;
        }
    }
}