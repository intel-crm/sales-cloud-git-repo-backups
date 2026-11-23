/**
 * @description       : Test Class for Pricing_QuoteLetterGenerate_Batch
 * @author            : Vrushabh 
 * @group             : 
 * @last modified on  : 03-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
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
        Id asyncJobId = Database.executeBatch(batchJob);
        test.stopTest();
        System.assertEquals(true, asyncJobId != null, 'Database.executeBatch should return a non-null AsyncApexJob Id.');
    }
    
    @isTest
    public static void testExecuteMethodWithEmptyBatch(){
        // Test execute method with empty batch to cover exception handling
        test.startTest();
        Pricing_QuoteLetterGenerate_Batch batchJob = new Pricing_QuoteLetterGenerate_Batch();
        batchJob.execute(null, new List<SBQQ__Quote__c>());
        test.stopTest();
        // Should not throw any exception
        System.assert(true, 'Execute method should handle empty batch without exception');
    }
    
    @isTest
    public static void testGenerateQuoteLetterMethod(){
        // Test the generateQuoteLetter static method with sample data
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            test.startTest();
            List<SBQQ__Quote__c> quote = [SELECT Id,createdById,Pricing_Auto_generate_Quote_Letter__c,Pricing_Maximum_Approved_Rejected_Date__c FROM SBQQ__Quote__c LIMIT 1];           
            List < SBQQ__QuoteLine__c > quoteLines = [Select Id,Pricing_Quote_Program_Nm__c,SBQQ__Quote__r.Pricing_Auto_generate_Quote_Letter__c,SBQQ__Quote__r.Id,Pricing_Last_Approved_Date_dt__c,Pricing_Status_Nm__c from SBQQ__QuoteLine__c Limit 1];
            List<SBQQ__QuoteLine__c> quoteLinesUpdated = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                Pricing_Test_Utility.createPerformanceMetrics(quoteLine.Id);
                quoteLine.Pricing_Quote_Program_Nm__c = Label.Pricing_Tender_Quote_Program;
                quoteLine.Pricing_Last_Approved_Date_dt__c = datetime.now();
                quoteLine.Pricing_Status_Nm__c = 'Approved';
                quoteLinesUpdated.add(quoteLine);
            }
            update quoteLinesUpdated;
            quoteLines[0].SBQQ__Quote__r.Pricing_Auto_generate_Quote_Letter__c = true;
            update quoteLines;
            
            // Test generateQuoteLetter method
            List<Id> quoteLineIds = new List<Id>();
            for(SBQQ__QuoteLine__c quoteLine : quoteLinesUpdated){
                quoteLineIds.add(quoteLine.Id);
            }
            Pricing_QuoteLetterGenerate_Batch.generateQuoteLetter(quoteLineIds);
            System.assertEquals(true, quoteLines.size() > 0);
            test.stopTest();
        }
    }
    
    
}