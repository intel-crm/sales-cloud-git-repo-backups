/*******************************************************************************************************************************************************
* Class Name  : Core_RestAPI_SPEnvDetails_Test
* Version     : 1.0 
* Created Date: 05 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         01/05/2018          Test class for Core_RestAPI_SPEnvDetailsV1 to retrieve specific Supported Product's Environment Details 
*********************************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_SPEnvDetails_Test{  

     private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
    private static User commUser  = null;
    private static String strProductId= null;
    private static Asset objsuppProdName = null;
    private static  Product2 productRecord;
    
    
    //Setting the data for accesssing the specific Supported Product's Environment Details API
    @testSetup 
    public static void setupData(){
    
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 1);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        }
        Test.stopTest();
            productRecord =TestUtilities.getProduct();
            insert productRecord;
            
            Core_IPS_Product_Organization__c objSupportedproductOrg =new Core_IPS_Product_Organization__c();
            objSupportedproductOrg.Core_IPS_Support_Org_Name__c='Test Org';
            objSupportedproductOrg.Core_Organization_Description__c='Test Description';
            insert objSupportedproductOrg;
            
            List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
            
            Core_IPS_Environment_Variables__c objEnvDetMaster= new Core_IPS_Environment_Variables__c();
            objEnvDetMaster.Name = 'Test Issue Resolution List';
            objEnvDetMaster.Core_Answers__c = 'Intel';
            objEnvDetMaster.Core_Datatype__c = 'Picklist';
            objEnvDetMaster.Core_Status__c = 'Active';
            objEnvDetMaster.Core_Product_Organization__c=objSupportedproductOrg.id;
            insert objEnvDetMaster;
            
            
            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar= new Core_IPS_Assigned_Environment_Variables__c ();
            ObjEnvVar.Core_Status__c = 'Active';
            ObjEnvVar.Core_Supported_Product__c=allAssets[0].Core_Supported_Product__c;
            ObjEnvVar.Core_Environment_Variable__c=objEnvDetMaster.id;
            insert ObjEnvVar;//inserting record for admin user
            
        }
       
    //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getEnvironmentDetails_VersionRequest(String version){
        objsuppProdName = [SELECT Id,Core_Supported_Product__r.Name FROM Asset];
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE , RestRequest.class);
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        if(v1_0.equals(version)){
           
            requestObj.resourcePath ='/services/apexrest/v1.0/products/'+objsuppProdName.Id+'/environmentdetails';
            requestObj.requestURI ='/v1.0/products/'+objsuppProdName.Id+'/environmentdetails';
        }
        return requestObj;
    }
    // Asserts for the responses of Cases list
    private static void doGet_getEnvironmentDetails_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
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
    //Here Test doGet method in Core_RestAPI_SPEnvDetailsV1
    @isTest public static void test_doGet_getEnvironmentDetails_v1(){
        commUser  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getEnvironmentDetails_VersionRequest(v1_0);//v1_0 is the parameter (String) of getEnvironmentDetails_VersionRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_SPEnvDetailsV1.doGet();
            doGet_getEnvironmentDetails_Asserts(apiResponse,null ,v1_0);
        } 
    }
    
}