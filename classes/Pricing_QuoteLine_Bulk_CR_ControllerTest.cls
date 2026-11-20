/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 04-07-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public class Pricing_QuoteLine_Bulk_CR_ControllerTest {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Line_Bulk_CR_Controller_Test');
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 2);
            test.stopTest();
        }
    }
    
    static testMethod void testgetQuoteLineDetails(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        System.runAs(adminUser){
            qliList = Pricing_QuoteLine_Bulk_CR_Controller.getQuoteLineDetails(quote.Id);
        }
        Boolean var = qliList.size() > 0;
        System.assertEquals(var, false);
        Test.stopTest();
    }
    
}