/************************************************************************************************************************
Apex Class Name  : PRM_RetriggerEV_Token_API_Test
Version          : 1.0 
Created Date     : 10 June 2021
Function         : Test Class for PRM_RetriggerEV_Token_API
Modification Log :
* Developer                        Date              Description
* ------------------------------------------------------------------------------------------------------------------------              
* GopiKrishna Vankadari         10/06/2021          Initial version
*************************************************************************************************************************/
@isTest
public class PRM_RetriggerEV_Token_API_Test {
    @testSetup
    private static void createData(){
        test.startTest();
        PRM_Registration_Request__c newRegistrationRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        newRegistrationRequest.PRM_Person_Phone_Number__c ='444444';
        newRegistrationRequest.PRM_EmailVerifiedDateTime__c = null;
        newRegistrationRequest.PRM_Contact_Login_ID__c ='testrequest@mailinator.com';
        newRegistrationRequest.PRM_EV_Token__c = '768688';
        newRegistrationRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRegistrationRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        insert newRegistrationRequest;        
        test.stopTest();
    }
    
    @isTest static void retrieveEvToken_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        test.startTest();
        PRM_Registration_Request__c newRegreq = [SELECT PRM_Email_ID__c, PRM_Contact_Login_ID__c, PRM_EV_Token__c, PRM_Person_Phone_Number__c,PRM_Partner_Type__c FROM PRM_Registration_Request__c LIMIT 1];

        PRM_RetriggerEV_Token_API.reTriggerEV(newRegreq.PRM_Contact_Login_ID__c);

        system.assertEquals('testrequest@mailinator.com', newRegreq.PRM_Contact_Login_ID__c);
        test.stopTest();
        
    }
    
    @isTest static void unableToRetrieveEvToken_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpFailedResponseGenerator()); 
        test.startTest();
        PRM_Registration_Request__c newRegreq = [SELECT PRM_Email_ID__c, PRM_Contact_Login_ID__c, PRM_EV_Token__c, PRM_Person_Phone_Number__c,PRM_Partner_Type__c FROM PRM_Registration_Request__c LIMIT 1];

        PRM_RetriggerEV_Token_API.reTriggerEV(newRegreq.PRM_Contact_Login_ID__c);

        system.assertEquals('testrequest@mailinator.com', newRegreq.PRM_Contact_Login_ID__c);
        test.stopTest();
        
    }
    
    @isTest static void exceptionToRetrieveEvToken_Test(){
        Test.setMock(HttpCalloutMock.class, new MockHttpFailedResponseGenerator()); 
        test.startTest();
        PRM_Registration_Request__c newRegreq = [SELECT PRM_Email_ID__c, PRM_EV_Token__c, PRM_Person_Phone_Number__c,PRM_Partner_Type__c FROM PRM_Registration_Request__c LIMIT 1];

        PRM_RetriggerEV_Token_API.reTriggerEV('');
        system.assertEquals('444444', newRegreq.PRM_Person_Phone_Number__c);
        test.stopTest();
        
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            res.setStatusCode(201);
            return res;
        }
    }
    
    public class MockHttpFailedResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            res.setStatusCode(400);
            return res;
        }
    }
}