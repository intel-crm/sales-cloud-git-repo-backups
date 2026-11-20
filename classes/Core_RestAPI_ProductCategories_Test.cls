/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductCategories_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017 
* Modification Log :
* Developer                 Date                    Description  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing the business use Categories and SubCategories. This single will take care of tesing all the versions of Categories and SubCategories API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_ProductCategories_Test {
    
    private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
    private static User commUser  = null;
    private static String strProductId= null;
    private static Asset objsuppProdName = null;
    private static  Product2 productRecord;
    
    @testSetup 
    public static void setupData(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        
        Test.startTest();
        System.runAs(adminUser){
            
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 1);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        }
        Test.stopTest();
            /*
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
			
            sp = [Select Name,Core_Product_Organization__c,Core_EOIS__c,Core_Supported_Product_Name__c,Core_Product__c    FROM Core_IPS_Supported_Product__c limit 1];
            
            
            Asset objAsst = new Asset(
                Name = 'Haswell EP Intel products',
                Core_Supported_Product__c = allAssets[0].Core_Supported_Product__c;
            );
            insert objAsst;
            strProductId = objAsst.id;

			*/
            List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];

            List<Core_IPS_Product_Issue_Category__c> CategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesList[i]; 
                objAPI.OwnerId = adminUser.Id;
                objAPI.Core_Type__c = 'Case Category';
                objAPI.Core_Supported_Product__c = allAssets[0].Core_Supported_Product__c;
            }
            for(Integer i =0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objProj = CategoriesList[i];
                objProj.OwnerId = commUser.Id;
                objProj.Core_Type__c = 'Case Category';
                objProj.Core_Supported_Product__c = allAssets[0].Core_Supported_Product__c;
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
    //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getCategoriesandSubCategories_VersionRequest(String version){
        objsuppProdName = [SELECT Id,Core_Supported_Product__r.Name FROM Asset];
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE , RestRequest.class);
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        
        if(v1_0.equals(version)){
            requestObj.requestUri ='/v1.0/products/'+objsuppProdName.Id+'/categories/';
            requestObj.resourcePath ='/services/apexrest/v1.0/products/'+objsuppProdName.Id+'/categories/';
        }
        return requestObj ;
    }
    
    //Setting the data for accesssing the Categories and SubCategories API
    // Asserts for the responses of Categories and SubCategories list
    private static void getCategoriesandSubCategories_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0){  
            System.assertEquals('200',apiResponse.Code,'RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            //check for all sharing Categories and SubCategories are retrieved
            System.assertEquals(apiResponse.successContent.size() != null, true);
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
    //Here Test doGet method in Core_RestAPI_ProductCategoriesV1
    @isTest public static void test_doGet_getCategoriesandSubCategories_V1(){
       commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getCategoriesandSubCategories_VersionRequest(v1_0);//v1_0 is the parameter (String) of doGet_getCategoriesandSubCategories_VersionRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ProductCategoriesV1.doGet();
            System.assertEquals('200',apiResponse.code);
            getCategoriesandSubCategories_Asserts(apiResponse,null,v1_0);
        } 
    }
}