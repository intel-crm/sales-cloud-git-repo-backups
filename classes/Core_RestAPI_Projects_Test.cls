/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Projects_Test
* Version     : 1.0 
* Created Date: 21 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/21/2017              This class is for testing the business use Project. This single will take care of tesing all the versions of projects API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_Projects_Test {
    
    private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
    private static User commUser  = null;
    
    //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getProjects_VersionRequest(String version){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestURI ='/v1.0/projects/'; 
            request.resourcePath ='/services/apexrest/v1.0/projects/';
        }
        return request;
    }
    
    //Setting the data for accesssing the project API
    @testSetup 
    public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        }
        System.runAs(adminUser){
            List<Core_IPS_Project__c> projectList = Core_RestAPI_TestUtilities.getListOfIpsProjects(10);
            for(Integer i=0;i<projectList.size()/2;i++){
                Core_IPS_Project__c objAPIProj = projectList[i]; 
                objAPIProj.OwnerId = adminUser.Id;
            }
            for(Integer i =projectList.size()/2;i<projectList.size();i++){
                Core_IPS_Project__c objProj = projectList[i];
                objProj.OwnerId = commUser.Id;
            }
            insert projectList;//inserting records for Admin user and Community user
        }
        Test.stopTest();
    }
    
    // Asserts for the responses of Project list
    private static void doGet_getProjects_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0){  
            System.assertEquals('200',apiResponse.Code,'RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(v1_0, strVersion);
            //check for all sharing projects are retrieved
            System.assertEquals(5,apiResponse.successContent.size(), 'All Community user projects retrieved');
            
        }
        //Common Asserts for all versions
        //Verify the transaction log is created
        if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
            try{
                Core_RestAPI_Transaction_Entry__c log = [Select Id FROM Core_RestAPI_Transaction_Entry__c Limit 1];    
                System.assertNotEquals(null, log);
            }catch(Exception e){
                //Fail if log entry is not found when 
                System.assert(null);
            }
        }
    } 
    //Our Test Class Starts from here 
    //Here Test doGet method in Core_RestAPI_ProjectV1
    @isTest public static void test_doGet_getProjects_v1(){
        commUser  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getProjects_VersionRequest(v1_0);//v1_0 is the parameter (String) of getProjects_VersionRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ProjectsV1.doGet();
            System.assertEquals('200',apiResponse.code);
            doGet_getProjects_Asserts(apiResponse,null ,v1_0);
        } 
    }
}