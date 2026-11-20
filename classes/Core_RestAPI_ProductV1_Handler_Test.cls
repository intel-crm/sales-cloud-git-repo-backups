/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductV1_Handler_Test 
* Version     : 1.0 
* Created Date: 11/21/2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/21/2017              This class is for testing Core_RestAPI_ProductV1_Handler methods with all the combination of inputs.
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_ProductV1_Handler_Test{
    
    
    private static User adminUser  = null;
    //Preparing data to be proceeded for product list API
    @testSetup public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Test.startTest();
        Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        
        //Insert 10 products for admin User
        System.runAs(adminUser){
            List<Asset> AssetList = TestUtilities.getAssetList(10); 
            
            Core_IPS_Project__c objIPSProj =TestUtilities.getIpsProjectRecord();
            objIPSProj.Core_Status__c = 'Draft';
            insert objIPSProj;
            objIPSProj.Core_Status__c = 'Active';
            update objIPSProj;
            
            for(Integer i=0;i<=(AssetList.size()-1);i++){
                Asset objAsset = AssetList[i];
                objAsset.OwnerId = adminUser.Id;
                objAsset.Core_IPS_Project__c= objIPSProj.Id;
                //objAsset.Core_IPS_Project__r.Core_Status__c=objIPSProj.Core_Status__c;
            }
            insert AssetList;
            System.assertEquals(10, AssetList.size());
        }
        Test.stopTest();
    }
    
    //This method test the handler methods: getProducts & processrequest
    @isTest public static void test_getProduct_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/products/';
        requestObj.requestUri ='/v1.0/products/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Core_RestAPI_ProductV1_Handler handler = new Core_RestAPI_ProductV1_Handler(System.now(), 'Core_RestAPI_ProductsV1'); 
        Core_RestAPI_Response response = handler.getProducts();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
    }
    
    
    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getProducts_Negative(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/products/';
        requestObj.requestUri ='/v1.0/products/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        
        Core_RestAPI_ProductV1_Handler handler = new Core_RestAPI_ProductV1_Handler(System.now(), 'Core_RestAPI_ProductsV1'); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getProducts();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);
    }
    
    //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/products/';
        requestObj.requestUri ='/v1.0/Products/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Core_RestAPI_ProductV1_Handler handler = new Core_RestAPI_ProductV1_Handler(System.now(), 'Core_RestAPI_ProductsV1'); 
        handler.doValidations();
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/products/';
        requestObj.requestUri ='/v1.0/products/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Boolean exceptionThrown = true;
        try{
            Core_RestAPI_ProductV1_Handler handler = new Core_RestAPI_ProductV1_Handler(System.now(), 'Core_RestAPI_ProductsV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(true, exceptionThrown);
    }
    
}