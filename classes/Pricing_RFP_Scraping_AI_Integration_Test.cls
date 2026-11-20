/****************************************************************************************************************************************************
 * Class Name      : Pricing_RFP_Scraping_AI_Integration_Test
 * Version               : 1.0
 * Created Date          :  04-20-2026 
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 *  Sinduja   04-20-2026       Test class for Pricing_RFP_Scraping_AI_Integration
 ******************************************************************************************************************************************************/
@isTest
public class Pricing_RFP_Scraping_AI_Integration_Test {
    
    // Mock HTTP response for successful callouts
    private class SuccessHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('SUCCESS');
            res.setBody('{"result":"success"}');
            return res;
        }
    }
    
    // Mock HTTP response for failed callouts
    private class FailureHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('FAILED');
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }
    
    @TestSetup
    static void setupData() {
        List < User > adminUser = Pricing_Test_Utility.createAdminUser();
		List < SBQQ__QuoteLine__c > lstquoteLines;
		if(!adminUser.isEmpty()) {
			system.runAs(adminUser[0]) {
				Pricing_Test_Utility.createPriceBook();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
                Pricing_Test_Utility.createTemplate(adminUser[0].id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                                  TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
                insert accTeam;
                List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 10,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
			}
		
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];
        system.debug('TEST QUOTES:'+quotes.size());
        // Create test documents for quotes with RFP pattern
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        // Create RFP documents (matching the pattern from custom label)
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'RFP Test Document 1'; // This should match the pattern
        cv1.PathOnClient = 'RFPTestDoc1.pdf';
        cv1.VersionData = Blob.valueOf('Test RFP document content 1');
        cv1.FirstPublishLocationId = quotes[0].Id;
        contentVersions.add(cv1);
            
        ContentVersion doc2 = new ContentVersion();
        doc2.Title = 'RFP Test Document 2';
        doc2.PathOnClient = 'RFPTestDoc2.pdf';
        doc2.VersionData = Blob.valueOf('Test RFP document content 2');
        doc2.FirstPublishLocationId = quotes[0].Id; // Same quote as cv1
        contentVersions.add(doc2);
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'RFP Test Document 2';
        cv2.PathOnClient = 'RFPTestDoc2.docx';
        cv2.VersionData = Blob.valueOf('Test RFP document content 2');
        cv2.FirstPublishLocationId = quotes[1].Id;
        contentVersions.add(cv2);
        
        insert contentVersions;
        }
    }
    
    @isTest
    static void testCompleteRFPScrapingFlow_Success() {
        // Get test quotes with documents
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 2];
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
        }
        
        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        
        Test.startTest();
        
        // Test the complete flow: checkRFPDocumentExists -> updateQuoteStatus -> fetchQuoteDetails -> makeCDBCallout
        Map<Id, List<Id>> documentMap = Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists(quoteIds);
        Pricing_RFP_Scraping_AI_Integration.updateQuoteStatus(quoteIds);
        Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails(quoteIds);
        
        // Test wrapper classes
        Pricing_RFP_Scraping_AI_Integration.QuoteWrapper quoteWrapper = new Pricing_RFP_Scraping_AI_Integration.QuoteWrapper();
        quoteWrapper.quoteId = quotes[0].Id;
        quoteWrapper.contentDocumentDetails = new List<Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper>();
        
        Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper cdWrapper = new Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper();
        cdWrapper.contentDocumentId = 'test123';
        quoteWrapper.contentDocumentDetails.add(cdWrapper);
        
        // Test JSON serialization
        String jsonPayload = JSON.serialize(quoteWrapper);
        
        // Test makeCDBCallout directly
        Map<String, String> payloadMap = new Map<String, String>();
        payloadMap.put(quotes[0].Id, jsonPayload);
        Pricing_RFP_Scraping_AI_Integration.makeCDBCallout(payloadMap);
        
        Test.stopTest();
        
        // Verify document mapping
        System.assertEquals(2, documentMap.size(), 'Should return map for all quotes');
        
        // Verify quote status updates
        List<SBQQ__Quote__c> updatedQuotes = [SELECT Id, Pricing_AI_RFP_Scraping_Status__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds];
        for(SBQQ__Quote__c quote : updatedQuotes) {
            System.assertEquals('In Progress', quote.Pricing_AI_RFP_Scraping_Status__c, 'Quote status should be In Progress');
        }
        
        // Verify CDB Integration Log was created
        List<Core_CDB_Integration_Log__c> logs = [SELECT Id, Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c];
        System.assert(logs.size() > 0, 'Should have CDB integration logs');
        
        // Verify wrapper class functionality
        System.assert(jsonPayload.contains(quotes[0].Id), 'JSON should contain quote ID');
        System.assert(jsonPayload.contains('test123'), 'JSON should contain document ID');
    }
    
    @isTest
    static void testErrorScenariosAndExceptionHandling() {
        // Get a quote without RFP documents
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 3];
        List<Id> quoteIdsWithoutDocs = new List<Id>{quotes[2].Id}; // Third quote has no RFP docs
        
        Test.startTest();
        
        // Test all methods with null/empty inputs
        Map<Id, List<Id>> nullResult = Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists(null);
        Map<Id, List<Id>> emptyResult = Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists(new List<Id>());
        
        // Test updateQuoteStatus with null and empty
        Pricing_RFP_Scraping_AI_Integration.updateQuoteStatus(new List<Id>{null});
        Pricing_RFP_Scraping_AI_Integration.updateQuoteStatus(new List<Id>());
        
        // Test fetchQuoteDetails with various scenarios
        Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails(null);
        Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails(new List<Id>());
        Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails(quoteIdsWithoutDocs); // Quote without RFP docs
        
        // Test makeCDBCallout with edge cases
        Pricing_RFP_Scraping_AI_Integration.makeCDBCallout(new Map<String, String>());
        Map<String, String> blankPayloadMap = new Map<String, String>();
        blankPayloadMap.put('testId', ''); // Blank payload
        Pricing_RFP_Scraping_AI_Integration.makeCDBCallout(blankPayloadMap);
        
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals(0, nullResult.size(), 'Should return empty map for null input');
        System.assertEquals(0, emptyResult.size(), 'Should return empty map for empty input');
        
        // Verify error logs were created for quotes without RFP documents
        List<Core_Log_Entry__c> errorLogs = [SELECT Id, Core_Details__c FROM Core_Log_Entry__c 
                                            WHERE Core_Message__c = 'Error'];
        
        // Check for specific error about missing RFP documents
        Boolean hasRFPError = false;
        for(Core_Log_Entry__c log : errorLogs) {
            if(log.Core_Details__c != null && log.Core_Details__c.contains('No RFP Document attached')) {
                hasRFPError = true;
                break;
            }
        }
        System.assert(hasRFPError, 'Should have error log for missing RFP documents');
    }
    
    @isTest
    static void testCalloutFailureAndApexException() {
        // Get test quotes
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 2];
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
        }
        
        // Mock failed HTTP response
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        
        Test.startTest();
        
        // Test fetchQuoteDetails with failed callout
        Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails(quoteIds);
        
        // Test makeCDBCallout with failed response
        Map<String, String> payloadMap = new Map<String, String>();
        payloadMap.put(quotes[0].Id, '{"test":"payload"}');
        Pricing_RFP_Scraping_AI_Integration.makeCDBCallout(payloadMap);
        
        // Test makeCDBCallout with multiple payloads (some successful, some failed)
        Map<String, String> multiPayloadMap = new Map<String, String>();
        for(SBQQ__Quote__c quote : quotes) {
            Pricing_RFP_Scraping_AI_Integration.QuoteWrapper wrapper = new Pricing_RFP_Scraping_AI_Integration.QuoteWrapper();
            wrapper.quoteId = quote.Id;
            wrapper.contentDocumentDetails = new List<Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper>();
            
            Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper cdWrapper = new Pricing_RFP_Scraping_AI_Integration.ContentDocumentDetailsWrapper();
            cdWrapper.contentDocumentId = 'doc' + quote.Id;
            wrapper.contentDocumentDetails.add(cdWrapper);
            
            multiPayloadMap.put(quote.Id, JSON.serialize(wrapper));
        }
        Pricing_RFP_Scraping_AI_Integration.makeCDBCallout(multiPayloadMap);
        
        Test.stopTest();
        
        // Verify failed CDB Integration Logs were created
        List<Core_CDB_Integration_Log__c> failedLogs = [SELECT Id, Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c 
                                                       WHERE Core_Log_Status_Nm__c = 'Failed'];
        System.assert(failedLogs.size() > 0, 'CDB Logs with Failed Status');
    }

}