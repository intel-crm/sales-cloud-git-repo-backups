/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_LoggingUtil_Test
* Version     : 1.0 
* Created Date: 09 Oct 2020
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/09/2017               Test class for Logging Util for logging the transactions & error logs
*****************************************************************************************************************************************/

@isTest
public class Pricing_RestAPI_LoggingUtil_Test{
    
    public static DateTime strDate = System.Now();
    public static String str='test';
    
    @testSetup
    public static void setupData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Pricing_Test_Utility.createPriceBook();
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Rest_API_Logging_Util_Test');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest();
        
             Core_RestAPI_Name__c cs = new Core_RestAPI_Name__c();
            cs.Name='Cases';    
            cs.API_Order__c = 'cs6';    
            cs.Search_URI__c = '/v1.0/cases';
            insert cs;
    	}
    }
    
    public static testMethod void test_logTransaction_Positive(){
        User usr = [SELECT id,ContactId,AccountId FROM User WHERE email='Rest_API_Logging_Util_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
            request1.httpMethod = 'GET';
            //request1.remoteAddress = '198.175.68.37';
            //request1.headers= '{"Content-Type":"application/json","Postman-Token":"6cc70844-7f01-4566-8d83-0ac47be8d51a","X-Cnection":"close","Cache-Control":"no-cache","X-Salesforce-SIP":"198.175.68.37","Accept-Encoding":"gzip, deflate","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"PostmanRuntime/7.1.1","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*"}';
            RestContext.request = request1;
            Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            response.code = '200';
            response.isSuccess = true;
            Pricing_RestAPI_LoggingUtil.logTransaction(strDate,response,usr);
            Pricing_RestAPI_LoggingUtil.logTransaction(strDate,response,'Cases',usr);
            RestContext.request.requestBody=Blob.valueof('myString');
            System.assertNotEquals(null,response);
            test.stopTest();
        }
    }
    
    public static testMethod void test_logTransaction_Negative(){
        User usr = [SELECT id,ContactId,AccountId FROM User WHERE email='Rest_API_Logging_Util_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request1 =  (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='/services/apexrest/v1.0/cases';//https://intel.my.salesforce.com//services/apexrest/v1.0/cases
            request1.httpMethod = 'GET';
           // request1.remoteAddress = '198.175.68.37';
            RestContext.request = request1;
            
            Pricing_RestAPI_Response responseNegative = new Pricing_RestAPI_Response();
            responseNegative.code = '500';
            responseNegative.isSuccess = false;
            RestContext.request.requestBody=Blob.valueof('myString');
            Pricing_RestAPI_LoggingUtil.logTransaction(strDate,responseNegative,usr);
            Pricing_RestAPI_LoggingUtil.logTransaction(null,null,null); 
            System.assertNotEquals(null,responseNegative);
            test.stopTest();
        }
    }
   public static testMethod void test_logErrorException_Positive(){
       User usr = [SELECT id FROM User WHERE email='Rest_API_Logging_Util_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
            request1.httpMethod = 'POST';
            RestContext.request = request1;
            RestContext.request.requestBody=Blob.valueof('myString');
            Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            response.code = '200';
            response.isSuccess = false;
            Exception testExc =new DMLException();
            //Pricing_RestAPI_LoggingUtil.logError(strDate,'api_name',testExc,response, null );
             Pricing_RestAPI_LoggingUtil.logError(strDate,'api_name','200',testExc,response,str);
             //DateTime currTime, String apiName, String expCode, Exception excp, Pricing_RestAPI_Response response,String request)
           
            System.assertNotEquals(null,response);
            test.stopTest();
        	}
        }
  
   public static testMethod void test_logErrorCodeAndExc_Positive(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Logging_Util_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
            request1.httpMethod = 'GET';
            //request1.remoteAddress = '198.175.68.37';
            RestContext.request = request1;
            Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            response.code = '500';
            response.isSuccess = false;
            Exception testExc =new DMLException();
            Pricing_RestAPI_LoggingUtil.logError(strDate,'api_name','500',testExc,response);
            RestContext.request.requestBody=Blob.valueof('myString');
            System.assertNotEquals(null,response);
            test.stopTest();
        }
    }
    
    public static testMethod void test_logErrorCodeAndExc_Negative(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Logging_Util_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request1 = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request1.requestUri ='https://intel.my.salesforce.com//services/apexrest/v1.0/cases';
            request1.httpMethod = 'GET';
           // request1.remoteAddress = '198.175.68.37';
            RestContext.request = request1;
            Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            response.code = '500';
            response.isSuccess = false;
            Exception testExc =new DMLException();
            Pricing_RestAPI_LoggingUtil.logError(strDate,'api_name','500',testExc,null);
            RestContext.request.requestBody=Blob.valueof('myString');
            System.assertNotEquals(null,response);
            test.stopTest();
        }
        
    }
   
}