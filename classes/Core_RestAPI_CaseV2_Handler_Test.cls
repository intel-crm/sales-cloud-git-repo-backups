/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseV2_Handler_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing Core_RestAPI_CaseV2_Handler_Test methods with all the combination of inputs and it is not intended for business cases scenarios.
*****************************************************************************************************************************************/

@isTest 
public class Core_RestAPI_CaseV2_Handler_Test {
    
    private static User commUser  = null;
    private static User adminUser  = null;
    static{
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v2.0/cases/';
        requestObj.requestUri ='/v2.0/cases/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        
    }
    
    
    @testSetup public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        System.debug(' Core_RestAPI_Case_HandlerV2_Test Account '+[Select Name FROM Account]);
        System.debug(' Core_RestAPI_Case_HandlerV2_Test Contact '+[Select Name FROM Contact]);
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        System.debug(' Core_RestAPI_Case_HandlerV2_Test User '+commUser);
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(adminUser){
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(10);
            for(Integer i =0;i<caseList.size()/2;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
            }
            for(Integer i =caseList.size()/2;i<caseList.size();i++){
                Case c = caseList[i];
                c.OwnerId = commUser.Id;
            }
            insert caseList;
        }
        Test.stopTest();
        System.debug(' +++++++++++++++++++++++++++ Core_RestAPI_Case_HandlerV2_Test Test Data Setup COmpleted +++++++++++++++++++++++++++ \n\n\n\n\n\n');
    }
    //This method test the handler methods: getCases & processrequest
    @isTest public static void test_getCases_Positive(){
        Core_RestAPI_CaseV2_Handler handler = new Core_RestAPI_CaseV2_Handler(System.now(), 'Core_RestAPI_CasesV2'); 
        Core_RestAPI_Response response = handler.getCases();
        System.assertNotEquals(null, response);
        System.debug(' >>> response '+response);
        
    }
    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getCases_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v2.0/cases/';
        requestObj.requestUri ='/v2.0/cases/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        
        Core_RestAPI_CaseV2_Handler handler = new Core_RestAPI_CaseV2_Handler(System.now(), 'Core_RestAPI_CasesV2'); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getCases();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.debug(' >>> test_getCases_Negative >>>  response '+finalResponse);
        System.assertNotEquals(null, finalResponse);
        System.assertNotEquals(false, exceptionThrown, 'Handler not thrown any excpetion if false');
        
    }
    
    //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        Core_RestAPI_CaseV2_Handler handler = new Core_RestAPI_CaseV2_Handler(System.now(), 'Core_RestAPI_CasesV2'); 
        handler.doValidations();
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_CaseV2_Handler handler = new Core_RestAPI_CaseV2_Handler(System.now(), 'Core_RestAPI_CasesV2'); 
            handler.doValidations();
        }   catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
    
}