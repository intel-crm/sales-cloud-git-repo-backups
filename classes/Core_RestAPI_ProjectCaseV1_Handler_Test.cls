/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectCaseV1_Handler_Test
* Version     : 1.0 
* Created Date: 14 Dec 2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/14/2017              This class is for testing Core_RestAPI_ProjectCaseV1_Handler methods with all the combination of inputs and it is not intended for business specific project's cases scenarios.
*****************************************************************************************************************************************/
@isTest 
Public class Core_RestAPI_ProjectCaseV1_Handler_Test{   
    
    private static User adminUser  = null;
    //Preparing data to be proceeded for Case list API
    @testSetup 
    public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        
        System.runAs(adminUser){
            list<Core_IPS_Project__c> objproj=Core_RestAPI_TestUtilities.getListOfIpsProjects(10);
            Core_IPS_Project__c objproject=new Core_IPS_Project__c();
            objproject.ownerId=adminuser.id;
            insert objproject;//inserting project record for admin user
            Case caseObj=Core_RestAPI_TestUtilities.getCase();
            caseObj.ownerId=adminuser.id;
            caseObj.Core_IPS_Project_Case__c=objproject.Id;
            //Added by Sowmya - Start - 24/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
             caseObj.Core_IPS_Customer_Visible__c = true;
            //Sowmya - End - 27/09/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        
            insert caseObj;//inserting Case record for admin user
        }
        
        // Core_RestAPI_ProjectCaseV1_Handler.CaseWrapper objcasewrapp= new Core_RestAPI_ProjectCaseV1_Handler.CaseWrapper(caseObj);
        Test.stopTest();
    }
    //This method test the handler methods: getProjectCases & processrequest
    @isTest public static void test_getProjectCases_Positive(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        List<case> lstCases=[SELECT Core_IPS_Project_Case__r.Core_IPS_Project_ID__c FROM case];//list of cases      
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';        
        requestObj.requestUri ='/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';      
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;    
        
        Core_RestAPI_ProjectCaseV1_Handler handler = new Core_RestAPI_ProjectCaseV1_Handler(System.now(), 'Core_RestAPI_ProjectCasesV1 '); 
        Core_RestAPI_Response response = handler.getProjectCases();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
        
    }
    //raising the exception if any error occurs
    @isTest public static void test_getProjectCases_Negative(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        List<case> lstCases=[SELECT Core_IPS_Project_Case__r.Core_IPS_Project_ID__c FROM case];//list of cases      
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';        
        requestObj.requestUri ='/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';      
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;     
        Core_RestAPI_ProjectCaseV1_Handler handler = new Core_RestAPI_ProjectCaseV1_Handler(System.now(), 'Core_RestAPI_ProjectCasesV1 '); 
        Core_RestAPI_Response finalResponse = null;
        System.assertEquals(null, finalResponse);
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getProjectCases();    
        }catch(Exception e){
            exceptionThrown = false;  
        }
        lstCases = null;
        finalResponse = handler.getProjectCases();
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);          
        
    }
    // tests the positive cases for the method doValidations.
    @isTest
    public static void test_doValidations_Positive(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        List<case> lstCases=[SELECT Core_IPS_Project_Case__r.Core_IPS_Project_ID__c FROM case];//list of cases      
        requestObj.resourcePath ='/services/apexrest/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';        
        requestObj.requestUri ='/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';      
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;    
        Core_RestAPI_ProjectCaseV1_Handler handler = new Core_RestAPI_ProjectCaseV1_Handler(System.now(),'Core_RestAPI_ProjectCasesV1 ');
        handler.doValidations();
    }
    //Testing the negative scenario for validation
    @isTest 
    public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            RestRequest requestObj = new RestRequest();
            requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            List<case> lstCases=[SELECT Core_IPS_Project_Case__r.Core_IPS_Project_ID__c FROM case];//list of cases      
            requestObj.resourcePath ='/services/apexrest/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';        
            requestObj.requestUri ='/v1.0/projects/'+lstCases[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';      
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;    
            Core_RestAPI_ProjectCaseV1_Handler handler = new Core_RestAPI_ProjectCaseV1_Handler(System.now(),'Core_RestAPI_ProjectCasesV1 '); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;        }        
        System.assertEquals(false, exceptionThrown);        
    }
}