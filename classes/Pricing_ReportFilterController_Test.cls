@isTest
public class Pricing_ReportFilterController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            User partnerUserList = Pricing_Test_Utility.createPartnerUser(acc.Id);
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            List<Pricing_Performance_Metric__c> performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            Test.stopTest();
        }
    }
    static testMethod void testSetReportFilterAsAE(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User aeUser = [SELECT Id, Name FROM User WHERE Email = 'firstNameAE@intel.com'];
        system.runAs(aeUser){
            Test.startTest();
            Pricing_ReportFilterController.setReportFilter(quote.Id);
            Test.stopTest();
        }
    }
    static testMethod void testSetReportFilterAsRPM(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User rpmUser = [SELECT Id, Name FROM User WHERE Email = 'firstNameRPM@intel.com'];
        system.runAs(rpmUser){
            Test.startTest();
            Pricing_ReportFilterController.setReportFilter(quote.Id);
            Test.stopTest();
        }
    }
    static testMethod void testSetReportFilterAsExternal(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User partnerUser = [SELECT Id, Name FROM User WHERE Email = 'partner@noemail.com'];
        system.runAs(partnerUser){
            Test.startTest();
            Pricing_ReportFilterController.setReportFilter(quote.Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetReportIdAsAE(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User aeUser = [SELECT Id, Name FROM User WHERE Email = 'firstNameAE@intel.com'];
        system.runAs(aeUser){
            Test.startTest();
            Pricing_ReportFilterController.getReportId(quote.Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetReportIdAsRPM(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User rpmUser = [SELECT Id, Name FROM User WHERE Email = 'firstNameRPM@intel.com'];
        system.runAs(rpmUser){
            Test.startTest();
            Pricing_ReportFilterController.getReportId(quote.Id);
            Test.stopTest();
        }
    }
    static testMethod void testGetReportIdAsExternal(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        User partnerUser = [SELECT Id, Name FROM User WHERE Email = 'partner@noemail.com'];
        system.runAs(partnerUser){
            Test.startTest();
            Pricing_ReportFilterController.getReportId(quote.Id);
            Test.stopTest();
        }
    }
}