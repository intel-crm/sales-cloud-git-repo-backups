@isTest
public class Pricing_PricingAI_BulkControllerTest { 
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_AI_Bulk_Controller');
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
        List<String> quoteLineId = new List<String>();
        quoteLineId.add(quoteLineList[0].Id);
        List<String> strList = new List<String>();
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            Pricing_PricingAI_BulkController.QuoteLineWrapper qlWrap = new Pricing_PricingAI_BulkController.QuoteLineWrapper();
            qlWrap.recommendedPrice = null;
            qlWrap.priceInterval = null;
            qlWrap.discount = 0;
            qlWrap.message = null;
            qlWrap.quoteLineNumber = null;
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAICalloutMockService());
            strList = Pricing_PricingAI_BulkController.makeCallout(quoteLineId);
        }
        Boolean var = strList.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }

    static testMethod void testBlankSuccessContentMakeCallout(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<String> quoteLineId = new List<String>();
        List<String> strList = new List<String>();
        quoteLineId.add(quoteLineList[0].Id);
        Test.startTest();
        System.runAs(adminUser){
            Test.setMock(HTTPCalloutMock.class, new Pricing_PricingAIMockInvRespService());
            strList = Pricing_PricingAI_BulkController.makeCallout(quoteLineId);
        }
        Boolean var = strList.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testMakeCalloutInvalidJSON(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<String> quoteLineId = new List<String>();
        List<String> strList = new List<String>();
        quoteLineId.add('abc123test');
        Test.startTest();
        System.runAs(adminUser){
            strList = Pricing_PricingAI_BulkController.makeCallout(quoteLineId);
        }
        Boolean var = strList.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testGetQuoteLineDetails(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Billing_Start_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
        List<String> quoteLineId = new List<String>();
        quoteLineId.add(quoteLineList[0].Id); 
        String str = '';
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        System.runAs(adminUser){
            str = Pricing_PricingAI_BulkController.getQuoteLineDetails(quoteLineId);
            Pricing_PricingAI_Wrapper.CalloutInputWrapper calloutWrapper = new Pricing_PricingAI_Wrapper.CalloutInputWrapper();
            calloutWrapper.endCustomer = null;
            calloutWrapper.groupType = null;
            calloutWrapper.approvedStartDate = null;
            calloutWrapper.approvedEndDate = null;
            calloutWrapper.unifiedEndCustomer = null;
            calloutWrapper.productFamily = null;
            calloutWrapper.meetCompPrice = null;
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
            Pricing_PricingAI_BulkController.getFormattedDate(datetime.newInstance(2022, 9, 15, 12, 30, 0));
        }
        Boolean var = String.isNotEmpty(str);
        System.assertEquals(var, true);
        Test.stopTest();
    }
}