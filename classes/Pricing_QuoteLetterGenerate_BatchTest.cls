/**
 * @description       : 
 * @author            : Vrushabh 
 * @group             : 
 * @last modified on  : 12-11-2024
 * @last modified by  : Vrushabh 
**/
@isTest
public class Pricing_QuoteLetterGenerate_BatchTest {

    @testSetup
    static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Letter_Generate_Batch_Test');
            
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
    
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);            
            List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 2);
            List<SBQQ__QuoteLine__c> quoteLinesUpdated = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                Pricing_Test_Utility.createPerformanceMetrics(quoteLine.Id);
                quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Tender_Quote_Program;
                quoteLine.Pricing_Last_Approved_Date_dt__c = datetime.now();
                quoteLine.Pricing_Status_Nm__c = 'Approved';
                quoteLinesUpdated.add(quoteLine);
            }
            test.startTest();
            update quoteLinesUpdated;
            quoteList[0].Pricing_Auto_generate_Quote_Letter__c = true;
            update quoteList;
            test.stopTest();
        }                         
    } 

    @isTest
    public static void testQuoteLineBatch(){ 
        test.startTest();
        Pricing_QuoteLetterGenerate_Batch batchJob = new Pricing_QuoteLetterGenerate_Batch();
        Database.executeBatch(batchJob);
        test.stopTest();
    }
}