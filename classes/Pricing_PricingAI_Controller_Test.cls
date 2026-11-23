/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-11-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
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
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_AI_Controller');
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
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 0;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAICalloutMockService());
            List<String> resp1 = Pricing_PricingAI_Controller.makeCallout(quoteLineList[0].Id);
            System.assertEquals(true, resp1 != null, 'makeCallout should return a non-null List<String>');
        }
        Test.stopTest();
    }
    
    static testMethod void testBlankSuccessContentMakeCallout(){
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAIMockInvRespService());
            List<String> resp2 = Pricing_PricingAI_Controller.makeCallout(quoteLineList[0].Id);
            System.assertEquals(true, resp2 != null, 'makeCallout should return a non-null List<String> even when successContent is blank');
        }
        Test.stopTest();
    }
    
    static testMethod void testMakeCalloutExceptionJSON(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 80;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            List<String> resp3 = Pricing_PricingAI_Controller.makeCallout('abc123test');
            System.assertEquals(true, resp3 != null, 'makeCallout should return a non-null List<String> for invalid Id to surface error JSON');
        }
        Test.stopTest();
    }
    
    static testMethod void testMakeCalloutInvalidJSON(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 80;
            Pricing_PricingAI_Controller.errorContentWrapper errorWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            errorWrap.message = null;
            errorWrap.quoteLineNumber = null;
            List<String> resp4 = Pricing_PricingAI_Controller.makeCallout('');
            System.assertEquals(true, resp4 != null, 'makeCallout should return a non-null List<String> when input JSON is invalid');
        }
        Test.stopTest();
    }
    
    static testMethod void testGetQuoteLineDetails(){
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Billing_Start_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            String jsonStr = Pricing_PricingAI_Controller.getQuoteLineDetails(quoteLineList[0].Id);
            System.assertEquals(true, jsonStr != null, 'getQuoteLineDetails should return a non-null JSON string for a valid Quote Line Id');
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
    
    static testMethod void testWriteJSONField(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Approved_Start_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
   
        update quoteLineList;
        JSONGenerator jsonGen = JSON.createGenerator(true);
        Map<String,String> mapFieldNames = new Map<String,String>();
        
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            Test.startTest();
            jsonGen.writeStartObject();
            //Pricing_PricingAI_Controller.writeJSONField(jsonGen, quoteLineList[0], mapFieldNames, fldName);
            Test.stopTest();
        }
    }
    
    static testMethod void testGetExceptionSearchResults(){
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        //quoteLineList[0].SBQQ__Description__c = 'Test';
       
        update quoteLineList;
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            String jsonObj = '{"objectName":"SBQQ__QuoteLine__c","fieldName":"SBQQ__Description__c","searchType":"Partial","searchText":"Test","filterFieldName":"Pricing_Reason_for_FeedBack_Txt__c","filterFieldValue":"Test"}';
            Test.startTest();
            Pricing_PricingAI_Controller.SearchResult searchResult = new Pricing_PricingAI_Controller.SearchResult(null,null);
            Pricing_PricingAI_Controller.SearchResultWrapper resWrapper = new Pricing_PricingAI_Controller.SearchResultWrapper();
            resWrapper.isSuccess = true;
            resWrapper.errorContent = null;
            Pricing_PricingAI_Controller.SearchResultWrapper res1 = Pricing_PricingAI_Controller.getSearchResults(jsonObj);
            System.assertEquals(true, res1 != null, 'getSearchResults should return a non-null wrapper');
        }
        Test.stopTest();
    }
    
    static testMethod void testGetSearchResults(){
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,SBQQ__Description__c from SBQQ__QuoteLine__c LIMIT 1];
        quoteLineList[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';
        quoteLineList[0].Pricing_Revised_Pricing_Start_Date_dt__c = System.today();
       
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
            Pricing_PricingAI_Controller.SearchResultWrapper res2 = Pricing_PricingAI_Controller.getSearchResults(jsonObj);
            System.assertEquals(true, res2 != null, 'getSearchResults should return a non-null wrapper');
        }
        Test.stopTest();
    }
}