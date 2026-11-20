/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Products_Test
* Version     : 1.0 
* Created Date: 11/21/2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/21/2017              Test class for Core_RestAPI_ProductsV1 to retrieve products 
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_Products_Test {
    
    private static final String v1_0 = 'v1.0';
    private static User commUser  = null;
    private static User adminUser = null;
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getProducts_VersionRequest(String version){
        
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/products/'; 
            request.resourcePath ='/services/apexrest/v1.0/products/';
        }
        return request;
    }
    // method to get user which as 'system admin' and 'active' 
    @testSetup public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        }
        //Insert 10 assets for admin User 
        System.runAs(adminUser){
            List<Asset> assetList = Core_RestAPI_TestUtilities.getAssetList(10);
            for(Integer i =0;i<assetList.size()/2;i++){
                Asset objAsset = assetList [i];
                objAsset.OwnerId = adminUser.Id;
            }
            for(Integer i =0;i<assetList.size()/2;i++){
                Asset objAsset = assetList [i];
                objAsset.OwnerId = commUser.Id;
            }
            insert assetList ;
        }
        Test.stopTest();
    }
    // Asserts for the responses of Product list
    private static void doGet_getProducts_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
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
    
    //Test the doGet method
    @isTest public static void test_doGet_getProducts_v1(){
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getProducts_VersionRequest(v1_0);
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ProductsV1.doGet();
            System.assertEquals('200',apiResponse.code);
            doGet_getProducts_Asserts(apiResponse,null,v1_0);
        }   
    }
}