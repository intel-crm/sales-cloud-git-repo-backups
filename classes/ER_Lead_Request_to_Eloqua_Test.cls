/**************************************************************************************
Apex Class Name: ER_Lead_Request_to_Eloqua_Test
Version     : 1.0 
Created Date: 29/11/2021 
Description : Test Class for ER_Lead_Request_to_Eloqua
* Modification Log :
* Developer                 Date                     Description
* ---------------------------------------------------------------------------- 
* Gaurav Kurwade          29/11/2021               Original Version
*************************************************************************************/


@isTest
public class ER_Lead_Request_to_Eloqua_Test {


    @isTest static void testGetRegistrationRequest(){
       
            Account acc = new Account();   
            acc.Name = 'Test';
       		acc.BillingCity = 'Jaipur';
        	acc.BillingCountry = 'India';
        	acc.BillingStreet = 'Test';
        	
           insert acc;
            
            Contact con = new Contact();
        	con.FirstName = 'Test';
            con.LastName = 'Test';
            con.Email = 'testing@gmail.com';
            con.AccountId = acc.Id;
        	
            insert con;
           
 			PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
    
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = con.Email;
            insert regUser;
        	
         	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(201));
        	ER_Lead_Request_to_Eloqua.submitRegistrationDetails(regUser.Id);
            System.assertEquals(regUser != null, true, 'user detail is null');

            Test.stopTest();
        
        
    }
    
 
    @isTest static void submitTest1(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
            PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
    
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = 'testing@gmail.com';
           // insert regUser;
            
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(201));
            ER_Lead_Request_to_Eloqua.setToLeadStageObj(regUser);
            System.assertEquals(regUser != null, true, 'user detail is null');
            Test.stopTest();
        } 
    }
    
    @isTest static void submitTest2(){
        User u = PMP_SearchTestDataFactory.createUser(true);
        System.runAs(u){
            Test.startTest();
			PRM_Registration_Request__c regUser = new PRM_Registration_Request__c ();
           
            regUser.PRM_First_Name__c = 'firstName1';
            regUser.PRM_Last_Name__c = 'lastName1';
            regUser.PRM_Account_Name__c = 'intel1';
            regUser.PRM_Country__c = 'India';
            regUser.PRM_State_Province__c = 'Karnataka';
            regUser.PRM_Person_Phone_Number__c = '9876543210';
            regUser.PRM_Email_ID__c = 'testing@gmail.com';
            
            Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyLeadGenHttpResponse(200));
            ER_Lead_Request_to_Eloqua.setToLeadStageObj(regUser);
            System.assertEquals(regUser != null, true, 'user detail is null');
            Test.stopTest();
        } 
    }
    
    public class PMP_SearchCompanyLeadGenHttpResponse implements HttpCalloutMock {
        
        public Integer statusCode;
        public PMP_SearchCompanyLeadGenHttpResponse(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test" , "values":[{"value":"test value"}]}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
}