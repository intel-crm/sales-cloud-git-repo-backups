/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseDetailV1_Handler_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/16/2017              This class is for testing Core_RestAPI_Case_Handler methods with all the combination of inputs and it is not intended for business cases scenarios.
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_CaseDetailV1_Handler_Test {
    private static User commUser  = null;
    private static User adminUser  = null;
    private static Case objCase = null;
    
    static{
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/';
        requestObj.requestUri ='/v1.0/cases/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        
    }
    
    @testSetup public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        System.debug(' Core_RestAPI_CaseDetailV1_Handler_Test Account '+[Select Name FROM Account] + ' Contact '+[Select Name FROM Contact]);

        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        System.debug(' Core_RestAPI_CaseDetailV1_Handler_Test User '+commUser);
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(adminUser){
            
            
            List<case> caseList = Core_RestAPI_TestUtilities.getListOfCases(10);
            List<Case> lstCase = Core_RestAPI_TestUtilities.getListOfCases(10);
            for(Integer i =0;i<lstCase.size()/2;i++){
                Case c = lstCase[i];
               c.OwnerId = commUser.Id;
               c.Core_IPS_Customer_Visible__c = true;
               //c.Core_IPS_Supported_Product__c = sp.id;
            }
            for(Integer i =lstCase.size()/2;i<lstCase.size();i++){
                Case c = lstCase[i];
                 c.OwnerId = adminUser.Id;
                 c.Core_IPS_Customer_Visible__c = true;
                 //c.Core_IPS_Supported_Product__c = sp.id;
            }
            insert lstCase;
            
            Core_IPS_Product_Organization__c  org =new Core_IPS_Product_Organization__c ( 
                Core_IPS_Support_Org_Name__c = 'TestName',
                Core_Organization_Description__c = 'TestDescription'        
            );
            insert org;
            Core_IPS_Question__c objQues = new Core_IPS_Question__c();
            objQues.Core_IPS_Datatype__c ='Multiselect Picklist';
            objQues.Core_IPS_Required__c = true;
            objQues.Core_IPS_Question__c = 'Test Question New EDQ model';
            objQues.Core_IPS_Product_Organization__c = org.id;
            objQues.Core_IPS_Status__c = 'Active';
            insert objQues;
            
            Core_IPS_Question__c objQuesPick = new Core_IPS_Question__c();
            objQuesPick.Core_IPS_Datatype__c ='Picklist';
            objQuesPick.Core_IPS_Required__c = true;
            objQuesPick.Core_IPS_Question__c = 'Test Question New EDQ model picklist';
            objQuesPick.Core_IPS_Product_Organization__c = org.id;
            objQuesPick.Core_IPS_Status__c = 'Active';
            insert objQuesPick;
            
            Core_IPS_Answer__c objAns = new Core_IPS_Answer__c();
            objAns.Core_IPS_Answer__c = 'Test Answer New EDQ model';
            objAns.Core_IPS_Question__c = objQues.id;
            objAns.Core_IPS_Status__c = 'Active';
            insert objAns;
           
            
            Core_IPS_Response__c objResponse = new Core_IPS_Response__c();
            objResponse.Core_IPS_Question_Master__c = objQues.id;
            objResponse.Core_IPS_Answer_Master__c = objAns.id;
            objResponse.Core_IPS_Case__c = lstCase[0].id;
            insert objResponse;
            
            Core_IPS_Response__c objResponse2 = new Core_IPS_Response__c();
            objResponse2.Core_IPS_Question_Master__c = objQuesPick.id;
            objResponse2.Core_IPS_Case__c = lstCase[0].id;
            insert objResponse2;
            
            Core_IPS_Response__c objResponse3 = new Core_IPS_Response__c();
            objResponse3.Core_IPS_Question_Master__c = objQues.id;
            objResponse3.Core_IPS_Answer_Master__c = objAns.id;
            objResponse3.Core_IPS_Case__c = lstCase[0].id;
            insert objResponse3;

            
            //inserting 10 records of project for Admin user and Community user
            System.debug('Print the insert cases'+lstCase);
            System.assertEquals(10, lstCase.size());
        }
        Test.stopTest();
        System.debug(' +++++++++++++++++++++++++++ Core_RestAPI_CaseDetailV1_Handler  Test Data Setup COmpleted +++++++++++++++++++++++++++ \n\n\n\n\n\n');
    }
    
    
    
    //This method test the handler methods: getCaseDetail & processrequest
    @isTest public static void test_getCaseDetail_Positive(){
        System.debug('In Case Detail Positive');
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
        objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
        System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber;
        requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber;
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(System.now(), 'Core_RestAPI_CasesV1'); 
        Core_RestAPI_Response response = handler.getCaseDetail();  
        System.assertNotEquals(null, response);
        System.debug(' >>> response '+response);
        
    }
    
    
    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getCaseDetail_Negative(){
        Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(System.now(), null); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getCaseDetail();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.debug(' >>> test_getCases_Negative >>>  response '+finalResponse);
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown, 'Handler not thrown any exception if false');
        
        
       
    }
    
    //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(System.now(), 'Core_RestAPI_Case_DetailV1'); 
        handler.doValidations();
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(System.now(), 'Core_RestAPI_Case_DetailV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
    
    @isTest public static void test_URI_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/00200621/sdes';
        requestObj.requestUri ='/v1.0/cases/00200621/sdes';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Core_RestAPI_CaseDetailV1_Handler handler = new Core_RestAPI_CaseDetailV1_Handler(System.now(), 'Core_RestAPI_Case_DetailV1'); 
        Boolean validationsPassed = handler.doValidations();
        System.assertEquals(false, validationsPassed);
        
    }
}