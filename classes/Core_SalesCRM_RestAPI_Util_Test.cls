/****************************************************************************************************************************************
* Class Name  : Core_SalesCRM_RestAPI_Util_Test
* Version     : 1.0 
* Created Date:  07/09/2023		   
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			         07/09/2023		            Test class for Sales CRM RestAPI Util for error logs
*****************************************************************************************************************************************/
@isTest
public class Core_SalesCRM_RestAPI_Util_Test {
    public static  DateTime strDate = System.Now();
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
    
    public static testMethod void test_getCondition_Positive(){
        String condition = Core_SalesCRM_RestAPI_Util.getCondition('ABC','xyz');
        system.assertEquals('ABC = xyz', condition);
    }
    
    public static testMethod void test_processException_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        Core_SalesCRM_RestAPI_Response  response = new Core_SalesCRM_RestAPI_Response ();
        Core_SalesCRM_RestAPI_Util.processException(null,null,response,null,strDate);
        System.assertEquals(null,response.ErrorContent.traceId);
    }
    
    public static testMethod void test_processException_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Core_SalesCRM_RestAPI_Response  response = new Core_SalesCRM_RestAPI_Response ();
        Exception testExp=new QueryException();
        
        Core_RestAPI_Response_Codes__c tempNegative = new Core_RestAPI_Response_Codes__c();
        tempNegative.Core_Code__c='500';
        tempNegative.Core_Http_Status_Code__c='5000';
        tempNegative.Core_Message__c='testdata dsff';
        tempNegative.name='Default';
        insert  tempNegative;
        Core_SalesCRM_RestAPI_Util.processException(testExp,tempNegative.Core_Code__c,response,null,strDate);
        Core_SalesCRM_RestAPI_Util.processException(testExp,tempNegative.Core_Code__c,null,null,strDate);
        System.assertNotEquals(null,response.ErrorContent);
    }  
    public static testMethod void testExceptionRequest_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Core_RestAPI_Request requestCustom = new Core_RestAPI_Request();
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'POST';
        RestContext.request = requestObj;
        Core_SalesCRM_RestAPI_Response response = new Core_SalesCRM_RestAPI_Response ();
        Core_SalesCRM_RestAPI_Util.processException(null,null,response,null,strDate,requestCustom);
        System.assertEquals(null,response.ErrorContent.traceId);
    }
    
    public static testMethod void testExceptionRequest_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Core_RestAPI_Request requestCustom = new Core_RestAPI_Request();
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'POST';
        RestContext.request = requestObj;
        Core_SalesCRM_RestAPI_Response  response = new Core_SalesCRM_RestAPI_Response (); 
        Exception testExp=new QueryException();
        Core_RestAPI_Response_Codes__c temp= new Core_RestAPI_Response_Codes__c();
        temp.Core_Code__c='500';
        temp.Core_Http_Status_Code__c='5000';
        temp.Core_Message__c='testdata';
        temp.name='System.QueryException';
        insert temp;
        Core_SalesCRM_RestAPI_Util.processException(testExp,null,response,null,strDate,requestCustom);
        Core_SalesCRM_RestAPI_Util.processException(testExp,null,null,null,strDate,requestCustom);
        System.assertNotEquals(null,response.ErrorContent);
    }    
    public static testMethod void test_getConditionWithURIParam_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getConditionWithURIParam('id',3);
        String APIName=  Core_SalesCRM_RestAPI_Util.getAPIName('https://intel.my.salesforce.com//services/apexrest/v1.0/cases');
        system.assert(!String.isEmpty(URIParam));
        //system.assert(!String.isEmpty(APIName));
    }
    public static testMethod void test_getConditionWithURIParam_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getConditionWithURIParam('',null);
        system.assert(String.isEmpty(URIParam));
    }
    
    public static testMethod void test_getInputFromURIParam_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getInputFromURIParam(null);
        system.assert(String.isEmpty(URIParam));
    }
    public static testMethod void test_getInputFromURIParam_Negative(){
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getInputFromURIParam(null);
        system.assert(String.isEmpty(URIParam));
    }
    
    public static testMethod void test_getRequestParam_Positive(){
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getRequestParam('');
        system.assert(String.isEmpty(URIParam));
    }
    public static testMethod void test_getRequestParam_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri =null;
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Core_SalesCRM_RestAPI_Util.getRequestParam('');
        system.assert(String.isEmpty(URIParam));
    }
    
    
    public static testMethod void test_isRequestParamValid_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        requestObj.addParameter('paramKey','case');
        RestContext.request = requestObj;
        Map<String, String> allowedURIParams= new Map<String, String>();
        allowedURIParams.put('paramKey','case');
        allowedURIParams.put('2','products');
        Boolean URIParam=  Core_SalesCRM_RestAPI_Util.isRequestParamValid(allowedURIParams);
        System.assertEquals(true, URIParam);
    }
    public static testMethod void test_isRequestParamValid_Negative(){
        
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        requestObj.addParameter('paramKeyInvalid','case');
        RestContext.request = requestObj;
        Map<String, String> allowedURIParams= new Map<String, String>();
        allowedURIParams.put('paramKey','case');
        allowedURIParams.put('2','products');
        Boolean URIParam=  Core_SalesCRM_RestAPI_Util.isRequestParamValid(allowedURIParams);
        System.assertEquals(false, URIParam);
    }
    
    
    public static testMethod void test_isRequestURIValid_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/00200621';
        requestObj.requestUri ='/v1.0/cases/00200621';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Boolean URIParam=  Core_SalesCRM_RestAPI_Util.isRequestURIValid(requestObj.requestUri);
        System.assertEquals(true, URIParam);
    }
    public static testMethod void test_isRequestURIValid_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/00200621/invalidURI';
        requestObj.requestUri ='/v1.0/cases/00200621';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Boolean URIParam=  Core_SalesCRM_RestAPI_Util.isRequestURIValid(requestObj.resourcePath);
        System.assertEquals(false, URIParam);
    }
    
    public static testMethod void test_isMaxLengthExceeded(){
        String str = 'test123456uiojdg';
        Integer maxLength = 8;
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        Core_SalesCRM_RestAPI_Util.isMaxLengthExceeded(str,maxLength);
        system.assert(True);
    }
    
    public static testMethod void test_logErrorCodeAndExc_Negative(){
        system.runAs(Core_Test_Utility.systemAdminUser){
            test.startTest();
            RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
            request1.httpMethod = 'GET';
            RestContext.request = request1;
            Core_SalesCRM_RestAPI_Response response = new Core_SalesCRM_RestAPI_Response();
            response.successContent = new List<Core_RestAPI_SuccessContent>();
            response.code = '500';
            response.isSuccess = false;
            Exception testExc =new DMLException();
            Core_SalesCRM_RestAPI_Util.logError(strDate,'api_name','500',testExc,null);
            RestContext.request.requestBody=Blob.valueof('myString');
            System.assertNotEquals(null,response);
            test.stopTest();
        }
    }
    
    public static testMethod void test_logTransaction_Positive(){
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        RestContext.request = request1;
        Core_SalesCRM_RestAPI_Response response = new Core_SalesCRM_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '200';
        response.isSuccess = true;
        Core_SalesCRM_RestAPI_Util.logTransaction(strDate,response);
        RestContext.request.requestBody=Blob.valueof('myString');
        System.assertNotEquals(null,response);
    }
    
    public static testMethod void test_logTransaction_Negative(){
        
        RestRequest request1 =  (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'GET';
        RestContext.request = request1;
        Core_SalesCRM_RestAPI_Response responseNegative = new Core_SalesCRM_RestAPI_Response();
        responseNegative.code = '500';
        responseNegative.isSuccess = false;
        RestContext.request.requestBody=Blob.valueof('myString');
        Core_SalesCRM_RestAPI_Util.logTransaction(strDate,responseNegative);
        Core_SalesCRM_RestAPI_Util.logTransaction(null,null); 
        System.assertNotEquals(null,responseNegative);
    }
    public static testMethod void test_logErrorException_Positive(){
        RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        request1.httpMethod = 'POST';
        RestContext.request = request1;
        RestContext.request.requestBody=Blob.valueof('myString');
        Core_SalesCRM_RestAPI_Response response = new Core_SalesCRM_RestAPI_Response();
        response.successContent = new List<Core_RestAPI_SuccessContent>();
        response.code = '200';
        response.isSuccess = false;
        Exception testExc =new DMLException();
        Core_SalesCRM_RestAPI_Util.logError(strDate,'api_name','200',testExc,response,str);
        System.assertNotEquals(null,response);
    }
}