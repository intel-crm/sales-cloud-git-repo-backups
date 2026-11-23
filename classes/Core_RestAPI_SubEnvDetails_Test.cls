/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_SubEnvDetails_Test
* Version     : 1.0 
* Created Date: 12/14/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/14/2017              Test class for Core_RestAPI_SubEnvDetailsV1to retrieve products 
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_SubEnvDetails_Test{
    private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
     private static String strProductId= null;
    private static  Product2 productRecord;
    private static User commUser  = null;
    
    
    //Setting the data for accesssing the specific Supported Product's Environment Details API
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
            strProductId = sp.id;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesList[i]; 
                objAPI.Core_Type__c = 'Case Category';
                objAPI.Core_Supported_Product__c = sp.id;
            }
            for(Integer i =0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objProj = CategoriesList[i];
                objProj.Core_Type__c = 'Case Category';
                objProj.Core_Supported_Product__c = sp.id;
            }
            Insert CategoriesList;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            
            for(Integer i =0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objProj = CategoriesandSubCategoriesList[i];
                objProj.Core_Type__c = 'Case SubCategory';
                objProj.OwnerId = commUser.Id;
                objProj.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            insert CategoriesandSubCategoriesList;//inserting records for Admin user and community user
            
            
             Core_IPS_Environment_Variables__c objEnvDetMaster= new Core_IPS_Environment_Variables__c();
            objEnvDetMaster.Name = 'Test Issue Resolution List';
            objEnvDetMaster.Core_Answers__c = 'Intel';
            objEnvDetMaster.Core_Datatype__c = 'Picklist';
            objEnvDetMaster.Core_Status__c = 'Active';
            objEnvDetMaster.Core_Product_Organization__c=org.id;
            insert objEnvDetMaster;

            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar= new Core_IPS_Assigned_Environment_Variables__c ();
            ObjEnvVar.Core_Status__c = 'Active';
            ObjEnvVar.Core_Required__c = true;
            ObjEnvVar.Core_Supported_Product__c=sp.id;
            ObjEnvVar.Core_Agent_Only__c=false;
            ObjEnvVar.Core_Environment_Variable__c=objEnvDetMaster.id;
            ObjEnvVar.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            insert ObjEnvVar;//inserting record for admin user
            
           Core_IPS_Assigned_Environment_Variables__c testlst=[
 Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
         
        }
        Test.stopTest();
    }  
    
    
     //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getEnvironmentDetails_VersionRequest(String version){
        RestRequest request = (RestRequest)System.jSON.deserialize('{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.sandbox.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}', RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            User u  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            
             
         List<Core_IPS_Assigned_Environment_Variables__c> subCatId =[select Core_Product_Issue_Sub_Category__r.Name from Core_IPS_Assigned_Environment_Variables__c where Core_Environment_Variable__r.name= 'Test Issue Resolution List'  ];
             request.resourcePath ='/services/apexrest/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';
            request.requestURI ='/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';
            
        }
        return request;
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
    //Here Test doGet method in Core_RestAPI_SPEnvnmtDetailsV1 
    @isTest public static void test_doGet_getEnvironmentDetails_v1(){
        commUser  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getEnvironmentDetails_VersionRequest(v1_0);//v1_0 is the parameter (String) of getEnvironmentDetails_VersionRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_SubEnvDetailsV1.doGet();
            System.assertEquals('200',apiResponse.code);
            doGet_getEnvironmentDetails_Asserts(apiResponse,null ,v1_0);
        } 
    }

}