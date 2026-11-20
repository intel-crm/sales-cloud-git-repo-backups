/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectV1_Handler_Test 
* Version     : 1.0 
* Created Date: 20 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/20/2017              This class is for testing Core_RestAPI_ProjectV1_Handler methods with all the combination of inputs and it is not intended for business projects scenarios.
*****************************************************************************************************************************************/
@isTest
public class Core_RestAPI_ProjectV1_Handler_Test{
    
    private static User adminUser  = null;
    public static DateTime startDate=system.now();
    
    
    //Preparing data to be proceeded for project list API
    @testSetup 
    public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        
        System.runAs(adminUser){
            List<Core_IPS_Project__c> projectList = TestUtilities.getListOfIpsProjects(10);
            for(Integer i=0;i<projectList.size();i++){
                Core_IPS_Project__c objProj = projectList[i];
                objProj.OwnerId = adminUser.Id;
            }
            
            //inserting 10 records of project for Admin user and Community user
            insert projectList;
            System.assertEquals(10, projectList.size());
        }
        Test.stopTest();
    }
    //This method test the handler methods: getProjects & processrequest
    @isTest public static void test_getProjects_Positive(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/';
        requestObj.requestUri ='/v1.0/projects/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;      
        Core_RestAPI_ProjectV1_Handler handler = new Core_RestAPI_ProjectV1_Handler(System.now(), 'Core_RestAPI_ProjectV1'); 
        Core_RestAPI_Response response = handler.getProjects();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
        
    }
    //raising the exception if any error occurs
    @isTest public static void test_getProjects_Negative(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/';
        requestObj.requestUri ='/v1.0/projects/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;      
        Core_RestAPI_ProjectV1_Handler handler = new Core_RestAPI_ProjectV1_Handler(System.now(), 'Core_RestAPI_ProjectV1'); 
        Core_RestAPI_Response finalResponse = null;
        System.assertEquals(null, finalResponse);
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getProjects();    
        }catch(Exception e){
            exceptionThrown = false;  
        }
        System.assertEquals(true, exceptionThrown);
        
    }
    // tests the positive projects for the method doValidations.
    //For future purpose
    @isTest
    public static void test_doValidations_Positive(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/';
        requestObj.requestUri ='/v1.0/projects/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;      
        Core_RestAPI_ProjectV1_Handler handler = new Core_RestAPI_ProjectV1_Handler(System.now(), 'Core_RestAPI_ProjectsV1');
        handler.doValidations();
    }
    //Testing the negative scenario for validation
    //For Future purpose
    @isTest 
    public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/';
        requestObj.requestUri ='/v1.0/projects/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;      
        try{
            Core_RestAPI_ProjectV1_Handler handler = new Core_RestAPI_ProjectV1_Handler(System.now(), 'Core_RestAPI_ProjectsV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;        }        
        System.assertEquals(false, exceptionThrown);
    }
}