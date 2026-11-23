/****************************************************************************************************
Apex Class Name : Pricing_sw_QuoteExpiryBatchTest 
Version         : 1.0 
Created Date    : 08/13/2024
Function        : Test class for batch Pricing_sw_QuoteExpiryBatch.
*****************************************************************************************************/
@isTest
public class Pricing_sw_QuoteExpiryBatchTest {
    
    @testsetup
    static void setupData() {
        Pricing_Sw_Validation_Bypass__c setting = new Pricing_Sw_Validation_Bypass__c();
        setting.By_Pass_Validation__c = true;
        insert setting;
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Pricing_Software_Quote_Readonly'].Id;
        //SBQQ__Quote__c testQuote = createApprovedQuote(recordTypeId, Date.today());
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        
        // Insert a quote to update later
        SBQQ__Quote__c approvedQuote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(approvedQuote);
        approvedQuote.ApprovalStatus__c = Label.Pricing_SW_QuoteStatusApproved;
        approvedQuote.SBQQ__Status__c = Label.Pricing_SW_QuoteStatusApproved;
        
        approvedQuote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Software;
        approvedQuote.RecordTypeId = recordTypeId;
        approvedQuote.SBQQ__Primary__c = true;
        approvedQuote.Pricing_SW_Expiry_Date__c = Date.today(); // Set expiry date
        approvedQuote.SBQQ__StartDate__c = Date.today();
        approvedQuote.SBQQ__SubscriptionTerm__c = 12;
        update approvedQuote;
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
        
    }
    @isTest
    static void testQuoteExpiryBatch() {
        Account acc = [Select id,name from Account where name ='Test Account'];
        SBQQ__Quote__c approvedQuote = [Select id,Pricing_SW_Expiry_Date__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id];
        approvedQuote.Pricing_SW_Expiry_Date__c = Date.today().addDays(-5); // Expired
        update approvedQuote;
       
        Test.startTest();
        Pricing_sw_QuoteExpiryBatch batch = new Pricing_sw_QuoteExpiryBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        approvedQuote = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :approvedQuote.Id];
        System.assertNotEquals(Label.Pricing_SW_QuoteStatusDenied, approvedQuote.SBQQ__Status__c, 'The quote status should not be denied after the batch job.');
    }

    @isTest
    static void testQuoteExpiryBatchScheduler() {
            Test.startTest();
            // Schedule the batch class
            String jobId = System.schedule('Pricing_sw_QuoteExpiryBatch', '0 0 0 1 1 ? *', new Pricing_sw_QuoteexpiryBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                              FROM CronTrigger 
                              WHERE id = :jobId];
            System.assertEquals(0, ct.TimesTriggered, 'The batch job should not have run yet.');
            System.assertEquals('0 0 0 1 1 ? *', ct.CronExpression, 'The Cron expression should match the scheduled one.');
            DateTime nextFireTime = ct.NextFireTime;
            System.assert(nextFireTime != null, 'Next fire time should not be null');
            Test.stopTest();
      }
}