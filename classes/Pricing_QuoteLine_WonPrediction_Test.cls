@isTest
public class Pricing_QuoteLine_WonPrediction_Test {
@testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('quoteLineControllerAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.createPriceBook();

        System.runAs(adminUserList[0]){
            //Pricing_Test_Utility.createPriceBook();
            
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            //Test.startTest();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            //List<SBQQ__Quote__c> quoteListNotUnifiedCustomer = Pricing_Test_Utility.createQuoteWithParamPartialUnified(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            SBQQ__QuoteLine__c lstquoteLines = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id, 'Approved');

        }
    }
    static testmethod void testpredictionQlStatusMarkAsWon(){
        Set<Id> qlIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id from SBQQ__QuoteLine__c LIMIT 1];
        qlIds.add(quoteLineList[0].Id);
        Test.setMock(HTTPCalloutMock.class, new Pricing_QlWonPredictionCalloutMockServc());
        Pricing_QuoteLine_WonPrediction.predictionQlStatusMarkAsWon(qlIds);
        System.assertEquals(quoteLineList.size() > 0, true);
    }
}