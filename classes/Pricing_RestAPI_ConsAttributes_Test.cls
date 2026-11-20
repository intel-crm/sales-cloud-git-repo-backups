/**
 * @description       : Test class for Pricing_RestAPI_ConsumptionAttributes
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 11-21-2023
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_RestAPI_ConsAttributes_Test {
    
   @isTest
   public static void testSuccess() {
        
       test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/consumptionattributes';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"Header":{"xid":"00000000-0000-0000-0000-000000000000","target_system":"Tender","source_system":"MyDeals","action":"UpdateDropdowns"},"RecordDetails":{"ConsumptionData":[{"value":"Blank Check 1","mode":"Insert","isActive":false,"consumptionType":"Consumption Platform","cimId":""},{"value":"Null check","mode":"Insert","isActive":true,"consumptionType":"Consumption Sales Geo","cimId":null},{"value":"0 check","mode":"Insert","isActive":false,"consumptionType":"Consumption Sales Geo","cimId":"0"}]}}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_ConsumptionAttributes.doPost();
            system.assert(restResponse!=null, 'Invalid Request'); 
            test.stopTest();
   }
    
   @isTest
   public static void testException(){

       test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/consumptionattributes';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_ConsumptionAttributes.doPost();
            system.assert(restResponse!=null, 'Invalid Request'); 
            test.stopTest();
   }
}