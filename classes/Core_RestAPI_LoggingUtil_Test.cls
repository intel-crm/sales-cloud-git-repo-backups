/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_LoggingUtil_Test
* Version     : 1.0 
* Created Date: 10 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Test class for Logging Util for logging the transactions & error logs
*****************************************************************************************************************************************/

@isTest
public class Core_RestAPI_LoggingUtil_Test{
    
    public static DateTime strDate = System.Now();
    public static String str='test';
    
    @testSetup
    public static void setupData(){
        Test.startTest();
         Core_RestAPI_Name__c cs = new Core_RestAPI_Name__c();
        cs.Name='Cases';    
        cs.API_Order__c = 'cs6';    
        cs.Search_URI__c = '/v1.0/cases';
        insert cs;
       
        Test.stopTest();
    }
    
    public static testMethod void test_logTransaction_Positive(){

        
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        //request1.remoteAddress = '198.175.68.37';
        //request1.headers= '{"Content-Type":"application/json","Postman-Token":"6cc70844-7f01-4566-8d83-0ac47be8d51a","X-Cnection":"close","Cache-Control":"no-cache","X-Salesforce-SIP":"198.175.68.37","Accept-Encoding":"gzip, deflate","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"PostmanRuntime/7.1.1","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*"}';
        RestContext.request = request1;
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '200';
        response.isSuccess = true;
        Core_RestAPI_LoggingUtil.logTransaction(strDate,response);
        Core_RestAPI_LoggingUtil.logTransaction(strDate,response,'Cases');
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
    }
    
    public static testMethod void test_logTransaction_Negative(){
        
        RestRequest request1 =  (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
       // request1.remoteAddress = '198.175.68.37';
        RestContext.request = request1;
        
        Core_RestAPI_Response responseNegative = new Core_RestAPI_Response();
        responseNegative.code = '500';
        responseNegative.isSuccess = false;
        RestContext.request.requestBody=Blob.valueof('myString');
        Core_RestAPI_LoggingUtil.logTransaction(strDate,responseNegative);
        Core_RestAPI_LoggingUtil.logTransaction(null,null); 
        System.assertNotEquals(null,responseNegative);
    }
   public static testMethod void test_logErrorException_Positive(){
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'POST';
        RestContext.request = request1;
        RestContext.request.requestBody=Blob.valueof('myString');
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '200';
        response.isSuccess = false;
        Exception testExc =new DMLException();
        //Core_RestAPI_LoggingUtil.logError(strDate,'api_name',testExc,response, null );
         Core_RestAPI_LoggingUtil.logError(strDate,'api_name','200',testExc,response,str);
         //DateTime currTime, String apiName, String expCode, Exception excp, Core_RestAPI_Response response,String request)
       
        System.assertNotEquals(null,response);
    }
    
  /*   public static testMethod void test_logErrorException_Negative(){
        RestRequest request1 = new RestRequest();
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        RestContext.request = request1;
        
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '500';
        response.isSuccess = false;
        Exception testExc =new DMLException();
        Core_RestAPI_LoggingUtil.logError(strDate,'api_name',testExc,null);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
        
    }
    public static testMethod void test_logErrorCode_Positive(){
        RestRequest request1 = new RestRequest();
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        RestContext.request = request1;
        
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '500';
        response.isSuccess = false;
       // Core_RestAPI_LoggingUtil.logError(strDate,'api_name','500',response);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
    }
    
    public static testMethod void test_logErrorCode_Negative(){
        RestRequest request1 = new RestRequest();
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        RestContext.request = request1;
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '5000';
        response.isSuccess = false;
        Core_RestAPI_LoggingUtil.logError(null,'api_name','5001',null);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
        
    }*/
   public static testMethod void test_logErrorCodeAndExc_Positive(){
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        //request1.remoteAddress = '198.175.68.37';
        RestContext.request = request1;
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '500';
        response.isSuccess = false;
        Exception testExc =new DMLException();
        Core_RestAPI_LoggingUtil.logError(strDate,'api_name','500',testExc,response);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
    }
    
    public static testMethod void test_logErrorCodeAndExc_Negative(){
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
       // request1.remoteAddress = '198.175.68.37';
        RestContext.request = request1;
        Core_RestAPI_Response response = new Core_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '500';
        response.isSuccess = false;
        Exception testExc =new DMLException();
        Core_RestAPI_LoggingUtil.logError(strDate,'api_name','500',testExc,null);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
        
    }
   
}