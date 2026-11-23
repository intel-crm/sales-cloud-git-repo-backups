/***************************************************************************************************
Class Name:  Core_AVM_RestAPI_UserCaseSharedData_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 17 Jan 2021
Function    : This class contains test coverage for Core_AVM_RestAPI_UserCaseSharedData class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_AVM_RestAPI_UserCaseSharedData class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* PopcornApps        17/01/2022                 This class contains unit test scenarios for Core_AVM_RestAPI_UserCaseSharedData class
****************************************************************************************************/  
@isTest(seealldata=false)
public class Core_AVM_RestAPI_UserCaseSharedData_Test {
    public static  DateTime strDate = System.Now();
    //private static User adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_AVM_RestAPI_UserCaseSharedData.class.getName();
    
    private static User commUser  = null;
    private static User adminUser  = null;
    private static Case objCase = null;
    
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
        
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            System.debug(' Core_RestAPI_CaseDetailV1_Handler_Test Account '+[Select Name FROM Account] + ' Contact '+[Select Name FROM Contact]);
            
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            System.debug(' Core_RestAPI_CaseDetailV1_Handler_Test User '+commUser);
            List<Case> lstCase = Core_RestAPI_TestUtilities.getListOfCases(10);
       
            for(Integer i=0;i<lstCase.size();i++){
                Case c = lstCase[i];
                c.OwnerId = adminUser.Id;
                c.Core_IPS_Customer_Visible__c = true;
                //c.Core_IPS_Supported_Product__c = sp.id;
            }
             //Added by Sowmya - Start - 27/09/2024 - TWC745-6800 - Fix test coverage for all failed classes - for the above case the status is New hence the asswetion is failing so created another case with status as open
       		  for(Integer i=0;i<lstCase.size();i++){
                Case c = lstCase[i];
                c.OwnerId = adminUser.Id;
                c.Core_IPS_Customer_Visible__c = true;
                 c.Status = 'Open';
              }
             //Sowmya - End - 27/09/2024 - TWC745-6800 - Fix test coverage for all failed classes 
       
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
       
        User adminUser = [Select Id,Email FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        //Insert 5 cases for admin User & 5 cases for Community User
      
        Test.startTest();
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/userCaseShares/'+adminUser.Email;
        requestObj.requestUri ='/v1.0/userCaseShares/'+adminUser.Email;
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        Core_AVM_RestAPI_UserCaseSharedData.doGet();
        Core_AVM_UserCaseSharedData_Handler handler = new Core_AVM_UserCaseSharedData_Handler(System.now(), 'Core_AVM_RestAPI_UserCaseSharedData'); 
        Core_RestAPI_Response response = handler.getCaseDetail();  
        //handler.processRequest();
        system.debug('response'+response);
        System.assertEquals(response.successContent.size(),10);
        System.assertNotEquals(null, response);
        System.debug(' >>> response '+response);
        Test.stopTest();
    }
}