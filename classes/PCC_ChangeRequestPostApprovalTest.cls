@IsTest
public class PCC_ChangeRequestPostApprovalTest {
    
    @TestSetup
    static void setupData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('quoteLineControllerAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.createPriceBook();
        
        System.runAs(adminUserList[0]){
            //Pricing_Test_Utility.createPriceBook();
            
            Account acc = Pricing_Test_Utility.createAccount();
            
        // Create a new account        
        	acc = new Account(Id =acc.Id,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            update acc;
            
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            //Test.startTest();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            //List<SBQQ__Quote__c> quoteListNotUnifiedCustomer = Pricing_Test_Utility.createQuoteWithParamPartialUnified(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            
            // Create a test Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Define', CloseDate = System.today().addDays(30));
            insert opp;
            
            // Create a test OpportunityLineItem
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, SBQQ__QuoteLine__c = lstquoteLines[0].Id, Quantity = 1, TotalPrice = 100);
            insert oli;
            
            // Create a test Change Request Line Item
            PCC_Deal_Change_Request_Line_Item__c crli = new PCC_Deal_Change_Request_Line_Item__c(PCC_Change_Request__c = 'ChangeRequest1', PCC_Opportunity_Product_Id__c = oli.Id, PCC_Approval_Status__c = 'Approved- RPM Pending');
            insert crli;
        }
    }
    
    @IsTest
    static void testChangeRequestPostApproval() {
        // Retrieve the test quote created in setup
        List<SBQQ__Quote__c> testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Call the method under test
        List<Id> quoteIds = new List<Id>{ testQuote[0].Id };
        List<PCC_ChangeRequestPostApproval.ResponseWrapper> response = PCC_ChangeRequestPostApproval.changeRequestPostApproval(quoteIds);
        
        // Assertions to ensure the method worked correctly
        System.assertNotEquals(null, response);
        System.assertEquals('Success', response[0].response[0]);
        
        // Verify that the Change Request Line Item status was updated
        PCC_Deal_Change_Request_Line_Item__c updatedCRLI = [SELECT Id, PCC_Approval_Status__c FROM PCC_Deal_Change_Request_Line_Item__c LIMIT 1];
        System.assertEquals('Approved- RPM Complete', updatedCRLI.PCC_Approval_Status__c);
    }
    
    @IsTest
    static void testChangeRequestPostApprovalWithError() {
        // Retrieve the test quote created in setup
        List<SBQQ__Quote__c> testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Test scenario where an error should occur (e.g., invalid Quote ID)
        List<Id> invalidQuoteIds = new List<Id>{ 'InvalidId' };
        
        // Call the method under test
        List<PCC_ChangeRequestPostApproval.ResponseWrapper> response = PCC_ChangeRequestPostApproval.changeRequestPostApproval(invalidQuoteIds);
        
        // Assertions to ensure error handling works correctly
        System.assertNotEquals(null, response);
        System.assertEquals('Failed', response[0].response[0]);
        System.assertNotEquals(null, response[0].errorMessage);
    }
}