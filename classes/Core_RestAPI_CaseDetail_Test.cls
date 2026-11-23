/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseDetail_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/15/2017              This class is for testing the business use cases all the version of case detail apis
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_CaseDetail_Test {
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getDetail service
    private static Case caseObj = null;
    @testSetup public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 0;
            Integer noOfCommUsers = 1;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 2; 
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        //Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        Asset assetWithCategories = allAssets[0];
        Asset assetWithNoCategories = allAssets[1];
        
        
        System.debug(' Core_RestAPI_CaseDetail_Test \n Account '+[Select Name FROM Account]+'\n Contact '+[Select Name FROM Contact]);
        
        commUser1 = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        
        System.debug(' Core_RestAPI_CasesV1_Test User \n Comm User obj : '+commUser1+' \n adminUser User obj : '+adminUser);
        //Insert 5 cases for admin User & 5 cases for Community User
        System.runAs(adminUser){
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(10);
            for(Integer i =0;i<caseList.size()/2;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
            }
            for(Integer i =caseList.size()/2;i<caseList.size();i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
            }
            insert caseList;
            //Insert environment variables for the case
            List<Core_IPS_Environment_Details__c> envDet = Core_RestAPI_TestUtilities.getEnvironmentDetailResponses(5);
            System.debug(' envDet '+envDet);
            for(Integer i=0 ;i< envDet.size();i++){
                Core_IPS_Environment_Details__c env = envDet[i];
                env.Core_Case__c = caseList[i+5].id;
                System.debug('+++++++ ENV Details '+env.Core_Case__c);
            }
            insert envDet;
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
        System.debug(Json.serialize([Select Id, CaseNumber, assetId FROM Case ]));
        System.debug(Json.serialize([Select Id, Core_Case__c FROM Core_IPS_Environment_Details__c ]));
    }
    
    
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getCaseDetail_VersionRequest(String version,  String caseNbr){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            caseObj = [Select CaseNumber FROM Case where OwnerId =: commUser1.Id Limit 1];
            System.debug(' Test class caseObj '+caseNbr);
            request.requestUri ='/v1.0/cases/'+caseNbr; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+caseNbr;
        }
        return request;
    }
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doPatch_updateCase_VersionRequest(String version,  String caseNbr){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        System.debug(' Versoin '+version+' caseNbr '+caseNbr);
        request.httpMethod = 'PATCH';
        if(v1_0.equals(version)){
            //caseObj = [Select CaseNumber FROM Case where OwnerId =: commUser1.Id Limit 1];
            System.debug(' Test class caseObj '+caseNbr);
            request.requestUri ='/v1.0/cases/'+caseNbr; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+caseNbr;
        }
        return request;
    }
    
    
    private static void doGet_getDetail_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            //Assert all sharing cases are retrieved
            System.assertEquals(1, apiResponse.successContent.size(), 'Case Found');
        }
        
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
    
    private static void test_doPatch_updateCaseDetail_v1_0_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('201', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertNotEquals(null, apiResponse.successContent);
            //Assert all sharing cases are retrieved
            System.assertEquals(1, apiResponse.successContent.size(), 'Case Found');
        }
        
    }    
    
    //Test doGet method
    @isTest public static void test_doGet_getCaseDetail_v1_0_Positive(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_getInterestedParties_v1_0 as  '+commUser1);  
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        RestContext.request = doGet_getCaseDetail_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doGet();
            System.debug(' test_doGet_getInterestedParties_v1_0 test_doGet >>>> '+apiResponse); 
            doGet_getDetail_Asserts(apiResponse, null, v1_0);
        } 
        
        
    }
    
    //Test doGet method
    @isTest public static void test_doGet_getCaseDetail_v1_0_Negative(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        //Negative test case
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_getInterestedParties_v1_0 as  '+commUser1);  
        RestContext.request = doGet_getCaseDetail_VersionRequest(v1_0, 'invalidCasenumber');
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doGet();
            System.debug(' test_doGet_getInterestedParties_v1_0 test_doGet >>>> '+apiResponse); 
        } 
        
    }
    
    //Test doGet method
    @isTest public static void test_doPatch_updateCaseDetail_v1_0_Positive(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_updateCaseDetail_v1_0_Positive as  '+commUser1);  
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        List<Core_IPS_Product_Issue_Category__c> catgList = [SELECT Name, ID, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c  FROM Core_IPS_Product_Issue_Category__c ];
        Core_IPS_Product_Issue_Category__c catgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Category' LIMIT 1];
        Core_IPS_Product_Issue_Category__c subCatgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Subcategory' LIMIT 1];
        
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        System.debug(' test_doPatch_updateCaseDetail_v1_0_Positive Case Obj '+caseObj);
        RestContext.request = doPatch_updateCase_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Case_UpdateV1_Wrapper caseDetail = new Core_RestAPI_Case_UpdateV1_Wrapper();
            caseDetail.severityReason = null;
            caseDetail.endCustomer = '';
            caseDetail.customerReferenceId = '';
            caseDetail.caseType = 'Question';
            caseDetail.subject = 'Case create api testing';
            caseDetail.caseSeverity = 'Low';
            caseDetail.caseDescription = 'Demo';
            caseDetail.caseCategoryId = catgName.Name;
            caseDetail.subCategoryId = subCatgName.Name;
            caseDetail.envDetails = null;
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doPatch(caseDetail);
            test_doPatch_updateCaseDetail_v1_0_Asserts(apiResponse, null, v1_0);
        } 
        
        
    }
    
    
    @isTest public static void test_doPatch_updateCaseDetail_v1_0_Negative(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_updateCaseDetail_v1_0_Positive as  '+commUser1);  
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        List<Core_IPS_Product_Issue_Category__c> catgList = [SELECT Name, ID, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c  FROM Core_IPS_Product_Issue_Category__c ];
        Core_IPS_Product_Issue_Category__c catgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Category' LIMIT 1];
        Core_IPS_Product_Issue_Category__c subCatgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Subcategory' LIMIT 1];
        
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        RestContext.request = doPatch_updateCase_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Case_UpdateV1_Wrapper caseDetail = new Core_RestAPI_Case_UpdateV1_Wrapper();
            caseDetail.severityReason = null;
            caseDetail.endCustomer = '';
            caseDetail.customerReferenceId = '';
            caseDetail.caseType = 'Question';
            caseDetail.subject = 'Case create api testing';
            caseDetail.caseSeverity = 'Low';
            caseDetail.caseDescription = 'Demo';
            caseDetail.caseCategoryId = catgName.Name;
            caseDetail.subCategoryId = subCatgName.Name;
            caseDetail.envDetails = null;
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doPatch(caseDetail);
            System.debug(' test_doGet_getInterestedParties_v1_0 test_doGet >>>> '+apiResponse); 
            test_doPatch_updateCaseDetail_v1_0_Asserts(apiResponse, null, v1_0);
        } 
        
        System.runAs(commUser1){
            Core_RestAPI_Case_UpdateV1_Wrapper caseDetail = new Core_RestAPI_Case_UpdateV1_Wrapper();
            caseDetail.severityReason = null;
            caseDetail.endCustomer = '';
            caseDetail.customerReferenceId = '';
            caseDetail.status = 'Closed';
            caseDetail.caseType = 'Question';
            caseDetail.subject = 'Case create api testing';
            caseDetail.caseSeverity = 'Low';
            caseDetail.caseDescription = 'Demo';
            caseDetail.caseCategoryId = catgName.Name;
            caseDetail.subCategoryId = subCatgName.Name;
            caseDetail.envDetails = null;
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doPatch(caseDetail);
            System.debug(' test_doGet_getInterestedParties_v1_0 test_doGet >>>> '+apiResponse); 
            test_doPatch_updateCaseDetail_v1_0_Asserts(apiResponse, null, v1_0);
        } 
        
    }


	//Test doGet method
    @isTest public static void test_doPatch_CaseCloseDetail_v1_0_Positive(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_updateCaseDetail_v1_0_Positive as  '+commUser1);  
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        List<Core_IPS_Product_Issue_Category__c> catgList = [SELECT Name, ID, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c  FROM Core_IPS_Product_Issue_Category__c ];
        Core_IPS_Product_Issue_Category__c catgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Category' LIMIT 1];
        Core_IPS_Product_Issue_Category__c subCatgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Subcategory' LIMIT 1];
        
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        System.debug(' test_doPatch_updateCaseDetail_v1_0_Positive Case Obj '+caseObj);
        RestContext.request = doPatch_updateCase_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Case_UpdateV1_Wrapper caseDetail = new Core_RestAPI_Case_UpdateV1_Wrapper();
            caseDetail.status = 'Closed';
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doPatch(caseDetail);
            test_doPatch_updateCaseDetail_v1_0_Asserts(apiResponse, null, v1_0);
        } 
        
        
    }
    
    //Test doGet method
    @isTest public static void test_doPatch_CaseCloseDetail_v1_0_Negative(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_updateCaseDetail_v1_0_Positive as  '+commUser1);  
        List<Asset> allAssets = [Select Name, Account.Name, Core_Supported_Product__c, Core_Supported_Product__r.Name FROM Asset ORDER BY NAME ];
        List<Core_IPS_Product_Issue_Category__c> catgList = [SELECT Name, ID, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c  FROM Core_IPS_Product_Issue_Category__c ];
        Core_IPS_Product_Issue_Category__c catgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Category' LIMIT 1];
        Core_IPS_Product_Issue_Category__c subCatgName = [SELECT Name, ID  FROM Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case Subcategory' LIMIT 1];
        
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        System.debug(' test_doPatch_updateCaseDetail_v1_0_Positive Case Obj '+caseObj);
        RestContext.request = doPatch_updateCase_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Case_UpdateV1_Wrapper caseDetail = new Core_RestAPI_Case_UpdateV1_Wrapper();
            caseDetail.status = 'Open';
            caseDetail.subject = 'Case create api testing';
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseDetailV1.doPatch(caseDetail);
            test_doPatch_updateCaseDetail_v1_0_Asserts(apiResponse, null, v1_0);
        } 
    }

    
}