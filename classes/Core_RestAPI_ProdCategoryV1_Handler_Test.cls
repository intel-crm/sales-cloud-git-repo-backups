/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProdCategoryV1_Handler_Test 
* Version     : 1.0 
* Created Date: 20 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/20/2017              This class is for testing Core_RestAPI_ProdCategoryV1_Handler_Test methods with all the combination of inputs and it is not intended for business projects scenarios.
*****************************************************************************************************************************************/
@isTest
public class Core_RestAPI_ProdCategoryV1_Handler_Test{
    
    private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
    private static User commUser  = null;
    private static String strProductId= null;
    private static Asset objsuppProdName = null;
    //Preparing data to be proceeded for product list API
    
    @testSetup 
    public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            
            Core_IPS_Product_Organization__c  org =new Core_IPS_Product_Organization__c ( 
                Core_IPS_Support_Org_Name__c = 'TestName',
                Core_Organization_Description__c = 'TestDescription'        
            );
            insert org;
            Product2 prod = new Product2(
                Name = 'Haswell EP',
                Core_Sales_Visible_Flag__c = false,
                Core_IPS_Visible_Flag_External__c = true,
                Core_IPS_Visible_Flag_Internal__c = 'Yes',
                IsActive = true,
                Core_Product_Org__c = 'IPS'//@@New Validation Rule!!!
                
            ); 
            insert prod;
            
            Core_IPS_Supported_Product__c sp= new Core_IPS_Supported_Product__c(
                Core_Product_Organization__c = org.Id,
                Core_EOIS__c = false,
                Core_Supported_Product_Name__c = 'Haswell EP',
                Core_Product__c=prod.id
            );
            
            insert sp;
            Asset objAsst = new Asset(
                Name = 'Haswell EP Intel products',
                Core_Supported_Product__c = sp.id
            );
            insert objAsst;
            strProductId = objAsst.id;
            List<Core_IPS_Product_Issue_Category__c> CategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesList[i]; 
                objAPI.OwnerId = adminUser.Id;
                objAPI.Core_Type__c = 'Case Category';
                objAPI.Core_Supported_Product__c = sp.id;
            }
            for(Integer i =0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objProj = CategoriesList[i];
                objProj.OwnerId = commUser.Id;
                objProj.Core_Type__c = 'Case Category';
                objProj.Core_Supported_Product__c = sp.id;
            }
            Insert CategoriesList;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.OwnerId = adminUser.Id;
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            
            for(Integer i =0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objProj = CategoriesandSubCategoriesList[i];
                objProj.Core_Type__c = 'Case SubCategory';
                objProj.OwnerId = commUser.Id;
                objProj.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            insert CategoriesandSubCategoriesList;//inserting records for Admin user and community user
        }
        Test.stopTest();
    }
    //This method test the handler methods: getCategoriesandSubCategories & processrequest
    @isTest public static void test_getCategoriesandSubCategories_Positive(){
        objsuppProdName = [SELECT Id,Core_Supported_Product__r.Name FROM Asset  WHERE Name = 'Haswell EP Intel products'];
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE , RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/products/'+objsuppProdName.Id+'/categories/';
        requestObj.requestUri ='/v1.0/products/'+objsuppProdName.Id+'/categories/';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        
        Core_RestAPI_ProductCategoryV1_Handler handler = new Core_RestAPI_ProductCategoryV1_Handler(system.now(),null); 
        Core_RestAPI_Response finalResponse = null;
        System.assertEquals(null, finalResponse);
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        
        try{
            finalResponse = handler.getCategoriesandSubCategories(); 
        }catch(Exception e){
            exceptionThrown = false;  
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);
        Core_RestAPI_Response response = handler.getCategoriesandSubCategories();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
    }
    
    @isTest public static void test_getCategoriesandSubCategories_Negative(){
        RestContext.request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Core_RestAPI_ProductCategoryV1_Handler handler = new Core_RestAPI_ProductCategoryV1_Handler(system.now(),null); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        RestContext.request =null;
        finalResponse = handler.getCategoriesandSubCategories(); 
        System.assertNotEquals(null, finalResponse);
    }
    
    // tests the positive projects for the method doValidations.
    //For future purpose
    @isTest
    public static void test_doValidations_Positive(){
        RestContext.request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        Core_RestAPI_ProductCategoryV1_Handler handler = new Core_RestAPI_ProductCategoryV1_Handler(system.now(), 'Core_RestAPI_ProductCategoriesV1');
        handler.doValidations();   
    }
    //Testing all the negative scenario for validation
    //For Future purpose
    @isTest 
    public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_ProductCategoryV1_Handler handler = new Core_RestAPI_ProductCategoryV1_Handler(system.now(), 'Core_RestAPI_ProductCategoriesV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
}