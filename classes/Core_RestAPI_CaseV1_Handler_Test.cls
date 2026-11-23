/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Case_Handler_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing Core_RestAPI_Case_Handler methods with all the combination of inputs and it is not intended for business cases scenarios.
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_CaseV1_Handler_Test { 
    
    private static User commUser  = null;
    private static User adminUser  = null;
    
    static{
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/';
        requestObj.requestUri ='/v1.0/cases/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        
    }
    @testSetup public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        commUser = [Select Name, ContactId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(commUser){
            List<case> caseList = Core_RestAPI_TestUtilities.getListOfCases(10);
            Integer i;
            for( i=0;i<caseList.size();i++){
                Case objCase = caseList[i];
                //objCase.OwnerId = adminUser.Id;
                if(i==1){
                    objCase.Status = 'Open';
                    objCase.ContactId = commUser.ContactId;
                }
                    
            } 
            //inserting 10 records of project for Admin user and Community user
            insert caseList;
            System.assertEquals(10, caseList.size());
        }
        
        Test.stopTest();
    }
    
    
    
    //This method test the handler methods: getCases & processrequest
    @isTest public static void test_getCases_Positive(){
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
        Core_RestAPI_Response response = handler.getCases();  
        System.assertNotEquals(null, response);
        
    }
    
    //This method test the handler methods: getCases & processrequest
    @isTest public static void test_getCases_Negative2(){
        Map<String, String> par = new  Map<String, String>();
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases?v2=mycasess';
        requestObj.requestUri ='/v1.0/cases?v2=mycasess';
        requestObj.httpMethod = 'GET';
        requestObj.params.put('v', 'mycasess');
        RestContext.request = requestObj;
        
        Core_RestAPI_CasesV1.doGet();
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
        Core_RestAPI_Response response = handler.getCases();  
        handler.doValidations();
        //handler.getCondition();
        
        System.assertNotEquals(null, response);
    }
    
    //This method test the handler methods: getCases & processrequest
    @isTest public static void test_getCases_Positive2(){
        Map<String, String> par = new  Map<String, String>();
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases?v=mycases';
        requestObj.requestUri ='/v1.0/cases?v=mycases';
        requestObj.httpMethod = 'GET';
        requestObj.params.put('v', 'mycases');
        RestContext.request = requestObj;
        
        Core_RestAPI_CasesV1.doGet();
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
        Core_RestAPI_Response response = handler.getCases();  
        handler.doValidations();
        
        System.assertNotEquals(null, response);
    }
    
    //Test error case:  -PK
    
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getCases_Negative(){
        
        
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), null); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            handler.allowedRequestURIParams = null;
            finalResponse = handler.getCases();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown, 'Handler not thrown any excpetion if false');
        
    }
    
    
    
    
    //Test method - tests the positive cases for the method doValidations. -PK
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
        handler.doValidations();
        System.assertEquals(handler != null, true);
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_CaseV1_Handler handler = new Core_RestAPI_CaseV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
    
}