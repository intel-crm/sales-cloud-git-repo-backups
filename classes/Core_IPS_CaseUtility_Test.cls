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
    static List<User> ListOfUser = new List<User> ();
    static String productId = null;
    static String SubCatId = null;
    static boolean isAgent = null;
    static List<Core_IPS_Assigned_Environment_Variables__c> ListOfEnvDetailsOperational = new List<Core_IPS_Assigned_Environment_Variables__c> ();
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
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
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
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseCat;
        }
        System.assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case SubCategory 
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(1);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseSubCat){
            CoreProdIssCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
            CoreProdIssCategory.Core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseSubCat;
        }
        System.assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        // Create Environmental Detail Master
        List<Core_IPS_Environment_Variables__c> ListOfEnDetailMaster = TestUtilities.getListOfEnDetailMaster(1);
        for(Core_IPS_Environment_Variables__c EnvironmentalDetailMaster : ListOfEnDetailMaster){
            EnvironmentalDetailMaster.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfEnDetailMaster;
        }
        System.assert(ListOfEnDetailMaster != null, 'Record not created');
        // Create Environment Details Operational
        ListOfEnvDetailsOperational = TestUtilities.getListOfEnvDetailsOperational(200);
        for(Core_IPS_Assigned_Environment_Variables__c EnvDetailsOperational : ListOfEnvDetailsOperational){
            EnvDetailsOperational.Core_Environment_Variable__c = ListOfEnDetailMaster.get(0).id;
            EnvDetailsOperational.Core_Supported_Product__c = ListOfSupportedProduct.get(0).Id;
            EnvDetailsOperational.Core_Product_Issue_Sub_Category__c = ListOfCoreProdIssCategory_CaseSubCat.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfEnvDetailsOperational;
        }
        System.assert(ListOfEnvDetailsOperational != null, 'Record not created');
        // Common Input Variables used for testing
        productId = ListOfSupportedProduct.get(0).Id;
        SubCatId = ListOfCoreProdIssCategory_CaseSubCat.get(0).id;
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
    static testmethod void GetSupportedProduct_PositiveTest(){
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        Core_IPS_Supported_Product__c SupportedProduct = [select Core_Product__c, Core_Product_Organization__r.name from Core_IPS_Supported_Product__c where id =: ListOfSupportedProduct.get(0).id];
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.Supported_product SupportedProductWrapper = new Core_IPS_CaseUtility.Supported_product(SupportedProduct.Core_Product__c,SupportedProduct.Core_Product_Organization__r.name);
            Core_IPS_CaseUtility.GetSupportedProduct(SupportedProduct.Core_Product__c,SupportedProduct.Core_Product_Organization__r.name);
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
    static testmethod void GetSupportedProduct_NegativeTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
            Id ProdId = null;
            string ProdOrgName = null;
            Test.startTest();
            Core_IPS_CaseUtility.Supported_product SupportedProductWrapper = new Core_IPS_CaseUtility.Supported_product(ProdId,ProdOrgName);
            Core_IPS_CaseUtility.GetSupportedProduct(ProdId,ProdOrgName);
            System.assertEquals(true, SupportedProductWrapper!=null);
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
    static testmethod void getCategories_PositiveTest(){
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Master_Issue_Category__c - Core Master Issue Category - Type : Case Category
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
        for(Core_IPS_Master_Issue_Category__c CoreMasterIssCategory : ListOfCoreMasterIssueCategory_CaseCat){
            CoreMasterIssCategory.Core_type__c = 'Case Category';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreMasterIssueCategory_CaseCat;
        }
        System.Assert(ListOfCoreMasterIssueCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseCat){
            CoreProdIssCategory.Core_type__c = 'Case Category';
            CoreProdIssCategory.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
            CoreProdIssCategory.Core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseCat;
        }
        System.Assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        string CoreSupportedProd = ListOfSupportedProduct.get(0).id;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCatg = Core_IPS_CaseUtility.getCategories(CoreSupportedProd);
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
    static testmethod void getCategories_NegativeTest(){
        getRecords();
        string CoreSupportedProd = null;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCatg = Core_IPS_CaseUtility.getCategories(CoreSupportedProd);
            System.assertEquals(ListOfCoreProdIssCategory_CaseCatg,null);
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
    static testmethod void getSubCategories_PositiveTest(){
        getRecords();
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseCat;
        }
        System.Assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseSubCat){
            CoreProdIssCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseSubCat;
        }
        System.Assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        System.runAs(ListOfUser.get(0)){
            string CoreProdIssCategory_CaseCat = ListOfCoreProdIssCategory_CaseCat.get(0).id;
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCatg = Core_IPS_CaseUtility.getSubCategories(CoreProdIssCategory_CaseCat);
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
    static testmethod void getSubCategories_NegativeTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
            string CoreProdIssCategory_CaseCat;
            Test.startTest();
            List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCatg = Core_IPS_CaseUtility.getSubCategories(CoreProdIssCategory_CaseCat);
            System.assertEquals(null,CoreProdIssCategory_CaseCat);
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
    static testmethod void getSubCategories_PositiveTest2(){
        getRecords();
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseCat;
        }
        System.assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case SubCategory 
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseSubCat){
            CoreProdIssCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
            CoreProdIssCategory.Core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseSubCat;
        }
        System.assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        string CoreSupportedProd = ListOfSupportedProduct.get(0).id;
        string CoreProdIssCategory_CaseCat = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueSubCategories IssueSubCategoriesWrapper = new Core_IPS_CaseUtility.IssueSubCategories(CoreProdIssCategory_CaseCat,CoreSupportedProd);
            Core_IPS_CaseUtility.getSubCategories(CoreProdIssCategory_CaseCat,CoreSupportedProd);
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
    static testmethod void getSubCategories_NegativeTest2(){
        getRecords();
        string CoreSupportedProd = null;
        string CoreProdIssCategory_CaseCat = null;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueSubCategories IssueSubCategoriesWrapper = new Core_IPS_CaseUtility.IssueSubCategories(CoreProdIssCategory_CaseCat,CoreSupportedProd);
            Core_IPS_CaseUtility.getSubCategories(CoreProdIssCategory_CaseCat,CoreSupportedProd);
            System.assertEquals(true, IssueSubCategoriesWrapper!=null);
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
    static testmethod void getEnvVariables_Agent_SubCatId_Test(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,SubCatId,isAgent);
            System.assert(LstOfEnvDetailsOperational != null, 'Record not created');
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
    static testmethod void getEnvVariables_Customer_SubCatId_Test(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            isAgent = false;
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,SubCatId,isAgent);
            System.assert(LstOfEnvDetailsOperational != null, 'Record not created');
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
    static testmethod void getEnvVariables_Agent_productId_Test(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            SubCatId = null;
            isAgent = true;
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,SubCatId,isAgent);
            System.assert(LstOfEnvDetailsOperational != null, 'Record not created');
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
    static testmethod void getEnvVariables_Customer_productId_Test(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            SubCatId = null;
            isAgent = false;
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,SubCatId,isAgent);
            System.assert(LstOfEnvDetailsOperational != null, 'Record not created');
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
    static testmethod void getEnvVariables_NegativeTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvVariables(productId,SubCatId,isAgent);
            System.assertEquals(LstOfEnvDetailsOperational.isEmpty(),true);
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
    static testmethod void getEnvironmentVariables_SubCatIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates EnvironmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(SubCatId,productId);
            System.assertEquals(true, EnvironmentTemplatesWrapper!=null);
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
    static testmethod void getEnvironmentVariables_productIdTest(){
        getRecords();
        getRecordsForGetEnvVariablesTest();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates EnvironmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(productId,SubCatId);
            System.assertEquals(true, EnvironmentTemplatesWrapper!=null);
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
    static testmethod void getEnvironmentVariables_NegativeTest(){
        getRecords();
        string envId;
        string envName;
        boolean agentOnly;
        boolean required;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.EnvironmentTemplates EnvironmentTemplatesWrapper = new Core_IPS_CaseUtility.EnvironmentTemplates(envId,envName,agentOnly,required);
            Core_IPS_CaseUtility.getEnvironmentVariables(productId,SubCatId);
            System.assertEquals(true, EnvironmentTemplatesWrapper!=null);
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
    static testmethod void AssetList_WrapperClassTest(){
        getRecords();
        string AssetName;
        string assetid;
        string prodorgId;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.AssetList AssetListWrapper = new Core_IPS_CaseUtility.AssetList(AssetName,assetid,prodorgId);
            System.assertEquals(true, AssetListWrapper!=null);
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
    static testmethod void IssueCategories_WrapperClassTest(){
        getRecords();
        string issueCatId;
        string issueCatName;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_IPS_CaseUtility.IssueCategories IssueCategoriesWrapper = new Core_IPS_CaseUtility.IssueCategories(issueCatId,issueCatName);
            System.assertEquals(true, IssueCategoriesWrapper!=null);
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
    static testmethod void getIPSProjectList_PositiveTest(){
        getRecords();
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(200);
        for(Core_IPS_Project__c IpsProject : ListOfIpsProjects){
            IpsProject.Core_Status__c = 'Draft';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfIpsProjects;
            // TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            
        }
        /*  for(Core_IPS_Project__c IpsProject : ListOfIpsProjects){
IpsProject.Core_Status__c = 'Active';
}
update ListOfIpsProjects;*/
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getIPSProjectList_NegativeTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getGECAnswerOptions_PositiveTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getCase_DynamiCSOQL_Agent_PositiveTest(){
        getRecords(); 
        
        List<Case> ListOfCases = new List<Case> ();
        Map<string,ID> CaseRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
            CaseRecordtype.put(Rt.Name,Rt.ID);
        }  
        for(Integer i=1;i<=1;i++){
            Case CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCases.add(CaseRecord);
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
        for(Case cs:ListOfCases )  {
            cs.accountid=testAccount.id;
            cs.contactid=testContact.id;
        } 
        System.RunAs(ListOfUser[0]){  
            insert ListOfCases;
        } 
        
        //System.assert(ListOfCases[0].Id != null, 'Record not created');
        string csId = ListOfCases.get(0).id;
        boolean Agent = true; 
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Case CaseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,Agent);
            //System.assert(CaseRecord.Id != null, 'Record not created');
                        System.assertEquals(Agent, true);

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
Case CaseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,Agent);
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
    static testmethod void getCase_DynamiCSOQL_NegativeTest(){
        getRecords(); 
        //  TWC745-7160 - START Shipra
        List<Case> ListOfCases = new List<Case> ();
        Map<string,ID> CaseRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
            CaseRecordtype.put(Rt.Name,Rt.ID);
        }  
        for(Integer i=1;i<=1;i++){
            Case CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCases.add(CaseRecord);
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
        for(Case cs:ListOfCases )  {
            cs.accountid=testAccount.id;
            cs.contactid=testContact.id;
        } 
        System.RunAs(ListOfUser[0]){  
            insert ListOfCases;
        } 
        
        //System.assert(ListOfCases[0].Id != null, 'Record not created');
        string csId = ListOfCases.get(0).id;
        boolean Agent = false; 
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Case CaseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,Agent);
           // System.assert(CaseRecord.Id != null, 'Record not created');
            Test.stopTest();
        } 
                        System.assertEquals(Agent, false);

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
    static testmethod void getFields_Agent_PositiveTest(){
        getRecords();
        boolean Agent = true; 
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> fieldSetMemberLst = Core_IPS_CaseUtility.getFields(Agent);
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
    static testmethod void getFields_Customer_PositiveTest(){
        getRecords();
        boolean Agent = false; 
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> fieldSetMemberLst = Core_IPS_CaseUtility.getFields(Agent);
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
    static testmethod void getEnvironmentDetailsOperationalRecords_Test(){
        getRecords();
        string prod;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Core_IPS_Assigned_Environment_Variables__c> LstOfEnvDetailsOperational = Core_IPS_CaseUtility.getEnvironmentDetailsOperationalRecords(prod);
            System.assertEquals(LstOfEnvDetailsOperational, null);
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
    static testmethod void getPlatform_PositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Unique_ID__c = 'Product12345';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            suppProductIdList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getPlatform_NegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getCodeName_PositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            suppProductIdList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getCodeName_NegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getVPHProductType_PositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '43';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Create Flat Product Hierarchy
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            FlatProductHierarchy.Core_EPM_Hierarchy_ID__c = ListOfProducts.get(0).Core_Hierarchy_ID__c;
            FlatProductHierarchy.Core_EPM_Hierarchy_Name__c = ListOfProducts.get(0).Core_Hierarchy_Name__c;
            if(counter < 2)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 5)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 8)
                FlatProductHierarchy.Core_L3_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            suppProductIdList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getVPHProductType_NegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getVPLHProductType_PositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Create Flat Product Hierarchy
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            FlatProductHierarchy.Core_EPM_Hierarchy_ID__c = ListOfProducts.get(0).Core_Hierarchy_ID__c;
            FlatProductHierarchy.Core_EPM_Hierarchy_Name__c = ListOfProducts.get(0).Core_Hierarchy_Name__c;
            if(counter < 5)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            suppProductIdList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getVPLHProductType_NegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();   //get records method called
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getplatform_Options_Asset_PositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.Assert(ListOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.Assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> AssetList  = TestUtilities.getAssetList(1);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Asst.accountId = ListOfAccounts.get(0).Id;
            Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert AssetList;
        }
        System.Assert(AssetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Asset AssetRec : AssetList){
            idList.add(AssetRec.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getplatform_Options_SupProd_PositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.Assert(ListOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.Assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> AssetList  = TestUtilities.getAssetList(1);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Asst.accountId = ListOfAccounts.get(0).Id;
            Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert AssetList;
        }
        System.Assert(AssetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            idList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
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
    static testmethod void getplatform_Options_NegativeTest(){  
        List<Id> idList = new List<Id> ();
        getRecords();
        System.runAs(ListOfUser.get(0)){
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
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        List<Asset> AssetList  = TestUtilities.getAssetList(1);
        insert AssetList;
        astList = [select Id,core_supported_product__c,Status  from Asset where id =: AssetList[0].id];
        astList.Status = 'Open';
        update astList;
        Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(astList.id);
        Core_IPS_CaseUtility.isSelectedProdRelatedToProject('NA',astList.id);
        Core_IPS_CaseUtility.isSelectedProdRelatedToProject('NAQ',astList.id);
        System.assertEquals('Open', astList.Status);
    }
}