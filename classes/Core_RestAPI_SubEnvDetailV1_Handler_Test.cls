/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_SubEnvDetailV1_Handler_Test
* Version     : 1.0 
* Created Date: 14 Dec 2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/14/2017              This class is for testing Core_RestAPI_SubEnvDetailV1_Handler methods with all the combination of inputs 
*****************************************************************************************************************************************/
@isTest 
public with sharing class Core_RestAPI_SubEnvDetailV1_Handler_Test{

 private static User adminUser= [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
  private static String strProductId= null;
   private static User commUser  = null;
    //Preparing data to be proceeded for Case list API
    @testSetup 
    public static void setupData(){
       // adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            //commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
            RecordType rt =[select id,Name from RecordType where sObjectType='Core_IPS_Question__c' AND Name='Environment Detail Question' limit 1];
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
            
            Insert CategoriesList;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            
           
            insert CategoriesandSubCategoriesList;//inserting records for Admin user and community user
            Core_IPS_Question__c objQues = new Core_IPS_Question__c();
            //objQues.RecordType = rt.
            objQues.Core_IPS_Datatype__c ='Picklist';
            objQues.Core_IPS_Required__c = true;
            objQues.Core_IPS_Question__c = 'Test Question New EDQ model';
            objQues.Core_IPS_Product_Organization__c = org.id;
            objQues.Core_IPS_Status__c = 'Active';
            insert objQues;
            
            Core_IPS_Answer__c objAns = new Core_IPS_Answer__c();
            objAns.Core_IPS_Answer__c = 'Test Answer New EDQ model';
            objAns.Core_IPS_Question__c = objQues.id;
            objAns.Core_IPS_Status__c = 'Active';
            insert objAns;

            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar= new Core_IPS_Assigned_Environment_Variables__c ();
            ObjEnvVar.Core_Status__c = 'Active';
            ObjEnvVar.Core_Required__c = true;
            ObjEnvVar.Core_Supported_Product__c=sp.id;
            ObjEnvVar.Core_Agent_Only__c=false;
            ObjEnvVar.Core_IPS_Question__c=objQues.id;
            ObjEnvVar.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            insert ObjEnvVar;//inserting record for admin user
            
            List<Core_IPS_Assigned_Environment_Variables__c> testlst=[
 Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        }
        Test.stopTest();
    }
    
    //This method test the handler methods: getProjectCases & processrequest
    @isTest public static void test_getEnvironmentDetails_Positive(){
        
        Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(System.now(), 'Core_RestAPI_SubEnvDetailsV1'); 
        Core_RestAPI_Response response = handler.getEnvironmentDetails();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
        
    }
    //raising the exception if any error occurs
    @isTest public static void test_getEnvironmentDetails_Negative(){
        RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize('{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}', RestRequest.class);
        
         
         List<Core_IPS_Assigned_Environment_Variables__c> subCatId =[select Core_Product_Issue_Sub_Category__r.Name from Core_IPS_Assigned_Environment_Variables__c where Core_IPS_Question__r.Core_IPS_Question__c= 'Test Question New EDQ model'];
        requestObj.resourcePath ='/services/apexrest/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';   
        requestObj.requestUri ='/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';      
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;     
        Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(System.now(), 'Core_RestAPI_SubEnvDetailsV1'); 
        Core_RestAPI_Response finalResponse = null;
        System.assertEquals(null, finalResponse);
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getEnvironmentDetails();    
        }catch(Exception e){
            exceptionThrown = false;  
        }
        subCatId= null;
        finalResponse = handler.getEnvironmentDetails();
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);          
        
    }
      @isTest public static void test_getEnvironmentDetails_NegativeElse(){
          
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
            
            Insert CategoriesList;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
            }
            
           
            insert CategoriesandSubCategoriesList;//inserting records for Admin user and community user
            
            
            
             Core_IPS_Environment_Variables__c objEnvDetMaster= new Core_IPS_Environment_Variables__c();
            objEnvDetMaster.Name = 'Else Test Issue Resolution List';
            objEnvDetMaster.Core_Answers__c = 'Intel';
            objEnvDetMaster.Core_Datatype__c = 'Text (255)';
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
          
          
          
          
          RestRequest requestObj = new RestRequest();
        requestObj = (RestRequest)System.jSON.deserialize('{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}', RestRequest.class);
        
         
         List<Core_IPS_Assigned_Environment_Variables__c> subCatId =[select Core_Product_Issue_Sub_Category__r.Name from Core_IPS_Assigned_Environment_Variables__c where Core_Environment_Variable__r.name= 'Else Test Issue Resolution List' ];
         
        requestObj.resourcePath ='/services/apexrest/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';   
        requestObj.requestUri ='/v1.0/sp/categories/'+subCatId[0].Core_Product_Issue_Sub_Category__r.Name+'/environmentdetails';      
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;     
        Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(System.now(), 'Core_RestAPI_SubEnvDetailsV1'); 
        Core_RestAPI_Response finalResponse = null;
        System.assertEquals(null, finalResponse);
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getEnvironmentDetails();    
        }catch(Exception e){
            exceptionThrown = false;  
        }
          
      }
    
    // tests the positive cases for the method doValidations.
    @isTest
    public static void test_doValidations_Positive(){
        Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(System.now(),'Core_RestAPI_SubEnvDetailsV1');
        handler.doValidations();
    }
    //Testing the negative scenario for validation
    @isTest 
    public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_SubEnvDetailV1_Handler handler = new Core_RestAPI_SubEnvDetailV1_Handler(System.now(),'Core_RestAPI_SubEnvDetailsV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
            }        
        System.assertEquals(false, exceptionThrown);        
    }
}