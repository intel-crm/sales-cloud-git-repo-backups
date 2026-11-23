/**
* @description       : Test class for Quote Email Alert Controller
* @author            : Prasad
* @group             : Software & Services
* @last modified on  : 08-21-2024
* @last modified by  : Prasad
**/

@isTest
public class Pricing_SW_QuoteEmailAlertControllerTest {

    private static Document testDocument;
    private static Account testAccount;
    private static Opportunity testOpportunity;
    private static SBQQ__Quote__c testQuote;
    private static List<SBQQ__Quote__c> testQuotes;
    private static List<sbaa__Approval__c> testApproval;
    private static Network testCommunityNetwork;
    private static Network testDealRegNetwork;

    @testSetup
    static void setupData() {
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        // Set up Document data
        testDocument = Pricing_SW_UtilityTest.createTestDocument();
        
        // Set up Account data
        testAccount = Pricing_SW_UtilityTest.createAccount('Test Account');
        
        // Set up Opportunity data
        testOpportunity = Pricing_SW_UtilityTest.createOpportunity(testAccount, 'Prospecting', Date.today().addMonths(1));
        
        // Set up Quote data
        testQuote = new SBQQ__Quote__c();
        testQuotes = new List<SBQQ__Quote__c>();
        
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Quote - Draft', testAccount.Id);        
        testQuotes.Add(testQuote);
        
        testQuote = new SBQQ__Quote__c();
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Quote - Approved', testAccount.Id);        
        testQuotes.Add(testQuote);
        
        testQuote = new SBQQ__Quote__c();
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Quote - Rejected', testAccount.Id);        
        testQuotes.Add(testQuote);
        
        testQuote = new SBQQ__Quote__c();
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Quote - Denied', testAccount.Id);        
        testQuotes.Add(testQuote);        
        
        // Set up Approval data
        testApproval = Pricing_SW_UtilityTest.createTestApproval(testQuotes);
        
    }  

    /*@isTest
    static void testGetHeaderURL() {
        // Instantiate the controller
        Pricing_SW_QuoteEmailAlertController controller = new Pricing_SW_QuoteEmailAlertController();

        // Test the getHeaderURL method
        Test.startTest();
        String headerURL = controller.getHeaderURL();
        Test.stopTest();

        // Validate the results
        System.assert.isNotNull(headerURL, 'Header URL should not be null');
        //System.assert(headerURL.contains('servlet.ImageServer'), 'Header URL should contain servlet.ImageServer:' + headerURL);
    }*/
    
    @isTest
    static void testGetHeaderURL() {
        // Create a mock Document record
        Document doc = new Document(
            Name = Label.Pricing_SW_Intel_Logo, //'Pricing_SW_Intel_Logo',  // Match this with the value of Label.Pricing_SW_Intel_Logo
            Body = Blob.valueOf('Test Content'),
            FolderId = UserInfo.getUserId() // Set FolderId to a valid ID, like the running user's ID
        );
        insert doc;

        // Create an instance of the controller
        Pricing_SW_QuoteEmailAlertController controller = new Pricing_SW_QuoteEmailAlertController();

        // Test the getHeaderURL method
        Test.startTest();
        String headerURL = controller.getHeaderURL();
        Test.stopTest();

        // Validate the results
        System.assert.isNotNull(headerURL, 'Header URL should not be null');
        System.assert(headerURL.contains('servlet.ImageServer'), 'Header URL should contain servlet.ImageServer: ' + headerURL);
    }
    
    @isTest
    static void testGetQuoteData() {
        // Fetch the quote with 'Approved' status
        SBQQ__Quote__c approvedQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote - Approved' LIMIT 1];
        
        // Instantiate the controller and set the quoteId
        Pricing_SW_QuoteEmailAlertController controller = new Pricing_SW_QuoteEmailAlertController();
        controller.quoteId = approvedQuote.Id;

        // Test the getQuoteData method
        Test.startTest();
        SBQQ__Quote__c result = controller.getQuoteData();
        Test.stopTest();

        // Validate the results
        System.assertEquals('Quote - Approved', result.SBQQ__Status__c, 'The quote status should be Approved');
    }
    
    @isTest
    static void testGetApprovalData() {
        // Fetch the approval record
        sbaa__Approval__c approval = [SELECT Id, sbaa__ApprovalStep__c FROM sbaa__Approval__c WHERE sbaa__ApprovalStep__c = 10 LIMIT 1];
        
        // Instantiate the controller and set the quoteApprovalId
        Pricing_SW_QuoteEmailAlertController controller = new Pricing_SW_QuoteEmailAlertController();
        controller.quoteApprovalId = approval.Id;

        // Test the getApprovalData method
        Test.startTest();
        sbaa__Approval__c result = controller.getApprovalData();
        Test.stopTest();

        sbaa__Approval__c updatedresult = [SELECT sbaa__ApprovalStep__c FROM sbaa__Approval__c WHERE Id = :approval.Id];
        // Validate the results
        System.assertEquals(10, updatedresult.sbaa__ApprovalStep__c, 'The Approval Step Field should be 10');
    }  

    @isTest
    static void testGetDomainName() {
        // Instantiate the controller
        Pricing_SW_QuoteEmailAlertController controller = new Pricing_SW_QuoteEmailAlertController();

        // Test the getDomainName method
        Test.startTest();
        String domainName = controller.getDomainName();
        Test.stopTest();

        // Validate the results
        System.assert.isNotNull(domainName, 'Domain Name should not be null');
        System.assert(domainName.contains('https://'), 'Domain Name should start with https://');
    }
}