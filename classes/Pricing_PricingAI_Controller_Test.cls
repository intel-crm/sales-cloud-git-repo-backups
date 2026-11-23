/**
 * @description       : 
 * @author            : Bharath Chandrashekar
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : Bharath Chandrashekar
**/
@isTest
public class Pricing_PricingAI_Controller_Test { 
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_PricingAI_Controller_Test');
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
    
    static testMethod void testMakeCallout(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        String discountPercent;
        String discountPrice;
        Test.startTest();
        System.runAs(adminUser){
            /*Pricing_PricingAI_Controller.pricingAIJSONStringWrapper priceWrap = new Pricing_PricingAI_Controller.pricingAIJSONStringWrapper();
            priceWrap.requestedPrice = null;
            priceWrap.ecapPrice = null;
            priceWrap.priceAxisRange = null;
            priceWrap.ranges = null;
            Pricing_PricingAI_Controller.Plots plots = new Pricing_PricingAI_Controller.Plots();
            priceWrap.plots=plots;
            plots.low_risk = null;
            plots.high_risk = null;
            plots.severe_risk = null;*/
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            //discountPercent = '0.80%';
            //discountPrice = (discountPercent).replaceAll('%', '');
            qlWrap.discount = 0;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAICalloutMockService());
            Pricing_PricingAI_Controller.makeCallout(quoteLineList[0].Id);
        }
        Test.stopTest();
    }
    
    static testMethod void testBlankSuccessContentMakeCallout(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAIMockInvRespService());
            Pricing_PricingAI_Controller.makeCallout(quoteLineList[0].Id);
        }
        Test.stopTest();
    }
    
    static testMethod void testMakeCalloutExceptionJSON(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            /*Pricing_PricingAI_Controller.pricingAIJSONStringWrapper priceWrap = new Pricing_PricingAI_Controller.pricingAIJSONStringWrapper();
            priceWrap.requestedPrice = null;
            priceWrap.ecapPrice = null;
            priceWrap.priceAxisRange = null;
            priceWrap.ranges = null;
            Pricing_PricingAI_Controller.Plots plots = new Pricing_PricingAI_Controller.Plots();
            priceWrap.plots=plots;
            plots.low_risk = null;
            plots.high_risk = null;
            plots.severe_risk = null;*/
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 80;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            Pricing_PricingAI_Controller.makeCallout('abc123test');
        }
        Test.stopTest();
    }
    
    static testMethod void testMakeCalloutInvalidJSON(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            /*Pricing_PricingAI_Controller.pricingAIJSONStringWrapper priceWrap = new Pricing_PricingAI_Controller.pricingAIJSONStringWrapper();
            priceWrap.requestedPrice = null;
            priceWrap.ecapPrice = null;
            priceWrap.priceAxisRange = null;
            priceWrap.ranges = null;
            Pricing_PricingAI_Controller.Plots plots = new Pricing_PricingAI_Controller.Plots();
            priceWrap.plots=plots;
            plots.low_risk = null;
            plots.high_risk = null;
            plots.severe_risk = null;*/
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 80;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            Pricing_PricingAI_Controller.makeCallout('');
        }
        Test.stopTest();
    }
    
    static testMethod void testGetQuoteLineDetails(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Billing_Start_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            Pricing_PricingAI_Controller.getQuoteLineDetails(quoteLineList[0].Id);
            Pricing_PricingAI_Wrapper.CalloutInputWrapper calloutWrapper = new Pricing_PricingAI_Wrapper.CalloutInputWrapper();
            calloutWrapper.endCustomer = null;
            calloutWrapper.groupType = null;
            calloutWrapper.approvedStartDate = null;
            calloutWrapper.approvedEndDate = null;
            calloutWrapper.unifiedEndCustomer = null;
            calloutWrapper.productFamily = null;
            calloutWrapper.meetCompPrice = null;
            calloutWrapper.tentativeECAPPrice = null;
            calloutWrapper.requestedDiscountPrice = null;
            calloutWrapper.unifiedCountryEndCustomerId = null;
            calloutWrapper.competitorProductName = null;
            calloutWrapper.effectivePricingStartDate = null;
            calloutWrapper.endCustomerRegion = null;
            calloutWrapper.endCustomerCountry = null;
            calloutWrapper.unifiedEndCustomerId = null;
            calloutWrapper.billingEndDate = null;
            calloutWrapper.quoteLineId = null;
            calloutWrapper.name = null;
            calloutWrapper.region = null;
            calloutWrapper.marketSegment = null;
            calloutWrapper.billingStartDate = null;
            calloutWrapper.approvedQuantity = null;
            calloutWrapper.quoteLineNumber = null;
            calloutWrapper.productName = null;
            calloutWrapper.noOfCPUPerSystem = null;
            calloutWrapper.noOfCompCPUPerSystem = null;
            calloutWrapper.wwid = null;
            Pricing_PricingAI_Wrapper.AccountWrapper accDets = new Pricing_PricingAI_Wrapper.AccountWrapper();
            accDets.name = null;
            accDets.cimId = null;
            accDets.id = null;
            Pricing_PricingAI_Wrapper.ProductWrapper prodDets = new Pricing_PricingAI_Wrapper.ProductWrapper();
            prodDets.name = null;
            prodDets.epmId = null;
            prodDets.processorNumber = null;
            prodDets.id = null;
        }
        Test.stopTest();
    }
    
    static testMethod void testGetExceptionSearchResults(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        //quoteLineList[0].SBQQ__Description__c = 'Test';
        quoteLineList[0].Pricing_Reason_for_FeedBack_Txt__c = 'Test';
        update quoteLineList;
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            String jsonObj = '{"objectName":"SBQQ__QuoteLine__c","fieldName":"SBQQ__Description__c","searchType":"Partial","searchText":"Test","filterFieldName":"Pricing_Reason_for_FeedBack_Txt__c","filterFieldValue":"Test"}';
            Test.startTest();
            Pricing_PricingAI_Controller.SearchResult searchResult = new Pricing_PricingAI_Controller.SearchResult(null,null);
            Pricing_PricingAI_Controller.SearchResultWrapper resWrapper = new Pricing_PricingAI_Controller.SearchResultWrapper();
            resWrapper.isSuccess = true;
            resWrapper.errorContent = null;
            Pricing_PricingAI_Controller.getSearchResults(jsonObj);
        }
        Test.stopTest();
    }
    
    static testMethod void testGetSearchResults(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,SBQQ__Description__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';
        quoteLineList[0].Pricing_Revised_Pricing_Start_Date_dt__c = System.today();
        quoteLineList[0].Pricing_Reason_for_FeedBack_Txt__c = 'Test';
        update quoteLineList;
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            String jsonObj = '{"objectName":"SBQQ__QuoteLine__c","fieldName":"Pricing_Revised_Pricing_Start_Date_dt__c","searchType":"Partial","searchText":"2021-09-15 00:00:00","filterFieldName":"Pricing_Reason_for_FeedBack_Txt__c","filterFieldValue":"Test"}';
            Test.startTest();
            Pricing_PricingAI_Controller.SearchResult searchResult = new Pricing_PricingAI_Controller.SearchResult(null,null);
            Pricing_PricingAI_Controller.SearchResultWrapper resWrapper = new Pricing_PricingAI_Controller.SearchResultWrapper();
            resWrapper.isSuccess = true;
            resWrapper.errorContent = null;
            Pricing_PricingAI_Wrapper.ProductWrapper prodWrapper = new Pricing_PricingAI_Wrapper.ProductWrapper();
            Pricing_PricingAI_Wrapper.CalloutInputWrapper calloutWrap = new Pricing_PricingAI_Wrapper.CalloutInputWrapper();
            calloutWrap.endCustomer = 'Test end customer';
            calloutWrap.groupType = 'mutually exclusive';
            //calloutWrap.approvedStartDate = 
            Pricing_PricingAI_Controller.getSearchResults(jsonObj);
        }
        Test.stopTest();
    }
}