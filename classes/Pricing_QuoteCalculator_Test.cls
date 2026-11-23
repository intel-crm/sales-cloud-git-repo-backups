/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-06-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteCalculator_Test {
    
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('quoteLineControllerAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.createPriceBook();

        System.runAs(adminUserList[0]){
            //Pricing_Test_Utility.createPriceBook();
            
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Calculator_Test');
            //Test.startTest();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            //List<SBQQ__Quote__c> quoteListNotUnifiedCustomer = Pricing_Test_Utility.createQuoteWithParamPartialUnified(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
        }
    }
    
    static testMethod void testquoteCalculator(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        QuoteModel quoteModel = new QuoteModel();
        quoteModel.record = quoteList[0];
        Test.startTest();
        Pricing_QuoteCalculator calculator = new Pricing_QuoteCalculator();
		calculator.calculate(quoteModel, 'Pricing_CalculatorCallBack');
        System.assertEquals(true , quoteList.size() > 0 );
        Test.stopTest();
        
    }
    
     static testMethod void testquoteCalculatorWithList(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<QuoteModel> quoteModel = new List<QuoteModel>();
        Test.startTest();
        Pricing_QuoteCalculator calculator = new Pricing_QuoteCalculator();
		calculator.calculate(quoteModel, 'Pricing_CalculatorCallBack');
        System.assertEquals(true , quoteList.size() > 0 );
        Test.stopTest();
        
    }

}