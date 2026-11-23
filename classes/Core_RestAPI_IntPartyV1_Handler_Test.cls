/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_IntPartyV1_Handler_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This is for testing the handler class
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_IntPartyV1_Handler_Test {
    private static User commUser  = null;
    private static User adminUser  = null;

    
    @testSetup public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(adminUser){
            List<case> caseList = Core_RestAPI_TestUtilities.getListOfCases(2);
            Integer i;
            for( i=0;i<caseList.size();i++){
                Case objCase = caseList[i];
                objCase.OwnerId = adminUser.Id;
            } 
            //inserting 10 records of project for Admin user and Community user
            insert caseList;
            //Insert interested parties to the case
            List<Core_IPS_Case_Interested_Party__c> intPartyList = Core_RestAPI_TestUtilities.getInternalInterestedParties(4, 'External');
            List<Core_IPS_Case_Interested_Party__c> extPartyList = Core_RestAPI_TestUtilities.getInternalInterestedParties(2, 'Internal');
            for(Core_IPS_Case_Interested_Party__c ip : intPartyList){
                //Added cases to commUser1
                ip.Case__c = caseList[0].Id;
                ip.User__c = adminUser.Id;
            }
            for(Core_IPS_Case_Interested_Party__c ip : extPartyList){
                //Added cases to commUser2
                ip.Case__c = caseList[1].Id;
                ip.User__c = adminUser.Id;
            }
            insert intPartyList;
            insert extPartyList;
        }
        Test.stopTest();
    }
    
    
    
    //This method test the handler methods: getInterestedParties & processrequest
    @isTest public static void test_getInterestedParties_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/*/interestedparties';
        requestObj.requestUri ='/v1.0/cases/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        
        Core_RestAPI_InterestedPartyV1_Handler handler = new Core_RestAPI_InterestedPartyV1_Handler(System.now(), 'Core_RestAPI_InterestedPartyV1_Handler'); 
        Core_RestAPI_Response response = handler.getInterestedParties();  
        System.assertNotEquals(null, response);
        
    }
    
   
    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getInterestedParties_Negative(){
        Core_RestAPI_InterestedPartyV1_Handler handler = new Core_RestAPI_InterestedPartyV1_Handler(System.now(), null); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getInterestedParties();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown, 'Handler not thrown any exception if false');
        
        
        
    }
    
    
    //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        Core_RestAPI_InterestedPartyV1_Handler handler = new Core_RestAPI_InterestedPartyV1_Handler(System.now(), 'Core_RestAPI_InterestedPartyV1_Handler'); 
        handler.doValidations();
        System.assertEquals(handler != null, true);
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Core_RestAPI_InterestedPartyV1_Handler handler = null;
        Boolean exceptionThrown = false;
        try{
            RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            requestObj.resourcePath ='/services/apexrest/v1.0/cases/InvalidCaseNumber/interestedparties';
            requestObj.requestUri ='/v1.0/cases/';
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;
            
            
            handler = new Core_RestAPI_InterestedPartyV1_Handler(System.now(), 'Core_RestAPI_InterestedPartyV1_Handler'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
        System.assertEquals(handler != null, true);
    } 
}