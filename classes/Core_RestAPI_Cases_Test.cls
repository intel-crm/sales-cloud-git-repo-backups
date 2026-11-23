/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Cases_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing the business use cases. This single will take care of testing all the versions of cases API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_Cases_Test {
    
    private static final String v1_0 = 'v1.0';
    private static final String v2_0 = 'v2.0';
    private static User commUser1  = null;
    private static User commUser2  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getDetail service
    private static Case caseObj = null;
    
    //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 1;
            Integer noOfCommUsers = 3;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 2; //Not needed for this testing
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        List<User> allCommUsers = [Select Name, ContactId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        Asset assetWithCategories = allAssets[0];
        Asset assetWithNoCategories = allAssets[1];
        
        
        commUser1 = allCommUsers[0];
        commUser2 = allCommUsers[1];
        
        
        System.runAs(adminUser){
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(25);
            //Assign 5 cases for admin User with blank contact id
            for(Integer i = 0;i<5;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.ContactId = null;
            }
            //Assign 5 cases for nonIPs Contact
            for(Integer i =5;i<10;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.ContactId = nonIpsContact.id;
                c.AccountId = allAccounts[0].id;
            }
            //Assign 5 cases CommUser1 with the user contact Id
            for(Integer i =10;i<15;i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
                c.ContactId = commUser1.ContactId;
                c.AccountId = allAccounts[0].id;
            }
            //Assign 5 cases for commUser1 with the another contact Id
            for(Integer i = 15;i<20;i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
                c.ContactId = nonIpsContact.Id;
                c.AccountId = allAccounts[0].id;
            }
            
            //Assign 5 cases for commUser2
            for(Integer i = 20;i<25;i++){
                Case c = caseList[i];
                c.OwnerId = commUser2.Id;
                c.AccountId = allAccounts[0].id;
            }
             //Added by Sowmya -Start - 10/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
    		for(Integer i = 0;i<5;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.ContactId = commUser1.ContactId;
                c.Status = 'New';
                c.AssetId = assetWithCategories.Id;
                c.Core_IPS_Customer_Visible__c = True;
            }
 			//Sowmya -End - 10/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
    
            insert caseList;
            
            
            
            //Insert environment variables for the case
            List<Core_IPS_Environment_Details__c> envDet = Core_RestAPI_TestUtilities.getEnvironmentDetailResponses(5);
            for(Integer i=0 ;i< envDet.size();i++){
                Core_IPS_Environment_Details__c env = envDet[i];
                env.Core_Case__c = caseList[i+5].id;
            }
            insert envDet;
            //TODO remove the below for loop
            for(Case c: [Select Id, Account.Name, Contact.Name, Owner.Name, Core_IPSPortal_Check__c from Case]){
            }
            
        }
        
        //Insert master categories Data 
        List<Core_IPS_Master_Issue_Category__c> masterSubCatList = new List<Core_IPS_Master_Issue_Category__c>();
        Core_IPS_Master_Issue_Category__c masterSubCat = new Core_IPS_Master_Issue_Category__c();
        
        Core_IPS_Master_Issue_Category__c masterCat = new Core_IPS_Master_Issue_Category__c();
        masterCat.Name = 'XDemo_IP-Interface Protocols';
        masterCat.Core_Description__c = 'Demo_IP-Interface Protocols';
        masterCat.Core_Status__c = 'Active';
        masterCat.Core_Type__c = 'Case Category';
        insert masterCat;
        
        masterSubCat = new Core_IPS_Master_Issue_Category__c();
        masterSubCat.Name = 'Xdemo_100G Ethernet';
        masterSubCat.Core_Description__c = '100G Ethernet';
        masterSubCat.Core_Status__c = 'Active';
        masterSubCat.Core_Type__c = 'Case Subcategory';
        masterSubCat.Core_Master_Issue_Category__c = masterCat.id;
        masterSubCatList.add(masterSubCat);
        
        masterSubCat = new Core_IPS_Master_Issue_Category__c();
        masterSubCat.Name = 'Xdemo_10G Ethernet';
        masterSubCat.Core_Description__c = '10G Ethernet';
        masterSubCat.Core_Status__c = 'Active';
        masterSubCat.Core_Type__c = 'Case Subcategory';
        masterSubCat.Core_Master_Issue_Category__c = masterCat.id;
        masterSubCatList.add(masterSubCat);        
        insert masterSubCatList;
        
        //Insert categories 
        Core_IPS_Product_Issue_Category__c prodParentCategory = new Core_IPS_Product_Issue_Category__c();
        prodParentCategory.Core_Supported_Product__c = assetWithCategories.Core_Supported_Product__c;
        prodParentCategory.Core_Type__c = 'Case Category';
        prodParentCategory.Core_Status__c = 'Active';
        prodParentCategory.Core_Issue_Category_Name__c = masterCat.id;
        insert prodParentCategory;
        
        List<Core_IPS_Product_Issue_Category__c> prodChildCategories = new List<Core_IPS_Product_Issue_Category__c>();
        Core_IPS_Product_Issue_Category__c prodChildCategory = new Core_IPS_Product_Issue_Category__c();
        prodChildCategory.Core_Supported_Product__c = assetWithCategories.Core_Supported_Product__c;   
        prodChildCategory.Core_Type__c = 'Case Subcategory';
        prodChildCategory.Core_Status__c = 'Active';
        prodChildCategory.Core_Issue_Sub_Category_Name__c = masterSubCatList[0].id;
        prodChildCategory.Core_Product_Issue_Category__c = prodParentCategory.Id;
        prodChildCategories.add(prodChildCategory);
        
        prodChildCategory = new Core_IPS_Product_Issue_Category__c();
        prodChildCategory.Core_Supported_Product__c = assetWithCategories.Core_Supported_Product__c;   
        prodChildCategory.Core_Type__c = 'Case Subcategory';
        prodChildCategory.Core_Status__c = 'Active';
        prodChildCategory.Core_Issue_Sub_Category_Name__c = masterSubCatList[1].id;
        prodChildCategory.Core_Product_Issue_Category__c = prodParentCategory.Id;
        prodChildCategories.add(prodChildCategory);
        insert prodChildCategories;
        
        Test.stopTest();
    }
    
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getCases_VersionRequest(String version, boolean includeFilter){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            if(includeFilter == false)
                request.requestUri ='/v1.0/cases/'; 
            else 
			request.requestUri ='/v1.0/cases?v=mycases'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/';
     
        }/*else if(v2_0.equals(version)){
            if(includeFilter == false)
                request.requestUri ='/v2.0/cases/'; 
            else 
                request.requestUri ='/v2.0/cases?v=mycases'; 
            request.resourcePath ='/services/apexrest/v2.0/cases/';
        }*/
        return request;
    }
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doPost_CreateCases_VersionRequest(String version){
        //TODO Create a new template for POST request
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'POST';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/cases'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/';
        }/*else if(v2_0.equals(version)){
            request.requestUri ='/v1.0/cases'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/';
        }*/
        return request;
    }

    private static void doGet_getCases_Asserts_Positive(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            
             System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
            
            RestRequest request = RestContext.request;
			System.assertEquals(5, apiResponse.successContent.size(), 'All Community user cases retrieved ');
            
        }/*else If(strVersion == v2_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
            
            RestRequest request = RestContext.request;
            System.assertEquals(10, apiResponse.successContent.size(), 'All Community user cases retrieved ');
            
        }*/
        
        //Common Asserts for all versions
        //Verify the transaction log is created
        if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
            try{
                Core_RestAPI_Transaction_Entry__c log = [Select Id FROM Core_RestAPI_Transaction_Entry__c Limit 1];    
                System.assertNotEquals(null, log);
            }catch(Exception e){
                //Fail if log entry is not found when 
                System.assert(false);
            }
        }
    } 
    
    //This method is for asserting negative test cases    
    private static void doGet_getCases_Asserts_Negative(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
        }/*else If(strVersion == v2_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(false, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(0, apiResponse.successContent.size(), 'All Community user cases retrieved ');
            System.assertNotEquals(null, apiResponse.errorContent);
        }*/
        
        //Common Asserts for all versions
        //Verify the transaction log is created
        if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
            try{
                Core_RestAPI_Transaction_Entry__c log = [Select Id FROM Core_RestAPI_Transaction_Entry__c Limit 1];    
                System.assertNotEquals(null, log);
            }catch(Exception e){
                //Fail if log entry is not found when 
                System.assert(false);
            }
        }
    } 
    
    
    private static void doPost_CreateCase_Asserts_Positive(Core_RestAPI_Response apiResponse , String strVersion) {
        if(strVersion == v1_0) { 
            System.assertEquals('201', apiResponse.Code, ' RestAPIResponse Success code 201');
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertEquals(null, apiResponse.errorContent);
        }
    }
    
    private static void doPost_CreateCase_Asserts_Negative(Core_RestAPI_Response apiResponse, String strVersion) {
        if(strVersion == v1_0) { 
            System.assertEquals('201', apiResponse.Code, ' RestAPIResponse Success code 201');
            System.assertEquals(false, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.errorContent);
        }
    }
    
    /****************************************************************************************************************************************
* Test Method for GET CASES starts from here
*****************************************************************************************************************************************/
    
    //Test doGet method
    @isTest public static void test_doGet_getCases_v1_0(){
        RestContext.request = doGet_getCases_VersionRequest(v1_0, false);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV1.doGet();
            doGet_getCases_Asserts_Positive(apiResponse,null ,v1_0);
        }
        
        //Negative testing User has no casess and verify the user never gets other contacts cases from his account
        commUser3_NoCases  = [Select Name FROM User WHERE Name = 'CommUser2 RestApiUnitTest0'];
        System.runAs(commUser3_NoCases){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV1.doGet();
            doGet_getCases_Asserts_Negative(apiResponse, null , v1_0);
        } 
    }
    
    
    //This method is for testing the filter for both positive and negative test cases
    @isTest public static void test_doGet_getCases_WithFilter_v1_0(){
        RestContext.request = doGet_getCases_VersionRequest(v1_0, true);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        
        RestContext.request.requestUri ='/v1.0/cases?v=mycases'; 
        Map<String,String> params1 = new Map<String,String>();
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV1.doGet();
            doGet_getCases_Asserts_Positive(apiResponse, null ,v1_0);
        } 
        
    } 
    
    
    //Test doGet method for version 2 API
    /*
    @isTest public static void test_doGet_getCases_v2_0(){
        RestContext.request = doGet_getCases_VersionRequest(v2_0, false);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV2.doGet();
            doGet_getCases_Asserts_Positive(apiResponse,null ,v2_0);
        }  
    } */
    
    /****************************************************************************************************************************************
* Test Method for CREATE CASE (POST) starts from here
*****************************************************************************************************************************************/
    
    @isTest public static void test_doPost_CreateCase_V1_0_Negative(){
        RestContext.request = doPost_CreateCases_VersionRequest(v1_0);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        
        Core_RestAPI_Case_CreateV1_Wrapper caseDetail = new Core_RestAPI_Case_CreateV1_Wrapper();
        caseDetail.severityReason = null;
        caseDetail.intelProductId = allAssets[0].Id;
        caseDetail.endCustomer = '';
        caseDetail.customerReferenceId = '';
        caseDetail.caseType = 'Question';
        caseDetail.subject = 'Case create api testing';
        caseDetail.caseSeverity = 'Low';
        caseDetail.caseDescription = 'Demo';
        caseDetail.caseCategoryId = 'IC-00017641';
        caseDetail.subCategoryId = 'IC-00017648';
        caseDetail.envDetails = null;
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV1.doPost(caseDetail);
            doPost_CreateCase_Asserts_Negative(apiResponse, v1_0);
        }
        
    }
    
    @isTest public static void test_doPost_CreateCase_V1_0_Positive(){
        

        
        RestContext.request = doPost_CreateCases_VersionRequest(v1_0);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        List<Core_IPS_Product_Issue_Category__c> catgList = [SELECT Name, ID, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c  FROM Core_IPS_Product_Issue_Category__c ];
        Core_IPS_Product_Issue_Category__c catgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Category' LIMIT 1];
        Core_IPS_Product_Issue_Category__c subCatgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Subcategory' LIMIT 1];
        
        Core_RestAPI_Case_CreateV1_Wrapper caseDetail = new Core_RestAPI_Case_CreateV1_Wrapper();
        caseDetail.severityReason = null;
        caseDetail.intelProductId = allAssets[0].Id;
        caseDetail.endCustomer = '';
        caseDetail.customerReferenceId = '';
        caseDetail.caseType = 'Question';
        caseDetail.subject = 'Case create api testing';
        caseDetail.caseSeverity = 'Low';
        caseDetail.caseDescription = 'Demo';
        caseDetail.caseCategoryId = catgName.Name;
        caseDetail.subCategoryId = subCatgName.Name;
        caseDetail.envDetails = null;
      	System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CasesV1.doPost(caseDetail);
            
            doPost_CreateCase_Asserts_Positive(apiResponse, v1_0);
        }
        
    }
    
    
}