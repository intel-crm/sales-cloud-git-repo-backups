@isTest
public class Pricing_QuoteLine_BulkWonLostBatchTest {
    
    @testSetup
    static void dataSetup(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            test.stopTest();
        }
    }
    
    static testMethod void testProcessWonLost(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Won_Lost_Comments_Txt__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Map<String, SBQQ__QuoteLine__c> QLMap = New Map<String, SBQQ__QuoteLine__c>();

        QLMap.put(quoteLineList[0].Pricing_Quote_Line_Number__c,quoteLineList[0]);
        System.runAs(adminUser){
            Pricing_QuoteLine_BulkWonLostBatch bulkWonLost = new Pricing_QuoteLine_BulkWonLostBatch(QLMap);
            Database.executeBatch(bulkWonLost, Integer.valueOf(Label.Pricing_QuoteLine_BulkWonLost_BatchSize));
        }
        System.assertEquals(quoteLineList[0].Pricing_Status_Nm__c, 'Approved');
        Test.stopTest();
    }
}