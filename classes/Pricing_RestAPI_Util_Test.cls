/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Util_Test
* Version     : 1.0 
* Created Date: 09 Oct 2020
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/09/2020             Test class for Pricing RestAPI Util for error logs
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_Util_Test{
    
    public static  DateTime strDate = System.Now();
    
    @testSetup
    public static void setupData(){
        Test.startTest();
        Case caseObj=Core_RestAPI_TestUtilities.getCase(); 
        insert caseObj;
        Test.stopTest();
    }
    
    public static testMethod void test_getCondition_Positive(){
        String condition = Pricing_RestAPI_Util.getCondition('ABC','xyz');
        system.assertEquals('ABC = xyz', condition);
    }
    
    public static testMethod void test_processException_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        Pricing_RestAPI_Response  response = new Pricing_RestAPI_Response ();
        Pricing_RestAPI_Util.processException(null,null,response,null,strDate);
        System.assertEquals(null,response.ErrorContent.traceId);
    }
    
    public static testMethod void test_processException_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Pricing_RestAPI_Response  response = new Pricing_RestAPI_Response ();
        Exception testExp=new QueryException();
        
        Core_RestAPI_Response_Codes__c tempNegative = new Core_RestAPI_Response_Codes__c();
        tempNegative.Core_Code__c='500';
        tempNegative.Core_Http_Status_Code__c='5000';
        tempNegative.Core_Message__c='testdata dsff';
        tempNegative.name='Default';
        insert  tempNegative;
        Pricing_RestAPI_Util.processException(testExp,tempNegative.Core_Code__c,response,null,strDate);
        Pricing_RestAPI_Util.processException(testExp,tempNegative.Core_Code__c,null,null,strDate);
        System.assertNotEquals(null,response.ErrorContent);
    }  
    public static testMethod void testExceptionRequest_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Pricing_RestAPI_Request requestCustom = new Pricing_RestAPI_Request();
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'POST';
        RestContext.request = requestObj;
        Pricing_RestAPI_Response response = new Pricing_RestAPI_Response ();
        Pricing_RestAPI_Util.processException(null,null,response,null,strDate,requestCustom);
        System.assertEquals(null,response.ErrorContent.traceId);
    }
    
    public static testMethod void testExceptionRequest_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Pricing_RestAPI_Request requestCustom = new Pricing_RestAPI_Request();
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'POST';
        RestContext.request = requestObj;
        Pricing_RestAPI_Response  response = new Pricing_RestAPI_Response (); 
        Exception testExp=new QueryException();
        Core_RestAPI_Response_Codes__c temp= new Core_RestAPI_Response_Codes__c();
        temp.Core_Code__c='500';
        temp.Core_Http_Status_Code__c='5000';
        temp.Core_Message__c='testdata';
        temp.name='System.QueryException';
        insert temp;
        Pricing_RestAPI_Util.processException(testExp,null,response,null,strDate,requestCustom);
        Pricing_RestAPI_Util.processException(testExp,null,null,null,strDate,requestCustom);
        System.assertNotEquals(null,response.ErrorContent);
    }    
    public static testMethod void test_getConditionWithURIParam_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getConditionWithURIParam('id',3);
        system.assert(!String.isEmpty(URIParam));
    }
    public static testMethod void test_getConditionWithURIParam_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getConditionWithURIParam('',null);
        system.assert(String.isEmpty(URIParam));
    }
    
    public static testMethod void test_getInputFromURIParam_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getInputFromURIParam(null);
        system.assert(String.isEmpty(URIParam));
    }
    public static testMethod void test_getInputFromURIParam_Negative(){
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getInputFromURIParam(null);
        system.assert(String.isEmpty(URIParam));
    }
    
    public static testMethod void test_getRequestParam_Positive(){
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getRequestParam('');
        system.assert(String.isEmpty(URIParam));
    }
    public static testMethod void test_getRequestParam_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri =null;
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        String URIParam=  Pricing_RestAPI_Util.getRequestParam('');
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
        Boolean URIParam=  Pricing_RestAPI_Util.isRequestParamValid(allowedURIParams);
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
        Boolean URIParam=  Pricing_RestAPI_Util.isRequestParamValid(allowedURIParams);
        System.assertEquals(false, URIParam);
    }
    
    
    public static testMethod void test_isRequestURIValid_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/00200621';
        requestObj.requestUri ='/v1.0/cases/00200621';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Boolean URIParam=  Pricing_RestAPI_Util.isRequestURIValid(requestObj.requestUri);
        System.assertEquals(true, URIParam);
    }
    public static testMethod void test_isRequestURIValid_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/00200621/invalidURI';
        requestObj.requestUri ='/v1.0/cases/00200621';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Boolean URIParam=  Pricing_RestAPI_Util.isRequestURIValid(requestObj.resourcePath);
        System.assertEquals(false, URIParam);
    }
    public static testMethod void test_isCaseNumberValid_Negative(){
        Case caseObj=[select casenumber,Subject from Case where Subject='TestSubject' AND id!= null ];
        String Str=caseObj.id;
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+caseObj.id;
        requestObj.requestUri ='/v1.0/cases/'+caseObj.id;
        requestObj.httpMethod = 'GET';  
        RestContext.request = requestObj;
        Pricing_RestAPI_Util.isCaseNumberValid(Str);
        system.assert(true);
    }
    
    public static testMethod void test_isMaxLengthExceeded(){
        String str = 'test123456uiojdg';
        Integer maxLength = 8;
        RestRequest requestObj =(RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
        requestObj.httpMethod = 'GET';
        requestObj.requestBody=Blob.valueof('myString');
        RestContext.request = requestObj;
        Pricing_RestAPI_Util.isMaxLengthExceeded(str,maxLength);
        system.assert(True);
    }
    public static testMethod void testIsProductIdValid(){
        boolean isValid = Pricing_RestAPI_Util.isProductIdValid('AXEFS212323EFRR');
        system.assertEquals(True, isValid);
    }
    
}