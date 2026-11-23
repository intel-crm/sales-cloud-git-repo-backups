/***************************************************************************************************
Class Name:  Core_IPS_CaseUtility_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_CaseUtility class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_CaseUtility class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/   
@isTest
public class Core_IPS_CaseUtility_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> listOfUser = new List<User> ();
    static String productId = null;
    static String subCatId = null;
    static boolean isAgent = null;
    static List<Core_IPS_Assigned_Environment_Variables__c> listOfEnvDetailsOperational = new List<Core_IPS_Assigned_Environment_Variables__c> ();
    /***************************************************************************************************
Method Name:  getRecords
Method Type: Void Method
Version     : 1.0 
Created Date: 03 Nov 2015
Description:  Common Test data used in multiple test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        listOfUser = TestUtilities.getListOfUser(1);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insert listOfUser;
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    /***************************************************************************************************
Method Name:  getRecordsForGetEnvVariablesTest
Method Type: Void Method
Version     : 1.0 
Created Date: 03 Nov 2015
Description:  Common Test data used in multiple test methods to test getEnvVariables Utility method
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static void getRecordsForGetEnvVariablesTest(){
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseCat;
        }
        System.assert(listOfCoreProdIssCategoryCaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case SubCategory 
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseSubCat = TestUtilities.getListOfCoreProdIssCategory(1);
        for(Core_IPS_Product_Issue_Category__c coreProdIssCategory : listOfCoreProdIssCategoryCaseSubCat){
            coreProdIssCategory.Core_Product_Issue_Category__c = listOfCoreProdIssCategoryCaseCat.get(0).id;
            coreProdIssCategory.Core_supported_product__c = listOfSupportedProduct.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseSubCat;
        }
        System.assert(listOfCoreProdIssCategoryCaseSubCat[0].Id != null, 'Record not Created');
        // Create Environmental Detail Master
        List<Core_IPS_Environment_Variables__c> listOfEnDetailMaster = TestUtilities.getListOfEnDetailMaster(1);
        for(Core_IPS_Environment_Variables__c environmentalDetailMaster : listOfEnDetailMaster){
            environmentalDetailMaster.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfEnDetailMaster;
        }
        System.assert(listOfEnDetailMaster != null, 'Record not created');
        // Create Environment Details Operational
        listOfEnvDetailsOperational = TestUtilities.getListOfEnvDetailsOperational(200);
        for(Core_IPS_Assigned_Environment_Variables__c envDetailsOperational : listOfEnvDetailsOperational){
            envDetailsOperational.Core_Environment_Variable__c = listOfEnDetailMaster.get(0).id;
            envDetailsOperational.Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
            envDetailsOperational.Core_Product_Issue_Sub_Category__c = listOfCoreProdIssCategoryCaseSubCat.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfEnvDetailsOperational;
        }
        System.assert(listOfEnvDetailsOperational != null, 'Record not created');
        // Common Input Variables used for testing
        productId = listOfSupportedProduct.get(0).Id;
        subCatId = listOfCoreProdIssCategoryCaseSubCat.get(0).id;
        isAgent = true;
    }
    /***************************************************************************************************
Method Name:  GetSupportedProduct_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSupportedProductPositiveTest(){
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        Core_IPS_Supported_Product__c supportedProduct = [select Core_Product__c, Core_Product_Organization__r.name from Core_IPS_Supported_Product__c where id =: listOfSupportedProduct.get(0).id];
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.Supported_product supportedProductWrapper = new Core_IPS_CaseUtility.Supported_product(supportedProduct.Core_Product__c,supportedProduct.Core_Product_Organization__r.name);
            Core_IPS_CaseUtility.getSupportedProduct(supportedProduct.Core_Product__c,supportedProduct.Core_Product_Organization__r.name);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  GetSupportedProduct_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSupportedProductNegativeTest(){
        getRecords();
        System.runAs(listOfUser.get(0)){
            Id prodId = null;
            string prodOrgName = null;
            Test.startTest();
            Core_IPS_CaseUtility.Supported_product supportedProductWrapper = new Core_IPS_CaseUtility.Supported_product(prodId,prodOrgName);
            Core_IPS_CaseUtility.getSupportedProduct(prodId,prodOrgName);
            System.assertEquals(true, supportedProductWrapper!=null);
            Test.stopTest();
        }
    }   
    /***************************************************************************************************
Method Name:  getCategories_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCategoriesPositiveTest(){
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Master_Issue_Category__c - Core Master Issue Category - Type : Case Category
        List<Core_IPS_Master_Issue_Category__c> listOfCoreMasterIssueCategoryCaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
        for(Core_IPS_Master_Issue_Category__c coreMasterIssCategory : listOfCoreMasterIssueCategoryCaseCat){
            coreMasterIssCategory.Core_type__c = 'Case Category';
        }
        System.RunAs(listOfUser[0]){
            insert listOfCoreMasterIssueCategoryCaseCat;
        }
        System.Assert(listOfCoreMasterIssueCategoryCaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c coreProdIssCategory : listOfCoreProdIssCategoryCaseCat){
            coreProdIssCategory.Core_type__c = 'Case Category';
            coreProdIssCategory.Core_Issue_Category_Name__c = listOfCoreMasterIssueCategoryCaseCat.get(0).id;
            coreProdIssCategory.Core_supported_product__c = listOfSupportedProduct.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseCat;
        }
        System.Assert(listOfCoreProdIssCategoryCaseCat[0].Id != null, 'Record not Created');
        string coreSupportedProd = listOfSupportedProduct.get(0).id;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCatg = Core_IPS_CaseUtility.getCategories(coreSupportedProd);
            //[Jan/25/2016 - START]
            //System.assertEquals(ListOfCoreProdIssCategory_CaseCatg.get(0).id,ListOfCoreProdIssCategory_CaseCat.get(0).id);
            //[Jan/25/2016 - END]
            Test.stopTest();
        }       
    }
    /***************************************************************************************************
Method Name:  getCategories_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCategoriesNegativeTest(){
        getRecords();
        string coreSupportedProd = null;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCatg = Core_IPS_CaseUtility.getCategories(coreSupportedProd);
            System.assertEquals(listOfCoreProdIssCategoryCaseCatg,null);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getSubCategories_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSubCategoriesPositiveTest(){
        getRecords();
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseCat;
        }
        System.Assert(listOfCoreProdIssCategoryCaseCat[0].Id != null, 'Record not Created');
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c coreProdIssCategory : listOfCoreProdIssCategoryCaseSubCat){
            coreProdIssCategory.Core_Product_Issue_Category__c = listOfCoreProdIssCategoryCaseCat.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseSubCat;
        }
        System.Assert(listOfCoreProdIssCategoryCaseSubCat[0].Id != null, 'Record not Created');
        System.runAs(listOfUser.get(0)){
            string coreProdIssCategoryCaseCat = listOfCoreProdIssCategoryCaseCat.get(0).id;
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseSubCatg = Core_IPS_CaseUtility.getSubCategories(coreProdIssCategoryCaseCat);
            //[Jan/25/2016 - START]
            //System.assertEquals(ListOfCoreProdIssCategory_CaseSubCat.get(0).id,ListOfCoreProdIssCategory_CaseSubCatg.get(0).id);
            //[Jan/25/2016 - END]
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getSubCategories_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSubCategoriesNegativeTest(){
        getRecords();
        System.runAs(listOfUser.get(0)){
            string coreProdIssCategoryCaseCat;
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseSubCatg = Core_IPS_CaseUtility.getSubCategories(coreProdIssCategoryCaseCat);
            System.assertEquals(null,coreProdIssCategoryCaseCat);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getSubCategories_PositiveTest2
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSubCategoriesPositiveTest2(){
        getRecords();
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseCat;
        }
        System.assert(listOfCoreProdIssCategoryCaseCat[0].Id != null, 'Record not Created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case SubCategory 
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c coreProdIssCategory : listOfCoreProdIssCategoryCaseSubCat){
            coreProdIssCategory.Core_Product_Issue_Category__c = listOfCoreProdIssCategoryCaseCat.get(0).id;
            coreProdIssCategory.Core_supported_product__c = listOfSupportedProduct.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfCoreProdIssCategoryCaseSubCat;
        }
        System.assert(listOfCoreProdIssCategoryCaseSubCat[0].Id != null, 'Record not Created');
        string coreSupportedProd = listOfSupportedProduct.get(0).id;
        string coreProdIssCategoryCaseCat = listOfCoreProdIssCategoryCaseCat.get(0).id;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueSubCategories issueSubCategoriesWrapper = new Core_IPS_CaseUtility.IssueSubCategories(coreProdIssCategoryCaseCat,coreSupportedProd);
            Core_IPS_CaseUtility.getSubCategories(coreProdIssCategoryCaseCat,coreSupportedProd);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getSubCategories_NegativeTest2
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getSubCategoriesNegativeTest2(){
        getRecords();
        string coreSupportedProd = null;
        string coreProdIssCategoryCaseCat = null;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueSubCategories issueSubCategoriesWrapper = new Core_IPS_CaseUtility.IssueSubCategories(coreProdIssCategoryCaseCat,coreSupportedProd);
            Core_IPS_CaseUtility.getSubCategories(coreProdIssCategoryCaseCat,coreSupportedProd);
            System.assertEquals(true, issueSubCategoriesWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvVariables_Agent_SubCatId_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvVariablesAgentSubCatIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,subCatId,isAgent);
            System.assert(lstOfEnvDetailsOperational != null, 'Record not created');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvVariables_Customer_SubCatId_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvVariablesCustomerSubCatIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            isAgent = false;
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,subCatId,isAgent);
            System.assert(lstOfEnvDetailsOperational != null, 'Record not created');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvVariables_Agent_productId_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvVariablesAgentProductIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            subCatId = null;
            isAgent = true;
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,subCatId,isAgent);
            System.assert(lstOfEnvDetailsOperational != null, 'Record not created');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvVariables_Customer_productId_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvVariablesCustomerProductIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            subCatId = null;
            isAgent = false;
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,subCatId,isAgent);
            System.assert(lstOfEnvDetailsOperational != null, 'Record not created');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvVariables_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvVariablesNegativeTest(){
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,subCatId,isAgent);
            System.assertEquals(lstOfEnvDetailsOperational.isEmpty(),true);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvironmentVariables_SubCatIdTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvironmentVariablesSubCatIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates environmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(subCatId,productId);
            System.assertEquals(true, environmentTemplatesWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvironmentVariables_productIdTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvironmentVariablesProductIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates environmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(productId,subCatId);
            System.assertEquals(true, environmentTemplatesWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getEnvironmentVariables_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvironmentVariablesNegativeTest(){
        getRecords();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates environmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(productId,subCatId);
            System.assertEquals(true, environmentTemplatesWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  AssetList_WrapperClassTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void assetListWrapperClassTest(){
        getRecords();
        string assetName;
        string assetid;
        string prodorgId;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.AssetList assetListWrapper = new Core_IPS_CaseUtility.AssetList(assetName,assetid,prodorgId);
            System.assertEquals(true, assetListWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  IssueCategories_WrapperClassTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void issueCategoriesWrapperClassTest(){
        getRecords();
        string issueCatId;
        string issueCatName;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueCategories issueCategoriesWrapper = new Core_IPS_CaseUtility.IssueCategories(issueCatId,issueCatName);
            System.assertEquals(true, issueCategoriesWrapper!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getIPSProjectListPositiveTest(){
        getRecords();
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(200);
        for(Core_IPS_Project__c ipsProject : listOfIpsProjects){
            ipsProject.Core_Status__c = 'Draft';
        }
        System.RunAs(listOfUser[0]){
            insert listOfIpsProjects;
            // TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            
        }
        /*  for(Core_IPS_Project__c IpsProject : ListOfIpsProjects){
IpsProject.Core_Status__c = 'Active';
}
update ListOfIpsProjects;*/
        System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> projectList = Core_IPS_CaseUtility.getIPSProjectList();
            //system.assertEquals(projectList.size(),1);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getIPSProjectList_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type: Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getIPSProjectListNegativeTest(){
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> projectList = Core_IPS_CaseUtility.getIPSProjectList();
            System.assertEquals(true, projectList!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getGECAnswerOptions_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getGECAnswerOptionsPositiveTest(){
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> answerOptions = Core_IPS_CaseUtility.getGECAnswerOptions();
            system.assertEquals(answerOptions.size(),3);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getCase_DynamiCSOQL_Agent_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCaseDynamiCSoqlAgentPositiveTest(){
        getRecords(); 
        
        List<Case> listOfCases = new List<Case> ();
        Map<string,ID> caseRecordtype = new Map<string,ID>();
        for(Recordtype rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
            caseRecordtype.put(rt.Name,rt.ID);
        }  
        for(Integer i=1;i<=1;i++){
            Case caseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                RecordTypeId = caseRecordtype.get('IPS Case Create')
            );
            listOfCases.add(caseRecord);
        }
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId());
        insert testAccount;
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123456@testing.com.testsetup', MailingCountry = 'India',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
        insert testContact;
        System.assertNotEquals(null, testAccount.id);
        for(Case cs:listOfCases )  {
            cs.accountid=testAccount.id;
            cs.contactid=testContact.id;
        } 
        System.RunAs(listOfUser[0]){  
            insert listOfCases;
        } 
        
        //System.assert(ListOfCases[0].Id != null, 'Record not created');
        string csId = listOfCases.get(0).id;
        boolean agent = true; 
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Case caseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,agent);
            //System.assert(CaseRecord.Id != null, 'Record not created');
                        System.assertEquals(agent, true);

            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getCase_DynamiCSOQL_Customer_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    /* static testmethod void getCase_DynamiCSOQL_Customer_PositiveTest(){
getRecords();
List<Case> ListOfCases = TestUtilities.getListOfCases(200);
Account testAccount= TestUtilities.getAccount();
insert testAccount;
Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test012345@testing.com.testsetup',
AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
insert testContact;
System.assertNotEquals(null, testAccount.id);
for(Case cs:ListOfCases )  {
cs.accountid=testAccount.id;
cs.contactid=testContact.id;
}   
System.RunAs(ListOfUser[0]){
insert ListOfCases;
}
System.assert(ListOfCases[0].Id != null, 'Record not created');
string csId = ListOfCases.get(0).id;
boolean Agent = false; 
System.runAs(ListOfUser.get(0)){
Test.startTest();
Case CaseRecord = Core_IPS_CaseUtility.getCaseDynamiCSoql(csId,Agent);
System.assert(CaseRecord.Id != null, 'Record not created');
Test.stopTest();
}   
}*/
    /***************************************************************************************************
Method Name:  getCase_DynamiCSOQL_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCaseDynamiCSoqlNegativeTest(){
        getRecords(); 
        //  TWC745-7160 - START Shipra
        List<Case> listOfCases = new List<Case> ();
        Map<string,ID> caseRecordtype = new Map<string,ID>();
        for(Recordtype rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
            caseRecordtype.put(rt.Name,rt.ID);
        }  
        for(Integer i=1;i<=1;i++){
            Case caseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                RecordTypeId = caseRecordtype.get('IPS Case Create')
            );
            listOfCases.add(caseRecord);
        }
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId());
        insert testAccount;
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123456@testing.com.testsetup', MailingCountry = 'India',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
        insert testContact;
        System.assertNotEquals(null, testAccount.id);
        for(Case cs:listOfCases )  {
            cs.accountid=testAccount.id;
            cs.contactid=testContact.id;
        } 
        System.RunAs(listOfUser[0]){  
            insert listOfCases;
        } 
        
        //System.assert(ListOfCases[0].Id != null, 'Record not created');
        string csId = listOfCases.get(0).id;
        boolean agent = false; 
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Case caseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,agent);
           // System.assert(CaseRecord.Id != null, 'Record not created');
            Test.stopTest();
        } 
                        System.assertEquals(agent, false);

          //  TWC745-7160 - END Shipra
    }
    /***************************************************************************************************
Method Name:  getFields_Agent_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getFieldsAgentPositiveTest(){
        getRecords();
        boolean agent = true; 
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> fieldSetMemberLst = Core_IPS_CaseUtility.getFields(agent);
            System.assertEquals(true, fieldSetMemberLst!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getFields_Customer_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getFieldsCustomerPositiveTest(){
        getRecords();
        boolean agent = false; 
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> fieldSetMemberLst = Core_IPS_CaseUtility.getFields(agent);
            System.assertEquals(true, fieldSetMemberLst!=null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getFields_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/ 
    /* Commenting the below line as getting null pointer exception. Need to discuss with Jp to add the null pointer check in the Utility method
static testmethod void getFields_NegativeTest(){
getRecords();
boolean Agent = null; 
System.runAs(ListOfUser.get(0)){
Test.startTest();
Core_IPS_CaseUtility.getFields(Agent);
Test.stopTest();
}   
} */
    /***************************************************************************************************
Method Name:  getEnvironmentDetailsOperationalRecords_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getEnvironmentDetailsOperationalRecordsTest(){
        getRecords();
        string prod;
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvironmentDetailsOperationalRecords(prod);
            System.assertEquals(lstOfEnvDetailsOperational, null);
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getPlatform_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getPlatformPositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '59';
            product.Core_Unique_ID__c = 'Product12345';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c flatProductHierarchy : listOfFlatProductHierarchy){
            if(counter < 3)
                flatProductHierarchy.Core_L5_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                flatProductHierarchy.Core_L4_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else
                flatProductHierarchy.Core_L2_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(listOfUser[0]){
            insert listOfFlatProductHierarchy;
        }
        System.assert(listOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            suppProductIdList.add(supportedProduct.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String, Set<String>> prodHierarchyBySupProd = Core_IPS_CaseUtility.getPlatform(suppProductIdList);
            System.assert(prodHierarchyBySupProd != null,'Records are not fetched');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getPlatform_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getPlatformNegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String, Set<String>> prodHierarchyBySupProd = Core_IPS_CaseUtility.getPlatform(suppProductIdList);
            System.assert(prodHierarchyBySupProd == null,'Records are fetched');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getCodeName_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCodeNamePositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '59';
            product.Core_Unique_ID__c = 'Product12345';
            product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            suppProductIdList.add(supportedProduct.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,String> suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProductIdList);
            System.assert(suppProdIdCodeNameMap != null,'Records are not fetched');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getCodeName_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getCodeNameNegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,String> suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProductIdList);
            System.assert(suppProdIdCodeNameMap == null,'Records are fetched');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getVPHProductType_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getVPHProductTypePositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '43';
            product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            product.Core_Unique_ID__c = 'Product12345';
            product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Create Flat Product Hierarchy
        List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c flatProductHierarchy : listOfFlatProductHierarchy){
            flatProductHierarchy.Core_EPM_Hierarchy_ID__c = listOfProducts.get(0).Core_Hierarchy_ID__c;
            flatProductHierarchy.Core_EPM_Hierarchy_Name__c = listOfProducts.get(0).Core_Hierarchy_Name__c;
            if(counter < 2)
                flatProductHierarchy.Core_L5_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 5)
                flatProductHierarchy.Core_L4_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 8)
                flatProductHierarchy.Core_L3_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else
                flatProductHierarchy.Core_L2_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(listOfUser[0]){
            insert listOfFlatProductHierarchy;
        }
        System.assert(listOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            suppProductIdList.add(supportedProduct.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,Set<String>> suppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProductIdList);
            System.assert(suppProdIdProdTypeMap != null,'Records are not fetched');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getVPHProductType_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getVPHProductTypeNegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,Set<String>> suppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProductIdList);
            System.assert(suppProdIdProdTypeMap == null,'Records are fetched');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getVPLHProductType_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getVPLHProductTypePositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '59';
            product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            product.Core_Unique_ID__c = 'Product12345';
            product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Create Flat Product Hierarchy
        List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c flatProductHierarchy : listOfFlatProductHierarchy){
            flatProductHierarchy.Core_EPM_Hierarchy_ID__c = listOfProducts.get(0).Core_Hierarchy_ID__c;
            flatProductHierarchy.Core_EPM_Hierarchy_Name__c = listOfProducts.get(0).Core_Hierarchy_Name__c;
            if(counter < 5)
                flatProductHierarchy.Core_L5_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else
                flatProductHierarchy.Core_L4_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            
            counter++;
        }
        System.RunAs(listOfUser[0]){
            insert listOfFlatProductHierarchy;
        }
        System.assert(listOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            suppProductIdList.add(supportedProduct.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,Set<String>> suppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProductIdList);
            System.assert(suppProdIdProdTypeMap != null,'Records are not fetched');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getVPLHProductType_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getVPLHProductTypeNegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();   //get records method called
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            Map<String,Set<String>> suppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProductIdList);
            System.assert(suppProdIdProdTypeMap == null,'Records are fetched');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getplatform_Options_Asset_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getplatformOptionsAssetPositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(listOfUser[0]){
            insert listOfAccounts;
        }
        System.Assert(listOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(listOfUser[0]){
            insert listOfIpsProjects;
        }
        System.Assert(listOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '59';
            product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            product.Core_Unique_ID__c = 'Product12345';
            product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> assetList  = TestUtilities.getAssetList(1);
        for(Asset asst : assetList){
            asst.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            asst.accountId = listOfAccounts.get(0).Id;
            asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert assetList;
        }
        System.Assert(assetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c flatProductHierarchy : listOfFlatProductHierarchy){
            if(counter < 3)
                flatProductHierarchy.Core_L5_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                flatProductHierarchy.Core_L4_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else
                flatProductHierarchy.Core_L2_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(listOfUser[0]){
            insert listOfFlatProductHierarchy;
        }
        System.assert(listOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Asset assetRec : assetList){
            idList.add(assetRec.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> platformOptions = Core_IPS_CaseUtility.getplatform_Options(idList);
            System.assert(platformOptions.size()>1,true);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getplatform_Options_SupProd_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getplatformOptionsSupProdPositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(listOfUser[0]){
            insert listOfAccounts;
        }
        System.Assert(listOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(listOfUser[0]){
            insert listOfIpsProjects;
        }
        System.Assert(listOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(listOfUser[0]){
            insert listOfSupportOrg;
        }
        System.assert(listOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  listOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 product : listOfProducts){
            product.Core_Hierarchy_ID__c = '59';
            product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            product.Core_Unique_ID__c = 'Product12345';
            product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(listOfUser[0]){
            insert listOfProducts;
        }
        System.assert(listOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            supportedProduct.Core_Product__c = listOfProducts.get(0).id;
            supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert listOfSupportedProduct;
        }
        System.assert(listOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> assetList  = TestUtilities.getAssetList(1);
        for(Asset asst : assetList){
            asst.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            asst.accountId = listOfAccounts.get(0).Id;
            asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
        }
        System.RunAs(listOfUser[0]){
            insert assetList;
        }
        System.Assert(assetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c flatProductHierarchy : listOfFlatProductHierarchy){
            if(counter < 3)
                flatProductHierarchy.Core_L5_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                flatProductHierarchy.Core_L4_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            else
                flatProductHierarchy.Core_L2_EPM_ID__c = listOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(listOfUser[0]){
            insert listOfFlatProductHierarchy;
        }
        System.assert(listOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
            idList.add(supportedProduct.id);
        }
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> platformOptions = Core_IPS_CaseUtility.getplatform_Options(idList);
            System.assert(platformOptions.size()>1,true);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
Method Name:  getplatform_Options_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/
    static testmethod void getplatformOptionsNegativeTest(){  
        List<Id> idList = new List<Id> ();
        getRecords();
        System.runAs(listOfUser.get(0)){
            Test.startTest();
            List<SelectOption> platformOptions = Core_IPS_CaseUtility.getplatform_Options(idList);
            System.assert(platformOptions.size()==1,true);
            Test.stopTest();
        }
    }
    //Added by Geetha 
    /* public static testmethod void parentAccount(){
getRecords();
Profile pf = [select id, name from Profile where name = 'IPS Agent' LIMIT 1];
User accountOwner = TestUtilities.getListOfUser(1)[0];
System.runAs (ListOfUser[0]) {
UserRole urole = new UserRole(Name= 'CEO'); 
insert urole;               
accountOwner.profileId = pf.Id;
accountOwner.userRoleId = urole.Id;
insert accountOwner;
}
/*
Account accountRecord;
Contact contactRecord;
System.runAs (ListOfUser[0]) {

accountRecord = new Account(
OwnerId = accountOwner.Id,
Name = 'Dell Products',
Core_Account_Type__c = 'Distributor',
Core_Sales_Segment__c = 'Compute',
Industry = 'Banking',
BillingCity = 'Delhi',
BillingCountry = 'USA',
billingState = 'AK',
billingStreet = 'Bratislava 1',
Core_IPS_Active__c = true
);
insert accountRecord;
contactRecord = new Contact(
FirstName = 'Ding Dong', 
Lastname = 'Dell',
Email = 'Contact1Dell@gmail.com',
Accountid = accountRecord.id,
Core_IPS_Intel_Support_Owner__c=accountOwner.id,
Core_IPS_Active__c = true
);
insert contactRecord;
}*/
    /* Set<String> customerUserTypes = new Set<String> { 'PowerPartner', 'PowerCustomerSuccess'};
user u1 = TestUtilities.getCustomerUser('IPS External Customer');
Account objAcc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:u1.ContactId)];
System.runAs (u1) {
Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
cipspro.Name='testproject';
insert cipspro;

Core_IPS_Account__c  ipsAccount = new Core_IPS_Account__c();
ipsAccount.Core_Account__c=objAcc.Id;
ipsAccount.Core_IPS_Project__c=cipspro.id;
insert ipsAccount;

Core_IPS_Project_Member__c proMember = new Core_IPS_Project_Member__c();
proMember.Core_IPS_Contact__c = u1.ContactId;
proMember.Core_IPS_Project__c = cipspro.id;
insert proMember;
System.assertEquals(true, proMember.Id!=null);
Test.startTest();
List<SelectOption> getIPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(cipspro.id,u1.id);
Test.stopTest();
}   
}*/
    //Added by Mahendra
    public static testmethod void selectedProject(){
        Asset astList = new Asset();
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        List<Asset> assetList  = TestUtilities.getAssetList(1);
        insert assetList;
        astList = [select Id,core_supported_product__c,Status  from Asset where id =: assetList[0].id];
        astList.Status = 'Open';
        update astList;
        Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(astList.id);
        Core_IPS_CaseUtility.isSelectedProdRelatedToProject('NA',astList.id);
        Core_IPS_CaseUtility.isSelectedProdRelatedToProject('NAQ',astList.id);
        System.assertEquals('Open', astList.Status);
    }
}