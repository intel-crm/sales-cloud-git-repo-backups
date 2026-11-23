@IsTest
public class core_AccountPlanRevenueController_Test {
   
    @IsTest
    static void testGetOpportunities() {
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospect',
                CloseDate = Date.today().addDays(i),
                AccountId = testAcct.Id
            );
            opportunities.add(opportunity);
        }
        insert opportunities;

        Test.startTest();
        List<Opportunity> retrievedOpportunities = core_AccountPlanRevenueController.getOpportunities(accountPlan.Id);
        Test.stopTest();

        
    }

    @IsTest
    static void testGetOpportunityDetails() {
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospect',
            CloseDate = Date.today(),
            AccountId = testAcct.Id,
            Amount = 10000
        );
        insert opportunity;
        Test.startTest();
        AccountPlan retrievedAccountPlan = core_AccountPlanRevenueController.getOpportunityDetails(accountPlan.Id);
        Test.stopTest();

    }

    @IsTest
    static void testGetOpportunityId() {
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospect',
            CloseDate = Date.today(),
            AccountId = testAcct.Id,
            Amount = 10000
        );
        insert opportunity;

        Test.startTest();
        AccountPlan retrievedAccountPlan = core_AccountPlanRevenueController.getPreOpportunityDetail(accountPlan.Id);
        Test.stopTest();

    }

    @IsTest
    static void testSaveOpportunityComments() {
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opportunity = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospect',
                CloseDate = Date.today().addDays(i),
                AccountId = testAcct.Id
            );
            opportunities.add(opportunity);
        }
        insert opportunities;

        Test.startTest();
        core_AccountPlanRevenueController.saveOpportunityComments(accountPlan.Id, new List<Id>{opportunities[0].Id, opportunities[1].Id}, 'Test Comment');
        Test.stopTest();

    }
}