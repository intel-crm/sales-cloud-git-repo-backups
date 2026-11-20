/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_SPEnvDetailV1_Handler_Test
* Version     : 1.0 
* Created Date: 08 Jan 2018
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         08/01/2018              This class is for testing Core_RestAPI_SPEnvDetailV1_Handler methods with all the combination of inputs and it is not intended for business specific Supported Product's Environment Details scenarios.
*****************************************************************************************************************************************/
@isTest 
Public class Core_RestAPI_SPEnvDetailV1_Handler_Test{   

    
    private static User adminUser  = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
    //Preparing data to be proceeded for Core_IPS_Assigned_Environment_Variables__c list API
    @testSetup 
    public static void setupData(){
        
        Test.startTest();
            TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        
        System.runAs(adminUser){
            
            Product2 productRecord = TestUtilities.getProduct();
            insert productRecord;
            
            Core_IPS_Product_Organization__c objSupportedproduct =new Core_IPS_Product_Organization__c();
            objSupportedproduct.Core_IPS_Support_Org_Name__c='Test Org';
            objSupportedproduct.Core_Organization_Description__c='Test Description';
            insert objSupportedproduct;
            
            Core_IPS_Supported_Product__c objSuppProduct = Core_RestAPI_TestUtilities.getSupportedProduct();
            objSuppProduct.Core_Product_Organization__c = objSupportedproduct.id;
            objSuppProduct.Core_Product__c=productRecord.id;
            insert objSuppProduct;
            
            Asset objAsset = new Asset();
            objAsset.Name = 'HP Test Intel Asset';
            objAsset.Core_Supported_Product__c = objSuppProduct.id;
            insert objAsset;
            
            Core_IPS_Question__c objQues = new Core_IPS_Question__c();
            //objQues.RecordType = rt.
            objQues.Core_IPS_Datatype__c ='Picklist';
            objQues.Core_IPS_Required__c = true;
            objQues.Core_IPS_Question__c = 'Test Question New EDQ model';
            objQues.Core_IPS_Product_Organization__c = objSupportedproduct.id;
            objQues.Core_IPS_Status__c = 'Active';
            insert objQues;
            
            Core_IPS_Answer__c objAns = new Core_IPS_Answer__c();
            objAns.Core_IPS_Answer__c = 'Test Answer New EDQ model';
            objAns.Core_IPS_Question__c = objQues.id;
            objAns.Core_IPS_Status__c = 'Active';
            insert objAns;
            
            Core_IPS_Assigned_Environment_Variables__c objEnvVar= new Core_IPS_Assigned_Environment_Variables__c ();
            objEnvVar.Core_Status__c = 'Active';
            objEnvVar.Core_Supported_Product__c=objSuppProduct.id;
            objEnvVar.Core_IPS_Question__c=objQues.id;
            insert objEnvVar;
            
        }
        Test.stopTest();
    }
    //This method test the handler methods: getEnvironmentDetails & processrequest
    @isTest public static void test_getEnvironmentDetails_Positive(){
    
           
            Core_RestAPI_SPEnvDetailV1_Handler handler = new Core_RestAPI_SPEnvDetailV1_Handler(System.now(), 'Core_RestAPI_SPEnvDetailsV1 '); 
            Core_RestAPI_Response response = handler.getEnvironmentDetails();
            System.assertNotEquals(null, response);
            System.assertEquals(response.code,'200');
        
    }
    //raising the exception if any error occurs
    @isTest public static void test_getEnvironmentDetails_Negative(){
            RestRequest requestObj = new RestRequest();
            requestObj = (RestRequest)System.jSON.deserialize('{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}', RestRequest.class);
          
            List<Core_IPS_Assigned_Environment_Variables__c > lstEnvVariables=[select Core_Supported_Product__r.Name from Core_IPS_Assigned_Environment_Variables__c where Core_IPS_Question__r.Core_IPS_Question__c= 'Test Question New EDQ model'];//list of environment detail operational       
            requestObj.resourcePath ='/services/apexrest/v1.0/products/'+lstEnvVariables[0].Core_Supported_Product__r.Name+'/environmentdetails';  
            requestObj.requestUri ='/v1.0/products/'+lstEnvVariables[0].Core_Supported_Product__r.Name+'/environmentdetails'; 
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;     
            Core_RestAPI_SPEnvDetailV1_Handler handler = new Core_RestAPI_SPEnvDetailV1_Handler(System.now(), 'Core_RestAPI_SPEnvDetailsV1 '); 
            Core_RestAPI_Response finalResponse = null;
            System.assertEquals(null, finalResponse);
            handler.response.successContent = null;
            Boolean exceptionThrown = true;
            try{
                finalResponse = handler.getEnvironmentDetails();    
            }catch(Exception e){
                exceptionThrown = false;  
            }
            lstEnvVariables = null;
            finalResponse = handler.getEnvironmentDetails();
            System.assertNotEquals(null, finalResponse);
            System.assertEquals(true, exceptionThrown);  
        
    }
    @isTest public static void test_getEnvironmentDetails_NegativeElse(){
        
            Product2 productRecord = TestUtilities.getProduct();
            insert productRecord;
            
            Core_IPS_Product_Organization__c objSupportedproduct =new Core_IPS_Product_Organization__c();
            objSupportedproduct.Core_IPS_Support_Org_Name__c='Test Org';
            objSupportedproduct.Core_Organization_Description__c='Test Description';
            insert objSupportedproduct; 
            
            Core_IPS_Supported_Product__c objSuppProduct = TestUtilities.getSupportedProduct();
            objSuppProduct.Core_Product_Organization__c = objSupportedproduct.id;
            objSuppProduct.Core_Product__c=productRecord.id;
            insert objSuppProduct;
            
            Asset objAsset = new Asset();
            objAsset.Name = 'HP Intel Product Asset';
            objAsset.Core_Supported_Product__c = objSuppProduct.id;
            insert objAsset;
            
            Core_IPS_Environment_Variables__c objEnvDetMaster= new Core_IPS_Environment_Variables__c();
            objEnvDetMaster.Name = 'Test Issue Resolution List1';
            objEnvDetMaster.Core_Answers__c = 'Intel';
            objEnvDetMaster.Core_Datatype__c = 'Text (255)';
            objEnvDetMaster.Core_Status__c = 'Active';
            objEnvDetMaster.Core_Product_Organization__c=objSupportedproduct.id;
            insert objEnvDetMaster;
            
            
            Core_IPS_Assigned_Environment_Variables__c objEnvVar= new Core_IPS_Assigned_Environment_Variables__c ();
            objEnvVar.Core_Status__c = 'Active';
            objEnvVar.Core_Supported_Product__c=objSuppProduct.id;
            objEnvVar.Core_Environment_Variable__c=objEnvDetMaster.id;
            insert objEnvVar;
            
            
            RestRequest requestObj = new RestRequest();
            requestObj = (RestRequest)System.jSON.deserialize('{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}', RestRequest.class);
           
           // List<Core_IPS_Assigned_Environment_Variables__c > lstEnvVariables=[select Core_Supported_Product__r.Name from Core_IPS_Assigned_Environment_Variables__c  where Core_Environment_Variable__r.name= 'Test Issue Resolution List1'];//list of environment details operational   
            List<Asset> objAssetId = [Select Id,Core_Supported_Product__c FROM Asset Where Name = 'HP Intel Product Asset'];
            requestObj.resourcePath ='/services/apexrest/v1.0/products/'+objAssetId[0].id+'/environmentdetails';  
            requestObj.requestUri ='/v1.0/products/'+objAssetId[0].id+'/environmentdetails'; 
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;     
            Core_RestAPI_SPEnvDetailV1_Handler handler = new Core_RestAPI_SPEnvDetailV1_Handler( System.now(), 'Core_RestAPI_SPEnvDetailsV1 '); 
            Core_RestAPI_Response finalResponse = null;
            System.assertEquals(null, finalResponse);
            handler.response.successContent = null;
            Boolean exceptionThrown = true;
            try{
                finalResponse = handler.getEnvironmentDetails();    
            }catch(Exception e){
                exceptionThrown = false;  
            }
            //lstEnvVariables = null;
            objAssetId= null;
            finalResponse = handler.getEnvironmentDetails();
            System.assertNotEquals(null, finalResponse);
            System.assertEquals(true, exceptionThrown);  
        }
    
    // tests the positive cases for the method doValidations.
    @isTest
    public static void test_doValidations_Positive(){
            Core_RestAPI_SPEnvDetailV1_Handler handler = new  Core_RestAPI_SPEnvDetailV1_Handler(System.now(),'Core_RestAPI_SPEnvDetailsV1');
            handler.doValidations();
    }
    //Testing the negative scenario for validation
    @isTest 
    public static void test_doValidations_Negative(){
            Boolean exceptionThrown = false;
            try{
                Core_RestAPI_SPEnvDetailV1_Handler handler = new Core_RestAPI_SPEnvDetailV1_Handler(System.now(),'Core_RestAPI_SPEnvDetailsV1'); 
                handler.doValidations();
            }catch(Exception e){
                exceptionThrown = false;   
            }        
            System.assertEquals(false, exceptionThrown);        
    }
}