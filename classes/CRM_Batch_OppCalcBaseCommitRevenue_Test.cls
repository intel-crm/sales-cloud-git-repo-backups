@isTest
public class CRM_Batch_OppCalcBaseCommitRevenue_Test {
    
    @isTest
    static void test_CalculateBaseCommitRevenue() {
        Date today = System.today();
        Date quarterStartDate = CRM_Batch_OppCalculateBaseCommitRevenue.getQuarterStartDate(today);
        Date quarterEndDate = CRM_Batch_OppCalculateBaseCommitRevenue.getQuarterEndDate(today);
        Date fourteenDaysAfterStartDate = quarterStartDate.addDays(14);
        
        system.debug('quarterStartDate from test class--'+quarterStartDate);
        system.debug('quarterEndDate from test class--'+quarterEndDate);
        system.debug('fourteenDaysAfterStartDate from test class--'+fourteenDaysAfterStartDate);
        
        // Create Opportunities within the current quarter
        List<Account> accList = Core_Test_Utility.createAccount(1); 
        accList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        
        insert accList;

        List<Opportunity> oppList = new List<Opportunity>();

        oppList.add(new Opportunity(Name = 'Test Opportunity 1', AccountId = accList[0].Id, CloseDate = quarterStartDate.addDays(1),
                                    StageName = 'Design', Amount = 1000));
        
        oppList.add(new Opportunity(Name = 'Test Opportunity 2', AccountId = accList[0].Id, CloseDate = fourteenDaysAfterStartDate,
                                    StageName = 'Qualify',Amount = 2000));
        
        oppList.add(new Opportunity(Name = 'Test Opportunity 3', AccountId = accList[0].Id, CloseDate = quarterEndDate,
                                    StageName = 'Develop', Amount = 3000));
        
        insert oppList;
        
        CRM_Batch_OppCalculateBaseCommitRevenue batch = new CRM_Batch_OppCalculateBaseCommitRevenue();
        
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Opportunity> updatedOpportunities = [SELECT Id, CloseDate, Amount, CRM_Base_Commit_Revenue__c, CRM_Current_To_Base_Commit_Percent__c FROM Opportunity WHERE Id IN :oppList];
        
        for (Opportunity opp : updatedOpportunities) {
            if (opp.CloseDate == fourteenDaysAfterStartDate) {
                System.assertEquals(opp.Amount, opp.CRM_Base_Commit_Revenue__c);
            }
            if (opp.CloseDate == quarterEndDate) {
                if (opp.CRM_Base_Commit_Revenue__c != null && opp.CRM_Base_Commit_Revenue__c != 0) {
                    Decimal expectedPercent = (opp.Amount / opp.CRM_Base_Commit_Revenue__c) * 100;
                    System.assertEquals(expectedPercent, opp.CRM_Current_To_Base_Commit_Percent__c);
                }
            }
        }
    }
}