/****************************************************************************************************
Apex Class Name : Pricing_sw_QuoteExpiryBatchTest 
Version         : 1.0 
Created Date    : 08/13/2024
Function        : Test class for batch Pricing_sw_QuoteExpiryBatch.
*****************************************************************************************************/
@isTest
public class Pricing_sw_QuoteExpiryBatchTest {
    @isTest
    static void testQuoteExpiryBatch() {
        setUpValidationBypass();
        setUpTemplates();

        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Pricing_Software_Quote_Readonly' LIMIT 1].Id;
        SBQQ__Quote__c approvedQuote = createApprovedQuote(recordTypeId, Date.today());

        approvedQuote.Pricing_SW_Expiry_Date__c = Date.today().addDays(-5); // Expired
        update approvedQuote;

        Test.startTest();
        Pricing_sw_QuoteExpiryBatch batch = new Pricing_sw_QuoteExpiryBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        approvedQuote = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :approvedQuote.Id];
        System.assertNotEquals(Label.Pricing_SW_QuoteStatusDenied, approvedQuote.SBQQ__Status__c, 'The quote status should not be denied after the batch job.');
    }

    private static void setUpValidationBypass() {
        Pricing_Sw_Validation_Bypass__c setting = new Pricing_Sw_Validation_Bypass__c();
        setting.By_Pass_Validation__c = true;
        insert setting;
    }

    private static void setUpTemplates() {
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
    }

    private static SBQQ__Quote__c createApprovedQuote(Id recordTypeId, Date expiryDate) {
        SBQQ__Quote__c approvedQuote = new SBQQ__Quote__c();
        approvedQuote.ApprovalStatus__c = Label.Pricing_SW_QuoteStatusApproved;
        approvedQuote.SBQQ__Status__c = Label.Pricing_SW_QuoteStatusApproved;
        approvedQuote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Software;
        approvedQuote.RecordTypeId = recordTypeId;
        approvedQuote.SBQQ__Primary__c = true;
        approvedQuote.Pricing_SW_Expiry_Date__c = expiryDate; // Set expiry date
        approvedQuote.SBQQ__StartDate__c = Date.today();
        approvedQuote.SBQQ__SubscriptionTerm__c = 12;
        insert approvedQuote;
        return approvedQuote;
    }
}