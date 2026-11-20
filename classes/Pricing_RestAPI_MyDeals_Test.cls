/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_MyDeals_Test 
* Version     : 1.0 
* Created Date: 28 May 2021
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			        28/05/2021             Test class for Rest API to create integration inbound message record from mydeals
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_MyDeals_Test {

    @testSetup 
    private static void createData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
    }
    
    @isTest static void testDoPost_createIIM() {
        User usr = [SELECT id FROM User WHERE email='firstName@intel.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/mydeals2iqr';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"Header":{"xid":"4aec9897-04fc-e35d-78de-65d5011e3d3f","target_system":"Tender","source_system":"MyDeals","action":"Create"},"RecordDetails":{"Quote":{"Id":"a853b000000CdmPAAS","FolioID":"26534","Name":"Q-02653","FolioName":"Lenovo (Beijing) Limited - PRC - China Mobile - 2021-05-25 07:47:09","ProjectName":"Server Central Procurement Bid of Cloud Resouce Pool in 2021-2022","DealType":"ECAP","EndCustomer":"China Mobile","EndCustomerCountry":"China","Account":{"Id":"001o000000OSZS8AAP","Name":"Lenovo (Beijing) Limited","CIMId":"23505565"},"ShipmentStartDate":"2021-05-31","ShipmentEndDate":"2024-12-31","ServerDealType":"CoSP","QuoteLine":[{"Id":"a813b0000008VOyAAM","Name":"QL-0006244","ReferenceQuoteLineNumber":"null","Status":"Pending Further Intel Review","IntegrationStatus":"null","EffectivePricingStartDate":"2021-05-31","Wwid":"11632221","QuoteLineNumber":"Q-02653-003","Region":"Worldwide","EndCustomerRegion":"PRC","DealDescription":null,"GroupType":"Mutually Exclusive","MarketSegment":"Corp","Product":{"Id":"01t1J00000BdqoIQAR","Name":"Intel\u00ae Xeon\u00ae Gold 6252N Processor (35.75M Cache, 2.30 GHz)","ProductNameEPMID":"193951"},"CompetitorProduct":{"Id":"a8V3b000000YSEeEAO","Name":"2S AMD EPYC 7352 (128M Cache, 24C, 2.3GHz3.2GHz) 155W"},"OtherProduct":null,"MeetCompPrice":"500.0","ApprovedStartDate":"2021-05-31","ApprovedEndDate":"2022-12-31","BackdateReason":null,"BillingStartDate":"2021-05-31","BillingEndDate":"2022-12-31","ApprovedQuantity":"1328","ApprovedECAPPrice":"1390.0","AdditionalTandC":null,"ExcludeAutomation":false,"DealRFQStatus":"Submitted","DealRFQId":"662545","PerformanceMetric":[{"Id":"a8W3b0000008ZcNEAU","Name":"PM - 00006107","performanceMetric":"SPECrate2017_int_base","IntelSKUPerformance":"301.0","CompSKUPerformance":"324.0","Weighting":null}],"ApprovedByInfo":null,"ErrorMessages":[]}]}} }');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_MyDeals.doPostapi();
            system.assert(restResponse.successContent!=null); 
            test.stopTest();
        }        
    }
    
    @isTest static void testDoPost_createIIMWithValidError() {
        User usr = [SELECT id FROM User WHERE email='firstName@intel.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/mydeals2iqr';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"Header":{"xid":"4aec9897-04fc-e35d-78de-65d5011e3d3f","target_system":"Tender123","source_system":"MyDeals","action":"Create"},"RecordDetails":{"Quote":{"Id":"a853b000000CdmPAAS","FolioID":"26534","Name":"Q-02653","FolioName":"Lenovo (Beijing) Limited - PRC - China Mobile - 2021-05-25 07:47:09","ProjectName":"Server Central Procurement Bid of Cloud Resouce Pool in 2021-2022","DealType":"ECAP","EndCustomer":"China Mobile","EndCustomerCountry":"China","Account":{"Id":"001o000000OSZS8AAP","Name":"Lenovo (Beijing) Limited","CIMId":"23505565"},"ShipmentStartDate":"2021-05-31","ShipmentEndDate":"2024-12-31","ServerDealType":"CoSP","QuoteLine":[{"Id":"a813b0000008VOyAAM","Name":"QL-0006244","ReferenceQuoteLineNumber":"null","Status":"Pending Further Intel Review","IntegrationStatus":"null","EffectivePricingStartDate":"2021-05-31","Wwid":"11632221","QuoteLineNumber":"Q-02653-003","Region":"Worldwide","EndCustomerRegion":"PRC","DealDescription":null,"GroupType":"Mutually Exclusive","MarketSegment":"Corp","Product":{"Id":"01t1J00000BdqoIQAR","Name":"Intel\u00ae Xeon\u00ae Gold 6252N Processor (35.75M Cache, 2.30 GHz)","ProductNameEPMID":"193951"},"CompetitorProduct":{"Id":"a8V3b000000YSEeEAO","Name":"2S AMD EPYC 7352 (128M Cache, 24C, 2.3GHz3.2GHz) 155W"},"OtherProduct":null,"MeetCompPrice":"500.0","ApprovedStartDate":"2021-05-31","ApprovedEndDate":"2022-12-31","BackdateReason":null,"BillingStartDate":"2021-05-31","BillingEndDate":"2022-12-31","ApprovedQuantity":"1328","ApprovedECAPPrice":"1390.0","AdditionalTandC":null,"ExcludeAutomation":false,"DealRFQStatus":"Submitted","DealRFQId":"662545","PerformanceMetric":[{"Id":"a8W3b0000008ZcNEAU","Name":"PM - 00006107","performanceMetric":"SPECrate2017_int_base","IntelSKUPerformance":"301.0","CompSKUPerformance":"324.0","Weighting":null}],"ApprovedByInfo":null,"ErrorMessages":[]}]}} }');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_MyDeals.doPostapi();
            system.assert(restResponse.successContent ==null); 
            test.stopTest();
        }        
    }
    
    @isTest static void testDoPost_createIIMWithError() {
        User usr = [SELECT id FROM User WHERE email='firstName@intel.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/mydeals2iqr';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"Header": "ABC"}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_MyDeals.doPostapi();
            system.assert(restResponse.successContent ==null); 
            test.stopTest();
        }        
    }
}