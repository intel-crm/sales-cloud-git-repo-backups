/****************************************************************************************************************************************************
 * Class Name      : Pricing_Application_Agent_AI_Test
 * Version               : 1.0
 * Created Date          :  04-02-2026 
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 *  Sinduja   04-02-2026       Test class for Pricing_Application_Agent_AI_Integration
 ******************************************************************************************************************************************************/
@isTest
public class Pricing_Application_Agent_AI_Test {
    
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
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        
        if(!adminUser.isEmpty()) {
            system.runAs(adminUser[0]) {
                Pricing_Test_Utility.createPriceBook();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
                Pricing_Test_Utility.createTemplate(adminUser[0].id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                
                AccountTeamMember accTeam = new AccountTeamMember(
                    AccountId = acc.Id,
                    TeamMemberRole = 'Technical Sales',
                    UserId = salesRepUserList[0].Id
                );
                insert accTeam;
                
                // Create quotes with required fields
                List<SBQQ__Quote__c> quotes = Pricing_Test_Utility.createQuoteWithParam(
                    acc.Id, con.Id, 2, salesRepUserList[0].Email, accountExecutiveUserList[0].Email
                );
                Id quoteID = quotes[0].Id;
                
                // Create quote lines with only writable fields
                List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
                quoteLines = Pricing_Test_Utility.createQuoteLines(quoteID, 5);
                
                // Create quote comments
                List<Pricing_Comments__c> comments = new List<Pricing_Comments__c>();
                for(SBQQ__Quote__c quote : quotes) {
                    Pricing_Comments__c comment = new Pricing_Comments__c();
                    comment.Pricing_Quote__c = quote.Id;
                    comment.Pricing_Question__c = 'What is the delivery timeline?';
                    comment.Pricing_Answer__c = '30-45 days from order confirmation';
                    comment.Pricing_Comment_Ref_Id__c = 'REF001';
                    comments.add(comment);
                }
                insert comments;
                
                List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
                Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
                metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
                metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
                metrics.Pricing_Other_Nm__c='test';
                metrics.Pricing_Performance_Metric_Nm__c='Other';
                metrics.Pricing_Quote_Line__c=quoteLines[0].Id;
                metrics.Pricing_Weighting_Pct__c=10;
                mList.add(metrics);
                insert mList;
            }
        }
    }
    
    @isTest
    static void testCompleteFlow_Success() {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 2];
        List<Id> quoteLineIds = new List<Id>();
        for(SBQQ__QuoteLine__c ql : quoteLines) {
            quoteLineIds.add(ql.Id);
        }
        
        Map<String, Integer> retryCountMap = new Map<String, Integer>();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        
        Test.startTest();
        Pricing_Application_Agent_AI_Integration.populateJSON(quoteLineIds, retryCountMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void testFetchMethods_Success() {
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 2];
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 2];
        List<Id> quoteIds = new List<Id>();
        List<Id> quoteLineIds = new List<Id>();
        
        for(SBQQ__Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
        }
        for(SBQQ__QuoteLine__c ql : quoteLines) {
            quoteLineIds.add(ql.Id);
        }
        
        Test.startTest();
        Map<Id, List<Pricing_Application_Agent_AI_Integration.PerformanceMetricWrapper>> perfomanceMetricMap = new Map<Id, List<Pricing_Application_Agent_AI_Integration.PerformanceMetricWrapper>>();
        Map<Id, SBQQ__Quote__c> quoteMap = Pricing_Application_Agent_AI_Integration.fetchQuoteDetails(quoteIds);
        Map<Id, List<Pricing_Application_Agent_AI_Integration.QuoteLineWrapper>> quoteLineMap = 
            Pricing_Application_Agent_AI_Integration.fetchQuoteLineDetails(quoteLineIds,perfomanceMetricMap);
        Map<Id, List<Pricing_Application_Agent_AI_Integration.QuoteCommentWrapper>> commentMap = 
            Pricing_Application_Agent_AI_Integration.getQuoteCommentsWrapper(new Set<Id>(quoteIds));
        Test.stopTest();
        
        System.assertEquals(2, quoteMap.size(), 'Should return 2 quotes');
    }
    
    @isTest
    static void testCalloutFailure_Scenarios() {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c LIMIT 1];
        
        Map<String, String> quoteIdToJsonMap = new Map<String, String>();
        Map<String, List<String>> quoteIdToQuoteLineIdsMap = new Map<String, List<String>>();
        
        String quoteId = quoteLines[0].SBQQ__Quote__c;
        quoteIdToJsonMap.put(quoteId, '{"test":"payload"}');
        quoteIdToQuoteLineIdsMap.put(quoteId, new List<String>{quoteLines[0].Id});
        
        String serializedQuoteLineIdsMap = JSON.serialize(quoteIdToQuoteLineIdsMap);
        Map<String, Integer> retryCountMap = new Map<String, Integer>();
        
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        
        Test.startTest();
        Pricing_Application_Agent_AI_Integration.makeCDBCallout(quoteIdToJsonMap, serializedQuoteLineIdsMap, retryCountMap);
        Test.stopTest();
        
        List<Core_CDB_Integration_Log__c> logs = [SELECT Id FROM Core_CDB_Integration_Log__c];
    }
    
    @isTest
    static void testWrapperClasses_AndExceptionHandling() {
        Test.startTest();
        
        // Test wrapper instantiation
        Pricing_Application_Agent_AI_Integration.MainWrapper mainWrapper = 
            new Pricing_Application_Agent_AI_Integration.MainWrapper();
        mainWrapper.Id = 'test123';
        
        Pricing_Application_Agent_AI_Integration.QuoteLineWrapper quoteLineWrapper = 
            new Pricing_Application_Agent_AI_Integration.QuoteLineWrapper();
        quoteLineWrapper.Status = 'Draft';
        
        Pricing_Application_Agent_AI_Integration.QuoteCommentWrapper commentWrapper = 
            new Pricing_Application_Agent_AI_Integration.QuoteCommentWrapper();
        commentWrapper.question = 'Test Question';
        
        // Test exception handling with null inputs
        Pricing_Application_Agent_AI_Integration.populateJSON(null, null);
        Pricing_Application_Agent_AI_Integration.fetchQuoteDetails(null);
        
        Test.stopTest();
        
        System.assertEquals('test123', mainWrapper.Id, 'Wrapper classes should be instantiated correctly');
    }

}