/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_PriceComparisionController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Price_Comparison_Controller_Test');
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 2);
            Test.stopTest();
        }
    }
    
    static testMethod void testGetMetadataColumns(){
        List<Pricing_PriceComparisionController.DataTableColumns> lstDataColumns = new List<Pricing_PriceComparisionController.DataTableColumns>();
        Test.startTest();
		lstDataColumns = Pricing_PriceComparisionController.getDataTableColumns();
        Boolean var = lstDataColumns.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testgetQuoteLineDataforComparision(){
        String searchText;
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Quote_Line_Number__c,Pricing_Product_Nm__r.Name,Pricing_Status_Nm__c,Pricing_Product_Nm__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Program_Type_Nm__c,
                                                   Pricing_Quote_Program_Nm__c from SBQQ__QuoteLine__c LIMIT 2];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<Pricing_PriceComparisionController.QuoteLineDetails> quoteLineDetailsList = new List<Pricing_PriceComparisionController.QuoteLineDetails>();
        Test.startTest();
        System.runAs(adminUser){
            quoteLineList[0].Pricing_Status_Nm__c = 'Won';
            quoteLineList[0].Pricing_Last_Submitted_Date_dt__c = system.today();
            quoteLineList[1].Pricing_Status_Nm__c = 'Won';
            quoteLineList[1].Pricing_Last_Submitted_Date_dt__c = system.today();
            quoteLineList[1].Pricing_Product_Nm__c = quoteLineList[0].Pricing_Product_Nm__c;
            update quoteLineList;
        }
        quoteLineDetailsList = Pricing_PriceComparisionController.getQuoteLineDataforComparision(quoteLineList[0].Pricing_Quote_Line_Number__c,searchText);
        Boolean var = quoteLineDetailsList.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testgetQuoteLineNumber(){
        SBQQ__QuoteLine__c qli = [SELECT Id,Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c LIMIT 1];
        Test.startTest();
        String qliNumber = Pricing_PriceComparisionController.getQuoteLineNumber(qli.Id);
        System.assertEquals(qliNumber, qli.Pricing_Quote_Line_Number__c);
        Test.stopTest();
    }
}