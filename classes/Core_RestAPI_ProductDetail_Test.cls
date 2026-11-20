/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductDetail_Test
* Version     : 1.0 
* Created Date: 12/14/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/14/2017              Test class for Core_RestAPI_ProductDetailV1 to retrieve products 
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_ProductDetail_Test{
    
    private static final String v1_0 = 'v1.0';
    private static User commUser  = null;
    private static User adminUser = null;
  
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getProducts_VersionRequest(String version){
         List<Asset> AssetList=[select id from Asset];
        String strProductId = AssetList[0].id;
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/products/'+strProductId; 
            request.resourcePath ='/services/apexrest/v1.0/products/'+strProductId;
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
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            List<Asset> assetList = Core_RestAPI_TestUtilities.getAssetList(10);
            Core_IPS_Product_Organization__c objProdOrg = Core_RestAPI_TestUtilities.getSupportOrg();
            insert objProdOrg;
            Product2 objProd =Core_RestAPI_TestUtilities.getProduct();
            insert objProd;
            Core_IPS_Supported_Product__c objSP= Core_RestAPI_TestUtilities.getSupportedProduct();
            objSP.Core_IPS_Public_Product__c = false;
            objSP.Core_Product__c= objProd.Id ;
            objSP.Core_Product_Organization__c=objProdOrg.Id;
            objSP.Core_Supported_Product_Name__c='Test supported product';
            
            insert objSP;
            Core_IPS_Project__c objIPSProj =Core_RestAPI_TestUtilities.getIpsProjectRecord();
            objIPSProj.Core_Status__c = 'Draft';
            insert objIPSProj;
            objIPSProj.Core_Status__c = 'Active';
            update objIPSProj;
            
            string accountId = [Select Id FROM Account Limit 1].Id;
            for(Integer i =0;i<assetList.size()/2;i++){
                Asset objAsset = assetList [i];
                // objAsset.Core_IPS_Project_Name__c= objIPSProj.Name;
                objAsset.OwnerId = adminUser.Id;
                objAsset.Core_Supported_Product__c=objSP.Id;
                objAsset.AccountId = accountId;
            }
            for(Integer i =assetList.size()/2;i< 10;i++){
                Asset objAsset = assetList [i];
                objAsset.OwnerId = commUser.Id;
                objAsset.Core_Supported_Product__c=objSP.Id;
            }
            insert assetList ;
            
            User u1 = [select Id, username, profileid from User where Id = :UserInfo.getUserId()];
            
            List<Asset> lstAsset =[SELECT Core_IPS_Project_Name__c, id,  Core_IPS_Project__c,core_Product_Application__c,Core_Supported_Product__r.Core_IPS_Public_Product__c,Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Supported_Product__r.Name FROM Asset];
            Core_RestAPI_Response_Codes__c lstResponceCode = new Core_RestAPI_Response_Codes__c(name ='Default', Core_Message__c= 'default error');
            insert lstResponceCode;
            
            
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
            List<Asset> lstAsset =[SELECT Core_IPS_Project_Name__c, id,  Core_IPS_Project__c,core_Product_Application__c,Core_Supported_Product__r.Core_IPS_Public_Product__c,Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Supported_Product__r.Name FROM Asset];
            Core_RestAPI_Response apiResponse = Core_RestAPI_ProductDetailV1.doGet();
            System.assertEquals('200',apiResponse.code);
            System.debug('apiResponse--->'+apiResponse);
            doGet_getProducts_Asserts(apiResponse,null,v1_0);
        }   
    }
}