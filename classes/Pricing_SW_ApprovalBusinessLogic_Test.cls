@isTest
public class Pricing_SW_ApprovalBusinessLogic_Test {

    private static Account testAccount;
    private static Opportunity testOpportunity;
    private static SBQQ__Quote__c testQuote;

    @testSetup
    static void setupTestData() {
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');

        // Set up Account data
        testAccount = Pricing_SW_UtilityTest.createAccount('Test Account');
            
        // Set up Opportunity data
        testOpportunity = Pricing_SW_UtilityTest.createOpportunity(testAccount, 'Prospecting', Date.today().addMonths(1));
                    
        // Set up Quote data
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Draft', testAccount.Id);

        sbaa__Approval__c approvalRequested = new sbaa__Approval__c(
            Quote__c = testQuote.Id,
            sbaa__Status__c = 'Requested',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Quote__c'
        );

        sbaa__Approval__c approvalApproved = new sbaa__Approval__c(
            Quote__c = testQuote.Id,
            sbaa__Status__c = 'Approved',
            sbaa__CommentsLong__c = 'Approved comments',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Quote__c'
        );

        sbaa__Approval__c approvalRejected = new sbaa__Approval__c(
            Quote__c = testQuote.Id,
            sbaa__Status__c = 'Rejected',
            sbaa__CommentsLong__c = 'Rejected comments',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Quote__c'
        );

        sbaa__Approval__c approvalRecalled = new sbaa__Approval__c(
            Quote__c = testQuote.Id,
            sbaa__Status__c = 'Recalled',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Quote__c'
        );

        insert new List<sbaa__Approval__c>{ approvalRequested, approvalApproved, approvalRejected, approvalRecalled };
    }

    @isTest
    static void testAfterInsertUpdateApprovalComments() {
        // Retrieve all test data
        List<sbaa__Approval__c> approvalList = [SELECT Id, sbaa__Status__c, Quote__c, sbaa__CommentsLong__c FROM sbaa__Approval__c];

        Map<Id, sbaa__Approval__c> oldMap = new Map<Id, sbaa__Approval__c>();
    
        for (sbaa__Approval__c approval : approvalList) {
            sbaa__Approval__c oldApproval = approval.clone(false, true, true, true);
            oldApproval.sbaa__Status__c = 'Requested';  // Simulate a status change from 'Requested'
            oldMap.put(approval.Id, oldApproval);
        }
    
        Test.startTest();
        Integer emailSentBefore = Limits.getEmailInvocations();
        Pricing_SW_ApprovalBusinessLogic.afterInsertUpdateApprovalComments(approvalList, oldMap);
        Integer emailSentAfter = Limits.getEmailInvocations();
        Test.stopTest();
    
        // Verify the changes to the quotes
        List<SBQQ__Quote__c> updatedQuotes = [SELECT Id, Pricing_SW_Approval_Comments__c FROM SBQQ__Quote__c];

        for (SBQQ__Quote__c quote : updatedQuotes) {
            String expectedComments = null;

            for (sbaa__Approval__c approval : approvalList) {
                if (approval.Quote__c == quote.Id) {
                    if (approval.sbaa__Status__c == Label.Pricing_SW_QuoteApprovalStatusApproved || approval.sbaa__Status__c == Label.Pricing_SW_QuoteApprovalStatusRejected) {
                        expectedComments = approval.sbaa__CommentsLong__c;
                    } else if (approval.sbaa__Status__c == Label.Pricing_SW_QuoteApprovalStatusRecalled) {
                        expectedComments = null; // Recalled status should clear comments
                    }
                    break;
                }
            }

            System.assertEquals(expectedComments, quote.Pricing_SW_Approval_Comments__c, 'Quote comments do not match the expected value');
        }
    
        // Verify that email notifications were sent
        System.assert(emailSentAfter > emailSentBefore, 'Email notifications were not sent.');
    }

}