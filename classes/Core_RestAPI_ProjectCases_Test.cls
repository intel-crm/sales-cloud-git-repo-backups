/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectCases_Test 
* Version     : 1.0  
* Created Date: 11 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps        12/11/2017            This class is for testing the business use Project. This single will take care of tesing all the versions of specific project's Cases API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_ProjectCases_Test {
    private static final String v1_0 = 'v1.0';
 private static User adminUser  = null;
    private static User commUser  = null;
    
    //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getProjectCases_VersionRequest(String version){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            User u  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            List<case> lstCseObj= [Select Core_IPS_Project_Case__r.Core_IPS_Project_ID__c, ContactId, AccountId, contact.AccountId FROM Case Where Core_IPS_Project_Case__r.Core_IPS_Project_ID__c != null AND OwnerId =: u.id];
            request.resourcePath ='/services/apexrest/v1.0/projects/'+lstCseObj[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';
            request.requestURI ='/v1.0/projects/'+lstCseObj[0].Core_IPS_Project_Case__r.Core_IPS_Project_ID__c+'/cases';
            
        }
        return request;
    }
    
    //Setting the data for accesssing the specific project's Cases API
    @testSetup 
    public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(2);
            
            List<Account> allAccounts = [Select Name FROM Account];
            Core_IPS_Project__c objproj=Core_RestAPI_TestUtilities.getIpsProjectRecord();
            Core_IPS_Project__c objproject=new Core_IPS_Project__c();
            objproject.ownerId=adminuser.id;
            insert objproject;//inserting project record for admin user
            
            Case caseObj=caseList[0];
            caseObj.ownerId=adminuser.id;
            caseObj.Core_IPS_Project_Case__c=objproject.Id;
            insert caseObj;//inserting case record for admin user
            
            
            Core_IPS_Project__c projectObj=TestUtilities.getIpsProjectRecord();
            //Core_IPS_Project__c objPrjt=new Core_IPS_Project__c();
            projectObj.ownerId = commUser.id;
            projectObj.Core_Status__c  = 'Draft';
            insert projectObj;//inserting project record for community user
            
            Case objCase=caseList[1];
            objCase.ownerId = commUser.id;
            objCase.Core_IPS_Project_Case__c = projectObj.Id;
            objCase.AccountId = allAccounts[0].id;
            insert objCase;//inserting case record for community user
            
        }  
        System.runAs(commUser){
            
        }
        Test.stopTest();
    }
    // Asserts for the responses of Cases list
    private static void doGet_getProjectCases_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0){  
            System.assertEquals('200',apiResponse.Code,'RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(v1_0, strVersion);
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
    //Here Test doGet method in Core_RestAPI_ProjectCasesV1 
    @isTest public static void test_doGet_getProjectCases_v1(){
        commUser  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getProjectCases_VersionRequest(v1_0);//v1_0 is the parameter (String) of getProjectCases_VersionRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ProjectCasesV1.doGet();
            System.assertEquals('200',apiResponse.code);
            doGet_getProjectCases_Asserts(apiResponse,null ,v1_0);
        } 
    }

}