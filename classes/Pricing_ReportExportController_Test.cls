@isTest
public class Pricing_ReportExportController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createContact(acc.Id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            User partnerUserList = Pricing_Test_Utility.createPartnerUser(acc.Id);
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Test.stopTest();
        }
    }
    static testmethod void testGetReportData(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_ReportExportController.getReportData(quote.Id);
        Test.stopTest();
    }
    static testMethod void testGetColumnHeaders(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        Pricing_ReportExportController.getColumnHeaders(quote.Id);
        Test.stopTest();
    }
}